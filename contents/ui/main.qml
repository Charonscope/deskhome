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
    toolTipSubText: ""
    
    readonly property string url: plasmoid.configuration.url
    // Ohne Widget-Hintergrund bekommt jede Kachel einen eigenen, damit nur die Kacheln sichtbar sind
    readonly property var look: plasmoid.configuration
    readonly property string lang: I18n.resolve(plasmoid.configuration.language)
    function tr(key, ...args) { return I18n.tr(lang, key, ...args) }
    readonly property color tileBaseColor: look.tileCustomColor ? look.tileColor : Kirigami.Theme.backgroundColor
    readonly property color tileFillColor: tileBackgrounds ? Qt.rgba(tileBaseColor.r, tileBaseColor.g, tileBaseColor.b, look.tileOpacity / 100) : "transparent"
    readonly property real tileScale: look.tileScale / 100
    // Schriftgröße der Beschriftungen; über 100 % wachsen die Kacheln mit
    readonly property real labelScale: look.labelScale / 100
    readonly property real labelGrow: Math.max(1, labelScale)
    readonly property real defaultPt: Kirigami.Theme.defaultFont.pointSize * labelScale
    readonly property real smallPt: Kirigami.Theme.smallFont.pointSize * labelScale
    readonly property bool tileBackgrounds: !(Plasmoid.effectiveBackgroundHints & (PlasmaCore.Types.StandardBackground | PlasmaCore.Types.TranslucentBackground))
    property Client ha

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