// Checks the Desk Status logic without Plasma: reading the system values, the messages for
// Home Assistant's mobile app interface, lock events and the quick rules.
// Usage: QT_QPA_PLATFORM=offscreen qml tests/deskstatus.qml
import QtQuick

import "../contents/code/deskstatus.mjs" as DS

Item {
    property int failed: 0
    function check(name, actual, expected) {
        const ok = JSON.stringify(actual) === JSON.stringify(expected)
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        if (!ok) failed++
    }

    Component.onCompleted: {
        // ---- parse ----
        const first = DS.parse("SS=b false\nLH=no\nVOL=Volume: 0.45\nCPU=cpu  100 0 100 800 0 0 0 0 0 0\nMEM=1000 250 \n", null)
        check("unlocked", first.values.locked, false)
        check("status active", first.values.status, "active")
        check("volume", first.values.volume, 45)
        check("not muted", first.values.muted, false)
        check("no cpu on first call", first.values.cpu, undefined)
        check("memory", first.values.memory, 75)
        const second = DS.parse("SS=b false\nLH=no\nCPU=cpu  150 0 150 900 0 0 0 0 0 0", first.cpu)
        check("cpu from difference", second.values.cpu, 50)
        check("no volume without wpctl", second.values.volume, undefined)
        check("locked by screen saver", DS.parse("SS=b true\nLH=no", null).values.status, "locked")
        check("locked by logind", DS.parse("SS=\nLH=yes", null).values.locked, true)
        check("lock unknown", DS.parse("SS=\nLH=", null).values.locked, undefined)
        check("muted", DS.parse("VOL=Volume: 0.30 [MUTED]", null).values.muted, true)
        check("garbage", DS.parse("nonsense\n=x\nCPU=cpu a b", null).values, {})

        // ---- messages ----
        const reg = DS.registration({ deviceId: "id1", deviceName: "pc", version: "1.7.0" })
        check("registration", [reg.device_id, reg.app_id, reg.device_name, reg.supports_encryption], ["id1", "io.github.deskhome", "pc", false])
        const sensor = DS.registerSensor(DS.SENSORS.find(s => s.key === "cpu"), "pc CPU", 12)
        check("register cpu", sensor, { type: "register_sensor", data: { unique_id: "cpu", type: "sensor", name: "pc CPU", icon: "mdi:cpu-64-bit", state: 12, unit_of_measurement: "%", state_class: "measurement", entity_category: "diagnostic" } })
        check("register binary default", DS.registerSensor(DS.SENSORS.find(s => s.key === "locked"), "pc Locked").data.state, false)
        const upd = DS.updateStates({ status: "locked", locked: true, volume: 5 }, ["status", "locked", "cpu"])
        check("update", upd, { type: "update_sensor_states", data: [
            { unique_id: "status", type: "sensor", state: "locked", icon: "mdi:monitor-lock" },
            { unique_id: "locked", type: "binary_sensor", state: true, icon: "mdi:monitor-lock" }] })
        check("changed keys", DS.changedKeys({ status: "active", volume: 5 }, { status: "active", volume: 4 }, ["status", "volume", "cpu"]), ["volume"])

        // ---- events ----
        check("start unlocked", DS.events(undefined, false), ["start"])
        check("start locked", DS.events(undefined, true), [])
        check("unlock", DS.events(true, false), ["unlock"])
        check("lock", DS.events(false, true), ["lock"])
        check("no change", DS.events(false, false), [])
        check("unknown", DS.events(false, undefined), [])

        // ---- rules ----
        const rules = DS.parseRules(JSON.stringify([
            { trigger: "unlock", entity: "light.desk", action: "on", brightness: 60, condEntity: "sensor.lux", condOp: "below", condValue: "15" },
            { trigger: "weird", entity: "switch.fan", action: "off", enabled: false },
            null, 5
        ]))
        check("rules parsed", rules.length, 2)
        check("bad trigger -> unlock", rules[1].trigger, "unlock")
        check("disabled kept", rules[1].enabled, false)
        check("broken json", DS.parseRules("{oops"), [])
        check("dark enough", DS.conditionMet(rules[0], { state: "10" }), true)
        check("too bright", DS.conditionMet(rules[0], { state: "40" }), false)
        check("unavailable sensor", DS.conditionMet(rules[0], { state: "unavailable" }), false)
        check("no condition", DS.conditionMet(rules[1], undefined), true)
        check("light on with brightness", DS.serviceCall(rules[0]), { domain: "light", service: "turn_on", target: { entity_id: "light.desk" }, data: { brightness_pct: 60 } })
        check("switch off", DS.serviceCall(rules[1]), { domain: "switch", service: "turn_off", target: { entity_id: "switch.fan" }, data: {} })
        check("scene always on", DS.serviceCall({ entity: "scene.evening", action: "off", brightness: 0 }).service, "turn_on")
        check("sensor name without device", DS.sensorName(" Status "), "Status")
        check("device id", /^deskhome-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}$/.test(DS.newDeviceId()), true)

        Qt.exit(failed ? 1 : 0)
    }
}
