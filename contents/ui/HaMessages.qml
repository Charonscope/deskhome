import QtQuick

// Home Assistant's own messages on the desktop: its notifications (the bell in the sidebar),
// open repairs and available updates. New notifications can also pop up as desktop
// notifications; the counts are shown in a small tile.
QtObject {
    id: messages
    // a Client; typed loosely so tests can pass a fake connection
    property QtObject client
    // counts in a tile
    property bool showCounts: false
    // new HA notifications as desktop notifications
    property bool popups: false
    readonly property bool enabled: (showCounts || popups) && !!client
    // called with (title, message) for every notification that arrives while running
    property var notify: null

    property int notificationCount: 0
    // -1 = unknown (e.g. no admin rights for the repairs list)
    property int repairCount: -1
    property int updateCount: 0
    readonly property int total: notificationCount + Math.max(0, repairCount) + updateCount

    property var _cancel: null

    onEnabledChanged: Qt.callLater(restart)
    onClientChanged: Qt.callLater(restart)
    property Connections _ready: Connections {
        target: messages.client
        function onReadyChanged() { Qt.callLater(messages.restart) }
    }
    Component.onDestruction: stop()

    function stop() {
        if (typeof _cancel === "function") _cancel()
        _cancel = null
    }

    function restart() {
        stop()
        notificationCount = 0
        repairCount = -1
        updateCount = 0
        if (!enabled || !client.ready) return
        _cancel = client.subscribeMessage({ type: "persistent_notification/subscribe" }, received)
        refresh()
    }

    function received(event) {
        const list = event.notifications || {}
        if (event.type === "current") {
            notificationCount = Object.keys(list).length
            return
        }
        if (event.type === "added") {
            notificationCount += Object.keys(list).length
            if (popups && typeof notify === "function") {
                for (const id in list) notify(list[id].title || "Home Assistant", list[id].message || "")
            }
        } else if (event.type === "removed") {
            notificationCount = Math.max(0, notificationCount - Object.keys(list).length)
        }
    }

    // repairs and updates have no subscription: asked every ten minutes
    function refresh() {
        if (!enabled || !client.ready) return
        client.getRepairs().then(issues => repairCount = issues.length, () => repairCount = -1)
        client.getStates().then(states => {
            updateCount = states.filter(s => s.entity_id.startsWith("update.") && s.state === "on").length
        }, () => {})
    }

    property Timer _poll: Timer {
        interval: 600000
        repeat: true
        running: messages.enabled
        onTriggered: messages.refresh()
    }
}
