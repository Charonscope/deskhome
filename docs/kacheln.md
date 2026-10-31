# Kacheln anlegen

*[English version](tiles.md)*

Diese Anleitung zeigt, wie du Kacheln in DeskHome anlegst und was jede Kachel-Einstellung bewirkt. Installation und Verbindung zu Home Assistant stehen in der [README](../README.md#deskhome-deutsch).

## Kacheln hinzufügen

1. Rechtsklick auf das Widget → *DeskHome einrichten …* → Seite **Kacheln**.
2. **Hinzufügen** klicken, einen Teil von Name, Bereich oder Entity-ID ins Suchfeld tippen und die Entity auswählen. DeskHome wählt den passenden Kachel-Typ selbst.
3. **OK** oder **Anwenden** klicken.

**Ganzer Raum auf einmal:** *Bereich …* übernimmt alle passenden Entities eines Home-Assistant-Bereichs. Schon vorhandene werden übersprungen.

**Reihenfolge:** einen Eintrag am Griff links an die gewünschte Stelle ziehen. Die Kacheln erscheinen in derselben Reihenfolge, Zeile für Zeile.

**Schnell ändern auf dem Desktop:** Rechtsklick auf eine Kachel:

| Menüpunkt | Was passiert |
|---|---|
| *Kachel bearbeiten …* | dieselben Einstellungen wie auf der Seite *Kacheln*, nur für diese Kachel |
| *Breite* | 1 oder 2 Spalten |
| *Verlauf in Home Assistant öffnen* | öffnet den Verlauf der Entity im Browser |
| *Kachel entfernen …* | entfernt die Kachel aus DeskHome (in Home Assistant ändert sich nichts) |
| *Alle Kacheln einrichten …* | öffnet die kompletten Einstellungen |

## Kachel-Typen

Bei *Kachel-Typ: Automatisch* wählt DeskHome den Typ anhand der Entity. Pro Kachel lässt er sich ändern.

| Typ | Automatisch für | Zeigt | Maus |
|---|---|---|---|
| **Sensor mit Verlauf** | numerische `sensor`, `number`, `input_number`, `counter` | großer Wert, Verlaufsgraph, Min/Max, Trendpfeil | Klick öffnet den Verlauf in HA |
| **Kombi (zwei Werte)** | – (selbst auswählen) | zwei Werte eines Geräts, z. B. Temperatur + Luftfeuchte, jeder mit eigener Verlaufslinie | wie Sensor |
| **Licht / Schalter** | `light`, `switch`, `fan`, `input_boolean`, `cover`, `siren`, `humidifier` | Zustand, Icon in der Lichtfarbe, Helligkeit | Klick schaltet, Mausrad dimmt Lichter |
| **Thermostat** | `climate` | Ist- und Solltemperatur | Mausrad stellt die Solltemperatur |
| **Status-Ampel** | `binary_sensor` | grün / gelb / rot | Klick öffnet den Verlauf in HA |
| **Einfach (wie Original)** | alles andere | Icon + Wert | wie eingestellt |

## Kachel-Einstellungen

### Grundlegendes

| Einstellung | Bedeutung |
|---|---|
| **Entity** | was die Kachel zeigt. Suche nach Name, Bereich oder ID. |
| **Überschrift davor** | Text über dieser Kachel, z. B. „Balkon“. Beginnt eine neue Zeile – so gruppierst du Kacheln. |
| **Name** | eigener Name statt dem aus Home Assistant |
| **Icon** | eigenes Icon. *Icon auswählen …* durchsucht alle Material-Design-Icons (englische Namen wie `thermometer`, `fan`, `lamp`); der zweite Knopf bietet Icons aus dem System-Icon-Design. |
| **Attribut anzeigen** | ein Attribut statt des Zustands zeigen, z. B. `current_temperature` eines Thermostats |
| **Nachkommastellen** | Anzahl der Nachkommastellen des Werts |

### Kachel

| Einstellung | Bedeutung |
|---|---|
| **Kachel-Typ** | siehe Tabelle oben |
| **Zweiter Wert** | nur bei *Kombi*: die Entity des zweiten Werts, z. B. die Luftfeuchte zum Temperatursensor. Er bekommt eine zweite Farbe und eine eigene Verlaufslinie. |
| **Breite (Spalten)** | ½, 1, 2, 3 oder 4 Spalten. Zwei halbe Kacheln stehen nebeneinander, wenn sie in der Liste direkt aufeinander folgen. |
| **Verlauf** | Zeitraum des Graphen, 1 Stunde bis 7 Tage, oder *Aus* |
| **Verlauf logarithmisch** | der Graph mit logarithmischer Skala: kleine Werte bleiben neben großen Spitzen sichtbar (z. B. Stromverbrauch, wenn der Backofen läuft) |

### Status und Warnungen

| Einstellung | Bedeutung |
|---|---|
| **Warnung unter / über** | gelb, wenn der Wert unter bzw. über diese Zahlen fällt oder steigt. Nicht benötigte Felder leer lassen. |
| **Kritisch unter / über** | rot, sonst wie oben |
| **OK-Zustände** | Zustände, die als in Ordnung gelten, mit Komma getrennt, z. B. `off` oder `on, home`. Jeder andere Zustand wird rot. Leer = automatisch. |
| **Nur bei Auffälligkeit zeigen** | die Kachel bleibt ausgeblendet, solange alles in Ordnung ist. Eine Sammelkachel zählt die ausgeblendeten Prüfungen, damit du siehst, dass sie überwacht werden. |
| **Status zeigen: Wert im OK-Bereich in OK-Farbe** | solange der Wert in Ordnung ist, erscheint er in der OK-Farbe (grün). Zusammen mit den Schwellen ergibt das drei Farben. |
| **Status zeigen: Beschriftung in Statusfarbe** | der Kachelname bekommt dieselbe Farbe wie der Wert |
| **Status zeigen: Blinkt bei Warnung/Kritisch** | die Kachel blendet ein und aus, solange sie gelb oder rot ist (nur bei eingeschalteten Animationen) |

**So entsteht die Farbe:**

- `unavailable` ist immer rot, `unknown` gelb.
- Sind *OK-Zustände* eingetragen: diese sind grün, alle anderen rot.
- Binärsensoren sind rot, wenn sie ein Problem melden (`on` z. B. bei Rauch, Feuchtigkeit, Gas, Problem, Batterie schwach, Update verfügbar), sonst grün.
- Zahlen richten sich nach den Warn- und Kritisch-Schwellen. Batteriesensoren ohne eigene Schwellen nutzen 30 % (Warnung) und 15 % (kritisch).

Bei Problemen bekommt die Kachel zusätzlich einen farbigen Rand; abschalten unter *Kachelstil → Rand bei Warnung/Fehler einfärben*, wenn dir der farbige Wert reicht. Eigene Farben für OK, Warnung und Fehler: *Farben → Statusfarben*.

### Aktionen

| Einstellung | Bedeutung |
|---|---|
| **Klick-Aktion** | Home-Assistant-Aktion bei einem Klick, z. B. `light.toggle` oder `script.turn_on` |
| **Doppelklick-Aktion** | dasselbe bei einem Doppelklick |
| **Mausrad-Aktion** | Aktion für das Mausrad, z. B. Helligkeit eines Lichts |
| **Bedienung: Nur anzeigen** | die Kachel zeigt nur ihren Wert: Klick, Doppelklick und Mausrad bewirken nichts. Für alle Kacheln auf einmal: auf der Seite *Kacheln* *Alle Kacheln nur anzeigen* anhaken. |

Lichter und Schalter bekommen automatisch *Umschalten* (Klick) und *Helligkeit* (Mausrad), wenn nichts eingestellt ist. Sensor-, Kombi- und Status-Kacheln ohne Klick-Aktion öffnen den Verlauf in Home Assistant.

### Farben dieser Kachel

Schriftfarbe Messwert, Schriftfarbe Beschriftung, Farbe zweiter Wert und Linie zweiter Wert (Kombikachel), Linienfarbe, Hintergrundfarbe und Deckkraft Hintergrund: Mit dem Haken *Eigene Farbe* daneben gilt die Farbe nur für diese Kachel. Ohne Haken gelten die Werte unter *Farben* und *Kachelstil*. Warn- und Fehlerfarben haben immer Vorrang. Hintergrund und Deckkraft wirken nur beim eigenen Kachelstil.

### Weiteres

| Einstellung | Bedeutung |
|---|---|
| **Bei Änderung benachrichtigen** | Desktop-Benachrichtigung bei jeder Zustandsänderung, z. B. für Klingel oder Waschmaschine |
| **In der Leiste anzeigen (kompakt) / Im Widget anzeigen** | Haken in der Kachel-Liste: ob eine Kachel in der Leiste (kompakt), im Kachel-Raster oder in beiden erscheint |

## Schwache Batterien

Auf der Seite *Überwachung* findet *Schwache Batterien zeigen unter* alle Batteriesensoren in Home Assistant selbst – Kacheln dafür sind nicht nötig. Geräte, die nur „Batterie schwach“ melden (z. B. Homematic-Thermostate), erscheinen unabhängig von der Schwelle. *aus* schaltet die Liste ab.

## Beispiele

**Temperatur und Luftfeuchte in einer Kachel**
Entity: der Temperatursensor → *Kachel-Typ: Kombi* → *Zweiter Wert:* der Feuchtesensor desselben Raums → *Verlauf: 24 Stunden*.

**Fenster, das bei offen warnt**
Entity: `binary_sensor.fenster_…` → *Kachel-Typ: Status-Ampel* → *OK-Zustände:* `off` → optional *Nur bei Auffälligkeit zeigen*. Die Kachel erscheint nur rot, solange das Fenster offen ist.

**Stromverbrauch mit Warnung**
Entity: der Leistungssensor (W) → *Warnung über:* `2000` → *Kritisch über:* `3500`.

**Strompreis in drei Farben**
Entity: der Preis-Sensor → *Warnung über:* `0,30` → *Kritisch über:* `0,40` → *Status zeigen:* *Wert im OK-Bereich in OK-Farbe* anhaken (wer mag, auch *Beschriftung in Statusfarbe*). Unter 0,30 ist der Preis grün, bis 0,40 gelb, darüber rot. Den farbigen Rand unter *Kachelstil* abschalten, wenn nur die Farben gewünscht sind.

**Gefriertruhe**
Entity: der Gefriertruhen-Sensor → *Warnung über:* `-16` → *Kritisch über:* `-12` → *Nur bei Auffälligkeit zeigen*.

## Backup

*Exportieren* auf der Seite *Kacheln* speichert alle Kacheln, das Aussehen und die Home-Assistant-Adresse in eine Datei (nie den Token). *Importieren* stellt sie wieder her, z. B. auf einem neuen Rechner. *Automatisches Backup* legt zusätzlich bei jeder Änderung eine Kopie an und behält die drei vorigen Stände daneben (`name.1.json` ist der vorige, `name.3.json` der älteste).
