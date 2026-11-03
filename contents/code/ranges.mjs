// Color ranges of a tile ("from–to: color"), e.g. an energy price: below 0.25 green,
// 0.25–0.33 yellow, above red. They color the value, the history line and the gauge arc.
// A range without "from" starts at minus infinity, one without "to" ends at plus infinity;
// "from" belongs to the range, "to" no longer does. The first matching range wins.

function num(v) {
    if (v === undefined || v === null || v === "") return NaN
    return +v
}

// config.ranges: [{ from, to, color }] -> the same with numbers (NaN = open end)
export function rangesOf(config = {}) {
    const list = Array.isArray(config.ranges) ? config.ranges : []
    return list.filter(r => r && r.color).map(r => ({ from: num(r.from), to: num(r.to), color: String(r.color) }))
}

export function rangeColor(ranges, value) {
    if (isNaN(value)) return ""
    for (const r of ranges) {
        if ((isNaN(r.from) || value >= r.from) && (isNaN(r.to) || value < r.to)) return r.color
    }
    return ""
}

// Scale of a gauge: the tile's own min/max, else the outer ends of its ranges, else 0–100
export function gaugeScale(config = {}, ranges = rangesOf(config)) {
    // no flatMap: the QML engine does not have it
    const ends = ranges.reduce((all, r) => all.concat([r.from, r.to]), []).filter(v => !isNaN(v))
    let min = num(config.gauge_min)
    let max = num(config.gauge_max)
    // neither an own scale nor ranges: the caller may know a better default
    const auto = isNaN(min) && isNaN(max) && !ends.length
    if (isNaN(min)) min = ends.length ? Math.min(...ends) : 0
    if (isNaN(max)) max = ends.length ? Math.max(...ends) : 100
    if (max <= min) max = min + 1
    return { min, max, auto }
}
