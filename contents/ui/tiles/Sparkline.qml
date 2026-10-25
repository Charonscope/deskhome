import QtQuick

import org.kde.kirigami as Kirigami

// History line over a fixed time window up to "now"
Canvas {
    id: spark
    property var points: []
    property real windowMs: 24 * 3600000
    property color color: root.accentColor
    property int revision: 0
    property real currentValue: NaN
    property real lineWidth: 1.5
    property bool fill: true
    // Radius of the bottom corners, so line and area do not run over the tile corners
    property real cornerRadius: 0
    // share of the line drawn (0..1): the line draws in from the left when it first appears
    property real reveal: 1
    property bool _revealed: false
    function startReveal() {
        if (_revealed || !points?.length) return
        _revealed = true
        if (root.animationDuration <= 0) return
        reveal = 0
        revealAnimation.start()
    }
    NumberAnimation {
        id: revealAnimation
        target: spark
        property: "reveal"
        to: 1
        duration: root.animationDuration * 4
        easing.type: Easing.OutCubic
    }
    onRevealChanged: requestPaint()
    Component.onCompleted: startReveal()

    onRevisionChanged: {
        startReveal()
        requestPaint()
    }
    onPointsChanged: {
        startReveal()
        requestPaint()
    }
    onColorChanged: requestPaint()
    onLineWidthChanged: requestPaint()
    onFillChanged: requestPaint()
    onCornerRadiusChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const now = Date.now()
        const from = now - windowMs
        const data = points.filter(p => p[0] >= from)
        // last point before the window as the start value at the left edge
        const before = points.filter(p => p[0] < from).pop()
        if (before) data.unshift([from, before[1]])
        const last = !isNaN(currentValue) ? currentValue : data.length ? data[data.length - 1][1] : NaN
        if (!isNaN(last)) data.push([now, last])
        if (data.length < 2) return

        let min = Infinity, max = -Infinity
        for (const p of data) {
            if (p[1] < min) min = p[1]
            if (p[1] > max) max = p[1]
        }
        const r = Math.min(cornerRadius, width / 2, height)
        ctx.beginPath()
        ctx.moveTo(0, 0)
        ctx.lineTo(width, 0)
        ctx.lineTo(width, height - r)
        ctx.arcTo(width, height, width - r, height, r)
        ctx.lineTo(r, height)
        ctx.arcTo(0, height, 0, height - r, r)
        ctx.closePath()
        ctx.clip()
        if (reveal < 1) {
            ctx.beginPath()
            ctx.rect(0, 0, width * reveal, height)
            ctx.clip()
        }

        // Minimum scale height: 5 % of the value, otherwise measurement noise
        // (e.g. fan 1008–1020 rpm) is blown up to the full tile height
        const mid = (max + min) / 2
        const span = Math.max(max - min, Math.abs(mid) * 0.05) || 1
        min = mid - span / 2
        const pad = 2
        const half = lineWidth / 2
        const x = t => half + (t - from) / windowMs * (width - lineWidth)
        const y = v => height - pad - (v - (min - span * 0.08)) / (span * 1.16) * (height - 2 * pad)

        ctx.beginPath()
        ctx.moveTo(x(data[0][0]), y(data[0][1]))
        for (let i = 1; i < data.length; i++) ctx.lineTo(x(data[i][0]), y(data[i][1]))
        ctx.lineWidth = lineWidth
        ctx.strokeStyle = color
        ctx.lineJoin = "round"
        ctx.stroke()
        if (!fill) return

        ctx.lineTo(x(data[data.length - 1][0]), height)
        ctx.lineTo(x(data[0][0]), height)
        ctx.closePath()
        const gradient = ctx.createLinearGradient(0, 0, 0, height)
        gradient.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0.35))
        gradient.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0.02))
        ctx.fillStyle = gradient
        ctx.fill()
    }
}
