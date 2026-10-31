import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls

import "../code/i18n.mjs" as I18n
import "../code/themes.mjs" as Themes
import "."
import "components"

// Colors: Plasma or Home Assistant theme, own colors for values, labels and status
KCM.SimpleKCM {
    property string cfg_colorSource
    property string cfg_haTheme
    property alias cfg_valueCustomColor: valueCustomColor.checked
    property alias cfg_valueColor: valueColor.color
    property alias cfg_labelCustomColor: labelCustomColor.checked
    property alias cfg_labelColor: labelColor.color
    property alias cfg_secondCustomColor: secondCustomColor.checked
    property alias cfg_secondColor: secondColor.color
    property alias cfg_levelCustomColors: levelCustomColors.checked
    property alias cfg_customOkColor: customOkColor.color
    property alias cfg_customWarnColor: customWarnColor.color
    property alias cfg_customCritColor: customCritColor.color

    // HA theme names for the selection; loaded from the shared connection
    property Client ha
    property var haThemes: null
    function loadThemes() {
        if (ha?.ready) ha.getThemes().then(result => haThemes = result, () => {})
    }
    Component.onCompleted: {
        if (!plasmoid.configuration.url) return
        ha = ClientFactory.getClient(this, plasmoid.configuration.url)
        ha.readyChanged.connect(loadThemes)
        loadThemes()
    }

    signal configurationChanged
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    Kirigami.FormLayout {
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.colors")
        }

        ComboBox {
            id: colorSource
            Kirigami.FormData.label: tr("look.colorSource")
            model: [
                { value: "plasma", text: tr("look.source.plasma") },
                { value: "ha", text: tr("look.source.ha") }
            ]
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_colorSource))
            onActivated: cfg_colorSource = currentValue
        }

        ComboBox {
            id: haTheme
            visible: cfg_colorSource === "ha"
            enabled: !!haThemes
            Kirigami.FormData.label: tr("look.haTheme")
            model: {
                const def = haThemes ? Themes.themeName(haThemes, "", false) : ""
                return [{ value: "", text: tr("look.haDefault", def || "…") }]
                    .concat((haThemes ? Themes.themeNames(haThemes) : []).map(n => ({ value: n, text: n })))
            }
            textRole: "text"
            valueRole: "value"
            onModelChanged: currentIndex = Math.max(0, indexOfValue(cfg_haTheme))
            onActivated: cfg_haTheme = currentValue
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        Label {
            visible: cfg_colorSource === "ha"
            text: haThemes ? tr("look.haHint") : tr("look.haNotConnected")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        RowLayout {
            Kirigami.FormData.label: tr("look.valueColor")
            CheckBox {
                id: valueCustomColor
                text: tr("look.customColor")
            }
            KQControls.ColorButton {
                id: valueColor
                enabled: valueCustomColor.checked
                showAlphaChannel: false
            }
        }

        RowLayout {
            Kirigami.FormData.label: tr("look.secondColor")
            CheckBox {
                id: secondCustomColor
                text: tr("look.customColor")
            }
            KQControls.ColorButton {
                id: secondColor
                enabled: secondCustomColor.checked
                showAlphaChannel: false
            }
        }

        // Own status colors instead of the theme's (OK / warning / critical)
        RowLayout {
            Kirigami.FormData.label: tr("look.levelColors")
            CheckBox {
                id: levelCustomColors
                text: tr("look.customColor")
            }
            KQControls.ColorButton {
                id: customOkColor
                enabled: levelCustomColors.checked
                showAlphaChannel: false
                ToolTip.text: tr("look.levelOk")
                ToolTip.visible: hovered
            }
            KQControls.ColorButton {
                id: customWarnColor
                enabled: levelCustomColors.checked
                showAlphaChannel: false
                ToolTip.text: tr("look.levelWarn")
                ToolTip.visible: hovered
            }
            KQControls.ColorButton {
                id: customCritColor
                enabled: levelCustomColors.checked
                showAlphaChannel: false
                ToolTip.text: tr("look.levelCrit")
                ToolTip.visible: hovered
            }
        }

        RowLayout {
            Kirigami.FormData.label: tr("look.labelColor")
            CheckBox {
                id: labelCustomColor
                text: tr("look.customColor")
            }
            KQControls.ColorButton {
                id: labelColor
                enabled: labelCustomColor.checked
                showAlphaChannel: false
            }
        }

        Label {
            text: tr("look.colorHint")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

    }
}
