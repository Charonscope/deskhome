// Checks the entity search of the tile settings (several words, name, area, id).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/search.qml
import QtQuick
import QtQuick.Controls

import "../contents/ui/components"

ApplicationWindow {
    visible: true
    width: 400
    height: 300

    function check(name, actual, expected) {
        const ok = JSON.stringify(actual) === JSON.stringify(expected)
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        return ok
    }

    TextField {
        id: field
        Autocompletion {
            id: completion
            model: [
                { value: "sensor.flur_temp", title: "Flur Temperatur", subtitle: "sensor.flur_temp · Flur" },
                { value: "light.dirk_desktop", title: "Desktop-Licht", subtitle: "light.dirk_desktop · Dirk Desktop" },
                { value: "climate.wohnstube", title: "Wohnstube", subtitle: "climate.wohnstube · Wohnzimmer" }
            ]
        }
    }

    Component.onCompleted: {
        const ids = text => { field.text = text; return completion.getModel().map(e => completion.valueOf(e)) }
        const results = [
            check("by name", ids("licht"), ["light.dirk_desktop"]),
            check("by area", ids("wohnzimmer"), ["climate.wohnstube"]),
            check("by id", ids("sensor."), ["sensor.flur_temp"]),
            check("all words must match", ids("flur temp"), ["sensor.flur_temp"]),
            check("words in any field", ids("dirk licht"), ["light.dirk_desktop"]),
            check("no match", ids("keller"), []),
            check("empty shows all", ids("").length, 3)
        ]
        Qt.exit(results.every(r => r) ? 0 : 1)
    }
}
