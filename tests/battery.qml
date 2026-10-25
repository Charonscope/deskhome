// Checks BatteryWatch with a fake Home Assistant connection: finds battery sensors,
// follows live changes and applies the threshold.
// Usage: QT_QPA_PLATFORM=offscreen qml tests/battery.qml
import QtQuick

import "../contents/ui"

Item {
    function check(name, actual, expected) {
        const ok = JSON.stringify(actual) === JSON.stringify(expected)
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        return ok
    }

    QtObject {
        id: fakeClient
        property bool ready: true
        property var callback
        property var subscribed: []
        function getStates() {
            return Promise.resolve([
                { entity_id: "sensor.a_battery", state: "12", attributes: { device_class: "battery", unit_of_measurement: "%", friendly_name: "A" } },
                { entity_id: "sensor.b_battery", state: "80", attributes: { device_class: "battery", unit_of_measurement: "%", friendly_name: "B" } },
                { entity_id: "sensor.c_voltage", state: "3.1", attributes: { device_class: "battery", unit_of_measurement: "V" } },
                { entity_id: "sensor.temp", state: "21", attributes: { device_class: "temperature", unit_of_measurement: "°C" } }
            ])
        }
        function subscribeEntities(ids, cb) {
            subscribed = ids
            callback = cb
            cb({ a: { "sensor.a_battery": { s: "12", a: { friendly_name: "A" } }, "sensor.b_battery": { s: "80", a: { friendly_name: "B" } } } })
            return () => {}
        }
    }

    BatteryWatch {
        id: watch
        threshold: 20
    }

    // BatteryWatch.client is typed as Client, so the fake drives its functions directly
    Component.onCompleted: runTimer.start()

    Timer {
        id: runTimer
        interval: 50
        onTriggered: {
            watch._cancel = null
            watch.total = 0
            // drive the watch directly with the fake
            fakeClient.getStates().then(states => {
                const ids = watch.batteryIds(states)
                fakeClient.subscribeEntities(ids, watch.received)
                const r = [
                    check("only % battery sensors", fakeClient.subscribed, ["sensor.a_battery", "sensor.b_battery"]),
                    check("below threshold", watch.low.map(b => b.entity_id), ["sensor.a_battery"])
                ]
                fakeClient.callback({ c: { "sensor.b_battery": { "+": { s: "9" } } } })
                r.push(check("live change, lowest first", watch.low.map(b => b.name + " " + b.level), ["B 9", "A 12"]))
                watch.threshold = 10
                r.push(check("threshold change", watch.low.map(b => b.name), ["B"]))
                fakeClient.callback({ r: ["sensor.b_battery"] })
                r.push(check("removed sensor", watch.low.length, 0))
                Qt.exit(r.every(x => x) ? 0 : 1)
            })
        }
    }
}
