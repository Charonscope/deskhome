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

    // round plate behind the icon (glass look); it reaches platePad beyond the icon
    property bool plate: false
    readonly property real platePad: plate ? 3 : 0
    Rectangle {
        z: -1
        visible: dynamicIcon.plate
        anchors.centerIn: parent
        width: Math.max(parent.width, parent.height) + 2 * dynamicIcon.platePad
        height: width
        radius: width / 2
        color: Qt.rgba(dynamicIcon.color.r, dynamicIcon.color.g, dynamicIcon.color.b, 0.22)
        border.width: 1
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
            color: dynamicIcon.color
        }
    }

    Component {
        id: plasma
        Kirigami.Icon {
            source: id
        }
    }
}
