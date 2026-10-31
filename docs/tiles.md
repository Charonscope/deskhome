# Creating tiles

*[Deutsche Version](kacheln.md)*

This guide explains how to add tiles to DeskHome and what every tile setting does. For installation and connecting to Home Assistant see the [README](../README.md).

## Adding tiles

1. Right-click the widget → *Configure DeskHome…* → page **Tiles**.
2. Click **Add**, type part of a name, area or entity ID into the search field and pick the entity. DeskHome chooses a suitable tile type on its own.
3. Click **OK** or **Apply**.

**A whole room at once:** *Area …* adds every suitable entity of a Home Assistant area. Entities that are already there are skipped.

**Order:** drag an entry by the handle on the left. The tiles appear in the same order, row by row.

**Quick changes on the desktop:** right-click a tile:

| Menu entry | What it does |
|---|---|
| *Edit tile …* | opens the same settings as on the *Tiles* page, just for this tile |
| *Width* | 1 or 2 columns |
| *Open history in Home Assistant* | opens the entity's history in your browser |
| *Remove tile …* | removes the tile from DeskHome (nothing changes in Home Assistant) |
| *Set up all tiles …* | opens the full settings |

## Tile types

With *Tile type: Automatic* DeskHome picks the type from the entity. You can change it per tile.

| Type | Chosen automatically for | Shows | Mouse |
|---|---|---|---|
| **Sensor with history** | numeric `sensor`, `number`, `input_number`, `counter` | large value, history graph, min/max, trend arrow | click opens the history in HA |
| **Combo (two values)** | – (choose it yourself) | two values of one device, e.g. temperature + humidity, each with its own graph line | like sensor |
| **Light / switch** | `light`, `switch`, `fan`, `input_boolean`, `cover`, `siren`, `humidifier` | state, icon in the light's color, brightness | click toggles, scroll wheel dims lights |
| **Thermostat** | `climate` | current and target temperature | scroll wheel changes the target temperature |
| **Status light** | `binary_sensor` | green / yellow / red | click opens the history in HA |
| **Simple (like original)** | everything else | icon + value | as configured |

## Tile settings

### Basics

| Setting | Meaning |
|---|---|
| **Entity** | what the tile shows. Search by name, area or ID. |
| **Heading above** | text above this tile, e.g. “Balcony”. Starts a new row – use it to group tiles. |
| **Name** | own name instead of the one from Home Assistant |
| **Icon** | own icon. *Pick an icon …* searches all Material Design Icons (English names such as `thermometer`, `fan`, `lamp`); the second button offers icons from your system icon theme. |
| **Display attribute** | show an attribute instead of the state, e.g. `current_temperature` of a thermostat |
| **Precision** | decimal places of the value |

### Tile

| Setting | Meaning |
|---|---|
| **Tile type** | see the table above |
| **Second value** | only for *Combo*: the entity of the second value, e.g. the humidity next to a temperature sensor. It gets a second color and its own history line. |
| **Width (columns)** | ½, 1, 2, 3 or 4 columns. Two half tiles sit side by side when they follow each other directly in the list. |
| **History** | time span of the graph, 1 hour to 7 days, or *Off* |
| **Logarithmic history** | the graph on a logarithmic scale: small values stay visible next to large peaks (e.g. power with an oven running) |

### Status and warnings

| Setting | Meaning |
|---|---|
| **Warning below / above** | yellow when the value falls below or rises above these numbers. Leave a field empty if you don't need it. |
| **Critical below / above** | red, same as above |
| **OK states** | states that count as fine, comma-separated, e.g. `off` or `on, home`. Every other state is shown red. Empty = automatic. |
| **Only show when abnormal** | the tile stays hidden while everything is fine. A summary tile counts the hidden checks, so you can still see that they are being watched. |
| **Show status: value in the OK color** | while the value is in range it is shown in the OK color (green). Together with the thresholds this gives three colors. |
| **Show status: label in the status color** | the tile name takes the same color as the value |
| **Show status: blinks on warning/critical** | the tile fades in and out while it is yellow or red (only with animations switched on) |

**How the color is decided:**

- `unavailable` is always red, `unknown` is yellow.
- If *OK states* are set: listed states are green, all others red.
- Binary sensors are red when they report a problem (`on` for e.g. smoke, moisture, gas, problem, battery low, update available), otherwise green.
- Numbers follow the warning and critical thresholds. Battery sensors without own thresholds use 30 % (warning) and 15 % (critical).

Problems also get a colored tile border; switch it off under *Appearance → Color border on warning/error* if the colored value is enough. Own colors for OK, warning and error: *Appearance → Colors → Status colors*.

### Actions

| Setting | Meaning |
|---|---|
| **Click action** | Home Assistant action on a single click, e.g. `light.toggle` or `script.turn_on` |
| **Double click action** | same, on a double click |
| **Scroll action** | action for the scroll wheel, e.g. brightness of a light |
| **Control: display only** | the tile only shows its value: click, double click and scroll wheel do nothing. For all tiles at once: tick *All tiles display only* on the *Tiles* page. |

Lights and switches get *toggle* (click) and *brightness* (scroll) automatically when nothing is set. Sensor, combo and status tiles without a click action open the history in Home Assistant.

### Colors of this tile

Value font color, label font color, second value color and its line color (combo tile), line color, background color and background opacity: tick *Custom color* next to one of them to override the *Appearance* settings for this tile only. Unticked, the *Appearance* page applies. Warning and error colors always take precedence. Background and opacity only work with the own tile style.

### More

| Setting | Meaning |
|---|---|
| **Notify about changes** | desktop notification whenever the state changes, e.g. for a doorbell or washing machine |
| **Display in compact view / in full view** | checkboxes in the tile list: whether a tile appears in the panel (compact), in the tile grid (full), or both |

## Weak batteries

On the *Tiles* page, *Show weak batteries below* finds every battery sensor in Home Assistant on its own – you don't need tiles for them. Devices that only report “battery low” (e.g. Homematic thermostats) appear regardless of the threshold. *off* disables the list.

## Examples

**Temperature and humidity in one tile**
Entity: the temperature sensor → *Tile type: Combo* → *Second value:* the humidity sensor of the same room → *History: 24 hours*.

**Window that warns when open**
Entity: `binary_sensor.window_…` → *Tile type: Status light* → *OK states:* `off` → optionally *Only show when abnormal*. The tile appears red only while the window is open.

**Power consumption with a warning**
Entity: the power sensor (W) → *Warning above:* `2000` → *Critical above:* `3500`.

**Energy price in three colors**
Entity: the price sensor → *Warning above:* `0.30` → *Critical above:* `0.40` → *Show status:* tick *value in the OK color* (and *label in the status color* if you like). Below 0.30 the price is green, up to 0.40 yellow, above that red. Switch off the colored border under *Appearance* if you only want the colors.

**Freezer temperature**
Entity: the freezer sensor → *Warning above:* `-16` → *Critical above:* `-12` → *Only show when abnormal*.

## Backup

*Export* on the *Tiles* page saves all tiles, the appearance and the Home Assistant URL into one file (never the token). *Import* restores it, e.g. on a new computer. *Automatic backup* additionally saves a copy on every change and keeps the three previous versions next to it (`name.1.json` is the previous one, `name.3.json` the oldest).
