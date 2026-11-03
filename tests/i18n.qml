// Checks the translation helper inside the real QML engine (its JavaScript differs from
// node: in 1.0.0 placeholders were never replaced because of an engine quirk).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/i18n.qml
import QtQuick

import "../contents/code/i18n.mjs" as I18n
import "../contents/code/timeago.mjs" as TimeAgo
import "../contents/code/version.mjs" as Version
import "../contents/code/ranges.mjs" as Ranges

QtObject {
    function check(name, actual, expected) {
        const ok = actual === expected
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        return ok
    }

    readonly property var priceRanges: ({ ranges: [
        { to: 0.25, color: "#00ff00" }, { from: 0.25, to: 0.33, color: "#ffaa00" }, { from: 0.33, color: "#ff0000" }
    ] })

    Component.onCompleted: {
        const results = [
            check("placeholder de", I18n.tr("de", "items.importedOld", 5), "5 Kacheln importiert (Datei ohne Aussehen)."),
            check("placeholder en", I18n.tr("en", "state.onBrightness", 60), "On · 60 %"),
            check("two placeholders", I18n.tr("en", "items.imported", "today", 3), "Backup from today loaded: 3 tiles and appearance."),
            check("unknown key falls back to key", I18n.tr("de", "no.such.key"), "no.such.key"),
            check("explicit language", I18n.resolve("en"), "en"),
            check("spanish", I18n.tr("es", "state.onBrightness", 60), "Encendido · 60 %"),
            check("french placeholder", I18n.tr("fr", "ok.many", 3), "3 autres vérifications OK"),
            check("unknown language resolves to a known one", I18n.LANGUAGES.includes(I18n.resolve("auto")), true),
            check("ago just now", TimeAgo.ago("de", 1000000, 1030000), "gerade eben"),
            check("ago minutes de", TimeAgo.ago("de", 0 + 1, 1 + 5 * 60000), "vor 5 min"),
            check("ago hours en", TimeAgo.ago("en", 1, 1 + 3 * 3600000 + 59000), "3 h ago"),
            check("ago days de", TimeAgo.ago("de", 1, 1 + 2 * 86400000), "vor 2 T."),
            check("ago unknown time", TimeAgo.ago("de", 0, 5000), ""),
            check("newer patch", Version.isNewer("v1.3.1", "1.3.0"), true),
            check("newer minor, numeric", Version.isNewer("1.10.0", "1.9.3"), true),
            check("same version", Version.isNewer("v1.3.0", "1.3.0"), false),
            check("older", Version.isNewer("1.2.9", "1.3.0"), false),
            check("unknown never newer", Version.isNewer("latest", "1.3.0"), false),
            // color ranges: "from" belongs to the range, "to" does not; open ends
            check("range below", Ranges.rangeColor(Ranges.rangesOf(priceRanges), 0.1), "#00ff00"),
            check("range boundary goes up", Ranges.rangeColor(Ranges.rangesOf(priceRanges), 0.25), "#ffaa00"),
            check("range open end", Ranges.rangeColor(Ranges.rangesOf(priceRanges), 9), "#ff0000"),
            check("no value, no color", Ranges.rangeColor(Ranges.rangesOf(priceRanges), NaN), ""),
            check("ranges without color are ignored", Ranges.rangesOf({ ranges: [{ from: 1 }] }).length, 0),
            check("gauge scale from the ranges", JSON.stringify(Ranges.gaugeScale(priceRanges)), JSON.stringify({ min: 0.25, max: 0.33, auto: false })),
            check("gauge scale own min/max", JSON.stringify(Ranges.gaugeScale({ gauge_min: 0, gauge_max: "0,5".replace(",", ".") })), JSON.stringify({ min: 0, max: 0.5, auto: false })),
            check("gauge scale default", JSON.stringify(Ranges.gaugeScale({})), JSON.stringify({ min: 0, max: 100, auto: true }))
        ]
        Qt.exit(results.every(r => r) ? 0 : 1)
    }
}
