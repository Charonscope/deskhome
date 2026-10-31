// Checks the problem list (devices gone, motion sensors hanging) and the Home Assistant
// messages (notifications, repairs, updates) with a fake Home Assistant connection.
// Usage: QT_QPA_PLATFORM=offscreen qml tests/problems.qml
import QtQuick

import "../contents/ui"
import "../contents/code/problems.mjs" as Problems

Item {
    id: test
    property int failed: 0
    function check(name, actual, expected) {
        const ok = JSON.stringify(actual) === JSON.stringify(expected)
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        if (!ok) failed++
    }

    readonly property double now: Date.parse("2026-10-31T12:00:00Z")
    function at(hoursAgo) { return new Date(now - hoursAgo * 3600000).toISOString() }

    readonly property var states: [
        // device "Hue sensor": two entities gone for 3 h, listed once as the device
        { entity_id: "binary_sensor.hue_motion", state: "unavailable", last_changed: at(3), attributes: { friendly_name: "Hue motion" } },
        { entity_id: "sensor.hue_temperature", state: "unavailable", last_changed: at(2), attributes: { friendly_name: "Hue temperature" } },
        // diagnostic entity of the same device: does not count on its own
        { entity_id: "sensor.hue_signal", state: "unavailable", last_changed: at(3), attributes: {} },
        // gone for 10 minutes only
        { entity_id: "light.fresh", state: "unavailable", last_changed: at(1 / 6), attributes: { friendly_name: "Fresh" } },
        // no registry entry (YAML): listed by its own name
        { entity_id: "sensor.yaml_thing", state: "unavailable", last_changed: at(5), attributes: { friendly_name: "YAML thing" } },
        // ignored by pattern
        { entity_id: "sensor.old_meter", state: "unavailable", last_changed: at(50), attributes: {} },
        // buttons say nothing about reachability
        { entity_id: "button.restart", state: "unavailable", last_changed: at(9), attributes: {} },
        // hidden
        { entity_id: "switch.hidden", state: "unavailable", last_changed: at(9), attributes: {} },
        // motion sensor "on" for 30 h: stuck; another one "on" for 1 h: fine; a door "on" for 30 h: no motion sensor
        { entity_id: "binary_sensor.kitchen_motion", state: "on", last_changed: at(30), attributes: { device_class: "motion", friendly_name: "Kitchen motion" } },
        { entity_id: "binary_sensor.hall_motion", state: "on", last_changed: at(1), attributes: { device_class: "occupancy" } },
        { entity_id: "binary_sensor.door", state: "on", last_changed: at(30), attributes: { device_class: "door" } },
        { entity_id: "sensor.ok", state: "21", last_changed: at(40), attributes: {} },
        // router: one offline client switch, but the router itself works -> not listed
        { entity_id: "sensor.router_wan", state: "up", last_changed: at(40), attributes: {} },
        { entity_id: "switch.router_client_allow", state: "unavailable", last_changed: at(9), attributes: {} }
    ]
    readonly property var registry: ({
        entities: {
            "binary_sensor.hue_motion": { device_id: "d1", hidden: false, category: false },
            "sensor.hue_temperature": { device_id: "d1", hidden: false, category: false },
            "sensor.hue_signal": { device_id: "d1", hidden: false, category: true },
            "light.fresh": { device_id: "d2", hidden: false, category: false },
            "switch.hidden": { device_id: "d3", hidden: true, category: false },
            "binary_sensor.kitchen_motion": { device_id: "d4", hidden: false, category: false },
            "sensor.router_wan": { device_id: "d5", hidden: false, category: false },
            "switch.router_client_allow": { device_id: "d5", hidden: false, category: false }
        },
        deviceNames: { d1: "Hue sensor", d2: "Fresh lamp", d3: "Hidden", d4: "Kitchen sensor", d5: "Router" }
    })

    QtObject {
        id: fakeClient
        property bool ready: true
        property var callback
        property var subscribedTo: null
        function getStates() {
            return Promise.resolve(test.states.concat([
                { entity_id: "update.core", state: "on", attributes: {} },
                { entity_id: "update.zha", state: "off", attributes: {} },
                { entity_id: "update.esphome", state: "on", attributes: {} }
            ]))
        }
        function getRegistry() { return Promise.resolve(test.registry) }
        function getRepairs() { return Promise.resolve([{ issue_id: "a" }, { issue_id: "b" }]) }
        function subscribeMessage(message, cb) {
            subscribedTo = message.type
            callback = cb
            return () => callback = null
        }
    }

    property var popups: []
    HaMessages {
        id: messages
        client: fakeClient
        showCounts: true
        popups: true
        notify: (title, text) => test.popups.push(title + ": " + text)
    }

    Component.onCompleted: {
        const found = Problems.findProblems(states, registry, { unavailableMinutes: 30, stuckHours: 24, ignore: "sensor.old_*" }, now)
        // not listed: the router (only a client is offline), the lamp (gone for 10 min only),
        // the YAML entity (no device), the hidden switch, the button
        check("problems found", found.map(p => [p.kind, p.name, p.entity_ids.length]), [
            ["unavailable", "Hue sensor", 2],
            ["stuck", "Kitchen motion", 1]
        ])
        check("device gone since its last entity went", found[0].since, now - 2 * 3600000)
        check("device id for the link", found[0].device_id, "d1")
        check("lamp after a longer time", Problems.findProblems(states, registry, { unavailableMinutes: 5 }, now).map(p => p.name), ["Hue sensor", "Fresh lamp"])
        check("off means off", Problems.findProblems(states, registry, { unavailableMinutes: 0, stuckHours: 0 }, now).length, 0)
        check("only stuck sensors", Problems.findProblems(states, registry, { stuckHours: 12 }, now).map(p => p.name), ["Kitchen motion"])
        const ignore = Problems.ignoreMatcher("light.x, sensor.a_*")
        check("ignore exact", ignore("light.x"), true)
        check("ignore pattern", ignore("sensor.a_b"), true)
        check("ignore no partial match", ignore("light.xy"), false)
        check("dot is literal", Problems.ignoreMatcher("sensor.a")("sensorxa"), false)
        later.start()
    }

    // HaMessages starts on its own (Qt.callLater) and answers asynchronously
    Timer {
        id: later
        interval: 200
        onTriggered: {
            check("subscribed to HA notifications", fakeClient.subscribedTo, "persistent_notification/subscribe")
            fakeClient.callback({ type: "current", notifications: { n1: { title: "A", message: "x" }, n2: { title: "B", message: "y" } } })
            check("current notifications counted, no popup", [messages.notificationCount, test.popups.length], [2, 0])
            fakeClient.callback({ type: "added", notifications: { n3: { title: "New login", message: "from 10.0.0.5" } } })
            check("new notification pops up", test.popups, ["New login: from 10.0.0.5"])
            fakeClient.callback({ type: "removed", notifications: { n1: {} } })
            check("removed notification", messages.notificationCount, 2)
            check("repairs counted", messages.repairCount, 2)
            check("updates counted", messages.updateCount, 2)
            check("total", messages.total, 6)
            Qt.exit(test.failed ? 1 : 0)
        }
    }
}
