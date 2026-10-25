import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "components"
import "../code/formatter.mjs" as Formatter
import "../code/attributesBlacklist.mjs" as Ab
import "../code/i18n.mjs" as I18n

Kirigami.FormLayout {
    id: form
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }
    property var item
    readonly property var source: item.entity_id && entities[item.entity_id] || {}
    readonly property list<string> itemServiceNames: services.getNames(item.domain)
    // Suggestions with display name and area, so entities can be found without knowing their id
    function entityChoices(filter) {
        const areaOf = entityAreas?.areaOf || {}
        return Object.keys(entities).filter(id => !filter || filter(id)).sort().map(id => ({
            value: id,
            title: entities[id].attributes?.friendly_name || id,
            subtitle: areaOf[id] ? `${id} · ${areaOf[id]}` : id
        }))
    }

    TextField {
        Kirigami.FormData.label: tr("item.entity")
        text: item.entity_id
        placeholderText: tr("item.entitySearch")
        onEditingFinished: {
            item.entity_id = text
            itemChanged()
        }
        Autocompletion {
            model: form.entityChoices()
        }
    }

    RestorableComboBox {
        readonly property int steps: 7
        Kirigami.FormData.label: tr("item.precision")
        visible: !isNaN(+source.state) && !attributeSelector.enabled
        // undefined = automatic (about three significant digits), -1 = exactly as HA sends it
        model: [{
            text: tr("item.precisionAuto", Formatter.formatIfNumber(source.state, Formatter.getDefaultPrecision(String(source.state ?? "")))),
            value: undefined
        }, {
            text: tr("item.precisionRaw", source.state),
            value: -1
        }, ...Array.from({ length: steps }, (_, i) => ({
            text: Formatter.formatIfNumber(source.state, i),
            value: i
        }))]
        textRole: "text"
        valueRole: "value"
        onActivated: item.value_number_precision = currentValue
        initialValue: item.value_number_precision
    }

    CheckableFormControl {
        Kirigami.FormData.label: tr("item.attribute")
        visible: attributeSelector.model?.length > 0
        checked: ~attributeSelector.currentIndex
        RestorableComboBox {
            id: attributeSelector
            model: source.attributes ? Ab.filter(Object.keys(source.attributes)).sort() : []
            onActivated: index => item.attribute = model[index]
            initialValue: item.attribute
            onEnabledChanged: !enabled && activated(-1)
        }
    }

    TextField {
        text: item.name || ''
        placeholderText: source.attributes?.friendly_name || ''
        onTextChanged: item.name = text
        Kirigami.FormData.label: tr("item.name")
    }

    TextField {
        text: item.heading || ''
        placeholderText: tr("item.headingPlaceholder")
        onTextChanged: item.heading = text.trim() || undefined
        Kirigami.FormData.label: tr("item.heading")
    }

    Row {
        Kirigami.FormData.label: tr("item.icon")
        spacing: Kirigami.Units.smallSpacing
        TextField {
            id: iconName
            text: item.icon || ''
            placeholderText: source.attributes?.icon || 'mdi: | plasma:'
            onTextChanged: item.icon = text
        }
        DynamicIcon {
            name: iconName.text || iconName.placeholderText
            height: iconName.height
            width: height
        }
    }

    CheckBox {
        Kirigami.FormData.label: tr("item.notify")
        checked: !!item.notify
        onCheckedChanged: item.notify = checked
    }

    // --- Tile options (DeskHome) ---
    readonly property bool sourceIsNumber: source.state !== undefined && source.state !== '' && !isNaN(+source.state)

    function parseNumber(text) {
        const t = text.trim().replace(',', '.')
        return t === '' || isNaN(+t) ? undefined : +t
    }

    component NumberField: TextField {
        property string key
        text: form.item[key] ?? ''
        placeholderText: '–'
        implicitWidth: Kirigami.Units.gridUnit * 5
        validator: RegularExpressionValidator { regularExpression: /^-?\d*([.,]\d*)?$/ }
        onTextChanged: form.item[key] = form.parseNumber(text)
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: tr("item.tile")
    }

    ComboBox {
        Kirigami.FormData.label: tr("item.tileType")
        textRole: "text"
        valueRole: "value"
        model: [
            { value: "auto", text: tr("item.type.auto") },
            { value: "sensor", text: tr("item.type.sensor") },
            { value: "combo", text: tr("item.type.combo") },
            { value: "switch", text: tr("item.type.switch") },
            { value: "status", text: tr("item.type.status") },
            { value: "thermostat", text: tr("item.type.thermostat") },
            { value: "simple", text: tr("item.type.simple") }
        ]
        Component.onCompleted: currentIndex = Math.max(0, indexOfValue(item.tile || "auto"))
        onActivated: {
            item.tile = currentValue === "auto" ? undefined : currentValue
            form.tileType = currentValue
        }
    }

    property string tileType: item.tile || "auto"

    TextField {
        Kirigami.FormData.label: tr("item.secondEntity")
        visible: form.tileType === "combo"
        text: item.second_entity_id || ""
        placeholderText: "sensor.…"
        onTextChanged: item.second_entity_id = text.trim() || undefined
        Autocompletion {
            model: form.entityChoices(e => e.startsWith("sensor.") || e.startsWith("number.") || e.startsWith("input_number."))
        }
    }

    Label {
        visible: form.tileType === "combo"
        text: tr("item.secondHint")
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        Layout.maximumWidth: Kirigami.Units.gridUnit * 18
    }

    ComboBox {
        Kirigami.FormData.label: tr("item.width")
        textRole: "text"
        valueRole: "value"
        model: [
            { value: 0.5, text: tr("item.widthHalf") },
            { value: 1, text: "1" },
            { value: 2, text: "2" },
            { value: 3, text: "3" },
            { value: 4, text: "4" }
        ]
        Component.onCompleted: currentIndex = Math.max(0, indexOfValue(+item.colspan || 1))
        onActivated: item.colspan = currentValue === 1 ? undefined : currentValue
    }

    Label {
        text: tr("item.widthHint")
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        Layout.maximumWidth: Kirigami.Units.gridUnit * 18
    }

    ComboBox {
        Kirigami.FormData.label: tr("item.history")
        visible: sourceIsNumber
        textRole: "text"
        valueRole: "value"
        model: [
            { value: 0, text: tr("item.historyOff") },
            { value: 1, text: tr("item.hour") },
            { value: 6, text: tr("item.hours", 6) },
            { value: 12, text: tr("item.hours", 12) },
            { value: 24, text: tr("item.hours", 24) },
            { value: 48, text: tr("item.hours", 48) },
            { value: 168, text: tr("item.days", 7) }
        ]
        Component.onCompleted: currentIndex = Math.max(0, indexOfValue(item.history_hours ?? 24))
        onActivated: item.history_hours = currentValue === 24 ? undefined : currentValue
    }

    Row {
        Kirigami.FormData.label: tr("item.warn")
        visible: sourceIsNumber
        spacing: Kirigami.Units.smallSpacing
        NumberField { key: "warn_below" }
        NumberField { key: "warn_above" }
    }

    Row {
        Kirigami.FormData.label: tr("item.crit")
        visible: sourceIsNumber
        spacing: Kirigami.Units.smallSpacing
        NumberField { key: "crit_below" }
        NumberField { key: "crit_above" }
    }

    TextField {
        Kirigami.FormData.label: tr("item.okStates")
        text: item.ok_states || ''
        placeholderText: sourceIsNumber ? "" : tr("item.okStatesHint")
        visible: !sourceIsNumber
        onTextChanged: item.ok_states = text.trim() || undefined
    }

    CheckBox {
        Kirigami.FormData.label: tr("item.hideWhenOk")
        checked: !!item.hide_when_ok
        onCheckedChanged: item.hide_when_ok = checked || undefined
    }

    component ServiceSelector: CheckableFormControl {
        visible: !!serviceSelector.count
        checked: ~serviceSelector.currentIndex
        property alias service: serviceSelector.currentValue
        property alias initialValue: serviceSelector.initialValue
        property var serviceFilter
        RestorableComboBox {
            id: serviceSelector
            model: serviceFilter ? itemServiceNames.filter(serviceFilter) : itemServiceNames
            onEnabledChanged: if (!enabled) currentIndex = -1
        }
    }

    function assignAction(action, part) {
        item[action] = Object.assign({}, item[action], part)
    }

    ServiceSelector {
        Kirigami.FormData.label: tr("item.click")
        initialValue: item.default_action?.service
        onServiceChanged: assignAction('default_action', { service })
    }

    ServiceSelector {
        Kirigami.FormData.label: tr("item.dclick")
        initialValue: item.dclick_action?.service
        onServiceChanged: assignAction('dclick_action', { service })
    }

    ServiceSelector {
        id: scrollActionSelector
        Kirigami.FormData.label: tr("item.scroll")
        serviceFilter: k => getNumberFields(k).length
        initialValue: item.scroll_action?.service
        onServiceChanged: assignAction('scroll_action', { service })

        RestorableComboBox {
            model: getNumberFields(scrollActionSelector.service).map(e => e.name)
            onCurrentValueChanged: assignAction('scroll_action', { data_field: currentValue })
            initialValue: item.scroll_action?.data_field
            fallbackIndex: 0
        }
    }

    function getNumberFields(serviceName) {
        if (!serviceName) return []
        return services.getService(item.domain, serviceName)
            .filterFields(f => f.isNumber() && f.isApplicableTo(source) && f.hasCorrespondingAttribute(source), true)
    }
}