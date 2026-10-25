import QtQuick

import "./components"
import "../code/model.mjs" as Model
import "../code/formatter.mjs" as Formatter
import "../code/defaults.mjs" as Defaults

BaseObject {
    property var items: []
    property string language
    readonly property bool initialized: items.length === itemModel.count
    readonly property ListModel itemModel: ListModel {}
    readonly property var getFieldScrollMapper: _.getFieldScrollMapper
    readonly property alias hasFullRepresenationItems: _.hasFullRepresenationItems
    // Incremented on every history change so tiles repaint
    property int historyRevision: 0

    // callLater: only after dependent bindings (e.g. historyHoursByEntityId) are re-evaluated,
    // and several triggers in quick succession result in a single subscription
    onItemsChanged: Qt.callLater(fetchDataAndSubscribe)
    onLanguageChanged: Qt.callLater(fetchDataAndSubscribe)
    // The HA connection is shared between widgets and lives on: unsubscribe when removed,
    // otherwise it keeps calling the deleted store on every value change
    Component.onDestruction: {
        if (_.client) _.client.readyChanged.disconnect(fetchDataAndSubscribe)
        _.unsubscribe()
    }

    function setClient(client) {
        if (_.client) {
            _.unsubscribe()
            _.client.readyChanged.disconnect(fetchDataAndSubscribe)
        }
        _.client = client
        Qt.callLater(fetchDataAndSubscribe)
        _.client.readyChanged.connect(fetchDataAndSubscribe)
    }

    function fetchDataAndSubscribe() {
        if (!_.client?.ready) return
        fetchFieldsInfo()
        _.subscribe()
        _.fetchHistory()
    }

    function history(entityId) {
        return _.histories[entityId] || []
    }

    function fetchFieldsInfo() {
        if (!items.length) return
        _.client.getServices().then(_.initFields)
    }

    function getUsedEntityIds() {
        return Object.keys(_.itemIdxsByEntityId)
    }

    function getUsedDomains() {
        return Array.from(new Set(items.map(i => i.domain)))
    }

    QtObject {
        id: _
        readonly property var fields: new Map()
        property var translations
        readonly property bool hasFullRepresenationItems: items.some(e => e.display & DisplayFilterModel.Full)
        // primary and second (combo tile) entity ids -> indexes of the items that show them
        readonly property var itemIdxsByEntityId: items.reduce((o, item, i) => {
            for (const e of [item.entity_id, item.second_entity_id]) {
                if (!e) continue
                if (!o[e]) o[e] = []
                if (!o[e].includes(i)) o[e].push(i)
            }
            return o
        }, {})
        // last known state of second entities, needed to format partial updates
        property var secondStates: ({})
        readonly property var entityModelOptions: ({ valueFormatter: getDisplayValue })
        property Client client
        property var cancelSubscription
        property var histories: ({})
        readonly property var historyHoursByEntityId: items.reduce((o, i) => {
            if (!wantsHistory(i)) return o
            const hours = Defaults.historyHoursOf(i)
            o[i.entity_id] = Math.max(o[i.entity_id] || 0, hours)
            if (i.tile === "combo" && i.second_entity_id) o[i.second_entity_id] = Math.max(o[i.second_entity_id] || 0, hours)
            return o
        }, {})

        function wantsHistory(config) {
            if (Defaults.historyHoursOf(config) <= 0) return false
            if (config.tile === "sensor" || config.tile === "combo") return true
            if (config.tile && config.tile !== "auto") return false
            return ["sensor", "number", "input_number", "counter"].includes(config.domain)
        }

        function fetchHistory() {
            const ids = Object.keys(historyHoursByEntityId)
            if (!ids.length) return
            const hours = Math.max(...Object.values(historyHoursByEntityId))
            const start = new Date(Date.now() - hours * 3600000)
            client.getHistory(ids, start).then(result => {
                const h = {}
                for (const id of ids) {
                    h[id] = (result[id] || [])
                        .map(e => [((e.lu ?? e.lc) || 0) * 1000, +e.s])
                        .filter(p => p[0] && !isNaN(p[1]))
                }
                histories = h
                historyRevision++
            }).catch(e => console.warn("DeskHome: Verlauf nicht ladbar", JSON.stringify(e)))
        }

        function appendHistory(id, change) {
            const points = histories[id]
            if (!points || change.s === undefined || isNaN(+change.s)) return
            points.push([change.lu ? change.lu * 1000 : Date.now(), +change.s])
            historyRevision++
        }

        function pruneHistory() {
            const now = Date.now()
            for (const id in histories) {
                const from = now - (historyHoursByEntityId[id] || 0) * 3600000
                const points = histories[id]
                // keep one point before the window start so the line begins at the left edge
                let cut = 0
                while (cut < points.length - 1 && points[cut + 1][0] < from) cut++
                if (cut) points.splice(0, cut)
            }
            historyRevision++
        }

        readonly property var noValueStates: ({
            'unknown': root.tr('state.unknown'),
            'unavailable': root.tr('state.unavailable')
        })

        function filterRelevantTranslations(r) {
            const result = {};
            for (const k in r) {
                if (k.includes(".state.")) result[k] = r[k];
            }
            return result
        }

        function getTranslationKey(state, domain = "_", device_class = "_") {
            return `component.${domain}.entity_component.${device_class}.state.${state}`
        }

        function loadTranslations() {
            if (language === 'en') {
                translations = undefined
                return Promise.resolve()
            }
            return client.getTranslations(language, "entity_component", getUsedDomains()).then(({ resources }) => {
                translations = filterRelevantTranslations(resources)
            })
        }

        function getDisplayValue({ attributes, state }, config = {}) {
            const { attribute, domain } = config
            const value_number_precision = config.value_number_precision ?? Formatter.getDefaultPrecision(state || '')
            if (attribute && attributes[attribute]) return attributes[attribute] + ''
            if (!state) return ''
            const unit = attributes.unit_of_measurement
            if (unit && !(state in noValueStates)) return Formatter.formatIfNumber(state, value_number_precision) + (unit === '%' ? unit : ' ' + unit)
            if (!translations) return state
            return translations[getTranslationKey(state, domain, attributes.device_class)]
                || translations[getTranslationKey(state, domain)]
                || noValueStates[state]
                || state
        }

        function subscribe() {
            unsubscribe()
            itemModel.clear()
            if (!items.length) return
            loadTranslations().then(() => {
                cancelSubscription = client.subscribeEntities(getUsedEntityIds(), processState)
            })
        }

        function unsubscribe() {
            cancelSubscription = typeof cancelSubscription === 'function' && cancelSubscription()
        }

        function updateState(state) {
            for (const id in state) {
                const itemIdxs = itemIdxsByEntityId[id] || []
                const change = state[id]['+']
                if (change) appendHistory(id, change)
                for (const itemIdx of itemIdxs) {
                    const config = items[itemIdx]
                    const item = itemModel.get(itemIdx)
                    if (config.second_entity_id === id) {
                        const previous = secondStates[id] || {}
                        const merged = {
                            state: change?.s ?? previous.state,
                            attributes: Object.assign({}, previous.attributes, change?.a)
                        }
                        secondStates[id] = merged
                        itemModel.set(itemIdx, new Model.SecondValue(config, merged, entityModelOptions))
                        if (config.entity_id !== id) continue
                    }
                    const newItem = new Model.EntityUpdate(config, change, item, entityModelOptions)
                    const oldValue = item.value
                    itemModel.set(itemIdx, newItem)
                    if (config.notify && oldValue !== newItem.value) {
                        notifications.createNotification(item.name + " " + newItem.value)
                    }
                }
            }
        }

        function setState(state) {
            items.forEach((config, idx) => {
                const entityData = state[config.entity_id]
                if (!entityData && initialized) return
                itemModel.set(idx, new Model.Entity(config, entityData, entityModelOptions))
                const second = config.second_entity_id && state[config.second_entity_id]
                if (second) {
                    secondStates[config.second_entity_id] = { state: second.s, attributes: second.a || {} }
                    itemModel.set(idx, new Model.SecondValue(config, secondStates[config.second_entity_id], entityModelOptions))
                }
            })
        }

        function processState(event) {
            if (event.a) setState(event.a)
            if (event.c) updateState(event.c)
        }

        readonly property Timer pruneTimer: Timer {
            interval: 300000
            running: true
            repeat: true
            onTriggered: _.pruneHistory()
        }

        function fieldKey(action) {
            return action.domain + action.service + action.data_field
        }

        function initFields(services) {
            fields.clear()
            for (const { scroll_action: action } of items) {
                if (!action) continue
                const field = services.getService(action.domain, action.service)
                    .findField(f => f.name === action.data_field, true)
                fields.set(fieldKey(action), field)
            }
        }

        function getFieldScrollMapper(action, attrs) {
            const field = fields.get(fieldKey(action))
            if (!field) return { normalize: () => 0, denormalize: v => v, attribute: action.data_field }
            const max = attrs['max_' + field.name] ?? attrs[field.overrides.max] ?? field.selector.number.max ?? 1
            const min = attrs['min_' + field.name] ?? attrs[field.overrides.min] ?? field.selector.number.min ?? 0
            return {
                normalize: value => (value - min) / (max - min),
                denormalize: value => value * (max - min) + min,
                attribute: field.overrides.attribute || field.name
            }
        }
    }
}