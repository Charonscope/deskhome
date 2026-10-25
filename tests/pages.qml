// Loads every settings page outside Plasma with a fake `plasmoid` and fails if one
// cannot be created (e.g. a missing import breaks a whole page, as in 1.0.0–1.0.1).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/pages.qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: window
    visible: true
    width: 900
    height: 700

    QtObject {
        id: plasmoid
        property var configuration: ({
            url: "http://ha.test:8123", language: "de", items: "[]",
            autoBackupFile: "", itemDisplayDefault: 1
        })
    }

    // used by ConfigItem when it is shown inside the tile list
    property var services: ({ getNames: () => [], getService: () => ({ filterFields: () => [], findField: () => null }) })
    property var entities: ({})
    property var entityAreas: ({ areas: [], areaOf: {} })

    readonly property var pages: [
        ["ConfigGeneral.qml", { cfg_url: "http://ha.test:8123", cfg_language: "de" }],
        ["ConfigItems.qml", { cfg_items: "[]", cfg_autoBackupFile: "", cfg_itemDisplayDefault: 1 }],
        ["ConfigLook.qml", {}],
        ["ConfigItem.qml", { item: { entity_id: "light.test", domain: "light", colspan: 0.5 } }]
    ]
    property int done: 0
    property int failed: 0

    Repeater {
        model: window.pages.length
        delegate: Loader {
            Component.onCompleted: setSource(Qt.resolvedUrl("../contents/ui/" + window.pages[index][0]), window.pages[index][1])
            onStatusChanged: {
                if (status !== Loader.Ready && status !== Loader.Error) return
                const ok = status === Loader.Ready
                console.log((ok ? "PASS " : "FAIL ") + window.pages[index][0])
                if (!ok) window.failed++
                if (++window.done === window.pages.length) Qt.exit(window.failed ? 1 : 0)
            }
        }
    }

    // The tile editor (right-click menu) is a separate window, not a page
    Component.onCompleted: {
        const c = Qt.createComponent(Qt.resolvedUrl("../contents/ui/TileEditWindow.qml"))
        const w = c.status === Component.Ready ? c.createObject(window, { index: 0, config: { entity_id: "sensor.test", name: "Test" } }) : null
        console.log((w ? "PASS " : "FAIL ") + "TileEditWindow.qml" + (w ? "" : ": " + c.errorString()))
        if (!w) window.failed++
        else w.destroy()
    }

    Timer {
        interval: 15000
        running: true
        onTriggered: {
            console.log("FAIL timeout: only " + window.done + " of " + window.pages.length + " pages finished")
            Qt.exit(1)
        }
    }
}
