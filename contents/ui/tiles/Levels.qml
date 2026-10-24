pragma Singleton

import QtQuick

import org.kde.kirigami as Kirigami

// Farben der Ampel-Stufen aus levels.mjs (0 ok, 1 Warnung, 2 kritisch)
QtObject {
    function color(level, okColor) {
        switch (level) {
            case 1: return Kirigami.Theme.neutralTextColor
            case 2: return Kirigami.Theme.negativeTextColor
        }
        return okColor ?? Kirigami.Theme.textColor
    }
}
