// Checks the translation helper inside the real QML engine (its JavaScript differs from
// node: in 1.0.0 placeholders were never replaced because of an engine quirk).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/i18n.qml
import QtQuick

import "../contents/code/i18n.mjs" as I18n

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
            check("explicit language", I18n.resolve("en"), "en")
        ]
        Qt.exit(results.every(r => r) ? 0 : 1)
    }
}
