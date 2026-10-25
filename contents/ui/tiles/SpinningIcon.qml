import QtQuick

import ".."

// Icon that turns while something runs (e.g. a fan); the period is the time per turn.
// It stands still at 0 and when animations are off.
DynamicIcon {
    id: icon
    // milliseconds per turn, 0 = still
    property int period: 0
    animationDuration: root.animationDuration
    readonly property bool spinning: period > 0 && root.animationDuration > 0

    onSpinningChanged: if (!spinning) rotation = 0
    // a new speed continues from the current angle instead of jumping back
    onPeriodChanged: {
        if (!spinning) return
        spin.from = rotation % 360
        spin.to = spin.from + 360
        spin.restart()
    }

    NumberAnimation on rotation {
        id: spin
        from: 0
        to: 360
        loops: Animation.Infinite
        duration: Math.max(300, icon.period)
        running: icon.spinning
    }
}
