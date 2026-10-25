// Colors from a Home Assistant frontend theme (result of "frontend/get_themes").
// Theme variables are CSS values: hex, rgb()/rgba(), color names or var(--other-variable).

// HA's built-in theme ("default"), which get_themes does not list
const BUILTIN = Object.freeze({
    light: {
        "primary-color": "#03a9f4", "primary-text-color": "#212121", "secondary-text-color": "#727272",
        "disabled-text-color": "#bdbdbd", "card-background-color": "#ffffff",
        "success-color": "#4caf50", "warning-color": "#ff9800", "error-color": "#db4437"
    },
    dark: {
        "primary-color": "#03a9f4", "primary-text-color": "#e1e1e1", "secondary-text-color": "#9b9b9b",
        "disabled-text-color": "#6f6f6f", "card-background-color": "#1c1c1c",
        "success-color": "#4caf50", "warning-color": "#ff9800", "error-color": "#db4437"
    }
})

// palette key -> theme variables, first one that resolves wins
const KEYS = Object.freeze({
    accent: ["primary-color"],
    text: ["primary-text-color"],
    label: ["secondary-text-color"],
    muted: ["disabled-text-color"],
    background: ["ha-card-background", "card-background-color"],
    ok: ["success-color"],
    warn: ["warning-color"],
    crit: ["error-color"]
})

export function themeNames(result) {
    const names = Object.keys(result?.themes || {})
    names.sort((a, b) => a.localeCompare(b))
    return names
}

// The theme in use: the configured one, otherwise HA's default for the mode
export function themeName(result, configured, dark) {
    if (configured) return configured
    return (dark && result?.default_dark_theme) || result?.default_theme || "default"
}

// {accent, text, label, muted, background, ok, warn, crit} as "#rrggbb"; missing ones are ""
export function themePalette(result, configured, dark) {
    const mode = dark ? "dark" : "light"
    const theme = result?.themes?.[themeName(result, configured, dark)] || {}
    const vars = Object.assign({}, BUILTIN[mode], withoutModes(theme), theme.modes?.[mode])
    const palette = {}
    for (const key in KEYS) {
        palette[key] = ""
        for (const name of KEYS[key]) {
            const c = parseColor(resolve(vars, vars[name], 0))
            if (c) {
                palette[key] = c
                break
            }
        }
    }
    return palette
}

function withoutModes(theme) {
    const out = {}
    for (const k in theme) if (k !== "modes" && typeof theme[k] !== "object") out[k] = theme[k]
    return out
}

// Follows var(--name, fallback) references
function resolve(vars, value, depth) {
    if (value === undefined || value === null || depth > 8) return ""
    const s = String(value).trim()
    const m = s.match(/^var\(\s*--([\w-]+)\s*(?:,\s*(.+))?\)$/)
    if (!m) return s
    const ref = resolve(vars, vars[m[1]], depth + 1)
    return ref || resolve(vars, m[2], depth + 1)
}

const hex2 = n => Math.max(0, Math.min(255, Math.round(n))).toString(16).padStart(2, "0")

// CSS color -> "#rrggbb" (alpha is dropped, DeskHome has its own opacity), "" if unknown
export function parseColor(value) {
    const s = String(value || "").trim().toLowerCase()
    let m = s.match(/^#([0-9a-f]{3,8})$/)
    if (m) {
        const h = m[1]
        if (h.length === 3 || h.length === 4) return "#" + h[0] + h[0] + h[1] + h[1] + h[2] + h[2]
        if (h.length === 6 || h.length === 8) return "#" + h.substring(0, 6)
        return ""
    }
    m = s.match(/^rgba?\(\s*([\d.]+)[\s,]+([\d.]+)[\s,]+([\d.]+)/)
    if (m) return "#" + hex2(+m[1]) + hex2(+m[2]) + hex2(+m[3])
    m = s.match(/^hsla?\(\s*([\d.]+)(?:deg)?[\s,]+([\d.]+)%[\s,]+([\d.]+)%/)
    if (m) return hslToHex(+m[1], +m[2] / 100, +m[3] / 100)
    if (/^[a-z]+$/.test(s) && s !== "transparent" && s !== "inherit" && s !== "initial") return s
    return ""
}

function hslToHex(h, s, l) {
    const a = s * Math.min(l, 1 - l)
    const f = n => {
        const k = (n + h / 30) % 12
        return 255 * (l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1)))
    }
    return "#" + hex2(f(0)) + hex2(f(8)) + hex2(f(4))
}
