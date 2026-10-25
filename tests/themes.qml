// Checks reading colors from Home Assistant themes (frontend/get_themes) in the QML engine.
// Usage: QT_QPA_PLATFORM=offscreen qml tests/themes.qml
import QtQuick

import "../contents/code/themes.mjs" as Themes

QtObject {
    function check(name, actual, expected) {
        const ok = actual === expected
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        return ok
    }

    readonly property var result: ({
        default_theme: "glass",
        default_dark_theme: null,
        themes: {
            glass: {
                "accent-color": "rgba(10, 132, 255, 0.9)",
                "primary-color": "var(--accent-color)",
                "card-background-color": "rgba(30,30,30,0.4)",
                "error-color": "var(--missing, #f44)",
                modes: {
                    light: { "primary-text-color": "#111" },
                    dark: { "primary-text-color": "hsl(0, 0%, 90%)", "success-color": "Lime" }
                }
            },
            plain: { "primary-color": "teal", "ha-card-background": "#20304080" }
        }
    })

    Component.onCompleted: {
        const dark = Themes.themePalette(result, "", true)
        const light = Themes.themePalette(result, "", false)
        const plain = Themes.themePalette(result, "plain", true)
        const builtin = Themes.themePalette({ themes: {} }, "", false)
        const results = [
            check("var() to rgba", dark.accent, "#0a84ff"),
            check("background alpha dropped", dark.background, "#1e1e1e"),
            check("var() fallback", dark.crit, "#ff4444"),
            check("dark mode hsl", dark.text, "#e6e6e6"),
            check("color name", dark.ok, "lime"),
            check("light mode", light.text, "#111111"),
            check("builtin fills gaps", light.warn, "#ff9800"),
            check("named theme", plain.accent, "teal"),
            check("ha-card-background first", plain.background, "#203040"),
            check("default theme builtin", builtin.accent, "#03a9f4"),
            check("default dark falls back", Themes.themeName(result, "", true), "glass"),
            check("theme names sorted", Themes.themeNames(result).join(","), "glass,plain"),
            check("unknown color", Themes.parseColor("linear-gradient(red, blue)"), "")
        ]
        Qt.exit(results.every(r => r) ? 0 : 1)
    }
}
