import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents3

import org.kde.kirigami as Kirigami

import QtQuick.Dialogs

import "components"

PlasmaExtras.Representation {
    // Shown only while the connection is lost; the tiles are dimmed because their values are stale
    Kirigami.InlineMessage {
        id: connectionBanner
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        visible: root.connectionLost
        type: ha?.authFailed ? Kirigami.MessageType.Error : Kirigami.MessageType.Warning
        text: root.connectionMessage
    }

    Loader {
        id: gridLoader
        sourceComponent: gridComponent
        active: store.initialized && root.expanded
        anchors {
            top: connectionBanner.visible ? connectionBanner.bottom : parent.top
            topMargin: connectionBanner.visible ? Kirigami.Units.smallSpacing : 0
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        opacity: root.connectionLost ? 0.45 : 1
        Behavior on opacity {
            NumberAnimation { duration: Kirigami.Units.longDuration }
        }
    }

    Layout.preferredWidth: Kirigami.Units.gridUnit * 24
    Layout.preferredHeight: Kirigami.Units.gridUnit * 14
    Layout.minimumWidth: Kirigami.Units.gridUnit * 8
    Layout.minimumHeight: Kirigami.Units.gridUnit * 4

    Component {
        id: gridComponent
        ScrollView {
            id: scroll
            // fixed implicit size, otherwise a binding loop via the column count
            implicitWidth: Kirigami.Units.gridUnit * 24
            implicitHeight: Kirigami.Units.gridUnit * 14
            contentWidth: availableWidth
            contentHeight: tileGrid.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            // Tiles are positioned by hand instead of with a GridLayout: GridLayout refuses
            // tiles that arrive at runtime on an occupied cell and then sometimes never lays
            // them out (tiles went missing), and it distributes mixed spans unevenly.
            Item {
                id: tileGrid
                readonly property int minTileWidth: Kirigami.Units.gridUnit * 9 * root.tileScale * (1 + (root.labelGrow - 1) * 0.5)
                readonly property int tileHeight: Kirigami.Units.gridUnit * 4 * root.tileScale * (1 + (root.labelGrow - 1) * 0.6)
                readonly property int compactTileHeight: Kirigami.Units.gridUnit * 2.5 * root.tileScale * root.labelGrow
                readonly property int spacing: root.look.tileSpacing
                width: scroll.availableWidth
                implicitHeight: contentHeight
                // Every normal tile takes two columns so half tiles are possible
                readonly property int tileColumns: Math.max(1, Math.floor((width + spacing) / (minTileWidth + spacing)))
                readonly property int columns: tileColumns * 2
                readonly property real cellWidth: (width - (columns - 1) * spacing) / columns
                function spanWidth(span) {
                    const s = Math.min(span, columns)
                    return s * cellWidth + (s - 1) * spacing
                }

                // How many "only when abnormal" tiles are currently ok (and therefore hidden)
                property int hiddenOkCount: 0
                function recountHidden() {
                    let n = 0
                    for (let i = 0; i < store.itemModel.count; i++) {
                        const e = store.itemModel.get(i)
                        if (e.hide_when_ok && e.level === 0 && (e.display & DisplayFilterModel.Full)) n++
                    }
                    hiddenOkCount = n
                }

                // Geometry of every visible tile ({x, y, width, height}) plus the summary tile
                property var positions: []
                property var okPosition: ({ x: 0, y: 0, width: 0, height: 0 })
                property real contentHeight: 0

                function entryOf(row) {
                    return store.itemModel.get(visibleTiles.mapToSource(visibleTiles.index(row, 0)).row) || {}
                }

                function place() {
                    const result = []
                    let column = 0, y = 0, rowHeight = 0
                    const put = (span, height) => {
                        if (column + span > columns) {
                            y += rowHeight + spacing
                            column = 0
                            rowHeight = 0
                        }
                        const p = { x: column * (cellWidth + spacing), y: y, width: spanWidth(span), height: height }
                        column += span
                        rowHeight = Math.max(rowHeight, height)
                        return p
                    }
                    for (let i = 0; i < visibleTiles.count; i++) {
                        const e = entryOf(i)
                        const span = Math.min(Math.round((e.colspan || 1) * 2), columns)
                        // only sensors with a graph need the full height
                        const height = (e.kind === "sensor" || e.kind === "combo") && e.history_hours > 0 || e.kind === "thermostat" ? tileHeight : compactTileHeight
                        result.push(put(span, height))
                    }
                    if (hiddenOkCount > 0) okPosition = put(Math.min(2, columns), compactTileHeight)
                    positions = result
                    contentHeight = column === 0 && rowHeight === 0 ? 0 : y + rowHeight
                }

                function schedulePlace() { Qt.callLater(place) }
                onWidthChanged: schedulePlace()
                onTileHeightChanged: schedulePlace()
                onCompactTileHeightChanged: schedulePlace()
                onSpacingChanged: schedulePlace()
                onHiddenOkCountChanged: schedulePlace()
                Component.onCompleted: {
                    recountHidden()
                    place()
                }

                Connections {
                    target: store.itemModel
                    function onDataChanged() { tileGrid.recountHidden() }
                    function onCountChanged() { tileGrid.recountHidden() }
                }
                Connections {
                    target: visibleTiles
                    function onRowsInserted() { tileGrid.schedulePlace() }
                    function onRowsRemoved() { tileGrid.schedulePlace() }
                    function onModelReset() { tileGrid.schedulePlace() }
                    function onLayoutChanged() { tileGrid.schedulePlace() }
                    function onDataChanged() { tileGrid.schedulePlace() }
                }

                Repeater {
                    model: DisplayFilterModel {
                        id: visibleTiles
                        sourceModel: store.itemModel
                        filterItems: DisplayFilterModel.Full
                    }
                    delegate: EntityWrapper {
                        id: wrapper
                        sourceIndex: visibleTiles.mapToSource(visibleTiles.index(index, 0)).row
                        onContextMenuRequested: (x, y) => tileMenu.openFor(wrapper, sourceIndex, model.entity_id, model.name, model.colspan, x, y)
                        readonly property var geometry: tileGrid.positions[index]
                        visible: !!geometry
                        x: geometry?.x ?? 0
                        y: geometry?.y ?? 0
                        width: geometry?.width ?? 0
                        height: geometry?.height ?? 0
                        // fade in when shown; slide when other tiles come or go (not on the first placement)
                        opacity: geometry ? 1 : 0
                        property bool placed: false
                        onGeometryChanged: if (geometry && !placed) Qt.callLater(() => placed = true)
                        Behavior on opacity {
                            enabled: root.animationDuration > 0
                            NumberAnimation { duration: root.animationDuration }
                        }
                        Behavior on x {
                            enabled: wrapper.placed && root.animationDuration > 0
                            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                        }
                        Behavior on y {
                            enabled: wrapper.placed && root.animationDuration > 0
                            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                        }
                        flat: plasmoid.configuration.flat
                        showBackground: true
                        // full name as a tooltip in case it is shortened in the tile
                        tooltipTitle: model.name

                        Loader {
                            anchors.fill: parent
                            source: {
                                switch (model.kind) {
                                    case "sensor": return "tiles/SensorTile.qml"
                                    case "combo": return "tiles/ComboTile.qml"
                                    case "switch": return "tiles/SwitchTile.qml"
                                    case "status": return "tiles/StatusTile.qml"
                                    case "thermostat": return "tiles/ThermostatTile.qml"
                                }
                                return "EntityDelegateTile.qml"
                            }
                        }
                    }
                }

                Rectangle {
                    visible: opacity > 0
                    opacity: tileGrid.hiddenOkCount > 0 ? 1 : 0
                    Behavior on opacity {
                        enabled: root.animationDuration > 0
                        NumberAnimation { duration: root.animationDuration }
                    }
                    x: tileGrid.okPosition.x
                    y: tileGrid.okPosition.y
                    width: tileGrid.okPosition.width
                    height: tileGrid.okPosition.height
                    radius: root.look.tileRadius
                    color: root.tileBackgrounds
                        ? root.tileFillColor
                        : Qt.rgba(root.okColor.r, root.okColor.g, root.okColor.b, 0.12)
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        Kirigami.Icon {
                            source: "checkmark"
                            color: root.okColor
                            isMask: true
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        }
                        PlasmaComponents3.Label {
                            text: tileGrid.hiddenOkCount === 1 ? root.tr("ok.one") : root.tr("ok.many", tileGrid.hiddenOkCount)
                            font.pointSize: root.defaultPt
                            color: root.okColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    // Right-click menu of a tile; created when first needed (it is a native menu)
    QtObject {
        id: tileMenu
        property var menu: null
        function openFor(visualParent, index, entityId, name, colspan, x, y) {
            if (!menu) menu = tileMenuComponent.createObject(tileMenu)
            menu.index = index
            menu.entityId = entityId
            menu.name = name
            menu.colspan = colspan
            menu.visualParent = visualParent
            menu.open(x, y)
        }
    }

    Component {
        id: tileMenuComponent
        PlasmaExtras.Menu {
            id: menu
            property int index: -1
            property string entityId
            property string name
            property real colspan: 1
            // locked widgets (Plasma "Lock widgets") cannot be changed
            readonly property bool editable: !plasmoid.immutable

            PlasmaExtras.MenuItem {
                text: root.tr("menu.edit")
                icon: "document-edit"
                enabled: menu.editable
                onClicked: root.editTile(menu.index)
            }
            PlasmaExtras.MenuItem {
                text: root.tr("menu.width")
                section: true
            }
            PlasmaExtras.MenuItem {
                text: root.tr("item.widthHalf")
                checkable: true
                checked: menu.colspan === 0.5
                enabled: menu.editable
                onClicked: root.updateTile(menu.index, { colspan: 0.5 })
            }
            PlasmaExtras.MenuItem {
                text: root.tr("menu.width1")
                checkable: true
                checked: menu.colspan === 1
                enabled: menu.editable
                onClicked: root.updateTile(menu.index, { colspan: undefined })
            }
            PlasmaExtras.MenuItem {
                text: root.tr("menu.width2")
                checkable: true
                checked: menu.colspan === 2
                enabled: menu.editable
                onClicked: root.updateTile(menu.index, { colspan: 2 })
            }
            PlasmaExtras.MenuItem {
                separator: true
            }
            PlasmaExtras.MenuItem {
                text: root.tr("menu.history")
                icon: "view-history"
                enabled: !!root.url
                onClicked: Qt.openUrlExternally(`${root.url}/history?entity_id=${encodeURIComponent(menu.entityId)}`)
            }
            PlasmaExtras.MenuItem {
                text: root.tr("menu.remove")
                icon: "edit-delete"
                enabled: menu.editable
                onClicked: {
                    removeDialog.index = menu.index
                    removeDialog.text = root.tr("menu.removeQuestion", menu.name || menu.entityId)
                    removeDialog.open()
                }
            }
            PlasmaExtras.MenuItem {
                separator: true
            }
            PlasmaExtras.MenuItem {
                text: root.tr("menu.configure")
                icon: "configure"
                enabled: menu.editable
                onClicked: plasmoid.internalAction("configure").trigger()
            }
        }
    }

    MessageDialog {
        id: removeDialog
        property int index: -1
        title: root.tr("menu.removeTitle")
        buttons: MessageDialog.Yes | MessageDialog.No
        onButtonClicked: (button, role) => {
            if (button === MessageDialog.Yes) root.removeTile(index)
        }
    }

    Loader {
        width: parent.width
        anchors.centerIn: parent
        active: ClientFactory.error
        sourceComponent: PlasmaExtras.PlaceholderMessage {
            text: root.tr("error.ws")
            explanation: ClientFactory.errorString().split(/\d+:\s+/)?.[1]
            iconName: "error"
            helpfulAction: Action {
                icon.name: "link"
                text: root.tr("error.requirements")
                onTriggered: Qt.openUrlExternally(`${plasmoid.metaData.website}/tree/v${plasmoid.metaData.version}#requirements`)
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        active: plasmoid.configurationRequired
            && (plasmoid.formFactor === PlasmaCore.Types.Vertical
            || plasmoid.formFactor === PlasmaCore.Types.Horizontal)
        sourceComponent: PlasmaComponents3.Button {
            icon.name: "configure"
            text: root.tr("configure")
            onClicked: plasmoid.internalAction("configure").trigger()
        }
    }
}
