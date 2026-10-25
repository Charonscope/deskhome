// Checks the entity model in the QML engine, including values that went through a ListModel
// (nested arrays come back as array-like objects there).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/model.qml
import QtQuick

import "../contents/code/model.mjs" as Model

Item {
    ListModel { id: list }

    function check(name, actual, expected) {
        const ok = JSON.stringify(actual) === JSON.stringify(expected)
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        return ok
    }

    Component.onCompleted: {
        const config = { entity_id: "light.desk", domain: "light" }
        const first = new Model.Entity(config, { s: "on", a: { rgb_color: [255, 167, 87], brightness: 130 } })
        list.append(first)
        // HA sends only the changed brightness after dimming
        const update = new Model.EntityUpdate(config, { a: { brightness: 120 } }, list.get(0))
        const results = [
            check("light color from full state", first.light_color, "#ffa757"),
            check("light color kept after a brightness-only update", update.light_color, "#ffa757"),
            check("brightness updated", update.brightness_pct, 47),
            check("still on", update.active, true)
        ]
        Qt.exit(results.every(r => r) ? 0 : 1)
    }
}
