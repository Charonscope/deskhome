import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."

// Lights & switches: click toggles, scroll wheel dims (EntityWrapper draws the bar)
Item {
    id: tile
    readonly property bool on: model.active
    // half tiles: smaller icon so the name has room
    readonly property bool narrow: width < Kirigami.Units.gridUnit * 7 * root.labelGrow
    readonly property color iconColor: {
        if (model.level === 2) return root.critColor
        if (!on) return root.mutedColor
        return model.light_color || root.accentColor
    }
    readonly property string stateText: {
        if (model.level === 2 || model.state === "unknown") return model.value
        if (!on) return root.tr("state.off")
        return model.brightness_pct >= 0 ? root.tr("state.onBrightness", model.brightness_pct) : root.tr("state.on")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        DynamicIcon {
            name: model.icon
            color: tile.iconColor
            opacity: wrapper.pending ? 0.5 : 1
            Layout.preferredWidth: (tile.narrow ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * root.labelGrow
            Layout.preferredHeight: (tile.narrow ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * root.labelGrow
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            // If the name does not fit on one line it wraps to two; the state
            // is then shown by the icon (grey = off, colored = on). Errors stay visible as text.
            PlasmaComponents3.Label {
                id: nameLabel
                text: model.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: model.level === 2 ? 1 : 2
                font.weight: Font.Bold
                font.pointSize: root.defaultPt
                color: root.labelColor
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                visible: nameLabel.lineCount < 2 || model.level === 2
                text: tile.stateText
                elide: Text.ElideRight
                opacity: model.level === 2 ? 1 : root.labelOpacity * 0.9
                font.pointSize: root.smallPt
                color: model.level === 2 ? root.critColor : root.labelColor
                Layout.fillWidth: true
            }
        }
    }
}
