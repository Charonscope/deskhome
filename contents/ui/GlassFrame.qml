import QtQuick

// "Glass" tile background: light at the top, the tile color at the bottom, a soft sheen on the
// upper half and a light rim. The tile's opacity sets how strong the glass is. A real blur of
// what lies behind the widget is not possible in a Plasma applet, so this imitates frosted glass.
Item {
    id: frame
    property real radius: root.look.tileRadius
    // tile color including its opacity (root.tileFill / root.tileFillColor)
    property color fill: root.tileFillColor
    // a colored border (warning, active); width 0 = the light glass rim
    property real borderWidth: 0
    property color borderColor: "transparent"
    readonly property real strength: fill.a

    Rectangle {
        anchors.fill: parent
        radius: frame.radius
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.05 + 0.22 * frame.strength) }
            GradientStop { position: 1; color: Qt.rgba(frame.fill.r, frame.fill.g, frame.fill.b, 0.15 + 0.55 * frame.strength) }
        }
        border.width: frame.borderWidth > 0 ? frame.borderWidth : 1
        border.color: frame.borderWidth > 0 ? frame.borderColor : Qt.rgba(1, 1, 1, 0.12 + 0.25 * frame.strength)
        Behavior on border.color {
            enabled: root.animationDuration > 0
            ColorAnimation { duration: root.animationDuration }
        }
    }

    // sheen: fades out towards the middle of the tile
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 1
        }
        height: parent.height * 0.5
        radius: Math.max(0, frame.radius - 1)
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.14) }
            GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
}
