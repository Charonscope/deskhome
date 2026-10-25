import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."
import "../../code/formatter.mjs" as Formatter
import "../../code/stats.mjs" as Stats

// Large value, below it the history with min/max and trend arrow
Item {
    id: tile
    readonly property real windowMs: model.history_hours * 3600000
    readonly property bool showHistory: model.history_hours > 0
    readonly property var points: { store.historyRevision; return store.history(model.entity_id) }
    readonly property color levelColor: root.levelColor(model.level)
    // revision as an argument because points is always the same (growing) array
    readonly property var stats: computeStats(points, model.num, store.historyRevision)

    function computeStats(points, current, revision) {
        return Stats.computeStats(points, current, windowMs)
    }

    function fmt(v) {
        if (!isFinite(v)) return "–"
        const p = Formatter.getDefaultPrecision(String(model.state))
        return Formatter.formatIfNumber(String(v), p)
    }

    Sparkline {
        // Distance to the tile edge (the border is up to 1.5 px wide)
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
        color: model.level ? tile.levelColor : root.graphLineColor
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
                visible: showHistory && root.look.showMinMax && isFinite(stats.min)
                text: `↓${fmt(stats.min)}  ↑${fmt(stats.max)}`
                font.pointSize: root.smallPt
                color: root.labelColor
                opacity: root.labelOpacity * 0.9
            }
            PlasmaComponents3.Label {
                text: stats.trend
                visible: !!text && showHistory && root.look.showTrend
                font.pointSize: root.defaultPt
                color: root.labelColor
                opacity: root.labelOpacity
            }
        }

        CountingLabel {
            value: model.value
            color: tile.levelColor
            font.pixelSize: Kirigami.Units.gridUnit * (showHistory ? 1.3 : 1.8) * root.tileScale * root.look.valueScale / 100
            font.weight: Font.Bold
            elide: Text.ElideRight
            Layout.fillWidth: true
            // aligned with the visible left edge of the icon (the SVG has an inner margin)
            Layout.leftMargin: headerIcon.item?.size ? (headerIcon.width - headerIcon.item.size.width) / 2 : 0
        }

        Item { Layout.fillHeight: true }
    }
}
