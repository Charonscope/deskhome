// Full backup of the tiles and the appearance; the access token is never part of it
export const LOOK_KEYS = Object.freeze([
    "flat", "activeFrame", "compactEntity", "compactScaleIconsToFit", "compactIconSpacing", "itemDisplayDefault",
    "tileOpacity", "tileCustomColor", "tileColor", "tileRadius", "tileBorder", "levelBorder",
    "tileScale", "tileSpacing", "labelScale", "valueScale", "showMinMax", "showTrend",
    "graphHeight", "graphLineWidth", "graphFill", "graphCustomColor", "graphColor",
    "colorSource", "haTheme", "valueCustomColor", "valueColor", "labelCustomColor", "labelColor", "animations",
    "batteryThreshold", "showLastChanged", "valueWeight", "showSwitchState", "secondCustomColor", "secondColor",
    "readOnly", "levelCustomColors", "customOkColor", "customWarnColor", "customCritColor",
    "problemUnavailableMinutes", "problemStuckHours", "problemIgnore", "haCounts", "haPopups", "graphYesterday"
])

// Older copies of the automatic backup: "backup.json" -> "backup.1.json" … (newest first)
export const BACKUP_COPIES = 3
export function copyName(path, n) {
    const slash = path.lastIndexOf("/")
    const dot = path.lastIndexOf(".")
    return dot > slash + 1 ? `${path.slice(0, dot)}.${n}${path.slice(dot)}` : `${path}.${n}`
}

export function backupData(configuration, items) {
    const look = {}
    for (const k of LOOK_KEYS) {
        const v = configuration[k]
        look[k] = typeof v === "object" && v !== null ? v.toString() : v
    }
    return JSON.stringify({
        format: "deskhome",
        version: 1,
        exported: new Date().toISOString(),
        url: configuration.url,
        items: items,
        look
    }, null, 2)
}
