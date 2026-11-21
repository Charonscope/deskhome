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
    // the dark part of the glass: a tile's own color, otherwise a deep blue-grey, so white
    // text stays readable on a bright wallpaper whatever the theme's card color is
    property color tint: "#192332"

    Rectangle {
        anchors.fill: parent
        radius: frame.radius
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.18 * frame.strength) }
            GradientStop { position: 1; color: Qt.rgba(frame.tint.r, frame.tint.g, frame.tint.b, Math.min(0.9, 1.0 * frame.strength)) }
        }
        border.width: frame.borderWidth > 0 ? frame.borderWidth : 1
        border.color: frame.borderWidth > 0 ? frame.borderColor : Qt.rgba(1, 1, 1, 0.42)
        Behavior on border.color {
            enabled: root.animationDuration > 0
            ColorAnimation { duration: root.animationDuration }
        }
    }

    // inner highlight along the top edge, like light catching the edge of a glass pane
    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 1
        }
        height: Math.max(3, frame.radius * 0.8)
        clip: true
        Rectangle {
            width: parent.width
            height: frame.height - 2
            radius: Math.max(0, frame.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.5)
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
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.10) }
            GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
}
