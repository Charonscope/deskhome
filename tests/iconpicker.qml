// Opens the icon picker outside Plasma: search and choosing an icon.
// (Popups draw on their own layer, so there is no rendered image of it.)
// Usage: QT_QPA_PLATFORM=offscreen qml tests/iconpicker.qml
import QtQuick
import QtQuick.Controls

import "../contents/ui"

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 560

    QtObject {
        id: plasmoid
        property var configuration: ({ language: "en" })
    }

    property string chosen: ""
    IconPicker {
        id: picker
        current: "mdi:fan off"
        onPicked: icon => window.chosen = icon
    }

    function check(name, ok, detail) {
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": " + detail))
        return ok
    }

    Component.onCompleted: picker.open()

    Timer {
        interval: 800
        running: true
        onTriggered: {
            const results = [
                check("all icons listed", picker.tr("icon.count", 1) === "1 icons", ""),
                check("search with several words", picker.matches.length > 0 && picker.matches.every(n => n.includes("fan") && n.includes("off")), JSON.stringify(picker.matches.slice(0, 5))),
                check("fan-off found", picker.matches.includes("fan-off"), JSON.stringify(picker.matches))
            ]
            picker.choose("fan-off")
            results.push(check("choosing delivers mdi:<name>", window.chosen === "mdi:fan-off", window.chosen))
            Qt.exit(results.every(x => x) ? 0 : 1)
        }
    }
}
