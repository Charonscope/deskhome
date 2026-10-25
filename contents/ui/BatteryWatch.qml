import QtQuick

// Watches every battery sensor in Home Assistant (device class battery, unit %) and lists
// those below the threshold. The sensors are found on their own, no tiles are needed.
QtObject {
    id: watch
    property Client client
    // 0 = off
    property int threshold: 0
    readonly property bool enabled: threshold > 0 && !!client
    // [{ entity_id, name, level }], lowest first
    property var low: []
    property int total: 0

    property var _levels: ({})
    property var _cancel: null

    onEnabledChanged: Qt.callLater(restart)
    onThresholdChanged: update()
    onClientChanged: Qt.callLater(restart)
    // Connections instead of connect(): the client is shared and outlives this widget
    property Connections _ready: Connections {
        target: watch.client
        function onReadyChanged() { watch.restart() }
    }
    Component.onDestruction: stop()

    function stop() {
        if (typeof _cancel === "function") _cancel()
        _cancel = null
    }

    function restart() {
        stop()
        _levels = {}
        if (!enabled || !client.ready) {
            low = []
            total = 0
            return
        }
        client.getStates().then(states => {
            const ids = batteryIds(states)
            total = ids.length
            if (!ids.length) {
                update()
                return
            }
            _cancel = client.subscribeEntities(ids, received)
        }, () => {})
    }

    function batteryIds(states) {
        return states.filter(s => s.attributes?.device_class === "battery"
            && s.attributes?.unit_of_measurement === "%").map(s => s.entity_id)
    }

    function received(event) {
        const levels = Object.assign({}, _levels)
        for (const id in event.a || {}) {
            const e = event.a[id]
            levels[id] = { name: e.a?.friendly_name || id, state: e.s }
        }
        for (const id in event.c || {}) {
            const change = event.c[id]["+"] || {}
            const old = levels[id] || { name: id, state: "" }
            levels[id] = { name: change.a?.friendly_name || old.name, state: change.s ?? old.state }
        }
        for (const id of event.r || []) delete levels[id]
        _levels = levels
        update()
    }

    function update() {
        const result = []
        for (const id in _levels) {
            const level = parseFloat(_levels[id].state)
            if (!isNaN(level) && level < threshold) result.push({ entity_id: id, name: _levels[id].name, level })
        }
        result.sort((a, b) => a.level - b.level)
        low = result
    }

    // new devices appear without a restart
    property Timer rescan: Timer {
        interval: 6 * 3600 * 1000
        repeat: true
        running: watch.enabled
        onTriggered: watch.restart()
    }
}
