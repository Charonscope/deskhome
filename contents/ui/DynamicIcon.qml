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
