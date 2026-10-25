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

    RowLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            width: Kirigami.Units.gridUnit * 0.8 * root.labelGrow
            height: width
            radius: width / 2
            color: tile.dotColor
            Layout.alignment: Qt.AlignVCenter
        }

        DynamicIcon {
            name: model.icon
            color: tile.dotColor
            visible: !!model.icon && !tile.narrow
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium * root.labelGrow
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium * root.labelGrow
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            // Long name: two lines instead of cutting it off; the state is then shown by the dot color
            PlasmaComponents3.Label {
                id: nameLabel
                text: model.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: model.level ? 1 : 2
                font.pointSize: root.defaultPt
                color: root.labelColor
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                visible: nameLabel.lineCount < 2 || model.level > 0
                text: model.value
                elide: Text.ElideRight
                font.pointSize: root.smallPt
                color: model.level ? tile.dotColor : root.labelColor
                opacity: model.level ? 1 : root.labelOpacity * 0.9
                Layout.fillWidth: true
            }
        }
    }
}
