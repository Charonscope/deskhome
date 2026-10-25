// Renders the widget's tile view outside Plasma with fake data and saves a PNG.
// Usage: QT_QPA_PLATFORM=offscreen qml tests/render.qml -- <out.png> [ok|lost|theme|big] [dump]
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
            levelBorder: true, activeFrame: true, tileScale: 100, tileSpacing: 6, labelScale: 100, valueScale: window.args[1] === "big" ? 150 : 100,
            showMinMax: true, showTrend: true, graphHeight: 42, graphLineWidth: 1.5, graphFill: true,
            graphCustomColor: false, graphColor: "#88c0d0",
            // "theme": colors from a (fake) Home Assistant theme plus an own label color
            colorSource: window.args[1] === "theme" ? "ha" : "plasma", haTheme: "",
            valueCustomColor: false, valueColor: "#ffffff",
            labelCustomColor: window.args[1] === "theme", labelColor: "#ffd27f", animations: true
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
        property color tileFillColor: Qt.rgba(palette.background.r, palette.background.g, palette.background.b, 0.78)
        Palette {
            id: palette
            look: plasmoid.configuration
            haThemes: ({
                default_theme: "fake",
                themes: { fake: { "primary-color": "#e91e63", "ha-card-background": "rgba(20, 60, 40, 0.5)", "success-color": "#00e676" } }
            })
        }
        readonly property alias accentColor: palette.accent
        readonly property alias textColor: palette.text
        readonly property alias mutedColor: palette.muted
        readonly property alias okColor: palette.ok
        readonly property alias warnColor: palette.warn
        readonly property alias critColor: palette.crit
        readonly property alias valueColor: palette.value
        readonly property alias labelColor: palette.label
        readonly property alias labelOpacity: palette.labelOpacity
        readonly property alias graphLineColor: palette.graph
        function levelColor(level, okColor) { return palette.levelColor(level, okColor) }
        property real tileScale: 1
        property int animationDuration: 200
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
                const base = { attributes: {}, default_action: {}, dclick_action: {}, scroll_action: {}, display: 1, hide_when_ok: false, light_color: "", brightness_pct: -1, device_class: "", unit: "", attribute: "", second_entity_id: "", value2: "", num2: NaN, current_temp: NaN, target_temp: NaN, temp_min: 7, temp_max: 35, temp_step: 0.5, current_humidity: NaN, hvac_action: "", heading: "" }
                const add = o => append(Object.assign({}, base, o))
                add({ entity_id: "sensor.outside", name: "Outside", kind: "sensor", value: "9.6 °C", num: 9.6, state: "9.6", level: 0, icon: "mdi:thermometer", colspan: 1, history_hours: 24, domain: "sensor", active: false })
                add({ entity_id: "sensor.humidity", name: "Outside humidity", kind: "sensor", value: "63%", num: 63, state: "63", level: 0, icon: "mdi:water-percent", colspan: 1, history_hours: 24, domain: "sensor", active: false })
                add({ entity_id: "sensor.desk_temp", name: "Desk climate", kind: "combo", value: "23.7 °C", num: 23.7, state: "23.7", level: 0, icon: "mdi:thermometer", colspan: 1, history_hours: 24, domain: "sensor", active: false, second_entity_id: "sensor.desk_humidity", value2: "45%", num2: 45 })
                add({ entity_id: "climate.living", heading: "Heating", name: "Living room", kind: "thermostat", value: "Auto", num: NaN, state: "auto", level: 0, icon: "mdi:thermostat", colspan: 1, history_hours: 0, domain: "climate", active: false, current_temp: 21.9, target_temp: 21, current_humidity: 52, hvac_action: "heating" })
                add({ entity_id: "light.desk", heading: "Lights", name: "Desk lamp", kind: "switch", value: "on", num: NaN, state: "on", level: 0, icon: "mdi:lightbulb", colspan: 0.5, history_hours: 0, domain: "light", active: true, brightness_pct: 60, light_color: "#ffcc66" })
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

    // A changed value counts to the new one: in between neither the old nor the new text is shown
    property bool sawCounting: false
    Timer {
        interval: 600
        running: true
        onTriggered: store.itemModel.setProperty(0, "value", "12.4 °C")
    }
    Timer {
        interval: 700
        running: true
        onTriggered: {
            const walk = item => {
                if (item.text !== undefined && /^\d+\.\d °C$/.test(item.text) && !["9.6 °C", "12.4 °C", "23.7 °C"].includes(item.text)) window.sawCounting = true
                for (let i = 0; i < item.children.length; i++) walk(item.children[i])
            }
            walk(view)
        }
    }

    readonly property var valueTexts: ["12.4 °C", "23.7 °C", "45%"]
    readonly property var expectedTexts: ["12.4 °C", "Outside", "Outside humidity", "Desk climate", "45%", "Heating", "Lights", "Living room", "heating", "Desk lamp", "Kitchen", "Hallway motion", "Late tile", "1 more check OK"]

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
            if (!window.sawCounting) problems.push("changed value did not count to the new one")
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
                const inside = p.x >= 0 && p.y >= 0 && p.x + item.width <= view.width + 1 && item.width > 0
                // names may be shortened (full name in the tooltip), values must be shown completely
                found[item.text] = !inside ? "outside" : item.truncated && window.valueTexts.includes(item.text) ? "truncated" : "ok"
            }
            for (let i = 0; i < item.children.length; i++) walk(item.children[i])
        }
        walk(view)
        const problems = []
        for (const t of window.expectedTexts) {
            if (!(t in found)) problems.push("tile text not shown: " + t)
            else if (found[t] === "outside") problems.push("tile outside the view: " + t)
            else if (found[t] === "truncated") problems.push("tile text cut off: " + t)
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
