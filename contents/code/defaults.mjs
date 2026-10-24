// Kachel-Typen und Standard-Aktionen, die nicht in der Konfiguration stehen müssen
const TOGGLEABLE = Object.freeze(["light", "switch", "fan", "input_boolean", "cover", "siren", "humidifier"])
const NUMERIC_DOMAINS = Object.freeze(["sensor", "number", "input_number", "counter"])

export const DEFAULT_HISTORY_HOURS = 24

export function tileKind(config = {}, state = "") {
    if (config.tile && config.tile !== "auto") return config.tile
    const domain = config.domain
    if (TOGGLEABLE.includes(domain)) return "switch"
    if (domain === "binary_sensor") return "status"
    if (NUMERIC_DOMAINS.includes(domain) && state !== "" && !isNaN(+state)) return "sensor"
    if (NUMERIC_DOMAINS.includes(domain) && (state === "unavailable" || state === "unknown")) return "sensor"
    return "simple"
}

// Ergänzt Klick-/Scroll-Aktionen für Schalter und Lichter, wenn keine gesetzt sind
export function applyItemDefaults(items = []) {
    return items.map(item => {
        if (item.tile === "simple" || !TOGGLEABLE.includes(item.domain)) return item
        const target = { entity_id: item.entity_id }
        const result = Object.assign({}, item)
        if (!item.default_action?.service) {
            result.default_action = { domain: "homeassistant", service: "toggle", target }
        }
        if (item.domain === "light" && !item.scroll_action?.service) {
            result.scroll_action = { domain: "light", service: "turn_on", target, data_field: "brightness" }
        }
        return result
    })
}

const CLASS_ICONS = Object.freeze({
    temperature: "thermometer", humidity: "water-percent", battery: "battery",
    power: "flash", energy: "lightning-bolt", voltage: "flash", current: "flash",
    data_rate: "speedometer", wind_speed: "weather-windy", pressure: "gauge",
    motion: "motion-sensor", occupancy: "motion-sensor", presence: "motion-sensor",
    door: "door", window: "window-open-variant", connectivity: "lan-connect",
    problem: "alert-circle", running: "check-circle"
})
const DOMAIN_ICONS = Object.freeze({
    light: "lightbulb", switch: "toggle-switch", fan: "fan", input_boolean: "toggle-switch",
    cover: "blinds", sensor: "eye", binary_sensor: "check-circle"
})

// HA liefert für viele Entities kein icon-Attribut (das Frontend leitet es aus device_class ab)
export function fallbackIcon(domain, deviceClass, active) {
    if (domain === "light" && !active) return "mdi:lightbulb-outline"
    if (domain === "battery" || deviceClass === "battery") return "mdi:battery"
    const name = CLASS_ICONS[deviceClass] || DOMAIN_ICONS[domain]
    return name ? `mdi:${name}` : ""
}

export function historyHoursOf(config = {}) {
    const h = config.history_hours
    return h === undefined || h === null || h === "" ? DEFAULT_HISTORY_HOURS : +h
}
