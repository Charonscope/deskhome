import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../code/i18n.mjs" as I18n

KCM.SimpleKCM {
    property string cfg_url
    property string cfg_language
    property bool cfg_checkUpdates
    property int cfg_problemUnavailableMinutes
    property int cfg_problemStuckHours
    property alias cfg_problemIgnore: problemIgnore.text
    property alias cfg_haCounts: haCounts.checked
    property alias cfg_haPopups: haPopups.checked

    // Preview: texts on this page follow the selection immediately
    function tr(key, ...args) { return I18n.tr(cfg_language, key, ...args) }

    property bool urlInvalid: false

    // Pasted URLs often have a path, slash or spaces at the end;
    // a validator on the field would silently reject such pastes
    function normalizeUrl(text) {
        // copied from the browser address bar: cut off a path like /lovelace/0
        const m = text.trim().match(/^(https?:\/\/[\w.-]+(?::\d{2,5})?)(?:\/\S*)?$/)
        return m ? m[1] : ""
    }

    function acceptUrl(text) {
        const u = normalizeUrl(text)
        urlInvalid = !u && !!text.trim()
        if (!u) return
        cfg_url = u
        url.editText = u
    }

    signal configurationChanged

    onCfg_urlChanged: secrets.restore(cfg_url)

    Kirigami.FormLayout {
        Secrets {
            id: secrets
            property string token
            onReady: {
                restore(cfg_url)
                list().then(urls => (url.model = urls))
            }

            function restore(entryKey) {
                if (!entryKey) {
                    return this.token = ""
                }
                get(entryKey)
                    .then(t => this.token = t)
                    .catch(() => this.token = "")
            }
        }

        ComboBox {
            Kirigami.FormData.label: tr("general.language")
            textRole: "text"
            valueRole: "value"
            model: [
                { value: "auto", text: tr("general.languageAuto") },
                { value: "de", text: "Deutsch" },
                { value: "en", text: "English" },
                { value: "es", text: "Español" },
                { value: "fr", text: "Français" }
            ]
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_language || "auto"))
            onActivated: cfg_language = currentValue
        }

        CheckBox {
            Kirigami.FormData.label: tr("general.updates")
            text: tr("general.updatesText")
            checked: cfg_checkUpdates
            onToggled: cfg_checkUpdates = checked
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("general.api")
        }

        ComboBox {
            id: url
            editable: true
            onModelChanged: currentIndex = indexOfValue(cfg_url)
            onActiveFocusChanged: !activeFocus && accepted()
            onActivated: cfg_url = editText = currentValue
            onAccepted: acceptUrl(editText)
            Kirigami.FormData.label: tr("general.url")
            Layout.fillWidth: true
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Error
            text: tr("general.urlInvalid")
            visible: urlInvalid
        }

        Label {
            text: tr("general.urlHint", "\nhttp://homeassistant.local:8123\nhttp://homeassistant.local\nhttps://example.duckdns.org")
        }

        // Password field with an eye icon: the token is as powerful as the HA password
        // and must not end up on screenshots of the settings
        Kirigami.PasswordField {
            id: token
            text: secrets.token
            onTextEdited: configurationChanged()
            Kirigami.FormData.label: tr("general.token")
        }

        // Watching Home Assistant as a whole, without tiles
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("general.watch")
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

        CheckBox {
            id: haCounts
            Kirigami.FormData.label: tr("general.haMessages")
            text: tr("ha.countsSetting")
        }

        CheckBox {
            id: haPopups
            text: tr("ha.popupsSetting")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: tr("general.tokenHelpTitle")
        }

        Label {
            text: tr("general.tokenHelp")
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 26
        }

        Label {
            text: tr("general.tokenLink")
            visible: !!cfg_url
        }

        Kirigami.UrlButton {
            url: cfg_url + "/profile/security"
            visible: cfg_url
        }
    }

    function saveConfig() {
        acceptUrl(url.editText)
        const t = token.text.trim()
        if (!/^[\w-]+\.[\w-]+\.[\w-]+$/.test(t)) return
        secrets.set(cfg_url, t)
    }
}