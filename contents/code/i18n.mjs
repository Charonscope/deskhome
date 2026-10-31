// Own translations, selectable in the settings under "General".
// Entries: key -> [German, English]; %1, %2 … are replaced by arguments.
// Spanish and French live in their own files (key -> text); a missing text falls back to English.
import { STRINGS as ES } from "i18n-es.mjs"
import { STRINGS as FR } from "i18n-fr.mjs"

export const LANGUAGES = Object.freeze(["de", "en", "es", "fr"])
const OTHER = Object.freeze({ es: ES, fr: FR })

const STRINGS = Object.freeze({
    // Settings categories
    "cat.general": ["Allgemein", "General"],
    "cat.items": ["Kacheln", "Tiles"],
    "cat.look": ["Aussehen", "Appearance"],

    // General
    "general.language": ["Sprache:", "Language:"],
    "general.languageAuto": ["Automatisch (System)", "Automatic (system)"],
    "update.available": ["DeskHome %1 ist verfügbar.", "DeskHome %1 is available."],
    "update.changelog": ["Was ist neu", "What's new"],
    "update.store": ["KDE Store", "KDE Store"],
    "general.updates": ["Updates:", "Updates:"],
    "general.updatesText": ["Einmal täglich bei GitHub nach neuen Versionen sehen", "Check GitHub for new versions once a day"],
    "general.api": ["Verbindung", "Connection"],
    "general.url": ["Home-Assistant-Adresse:", "Home Assistant URL:"],
    "general.urlHint": ["Adresse mit Protokoll und Port angeben, zum Beispiel:%1", "Make sure the URL includes the protocol and port. For example:%1"],
    "general.urlInvalid": ["Das ist keine gültige Adresse. Bitte mit http:// oder https:// und ohne Pfad angeben.", "This is not a valid URL. Please include http:// or https:// and no path."],
    "general.token": ["Token:", "Token:"],
    "general.tokenHint": ["Token im Home-Assistant-Profil unter „Sicherheit“ erstellen:", "Create a token on your Home Assistant profile page under “Security”:"],
    "general.tokenHelpTitle": ["So legst du einen Token an", "How to create a token"],
    "general.tokenHelp": [
        "1. Home Assistant im Browser öffnen und unten links auf deinen Benutzernamen klicken (Profil).\n" +
        "2. Oben den Reiter „Sicherheit“ wählen.\n" +
        "3. Ganz unten bei „Langlebige Zugangstoken“ auf „Token erstellen“ klicken und einen Namen vergeben, z. B. „Plasma-Desktop“.\n" +
        "4. Den angezeigten Token sofort kopieren – Home Assistant zeigt ihn nur dieses eine Mal an.\n" +
        "5. Hier ins Feld „Token“ einfügen und mit „Anwenden“ speichern.\n" +
        "6. Danach erscheint links die Seite „Kacheln“, dort fügst du die gewünschten Entities hinzu.\n\n" +
        "Der Token wird in der KDE-Brieftasche (KWallet) gespeichert, nicht in der Widget-Konfiguration oder im Backup. " +
        "Verloren oder auf einem neuen Rechner? Einfach in Home Assistant einen neuen erstellen und den alten dort löschen.",
        "1. Open Home Assistant in your browser and click your user name at the bottom left (profile).\n" +
        "2. Select the “Security” tab at the top.\n" +
        "3. At the very bottom under “Long-lived access tokens”, click “Create token” and enter a name, e.g. “Plasma desktop”.\n" +
        "4. Copy the token right away – Home Assistant shows it only this once.\n" +
        "5. Paste it into the “Token” field here and save with “Apply”.\n" +
        "6. The “Tiles” page then appears on the left – add the entities you want there.\n\n" +
        "The token is stored in the KDE wallet (KWallet), not in the widget configuration or the backup. " +
        "Lost it or on a new computer? Simply create a new one in Home Assistant and delete the old one there."
    ],
    "general.tokenLink": ["Direkt zur Profilseite „Sicherheit“:", "Go directly to the “Security” profile page:"],

    // Tile list
    "items.displayMode": ["Anzeige für alle Kacheln", "Display mode for all tiles"],
    "items.compact": ["In der Leiste anzeigen (kompakt)", "Display in compact view"],
    "items.full": ["Im Widget anzeigen", "Display in full view"],
    "items.add": ["Hinzufügen", "Add"],
    "battery.setting": ["Schwache Batterien zeigen unter:", "Show weak batteries below:"],
    "battery.off": ["aus", "off"],
    "battery.hint": ["Findet alle Batterie-Sensoren in Home Assistant selbst; Kacheln dafür sind nicht nötig. Geräte, die nur „Batterie schwach“ melden (z. B. Homematic-Thermostate), erscheinen unabhängig von der Schwelle.", "Finds every battery sensor in Home Assistant on its own; no tiles needed. Devices that only report “battery low” (e.g. Homematic thermostats) appear regardless of the threshold."],
    "battery.title": ["Schwache Batterien", "Weak batteries"],
    "battery.low": ["schwach", "low"],
    "area.add": ["Bereich …", "Area …"],
    "area.title": ["Ganzen Bereich übernehmen", "Add a whole area"],
    "area.empty": ["In diesem Bereich gibt es keine passenden Entitäten.", "This area has no suitable entities."],
    "area.exists": ["(schon vorhanden)", "(already added)"],
    "area.added": ["%1 Kacheln aus „%2“ hinzugefügt – mit OK/Anwenden speichern.", "Added %1 tiles from “%2” – save with OK/Apply."],
    "items.edit": ["Bearbeiten", "Edit"],
    "items.delete": ["Löschen", "Delete"],
    "items.new": ["Neu", "New"],
    "items.unknown": ["Unbekannt", "Unknown"],
    "items.import": ["Importieren", "Import"],
    "items.export": ["Exportieren", "Export"],
    "items.autoBackup": ["Automatisches Backup", "Automatic backup"],
    "items.fileFilter": ["DeskHome-Backup (*.hapi *.json)", "DeskHome backup (*.hapi *.json)"],
    "items.allFiles": ["Alle Dateien (*)", "All files (*)"],
    "items.exported": ["Komplett-Backup gespeichert: Kacheln, Aussehen und HA-Adresse (ohne Token).", "Full backup saved: tiles, appearance and HA URL (without token)."],
    "items.importedOld": ["%1 Kacheln importiert (Datei ohne Aussehen).", "%1 tiles imported (file without appearance settings)."],
    "items.imported": ["Backup vom %1 geladen: %2 Kacheln und Aussehen.", "Backup from %1 loaded: %2 tiles and appearance."],
    "items.importedUrl": [" Neue HA-Adresse übernommen – falls noch kein Token für sie hinterlegt ist, unter „Allgemein“ eintragen.", " New HA URL applied – if no token is stored for it yet, enter one under “General”."],
    "items.importFailed": ["Import fehlgeschlagen: %1", "Import failed: %1"],
    "items.unknownFormat": ["Unbekanntes Dateiformat", "Unknown file format"],

    // Single tile
    "item.entity": ["Entity:", "Entity:"],
    "item.entitySearch": ["Name, Bereich oder Entity-ID suchen …", "Search name, area or entity id …"],
    "item.heading": ["Überschrift davor:", "Heading above:"],
    "item.headingPlaceholder": ["z. B. Balkon – beginnt eine neue Zeile", "e.g. Balcony – starts a new row"],
    "item.colors": ["Farben dieser Kachel", "Colors of this tile"],
    "item.colorsHint": ["Ohne Haken gelten die Werte unter „Aussehen“. Warn- und Fehlerfarben haben immer Vorrang. Hintergrund und Deckkraft wirken nur beim eigenen Kachelstil.", "Unticked, the settings under “Appearance” apply. Warning and error colors always take precedence. Background and opacity only apply to the own tile style."],
    "icon.pick": ["Icon auswählen …", "Pick an icon …"],
    "icon.pickSystem": ["Icon aus dem System-Icon-Design …", "Icon from the system icon theme …"],
    "icon.search": ["Icon suchen (englische Namen), z. B. thermometer, fan, lamp …", "Search icons, e.g. thermometer, fan, lamp …"],
    "icon.count": ["%1 Icons", "%1 icons"],
    "item.ownValue": ["Eigener Wert", "Own value"],
    "item.precision": ["Nachkommastellen:", "Precision:"],
    "item.precisionAuto": ["Automatisch (%1)", "Automatic (%1)"],
    "item.precisionRaw": ["%1 (unverändert)", "%1 (raw)"],
    "item.attribute": ["Attribut anzeigen:", "Display attribute:"],
    "item.name": ["Name:", "Name:"],
    "item.icon": ["Icon:", "Icon:"],
    "item.notify": ["Bei Änderung benachrichtigen:", "Notify about changes:"],
    "item.tile": ["Kachel", "Tile"],
    "item.tileType": ["Kachel-Typ:", "Tile type:"],
    "item.type.auto": ["Automatisch", "Automatic"],
    "item.type.sensor": ["Sensor mit Verlauf", "Sensor with history"],
    "item.type.combo": ["Kombi (zwei Werte)", "Combo (two values)"],
    "item.type.switch": ["Licht / Schalter", "Light / switch"],
    "item.type.status": ["Status-Ampel", "Status light"],
    "item.type.thermostat": ["Thermostat", "Thermostat"],
    "item.type.simple": ["Einfach (wie Original)", "Simple (like original)"],
    "item.secondEntity": ["Zweiter Wert:", "Second value:"],
    "item.secondHint": ["Entity des zweiten Werts, z. B. die Luftfeuchte zum Temperatursensor. Er erscheint in einer zweiten Farbe mit eigener Verlaufslinie.", "Entity of the second value, e.g. the humidity next to a temperature sensor. It is shown in a second color with its own history line."],
    "item.width": ["Breite (Spalten):", "Width (columns):"],
    "item.widthHalf": ["½ (halbe Kachel)", "½ (half tile)"],
    "item.widthHint": ["Zwei halbe Kacheln stehen nebeneinander, wenn sie in der Kachel-Liste direkt aufeinander folgen. Die Reihenfolge änderst du, indem du einen Eintrag am Griff links an die gewünschte Stelle ziehst.", "Two half tiles sit side by side when they follow each other directly in the tile list. Change the order by dragging an entry by the handle on the left."],
    "item.history": ["Verlauf:", "History:"],
    "item.historyOff": ["Aus", "Off"],
    "item.hour": ["1 Stunde", "1 hour"],
    "item.hours": ["%1 Stunden", "%1 hours"],
    "item.days": ["%1 Tage", "%1 days"],
    "item.warn": ["Warnung unter / über:", "Warning below / above:"],
    "item.crit": ["Kritisch unter / über:", "Critical below / above:"],
    "item.okStates": ["OK-Zustände:", "OK states:"],
    "item.okStatesHint": ["z. B. on, home (leer = automatisch)", "e.g. on, home (empty = automatic)"],
    "item.hideWhenOk": ["Nur bei Auffälligkeit zeigen:", "Only show when abnormal:"],
    "item.graphLog": ["Verlauf logarithmisch (kleine Werte neben großen Spitzen sichtbar)", "Logarithmic history (small values stay visible next to large peaks)"],
    "item.statusShow": ["Status zeigen:", "Show status:"],
    "item.levelOk": ["Wert im OK-Bereich in OK-Farbe", "Value in the OK color while in range"],
    "item.levelLabel": ["Beschriftung in Statusfarbe", "Label in the status color"],
    "item.blink": ["Blinkt bei Warnung/Kritisch", "Blinks on warning/critical"],
    "item.statusHint": ["Mit den Schwellen oben ergibt das drei Farben, z. B. Strompreis: unter der Warnschwelle OK-Farbe, darüber Warn-, über der kritischen Schwelle Fehlerfarbe. Der farbige Rand lässt sich unter „Aussehen“ abschalten; Blinken nur bei eingeschalteten Animationen.", "With the thresholds above this gives three colors, e.g. an energy price: below the warning threshold the OK color, above it the warning color, above the critical one the error color. The colored border can be switched off under “Appearance”; blinking needs animations switched on."],
    "item.secondLineColor": ["Linie zweiter Wert:", "Second value line:"],
    "item.readOnly": ["Bedienung:", "Control:"],
    "item.readOnlyText": ["Nur anzeigen (Klick und Mausrad aus)", "Display only (no click or scroll actions)"],
    "items.readOnly": ["Alle Kacheln nur anzeigen (Klick und Mausrad schalten nichts)", "All tiles display only (click and scroll wheel switch nothing)"],
    "look.weightLight": ["Dünn", "Light"],
    "look.levelColors": ["Statusfarben (OK / Warnung / Fehler):", "Status colors (OK / warning / error):"],
    "look.levelOk": ["OK", "OK"],
    "look.levelWarn": ["Warnung", "Warning"],
    "look.levelCrit": ["Fehler / kritisch", "Error / critical"],
    "item.click": ["Klick-Aktion:", "Click action:"],
    "item.dclick": ["Doppelklick-Aktion:", "Double click action:"],
    "item.scroll": ["Mausrad-Aktion:", "Scroll action:"],

    // Appearance
    "look.tiles": ["Kacheln", "Tiles"],
    "look.opacity": ["Deckkraft Hintergrund:", "Background opacity:"],
    "look.bgColor": ["Hintergrundfarbe:", "Background color:"],
    "look.customColor": ["Eigene Farbe", "Custom color"],
    "look.radius": ["Eckenradius:", "Corner radius:"],
    "look.border": ["Rand:", "Border:"],
    "look.borderThin": ["Feinen Rand zeichnen", "Draw thin border"],
    "look.levelBorder": ["Rand bei Warnung/Fehler einfärben", "Color border on warning/error"],
    "look.size": ["Kachelgröße:", "Tile size:"],
    "look.spacing": ["Abstand zwischen Kacheln:", "Spacing between tiles:"],
    "look.frame": ["Kachelstil:", "Tile style:"],
    "look.flat": ["Eigene Kacheln (Plasma-Rahmen ausblenden)", "Own tiles (hide Plasma frame)"],
    "look.bgHint": ["Deckkraft, Farbe, Eckenradius und Rand gelten nur für eigene Kacheln. Mit Plasma-Rahmen zeichnet Plasma die Kacheln mit festen Ecken.", "Opacity, color, corner radius and borders only apply to own tiles. With the Plasma frame, Plasma draws the tiles with fixed corners."],
    "look.activeFrame": ["Eingeschaltete Schalter mit Rahmen hervorheben", "Highlight switched-on tiles with a border"],
    "look.colors": ["Farben", "Colors"],
    "look.layout": ["Größe", "Size"],
    "look.colorSource": ["Farbquelle:", "Color source:"],
    "look.source.plasma": ["Plasma-Farbschema", "Plasma color scheme"],
    "look.source.ha": ["Home-Assistant-Theme", "Home Assistant theme"],
    "look.haTheme": ["Theme:", "Theme:"],
    "look.haDefault": ["HA-Standard (%1)", "HA default (%1)"],
    "look.haHint": ["Akzent-, Text-, Kachel- und Statusfarben kommen aus dem Theme. Hell oder dunkel richtet sich nach dem Plasma-Farbschema.", "Accent, text, tile and status colors come from the theme. Light or dark follows the Plasma color scheme."],
    "look.haNotConnected": ["Keine Verbindung zu Home Assistant – die Themes erscheinen, sobald sie besteht.", "Not connected to Home Assistant – the themes appear once it is."],
    "look.valueColor": ["Schriftfarbe Messwert:", "Value font color:"],
    "look.labelColor": ["Schriftfarbe Beschriftung:", "Label font color:"],
    "look.colorHint": ["Eigene Farben gelten zusätzlich zur Farbquelle. Warn- und Fehlerfarben haben immer Vorrang.", "Own colors apply on top of the color source. Warning and error colors always take precedence."],
    "look.animations": ["Animationen:", "Animations:"],
    "look.animationsText": ["Sanfte Übergänge", "Smooth transitions"],
    "look.animationsHint": ["Werte zählen hoch und runter, Farben blenden über, Kacheln blenden ein. Das Tempo folgt der Animationsgeschwindigkeit in den Plasma-Systemeinstellungen.", "Values count up and down, colors fade, tiles fade in. The speed follows the animation speed in Plasma's system settings."],
    "look.lastChanged": ["Seit wann der Zustand besteht („vor 5 min“)", "Time since the last change (“5 min ago”)"],
    "ago.now": ["gerade eben", "just now"],
    "ago.min": ["vor %1 min", "%1 min ago"],
    "ago.h": ["vor %1 h", "%1 h ago"],
    "ago.d": ["vor %1 T.", "%1 d ago"],
    "tip.history": ["Klicken: Verlauf in Home Assistant öffnen", "Click to open the history in Home Assistant"],
    "look.secondColor": ["Farbe zweiter Wert (Kombikachel):", "Second value color (combo tile):"],
    "look.valueWeight": ["Schriftstärke Messwert:", "Value font weight:"],
    "look.weightNormal": ["Normal", "Normal"],
    "look.weightSemi": ["Halbfett", "Semi-bold"],
    "look.weightBold": ["Fett", "Bold"],
    "look.switchState": ["Zustandstext bei Schaltern („An“, „Aus“)", "State text on switches (“On”, “Off”)"],
    "look.values": ["Werte", "Values"],
    "look.valueSize": ["Schriftgröße Messwert:", "Value font size:"],
    "look.labelSize": ["Schriftgröße Beschriftung:", "Label font size:"],
    "look.labelSizeHint": ["Gilt für Namen, Zustände, Min/Max und Hinweise. Größere Schrift macht die Kacheln automatisch höher.", "Applies to names, states, min/max and hints. Larger text makes the tiles taller automatically."],
    "look.show": ["Anzeigen:", "Show:"],
    "look.minMax": ["Minimum/Maximum", "Minimum/maximum"],
    "look.trend": ["Trendpfeil", "Trend arrow"],
    "look.graph": ["Verlaufsgraph", "History graph"],
    "look.graphHeight": ["Höhe:", "Height:"],
    "look.lineWidth": ["Liniendicke:", "Line width:"],
    "look.area": ["Fläche:", "Area:"],
    "look.fill": ["Unter der Linie füllen", "Fill below the line"],
    "look.lineColor": ["Linienfarbe:", "Line color:"],
    "look.compact": ["In der Leiste (kompakt)", "In the panel (compact)"],
    "look.scaleIcons": ["Icons skalieren:", "Scale icons:"],
    "look.scaleIconsText": ["An Leistenhöhe anpassen", "Fit to panel height"],
    "look.display": ["Darstellung:", "Display:"],
    "look.iconOnly": ["Nur Icon", "Icon only"],
    "look.iconText": ["Icon und Wert", "Icon and value"],
    "look.iconSpacing": ["Abstand:", "Spacing:"],
    "look.small": ["Klein", "Small"],
    "look.normal": ["Normal", "Normal"],
    "look.large": ["Groß", "Large"],

    // Connection banner
    "conn.lost": ["Keine Verbindung zu Home Assistant seit %1 – verbinde neu …", "No connection to Home Assistant since %1 – reconnecting …"],
    "conn.auth": ["Anmeldung bei Home Assistant fehlgeschlagen – bitte den Token in den Einstellungen prüfen.", "Home Assistant rejected the login – please check the token in the settings."],

    // Widget itself
    "state.unknown": ["unbekannt", "unknown"],
    "state.unavailable": ["nicht verfügbar", "unavailable"],
    "state.on": ["An", "On"],
    "state.onBrightness": ["An · %1 %", "On · %1 %"],
    "state.off": ["Aus", "Off"],
    "ok.one": ["1 weitere Prüfung OK", "1 more check OK"],
    "ok.many": ["%1 weitere Prüfungen OK", "%1 more checks OK"],
    "tip.click": ["Klicken: %1", "Click to %1"],
    "tip.dclick": ["Doppelklicken: %1", "Double click to %1"],
    "tip.scroll": ["Mausrad: %1 einstellen", "Scroll to adjust %1"],
    "tip.thermostat": ["Mausrad: Zieltemperatur einstellen", "Scroll to set the target temperature"],
    "thermo.target": ["Ziel %1", "Target %1"],
    "thermo.heating": ["heizt", "heating"],
    "menu.edit": ["Kachel bearbeiten …", "Edit tile …"],
    "menu.editTitle": ["Kachel bearbeiten – %1", "Edit tile – %1"],
    "menu.editOffline": ["Keine Verbindung zu Home Assistant: Entitäten und Aktionen können gerade nicht ausgewählt werden.", "Not connected to Home Assistant: entities and actions cannot be picked right now."],
    "menu.width": ["Breite", "Width"],
    "menu.width1": ["1 Spalte", "1 column"],
    "menu.width2": ["2 Spalten", "2 columns"],
    "menu.history": ["Verlauf in Home Assistant öffnen", "Open history in Home Assistant"],
    "menu.remove": ["Kachel entfernen …", "Remove tile …"],
    "menu.removeTitle": ["Kachel entfernen", "Remove tile"],
    "menu.removeQuestion": ["„%1“ aus DeskHome entfernen? In Home Assistant bleibt alles unverändert.", "Remove “%1” from DeskHome? Nothing changes in Home Assistant."],
    "menu.removeYes": ["Entfernen", "Remove"],
    "menu.removeNo": ["Abbrechen", "Cancel"],
    "menu.configure": ["Alle Kacheln einrichten …", "Set up all tiles …"],
    "tip.show": ["Kacheln anzeigen", "Show entities"],
    "tip.hide": ["Kacheln ausblenden", "Hide entities"],
    "menu.open": ["%1 öffnen", "Open %1"],
    "error.ws": ["WebSocket-Verbindung konnte nicht erstellt werden", "Failed to create WebSocket client"],
    "error.requirements": ["Voraussetzungen anzeigen", "Show requirements"],
    "configure": ["Einrichten …", "Configure…"]
})

// "auto" follows the system language if DeskHome has it, otherwise English
export function resolve(language) {
    if (LANGUAGES.includes(language)) return language
    const system = Qt.locale().name.substring(0, 2)
    return LANGUAGES.includes(system) ? system : "en"
}

export function tr(language, key, ...args) {
    const lang = resolve(language)
    const entry = STRINGS[key]
    let text = !entry ? key : lang === "de" ? entry[0] : (OTHER[lang]?.[key] ?? entry[1])
    // deliberately no forEach arrow function: the QML engine loses the assignment to "text" in it
    for (let i = 0; i < args.length; i++) text = text.replace("%" + (i + 1), args[i])
    return text
}
