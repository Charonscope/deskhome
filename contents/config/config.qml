import QtQuick
import org.kde.plasma.configuration

import "../code/i18n.mjs" as I18n

ConfigModel {
    ConfigCategory {
        name: I18n.tr(plasmoid?.configuration?.language, "cat.general")
        icon: "preferences-desktop-plasma"
        source: "ConfigGeneral.qml"
    }
    ConfigCategory {
        name: I18n.tr(plasmoid?.configuration?.language, "cat.items")
        icon: "view-list-details"
        source: "ConfigItems.qml"
        visible: !!plasmoid?.configuration?.url
    }
    ConfigCategory {
        name: I18n.tr(plasmoid?.configuration?.language, "cat.watch")
        icon: "dialog-warning"
        source: "ConfigWatch.qml"
        visible: !!plasmoid?.configuration?.url
    }
    ConfigCategory {
        name: I18n.tr(plasmoid?.configuration?.language, "cat.look")
        icon: "preferences-desktop-theme"
        source: "ConfigLook.qml"
    }
    ConfigCategory {
        name: I18n.tr(plasmoid?.configuration?.language, "cat.colors")
        icon: "color-management"
        source: "ConfigColors.qml"
    }
    ConfigCategory {
        name: I18n.tr(plasmoid?.configuration?.language, "cat.values")
        icon: "office-chart-line"
        source: "ConfigValues.qml"
    }
}
