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
            Kirigami.FormData.label: tr("look.fonts")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.labelSize")
            help: tr("look.labelSizeHint")
            ValueSlider {
                id: labelScale
                from: 70
                to: 200
                stepSize: 10
                suffix: " %"
            }
        }

        ValueSlider {
            id: valueScale
            Kirigami.FormData.label: tr("look.valueSize")
            from: 60
            to: 200
            stepSize: 10
            suffix: " %"
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.valueWeight")
            help: tr("help.valueWeight")
            ComboBox {
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
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.extras")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.show")
            help: tr("help.minMax")
            CheckBox {
                id: showMinMax
                text: tr("look.minMax")
            }
        }

        HelpRow {
            help: tr("help.trend")
            CheckBox {
                id: showTrend
                text: tr("look.trend")
            }
        }

        HelpRow {
            help: tr("help.lastChanged")
            CheckBox {
                id: showLastChanged
                text: tr("look.lastChanged")
            }
        }

        CheckBox {
            id: showSwitchState
            text: tr("look.switchState")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("look.graph")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.graphHeight")
            help: tr("help.graphHeight")
            ValueSlider {
                id: graphHeight
                from: 20
                to: 70
                stepSize: 2
                suffix: " %"
            }
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

        CheckBox {
            id: graphFill
            Kirigami.FormData.label: tr("look.area")
            text: tr("look.fill")
        }

        HelpRow {
            Kirigami.FormData.label: tr("look.yesterday")
            help: tr("help.yesterday")
            CheckBox {
                id: graphYesterday
                text: tr("look.yesterdayText")
            }
        }
    }
}
