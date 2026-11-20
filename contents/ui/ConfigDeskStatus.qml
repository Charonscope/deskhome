import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../code/deskstatus.mjs" as DS
import "../code/i18n.mjs" as I18n

import "components"

// Desk Status (beta): this computer reports its state to Home Assistant and can switch
// things itself ("quick rules"). The work is done by DeskStatus.qml inside the widget;
// this page only edits the settings and explains a lot, since it is new for most users.
KCM.SimpleKCM {
    id: page
    property alias cfg_deskStatusEnabled: enabledBox.checked
    property alias cfg_deskStatusDeviceName: deviceName.text
    property int cfg_deskStatusInterval
    property string cfg_deskStatusSensors
    property string cfg_deskStatusRules

    signal configurationChanged
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    // ---- data from Home Assistant for the entity suggestions -------------------------------
    property var ha
    property var entities: ({})
    Component.onCompleted: {
        ha = ClientFactory.getClient(this, plasmoid.configuration.url)
        if (!ha) return
        ha.readyChanged.connect(fetchEntities)
        if (ha.ready) fetchEntities()
    }
    function fetchEntities() {
        if (!ha?.ready) return
        ha.getStates().then(list => {
            const map = {}
            for (const e of list) map[e.entity_id] = e
            entities = map
        }, () => {})
    }
    function choices(domains) {
        return Object.keys(entities).filter(id => domains.includes(id.split(".")[0])).sort().map(id => ({
            value: id,
            title: entities[id].attributes?.friendly_name || id,
            subtitle: id
        }))
    }
    readonly property var targetDomains: ["light", "switch", "fan", "input_boolean", "scene", "script"]
    readonly property var conditionDomains: ["sensor", "number", "input_number"]

    // ---- sensors ---------------------------------------------------------------------------
    readonly property var sensorList: cfg_deskStatusSensors.split(",").filter(k => !!k)
    function setSensor(key, on) {
        const list = sensorList.filter(k => k !== key)
        if (on) list.push(key)
        cfg_deskStatusSensors = DS.SENSORS.map(s => s.key).filter(k => list.includes(k)).join(",")
    }

    // ---- rules -----------------------------------------------------------------------------
    readonly property var rules: DS.parseRules(cfg_deskStatusRules)
    function saveRules(list) { cfg_deskStatusRules = JSON.stringify(list) }
    function setRule(index, changes) {
        const list = rules.slice()
        list[index] = Object.assign({}, list[index], changes)
        saveRules(list)
    }
    function addRule() {
        saveRules(rules.concat([{ enabled: true, trigger: "unlock", entity: "", action: "on", brightness: 0, condEntity: "", condOp: "below", condValue: 15 }]))
    }
    function removeRule(index) {
        const list = rules.slice()
        list.splice(index, 1)
        saveRules(list)
    }

    // status written by the widget (last success or error)
    readonly property var info: { try { return JSON.parse(plasmoid.configuration.deskStatusInfo || "{}") } catch (e) { return {} } }

    Kirigami.FormLayout {

        Kirigami.InlineMessage {
            Kirigami.FormData.isSection: true
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Information
            text: tr("desk.beta")
        }

        Label {
            text: tr("desk.intro")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        // ---- part 1: report to Home Assistant ----------------------------------------------
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("desk.reportTitle")
        }

        Label {
            text: tr("desk.reportIntro")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        HelpRow {
            help: tr("desk.enabledHelp")
            CheckBox {
                id: enabledBox
                text: tr("desk.enabled")
            }
        }

        HelpRow {
            Kirigami.FormData.label: tr("desk.deviceName")
            help: tr("desk.deviceNameHelp")
            enabled: enabledBox.checked
            TextField {
                id: deviceName
                placeholderText: tr("desk.deviceNamePlaceholder")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
            }
        }

        HelpRow {
            Kirigami.FormData.label: tr("desk.interval")
            help: tr("desk.intervalHelp")
            enabled: enabledBox.checked
            ComboBox {
                textRole: "text"
                valueRole: "value"
                model: [5, 10, 15, 30, 60].map(s => ({ value: s, text: tr("desk.seconds", s) }))
                Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_deskStatusInterval))
                onActivated: cfg_deskStatusInterval = currentValue
            }
        }

        Repeater {
            model: DS.SENSORS
            delegate: HelpRow {
                required property var modelData
                required property int index
                Kirigami.FormData.label: index === 0 ? tr("desk.sensors") : ""
                help: tr(["desk.sensorHelp", modelData.key].join("."))
                enabled: enabledBox.checked
                CheckBox {
                    text: tr(["desk.sensor", modelData.key].join("."))
                    checked: page.sensorList.includes(modelData.key)
                    onToggled: page.setSensor(modelData.key, checked)
                }
            }
        }

        Label {
            Kirigami.FormData.label: tr("desk.state")
            visible: enabledBox.checked
            text: !plasmoid.configuration.deskStatusEnabled ? tr("desk.stateApply")
                : page.info.state === "ok" ? tr("desk.stateOk", page.info.device || "")
                : page.info.state === "error" ? tr("desk.stateError", page.info.text || "")
                : tr("desk.stateWaiting")
            color: page.info.state === "error" ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        // ---- part 2: quick rules -----------------------------------------------------------
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("desk.rulesTitle")
        }

        Label {
            text: tr("desk.rulesIntro")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        Repeater {
            model: page.rules
            delegate: Frame {
                id: ruleFrame
                required property var modelData
                required property int index
                readonly property var rule: modelData
                readonly property bool isLight: rule.entity.startsWith("light.")
                readonly property bool startsOnly: rule.entity.startsWith("scene.") || rule.entity.startsWith("script.")
                Layout.fillWidth: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 32

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: Kirigami.Units.smallSpacing
                    rowSpacing: Kirigami.Units.smallSpacing

                    RowLayout {
                        Layout.columnSpan: 2
                        CheckBox {
                            text: tr("desk.ruleN", ruleFrame.index + 1)
                            font.bold: true
                            checked: ruleFrame.rule.enabled
                            onToggled: page.setRule(ruleFrame.index, { enabled: checked })
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            icon.name: "edit-delete-remove"
                            text: tr("desk.ruleRemove")
                            onClicked: page.removeRule(ruleFrame.index)
                        }
                    }

                    Label { text: tr("desk.when") }
                    ComboBox {
                        Layout.fillWidth: true
                        textRole: "text"
                        valueRole: "value"
                        model: DS.TRIGGERS.map(t => ({ value: t, text: tr(["desk.trigger", t].join(".")) }))
                        Component.onCompleted: currentIndex = Math.max(0, indexOfValue(ruleFrame.rule.trigger))
                        onActivated: page.setRule(ruleFrame.index, { trigger: currentValue })
                    }

                    Label { text: tr("desk.then") }
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            Layout.fillWidth: true
                            text: ruleFrame.rule.entity
                            placeholderText: tr("desk.entityPlaceholder")
                            onEditingFinished: if (text !== ruleFrame.rule.entity) page.setRule(ruleFrame.index, { entity: text.trim() })
                            Autocompletion {
                                model: page.choices(page.targetDomains)
                            }
                        }
                        ComboBox {
                            visible: !ruleFrame.startsOnly
                            textRole: "text"
                            valueRole: "value"
                            model: [{ value: "on", text: tr("desk.actionOn") }, { value: "off", text: tr("desk.actionOff") }]
                            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(ruleFrame.rule.action))
                            onActivated: page.setRule(ruleFrame.index, { action: currentValue })
                        }
                        Label {
                            visible: ruleFrame.startsOnly
                            text: tr("desk.actionStart")
                        }
                    }

                    Label {
                        visible: ruleFrame.isLight && ruleFrame.rule.action === "on"
                        text: tr("desk.brightness")
                    }
                    RowLayout {
                        visible: ruleFrame.isLight && ruleFrame.rule.action === "on"
                        SpinBox {
                            from: 0
                            to: 100
                            stepSize: 5
                            value: ruleFrame.rule.brightness
                            textFromValue: v => v ? v + " %" : tr("desk.brightnessKeep")
                            valueFromText: t => parseInt(t) || 0
                            onValueModified: page.setRule(ruleFrame.index, { brightness: value })
                        }
                        Kirigami.ContextualHelpButton {
                            toolTipText: tr("desk.brightnessHelp")
                        }
                    }

                    Label { text: tr("desk.onlyIf") }
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            Layout.fillWidth: true
                            text: ruleFrame.rule.condEntity
                            placeholderText: tr("desk.condPlaceholder")
                            onEditingFinished: if (text !== ruleFrame.rule.condEntity) page.setRule(ruleFrame.index, { condEntity: text.trim() })
                            Autocompletion {
                                model: page.choices(page.conditionDomains)
                            }
                        }
                        ComboBox {
                            enabled: !!ruleFrame.rule.condEntity
                            textRole: "text"
                            valueRole: "value"
                            model: [{ value: "below", text: tr("desk.below") }, { value: "above", text: tr("desk.above") }]
                            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(ruleFrame.rule.condOp))
                            onActivated: page.setRule(ruleFrame.index, { condOp: currentValue })
                        }
                        TextField {
                            enabled: !!ruleFrame.rule.condEntity
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                            text: String(ruleFrame.rule.condValue)
                            validator: DoubleValidator {}
                            onEditingFinished: page.setRule(ruleFrame.index, { condValue: parseFloat(text.replace(",", ".")) || 0 })
                        }
                        Label {
                            enabled: !!ruleFrame.rule.condEntity
                            text: page.entities[ruleFrame.rule.condEntity]?.attributes?.unit_of_measurement || ""
                        }
                    }

                    // what the rule does, in one sentence
                    Label {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        opacity: 0.7
                        text: ruleFrame.rule.entity ? page.describe(ruleFrame.rule) : tr("desk.ruleIncomplete")
                    }
                }
            }
        }

        Button {
            icon.name: "list-add"
            text: tr("desk.ruleAdd")
            onClicked: page.addRule()
        }

        // ---- part 3: how to use it ---------------------------------------------------------
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("desk.howTitle")
        }

        Label {
            text: tr("desk.how")
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }
    }

    function name(id) { return entities[id]?.attributes?.friendly_name || id }
    function describe(rule) {
        const what = rule.entity.startsWith("scene.") || rule.entity.startsWith("script.")
            ? tr("desk.descStart", name(rule.entity))
            : rule.action === "off" ? tr("desk.descOff", name(rule.entity))
            : rule.brightness > 0 && rule.entity.startsWith("light.") ? tr("desk.descOnBrightness", name(rule.entity), rule.brightness)
            : tr("desk.descOn", name(rule.entity))
        const cond = rule.condEntity
            ? tr(rule.condOp === "above" ? "desk.descAbove" : "desk.descBelow", name(rule.condEntity), rule.condValue + (entities[rule.condEntity]?.attributes?.unit_of_measurement ? " " + entities[rule.condEntity].attributes.unit_of_measurement : ""))
            : ""
        return tr("desk.desc", tr(["desk.trigger", rule.trigger].join(".")), what, cond)
    }
}
