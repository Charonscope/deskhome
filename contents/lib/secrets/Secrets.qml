import QtQuick 2.0

QtObject {
    id: root
    property string appId
    signal ready

    function set(key, value) {
        if (!key) {
            return
        }
        return wallet.writeEntry(wallet.folder, key, value)
    }

    function get(key) {
        return wallet.readPassword(wallet.folder, key)
    }

    function list() {
        return wallet.entryList(wallet.folder)
    }

    readonly property var wallet: Wallet {
        appId: root.appId
        readonly property string folder: appId
        
        Component.onCompleted: localWallet()
            .then(open)
            .then(() => hasFolder(folder))
            .then(hasFolder => hasFolder || createFolder(folder))
            .then(ready)
    }
}
