import QtQuick

import "../code/problems.mjs" as Problems

// Lists devices that are gone (unavailable for a while) and motion sensors that hang on "on",
// across all of Home Assistant, like the battery list. Checked every two minutes: following
// every state change of every entity would cost far more than it brings.
QtObject {
    id: watch
    // a Client; typed loosely so tests can pass a fake connection
    property QtObject client
    // 0 = off
    property int unavailableMinutes: 0
    property int stuckHours: 0
    // entity ids or patterns with * that are never listed
    property string ignore: ""
    readonly property bool enabled: (unavailableMinutes > 0 || stuckHours > 0) && !!client
    // [{ kind, name, device_id, entity_ids, since }] (see problems.mjs)
    property var problems: []
    // whether a check has run (the summary tile counts a clean result as a passed check)
    property bool checked: false

    property var _registry: null

    onEnabledChanged: Qt.callLater(check)
    onUnavailableMinutesChanged: Qt.callLater(check)
    onStuckHoursChanged: Qt.callLater(check)
    onIgnoreChanged: Qt.callLater(check)
    onClientChanged: {
        _registry = null
        Qt.callLater(check)
    }
    property Connections _ready: Connections {
        target: watch.client
        function onReadyChanged() { Qt.callLater(watch.check) }
    }

    function check() {
        if (!enabled || !client.ready) {
            problems = []
            checked = false
            return
        }
        const registry = _registry ? Promise.resolve(_registry) : client.getRegistry().then(r => _registry = r)
        Promise.all([client.getStates(), registry]).then(([states, reg]) => {
            problems = Problems.findProblems(states, reg, { unavailableMinutes, stuckHours, ignore }, Date.now())
            checked = true
        }, () => {})
    }

    property Timer _poll: Timer {
        interval: 120000
        repeat: true
        running: watch.enabled
        onTriggered: watch.check()
    }
    // new devices and renamed ones: read the registries again now and then
    property Timer _reload: Timer {
        interval: 6 * 3600 * 1000
        repeat: true
        running: watch.enabled
        onTriggered: watch._registry = null
    }
}
