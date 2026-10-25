import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "."
import "../code/defaults.mjs" as Defaults
import "../code/i18n.mjs" as I18n
import "../code/backup.mjs" as Backup
import "../code/timeago.mjs" as TimeAgo
import "components"

PlasmoidItem {
    id: root
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
    Plasmoid.backgroundHints: PlasmaCore.Types.StandardBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.configurationRequired: !ClientFactory.error && !(url && ha?.token && store.items.length)
    Plasmoid.busy: !ClientFactory.error && !plasmoid.configurationRequired && !store.initialized
    toolTipMainText: ""
    toolTipSubText: connectionLost ? connectionMessage : ""
    
    readonly property string url: plasmoid.configuration.url
    readonly property var look: plasmoid.configuration
    readonly property string lang: I18n.resolve(plasmoid.configuration.language)
    function tr(key, ...args) { return I18n.tr(lang, key, ...args) }
    readonly property color tileFillColor: tileBackgrounds ? Qt.rgba(palette.background.r, palette.background.g, palette.background.b, look.tileOpacity / 100) : "transparent"

    Palette {
        id: palette
        look: root.look
    }
    readonly property alias accentColor: palette.accent
    readonly property alias textColor: palette.text
    readonly property alias mutedColor: palette.muted
    readonly property alias okColor: palette.ok
    readonly property alias warnColor: palette.warn
    readonly property alias critColor: palette.crit
    readonly property alias valueColor: palette.value
    readonly property alias labelColor: palette.label
    readonly property alias labelOpacity: palette.labelOpacity
    readonly property alias graphLineColor: palette.graph
    function levelColor(level, okColor) { return palette.levelColor(level, okColor) }
    readonly property alias secondColor: palette.second
    readonly property alias valueWeight: palette.valueWeight
    function tileValueColor(e) { return palette.tileValue(e) }
    function tileLabelColor(e) { return palette.tileLabel(e) }
    function tileLabelOpacity(e) { return palette.tileLabelOpacity(e) }
    function tileGraphColor(e) { return palette.tileGraph(e) }
    function tileSecondColor(e) { return palette.tileSecond(e) }

    // Home Assistant themes are loaded only when they are the color source
    function loadThemes() {
        if (!palette.useHaTheme || !ha?.ready) return
        ha.getThemes().then(result => palette.haThemes = result, () => {})
    }
    Connections {
        target: palette
        function onUseHaThemeChanged() { root.loadThemes() }
    }
    Connections {
        target: root.ha
        function onReadyChanged() { root.loadThemes() }
    }
    // Transitions follow Plasma's animation speed (0 when animations are off there)
    readonly property int animationDuration: look.animations ? Kirigami.Units.longDuration : 0
    readonly property real tileScale: look.tileScale / 100
    // "5 min ago" texts, refreshed every 30 s; empty when the option is off
    property double now: Date.now()
    Timer {
        interval: 30000
        repeat: true
        running: !!root.look.showLastChanged
        onTriggered: root.now = Date.now()
    }
    function ago(ms) { return look.showLastChanged ? TimeAgo.ago(lang, ms, now) : "" }
    // Label font size; above 100 % the tiles grow with it
    readonly property real labelScale: look.labelScale / 100
    readonly property real labelGrow: Math.max(1, labelScale)
    readonly property real defaultPt: Kirigami.Theme.defaultFont.pointSize * labelScale
    readonly property real smallPt: Kirigami.Theme.smallFont.pointSize * labelScale
    // Own tile style (default): DeskHome draws the tiles itself, so opacity, color, radius
    // and borders apply. Otherwise Plasma's button frames are used (fixed corners).
    readonly property bool tileBackgrounds: look.flat
    property Client ha

    // Connection banner: only after a short grace period, so a normal start or a brief
    // network hiccup does not flash it. A rejected token is reported right away.
    property bool connectionLost: false
    readonly property string connectionMessage: !ha ? ""
        : ha.authFailed ? tr("conn.auth")
        : tr("conn.lost", Qt.formatTime(ha.disconnectedSince || new Date(), "HH:mm"))

    function updateConnection() {
        if (!ha || ha.ready || !ha.configured) {
            connectionLost = false
            lostTimer.stop()
        } else if (ha.authFailed) {
            connectionLost = true
        } else if (!connectionLost && !lostTimer.running) {
            lostTimer.restart()
        }
    }

    Timer {
        id: lostTimer
        interval: 8000
        onTriggered: root.connectionLost = !!root.ha && root.ha.configured && !root.ha.ready
    }

    Connections {
        target: root.ha
        function onReadyChanged() { root.updateConnection() }
        function onAuthFailedChanged() { root.updateConnection() }
        function onConfiguredChanged() { root.updateConnection() }
    }

    onHaChanged: updateConnection()
    onUrlChanged: initClient(url)

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: tr("menu.open", url)
            icon.name: "open-link-symbolic"
            onTriggered: Qt.openUrlExternally(url)
        }
    ]

    Store {
        id: store
        items: Defaults.applyItemDefaults(JSON.parse(plasmoid.configuration.items))
        language: root.lang
    }

    UpdateCheck {
        id: updates
        enabled: plasmoid.configuration.checkUpdates
        current: plasmoid.metaData.version
    }
    readonly property alias updates: updates
    // a closed hint stays closed until an even newer version appears
    readonly property bool updateHintVisible: updates.available && plasmoid.configuration.dismissedUpdate !== updates.latest
    function dismissUpdate() { plasmoid.configuration.dismissedUpdate = updates.latest }

    BatteryWatch {
        id: batteries
        client: root.ha
        threshold: plasmoid.configuration.batteryThreshold
    }
    readonly property alias batteries: batteries

    Notifications {
        id: notifications
    }

    // Changes from the tiles' right-click menu go straight into the tile list
    function tileConfigs() {
        return JSON.parse(plasmoid.configuration.items || "[]")
    }
    function saveTileConfigs(items) {
        // same format as the settings page: empty values are left out
        plasmoid.configuration.items = JSON.stringify(items, (_, value) => value || (value === 0 ? 0 : undefined))
        // keep the automatic backup file current, as the settings dialog does when saving
        if (plasmoid.configuration.autoBackupFile) {
            backupFile.write(plasmoid.configuration.autoBackupFile, Backup.backupData(plasmoid.configuration, JSON.parse(plasmoid.configuration.items)))
        }
    }
    File {
        id: backupFile
    }
    function updateTile(index, changes) {
        const items = tileConfigs()
        if (!items[index]) return
        items[index] = Object.assign({}, items[index], changes)
        saveTileConfigs(items)
    }
    function removeTile(index) {
        const items = tileConfigs()
        if (!items[index]) return
        items.splice(index, 1)
        saveTileConfigs(items)
    }
    function editTile(index) {
        const config = tileConfigs()[index]
        if (!config) return
        const component = Qt.createComponent("TileEditWindow.qml")
        if (component.status === Component.Error) {
            console.warn(component.errorString())
            return
        }
        const window = component.createObject(root, { index, config, ha })
        window.accepted.connect((i, changed) => {
            const items = tileConfigs()
            items[i] = changed
            saveTileConfigs(items)
        })
        window.closing.connect(() => window.destroy())
        window.show()
        window.requestActivate()
    }

    function initClient(url) {
        ha = url ? ClientFactory.getClient(root, url) : null
        store.setClient(ha)
        loadThemes()
    }
}