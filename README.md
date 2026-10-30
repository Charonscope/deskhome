# DeskHome

**Your Home Assistant on the KDE Plasma desktop.** DeskHome is a Plasma 6 widget that shows your Home Assistant entities as a grid of tiles: sensors with history graphs, lights and switches you can control, thermostats, and a status overview that only speaks up when something is wrong.

*Deutsche Anleitung weiter unten.*

## Features

- **Tile grid** that adapts to the widget size; tiles can be ½, 1, 2, 3 or 4 columns wide, optional **headings** to group them
- **Automatic tile type** per entity, overridable per tile:
  - **Sensor** – large value, history graph (1 hour to 7 days), min/max and trend arrow
  - **Combined** – two values of one device (e.g. temperature + humidity) with two graphs
  - **Thermostat** – current and target temperature, scroll to change the target
  - **Light / switch** – click to toggle, scroll to dim, icon in the light's color
  - **Status light** – green / yellow / red, e.g. for unavailable devices
  - **Simple** – the classic icon + value tile
- **Thresholds** for warning and critical (below/above), custom “OK” states, colored tile border on problems
- **“Only show when abnormal”** – such tiles stay hidden while everything is fine; a summary tile counts the hidden checks
- **Battery list** – automatically lists every battery below a threshold you set
- **Right-click a tile** to edit it, change its width, open it in Home Assistant or remove it
- **Searchable entity picker** (name, area or ID) and “add a whole area” at once
- **Live updates** via the Home Assistant WebSocket API – no polling
- **Appearance**: Home Assistant or own colors, per-tile color and background, transparency, corner radius, tile size, spacing, font sizes and weight, icon picker (all Material Design Icons), graph style, “changed 5 min ago”, small animations
- **Panel mode** (compact view) with icons or icon + value
- **English, German, Spanish and French** user interface
- **Full backup**: export/import of all tiles, appearance and the Home Assistant URL (the token is never exported), plus an automatic backup on every change
- **Update notice** when a new version is released (can be switched off)
- Access token stored in **KWallet**

## Requirements

- **KDE Plasma 6.** Plasma 5 is not supported. Check with `plasmashell --version`. *Kubuntu 24.04 LTS still ships Plasma 5.27 – use Kubuntu 25.04 or newer.*
- **KWallet**
- **Home Assistant** reachable from your computer, and a long-lived access token
- **QML modules** – most come with Plasma. Install the ones your distribution packages separately:

| Distribution | Command |
|---|---|
| Arch, CachyOS, Manjaro | `sudo pacman -S --needed qt6-websockets` |
| Fedora | `sudo dnf install qt6-qtwebsockets` |
| Debian, Ubuntu, Kubuntu, KDE neon | see below |

Debian and Ubuntu put every QML module into its own package:

```bash
sudo apt install qml6-module-qtwebsockets qml6-module-org-kde-kitemmodels qml6-module-org-kde-notifications \
  qml6-module-qtquick-effects qml6-module-qtquick-dialogs qml6-module-org-kde-iconthemes qml6-module-org-kde-kquickcontrols
```

## Installation

**From the KDE Store:** right-click the desktop → *Add or Manage Widgets…* → *Get New Widgets…* → *Download New Plasma Widgets…* → search for “DeskHome” → *Install*.

**From a file** (from the [releases](https://github.com/Charonscope/deskhome/releases)):

```bash
kpackagetool6 -t Plasma/Applet -i deskhome-<version>.plasmoid
```

To update an existing installation use `-u` instead of `-i`.

**Then log out and back in** (or restart Plasma with `systemctl --user restart plasma-plasmashell`). Plasma only loads a new or updated widget completely after a restart – without it you may see an empty widget.

## Setup

1. **Place the widget.** Right-click the desktop → *Add or Manage Widgets…* and drag *DeskHome* onto the desktop or into a panel:
   - **On the desktop** the tile grid is shown directly. This is the normal way to use DeskHome.
   - **In a panel** DeskHome shows a compact row of icons (or icons + values). Click it to open the tile grid as a popup.
2. Open the settings: right-click the widget → *Configure DeskHome…*
3. Under *General*, enter your Home Assistant URL including protocol and port, e.g. `http://homeassistant.local:8123` or `http://192.168.1.10:8123`.
4. Create a token: in Home Assistant click your user name (profile) → *Security* → *Long-lived access tokens* → *Create token*. Copy it right away – it is shown only once.
5. Paste the token into the *Token* field and click *Apply*.
6. Under *Tiles*, add the entities you want to see – search by name or area, or add a whole area at once. Click *Apply*.

**All tile types and settings, with examples: [Creating tiles](docs/tiles.md).**

## Troubleshooting

**The widget stays empty / no tiles appear**

1. Did you log out and back in after installing or updating? (See *Installation*.)
2. Is the widget on the **desktop**? In a panel it only shows icons – click them to open the tiles.
3. Did you add tiles under *Tiles* and click *Apply*?
4. Missing QML modules – especially on Debian/Ubuntu/Kubuntu, see *Requirements*. Log out and back in after installing them.
5. Plasma version: `plasmashell --version` must show 6.x.

**“No connection to Home Assistant” / no values**

- Open the Home Assistant URL from the settings in your browser on the same computer – it must load.
- Use `http://` or `https://` exactly as your Home Assistant uses it, including the port.
- Create a new token and paste it again (no spaces before or after).
- Is KWallet enabled? DeskHome stores the token there.

**Still stuck?** Open an [issue](https://github.com/Charonscope/deskhome/issues) and include your distribution, the output of `plasmashell --version` and of:

```bash
journalctl --user -b | grep -i deskhome | tail -30
```

## Development

Run all checks locally before a release (the GitHub workflow runs the same on every push):

```bash
tests/run.sh
```

It lints the QML, checks the translations, loads every settings page and renders the tile view
(connected and disconnected) outside Plasma.

## Credits

DeskHome is a fork of [plasma-homeassistant](https://github.com/korapp/plasma-homeassistant) by Krzysztof Korab, licensed under GPLv3. The tile grid, tile types, history graphs, status lights, appearance settings, translations and backup were added in DeskHome.

Icons: [Material Design Icons](https://pictogrammers.com/library/mdi/) by Pictogrammers (Apache 2.0).

## License

GNU General Public License v3.0 – see [LICENSE](LICENSE).

---

# DeskHome (Deutsch)

**Dein Home Assistant auf dem KDE-Plasma-Desktop.** DeskHome ist ein Plasma-6-Widget, das deine Home-Assistant-Entities als Kachel-Raster zeigt: Sensoren mit Verlaufsgraph, Lichter und Schalter zum Bedienen, Thermostate und eine Status-Übersicht, die sich nur meldet, wenn etwas nicht stimmt.

## Funktionen

- **Kachel-Raster**, passt sich der Widget-Größe an; Kacheln ½ bis 4 Spalten breit, optional mit **Überschriften**
- **Kachel-Typ automatisch** je Entity, pro Kachel änderbar: Sensor mit Verlauf (1 Stunde bis 7 Tage, Min/Max, Trendpfeil), Kombikachel (z. B. Temperatur + Luftfeuchte), Thermostat (Mausrad stellt die Solltemperatur), Licht/Schalter (Klick schaltet, Mausrad dimmt), Status-Ampel, Einfach
- **Schwellen** für Warnung und Kritisch, eigene OK-Zustände, farbiger Rand bei Problemen
- **„Nur bei Auffälligkeit zeigen“** mit Sammelkachel für alle unauffälligen Prüfungen
- **Batterieliste** – zeigt automatisch alle Batterien unter einer einstellbaren Schwelle
- **Rechtsklick auf eine Kachel**: bearbeiten, Breite ändern, in Home Assistant öffnen, entfernen
- **Entity-Suche** nach Name, Bereich oder ID und „ganzen Bereich übernehmen“
- **Live-Aktualisierung** über die WebSocket-Schnittstelle von Home Assistant
- **Aussehen** frei einstellbar: Home-Assistant- oder eigene Farben, Farbe und Hintergrund pro Kachel, Transparenz, Ecken, Größe, Abstände, Schriftgröße und -stärke, Icon-Auswahl, Graph, „vor 5 min“, kleine Animationen
- **Deutsch, Englisch, Spanisch und Französisch**
- **Komplett-Backup** von Kacheln, Aussehen und HA-Adresse (ohne Token), dazu automatisches Backup bei jeder Änderung
- **Update-Hinweis** bei neuer Version (abschaltbar)

## Voraussetzungen

- **KDE Plasma 6.** Plasma 5 wird nicht unterstützt. Prüfen mit `plasmashell --version`. *Kubuntu 24.04 LTS hat noch Plasma 5.27 – nötig ist Kubuntu 25.04 oder neuer.*
- **KWallet**
- **Home Assistant** vom Rechner aus erreichbar und ein langlebiger Zugangstoken
- **QML-Module** – die meisten bringt Plasma mit. Was die Distribution getrennt verpackt, nachinstallieren:

| Distribution | Befehl |
|---|---|
| Arch, CachyOS, Manjaro | `sudo pacman -S --needed qt6-websockets` |
| Fedora | `sudo dnf install qt6-qtwebsockets` |
| Debian, Ubuntu, Kubuntu, KDE neon | siehe unten |

Debian und Ubuntu packen jedes QML-Modul in ein eigenes Paket:

```bash
sudo apt install qml6-module-qtwebsockets qml6-module-org-kde-kitemmodels qml6-module-org-kde-notifications \
  qml6-module-qtquick-effects qml6-module-qtquick-dialogs qml6-module-org-kde-iconthemes qml6-module-org-kde-kquickcontrols
```

## Installation

**Aus dem KDE Store:** Rechtsklick auf den Desktop → *Miniprogramme hinzufügen oder verwalten …* → *Neue Miniprogramme holen …* → *Neue Plasma-Miniprogramme herunterladen …* → nach „DeskHome“ suchen → *Installieren*.

**Aus einer Datei** (von den [Releases](https://github.com/Charonscope/deskhome/releases)):

```bash
kpackagetool6 -t Plasma/Applet -i deskhome-<version>.plasmoid
```

Für ein Update `-u` statt `-i` verwenden.

**Danach einmal ab- und wieder anmelden** (oder Plasma neu starten: `systemctl --user restart plasma-plasmashell`). Plasma lädt ein neues oder aktualisiertes Widget erst nach einem Neustart vollständig – sonst bleibt es eventuell leer.

## Einrichtung

1. **Widget platzieren.** Rechtsklick auf den Desktop → *Miniprogramme hinzufügen oder verwalten …* und *DeskHome* auf den Desktop oder in eine Leiste ziehen:
   - **Auf dem Desktop** erscheint das Kachel-Raster direkt. Das ist der normale Weg.
   - **In der Leiste** (Taskleiste) zeigt DeskHome nur eine kompakte Reihe Symbole (oder Symbole + Werte). Ein Klick darauf öffnet die Kacheln als Aufklappfenster.
2. Einstellungen öffnen: Rechtsklick auf das Widget → *DeskHome einrichten …*
3. Unter *Allgemein* die Home-Assistant-Adresse mit Protokoll und Port eintragen, z. B. `http://homeassistant.local:8123` oder `http://192.168.1.10:8123`.
4. Token anlegen: in Home Assistant auf den Benutzernamen klicken (Profil) → *Sicherheit* → *Langlebige Zugangstoken* → *Token erstellen*. Sofort kopieren – er wird nur einmal angezeigt.
5. Token ins Feld *Token* einfügen und *Anwenden* klicken.
6. Unter *Kacheln* die gewünschten Entities hinzufügen – Suche nach Name oder Bereich, oder gleich einen ganzen Bereich übernehmen. *Anwenden* klicken.

**Alle Kachel-Typen und Einstellungen mit Beispielen: [Kacheln anlegen](docs/kacheln.md).**

## Fehlersuche

**Widget bleibt leer / keine Kacheln zu sehen**

1. Nach Installation oder Update ab- und wieder angemeldet? (Siehe *Installation*.)
2. Liegt das Widget auf dem **Desktop**? In der Leiste zeigt es nur Symbole – erst ein Klick öffnet die Kacheln.
3. Unter *Kacheln* Entities hinzugefügt und *Anwenden* geklickt?
4. Fehlende QML-Module – vor allem bei Debian/Ubuntu/Kubuntu, siehe *Voraussetzungen*. Danach ab- und wieder anmelden.
5. Plasma-Version: `plasmashell --version` muss 6.x zeigen.

**„Keine Verbindung zu Home Assistant“ / keine Werte**

- Die Home-Assistant-Adresse aus den Einstellungen im Browser auf demselben Rechner öffnen – sie muss laden.
- `http://` bzw. `https://` genau so wie bei deinem Home Assistant, inklusive Port.
- Neuen Token anlegen und erneut einfügen (ohne Leerzeichen davor oder danach).
- Ist KWallet aktiv? Dort speichert DeskHome den Token.

**Hilft alles nicht?** Ein [Issue](https://github.com/Charonscope/deskhome/issues) anlegen, mit Distribution, Ausgabe von `plasmashell --version` und von:

```bash
journalctl --user -b | grep -i deskhome | tail -30
```

DeskHome basiert auf [plasma-homeassistant](https://github.com/korapp/plasma-homeassistant) von Krzysztof Korab (GPLv3).
