// Version numbers like "1.3.0" or "v1.3.1"

export function parseVersion(text) {
    const m = /^v?(\d+)\.(\d+)(?:\.(\d+))?/.exec(String(text || "").trim())
    return m ? [+m[1], +m[2], +(m[3] || 0)] : null
}

// true if "candidate" is newer than "current"; unknown versions are never newer
export function isNewer(candidate, current) {
    const a = parseVersion(candidate), b = parseVersion(current)
    if (!a || !b) return false
    for (let i = 0; i < 3; i++) {
        if (a[i] !== b[i]) return a[i] > b[i]
    }
    return false
}
