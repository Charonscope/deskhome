import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."

// Ampel-Kachel: farbiger Punkt + Name + Zustand
Item {
    id: tile
    readonly property color dotColor: Levels.color(model.level, Kirigami.Theme.positiveTextColor)
    // halbe Kacheln: nur der Ampelpunkt, kein zusätzliches Icon
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
            // Langer Name: zwei Zeilen statt abschneiden; der Zustand steckt dann in der Ampelfarbe
            PlasmaComponents3.Label {
                id: nameLabel
                text: model.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: model.level ? 1 : 2
                font.pointSize: root.defaultPt
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                visible: nameLabel.lineCount < 2 || model.level > 0
                text: model.value
                elide: Text.ElideRight
                font.pointSize: root.smallPt
                color: model.level ? tile.dotColor : Kirigami.Theme.textColor
                opacity: model.level ? 1 : 0.7
                Layout.fillWidth: true
            }
        }
    }
}
