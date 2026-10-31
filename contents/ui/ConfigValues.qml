import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls

import "../code/i18n.mjs" as I18n

import "."
import "components"

// Values and history graph: font sizes and weight, what is shown, graph style
KCM.SimpleKCM {
    property alias cfg_valueScale: valueScale.value
    property alias cfg_labelScale: labelScale.value
    property alias cfg_showMinMax: showMinMax.checked
    property alias cfg_showTrend: showTrend.checked
    property alias cfg_graphHeight: graphHeight.value
    property alias cfg_graphLineWidth: graphLineWidth.value
    property alias cfg_graphFill: graphFill.checked
    property alias cfg_graphYesterday: graphYesterday.checked
    property alias cfg_graphCustomColor: graphCustomColor.checked
    property alias cfg_graphColor: graphColor.color
    property alias cfg_showLastChanged: showLastChanged.checked
    property alias cfg_showSwitchState: showSwitchState.checked
    property int cfg_valueWeight

    signal configurationChanged
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    Kirigami.FormLayout {
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.values")
        }

        ValueSlider {
            id: labelScale
            Kirigami.FormData.label: tr("look.labelSize")
            from: 70
            to: 200
            stepSize: 10
            suffix: " %"
        }

        Label {
            text: tr("look.labelSizeHint")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        ValueSlider {
            id: valueScale
            Kirigami.FormData.label: tr("look.valueSize")
            from: 60
            to: 200
            stepSize: 10
            suffix: " %"
        }

        ComboBox {
            Kirigami.FormData.label: tr("look.valueWeight")
            model: [
                { value: 300, text: tr("look.weightLight") },
                { value: 400, text: tr("look.weightNormal") },
                { value: 600, text: tr("look.weightSemi") },
                { value: 700, text: tr("look.weightBold") }
            ]
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_valueWeight || 700))
            onActivated: cfg_valueWeight = currentValue
        }

        CheckBox {
            id: showMinMax
            Kirigami.FormData.label: tr("look.show")
            text: tr("look.minMax")
        }

        CheckBox {
            id: showTrend
            text: tr("look.trend")
        }

        CheckBox {
            id: showLastChanged
            text: tr("look.lastChanged")
        }

        CheckBox {
            id: showSwitchState
            text: tr("look.switchState")
        }


        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.graph")
        }

        ValueSlider {
            id: graphHeight
            Kirigami.FormData.label: tr("look.graphHeight")
            from: 20
            to: 70
            stepSize: 2
            suffix: " %"
        }

        ValueSlider {
            id: graphLineWidth
            Kirigami.FormData.label: tr("look.lineWidth")
            from: 0.5
            to: 4
            stepSize: 0.5
            decimals: 1
            suffix: " px"
        }

        CheckBox {
            id: graphFill
            Kirigami.FormData.label: tr("look.area")
            text: tr("look.fill")
        }

        CheckBox {
            id: graphYesterday
            Kirigami.FormData.label: tr("look.yesterday")
            text: tr("look.yesterdayText")
        }

        RowLayout {
            Kirigami.FormData.label: tr("look.lineColor")
            CheckBox {
                id: graphCustomColor
                text: tr("look.customColor")
            }
            KQControls.ColorButton {
                id: graphColor
                enabled: graphCustomColor.checked
                showAlphaChannel: false
            }
        }

    }
}
