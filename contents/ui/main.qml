import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "."
import "../code/defaults.mjs" as Defaults
import "../code/i18n.mjs" as I18n

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
    readonly property color tileBaseColor: look.tileCustomColor ? look.tileColor : Kirigami.Theme.backgroundColor
    readonly property color tileFillColor: tileBackgrounds ? Qt.rgba(tileBaseColor.r, tileBaseColor.g, tileBaseColor.b, look.tileOpacity / 100) : "transparent"
    readonly property real tileScale: look.tileScale / 100
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

    Notifications {
        id: notifications
    }

    function initClient(url) {
        ha = url ? ClientFactory.getClient(root, url) : null
        store.setClient(ha)
    }
}