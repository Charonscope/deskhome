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
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.tiles")
        }

        CheckBox {
            id: flat
            Kirigami.FormData.label: tr("look.frame")
            text: tr("look.flat")
        }

        Label {
            text: tr("look.bgHint")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }


        ValueSlider {
            id: tileOpacity
            enabled: flat.checked
            Kirigami.FormData.label: tr("look.opacity")
            from: 0
            to: 100
            stepSize: 5
            suffix: " %"
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

        CheckBox {
            id: tileBorder
            enabled: flat.checked
            Kirigami.FormData.label: tr("look.border")
            text: tr("look.borderThin")
        }

        CheckBox {
            id: levelBorder
            enabled: flat.checked
            text: tr("look.levelBorder")
        }

        CheckBox {
            id: activeFrame
            enabled: flat.checked
            text: tr("look.activeFrame")
        }


        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.layout")
        }

        CheckBox {
            id: animations
            Kirigami.FormData.label: tr("look.animations")
            text: tr("look.animationsText")
        }

        Label {
            text: tr("look.animationsHint")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        ValueSlider {
            id: tileScale
            Kirigami.FormData.label: tr("look.size")
            from: 70
            to: 160
            stepSize: 5
            suffix: " %"
        }

        ValueSlider {
            id: tileSpacing
            Kirigami.FormData.label: tr("look.spacing")
            from: 0
            to: 24
            stepSize: 1
            suffix: " px"
        }


        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.compact")
        }

        CheckBox {
            id: compactScaleIconsToFit
            Kirigami.FormData.label: tr("look.scaleIcons")
            text: tr("look.scaleIconsText")
        }

        ComboBox {
            model: [
                {value: "icon", label: tr("look.iconOnly")},
                {value: "icon-and-text", label: tr("look.iconText")}
            ]
            textRole: "label"
            valueRole: "value"
            Kirigami.FormData.label: tr("look.display")
            Component.onCompleted: (currentIndex = indexOfValue(cfg_compactEntity))
            onActivated: (cfg_compactEntity = currentValue)
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
