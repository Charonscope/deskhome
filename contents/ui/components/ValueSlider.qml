import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

// Slider with value display (settings pages)
RowLayout {
    property alias value: slider.value
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property string suffix: ""
    property int decimals: 0
    Slider {
        id: slider
        snapMode: Slider.SnapAlways
        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
    }
    Label {
        text: slider.value.toFixed(decimals) + suffix
        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
    }
}
