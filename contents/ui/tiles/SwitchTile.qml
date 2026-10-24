import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import ".."
import "."

// Lichter & Schalter: Klick schaltet, Mausrad dimmt (Balken zeichnet EntityWrapper)
Item {
    id: tile
    readonly property bool on: model.active
    // halbe Kacheln: kleineres Icon, damit für den Namen Platz bleibt
    readonly property bool narrow: width < Kirigami.Units.gridUnit * 7 * root.labelGrow
    readonly property color iconColor: {
        if (model.level === 2) return Levels.color(2)
        if (!on) return Kirigami.Theme.disabledTextColor
        return model.light_color || Kirigami.Theme.highlightColor
    }
    readonly property string stateText: {
        if (model.level === 2 || model.state === "unknown") return model.value
        if (!on) return root.tr("state.off")
        return model.brightness_pct >= 0 ? root.tr("state.onBrightness", model.brightness_pct) : root.tr("state.on")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        DynamicIcon {
            name: model.icon
            color: tile.iconColor
            opacity: wrapper.pending ? 0.5 : 1
            Layout.preferredWidth: (tile.narrow ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * root.labelGrow
            Layout.preferredHeight: (tile.narrow ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * root.labelGrow
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            // Passt der Name nicht in eine Zeile, bricht er auf zwei um; der Zustand
            // ist dann am Icon zu sehen (grau = aus, farbig = an). Fehler bleiben als Text sichtbar.
            PlasmaComponents3.Label {
                id: nameLabel
                text: model.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: model.level === 2 ? 1 : 2
                font.weight: Font.Bold
                font.pointSize: root.defaultPt
                Layout.fillWidth: true
            }
            PlasmaComponents3.Label {
                visible: nameLabel.lineCount < 2 || model.level === 2
                text: tile.stateText
                elide: Text.ElideRight
                opacity: 0.75
                font.pointSize: root.smallPt
                color: model.level === 2 ? Levels.color(2) : Kirigami.Theme.textColor
                Layout.fillWidth: true
            }
        }
    }
}
