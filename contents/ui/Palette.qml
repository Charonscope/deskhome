import QtQuick

import org.kde.kirigami as Kirigami

import "../code/themes.mjs" as Themes

// Colors of the tiles: the Plasma color scheme or a Home Assistant theme, with the
// widget's own colors on top. Status colors (warning/critical) always win over own colors.
QtObject {
    property var look: ({})
    // result of frontend/get_themes, null until loaded
    property var haThemes: null

    readonly property bool useHaTheme: look.colorSource === "ha"
    readonly property bool dark: Kirigami.Theme.backgroundColor.hslLightness < 0.5
    readonly property var ha: useHaTheme && haThemes ? Themes.themePalette(haThemes, look.haTheme, dark) : ({})

    readonly property color accent: ha.accent || Kirigami.Theme.highlightColor
    readonly property color text: ha.text || Kirigami.Theme.textColor
    readonly property color muted: ha.muted || Kirigami.Theme.disabledTextColor
    readonly property color background: look.tileCustomColor ? look.tileColor : (ha.background || Kirigami.Theme.backgroundColor)
    // own status colors (Appearance → Colors) win over the theme
    readonly property bool customLevels: !!look.levelCustomColors
    readonly property color ok: customLevels ? look.customOkColor : (ha.ok || Kirigami.Theme.positiveTextColor)
    readonly property color warn: customLevels ? look.customWarnColor : (ha.warn || Kirigami.Theme.neutralTextColor)
    readonly property color crit: customLevels ? look.customCritColor : (ha.crit || Kirigami.Theme.negativeTextColor)
    readonly property color value: look.valueCustomColor ? look.valueColor : text
    readonly property color label: look.labelCustomColor ? look.labelColor : (ha.label || text)
    // the default label color is the text color, dimmed; a chosen one is shown as it is
    readonly property real labelOpacity: look.labelCustomColor || ha.label ? 1 : 0.8
    readonly property color graph: look.graphCustomColor ? look.graphColor : accent
    // second value of combo tiles: by default the accent turned a quarter back on the color wheel
    readonly property color second: look.secondCustomColor ? look.secondColor
        : Qt.hsla((accent.hslHue + 0.75) % 1, Math.max(0.45, accent.hslSaturation),
                  Math.min(0.65, Math.max(0.5, accent.hslLightness)), 1)
    // font weight of the large values (400 normal, 600 semi-bold, 700 bold)
    readonly property int valueWeight: look.valueWeight || Font.Bold

    // A tile's own colors (set in its settings) win over the global ones; empty = global
    function tileValue(e) { return e?.value_color || value }
    // the color while there is no warning: the tile's color range the value lies in, else the
    // OK color when the tile asks for it ("value in OK color"), else ''
    function okOrRange(e) { return e?.range_color || (e?.level_ok ? ok : "") }
    // the label takes the status/range color when the tile asks for it
    function labelLeveled(e) { return !!e?.level_label && (e.level > 0 || !!okOrRange(e)) }
    function tileLabel(e) { return labelLeveled(e) ? levelColor(e.level, okOrRange(e)) : (e?.label_color || label) }
    function tileLabelOpacity(e) { return labelLeveled(e) || e?.label_color ? 1 : labelOpacity }
    // the large value: status color, else range or OK color, else the value color
    function tileLevelValue(e) { return levelColor(e?.level, okOrRange(e) || tileValue(e)) }
    // history line: in the range color while the value lies in a range
    function tileGraph(e) { return e?.range_color || e?.graph_color || graph }
    function tileSecond(e) { return e?.second_color || second }
    function tileSecondGraph(e) { return e?.second_graph_color || tileSecond(e) }

    function levelColor(level, okColor) {
        switch (level) {
            case 1: return warn
            case 2: return crit
        }
        return okColor ?? value
    }
}
