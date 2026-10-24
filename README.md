# DeskHome

**Your Home Assistant on the KDE Plasma desktop.** DeskHome is a Plasma 6 widget that shows your Home Assistant entities as a grid of tiles: sensors with history graphs, lights and switches you can control, and a status overview that only speaks up when something is wrong.

*Deutsche Beschreibung weiter unten.*

## Features

- **Tile grid** that adapts to the widget size; tiles can be ½, 1, 2, 3 or 4 columns wide
- **Automatic tile type** per entity, overridable per tile:
  - **Sensor** – large value, history graph (1 hour to 7 days), min/max and trend arrow
  - **Light / switch** – click to toggle, scroll to dim, icon in the light's color
  - **Status light** – green / yellow / red, e.g. for unavailable devices or low batteries
  - **Simple** – the classic icon + value tile
- **Thresholds** for warning and critical (below/above), custom “OK” states, colored tile border on problems
- **“Only show when abnormal”** – such tiles stay hidden while everything is fine; a summary tile counts the hidden checks
- **Live updates** via the Home Assistant WebSocket API – no polling
- **Appearance**: transparent widget background with own tile background, opacity, color, corner radius, tile size, spacing, font sizes, graph style
- **Panel mode** (compact view) with icons or icon + value
- **English and German** user interface, selectable in the settings
- **Full backup**: export/import of all tiles, appearance and the Home Assistant URL (the token is never exported)
- Access token stored in **KWallet**

## Requirements

- KDE Plasma 6
- Qt WebSockets QML module (Arch/CachyOS: `qt6-websockets`, Debian/Ubuntu: `qml6-module-qtwebsockets`, Fedora: `qt6-qtwebsockets`)
- KWallet
- Home Assistant reachable from your computer, and a long-lived access token

## Installation

**From the KDE Store:** right-click the desktop → *Add Widgets…* → *Get New Widgets…* → search for “DeskHome”.

**From a file:**

```bash
kpackagetool6 -t Plasma/Applet -i deskhome-1.0.0.plasmoid
```

To update an existing installation use `-u` instead of `-i`.

## Setup

1. Add the widget to your desktop or panel and open its settings.
2. Under *General*, enter your Home Assistant URL including protocol and port, e.g. `http://homeassistant.local:8123`.
3. Create a token: in Home Assistant click your user name (profile) → *Security* → *Long-lived access tokens* → *Create token*. Copy it right away – it is shown only once.
4. Paste the token into the *Token* field and click *Apply*.
5. Under *Tiles*, add the entities you want to see.

## Credits

DeskHome is a fork of [plasma-homeassistant](https://github.com/korapp/plasma-homeassistant) by Krzysztof Korab, licensed under GPLv3. The tile grid, history graphs, status lights, appearance settings, translations and backup were added in DeskHome.

Icons: [Material Design Icons](https://pictogrammers.com/library/mdi/) by Pictogrammers (Apache 2.0).

## License

GNU General Public License v3.0 – see [LICENSE](LICENSE).

---

# DeskHome (Deutsch)

**Dein Home Assistant auf dem KDE-Plasma-Desktop.** DeskHome ist ein Plasma-6-Widget, das deine Home-Assistant-Entities als Kachel-Raster zeigt: Sensoren mit Verlaufsgraph, Lichter und Schalter zum Bedienen und eine Status-Übersicht, die sich nur meldet, wenn etwas nicht stimmt.

## Funktionen

- **Kachel-Raster**, passt sich der Widget-Größe an; Kacheln ½ bis 4 Spalten breit
- **Kachel-Typ automatisch** je Entity, pro Kachel änderbar: Sensor mit Verlauf (1 Stunde bis 7 Tage, Min/Max, Trendpfeil), Licht/Schalter (Klick schaltet, Mausrad dimmt), Status-Ampel, Einfach
- **Schwellen** für Warnung und Kritisch, eigene OK-Zustände, farbiger Rand bei Problemen
- **„Nur bei Auffälligkeit zeigen“** mit Sammelkachel für alle unauffälligen Prüfungen
- **Live-Aktualisierung** über die WebSocket-Schnittstelle von Home Assistant
- **Aussehen** frei einstellbar: transparenter Hintergrund, Deckkraft, Farbe, Ecken, Größe, Abstände, Schriftgrößen, Graph
- **Deutsch und Englisch** in den Einstellungen umschaltbar
- **Komplett-Backup** von Kacheln, Aussehen und HA-Adresse (ohne Token)

## Einrichtung

1. Widget auf den Desktop oder in die Leiste ziehen und die Einstellungen öffnen.
2. Unter *Allgemein* die Home-Assistant-Adresse mit Protokoll und Port eintragen, z. B. `http://homeassistant.local:8123`.
3. Token anlegen: in Home Assistant auf den Benutzernamen klicken (Profil) → *Sicherheit* → *Langlebige Zugangstoken* → *Token erstellen*. Sofort kopieren – er wird nur einmal angezeigt.
4. Token ins Feld *Token* einfügen und *Anwenden* klicken.
5. Unter *Kacheln* die gewünschten Entities hinzufügen.

DeskHome basiert auf [plasma-homeassistant](https://github.com/korapp/plasma-homeassistant) von Krzysztof Korab (GPLv3).
