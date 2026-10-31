import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../code/i18n.mjs" as I18n

// Watching Home Assistant as a whole, without tiles: weak batteries, devices that are gone,
// motion sensors that hang, and Home Assistant's own notifications, repairs and updates
KCM.SimpleKCM {
    property int cfg_batteryThreshold
    property int cfg_problemUnavailableMinutes
    property int cfg_problemStuckHours
    property alias cfg_problemIgnore: problemIgnore.text
    property alias cfg_haCounts: haCounts.checked
    property alias cfg_haPopups: haPopups.checked

    signal configurationChanged
    function tr(key, ...args) { return I18n.tr(plasmoid.configuration.language, key, ...args) }

    Kirigami.FormLayout {
        Label {
            text: tr("watch.intro")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 26
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("battery.title")
        }

        SpinBox {
            Kirigami.FormData.label: tr("battery.setting")
            from: 0
            to: 100
            stepSize: 5
            value: cfg_batteryThreshold
            textFromValue: v => v ? v + " %" : tr("battery.off")
            valueFromText: t => parseInt(t) || 0
            onValueModified: cfg_batteryThreshold = value
        }

        Label {
            text: tr("battery.hint")
            wrapMode: Text.WordWrap
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        // Watching Home Assistant as a whole, without tiles
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("watch.devices")
        }

        ComboBox {
            Kirigami.FormData.label: tr("problems.unavailableSetting")
            textRole: "text"
            valueRole: "value"
            model: [
                { value: 0, text: tr("battery.off") },
                { value: 15, text: tr("problems.minutes", 15) },
                { value: 30, text: tr("problems.minutes", 30) },
                { value: 60, text: tr("item.hour") },
                { value: 360, text: tr("item.hours", 6) },
                { value: 1440, text: tr("problems.day") }
            ]
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_problemUnavailableMinutes))
            onActivated: cfg_problemUnavailableMinutes = currentValue
        }

        ComboBox {
            Kirigami.FormData.label: tr("problems.stuckSetting")
            textRole: "text"
            valueRole: "value"
            model: [
                { value: 0, text: tr("battery.off") },
                { value: 6, text: tr("item.hours", 6) },
                { value: 12, text: tr("item.hours", 12) },
                { value: 24, text: tr("problems.day") },
                { value: 48, text: tr("item.days", 2) }
            ]
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_problemStuckHours))
            onActivated: cfg_problemStuckHours = currentValue
        }

        TextField {
            id: problemIgnore
            Kirigami.FormData.label: tr("problems.ignore")
            placeholderText: tr("problems.ignorePlaceholder")
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        Label {
            text: tr("problems.ignoreHint")
            wrapMode: Text.WordWrap
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Home Assistant"
        }

        CheckBox {
            id: haCounts
            text: tr("ha.countsSetting")
        }

        CheckBox {
            id: haPopups
            text: tr("ha.popupsSetting")
        }

    }
}
