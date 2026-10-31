// Finds devices that are gone and sensors that hang, without any tiles:
// - "unavailable": devices whose entities have all been unavailable for at least
//   `unavailableMinutes`. A device with only some unavailable entities still works (an
//   offline client of a router, a disabled app sensor of a phone) and is not listed.
//   Entities without a device are not listed either: there are many, and most are leftovers.
// - "stuck": motion/occupancy/presence sensors that have been "on" for at least `stuckHours`
// Only entities a user would put on a tile count: not hidden, no configuration/diagnostic ones.

export const UNAVAILABLE = "unavailable"
export const STUCK = "stuck"

// these domains say nothing about a device being reachable; media players are often
// "unavailable" simply because the TV or console is switched off
const SKIPPED_DOMAINS = Object.freeze(["button", "event", "scene", "script", "automation", "update",
    "image", "tts", "stt", "conversation", "notify", "persistent_notification", "zone", "person", "sun",
    "media_player"])
const MOTION_CLASSES = Object.freeze(["motion", "occupancy", "presence", "moving"])

// "sensor.old_*, light.x" -> matcher; * matches anything
export function ignoreMatcher(text) {
    const patterns = String(text || "").split(/[\s,;]+/).filter(p => p)
        .map(p => new RegExp("^" + p.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*") + "$"))
    return id => patterns.some(r => r.test(id))
}

// states: get_states result; registry: { entities: { entity_id: { device_id, hidden, category } },
// deviceNames: { device_id: name } }; now in ms
export function findProblems(states, registry, options, now) {
    const unavailableMs = (options.unavailableMinutes || 0) * 60000
    const stuckMs = (options.stuckHours || 0) * 3600000
    const ignored = ignoreMatcher(options.ignore)
    // device_id -> { total, gone, entity_ids, since }
    const devices = {}
    const result = []
    for (const s of states || []) {
        const id = s.entity_id
        const entry = registry.entities?.[id]
        if (entry && (entry.hidden || entry.category)) continue
        if (SKIPPED_DOMAINS.includes(id.split(".")[0]) || ignored(id)) continue
        const since = Date.parse(s.last_changed) || now
        const deviceId = entry?.device_id
        if (unavailableMs > 0 && deviceId && registry.deviceNames?.[deviceId] !== undefined) {
            const d = devices[deviceId] || (devices[deviceId] = { total: 0, gone: 0, entity_ids: [], since: 0 })
            d.total++
            if (s.state === "unavailable") {
                d.gone++
                d.entity_ids.push(id)
                // gone since the last of its entities went
                d.since = Math.max(d.since, since)
            }
        }
        if (stuckMs > 0 && s.state === "on" && id.startsWith("binary_sensor.")
            && MOTION_CLASSES.includes(s.attributes?.device_class) && now - since >= stuckMs) {
            result.push({ kind: STUCK, name: s.attributes?.friendly_name || id, device_id: deviceId || "", entity_ids: [id], since })
        }
    }
    for (const deviceId in devices) {
        const d = devices[deviceId]
        if (d.gone && d.gone === d.total && now - d.since >= unavailableMs) {
            result.push({ kind: UNAVAILABLE, name: registry.deviceNames[deviceId] || d.entity_ids[0], device_id: deviceId, entity_ids: d.entity_ids, since: d.since })
        }
    }
    // gone devices first, then hanging sensors; the longest-standing problem first
    result.sort((a, b) => (a.kind === b.kind ? 0 : a.kind === UNAVAILABLE ? -1 : 1) || a.since - b.since)
    return result
}
