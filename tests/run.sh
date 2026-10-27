#!/usr/bin/env bash
# Runs all DeskHome checks; exits non-zero if any fails. Used locally and by the release workflow.
# Needs Qt 6 (qml, qmllint), Kirigami, KCMUtils, libplasma, plasma5support, KSvg,
# KDeclarative, KItemModels, KNotifications, Qt WebSockets and python3.
set -u
cd "$(dirname "$0")/.."
export QT_QPA_PLATFORM=offscreen QT_FORCE_STDERR_LOGGING=1
QML=$(command -v qml6 || command -v /usr/lib/qt6/bin/qml || command -v qml)
QMLLINT=$(command -v qmllint6 || command -v /usr/lib/qt6/bin/qmllint || command -v qmllint)
OUT=${DESKHOME_TEST_OUT:-$(mktemp -d)}
mkdir -p "$OUT"
status=0

# QML messages that mean something in the widget is broken
BROKEN='already taken|ReferenceError|TypeError|is not a type|Type [A-Za-z]+ unavailable|Non-existent attached object|Cannot assign|Unable to assign|is not installed|Syntax error|Expected token|Binding loop'

# DESKHOME_TEST_IGNORE: regex for messages that only come from the test setup on a given
# platform (e.g. KDE modules that rely on plasmashell's global i18nc on Plasma 6.3)
relevant() {
    if [ -n "${DESKHOME_TEST_IGNORE:-}" ]; then grep -Ev "$DESKHOME_TEST_IGNORE" "$1"; else cat "$1"; fi
}

run() {
    local name=$1; shift
    if "$@" >"$OUT/$name.log" 2>&1 && ! relevant "$OUT/$name.log" | grep -Eq "$BROKEN"; then
        echo "PASS $name"
    else
        echo "FAIL $name"; relevant "$OUT/$name.log" | grep -E "FAIL|$BROKEN" | sed 's/^/     /' | head -20
        status=1
    fi
}

run syntax bash -c "\"$QMLLINT\" --bare -I contents/ui contents/ui/*.qml contents/ui/*/*.qml contents/config/*.qml 2>&1 | grep -E 'Syntax error|Expected token' && exit 1 || exit 0"
run i18n-static python3 tests/check_i18n.py
run i18n-engine timeout 30 "$QML" tests/i18n.qml
run themes timeout 30 "$QML" tests/themes.qml
run entity-model timeout 30 "$QML" tests/model.qml
run entity-search timeout 30 "$QML" tests/search.qml
run battery-watch timeout 30 "$QML" tests/battery.qml
run settings-pages timeout 30 "$QML" tests/pages.qml
run icon-picker timeout 30 "$QML" tests/iconpicker.qml
run render-connected timeout 30 "$QML" tests/render.qml -- "$OUT/connected.png" ok
run render-disconnected timeout 30 "$QML" tests/render.qml -- "$OUT/disconnected.png" lost
run render-large-values timeout 30 "$QML" tests/render.qml -- "$OUT/large-values.png" big
run render-ha-theme timeout 30 "$QML" tests/render.qml -- "$OUT/ha-theme.png" theme

echo "Logs and renders: $OUT"
exit $status
