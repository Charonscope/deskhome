import QtQuick
import QtWebSockets

import "components"
import "../code/services.mjs" as Services

// Connection to the Home Assistant WebSocket API. One instance per URL is shared by all
// DeskHome widgets (see ClientFactory). It reconnects on its own with growing pauses and
// reports its state, so the widget can show when the values are stale.
BaseObject {
    id: client

    property string baseUrl
    property string token

    readonly property bool configured: !!baseUrl && !!token
    readonly property bool ready: _.authenticated
    // HA rejected the token: retrying is pointless until the token changes
    readonly property bool authFailed: _.authFailed
    property string errorString: ""
    // when the current connection was established / since when there is none (null = connected)
    property var connectedSince: null
    property var disconnectedSince: new Date()

    onConfiguredChanged: _.connect()
    onBaseUrlChanged: _.restart()
    onTokenChanged: _.restart()

    function subscribeEntities(entityIds, callback) {
        if (!entityIds || !_.authenticated) return
        const id = command({ type: "subscribe_entities", entity_ids: entityIds })
        _.subscriptions.set(id, callback)
        return () => unsubscribe(id)
    }

    function unsubscribe(id) {
        if (!_.subscriptions.has(id)) return Promise.resolve()
        _.subscriptions.delete(id)
        return commandAsync({ type: "unsubscribe_events", subscription: id }).catch(() => {})
    }

    function callService({ domain, service, target } = {}, data) {
        return commandAsync({ type: "call_service", domain, service, service_data: data, target })
    }

    function getStates(entities) {
        return commandAsync({ type: "get_states" })
            .then(s => entities ? s.filter(e => entities.includes(e.entity_id)) : s)
    }

    function getServices() {
        return commandAsync({ type: "get_services" }).then(Services.fromObject)
    }

    function getTranslations(language, category, integration) {
        return commandAsync({ type: "frontend/get_translations", category, language, integration })
    }

    // Areas from the registries: { areas: [{ area_id, name }], areaOf: { entity_id: area name } }.
    // An entity without its own area takes the area of its device.
    function getAreas() {
        return Promise.all([
            commandAsync({ type: "config/area_registry/list" }),
            commandAsync({ type: "config/device_registry/list" }).catch(() => []),
            commandAsync({ type: "config/entity_registry/list_for_display" })
        ]).then(([areas, devices, display]) => {
            const areaName = {}
            for (const a of areas) areaName[a.area_id] = a.name
            const deviceArea = {}
            for (const d of devices) deviceArea[d.id] = d.area_id
            const areaOf = {}
            for (const e of display.entities || []) {
                const id = e.ai || deviceArea[e.di]
                if (id && areaName[id]) areaOf[e.ei] = areaName[id]
            }
            const sorted = areas.map(a => ({ area_id: a.area_id, name: a.name }))
            sorted.sort((a, b) => a.name.localeCompare(b.name))
            return { areas: sorted, areaOf }
        })
    }

    function getThemes() {
        return commandAsync({ type: "frontend/get_themes" })
    }

    function getHistory(entityIds, startTime) {
        return commandAsync({
            type: "history/history_during_period",
            start_time: startTime.toISOString(),
            entity_ids: entityIds,
            minimal_response: true,
            no_attributes: true,
            significant_changes_only: false
        })
    }

    function command(message) {
        const id = _.nextId++
        _.send(Object.assign({ id }, message))
        return id
    }

    function commandAsync(message) {
        if (!_.authenticated) {
            return Promise.reject({ code: "not-connected", message: "Not connected to Home Assistant" })
        }
        return new Promise((resolve, reject) => {
            const id = _.nextId++
            _.pending.set(id, { resolve, reject })
            _.send(Object.assign({ id }, message))
        })
    }

    WebSocket {
        id: socket
        active: false
        url: client.baseUrl ? client.baseUrl.replace(/^http/, "ws") + "/api/websocket" : ""
        onStatusChanged: _.socketStatusChanged(socket.status)
        onTextMessageReceived: message => _.received(JSON.parse(message))
    }

    // Reconnect with growing pauses so an offline HA is not hammered
    Timer {
        id: reconnectTimer
        onTriggered: {
            if (!_.authenticated && socket.status !== WebSocket.Connecting && socket.status !== WebSocket.Open) {
                _.connect()
            }
        }
    }

    // Detects silently dead connections (e.g. network cable pulled: the socket is never
    // closed). Ping every 15 s; no answer within 5 s means the connection is gone.
    Timer {
        interval: 15000
        repeat: true
        running: _.authenticated
        onTriggered: {
            client.command({ type: "ping" })
            pongTimer.restart()
        }
    }

    Timer {
        id: pongTimer
        interval: 5000
        onTriggered: socket.active = false
    }

    QtObject {
        id: _
        property bool authenticated: false
        property bool authFailed: false
        // last time anything arrived; a lost connection is dated to this moment
        property var lastMessageAt: new Date()
        property int nextId: 1
        property int failures: 0
        readonly property var pending: new Map()
        readonly property var subscriptions: new Map()
        readonly property var delays: [2000, 5000, 10000, 30000, 60000]

        function connect() {
            if (!client.configured || authFailed) return
            socket.active = false
            socket.active = true
        }

        function restart() {
            authFailed = false
            failures = 0
            connect()
        }

        function send(message) {
            socket.sendTextMessage(JSON.stringify(message))
        }

        function socketStatusChanged(status) {
            if (status === WebSocket.Error) client.errorString = socket.errorString
            if (status === WebSocket.Closed || status === WebSocket.Error) connectionLost()
        }

        function connectionLost() {
            if (authenticated) {
                client.disconnectedSince = lastMessageAt
                client.connectedSince = null
            }
            authenticated = false
            pongTimer.stop()
            for (const p of pending.values()) p.reject({ code: "connection-lost", message: "Connection lost" })
            pending.clear()
            // subscription ids are only valid for the connection that created them
            subscriptions.clear()
            if (authFailed || !client.configured) return
            reconnectTimer.interval = delays[Math.min(failures, delays.length - 1)]
            failures++
            reconnectTimer.restart()
        }

        function received(msg) {
            lastMessageAt = new Date()
            pongTimer.stop()
            switch (msg.type) {
            case "auth_required":
                send({ type: "auth", access_token: client.token })
                break
            case "auth_ok":
                failures = 0
                client.errorString = ""
                client.connectedSince = new Date()
                client.disconnectedSince = null
                authenticated = true
                break
            case "auth_invalid":
                authFailed = true
                client.errorString = msg.message
                socket.active = false
                break
            case "pong":
                break
            case "result": {
                const p = pending.get(msg.id)
                if (!p) break
                pending.delete(msg.id)
                if (msg.success) p.resolve(msg.result)
                else p.reject(msg.error)
                break
            }
            case "event": {
                const callback = subscriptions.get(msg.id)
                if (callback) callback(msg.event)
                break
            }
            }
        }
    }

    Component.onDestruction: socket.active = false
}
