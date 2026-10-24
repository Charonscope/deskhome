import QtQuick 2.0

import org.kde.plasma.plasma5support 2.0 as P5Support

P5Support.DataSource {
    engine: "executable"

    readonly property var callbacks: ({})

    onNewData: (sourceName, data) => {
        const { stdout } = data
        if (callbacks[sourceName] !== undefined) {
            if (!data["exit code"]) {
                callbacks[sourceName].resolve(stdout.trim())
            } else {
                callbacks[sourceName].reject(stdout.trim())
            }
            delete callbacks[sourceName]
        }

        disconnectSource(sourceName)
    }

    function exec(cmd) {
        return new Promise((resolve, reject) => {
            callbacks[cmd] = { resolve, reject }
            connectSource(cmd)
        })
    }
}