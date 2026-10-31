import QtCore
import QtQuick
import QtQuick.Dialogs

import org.kde.plasma.plasma5support as P5Support

import "../../code/backup.mjs" as Backup

BaseObject {
    property alias defaultSuffix: fileDialog.defaultSuffix
    property alias nameFilters: fileDialog.nameFilters
    property var write: file.write
    property var read: file.read
    property var writeKeepingCopies: file.writeKeepingCopies

    P5Support.DataSource {
        id: file
        engine: "executable"
        readonly property string cmdSave: "printf '%s\\n'"
        readonly property string cmdRead: "cat"
        property var promises: new Map()
        onNewData: (sourceName, data) => {
            const p = promises.get(sourceName)
            if (p) {
                if (!data["exit code"]) {
                    p.resolve(data.stdout)
                } else {
                    p.reject(data.stderr)
                }
                promises.delete(sourceName)
            }
            disconnectSource(sourceName)
        }

        function read(url) {
            return new Promise((resolve, reject) => {
                const source = `${cmdRead} ${quote(url)}`
                connectSource(source)
                promises.set(source, { resolve, reject })
            })
        }

        function write(url, content) {
            connectSource(`${cmdSave} ${quote(content)} > ${quote(url)}`)
        }

        // Writes the file and keeps older versions next to it ("x.1.json" = the previous one).
        // The copies only move on when the content changed apart from the export time.
        function writeKeepingCopies(path, content, copies = Backup.BACKUP_COPIES) {
            const names = [path]
            for (let i = 1; i <= copies; i++) names.push(Backup.copyName(path, i))
            let shift = ""
            for (let i = copies; i >= 1; i--) shift += `[ -f ${quote(names[i - 1])} ] && mv -f ${quote(names[i - 1])} ${quote(names[i])}; `
            const tmp = quote(path + ".tmp")
            const same = `[ "$(grep -v '"exported"' ${tmp})" = "$(grep -v '"exported"' ${quote(path)})" ]`
            connectSource(`${cmdSave} ${quote(content)} > ${tmp} && { if [ -f ${quote(path)} ] && ! ${same}; then ${shift}fi; mv -f ${tmp} ${quote(path)}; }`)
        }

        // Shell-safe single quoting (apostrophes in names, spaces in paths)
        function quote(text) {
            return "'" + String(text).replace(/'/g, "'\\''") + "'"
        }
    }

    function save(content) {
        return select(FileDialog.SaveFile).then(url => file.write(url, content))
    }

    function open() {
        return select(FileDialog.OpenFile).then(file.read)
    }

    function select(fileMode = FileDialog.SaveFile) {
        fileDialog.fileMode = fileMode
        return new Promise((resolve, reject) => {
            fileDialog.open()
            fileDialog.accepted.connect(() => resolve(fixUrl(fileDialog.selectedFile)))
            fileDialog.rejected.connect(reject)
        })
    }

    function fixUrl(url) {
        return url.toString().replace("file://", "")
    }

    FileDialog {
        id: fileDialog
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    }
}