import QtQuick

import "../code/version.mjs" as Version

// Asks GitHub once a day for the latest DeskHome release. It only informs: installing
// stays with the user (KDE Store, "Get New Widgets", Discover). Network errors are ignored.
QtObject {
    id: check
    property bool enabled: true
    property string current
    property string releasesApi: "https://api.github.com/repos/Charonscope/deskhome/releases/latest"
    // set when a newer release exists
    property string latest: ""
    property string releaseUrl: ""
    readonly property bool available: !!latest && Version.isNewer(latest, current)

    function run() {
        if (!enabled || !current) return
        const request = new XMLHttpRequest()
        request.onreadystatechange = () => {
            if (request.readyState !== XMLHttpRequest.DONE || request.status !== 200) return
            try {
                const release = JSON.parse(request.responseText)
                if (release.draft || release.prerelease) return
                latest = String(release.tag_name || "").replace(/^v/, "")
                releaseUrl = release.html_url || ""
            } catch (e) {}
        }
        request.open("GET", releasesApi)
        request.setRequestHeader("Accept", "application/vnd.github+json")
        request.send()
    }

    onEnabledChanged: if (enabled) firstRun.restart()

    // first check a minute after start (not during login), then once a day
    property Timer firstRun: Timer {
        interval: 60000
        running: check.enabled
        onTriggered: check.run()
    }
    property Timer daily: Timer {
        interval: 24 * 3600 * 1000
        repeat: true
        running: check.enabled
        onTriggered: check.run()
    }
}
