import QtQuick

import org.kde.plasma.components as PlasmaComponents3

// Label for a formatted value ("21,5 °C"): when the number changes it counts to the new
// one, keeping decimals, decimal separator and unit. Other texts change at once.
PlasmaComponents3.Label {
    id: label
    property string value
    property int duration: root.animationDuration * 2
    property real shown: NaN
    property var parts: split(value)

    text: parts && !isNaN(shown) ? format(shown) : value

    function split(s) {
        const m = /^(-?\d+)(?:([.,])(\d+))?(.*)$/.exec(s || "")
        if (!m) return null
        return { num: parseFloat(m[1] + (m[3] ? "." + m[3] : "")), sep: m[2] || ".", decimals: m[3] ? m[3].length : 0, rest: m[4] }
    }

    function format(n) {
        const s = n.toFixed(parts.decimals)
        return (parts.sep === "," ? s.replace(".", ",") : s) + parts.rest
    }

    onValueChanged: {
        const old = parts
        parts = split(value)
        counter.stop()
        if (!parts) {
            shown = NaN
        } else if (old && duration > 0 && old.rest === parts.rest && !isNaN(shown) && shown !== parts.num) {
            counter.from = shown
            counter.to = parts.num
            counter.start()
        } else {
            shown = parts.num
        }
    }
    Component.onCompleted: shown = parts ? parts.num : NaN

    Behavior on color {
        enabled: root.animationDuration > 0
        ColorAnimation { duration: root.animationDuration }
    }

    NumberAnimation {
        id: counter
        target: label
        property: "shown"
        duration: label.duration
        easing.type: Easing.OutCubic
    }
}
