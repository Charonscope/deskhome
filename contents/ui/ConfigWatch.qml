import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../code/i18n.mjs" as I18n

import "components"

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

        HelpRow {
            Kirigami.FormData.label: tr("battery.setting")
            help: tr("battery.hint")
            SpinBox {
                from: 0
                to: 100
                stepSize: 5
                value: cfg_batteryThreshold
                textFromValue: v => v ? v + " %" : tr("battery.off")
                valueFromText: t => parseInt(t) || 0
                onValueModified: cfg_batteryThreshold = value
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("watch.devices")
        }

        HelpRow {
            Kirigami.FormData.label: tr("problems.unavailableSetting")
            help: tr("help.unavailable")
            ComboBox {
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
        }

        HelpRow {
            Kirigami.FormData.label: tr("problems.stuckSetting")
            help: tr("help.stuck")
            ComboBox {
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
        }

        HelpRow {
            Kirigami.FormData.label: tr("problems.ignore")
            help: tr("problems.ignoreHint")
            enabled: cfg_problemUnavailableMinutes > 0 || cfg_problemStuckHours > 0
            TextField {
                id: problemIgnore
                placeholderText: tr("problems.ignorePlaceholder")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 18
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Home Assistant"
        }

        HelpRow {
            help: tr("help.haCounts")
            CheckBox {
                id: haCounts
                text: tr("ha.countsSetting")
            }
        }

        HelpRow {
            help: tr("help.haPopups")
            CheckBox {
                id: haPopups
                text: tr("ha.popupsSetting")
            }
        }
    }
}
