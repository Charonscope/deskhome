import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."

// Status tile: colored dot + name + state
Item {
    id: tile
    readonly property color dotColor: root.levelColor(model.level, root.okColor)
    // half tiles: only the status dot, no extra icon
    readonly property bool narrow: width < Kirigami.Units.gridUnit * 7 * root.labelGrow
    // a motion sensor that fires sends a short wave out of its dot
    readonly property bool motion: ["motion", "occupancy", "presence"].includes(model.device_class)
    readonly property bool on: !!model.active
    // "state on top" (like the simple tile): state first in the value font, name below
    readonly property bool stateFirst: !!model.state_first
    onOnChanged: if (on && motion && root.animationDuration > 0) wave.restart()

    RowLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            width: Kirigami.Units.gridUnit * 0.8 * root.labelGrow
            height: width
            radius: width / 2
            color: tile.dotColor
            Rectangle {
                id: waveRing
                anchors.centerIn: parent
                width: parent.width
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: tile.dotColor
                opacity: 0
                ParallelAnimation {
                    id: wave
                    NumberAnimation { target: waveRing; property: "scale"; from: 1; to: 3.2; duration: 900; easing.type: Easing.OutCubic }
                    NumberAnimation { target: waveRing; property: "opacity"; from: 0.9; to: 0; duration: 900; easing.type: Easing.OutCubic }
                }
            }
            Behavior on color {
                enabled: root.animationDuration > 0
                ColorAnimation { duration: root.animationDuration }
            }
            Layout.alignment: Qt.AlignVCenter
        }

        DynamicIcon {

            animationDuration: root.animationDuration
            name: model.icon
            color: tile.dotColor
            visible: !!model.icon && !tile.narrow
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium * root.labelGrow
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium * root.labelGrow
            Layout.alignment: Qt.AlignVCenter
        }

        // "state on top": state first in the value font, name below, like the simple tile
        GridLayout {
            columns: 1
            rowSpacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            // Long name: two lines instead of cutting it off; the state is then shown by the dot color
            PlasmaComponents3.Label {
                id: nameLabel
                text: model.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: model.level || tile.stateFirst ? 1 : 2
                font.pointSize: root.defaultPt
                color: root.tileLabelColor(model)
                opacity: tile.stateFirst ? root.tileLabelOpacity(model) : 1
                Layout.fillWidth: true
                Layout.row: tile.stateFirst ? 1 : 0
            }
            PlasmaComponents3.Label {
                visible: nameLabel.lineCount < 2 || model.level > 0 || tile.stateFirst
                text: root.ago(model.last_changed) ? model.value + " · " + root.ago(model.last_changed) : model.value
                elide: Text.ElideRight
                font.pointSize: tile.stateFirst ? root.defaultPt * 1.1 : root.smallPt
                font.weight: tile.stateFirst ? root.valueWeight : Font.Normal
                color: model.level ? tile.dotColor : tile.stateFirst ? root.tileLevelValueColor(model) : root.tileLabelColor(model)
                opacity: model.level || tile.stateFirst ? 1 : root.tileLabelOpacity(model) * 0.9
                Layout.fillWidth: true
                Layout.row: tile.stateFirst ? 0 : 1
            }
        }
    }
}
