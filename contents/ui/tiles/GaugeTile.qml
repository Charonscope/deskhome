import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."

// Round gauge: an arc of 240° from min to max, the tile's color ranges faintly as the track,
// the part up to the value in the current color (status, range or value color) and the value
// in the middle. The arc glides to a new value.
Item {
    id: tile
    readonly property color valueColor: root.tileLevelValueColor(model)
    readonly property var ranges: { try { return JSON.parse(model.ranges || "[]") } catch (e) { return [] } }
    readonly property real min: model.gauge_min
    readonly property real max: model.gauge_max
    // share of the arc filled (0..1)
    readonly property real target: isNaN(model.num) ? 0 : Math.max(0, Math.min(1, (model.num - min) / (max - min)))
    property real shown: 0
    Component.onCompleted: shown = target
    onTargetChanged: shown = target
    Behavior on shown {
        enabled: root.animationDuration > 0
        NumberAnimation { duration: root.animationDuration * 3; easing.type: Easing.OutCubic }
    }

    function fmt(v) {
        // as many decimals as the scale ends need (0.25 → 2, 22.5 → 1, 100 → 0)
        const decimals = Math.min(2, (String(v).split(".")[1] || "").length)
        return Number(v).toLocaleString(Qt.locale(), "f", decimals)
    }

    RowLayout {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Kirigami.Units.smallSpacing
        }
        spacing: Kirigami.Units.smallSpacing
        DynamicIcon {
            name: model.icon
            color: tile.valueColor
            animationDuration: root.animationDuration
            Layout.preferredWidth: Kirigami.Units.iconSizes.small * root.labelGrow
            Layout.preferredHeight: Kirigami.Units.iconSizes.small * root.labelGrow
        }
        PlasmaComponents3.Label {
            text: model.name
            elide: Text.ElideRight
            color: root.tileLabelColor(model)
            opacity: root.tileLabelOpacity(model)
            font.pointSize: root.smallPt
            Layout.fillWidth: true
        }
    }

    Canvas {
        id: arc
        readonly property real start: Math.PI * 5 / 6          // 150°, lower left
        readonly property real sweep: Math.PI * 4 / 3          // 240°
        readonly property real thickness: Math.max(4, Math.min(width, height) * 0.11)
        // room below the arc ends for the scale labels
        readonly property real scaleHeight: minLabel.implicitHeight
        // geometry: the open arc's lowest points lie 30° below the middle
        readonly property real radius: Math.max(0, Math.min(width / 2, (height - scaleHeight) / (1 + Math.sin(Math.PI / 6))) - thickness / 2 - 1)
        readonly property real cx: width / 2
        readonly property real cy: thickness / 2 + 1 + radius
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
            margins: Kirigami.Units.smallSpacing
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            if (radius <= 0) return
            const angle = f => start + sweep * f
            const part = (from, to, color, alpha) => {
                if (to <= from) return
                ctx.beginPath()
                ctx.arc(cx, cy, radius, angle(from), angle(to), false)
                ctx.lineWidth = thickness
                ctx.lineCap = "butt"
                ctx.strokeStyle = Qt.rgba(color.r, color.g, color.b, alpha)
                ctx.stroke()
            }
            const span = tile.max - tile.min
            const frac = v => isNaN(v) ? NaN : Math.max(0, Math.min(1, (v - tile.min) / span))
            // track: the color ranges faintly, the rest in the text color
            part(0, 1, Kirigami.Theme.textColor, 0.12)
            for (const range of tile.ranges) {
                const from = isNaN(frac(range.from)) ? 0 : frac(range.from)
                const to = isNaN(frac(range.to)) ? 1 : frac(range.to)
                part(from, to, Qt.color(range.color), 0.35)
            }
            // the value
            part(0, tile.shown, tile.valueColor, 1)
        }
        Connections {
            target: tile
            function onShownChanged() { arc.requestPaint() }
            function onValueColorChanged() { arc.requestPaint() }
            function onRangesChanged() { arc.requestPaint() }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        // the value in the middle of the arc
        CountingLabel {
            x: arc.cx - width / 2
            y: arc.cy - height / 2
            width: arc.radius * 1.5
            horizontalAlignment: Text.AlignHCenter
            value: model.value
            color: tile.valueColor
            font.pixelSize: Math.max(10, arc.radius * 0.42 * root.look.valueScale / 100)
            font.weight: root.valueWeight
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 8
        }

        // scale ends below the ends of the arc
        PlasmaComponents3.Label {
            id: minLabel
            text: tile.fmt(tile.min)
            font.pointSize: root.smallPt * 0.9
            color: root.tileLabelColor(model)
            opacity: 0.7
            x: arc.cx + arc.radius * Math.cos(arc.start) - width / 2
            y: arc.cy + arc.radius * Math.sin(arc.start) + arc.thickness / 2
        }
        PlasmaComponents3.Label {
            text: tile.fmt(tile.max)
            font.pointSize: root.smallPt * 0.9
            color: root.tileLabelColor(model)
            opacity: 0.7
            x: arc.cx + arc.radius * Math.cos(arc.start + arc.sweep) - width / 2
            y: arc.cy + arc.radius * Math.sin(arc.start + arc.sweep) + arc.thickness / 2
        }
    }
}
