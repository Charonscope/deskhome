import QtQuick

// Tile background in the chosen tile style (Appearance → Tile style):
//   flat        – plain rectangle in the tile color (the classic look)
//   glass       – frosted glass: light at the top, a dark tint at the bottom, sheen and light rim
//   cockpit     – dark panel with a glowing stripe on the left in the accent or status color
//   bento       – strongly rounded block; warning and error tiles are tinted completely
//   minimal / minimalDark – no background at all, only the content (with a halo, see main.qml)
// A real blur of what lies behind the widget is not possible in a Plasma applet.
Item {
    id: frame
    property string style: root.tileStyle
    property real radius: root.look.tileRadius
    // tile color including its opacity (root.tileFill / root.tileFillColor)
    property color fill: root.tileFillColor
    // the dark part of the glass: a tile's own color, otherwise a deep blue-grey
    property color tint: "#192332"
    // a colored border (warning, active); 0 = none
    property real borderWidth: 0
    property color borderColor: "transparent"
    // the fine border of "Draw thin border"
    property bool thinBorder: !!root.look.tileBorder && root.tileBackgrounds
    // warning level shown by the frame (0 = none), and its color
    property int level: 0
    property color levelColor: "transparent"
    readonly property real strength: fill.a

    Loader {
        anchors.fill: parent
        // minimal styles draw no background at all
        active: frame.style !== "minimal" && frame.style !== "minimalDark"
        sourceComponent: ({ glass: glassFrame, cockpit: cockpitFrame, bento: bentoFrame })[frame.style] ?? flatFrame
    }

    Component {
        id: flatFrame
        Rectangle {
            radius: frame.radius
            color: frame.fill
            border.width: frame.borderWidth > 0 ? frame.borderWidth : (frame.thinBorder ? 1 : 0)
            border.color: frame.borderWidth > 0 ? frame.borderColor
                : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
            Behavior on border.color {
                enabled: root.animationDuration > 0
                ColorAnimation { duration: root.animationDuration }
            }
        }
    }

    Component {
        id: glassFrame
        Item {
            Rectangle {
                anchors.fill: parent
                radius: frame.radius
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.18 * frame.strength) }
                    GradientStop { position: 1; color: Qt.rgba(frame.tint.r, frame.tint.g, frame.tint.b, Math.min(0.9, frame.strength)) }
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
    }

    Component {
        id: cockpitFrame
        Item {
            readonly property color stripe: frame.level > 0 ? frame.levelColor
                : frame.borderWidth > 0 ? frame.borderColor : root.accentColor
            Rectangle {
                anchors.fill: parent
                radius: frame.radius
                color: frame.fill
                border.width: 1
                border.color: Qt.rgba(parent.stripe.r, parent.stripe.g, parent.stripe.b, frame.level > 0 ? 0.45 : 0.18)
            }
            // glow of the stripe, fading into the tile
            Rectangle {
                x: 1
                width: 12
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: Math.max(1, frame.radius / 2)
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Qt.rgba(stripeBar.color.r, stripeBar.color.g, stripeBar.color.b, 0.35) }
                    GradientStop { position: 1; color: "transparent" }
                }
            }
            Rectangle {
                id: stripeBar
                x: 1
                width: 4
                radius: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: Math.max(1, frame.radius / 2)
                color: parent.stripe
                Behavior on color {
                    enabled: root.animationDuration > 0
                    ColorAnimation { duration: root.animationDuration }
                }
            }
        }
    }

    Component {
        id: bentoFrame
        Rectangle {
            radius: frame.radius
            // warning and error tiles: the whole block takes on the status color
            color: frame.level > 0
                ? Qt.rgba(frame.fill.r * 0.6 + frame.levelColor.r * 0.4,
                          frame.fill.g * 0.6 + frame.levelColor.g * 0.4,
                          frame.fill.b * 0.6 + frame.levelColor.b * 0.4,
                          Math.max(0.82, frame.fill.a))
                : frame.fill
            border.width: frame.level === 0 && frame.borderWidth > 0 ? frame.borderWidth : 0
            border.color: frame.borderColor
            Behavior on color {
                enabled: root.animationDuration > 0
                ColorAnimation { duration: root.animationDuration }
            }
        }
    }
}
