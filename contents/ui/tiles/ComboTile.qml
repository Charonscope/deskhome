import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."
import "../../code/stats.mjs" as Stats

// Two values of one place in one tile (e.g. temperature and humidity), each with its
// own history line. The second value and its line share an accent color.
Item {
    id: tile
    readonly property real windowMs: model.history_hours * 3600000
    readonly property bool showHistory: model.history_hours > 0
    readonly property var points: { store.historyRevision; return store.history(model.entity_id) }
    readonly property var points2: { store.historyRevision; return store.history(model.second_entity_id) }
    readonly property color levelColor: Levels.color(model.level)
    readonly property color firstLineColor: model.level ? levelColor : (root.look.graphCustomColor ? root.look.graphColor : Kirigami.Theme.highlightColor)
    // accent for the second value: the highlight color turned a quarter back on the color wheel (blue -> green)
    readonly property color secondColor: Qt.hsla((Kirigami.Theme.highlightColor.hslHue + 0.75) % 1,
                                                 Math.max(0.45, Kirigami.Theme.highlightColor.hslSaturation),
                                                 Math.min(0.65, Math.max(0.5, Kirigami.Theme.highlightColor.hslLightness)), 1)
    // revision as an argument because the point arrays are always the same (growing) arrays
    readonly property var stats: Stats.computeStats(points, model.num, windowMs, store.historyRevision)
    readonly property var stats2: Stats.computeStats(points2, model.num2, windowMs, store.historyRevision)

    Sparkline {
        id: firstLine
        readonly property real inset: 2
        visible: showHistory
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: inset
        }
        cornerRadius: Math.max(0, root.look.tileRadius - inset)
        height: parent.height * root.look.graphHeight / 100
        lineWidth: root.look.graphLineWidth
        fill: root.look.graphFill
        points: tile.points
        windowMs: tile.windowMs
        revision: store.historyRevision
        currentValue: model.num
        color: tile.firstLineColor
    }

    Sparkline {
        visible: showHistory
        anchors.fill: firstLine
        cornerRadius: firstLine.cornerRadius
        lineWidth: root.look.graphLineWidth
        fill: false
        points: tile.points2
        windowMs: tile.windowMs
        revision: store.historyRevision
        currentValue: model.num2
        color: tile.secondColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: 0

        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
            DynamicIcon {
                id: headerIcon
                name: model.icon
                color: tile.levelColor
                Layout.preferredWidth: Kirigami.Units.iconSizes.small * root.labelGrow
                Layout.preferredHeight: Kirigami.Units.iconSizes.small * root.labelGrow
            }
            PlasmaComponents3.Label {
                text: model.name
                elide: Text.ElideRight
                opacity: 0.8
                font.pointSize: root.smallPt
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                text: tile.stats.trend
                visible: !!text && showHistory && root.look.showTrend
                opacity: 0.8
                font.pointSize: root.defaultPt
            }
            PlasmaComponents3.Label {
                text: tile.stats2.trend
                visible: !!text && showHistory && root.look.showTrend
                color: tile.secondColor
                font.pointSize: root.defaultPt
            }
        }

        RowLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            // aligned with the visible left edge of the icon (the SVG has an inner margin)
            Layout.leftMargin: headerIcon.item?.size ? (headerIcon.width - headerIcon.item.size.width) / 2 : 0
            PlasmaComponents3.Label {
                text: model.value
                color: tile.levelColor
                font.pixelSize: Kirigami.Units.gridUnit * (showHistory ? 1.3 : 1.8) * root.tileScale * root.look.valueScale / 100
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            PlasmaComponents3.Label {
                text: model.value2
                color: tile.secondColor
                font.pixelSize: Kirigami.Units.gridUnit * (showHistory ? 1.3 : 1.8) * root.tileScale * root.look.valueScale / 100
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Item { Layout.fillHeight: true }
    }
}
