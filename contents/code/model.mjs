import { isActiveState } from "states.mjs"
import { levelOf } from "levels.mjs"
import { tileKind, historyHoursOf, fallbackIcon } from "defaults.mjs"

export function EntityUpdate(config = {}, update = {}, entity = {}, options = {}) {
    this.attributes = Object.assign({}, entity.attributes, update.a)
    this.icon = config.icon || this.attributes.icon || ''
    this.state = update.s || entity.state || ''
    // last state change (ms); HA sends lc only when the state itself changed
    this.last_changed = update.lc ? update.lc * 1000 : (entity.last_changed || 0)
    this.active = isActiveState(config.domain, this.state)
    this.value = options.valueFormatter?.(this, config) ?? ''
    // Flat helper values for the tiles (nested objects/arrays are awkward in a ListModel)
    this.kind = tileKind(config, this.state)
    this.level = levelOf(config, this)
    this.num = this.state !== '' && !isNaN(+this.state) ? +this.state : NaN
    this.unit = this.attributes.unit_of_measurement || ''
    this.device_class = this.attributes.device_class || ''
    if (!this.icon) this.icon = fallbackIcon(config.domain, this.device_class, this.active)
    // rgb_color may come back from the ListModel as an array-like object (not an Array) when
    // an update only carries other attributes, e.g. a new brightness
    const rgb = this.attributes.rgb_color
    this.light_color = rgb && rgb.length === 3 ? `#${[rgb[0], rgb[1], rgb[2]].map(c => Math.round(+c).toString(16).padStart(2, '0')).join('')}` : ''
    const b = this.attributes.brightness
    this.brightness_pct = b === undefined || b === null ? -1 : Math.round(b / 2.55)
    // thermostats (climate)
    const a = this.attributes
    this.current_temp = numberOr(a.current_temperature, NaN)
    this.target_temp = numberOr(a.temperature, NaN)
    this.temp_min = numberOr(a.min_temp, 7)
    this.temp_max = numberOr(a.max_temp, 35)
    this.temp_step = numberOr(a.target_temp_step, 0.5)
    this.current_humidity = numberOr(a.current_humidity, NaN)
    this.hvac_action = a.hvac_action || ''
    // fans: speed in percent (-1 = unknown)
    this.fan_pct = numberOr(a.percentage, -1)
}

function numberOr(v, fallback) {
    return v === undefined || v === null || v === '' || isNaN(+v) ? fallback : +v
}

// Second value of a combo tile (e.g. humidity next to temperature)
export function SecondValue(config = {}, data = {}, options = {}) {
    const attributes = data.attributes || data.a || {}
    const state = data.state ?? data.s ?? ''
    const secondConfig = { domain: (config.second_entity_id || '').split('.')[0], value_number_precision: config.value_number_precision }
    this.value2 = options.valueFormatter?.({ attributes, state }, secondConfig) ?? ''
    this.num2 = state !== '' && !isNaN(+state) ? +state : NaN
}

export function Entity(config = {}, data = {}, options = {}) {
    Object.assign(this, new EntityUpdate(config, data, undefined, options))
    this.entity_id = config.entity_id
    this.name = config.name || this.attributes.friendly_name || ''
    this.attribute = config.attribute || ''
    this.default_action = config.default_action || {}
    this.dclick_action = config.dclick_action || {}
    this.scroll_action = config.scroll_action || {}
    this.display = config.display ?? 1
    this.domain = config.domain || ''
    // 0.5 = half tile, otherwise whole columns
    this.colspan = +config.colspan === 0.5 ? 0.5 : Math.max(1, +config.colspan || 1)
    this.history_hours = historyHoursOf(config)
    this.hide_when_ok = !!config.hide_when_ok
    this.second_entity_id = config.second_entity_id || ''
    // heading shown above this tile, starting a new row
    this.heading = config.heading || ''
    // own colors of this tile ('' = the global colors)
    this.value_color = config.value_color || ''
    this.label_color = config.label_color || ''
    this.second_color = config.second_color || ''
    this.graph_color = config.graph_color || ''
    this.bg_color = config.bg_color || ''
    // own background opacity in % (-1 = the global one)
    this.bg_opacity = config.bg_opacity === undefined || config.bg_opacity === null || config.bg_opacity === '' ? -1 : +config.bg_opacity
    this.value2 = ''
    this.num2 = NaN
}

export function ConfigEntity(config = {}) {
    Object.defineProperties(this, {
        entity_id: {
            enumerable: true,
            get: function() { return this[Symbol.for('entity_id')] },
            set: function(id) {
                this[Symbol.for('entity_id')] = id
                this[Symbol.for('domain')] = id.substring(0, id.indexOf('.'))
                updateAction(this, 'default_action')
                updateAction(this, 'dclick_action')
                updateAction(this, 'scroll_action')
            }
        },
        domain: {
            enumerable: true,
            get: function() { return this[Symbol.for('domain')] }
        }
    });

    addActionProperty(this, 'default_action')
    addActionProperty(this, 'dclick_action')
    addActionProperty(this, 'scroll_action')

    this.entity_id = config.entity_id || ''
    this.name = config.name
    this.icon = config.icon
    this.attribute = config.attribute
    this.display = config.display ?? 1
    this.default_action = config.default_action
    this.dclick_action = config.dclick_action
    this.scroll_action = config.scroll_action
    this.notify = config.notify
    this.value_number_precision = config.value_number_precision
    this.tile = config.tile
    this.colspan = config.colspan
    this.history_hours = config.history_hours
    this.warn_below = config.warn_below
    this.crit_below = config.crit_below
    this.warn_above = config.warn_above
    this.crit_above = config.crit_above
    this.ok_states = config.ok_states
    this.hide_when_ok = config.hide_when_ok
    this.second_entity_id = config.second_entity_id
    this.heading = config.heading
    this.value_color = config.value_color
    this.label_color = config.label_color
    this.second_color = config.second_color
    this.graph_color = config.graph_color
    this.bg_color = config.bg_color
    this.bg_opacity = config.bg_opacity
}

function addActionProperty(o, name) {
    Object.defineProperty(o, name, {
        enumerable: true,
        get: function() { return o[Symbol.for(name)] },
        set: function(action) {
            o[Symbol.for(name)] = !action?.service ? null : {
                service: action.service,
                domain: action.domain || o.domain,
                target: action.target || { entity_id: o.entity_id },
                data_field: action.data_field
            }
        }
    })
}

function updateAction(o, name) {
    if (!o[name]) return
    if (o.domain !== o[name].domain) return o[name] = null
    o[name].target.entity_id = o.entity_id
}
