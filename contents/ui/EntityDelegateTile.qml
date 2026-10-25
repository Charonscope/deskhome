import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3

import org.kde.kirigami as Kirigami

import "tiles"

// "Simple" tile (the original look): icon, value in bold, name below. Uses the same colors
// as the other tiles: the tile's own or the global font colors, warning colors first.
GridLayout {
    id: grid
    columns: 2
    rows: model.value ? 2 : 1
    clip: true
    columnSpacing: Kirigami.Units.smallSpacing
    rowSpacing: 0
    anchors.margins: Kirigami.Units.smallSpacing

    readonly property color valueColor: root.levelColor(model.level, root.tileValueColor(model))

    DynamicIcon {
        name: model.icon
        color: model.level ? grid.valueColor : root.tileLabelColor(model)
        animationDuration: root.animationDuration
        Layout.rowSpan: model.value ? 2 : 1
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
    }

    CountingLabel {
        value: model.value
        visible: !!value
        color: grid.valueColor
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
        font.weight: root.valueWeight
        font.pointSize: root.defaultPt * 1.1
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
    }

    PlasmaComponents3.Label {
        text: name
        color: root.tileLabelColor(model)
        opacity: root.tileLabelOpacity(model)
        font.pointSize: root.defaultPt
        elide: Text.ElideRight
        Layout.alignment: model.value ? Qt.AlignTop : 0
        Layout.fillWidth: true
    }
}
