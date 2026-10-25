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
    readonly property color levelColor: root.levelColor(model.level)
    readonly property color firstLineColor: model.level ? levelColor : root.graphLineColor
    // accent for the second value: the highlight color turned a quarter back on the color wheel (blue -> green)
    readonly property color secondColor: Qt.hsla((root.accentColor.hslHue + 0.75) % 1,
                                                 Math.max(0.45, root.accentColor.hslSaturation),
                                                 Math.min(0.65, Math.max(0.5, root.accentColor.hslLightness)), 1)
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
                animationDuration: root.animationDuration
                id: headerIcon
                name: model.icon
                color: tile.levelColor
                Layout.preferredWidth: Kirigami.Units.iconSizes.small * root.labelGrow
                Layout.preferredHeight: Kirigami.Units.iconSizes.small * root.labelGrow
            }
            PlasmaComponents3.Label {
                text: model.name
                elide: Text.ElideRight
                color: root.labelColor
                opacity: root.labelOpacity
                font.pointSize: root.smallPt
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                text: tile.stats.trend
                visible: !!text && showHistory && root.look.showTrend
                color: root.labelColor
                opacity: root.labelOpacity
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
            id: valueRow
            spacing: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            // aligned with the visible left edge of the icon (the SVG has an inner margin)
            Layout.leftMargin: headerIcon.item?.size ? (headerIcon.width - headerIcon.item.size.width) / 2 : 0
            // both values must fit side by side: in narrow tiles (or with wide fonts) they shrink together
            readonly property real basePx: Kirigami.Units.gridUnit * (showHistory ? 1.3 : 1.8) * root.tileScale * root.look.valueScale / 100
            readonly property real needed: (firstMetrics.advanceWidth + secondMetrics.advanceWidth) * 1.05 + spacing
            readonly property real fit: needed > 0 ? Math.min(1, Math.max(0.5, (width - spacing) / (needed - spacing))) : 1
            // measured with the labels' own font family (it differs from the application font)
            TextMetrics {
                id: firstMetrics
                font.family: firstValue.font.family
                font.pixelSize: valueRow.basePx
                font.weight: Font.Bold
                text: model.value
            }
            TextMetrics {
                id: secondMetrics
                font.family: firstValue.font.family
                font.pixelSize: valueRow.basePx
                font.weight: Font.Bold
                text: model.value2
            }
            CountingLabel {
                id: firstValue
                value: model.value
                color: tile.levelColor
                font.pixelSize: valueRow.basePx * valueRow.fit
                font.weight: Font.Bold
            }
            CountingLabel {
                value: model.value2
                color: tile.secondColor
                font.pixelSize: valueRow.basePx * valueRow.fit
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Item { Layout.fillHeight: true }
    }
}
