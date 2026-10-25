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
            labelCustomColor: window.args[1] === "theme", labelColor: "#ffd27f", animations: true, showLastChanged: true, valueWeight: 600, showSwitchState: window.args[1] !== "theme", secondCustomColor: false, secondColor: "#66bb6a"
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
        readonly property alias secondColor: palette.second
        readonly property alias valueWeight: palette.valueWeight
        function tileValueColor(e) { return palette.tileValue(e) }
        function tileLabelColor(e) { return palette.tileLabel(e) }
        function tileLabelOpacity(e) { return palette.tileLabelOpacity(e) }
        function tileGraphColor(e) { return palette.tileGraph(e) }
        function tileSecondColor(e) { return palette.tileSecond(e) }
        function tileFill(e) {
            const c = Qt.color(e?.bg_color || palette.background)
            return Qt.rgba(c.r, c.g, c.b, (e?.bg_opacity >= 0 ? e.bg_opacity : 78) / 100)
        }
        property real tileScale: 1
        property int animationDuration: 200
        property real labelScale: 1
        property real labelGrow: 1
        property real defaultPt: 10
        property real smallPt: 8
        property bool tileBackgrounds: true
        property bool connectionLost: !ha.ready
        property string connectionMessage: tr("conn.lost", "14:05")
        // two weak batteries below a threshold of 20 %
        property double now: new Date(2026, 9, 25, 12, 0).getTime()
        function ago(ms) { return look.showLastChanged && ms ? Math.round((now - ms) / 60000) + " min ago" : "" }
        // "theme" also shows the update hint
        property bool updateHintVisible: window.args[1] === "theme"
        property var updates: ({ latest: "9.9.9", releaseUrl: "" })
        function dismissUpdate() {}
        property var batteries: ({ enabled: true, total: 12, threshold: 20, low: [
            { entity_id: "sensor.hall_battery", name: "Hall sensor battery", level: 8 },
            { entity_id: "sensor.door_battery", name: "Front door battery", level: 17 },
            { entity_id: "binary_sensor.radiator_battery", name: "Radiator battery", level: -1 }
        ] })
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
                const base = { attributes: {}, default_action: {}, dclick_action: {}, scroll_action: {}, display: 1, hide_when_ok: false, light_color: "", brightness_pct: -1, device_class: "", unit: "", attribute: "", second_entity_id: "", value2: "", num2: NaN, current_temp: NaN, target_temp: NaN, temp_min: 7, temp_max: 35, temp_step: 0.5, current_humidity: NaN, hvac_action: "", heading: "", last_changed: 0, fan_pct: -1, value_color: "", label_color: "", second_color: "", graph_color: "", bg_color: "", bg_opacity: -1 }
                const add = o => append(Object.assign({}, base, o))
                add({ entity_id: "sensor.outside", name: "Outside", kind: "sensor", value: "9.6 °C", num: 9.6, state: "9.6", level: 0, icon: "mdi:thermometer", colspan: 1, history_hours: 24, domain: "sensor", active: false })
                add({ entity_id: "sensor.humidity", name: "Outside humidity", kind: "sensor", value: "63%", num: 63, state: "63", level: 0, icon: "mdi:water-percent", colspan: 1, history_hours: 24, domain: "sensor", active: false })
                add({ entity_id: "sensor.desk_temp", name: "Desk climate", kind: "combo", value: "23.7 °C", num: 23.7, state: "23.7", level: 0, icon: "mdi:thermometer", colspan: 1, history_hours: 24, domain: "sensor", active: false, second_entity_id: "sensor.desk_humidity", value2: "45%", num2: 45, second_color: "#ff8800" })
                // simple tile with its own value color
                add({ entity_id: "sensor.battery_home", name: "Home battery", kind: "simple", value: "41%", num: 41, state: "41", level: 0, icon: "mdi:battery", colspan: 1, history_hours: 0, domain: "sensor", active: false, value_color: "#ff0000", bg_color: "#123456", bg_opacity: 100 })
                add({ entity_id: "sensor.fan_rpm", name: "Fan speed", kind: "sensor", value: "1000 rpm", num: 1000, unit: "rpm", state: "1000", level: 0, icon: "mdi:fan", colspan: 1, history_hours: 0, domain: "sensor", active: false })
                add({ entity_id: "climate.living", heading: "Heating", name: "Living room", kind: "thermostat", value: "Auto", num: NaN, state: "auto", level: 0, icon: "mdi:thermostat", colspan: 1, history_hours: 0, domain: "climate", active: false, current_temp: 21.9, target_temp: 21, current_humidity: 52, hvac_action: "heating" })
                add({ entity_id: "light.desk", heading: "Lights", name: "Desk lamp", kind: "switch", value: "on", num: NaN, state: "on", level: 0, icon: "mdi:lightbulb", colspan: 0.5, history_hours: 0, domain: "light", active: true, brightness_pct: 60, light_color: "#ffcc66" })
                // full width, so its name never wraps and the state line always has room
                add({ entity_id: "fan.hall", name: "Hall fan", kind: "switch", value: "off", num: NaN, state: "off", level: 0, icon: "mdi:fan", colspan: 1, history_hours: 0, domain: "fan", active: false })
                add({ entity_id: "light.kitchen", name: "Kitchen", kind: "switch", value: "off", num: NaN, state: "off", level: 0, icon: "mdi:lightbulb-outline", colspan: 0.5, history_hours: 0, domain: "light", active: false })
                add({ entity_id: "binary_sensor.hall", last_changed: new Date(2026, 9, 25, 11, 55).getTime(), name: "Hallway motion", kind: "status", value: "unavailable", num: NaN, state: "unavailable", level: 2, icon: "mdi:motion-sensor", colspan: 1, history_hours: 0, domain: "binary_sensor", active: false })
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

    readonly property var valueTexts: ["12.4 °C", "23.7 °C", "45%", "1000 rpm"]
    readonly property var expectedTexts: ["12.4 °C", "Outside", "Outside humidity", "Desk climate", "45%", "Home battery", "41%", "Fan speed", "1000 rpm", "Heating", "Lights", "Weak batteries", "Hall sensor battery", "8 %", "Front door battery", "Radiator battery", "low", "Living room", "heating", "Desk lamp", "Kitchen", "Hallway motion", "unavailable · 5 min ago", "Late tile", "1 more check OK"]

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
            if (window.args[1] === "theme" && !window.textShown("DeskHome 9.9.9 is available.")) problems.push("update hint not shown")
            if (!window.sawCounting) problems.push("changed value did not count to the new one")
            // own tile colors and the switch state text
            const colors = {}
            const states = []
            const walkColors = item => {
                if (item.text !== undefined && item.visible) {
                    colors[item.text] = String(item.color)
                    if (item.text === "Off" || item.text === "On · 60 %") states.push(item.text)
                }
                for (let i = 0; i < item.children.length; i++) walkColors(item.children[i])
            }
            walkColors(view)
            if (colors["41%"] !== "#ff0000") problems.push("simple tile ignores its own value color: " + colors["41%"])
            let ownBackground = false
            const walkBg = item => {
                if (item.radius !== undefined && item.border !== undefined && String(item.color) === "#123456") ownBackground = true
                for (let i = 0; i < item.children.length; i++) walkBg(item.children[i])
            }
            walkBg(view)
            if (!ownBackground) problems.push("tile ignores its own background color")
            if (colors["45%"] !== "#ff8800") problems.push("combo tile ignores its own second color: " + colors["45%"])
            const statesShown = window.args[1] !== "theme"
            if (statesShown !== (states.length > 0)) problems.push("switch state text " + (statesShown ? "missing" : "not hidden") + ": " + JSON.stringify(states))
            // animations: the rpm icon turns, history lines have drawn in completely
            const anim = { spinning: 0, turned: 0, lines: 0, revealed: 0 }
            const walkAnim = item => {
                if (item.period !== undefined && item.spinning !== undefined && item.spinning) {
                    anim.spinning++
                    if (item.rotation > 0) anim.turned++
                }
                if (item.reveal !== undefined && item.points !== undefined && item.points.length) {
                    anim.lines++
                    if (item.reveal === 1) anim.revealed++
                }
                for (let i = 0; i < item.children.length; i++) walkAnim(item.children[i])
            }
            walkAnim(view)
            if (anim.spinning !== 1 || anim.turned !== 1) problems.push("fan icon does not turn: " + JSON.stringify(anim))
            if (!anim.lines || anim.revealed !== anim.lines) problems.push("history lines not drawn in: " + JSON.stringify(anim))
            for (const p of problems) console.log("FAIL " + p)
            view.grabToImage(r => { r.saveToFile(window.args[0]); console.log("saved " + window.args[0]); Qt.exit(problems.length ? 1 : 0) })
        }
    }

    function textShown(text) {
        let found = false
        const walk = item => {
            if (item.text === text && item.visible) found = true
            for (let i = 0; i < item.children.length; i++) walk(item.children[i])
        }
        walk(view)
        return found
    }

    // Every expected tile text must be visible and lie fully inside the view
    function verify() {
        const found = {}
        const walk = item => {
            if (item.text !== undefined && item.visible && item.opacity > 0 && window.expectedTexts.includes(item.text)) {
                const p = item.mapToItem(view, 0, 0)
                const inside = p.x >= 0 && p.y >= 0 && p.x + item.width <= view.width + 1 && item.width > 0
                // names may be shortened (full name in the tooltip), values must be shown completely
                // values must also fit vertically into their tile
                let tile = item.parent
                while (tile && tile.sourceIndex === undefined) tile = tile.parent
                const t = tile ? tile.mapToItem(view, 0, 0) : null
                const cutVertically = !!t && window.valueTexts.includes(item.text) && p.y + item.height > t.y + tile.height + 1
                found[item.text] = !inside ? "outside" : (item.truncated || cutVertically) && window.valueTexts.includes(item.text) ? "truncated" : "ok"
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
