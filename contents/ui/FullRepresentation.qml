import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents3

import org.kde.kirigami as Kirigami

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

            GridLayout {
                id: tileGrid
                readonly property int minTileWidth: Kirigami.Units.gridUnit * 9 * root.tileScale * (1 + (root.labelGrow - 1) * 0.5)
                readonly property int tileHeight: Kirigami.Units.gridUnit * 4 * root.tileScale * (1 + (root.labelGrow - 1) * 0.6)
                readonly property int compactTileHeight: Kirigami.Units.gridUnit * 2.5 * root.tileScale * root.labelGrow
                width: scroll.availableWidth
                // Every normal tile takes two grid columns so half tiles are possible
                readonly property int tileColumns: Math.max(1, Math.floor((width + columnSpacing) / (minTileWidth + columnSpacing)))
                columns: tileColumns * 2
                // Compute widths ourselves: with fillWidth GridLayout distributes mixed spans unevenly
                readonly property real cellWidth: (width - (columns - 1) * columnSpacing) / columns
                function spanWidth(span) {
                    const s = Math.min(span, columns)
                    return s * cellWidth + (s - 1) * columnSpacing
                }
                columnSpacing: root.look.tileSpacing
                rowSpacing: root.look.tileSpacing
                // widths are set exactly per tile (spanWidth); uniformCellWidths would stretch columns
                uniformCellWidths: false

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
                Connections {
                    target: store.itemModel
                    function onDataChanged() { tileGrid.recountHidden() }
                    function onCountChanged() { tileGrid.recountHidden() }
                }
                Component.onCompleted: {
                    recountHidden()
                    place()
                }

                // Assign positions ourselves: GridLayout misplaces tiles with different
                // spans when they are added at runtime (tiles overlap)
                property var positions: []
                property var okPosition: ({ row: 0, column: 0 })
                function spanOf(row) {
                    const source = visibleTiles.mapToSource(visibleTiles.index(row, 0)).row
                    const colspan = store.itemModel.get(source)?.colspan || 1
                    return Math.min(Math.round(colspan * 2), columns)
                }
                function place() {
                    const result = []
                    let r = 0, c = 0
                    const put = span => {
                        if (c + span > columns) { r++; c = 0 }
                        const p = { row: r, column: c }
                        c += span
                        return p
                    }
                    for (let i = 0; i < visibleTiles.count; i++) result.push(put(spanOf(i)))
                    okPosition = put(Math.min(2, columns))
                    positions = result
                }
                onColumnsChanged: Qt.callLater(place)
                Connections {
                    target: visibleTiles
                    function onRowsInserted() { Qt.callLater(tileGrid.place) }
                    function onRowsRemoved() { Qt.callLater(tileGrid.place) }
                    function onModelReset() { Qt.callLater(tileGrid.place) }
                    function onLayoutChanged() { Qt.callLater(tileGrid.place) }
                    function onDataChanged() { Qt.callLater(tileGrid.place) }
                }

                Repeater {
                    model: DisplayFilterModel {
                        id: visibleTiles
                        sourceModel: store.itemModel
                        filterItems: DisplayFilterModel.Full
                    }
                    delegate: EntityWrapper {
                        id: wrapper
                        flat: plasmoid.configuration.flat
                        showBackground: true
                        // full name as a tooltip in case it is shortened in the tile
                        tooltipTitle: model.name
                        readonly property int span: Math.min(Math.round((model.colspan || 1) * 2), tileGrid.columns)
                        Layout.preferredWidth: tileGrid.spanWidth(span)
                        Layout.minimumWidth: tileGrid.spanWidth(span)
                        Layout.maximumWidth: tileGrid.spanWidth(span)
                        // only sensors with a graph need the full height
                        Layout.preferredHeight: model.kind === "sensor" && model.history_hours > 0 ? tileGrid.tileHeight : tileGrid.compactTileHeight
                        Layout.columnSpan: span
                        Layout.row: tileGrid.positions[index]?.row ?? 0
                        Layout.column: tileGrid.positions[index]?.column ?? 0

                        Loader {
                            anchors.fill: parent
                            source: {
                                switch (model.kind) {
                                    case "sensor": return "tiles/SensorTile.qml"
                                    case "switch": return "tiles/SwitchTile.qml"
                                    case "status": return "tiles/StatusTile.qml"
                                }
                                return "EntityDelegateTile.qml"
                            }
                        }
                    }
                }

                Rectangle {
                    visible: tileGrid.hiddenOkCount > 0
                    radius: root.look.tileRadius
                    color: root.tileBackgrounds
                        ? root.tileFillColor
                        : Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                    Layout.preferredWidth: tileGrid.spanWidth(2)
                    Layout.minimumWidth: tileGrid.spanWidth(2)
                    Layout.maximumWidth: tileGrid.spanWidth(2)
                    Layout.preferredHeight: tileGrid.compactTileHeight
                    Layout.columnSpan: Math.min(2, tileGrid.columns)
                    Layout.row: tileGrid.okPosition.row
                    Layout.column: tileGrid.okPosition.column
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        Kirigami.Icon {
                            source: "checkmark"
                            color: Kirigami.Theme.positiveTextColor
                            isMask: true
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        }
                        PlasmaComponents3.Label {
                            text: tileGrid.hiddenOkCount === 1 ? root.tr("ok.one") : root.tr("ok.many", tileGrid.hiddenOkCount)
                            font.pointSize: root.defaultPt
                            color: Kirigami.Theme.positiveTextColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
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
