// Min/max within the time window and a trend arrow compared to one hour ago
export function computeStats(points, current, windowMs) {
    const from = Date.now() - windowMs
    const hourMark = Date.now() - 3600000
    let min = Infinity, max = -Infinity, hourAgo = NaN
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
