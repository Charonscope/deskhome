import QtQuick
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import "tiles"

MouseArea {
    id: control
    clip: true
    // thermostats have no click action but take the scroll wheel
    // sensors without an own click action open their history in Home Assistant
    readonly property bool opensHistory: sourceIndex >= 0 && !default_action?.service
        && ["sensor", "combo", "status"].includes(model.kind) && !!root.url
    readonly property bool interactive: !!actions.length || model.kind === "thermostat" && !readOnly || opensHistory
    // "Seen" in the right-click menu: no border, pulse or blinking until the value was OK again
    readonly property bool quiet: { root.acknowledged; return root.isAcknowledged(model.entity_id) }
    // display only (all tiles or this one): no click, double click or scroll actions
    readonly property bool readOnly: !!root.look.readOnly || !!model.read_only
    // row in the tile list (store.items); tiles with one get the right-click menu
    property int sourceIndex: -1
    signal contextMenuRequested(real x, real y)
    enabled: interactive || sourceIndex >= 0
    hoverEnabled: interactive
    acceptedButtons: sourceIndex >= 0 ? Qt.LeftButton | Qt.RightButton : Qt.LeftButton
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) contextMenuRequested(mouse.x, mouse.y)
        else if (opensHistory) Qt.openUrlExternally(`${root.url}/history?entity_id=${encodeURIComponent(model.entity_id)}`)
    }
    property bool flat: true
    property bool showBackground: false
    property alias tooltipTitle: tooltip.mainText
    readonly property var actions: actionLoaders.filter(l => l.item)
    property alias content: socket.contentItem
    property alias background: socket.background
    property bool pending

    Kirigami.Theme.inherit: flat

    Control {
        id: socket
        padding: Kirigami.Units.smallSpacing
        anchors.fill: control
        Binding on background {
            when: showBackground
            value: Item {
                height: control.height
                width: control.width

                Rectangle {
                    readonly property bool levelFrame: root.look.levelBorder && (model.level ?? 0) > 0 && !control.quiet
                    // with own tile backgrounds "active" is drawn here, matching the tile radius
                    readonly property bool activeFrame: root.tileBackgrounds && !!root.look.activeFrame && !!model.active
                    anchors.fill: parent
                    radius: root.look.tileRadius
                    color: root.tileFill(model)
                    border.width: levelFrame || activeFrame ? 1.5 : (root.look.tileBorder && root.tileBackgrounds ? 1 : 0)
                    border.color: levelFrame ? root.levelColor(model.level)
                        : activeFrame ? root.accentColor
                        : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
                    Behavior on border.color {
                        enabled: root.animationDuration > 0
                        ColorAnimation { duration: root.animationDuration }
                    }
                }

                // A critical tile pulses slowly at its border, so it is noticed from the corner of the eye
                Rectangle {
                    id: alarmPulse
                    readonly property bool pulsing: model.level === 2 && root.animationDuration > 0 && !control.quiet
                    anchors.fill: parent
                    radius: root.look.tileRadius
                    color: "transparent"
                    border.width: 2.5
                    border.color: root.critColor
                    visible: pulsing
                    opacity: 0
                    SequentialAnimation on opacity {
                        running: alarmPulse.pulsing
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.9; duration: 1200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0; duration: 1200; easing.type: Easing.InOutSine }
                    }
                }

                // Hover for own tile backgrounds; the Plasma button frames below have their own,
                // smaller corner radius and would stick out of rounded tiles
                Rectangle {
                    anchors.fill: parent
                    radius: root.look.tileRadius
                    visible: root.tileBackgrounds && control.hoverEnabled && control.containsMouse
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06)
                }

                KSvg.FrameSvgItem {
                    anchors.fill: parent
                    imagePath: "widgets/button"
                    prefix: ["toolbutton-normal", "normal"]
                    visible: !flat
                }

                KSvg.FrameSvgItem {
                    id: surfacePressed
                    anchors.fill: parent
                    imagePath: "widgets/button"
                    prefix: ["toolbutton-pressed", "pressed"]
                    visible: !root.tileBackgrounds
                    opacity: model.active ? 0.5 : 0
                    Behavior on opacity {
                        enabled: Kirigami.Units.shortDuration > 0
                        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutQuad }
                    }
                }

                KSvg.FrameSvgItem {
                    anchors.fill: parent
                    imagePath: "widgets/button"
                    prefix: ["toolbutton-hover", "normal"]
                    visible: !root.tileBackgrounds && control.hoverEnabled && control.containsMouse
                }
            }
        }
    }

    PlasmaCore.ToolTipArea {
        id: tooltip
        anchors.fill: parent
        subText: actions.map(c => c.item.tip)
            .concat(model.kind === "thermostat" && !control.readOnly ? [root.tr("tip.thermostat")] : [])
            .concat(control.opensHistory ? [root.tr("tip.history")] : []).join("\n")
    }

    function format(underscoredText) {
        return underscoredText && underscoredText.replace(/_/g, ' ')
    }

    function callService(...args) {
        pending = true
        const reset = () => pending = false
        return ha.callService(...args).then(reset, reset)
    }

    readonly property list<Loader> actionLoaders: [
        Loader {
            active: !!default_action && !control.readOnly
            sourceComponent: Component {
                Connections {
                    readonly property string tip: root.tr("tip.click", format(default_action.service))
                    target: control
                    function onClicked(mouse) {
                        if (mouse.button !== Qt.LeftButton) return
                        callService(default_action)
                    }
                }
            }
        },
        Loader {
            active: !!dclick_action && !control.readOnly
            sourceComponent: Component {
                Connections {
                    readonly property string tip: root.tr("tip.dclick", format(dclick_action.service))
                    target: control
                    function onDoubleClicked(mouse) {
                        if (mouse.button !== Qt.LeftButton) return
                        callService(dclick_action)
                    }
                }
            }
        },
        Loader {
            // thermostat tiles handle the wheel themselves (a configured scroll action would send twice)
            active: !control.readOnly && model.active && model.kind !== "thermostat" && !!scroll_action?.service && (scroll_action.domain !== 'light' || model.brightness_pct >= 0)
            anchors.fill: parent
            parent: socket.background || socket
            sourceComponent: Component {
                Item {
                    readonly property string tip: root.tr("tip.scroll", format(scroll_action.data_field))
                    property var mapper: { mapper = store.getFieldScrollMapper(scroll_action, attributes) }
                    readonly property real attributeBasedPosition: mapper.normalize(attributes[mapper.attribute])
                    property real position

                    // While scrolling only the bar moves; the value is sent once the wheel rests,
                    // and HA's intermediate states (light transitions) are ignored for a moment
                    // so the bar does not jump back and forth.
                    Binding on position {
                        when: !pending && !holdTimer.running
                        value: attributeBasedPosition
                    }
                    WheelHandler {
                        acceptedDevices: PointerDevice.TouchPad | PointerDevice.Mouse
                        orientation: Qt.Vertical
                        onWheel: e => {
                            // one wheel notch (120) = 5 %; touchpads send smaller deltas
                            const p = position + e.angleDelta.y / 120 * 0.05
                            position = p > 1 ? 1 : p < 0 ? 0 : p
                            sendTimer.restart()
                            holdTimer.restart()
                        }
                    }
                    Timer {
                        id: sendTimer
                        interval: 250
                        onTriggered: callService(scroll_action, { [scroll_action.data_field]: Math.round(mapper.denormalize(position)) })
                    }
                    Timer {
                        id: holdTimer
                        interval: 2000
                    }
                    Rectangle {
                        visible: control.showBackground
                        // follows the tile's corner radius so the bar stays inside rounded tiles
                        radius: root.tileBackgrounds ? Math.max(0, root.look.tileRadius - 1) : 3
                        x: 1
                        y: 1
                        height: parent.height - 2 * y
                        width: position * (parent.width - 2 * x)
                        color: root.accentColor
                        // fades in when the light is switched on
                        opacity: 0
                        Component.onCompleted: opacity = 0.6
                        Behavior on opacity {
                            enabled: root.animationDuration > 0
                            NumberAnimation { duration: root.animationDuration }
                        }
                        Behavior on width {
                            NumberAnimation { duration: Kirigami.Units.shortDuration }
                        }
                    }
                }
            }
        }
    ]
}