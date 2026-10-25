import { tr } from "i18n.mjs"

// "5 min ago" style text for the time since the last change
export function ago(lang, ms, now) {
    if (!ms) return ""
    const s = Math.max(0, (now - ms) / 1000)
    if (s < 60) return tr(lang, "ago.now")
    if (s < 3600) return tr(lang, "ago.min", Math.floor(s / 60))
    if (s < 86400) return tr(lang, "ago.h", Math.floor(s / 3600))
    return tr(lang, "ago.d", Math.floor(s / 86400))
}
