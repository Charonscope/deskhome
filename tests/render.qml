// Renders the widget's tile view outside Plasma with fake data and saves a PNG.
// Usage: QT_QPA_PLATFORM=offscreen qml tests/render.qml -- <out.png> [lost|ok]
import QtQuick
import QtQuick.Controls

import "../contents/ui"
import "../contents/code/i18n.mjs" as I18n

ApplicationWindow {
    id: window
    visible: true
    width: 560
    height: 520
    color: "#5a6470"

    readonly property var args: Qt.application.arguments.slice(Qt.application.arguments.indexOf("--") + 1)

    QtObject {
        id: plasmoid
        property string id: "test"
        property bool configurationRequired: false
        property int formFactor: 0
        property var configuration: ({
            url: "http://ha.test:8123", language: "en", flat: true,
            tileOpacity: 78, tileCustomColor: false, tileColor: "#2e3440", tileRadius: 8, tileBorder: true,
            levelBorder: true, activeFrame: true, tileScale: 100, tileSpacing: 6, labelScale: 100, valueScale: 100,
            showMinMax: true, showTrend: true, graphHeight: 42, graphLineWidth: 1.5, graphFill: true,
            graphCustomColor: false, graphColor: "#88c0d0"
        })
    }

    QtObject {
        id: ha
        property bool ready: window.args[1] !== "lost"
        property bool authFailed: false
        property var disconnectedSince: new Date(2026, 9, 24, 14, 5)
        function callService() { return Promise.resolve() }
    }

    Item {
        id: root
        property bool expanded: true
        property var look: plasmoid.configuration
        property string lang: "en"
        function tr(key, ...args) { return I18n.tr(lang, key, ...args) }
        property color tileFillColor: Qt.rgba(0.18, 0.2, 0.25, 0.78)
        property real tileScale: 1
        property real labelScale: 1
        property real labelGrow: 1
        property real defaultPt: 10
        property real smallPt: 8
        property bool tileBackgrounds: true
        property bool connectionLost: !ha.ready
        property string connectionMessage: tr("conn.lost", "14:05")
    }

    QtObject {
        id: store
        property bool initialized: true
        property int historyRevision: 1
        readonly property var points: {
            const now = Date.now(), out = []
            for (let i = 0; i <= 48; i++) out.push([now - (48 - i) * 1800000, 8 + 3 * Math.sin(i / 7)])
            return out
        }
        function history(id) { return id.startsWith("sensor.") ? points : [] }
        property ListModel itemModel: ListModel {
            Component.onCompleted: {
                const base = { attributes: {}, default_action: {}, dclick_action: {}, scroll_action: {}, display: 1, hide_when_ok: false, light_color: "", brightness_pct: -1, device_class: "", unit: "", attribute: "", second_entity_id: "", value2: "", num2: NaN }
                const add = o => append(Object.assign({}, base, o))
                add({ entity_id: "sensor.outside", name: "Outside", kind: "sensor", value: "9.6 °C", num: 9.6, state: "9.6", level: 0, icon: "mdi:thermometer", colspan: 1, history_hours: 24, domain: "sensor", active: false })
                add({ entity_id: "sensor.humidity", name: "Outside humidity", kind: "sensor", value: "63%", num: 63, state: "63", level: 0, icon: "mdi:water-percent", colspan: 1, history_hours: 24, domain: "sensor", active: false })
                add({ entity_id: "sensor.desk_temp", name: "Desk climate", kind: "combo", value: "23.7 °C", num: 23.7, state: "23.7", level: 0, icon: "mdi:thermometer", colspan: 1, history_hours: 24, domain: "sensor", active: false, second_entity_id: "sensor.desk_humidity", value2: "45%", num2: 45 })
                add({ entity_id: "light.desk", name: "Desk lamp", kind: "switch", value: "on", num: NaN, state: "on", level: 0, icon: "mdi:lightbulb", colspan: 0.5, history_hours: 0, domain: "light", active: true, brightness_pct: 60, light_color: "#ffcc66" })
                add({ entity_id: "light.kitchen", name: "Kitchen", kind: "switch", value: "off", num: NaN, state: "off", level: 0, icon: "mdi:lightbulb-outline", colspan: 0.5, history_hours: 0, domain: "light", active: false })
                add({ entity_id: "binary_sensor.hall", name: "Hallway motion", kind: "status", value: "unavailable", num: NaN, state: "unavailable", level: 2, icon: "mdi:motion-sensor", colspan: 1, history_hours: 0, domain: "binary_sensor", active: false })
                // hidden while ok -> must show up in the "1 more check OK" summary tile
                add({ entity_id: "sensor.battery_ok", name: "Bedroom battery", kind: "status", value: "100%", num: 100, state: "100", level: 0, icon: "mdi:battery", colspan: 1, history_hours: 0, domain: "sensor", active: false, hide_when_ok: true })
            }
        }
    }

    // Tiles arriving while the view already exists (as with a live connection) went missing
    // in a GridLayout-based version; add one late to cover that case.
    Timer {
        interval: 500
        running: true
        onTriggered: store.itemModel.append(Object.assign({}, store.itemModel.get(0), {
            entity_id: "sensor.late", name: "Late tile", kind: "status", value: "44%", num: 44, state: "44",
            level: 1, icon: "mdi:battery", colspan: 1, history_hours: 0
        }))
    }

    readonly property var expectedTexts: ["Outside", "Outside humidity", "Desk climate", "45%", "Desk lamp", "Kitchen", "Hallway motion", "Late tile", "1 more check OK"]

    FullRepresentation {
        id: view
        anchors.fill: parent
        anchors.margins: 12
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: {
            if (window.args[2] === "dump") window.dump(view, 0)
            const problems = window.verify()
            for (const p of problems) console.log("FAIL " + p)
            view.grabToImage(r => { r.saveToFile(window.args[0]); console.log("saved " + window.args[0]); Qt.exit(problems.length ? 1 : 0) })
        }
    }

    // Every expected tile text must be visible and lie fully inside the view
    function verify() {
        const found = {}
        const walk = item => {
            if (item.text !== undefined && item.visible && item.opacity > 0 && window.expectedTexts.includes(item.text)) {
                const p = item.mapToItem(view, 0, 0)
                found[item.text] = p.x >= 0 && p.y >= 0 && p.x + item.width <= view.width + 1 && item.width > 0
            }
            for (let i = 0; i < item.children.length; i++) walk(item.children[i])
        }
        walk(view)
        const problems = []
        for (const t of window.expectedTexts) {
            if (!(t in found)) problems.push("tile text not shown: " + t)
            else if (!found[t]) problems.push("tile outside the view: " + t)
        }
        return problems
    }

    // Debug aid: lists every item that has a text, with its geometry
    function dump(item, depth) {
        if (item.text !== undefined && item.visible && item.text !== "") {
            const p = item.mapToItem(view, 0, 0)
            console.log("  ".repeat(Math.min(depth, 6)) + JSON.stringify(item.text) + " @" + Math.round(p.x) + "," + Math.round(p.y) + " " + Math.round(item.width) + "x" + Math.round(item.height))
        }
        for (let i = 0; i < item.children.length; i++) dump(item.children[i], depth + 1)
    }
}
