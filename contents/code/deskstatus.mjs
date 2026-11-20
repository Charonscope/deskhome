// Desk Status (beta): DeskHome reports the state of this computer to Home Assistant and can run
// simple rules ("when the PC is unlocked, switch on the desk light if it is dark").
//
// Reporting uses Home Assistant's mobile app interface, the same one the Companion apps use:
// DeskHome registers the computer once (POST /api/mobile_app/registrations) and then sends
// sensor values to the webhook it gets back. The computer shows up as a device with its own
// entities, without any YAML and without an extra program.
//
// This file holds the parts without Qt: reading the collected system values, the sensor
// definitions, the messages for Home Assistant and the rule logic. DeskStatus.qml runs it.

// One shell call collects everything; each line is KEY=value. Every part may fail on its own
// (no PipeWire, no logind …); the sensor is then left out instead of breaking the rest.
export const COLLECT_COMMAND = [
    'echo "SS=$(busctl --user call org.freedesktop.ScreenSaver /ScreenSaver org.freedesktop.ScreenSaver GetActive 2>/dev/null)"',
    'echo "LH=$(loginctl show-session "${XDG_SESSION_ID:-$(loginctl show-user "$(id -u)" -p Display --value 2>/dev/null)}" -p LockedHint --value 2>/dev/null)"',
    'echo "VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)"',
    'echo "CPU=$(head -1 /proc/stat 2>/dev/null)"',
    'echo "MEM=$(awk \'/^MemTotal:|^MemAvailable:/{printf "%s ", $2}\' /proc/meminfo 2>/dev/null)"',
    "true"
].join("; ")

export const HOSTNAME_COMMAND = "uname -n"

// Sensors the user can switch on. `type` is the Home Assistant platform; `states` lists
// the fixed values of a text sensor (English, so automations work in every language).
export const SENSORS = Object.freeze([
    { key: "status", type: "sensor", icon: "mdi:monitor", states: ["active", "locked", "off"] },
    { key: "locked", type: "binary_sensor", icon: "mdi:monitor-lock" },
    { key: "volume", type: "sensor", icon: "mdi:volume-high", unit: "%", stateClass: "measurement" },
    { key: "muted", type: "binary_sensor", icon: "mdi:volume-off" },
    { key: "cpu", type: "sensor", icon: "mdi:cpu-64-bit", unit: "%", stateClass: "measurement" },
    { key: "memory", type: "sensor", icon: "mdi:memory", unit: "%", stateClass: "measurement" }
])
export const DEFAULT_SENSORS = Object.freeze(["status", "locked"])

export const TRIGGERS = Object.freeze(["start", "unlock", "lock", "stop"])

// Parses the output of COLLECT_COMMAND. `previousCpu` is the CPU counter of the last call
// (the load is the difference between two calls). Returns { values, cpu }; a value that
// could not be read is missing from `values`.
export function parse(output, previousCpu) {
    const lines = {}
    for (const line of String(output || "").split("\n")) {
        const i = line.indexOf("=")
        if (i > 0) lines[line.slice(0, i).trim()] = line.slice(i + 1).trim()
    }
    const values = {}

    // locked: the screen saver interface ("b true") or logind's hint ("yes"); either is enough
    const ss = lines.SS || ""
    const lh = lines.LH || ""
    if (/\b(true|false)\b/.test(ss) || /^(yes|no)$/.test(lh)) {
        values.locked = /\btrue\b/.test(ss) || lh === "yes"
        values.status = values.locked ? "locked" : "active"
    }

    // "Volume: 0.45" or "Volume: 0.45 [MUTED]"
    const vol = /Volume:\s*([\d.]+)(.*)/.exec(lines.VOL || "")
    if (vol) {
        values.volume = Math.round(parseFloat(vol[1]) * 100)
        values.muted = /MUTED/.test(vol[2])
    }

    // "cpu  user nice system idle iowait irq softirq steal …"
    let cpu = null
    const fields = (lines.CPU || "").split(/\s+/).slice(1).map(Number).filter(n => !isNaN(n))
    if (fields.length >= 4) {
        const idle = fields[3] + (fields[4] || 0)
        const total = fields.reduce((a, b) => a + b, 0)
        cpu = { idle, total }
        if (previousCpu && total > previousCpu.total) {
            const busy = 1 - (idle - previousCpu.idle) / (total - previousCpu.total)
            values.cpu = Math.round(Math.min(1, Math.max(0, busy)) * 100)
        }
    }

    const mem = (lines.MEM || "").split(/\s+/).map(Number).filter(n => n > 0)
    if (mem.length === 2 && mem[0] >= mem[1]) {
        values.memory = Math.round((mem[0] - mem[1]) / mem[0] * 100)
    }
    return { values, cpu }
}

// Name of a sensor in Home Assistant. The mobile app integration puts the device name in
// front by itself ("cachypapa" + "Status" -> "cachypapa Status", sensor.cachypapa_status),
// so the sensor only gets its own label.
export function sensorName(label) {
    return String(label || "").trim()
}

// Body for POST /api/mobile_app/registrations
export function registration({ deviceId, deviceName, version, osVersion }) {
    return {
        device_id: deviceId,
        app_id: "io.github.deskhome",
        app_name: "DeskHome",
        app_version: version || "",
        device_name: deviceName,
        manufacturer: "DeskHome",
        model: "Linux PC",
        os_name: "Linux",
        os_version: osVersion || "",
        supports_encryption: false,
        app_data: {}
    }
}

// Webhook message that creates (or updates the definition of) one sensor
export function registerSensor(def, name, state) {
    const data = {
        unique_id: def.key,
        type: def.type,
        name,
        icon: def.icon,
        // not measured yet: false for a binary sensor, otherwise "unknown" (null)
        state: state ?? (def.type === "binary_sensor" ? false : null)
    }
    if (def.unit) data.unit_of_measurement = def.unit
    if (def.stateClass) data.state_class = def.stateClass
    if (def.key === "cpu" || def.key === "memory") data.entity_category = "diagnostic"
    return { type: "register_sensor", data }
}

// Webhook message with the current values of the given sensors
export function updateStates(values, keys) {
    const data = []
    for (const key of keys) {
        if (!(key in values)) continue
        const def = SENSORS.find(s => s.key === key)
        if (!def) continue
        data.push({ unique_id: key, type: def.type, state: values[key], icon: iconFor(key, values[key], def.icon) })
    }
    return { type: "update_sensor_states", data }
}

function iconFor(key, value, fallback) {
    if (key === "status") return value === "locked" ? "mdi:monitor-lock" : value === "off" ? "mdi:monitor-off" : "mdi:monitor"
    if (key === "locked") return value ? "mdi:monitor-lock" : "mdi:monitor"
    if (key === "muted") return value ? "mdi:volume-off" : "mdi:volume-high"
    return fallback
}

// Keys whose value differs from the last values sent
export function changedKeys(values, sent, keys) {
    return keys.filter(k => k in values && values[k] !== sent[k])
}

// Events between two samples of the lock state. The first sample of a session gives "start"
// when the session is unlocked (a locked start reports "unlock" later instead).
export function events(previousLocked, locked) {
    if (locked === undefined) return []
    if (previousLocked === undefined) return locked ? [] : ["start"]
    if (previousLocked && !locked) return ["unlock"]
    if (!previousLocked && locked) return ["lock"]
    return []
}

// Rules as stored in the configuration (JSON list); broken entries are dropped
export function parseRules(json) {
    let list
    try { list = JSON.parse(json || "[]") } catch (e) { return [] }
    if (!Array.isArray(list)) return []
    return list.filter(r => r && typeof r === "object").map(r => ({
        enabled: r.enabled !== false,
        trigger: TRIGGERS.includes(r.trigger) ? r.trigger : "unlock",
        entity: String(r.entity || ""),
        action: r.action === "off" ? "off" : "on",
        brightness: Math.max(0, Math.min(100, parseInt(r.brightness) || 0)),
        condEntity: String(r.condEntity || ""),
        condOp: r.condOp === "above" ? "above" : "below",
        condValue: isFinite(parseFloat(r.condValue)) ? parseFloat(r.condValue) : 0
    }))
}

// Is the rule's condition met by this state object (from get_states)? No condition = always.
// A sensor that is unavailable or not a number does not meet it (nothing happens).
export function conditionMet(rule, state) {
    if (!rule.condEntity) return true
    const value = parseFloat(state?.state)
    if (!isFinite(value)) return false
    return rule.condOp === "above" ? value > rule.condValue : value < rule.condValue
}

// The service call of a rule: { domain, service, target, data }
export function serviceCall(rule) {
    const domain = rule.entity.split(".")[0]
    const target = { entity_id: rule.entity }
    // scenes and scripts can only be started
    if (domain === "scene" || domain === "script") return { domain, service: "turn_on", target, data: {} }
    if (rule.action === "off") return { domain, service: "turn_off", target, data: {} }
    const data = domain === "light" && rule.brightness > 0 ? { brightness_pct: rule.brightness } : {}
    return { domain, service: "turn_on", target, data }
}

// A random device id (once per widget; the same computer keeps it)
export function newDeviceId() {
    const hex = () => Math.floor(Math.random() * 0x10000).toString(16).padStart(4, "0")
    return `deskhome-${hex()}${hex()}-${hex()}-${hex()}`
}
