// Checks the translation helper inside the real QML engine (its JavaScript differs from
// node: in 1.0.0 placeholders were never replaced because of an engine quirk).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/i18n.qml
import QtQuick

import "../contents/code/i18n.mjs" as I18n
import "../contents/code/timeago.mjs" as TimeAgo

QtObject {
    function check(name, actual, expected) {
        const ok = actual === expected
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        return ok
    }

    Component.onCompleted: {
        const results = [
            check("placeholder de", I18n.tr("de", "items.importedOld", 5), "5 Kacheln importiert (Datei ohne Aussehen)."),
            check("placeholder en", I18n.tr("en", "state.onBrightness", 60), "On · 60 %"),
            check("two placeholders", I18n.tr("en", "items.imported", "today", 3), "Backup from today loaded: 3 tiles and appearance."),
            check("unknown key falls back to key", I18n.tr("de", "no.such.key"), "no.such.key"),
            check("explicit language", I18n.resolve("en"), "en"),
            check("ago just now", TimeAgo.ago("de", 1000000, 1030000), "gerade eben"),
            check("ago minutes de", TimeAgo.ago("de", 0 + 1, 1 + 5 * 60000), "vor 5 min"),
            check("ago hours en", TimeAgo.ago("en", 1, 1 + 3 * 3600000 + 59000), "3 h ago"),
            check("ago days de", TimeAgo.ago("de", 1, 1 + 2 * 86400000), "vor 2 T."),
            check("ago unknown time", TimeAgo.ago("de", 0, 5000), "")
        ]
        Qt.exit(results.every(r => r) ? 0 : 1)
    }
}
