import QtQuick

import org.kde.kirigami as Kirigami

// Verlaufslinie über ein festes Zeitfenster bis "jetzt"
Canvas {
    id: spark
    property var points: []
    property real windowMs: 24 * 3600000
    property color color: Kirigami.Theme.highlightColor
    property int revision: 0
    property real currentValue: NaN
    property real lineWidth: 1.5
    property bool fill: true
    // Rundung der unteren Ecken, damit Linie und Fläche nicht über die Kachelecken laufen
    property real cornerRadius: 0

    onRevisionChanged: requestPaint()
    onPointsChanged: requestPaint()
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
        // letzter Punkt vor dem Fenster als Startwert am linken Rand
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

        // Mindesthöhe der Skala: 5 % vom Wert, sonst wird Messrauschen
        // (z. B. Lüfter 1008–1020 U/min) auf die volle Kachelhöhe aufgeblasen
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
