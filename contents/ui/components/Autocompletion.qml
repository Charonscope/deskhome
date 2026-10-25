import QtQuick
import QtQuick.Controls

import org.kde.kirigami as Kirigami

// Suggestion list under a text field. The model holds plain strings or entries
// { value, title, subtitle }; every word typed must appear in the value, title or subtitle.
Popup {
    property TextField target: parent
    property var model
    property int maximumResults: 60

    function valueOf(entry) {
        return typeof entry === "string" ? entry : entry.value
    }

    function getModel() {
        const words = target.text.toLowerCase().split(/\s+/).filter(w => !!w)
        const result = []
        for (const entry of model || []) {
            const haystack = typeof entry === "string" ? entry.toLowerCase()
                : `${entry.value} ${entry.title || ""} ${entry.subtitle || ""}`.toLowerCase()
            if (words.every(w => haystack.includes(w))) {
                result.push(entry)
                if (result.length >= maximumResults) break
            }
        }
        return result
    }

    function accept(index) {
        if (~index && list.model[index] !== undefined) target.text = valueOf(list.model[index])
        close()
    }

    onTargetChanged: {
        if (!target) return
        target.pressed.connect(open)
        target.textEdited.connect(open)
        target.accepted.connect(() => accept(list.currentIndex))
        target.Keys.onUpPressed.connect(list.decrementCurrentIndex)
        target.Keys.onDownPressed.connect(list.incrementCurrentIndex)
        target.Keys.onTabPressed.connect(() => list.count && (target.text = valueOf(list.model[list.currentIndex || 0])))
    }

    y: target.height
    width: Math.max(target.width, Kirigami.Units.gridUnit * 20)
    padding: 1
    height: Math.min(contentHeight + verticalPadding * 2, Kirigami.Units.gridUnit * 16)
    onClosed: target.focus = false

    contentItem: ScrollView {
        ListView {
            id: list
            clip: true
            model: visible ? getModel() : null
            highlightMoveDuration: 0
            delegate: ItemDelegate {
                width: ListView.view.width
                highlighted: ListView.isCurrentItem
                onClicked: accept(index)
                contentItem: Kirigami.TitleSubtitle {
                    title: typeof modelData === "string" ? modelData : (modelData.title || modelData.value)
                    subtitle: typeof modelData === "string" ? "" : (modelData.subtitle || "")
                }
            }
        }
    }
}
