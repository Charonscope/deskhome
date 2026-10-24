import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."
import "../../code/formatter.mjs" as Formatter

// Large value, below it the history with min/max and trend arrow
Item {
    id: tile
    readonly property real windowMs: model.history_hours * 3600000
    readonly property bool showHistory: model.history_hours > 0
    readonly property var points: { store.historyRevision; return store.history(model.entity_id) }
    readonly property color levelColor: Levels.color(model.level)
    // revision as an argument because points is always the same (growing) array
    readonly property var stats: computeStats(points, model.num, store.historyRevision)

    function computeStats(points, current, revision) {
        const from = Date.now() - windowMs
        let min = Infinity, max = -Infinity, hourAgo = NaN
        const hourMark = Date.now() - 3600000
        for (const p of points) {
            if (p[0] >= from) {
                if (p[1] < min) min = p[1]
                if (p[1] > max) max = p[1]
            }
            if (p[0] <= hourMark) hourAgo = p[1]
        }
        if (!isNaN(current)) {
            min = Math.min(min, current)
            max = Math.max(max, current)
        }
        // same minimum span as the graph, so noise does not trigger a trend arrow
        const range = Math.max(max - min, Math.abs(current) * 0.05)
        let trend = ""
        if (!isNaN(hourAgo) && !isNaN(current) && range > 0) {
            const d = current - hourAgo
            if (Math.abs(d) >= range * 0.1) trend = d > 0 ? "↗" : "↘"
            else trend = "→"
        }
        return { min, max, trend }
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
        color: model.level ? tile.levelColor : (root.look.graphCustomColor ? root.look.graphColor : Kirigami.Theme.highlightColor)
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
                visible: showHistory && root.look.showMinMax && isFinite(stats.min)
                text: `↓${fmt(stats.min)}  ↑${fmt(stats.max)}`
                font.pointSize: root.smallPt
                opacity: 0.7
            }
            PlasmaComponents3.Label {
                text: stats.trend
                visible: !!text && showHistory && root.look.showTrend
                font.pointSize: root.defaultPt
                opacity: 0.8
            }
        }

        PlasmaComponents3.Label {
            text: model.value
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
