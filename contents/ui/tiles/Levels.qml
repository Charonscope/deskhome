pragma Singleton

import QtQuick

import org.kde.kirigami as Kirigami

// Colors of the status levels from levels.mjs (0 ok, 1 warning, 2 critical)
QtObject {
    function color(level, okColor) {
        switch (level) {
            case 1: return Kirigami.Theme.neutralTextColor
            case 2: return Kirigami.Theme.negativeTextColor
        }
        return okColor ?? Kirigami.Theme.textColor
    }
}
