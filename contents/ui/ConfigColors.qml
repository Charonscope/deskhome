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
            Kirigami.FormData.label: tr("look.colorSourceTitle")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.colorSource")
            help: tr("help.colorSource")
            ComboBox {
                id: colorSource
                model: [
                    { value: "plasma", text: tr("look.source.plasma") },
                    { value: "ha", text: tr("look.source.ha") }
                ]
                textRole: "text"
                valueRole: "value"
                Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_colorSource))
                onActivated: cfg_colorSource = currentValue
            }
        }

        HelpRow {
            visible: cfg_colorSource === "ha"
            Kirigami.FormData.label: tr("look.haTheme")
            help: tr("look.haHint")
            ComboBox {
                id: haTheme
                enabled: !!haThemes
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
        }

        Label {
            visible: cfg_colorSource === "ha" && !haThemes
            text: tr("look.haNotConnected")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.fontColors")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.valueColor")
            help: tr("look.colorHint")
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

        HelpRow {
            Kirigami.FormData.label: tr("look.secondColor")
            help: tr("help.secondColor")
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

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.statusColorsTitle")
        }

        // Own status colors instead of the theme's (OK / warning / critical)
        HelpRow {
            Kirigami.FormData.label: tr("look.levelColors")
            help: tr("help.levelColors")
            CheckBox {
                id: levelCustomColors
                text: tr("look.customColors")
            }
        }

        RowLayout {
            enabled: levelCustomColors.checked
            Kirigami.FormData.label: tr("look.levelOk") + ":"
            KQControls.ColorButton {
                id: customOkColor
                showAlphaChannel: false
            }
        }
        RowLayout {
            enabled: levelCustomColors.checked
            Kirigami.FormData.label: tr("look.levelWarn") + ":"
            KQControls.ColorButton {
                id: customWarnColor
                showAlphaChannel: false
            }
        }
        RowLayout {
            enabled: levelCustomColors.checked
            Kirigami.FormData.label: tr("look.levelCrit") + ":"
            KQControls.ColorButton {
                id: customCritColor
                showAlphaChannel: false
            }
        }
    }
}
