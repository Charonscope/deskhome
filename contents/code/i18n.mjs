// Own translations (German/English), selectable in the settings under "General".
// Entries: key -> [German, English]; %1, %2 … are replaced by arguments.
const STRINGS = Object.freeze({
    // Settings categories
    "cat.general": ["Allgemein", "General"],
    "cat.items": ["Kacheln", "Tiles"],
    "cat.look": ["Aussehen", "Appearance"],

    // General
    "general.language": ["Sprache:", "Language:"],
    "general.languageAuto": ["Automatisch (System)", "Automatic (system)"],
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
    "tip.show": ["Kacheln anzeigen", "Show entities"],
    "tip.hide": ["Kacheln ausblenden", "Hide entities"],
    "menu.open": ["%1 öffnen", "Open %1"],
    "error.ws": ["WebSocket-Verbindung konnte nicht erstellt werden", "Failed to create WebSocket client"],
    "error.requirements": ["Voraussetzungen anzeigen", "Show requirements"],
    "configure": ["Einrichten …", "Configure…"]
})

// "auto" follows the system language: German, otherwise English
export function resolve(language) {
    if (language === "de" || language === "en") return language
    return Qt.locale().name.startsWith("de") ? "de" : "en"
}

export function tr(language, key, ...args) {
    const entry = STRINGS[key]
    let text = entry ? entry[resolve(language) === "de" ? 0 : 1] : key
    // deliberately no forEach arrow function: the QML engine loses the assignment to "text" in it
    for (let i = 0; i < args.length; i++) text = text.replace("%" + (i + 1), args[i])
    return text
}
