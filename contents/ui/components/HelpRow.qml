import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

// A settings row with a small "?" button behind it that explains the setting on click,
// like in Plasma's own settings. The row's controls go inside; `help` is the text.
RowLayout {
    id: row
    property string help
    default property alias content: controls.data
    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        id: controls
        spacing: Kirigami.Units.smallSpacing
    }

    Kirigami.ContextualHelpButton {
        visible: !!row.help
        toolTipText: row.help
    }
}
