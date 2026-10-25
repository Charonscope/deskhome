import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami

import "../code/model.mjs" as Model
import "../code/i18n.mjs" as I18n

// Edits one tile in its own window, opened from the tile's right-click menu.
// Uses the same form as the settings page (ConfigItem).
Window {
    id: window
    property int index: -1
    property var config: ({})
    property Client ha
    signal accepted(int index, var config)

    // looked up by ConfigItem
    property var entities: ({})
    property var entityAreas: ({ areas: [], areaOf: {} })
    property var services: ({ getNames: () => [], getService: () => null })
    property bool loading: true
    // for the tests: height of the form inside the scroll area
    readonly property real formHeight: scroll.contentHeight

    readonly property var item: new Model.ConfigEntity(config)
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    title: tr("menu.editTitle", config.name || config.entity_id || "")
    width: Kirigami.Units.gridUnit * 34
    height: Kirigami.Units.gridUnit * 32
    minimumWidth: Kirigami.Units.gridUnit * 24
    minimumHeight: Kirigami.Units.gridUnit * 16
    color: Kirigami.Theme.backgroundColor
    flags: Qt.Dialog

    Component.onCompleted: {
        if (!ha?.ready) {
            loading = false
            return
        }
        Promise.all([ha.getStates(), ha.getServices()]).then(([states, s]) => {
            const byId = {}
            for (const e of states) byId[e.entity_id] = e
            entities = byId
            ha.getAreas().then(a => entityAreas = a, () => {})
            services = s
            loading = false
        }, () => loading = false)
    }

    Shortcut {
        sequences: [StandardKey.Cancel]
        onActivated: window.close()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: !window.loading && !window.ha?.ready
            type: Kirigami.MessageType.Warning
            text: window.tr("menu.editOffline")
        }

        // the content size is set explicitly: with more than one child the ScrollView cannot
        // determine it and then does not scroll at all (the form was cut off at the bottom)
        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            contentHeight: form.implicitHeight
            Loader {
                id: form
                width: scroll.availableWidth
                active: !window.loading
                sourceComponent: ConfigItem {
                    item: window.item
                }
            }

            BusyIndicator {
                parent: scroll
                anchors.centerIn: parent
                visible: window.loading
            }
        }

        DialogButtonBox {
            Layout.fillWidth: true
            standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
            onAccepted: {
                if (!window.item.entity_id) return
                // plain object with the enumerable fields, like the settings page stores it
                window.accepted(window.index, JSON.parse(JSON.stringify(window.item)))
                window.close()
            }
            onRejected: window.close()
        }
    }
}
