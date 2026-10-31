import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls

import "../code/i18n.mjs" as I18n

import "."
import "components"

// Tile style: frame, transparency, corners, borders, size and spacing, panel view
KCM.SimpleKCM {
    property alias cfg_flat: flat.checked
    property alias cfg_activeFrame: activeFrame.checked
    property alias cfg_compactScaleIconsToFit: compactScaleIconsToFit.checked
    property string cfg_compactEntity
    property int cfg_compactIconSpacing
    property alias cfg_tileOpacity: tileOpacity.value
    property alias cfg_tileCustomColor: tileCustomColor.checked
    property alias cfg_tileColor: tileColor.color
    property alias cfg_tileRadius: tileRadius.value
    property alias cfg_tileBorder: tileBorder.checked
    property alias cfg_levelBorder: levelBorder.checked
    property alias cfg_tileScale: tileScale.value
    property alias cfg_tileSpacing: tileSpacing.value
    property alias cfg_animations: animations.checked

    signal configurationChanged
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    Kirigami.FormLayout {
        HelpRow {
            Kirigami.FormData.label: tr("look.frame")
            help: tr("look.bgHint")
            CheckBox {
                id: flat
                text: tr("look.flat")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.background")
        }

        HelpRow {
            enabled: flat.checked
            Kirigami.FormData.label: tr("look.opacity")
            help: tr("help.opacity")
            ValueSlider {
                id: tileOpacity
                from: 0
                to: 100
                stepSize: 5
                suffix: " %"
            }
        }

        RowLayout {
            enabled: flat.checked
            Kirigami.FormData.label: tr("look.bgColor")
            CheckBox {
                id: tileCustomColor
                text: tr("look.customColor")
            }
            KQControls.ColorButton {
                id: tileColor
                enabled: tileCustomColor.checked
                showAlphaChannel: false
            }
        }

        ValueSlider {
            id: tileRadius
            enabled: flat.checked
            Kirigami.FormData.label: tr("look.radius")
            from: 0
            to: 24
            stepSize: 1
            suffix: " px"
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.borders")
        }

        CheckBox {
            id: tileBorder
            enabled: flat.checked
            Kirigami.FormData.label: tr("look.border")
            text: tr("look.borderThin")
        }

        HelpRow {
            enabled: flat.checked
            help: tr("help.levelBorder")
            CheckBox {
                id: levelBorder
                text: tr("look.levelBorder")
            }
        }

        HelpRow {
            enabled: flat.checked
            help: tr("help.activeFrame")
            CheckBox {
                id: activeFrame
                text: tr("look.activeFrame")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.layout")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.size")
            help: tr("help.size")
            ValueSlider {
                id: tileScale
                from: 70
                to: 160
                stepSize: 5
                suffix: " %"
            }
        }

        ValueSlider {
            id: tileSpacing
            Kirigami.FormData.label: tr("look.spacing")
            from: 0
            to: 24
            stepSize: 1
            suffix: " px"
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.animations")
            help: tr("look.animationsHint")
            CheckBox {
                id: animations
                text: tr("look.animationsText")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.compact")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.display")
            help: tr("help.compactDisplay")
            ComboBox {
                model: [
                    {value: "icon", label: tr("look.iconOnly")},
                    {value: "icon-and-text", label: tr("look.iconText")}
                ]
                textRole: "label"
                valueRole: "value"
                Component.onCompleted: (currentIndex = indexOfValue(cfg_compactEntity))
                onActivated: (cfg_compactEntity = currentValue)
            }
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.scaleIcons")
            help: tr("help.scaleIcons")
            CheckBox {
                id: compactScaleIconsToFit
                text: tr("look.scaleIconsText")
            }
        }

        ComboBox {
            model: [
                { value: 1, name: tr("look.small") },
                { value: 2, name: tr("look.normal") },
                { value: 6, name: tr("look.large") }
            ]
            textRole: "name"
            valueRole: "value"
            Kirigami.FormData.label: tr("look.iconSpacing")
            Component.onCompleted: (currentIndex = indexOfValue(cfg_compactIconSpacing))
            onActivated: (cfg_compactIconSpacing = currentValue)
        }
    }
}
