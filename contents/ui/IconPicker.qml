import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "../code/mdi-names.mjs" as MdiNames
import "../code/i18n.mjs" as I18n

// Searchable grid of the bundled Material Design icons. "picked" delivers "mdi:<name>".
Popup {
    id: picker
    signal picked(string icon)
    // current value of the icon field, used as the first search
    property string current: ""

    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(Kirigami.Units.gridUnit * 30, (parent?.width ?? 600) - Kirigami.Units.gridUnit * 2)
    height: Math.min(Kirigami.Units.gridUnit * 26, (parent?.height ?? 500) - Kirigami.Units.gridUnit * 2)
    modal: true
    focus: true
    padding: Kirigami.Units.largeSpacing

    onOpened: {
        search.text = current.startsWith("mdi:") ? current.substring(4) : ""
        search.forceActiveFocus()
        search.selectAll()
    }

    // every word must be part of the name, e.g. "fan off"
    readonly property var matches: {
        const words = search.text.toLowerCase().split(/[\s:-]+/).filter(w => !!w)
        if (!words.length) return MdiNames.NAMES
        return MdiNames.NAMES.filter(n => words.every(w => n.includes(w)))
    }

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.SearchField {
            id: search
            Layout.fillWidth: true
            placeholderText: picker.tr("icon.search")
            onAccepted: if (picker.matches.length) picker.choose(picker.matches[0])
            Keys.onEscapePressed: picker.close()
        }

        Label {
            text: picker.tr("icon.count", picker.matches.length)
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridView {
                id: grid
                clip: true
                model: picker.matches
                cellWidth: Kirigami.Units.gridUnit * 3
                cellHeight: Kirigami.Units.gridUnit * 3
                delegate: ToolButton {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    onClicked: picker.choose(modelData)
                    ToolTip.text: modelData
                    ToolTip.visible: hovered
                    ToolTip.delay: Kirigami.Units.toolTipDelay
                    contentItem: DynamicIcon {
                        name: "mdi:" + modelData
                    }
                }
            }
        }
    }

    function choose(name) {
        picked("mdi:" + name)
        close()
    }
}
