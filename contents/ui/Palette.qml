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
    readonly property color ok: ha.ok || Kirigami.Theme.positiveTextColor
    readonly property color warn: ha.warn || Kirigami.Theme.neutralTextColor
    readonly property color crit: ha.crit || Kirigami.Theme.negativeTextColor
    readonly property color value: look.valueCustomColor ? look.valueColor : text
    readonly property color label: look.labelCustomColor ? look.labelColor : (ha.label || text)
    // the default label color is the text color, dimmed; a chosen one is shown as it is
    readonly property real labelOpacity: look.labelCustomColor || ha.label ? 1 : 0.8
    readonly property color graph: look.graphCustomColor ? look.graphColor : accent

    function levelColor(level, okColor) {
        switch (level) {
            case 1: return warn
            case 2: return crit
        }
        return okColor ?? value
    }
}
