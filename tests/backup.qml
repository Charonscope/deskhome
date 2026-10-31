// Checks the automatic backup: older versions are kept as "x.1.json" … "x.3.json" and only
// move on when the content changed (the export time alone does not count).
// Usage: QT_QPA_PLATFORM=offscreen qml tests/backup.qml -- <empty folder>
import QtQuick

import "../contents/ui/components"
import "../contents/code/backup.mjs" as Backup

Item {
    id: test
    readonly property string dir: Qt.application.arguments[Qt.application.arguments.length - 1]
    readonly property string path: dir + "/backup.json"
    property int failed: 0
    property int step: 0

    function check(name, actual, expected) {
        const ok = JSON.stringify(actual) === JSON.stringify(expected)
        console.log((ok ? "PASS " : "FAIL ") + name + (ok ? "" : ": got " + JSON.stringify(actual) + ", expected " + JSON.stringify(expected)))
        if (!ok) failed++
    }

    function content(n, time) {
        return JSON.stringify({ format: "deskhome", exported: time, items: [n] }, null, 2)
    }
    function itemsOf(text) { return text ? JSON.parse(text).items[0] : null }

    File { id: file }

    // what is in backup.json and its copies: [current, 1, 2, 3, 4] (null = missing)
    function contents() {
        const names = [path, Backup.copyName(path, 1), Backup.copyName(path, 2), Backup.copyName(path, 3), Backup.copyName(path, 4)]
        return Promise.all(names.map(n => file.read(n).then(itemsOf, () => null)))
    }

    Component.onCompleted: {
        check("copy name with extension", Backup.copyName("/a/b.json", 2), "/a/b.2.json")
        check("copy name without extension", Backup.copyName("/a.d/b", 1), "/a.d/b.1")
        check("copy name of a hidden file", Backup.copyName("/a/.b", 1), "/a/.b.1")
        next()
    }

    // writes run one after another (the shell commands are asynchronous)
    readonly property var steps: [
        () => file.writeKeepingCopies(path, content(1, "t1")),
        () => file.writeKeepingCopies(path, content(1, "t2")),
        () => contents().then(c => check("same content, new export time: no copy", c, [1, null, null, null, null])),
        () => file.writeKeepingCopies(path, content(2, "t3")),
        () => file.writeKeepingCopies(path, content(3, "t4")),
        () => file.writeKeepingCopies(path, content(4, "t5")),
        () => file.writeKeepingCopies(path, content(5, "t6")),
        () => contents().then(c => check("keeps the three previous versions", c, [5, 4, 3, 2, null]))
    ]
    function next() {
        if (step >= steps.length) {
            Qt.exit(failed ? 1 : 0)
            return
        }
        steps[step++]()
        pause.restart()
    }
    Timer {
        id: pause
        interval: 400
        onTriggered: test.next()
    }
    Timer {
        interval: 15000
        running: true
        onTriggered: {
            console.log("FAIL timeout")
            Qt.exit(1)
        }
    }
}
