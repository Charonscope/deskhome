// Status level of an entity: 0 = ok, 1 = warning, 2 = critical
export const OK = 0
export const WARN = 1
export const CRIT = 2

// binary_sensor device classes where "on" means a problem
const PROBLEM_CLASSES = Object.freeze([
    "battery", "carbon_monoxide", "cold", "gas", "heat", "moisture",
    "problem", "safety", "smoke", "tamper", "update"
])

function num(v) {
    if (v === undefined || v === null || v === "") return NaN
    return +v
}

function thresholdsOf(config, deviceClass) {
    const t = {
        warn_below: num(config.warn_below),
        crit_below: num(config.crit_below),
        warn_above: num(config.warn_above),
        crit_above: num(config.crit_above)
    }
    const noneSet = Object.values(t).every(isNaN)
    if (noneSet && deviceClass === "battery") {
        t.warn_below = 30
        t.crit_below = 15
    }
    return t
}

export function levelOf(config = {}, entity = {}) {
    const state = entity.state
    const attributes = entity.attributes || {}
    if (state === "unavailable") return CRIT
    if (state === "unknown" || state === "") return WARN

    const okStates = (config.ok_states || "").split(",").map(s => s.trim()).filter(s => s)
    if (okStates.length) return okStates.includes(state) ? OK : CRIT

    const domain = config.domain
    if (domain === "binary_sensor") {
        return state === "on" && PROBLEM_CLASSES.includes(attributes.device_class) ? CRIT : OK
    }

    const value = num(state)
    if (isNaN(value)) return OK
    const t = thresholdsOf(config, attributes.device_class)
    if (value < t.crit_below || value > t.crit_above) return CRIT
    if (value < t.warn_below || value > t.warn_above) return WARN
    return OK
}
