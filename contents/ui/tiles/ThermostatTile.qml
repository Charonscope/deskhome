import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."

// Thermostat (climate): current temperature large, target temperature below.
// The scroll wheel changes the target; it is sent once the wheel rests.
Item {
    id: tile
    readonly property bool heating: model.hvac_action === "heating"
    readonly property bool off: model.state === "off"
    readonly property color iconColor: {
        if (model.level === 2) return Levels.color(2)
        if (off) return Kirigami.Theme.disabledTextColor
        return heating ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.highlightColor
    }
    // shown target: the local one while scrolling, otherwise the one from HA
    property real target: NaN
    Binding on target {
        when: !wrapper.pending && !holdTimer.running
        value: model.target_temp
    }
    readonly property int targetDecimals: model.temp_step < 1 ? 1 : 0

    function format(value, decimals) {
        return isNaN(value) ? "–" : Number(value).toLocaleString(Qt.locale(), "f", decimals) + "°"
    }

    WheelHandler {
        enabled: !isNaN(model.target_temp) && !tile.off
        acceptedDevices: PointerDevice.TouchPad | PointerDevice.Mouse
        orientation: Qt.Vertical
        onWheel: e => {
            // one wheel notch (120) = one step; touchpads collect smaller deltas
            accumulated += e.angleDelta.y
            const steps = Math.trunc(accumulated / 120)
            if (!steps) return
            accumulated -= steps * 120
            const t = Math.round((tile.target + steps * model.temp_step) / model.temp_step) * model.temp_step
            tile.target = Math.min(model.temp_max, Math.max(model.temp_min, t))
            sendTimer.restart()
            holdTimer.restart()
        }
        property real accumulated: 0
    }
    Timer {
        id: sendTimer
        interval: 600
        onTriggered: wrapper.callService({ domain: "climate", service: "set_temperature", target: { entity_id: model.entity_id } },
                                         { temperature: tile.target })
    }
    Timer {
        id: holdTimer
        interval: 3000
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: 0

        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
            DynamicIcon {
                id: headerIcon
                name: model.icon
                color: tile.iconColor
                Layout.preferredWidth: Kirigami.Units.iconSizes.small * root.labelGrow
                Layout.preferredHeight: Kirigami.Units.iconSizes.small * root.labelGrow
            }
            PlasmaComponents3.Label {
                text: model.name
                elide: Text.ElideRight
                opacity: 0.8
                font.pointSize: root.smallPt
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                text: tile.heating ? root.tr("thermo.heating") : model.value
                color: tile.heating ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.textColor
                opacity: tile.heating ? 1 : 0.6
                font.pointSize: root.smallPt
                elide: Text.ElideRight
                Layout.maximumWidth: tile.width * 0.4
            }
        }

        RowLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            Layout.leftMargin: headerIcon.item?.size ? (headerIcon.width - headerIcon.item.size.width) / 2 : 0
            PlasmaComponents3.Label {
                text: tile.format(model.current_temp, 1)
                color: model.level ? Levels.color(model.level) : Kirigami.Theme.textColor
                font.pixelSize: Kirigami.Units.gridUnit * 1.3 * root.tileScale * root.look.valueScale / 100
                font.weight: Font.Bold
            }
            PlasmaComponents3.Label {
                visible: !isNaN(model.current_humidity)
                text: Number(model.current_humidity).toLocaleString(Qt.locale(), "f", 0) + " %"
                opacity: 0.6
                font.pointSize: root.defaultPt
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 2
            }
            Item { Layout.fillWidth: true }
        }

        Item { Layout.fillHeight: true }

        // target: highlighted while it is being changed with the wheel
        PlasmaComponents3.Label {
            visible: !isNaN(tile.target)
            text: root.tr("thermo.target", tile.format(tile.target, tile.targetDecimals))
            color: holdTimer.running ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            opacity: holdTimer.running ? 1 : 0.75
            font.pointSize: root.defaultPt
            font.weight: holdTimer.running ? Font.Bold : Font.Normal
            Layout.leftMargin: headerIcon.item?.size ? (headerIcon.width - headerIcon.item.size.width) / 2 : 0
        }
    }
}
