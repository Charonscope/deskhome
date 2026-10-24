import QtQuick

import org.kde.kitemmodels

KSortFilterProxyModel {
    enum Visibility {
        Full = 1,
        Compact = 2
    }
    property int filterItems: 0
    // Tiles with "only when abnormal" disappear while everything is ok
    filterRowCallback: row => {
        const item = sourceModel.get(row)
        return (item.display & filterItems) && !(item.hide_when_ok && item.level === 0)
    }
}