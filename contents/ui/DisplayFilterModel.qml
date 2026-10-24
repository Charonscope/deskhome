import QtQuick

import org.kde.kitemmodels

KSortFilterProxyModel {
    enum Visibility {
        Full = 1,
        Compact = 2
    }
    property int filterItems: 0
    // Kacheln mit "nur bei Auffälligkeit" verschwinden, solange alles ok ist
    filterRowCallback: row => {
        const item = sourceModel.get(row)
        return (item.display & filterItems) && !(item.hide_when_ok && item.level === 0)
    }
}