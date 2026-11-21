import QtQuick

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Label inside a tile: takes the font family of the tile style (cockpit: fixed width)
PlasmaComponents3.Label {
    font.family: root.tileFont || Kirigami.Theme.defaultFont.family
}
