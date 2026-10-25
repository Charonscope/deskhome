import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../code/model.mjs" as Model
import "../code/i18n.mjs" as I18n
import "../code/backup.mjs" as Backup
import "components"
import "."

KCM.ScrollViewKCM {
    id: page
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }
    property string cfg_items
    property alias cfg_autoBackupFile: autoBackupFileField.text
    property int cfg_itemDisplayDefault
    property ListModel items: ListModel { dynamicRoles: true }
    property var services: ({})
    property var entities: ({})
    // { areas, areaOf } from Client.getAreas(); optional, the search also works without
    property var entityAreas: ({ areas: [], areaOf: {} })
    property bool busy: true
    property Client ha
    property string infoMessage
    property bool infoIsError: false

    // Everything that belongs to the appearance and into a full backup
    readonly property var lookKeys: Backup.LOOK_KEYS

    function backupData() {
        return Backup.backupData(plasmoid.configuration, JSON.parse(cfg_items || "[]"))
    }

    // Accepts old .hapi files (tile list only) and full backups
    function restoreBackup(data) {
        const parsed = JSON.parse(data)
        if (Array.isArray(parsed)) {
            setItems(data)
            save()
            infoMessage = tr("items.importedOld", parsed.length)
            return
        }
        // "ha-kacheln" = backups from before the rename
        if (!["deskhome", "ha-kacheln"].includes(parsed?.format) || !Array.isArray(parsed.items)) {
            throw new Error(tr("items.unknownFormat"))
        }
        items.clear()
        setItems(JSON.stringify(parsed.items))
        save()
        for (const k of lookKeys) {
            if (parsed.look && k in parsed.look) plasmoid.configuration[k] = parsed.look[k]
        }
        let urlNote = ""
        if (parsed.url && parsed.url !== plasmoid.configuration.url) {
            plasmoid.configuration.url = parsed.url
            urlNote = tr("items.importedUrl")
        }
        infoMessage = tr("items.imported", new Date(parsed.exported).toLocaleString(Qt.locale(), Locale.ShortFormat), parsed.items.length) + urlNote
    }

    header: ColumnLayout {
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: ha?.errorString
            visible: !!text
            type: Kirigami.MessageType.Error
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: infoMessage
            visible: !!text
            showCloseButton: true
            type: infoIsError ? Kirigami.MessageType.Error : Kirigami.MessageType.Positive
            onVisibleChanged: if (!visible) infoMessage = ""
        }

        RowLayout {
            Layout.maximumWidth: itemList.width - Kirigami.Units.largeSpacing * 2
            Label {
                text: tr("items.displayMode")
                Layout.fillWidth: true
            }
            ConfigItemActionBar {
                actions: [
                    Kirigami.Action {
                        text: page.tr("items.compact")
                        icon.name: "window-minimize-pip"
                        checkable: true
                        checked: cfg_itemDisplayDefault & DisplayFilterModel.Compact
                        onTriggered: setDisplayDefaultAndItems(DisplayFilterModel.Compact, checked)
                    },
                    Kirigami.Action {
                        text: page.tr("items.full")
                        icon.name: "window-restore-pip"
                        checkable: true
                        checked: cfg_itemDisplayDefault & DisplayFilterModel.Full
                        onTriggered: setDisplayDefaultAndItems(DisplayFilterModel.Full, checked)
                    }
                ]
            }
        }
    }

    function setDisplayDefaultAndItems(flag, set) {
        cfg_itemDisplayDefault ^= flag
        for (let i = 0; i < items.count; i++) {
            const display = items.get(i).display
            items.setProperty(i, "display", set ? (display | flag) : (display & ~flag))
        }
        save()
    }

    footer: ColumnLayout {
        RowLayout {
            enabled: !busy
            Button {
                icon.name: 'list-add'
                text: tr("items.add")
                // new tiles start with the chosen default display (panel and/or full view)
                onClicked: openDialog(new Model.ConfigEntity({ display: cfg_itemDisplayDefault || DisplayFilterModel.Full }))
                Layout.fillWidth: true
            }
            Button {
                icon.name: 'view-list-tree'
                text: tr("area.add")
                enabled: !!entityAreas.areas.length
                onClicked: areaDialogComponent.createObject(page).open()
            }
            Button {
                icon.name: 'application-menu'
                down: backupMenu.visible
                onClicked: backupMenu.visible = !backupMenu.visible
            }
        }
            
        ColumnLayout {
            id: backupMenu
            visible: false

            RowLayout {
                Button {
                    icon.name: 'document-import'
                    text: tr("items.import")
                    onClicked: file.open().then(data => {
                        try {
                            infoIsError = false
                            restoreBackup(data)
                        } catch (e) {
                            infoIsError = true
                            infoMessage = tr("items.importFailed", e.message)
                        }
                    })
                    Layout.fillWidth: true
                }
                Button {
                    icon.name: 'document-export'
                    text: tr("items.export")
                    onClicked: file.save(backupData()).then(() => { infoIsError = false; infoMessage = tr("items.exported") })
                    enabled: !!items.count
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Label {
                    text: tr("items.autoBackup")
                }
                Kirigami.ActionTextField {
                    id: autoBackupFileField
                    readOnly: true
                    onPressed: file.select().then(file => cfg_autoBackupFile = file)
                    Layout.fillWidth: true
                    rightActions: [
                        Kirigami.Action {
                            visible: !!cfg_autoBackupFile
                            icon.name: 'edit-clear'
                            onTriggered: cfg_autoBackupFile = null
                        }
                    ]
                }
            }

            File {
                id: file
                defaultSuffix: "hapi"
                nameFilters: [tr("items.fileFilter"), tr("items.allFiles")]
            }
        }
    }

    view: ListView {
        id: itemList
        model: Object.keys(entities).length ? items : []
        delegate: EntityListItem {}
        moveDisplaced: Transition {
            NumberAnimation { properties: "y"; duration: Kirigami.Units.longDuration }
        }

        BusyIndicator {
            anchors.centerIn: parent
            visible: busy
        }
    }

    Component.onCompleted: {
        setItems(cfg_items)
        ha = ClientFactory.getClient(this, plasmoid.configuration.url)
        ha.readyChanged.connect(fetchData)
        // the connection is shared and usually already up when the page opens
        if (ha.ready) fetchData()
    }

    function setItems(data) {
        const rawItems = JSON.parse(data) || []
        rawItems.forEach(item => items.append(new Model.ConfigEntity(item)))
    }

    function fetchData() {
        if (!ha?.ready) return
        return Promise.all([ha.getStates(), ha.getServices()])
            .then(([e, s]) => {
                entities = arrayToObject(e, 'entity_id')
                ha.getAreas().then(a => entityAreas = a, () => {})
                services = s
                busy = false
            }).catch(() => busy = false)
    }

    component EntityListItem: Item { // Wrapper for ListItemDragHandle
        width: ListView.view.width
        implicitHeight: listItem.height
        ItemDelegate {
            id: listItem
            down: false
            width: parent.width
            readonly property var entity: entities[model.entity_id]
            function toggleDisplay(flag) {
                updateItem({ display: model.display ^ flag }, index)
            }
            contentItem: RowLayout {
                Kirigami.ListItemDragHandle {
                    listItem: listItem
                    listView: itemList
                    onMoveRequested: (oldIndex, newIndex) => items.move(oldIndex, newIndex, 1)
                    onDropped: save()
                }
                DynamicIcon {
                    name: model.icon || listItem.entity?.attributes.icon || ''
                    Layout.preferredWidth: parent.height
                    Layout.preferredHeight: parent.height
                }
                Kirigami.TitleSubtitle {
                    title: model.name || listItem.entity?.attributes.friendly_name || page.tr("items.unknown")
                    subtitle: model.entity_id
                    Layout.fillWidth: true
                }
                ConfigItemActionBar {
                    actions: [
                        Kirigami.Action {
                            icon.name: 'edit-entry'
                            onTriggered: openDialog(new Model.ConfigEntity(model), index)
                            text: page.tr("items.edit")
                            visible: listItem.hovered
                        },
                        Kirigami.Action {
                            icon.name: 'delete'
                            onTriggered: removeItem(index)
                            text: page.tr("items.delete")
                            visible: listItem.hovered
                        },
                        Kirigami.Action {
                            text: page.tr("items.compact")
                            icon.name: "window-minimize-pip"
                            checkable: true
                            checked: model.display & DisplayFilterModel.Compact
                            onTriggered: listItem.toggleDisplay(DisplayFilterModel.Compact)
                        },
                        Kirigami.Action {
                            text: page.tr("items.full")
                            icon.name: "window-restore-pip"
                            checkable: true
                            checked: model.display & DisplayFilterModel.Full
                            onTriggered: listItem.toggleDisplay(DisplayFilterModel.Full)
                        }
                    ]
                }
            }
        }
    }

    Component {
        id: dialogComponent
        Kirigami.Dialog {
            id: dialog
            property int index
            property var item
            signal itemAccepted(int index, var item)
            readonly property bool acceptable: !!itemForm.item?.entity_id
            padding: Kirigami.Units.largeSpacing
            standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
            onRejected: close()
            onAccepted: itemAccepted(index, item) || close()
            Component.onCompleted: standardButton(Kirigami.Dialog.Ok).enabled = Qt.binding(() => acceptable)

            ConfigItem {
                id: itemForm
                item: dialog.item
            }
        }
    }

    // Adds the tiles of a whole area at once; tiles that already exist are not added twice
    Component {
        id: areaDialogComponent
        Kirigami.Dialog {
            id: areaDialog
            title: page.tr("area.title")
            padding: Kirigami.Units.largeSpacing
            preferredWidth: Kirigami.Units.gridUnit * 28
            preferredHeight: Kirigami.Units.gridUnit * 26
            standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
            onClosed: destroy()

            readonly property var supported: ["sensor", "binary_sensor", "light", "switch", "fan", "climate", "input_boolean", "cover", "number", "input_number", "counter"]
            readonly property var existing: {
                const ids = new Set()
                for (let i = 0; i < items.count; i++) ids.add(items.get(i).entity_id)
                return ids
            }
            property var area: entityAreas.areas[0] || null
            readonly property var candidates: (area?.entities || []).filter(id => supported.includes(id.split(".")[0]) && !!entities[id])
            // entity_id -> checked
            property var chosen: ({})
            onCandidatesChanged: {
                const c = {}
                for (const id of candidates) c[id] = !existing.has(id)
                chosen = c
            }
            readonly property int chosenCount: candidates.filter(id => chosen[id]).length

            Component.onCompleted: standardButton(Kirigami.Dialog.Ok).enabled = Qt.binding(() => chosenCount > 0)
            onAccepted: {
                for (const id of candidates) {
                    if (chosen[id]) items.append(new Model.ConfigEntity({ entity_id: id, display: cfg_itemDisplayDefault || DisplayFilterModel.Full }))
                }
                save()
                infoIsError = false
                infoMessage = page.tr("area.added", chosenCount, area.name)
            }

            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                ComboBox {
                    Layout.fillWidth: true
                    model: entityAreas.areas.map(a => `${a.name} (${a.entities.filter(id => areaDialog.supported.includes(id.split(".")[0]) && !!entities[id]).length})`)
                    onActivated: index => areaDialog.area = entityAreas.areas[index]
                }
                Label {
                    visible: !areaDialog.candidates.length
                    text: page.tr("area.empty")
                    opacity: 0.7
                }
                Repeater {
                    model: areaDialog.candidates
                    delegate: CheckBox {
                        readonly property var entity: entities[modelData]
                        Layout.fillWidth: true
                        checked: !!areaDialog.chosen[modelData]
                        text: (entity?.attributes?.friendly_name || modelData)
                            + (areaDialog.existing.has(modelData) ? "  " + page.tr("area.exists") : "")
                        onToggled: {
                            const c = Object.assign({}, areaDialog.chosen)
                            c[modelData] = checked
                            areaDialog.chosen = c
                        }
                    }
                }
            }
        }
    }

    function openDialog(data, index = -1) {
        const dialog = dialogComponent.createObject(parent, { 
            index: index,
            item: data,
            title: data.name || data.entity_id || tr("items.new")
        })
        dialog.open()
        dialog.onItemAccepted.connect((index, item) => {
            if (~index) {
                return updateItem(item, index)
            }
            return addItem(item)
        })
        dialog.closed.connect(dialog.destroy)
    }

    function save() {
        const array = []
        for (let i = 0; i < items.count; i++) {
            array.push(items.get(i))
        }
        cfg_items = JSON.stringify(array, (_, value) => value || (value === 0 ? 0 : undefined))
    }

    function removeItem(index) {
        if (index >= items.length || index < 0) return
        items.remove(index)
        save()
    }

    function addItem(item) {
        items.append(item)
        save()
    }

    function updateItem(item, index) {
        if (index >= items.length || index < 0) return
        items.set(index, item)
        save()
    }

    function arrayToObject(array, key) {
        return array.reduce((o, e) => (o[e[key]] = e,o), {})
    }

    function saveConfig() {
        if (cfg_autoBackupFile) {
            file.write(cfg_autoBackupFile, backupData())
        }
    }
}