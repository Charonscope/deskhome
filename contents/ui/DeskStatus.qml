import QtQuick

import org.kde.plasma.plasma5support as P5Support

import "../code/deskstatus.mjs" as DS
import "../code/i18n.mjs" as I18n

// Desk Status (beta): reports this computer to Home Assistant and runs the quick rules.
// See code/deskstatus.mjs for how it works. Runs inside the widget, so only while the user
// is logged in and the widget is on the desktop or a panel.
QtObject {
    id: desk

    property var client                  // Client.qml (shared connection: token, URL, service calls)
    property var configuration           // plasmoid.configuration (device id, webhook and status are kept there)
    property string lang: "en"
    property string version: ""

    readonly property bool reporting: !!configuration?.deskStatusEnabled
    readonly property var sensorKeys: (configuration?.deskStatusSensors || "").split(",").filter(k => DS.SENSORS.some(s => s.key === k))
    readonly property var rules: DS.parseRules(configuration?.deskStatusRules)
    readonly property bool hasRules: rules.some(r => r.enabled && r.entity)
    readonly property bool active: (reporting || hasRules) && !!client?.baseUrl

    property var _values: ({})
    property var _sent: ({})
    property var _cpu: null
    property var _locked: undefined
    property string _hostname: ""
    property bool _registering: false
    property bool _sensorsRegistered: false
    property var _pendingEvents: []
    property int _counter: 0
    property double _lastFull: 0

    function tr(key, ...args) { return I18n.tr(lang, key, ...args) }

    readonly property string deviceName: (configuration?.deskStatusDeviceName || "").trim() || _hostname || "DeskHome PC"

    // Webhook of the registration, only valid for the Home Assistant it was made with
    function webhookId() {
        try {
            const w = JSON.parse(configuration?.deskStatusWebhook || "{}")
            return w.url === client?.baseUrl ? (w.id || "") : ""
        } catch (e) { return "" }
    }

    // Short status for the settings page: { state: "ok"|"error"|"off", text, time }
    function setInfo(state, text) {
        if (!configuration) return
        let old = {}
        try { old = JSON.parse(configuration.deskStatusInfo || "{}") } catch (e) {}
        if (old.state === state && old.text === text) return
        configuration.deskStatusInfo = JSON.stringify({ state, text, time: Date.now(), device: deviceName })
    }

    property var _timer: Timer {
        interval: Math.max(5, desk.configuration?.deskStatusInterval || 15) * 1000
        repeat: true
        triggeredOnStart: true
        running: desk.active
        onTriggered: desk.collect()
    }

    property var _exec: P5Support.DataSource {
        engine: "executable"
        property var callbacks: ({})
        onNewData: (sourceName, data) => {
            const cb = callbacks[sourceName]
            delete callbacks[sourceName]
            disconnectSource(sourceName)
            if (cb) cb(data.stdout || "")
        }
        function run(command, callback) {
            // a running number keeps each call apart (the engine caches by command text)
            const source = `${command} # ${++desk._counter}`
            callbacks[source] = callback
            connectSource(source)
        }
    }

    Component.onCompleted: _exec.run(DS.HOSTNAME_COMMAND, out => _hostname = out.trim())

    // logging out or removing the widget: say "off" (best effort, the session may already be gone)
    Component.onDestruction: {
        if (reporting && webhookId() && sensorKeys.includes("status")) {
            post(`${client.baseUrl}/api/webhook/${webhookId()}`, DS.updateStates({ status: "off" }, ["status"]), null, false)
        }
        fireEvents(["stop"])
    }

    onReportingChanged: {
        _sensorsRegistered = false
        _sent = {}
        if (!reporting) {
            // switched off in the settings: mark the computer as off once
            if (webhookId() && sensorKeys.includes("status")) {
                post(`${client.baseUrl}/api/webhook/${webhookId()}`, DS.updateStates({ status: "off" }, ["status"]))
            }
            setInfo("off", "")
        }
    }
    onSensorKeysChanged: { _sensorsRegistered = false; _sent = {} }
    onDeviceNameChanged: { _sensorsRegistered = false; _sent = {} }

    function collect() {
        _exec.run(DS.COLLECT_COMMAND, output => {
            const result = DS.parse(output, _cpu)
            _cpu = result.cpu
            _values = result.values
            const evs = DS.events(_locked, result.values.locked)
            if (result.values.locked !== undefined) _locked = result.values.locked
            fireEvents(evs)
            if (reporting) report()
        })
    }

    // ---- reporting -------------------------------------------------------------------------

    function report() {
        if (!client?.token) return
        if (!webhookId()) return register()
        if (!_sensorsRegistered) return registerSensors()
        // only what changed; everything every 5 minutes so Home Assistant stays current
        const full = Date.now() - _lastFull > 300000
        const keys = full ? sensorKeys.filter(k => k in _values) : DS.changedKeys(_values, _sent, sensorKeys)
        if (!keys.length) return
        const values = Object.assign({}, _values)
        post(`${client.baseUrl}/api/webhook/${webhookId()}`, DS.updateStates(values, keys), (ok, status, body) => {
            if (ok) {
                for (const k of keys) _sent[k] = values[k]
                if (full) _lastFull = Date.now()
                // a sensor Home Assistant does not know (deleted there): register again
                const unknown = Array.isArray(body) ? false : Object.values(body || {}).some(r => r?.success === false)
                if (unknown) _sensorsRegistered = false
                setInfo("ok", "")
            } else handleWebhookError(status)
        })
    }

    function register() {
        if (_registering) return
        _registering = true
        if (!configuration.deskStatusDeviceId) configuration.deskStatusDeviceId = DS.newDeviceId()
        const body = DS.registration({ deviceId: configuration.deskStatusDeviceId, deviceName, version })
        post(`${client.baseUrl}/api/mobile_app/registrations`, body, (ok, status, reply) => {
            _registering = false
            if (ok && reply?.webhook_id) {
                configuration.deskStatusWebhook = JSON.stringify({ url: client.baseUrl, id: reply.webhook_id })
                _sensorsRegistered = false
                setInfo("ok", "")
                report()
            } else {
                setInfo("error", status === 401 ? tr("desk.errAuth") : status === 404 ? tr("desk.errNoMobileApp") : tr("desk.errRegister", status || "–"))
            }
        }, true)
    }

    function registerSensors() {
        const keys = sensorKeys.slice()
        if (!keys.length) { _sensorsRegistered = true; return }
        let left = keys.length
        let failed = false
        for (const key of keys) {
            const def = DS.SENSORS.find(s => s.key === key)
            const msg = DS.registerSensor(def, DS.sensorName(deviceName, tr(["desk.sensor", key].join("."))), _values[key])
            post(`${client.baseUrl}/api/webhook/${webhookId()}`, msg, (ok, status) => {
                if (!ok) failed = true
                if (--left) return
                if (failed) return handleWebhookError(status)
                _sensorsRegistered = true
                _sent = {}
                _lastFull = 0
                report()
            })
        }
    }

    // 410 = the mobile app entry was deleted in Home Assistant: register again next time
    function handleWebhookError(status) {
        if (status === 410 || status === 404) {
            configuration.deskStatusWebhook = ""
            _sensorsRegistered = false
            setInfo("error", tr("desk.errGone"))
        } else {
            setInfo("error", tr("desk.errSend", status || "–"))
        }
    }

    // JSON POST. `auth` adds the token (only the registration needs it; the webhook is its own key).
    function post(url, body, callback, auth) {
        const xhr = new XMLHttpRequest()
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            let reply = null
            try { reply = JSON.parse(xhr.responseText || "null") } catch (e) {}
            const ok = xhr.status >= 200 && xhr.status < 300
            if (callback) callback(ok, xhr.status, reply)
        }
        xhr.open("POST", url)
        xhr.setRequestHeader("Content-Type", "application/json")
        if (auth) xhr.setRequestHeader("Authorization", "Bearer " + client.token)
        xhr.send(JSON.stringify(body))
    }

    // ---- quick rules -----------------------------------------------------------------------

    function fireEvents(evs) {
        if (!evs.length || !hasRules) return
        if (!client?.ready && evs.every(e => e !== "stop")) {
            // not connected yet (start of the session): try again for up to a minute
            _pendingEvents = _pendingEvents.concat(evs.map(e => ({ event: e, until: Date.now() + 60000 })))
            _retry.start()
            return
        }
        for (const ev of evs) runRules(ev)
    }

    property var _retry: Timer {
        interval: 3000
        repeat: true
        onTriggered: {
            const now = Date.now()
            desk._pendingEvents = desk._pendingEvents.filter(p => p.until > now)
            if (desk.client?.ready) {
                const evs = desk._pendingEvents.map(p => p.event)
                desk._pendingEvents = []
                for (const ev of evs) desk.runRules(ev)
            }
            if (!desk._pendingEvents.length) stop()
        }
    }

    function runRules(ev) {
        for (const rule of rules) {
            if (!rule.enabled || !rule.entity || rule.trigger !== ev) continue
            const run = () => {
                const call = DS.serviceCall(rule)
                client.callService({ domain: call.domain, service: call.service, target: call.target }, call.data)
                    .catch(e => console.warn("DeskHome Desk Status: rule failed", rule.entity, JSON.stringify(e)))
            }
            if (!rule.condEntity) { run(); continue }
            client.getStates([rule.condEntity]).then(list => {
                if (DS.conditionMet(rule, list[0])) run()
            }, () => {})
        }
    }
}
