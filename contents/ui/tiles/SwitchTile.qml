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
    // "state on top" (like the simple tile): state first in the value font, name below
    readonly property bool stateFirst: !!model.state_first
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

        SpinningIcon {
            // a running fan turns, faster with higher speed
            period: model.domain === "fan" && tile.on ? (model.fan_pct > 0 ? 4000 - model.fan_pct * 30 : 2000) : 0
            name: model.icon
            color: tile.iconColor
            opacity: wrapper.pending ? 0.5 : 1
            Layout.preferredWidth: (tile.narrow ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * root.labelGrow
            Layout.preferredHeight: (tile.narrow ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * root.labelGrow
            Layout.alignment: Qt.AlignVCenter
        }

        // "state on top": state first in the value font, name below, like the simple tile
        GridLayout {
            columns: 1
            rowSpacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            // If the name does not fit on one line it wraps to two; the state
            // is then shown by the icon (grey = off, colored = on). Errors stay visible as text.
            PlasmaComponents3.Label {
                id: nameLabel
                text: model.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: model.level === 2 || tile.stateFirst ? 1 : 2
                font.weight: tile.stateFirst ? Font.Normal : root.valueWeight
                font.pointSize: root.defaultPt
                color: root.tileLabelColor(model)
                opacity: tile.stateFirst ? root.tileLabelOpacity(model) : 1
                Layout.fillWidth: true
                Layout.row: tile.stateFirst ? 1 : 0
            }
            PlasmaComponents3.Label {
                // the on/off text can be hidden (Appearance); errors always stay visible;
                // with the state on top it is the tile's value and always shown
                visible: (nameLabel.lineCount < 2 && root.look.showSwitchState !== false) || model.level === 2 || tile.stateFirst
                text: root.ago(model.last_changed) ? tile.stateText + " · " + root.ago(model.last_changed) : tile.stateText
                elide: Text.ElideRight
                opacity: model.level === 2 || tile.stateFirst ? 1 : root.tileLabelOpacity(model) * 0.9
                font.pointSize: tile.stateFirst ? root.defaultPt * 1.1 : root.smallPt
                font.weight: tile.stateFirst ? root.valueWeight : Font.Normal
                color: model.level === 2 ? root.critColor : tile.stateFirst ? root.tileLevelValueColor(model) : root.tileLabelColor(model)
                Layout.fillWidth: true
                Layout.row: tile.stateFirst ? 0 : 1
            }
        }
    }
}
