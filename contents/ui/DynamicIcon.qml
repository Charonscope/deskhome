import QtQuick

import org.kde.kirigami as Kirigami

import 'mdi'

Loader {
    id: dynamicIcon
    property string name
    property string type
    property string id
    property color color: Kirigami.Theme.textColor
    // color changes fade over this time (0 = at once)
    property int animationDuration: 0
    Behavior on color {
        enabled: dynamicIcon.animationDuration > 0
        ColorAnimation { duration: dynamicIcon.animationDuration }
    }

    // plate behind the icon: "round" (glass: tinted circle) or "chip" (bento: solid rounded
    // square, the icon turns white); it reaches platePad beyond the icon
    property string plate: ""
    readonly property real platePad: plate ? 3 : 0
    Rectangle {
        z: -1
        visible: dynamicIcon.plate
        anchors.centerIn: parent
        width: Math.max(parent.width, parent.height) + 2 * dynamicIcon.platePad
        height: width
        radius: dynamicIcon.plate === "chip" ? width * 0.3 : width / 2
        // a grey or white icon would vanish on its chip: such chips take the accent color
        color: dynamicIcon.plate === "chip" ? (dynamicIcon.color.hslSaturation < 0.25 ? root.accentColor : dynamicIcon.color)
            : Qt.rgba(dynamicIcon.color.r, dynamicIcon.color.g, dynamicIcon.color.b, 0.22)
        border.width: dynamicIcon.plate === "chip" ? 0 : 1
        border.color: Qt.rgba(1, 1, 1, 0.18)
    }

    sourceComponent: {
        switch(type) {
            case 'mdi': return mdi
            case 'plasma': return plasma
        }
    }

    onNameChanged: () => {
        if (!name || !~name.indexOf(':')) return
        [type, id] = name.split(':')
    }

    Component {
        id: mdi
        MdiIcon {
            name: id
            color: dynamicIcon.plate === "chip" ? "white" : dynamicIcon.color
        }
    }

    Component {
        id: plasma
        Kirigami.Icon {
            source: id
        }
    }
}
