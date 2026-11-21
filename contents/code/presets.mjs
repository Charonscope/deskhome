// Ready-made looks (Appearance → Template). A template only sets the shape of the tiles:
// style, opacity, corners, borders, sizes and spacing. Colors stay with the color source,
// so every template can be combined with Plasma, a Home Assistant theme or a built-in palette.

// keys a template writes; the "undo" snapshot covers exactly these
export const PRESET_KEYS = Object.freeze([
    "flat", "tileStyle", "tileOpacity", "tileRadius", "tileBorder", "levelBorder", "activeFrame",
    "tileScale", "tileSpacing", "labelScale", "valueScale", "valueWeight", "graphFill", "graphLineWidth"
])

// the defaults from main.xml; every template starts from these
const BASE = Object.freeze({
    flat: true, tileStyle: "flat", tileOpacity: 78, tileRadius: 8, tileBorder: true, levelBorder: true,
    activeFrame: false, tileScale: 100, tileSpacing: 6, labelScale: 100, valueScale: 100, valueWeight: 700,
    graphFill: true, graphLineWidth: 1.5
})

export const PRESETS = Object.freeze([
    { id: "classic", values: {} },
    { id: "glass", values: { tileStyle: "glass", tileOpacity: 55, tileRadius: 14, tileSpacing: 8, labelScale: 95, valueScale: 90, valueWeight: 600 } },
    { id: "cockpit", values: { tileStyle: "cockpit", tileOpacity: 88, tileRadius: 5, tileSpacing: 4, labelScale: 90, valueScale: 95 } },
    { id: "bento", values: { tileStyle: "bento", tileOpacity: 82, tileRadius: 18, tileBorder: false, tileSpacing: 8, valueScale: 115 } },
    { id: "minimal", values: { tileStyle: "minimal", tileSpacing: 10, valueScale: 110, valueWeight: 600, graphFill: false } },
    { id: "minimalDark", values: { tileStyle: "minimalDark", tileSpacing: 10, valueScale: 110, valueWeight: 600, graphFill: false } },
    { id: "compact", values: { tileOpacity: 85, tileRadius: 6, tileSpacing: 3, tileScale: 80, labelScale: 85, valueScale: 85 } },
    { id: "large", values: { tileRadius: 12, tileSpacing: 9, tileScale: 130, labelScale: 125, valueScale: 140 } }
])

// all PRESET_KEYS for a template, or null if the id is unknown
export function presetValues(id) {
    const preset = PRESETS.find(p => p.id === id)
    return preset ? Object.assign({}, BASE, preset.values) : null
}
