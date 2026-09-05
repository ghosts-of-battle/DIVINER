# Tacpad Apps

`ghost_tacpad_apps`

The four panels that sit on the map screen, each with its own switch.

| panel | what it is | source |
|---|---|---|
| **LIVE TILES** | the top band — kicker, one big live value, one detail line; clicking a tile opens that app | drones and jam off `ghost_hacking`'s scanner, weather off the engine, radio stubbed |
| **SQUAD** | the left rail — one row per man with a health swatch | ACE medical where present, engine damage where not |
| **TAC//MSG READER** | the docked reader — threads newest first, precedence first in the eye | `ghost_messaging`'s index |
| **MAP TOOLS** | the bottom strip | a front end for PLP Map Tools Remastered |

**The band is aligned to its neighbours**: it starts where the squad rail's right
edge is and ends where the reader column's left edge is, so the three read as one
layout rather than three panels that happen to be near each other. Six tiles have
to fit that 0.562 of the safe zone, which is why `TILE_W` is 0.086 rather than
the design's 0.092 — at 0.092 the sixth tile ran through the reader's edge and
the band dropped it.

`ghost_tacpad_apps_tileRows` stacks the same tiles in **two rows** for a screen
where the rail and the reader have taken the width the band wanted; one row is
the design's and the default. The panel keeps whatever width it was dragged to,
so a two-row band is usually worth dragging narrower.

Six tiles: DRONES, JAM, **HACK**, WEATHER, RADIO, **TIMER** — the band's default width is
cut for exactly six. A tile that does not fit is not drawn at all, so a band
dragged narrower says `+N` at its right edge rather than quietly losing one.

**TIMER** is the archived cTab device's alarm page rebuilt, with a stopwatch
under it. The roster is armed alarms, soonest first — each a *running* clock and
not a rounded minute, numbered and named by whoever set them, red inside thirty
seconds and amber inside two — with `+1 / +5 / +10 MIN` to arm and a `DEL #N` per
row whose number is the number on the roster. It says RINGING while one is.

**The alarms are `ghost_hacking`'s, not this addon's.** They ring through its
handler, they are public so a section shares one roster, and the hand-held
scanner arms into the same list. Two alarm systems would be two sets of alarms
nobody could reconcile.

The stopwatch beneath is this addon's own and is a different tool — an alarm is a
mark you set for later, a stopwatch is a thing you time. It is three numbers in
`missionNamespace` read through `fnc_timerState`, so it is right whether or not
anything has been ticking, and it rings onto `ghost_common`'s alert bus locally.

The tile follows the same rule: an armed alarm counts the nearest one down,
because that is a thing that will happen to you; the stopwatch has the tile the
rest of the time.

## The EW scanner on a vanilla info panel — REMOVED

This addon used to carry a **Custom Info** panel resource for the EW readout —
the game's own side panels — plus a `scanPanelFoot` setting that turned one on
while walking. All of it is gone.

**It broke the vanilla info panels.** The component was never wired into any
vehicle (that patch was pulled earlier for blanking every panel in the game), so
`setInfoPanel` was being asked to select a component the player did not have.
Turning a panel on and then naming a component that is not there is what left the
built-in panels dead — a runtime call, not a config patch, which is why removing
the config the first time did not fix it.

The wiring cannot be done safely mod-wide either. Every vehicle writes its own
full component list — a helicopter has `SlingLoadDisplay`, a tank does not — so
adding one entry means transcribing BI's list per class, which goes stale the
first time they add a panel to anything.

**The readout lives on `ghost_hud` instead**, which is the same information on
the game screen in a box the player positions in Options > Game > Layout, and
owes nothing to BI's furniture.

**The EW SCANNER screen is not a tile — the DRONES and JAM tiles open it.**
Each of those answers its own question on the band (what is overhead, how bad the
jamming is) and both press through to the one page that holds the whole sweep.
They used to have a screen each, which was two half-views of one reading with no
way to see the rest of it; those two screens are gone and this is what replaced
them. It is the readout the archived cTab
device split across three pages — the whole sweep on one screen: air contact with
bearing, range and airframe, jamming level and what it has done to your net,
channel and frequency, mesh relays, armed alarms, and the last few entries off
`ghost_common`'s alert bus. It *presents* and does not measure: every number is
the same cached `ghost_hacking_fnc_scannerRead` sweep the tiles and the drone
screen read, so no two screens in the suite can disagree about what is overhead.
With the receiver taken off a unit it says NO RECEIVER rather than a page of
dashes. It is registered as the app `scanner`, and `["scanner"] call
ghost_tacpad_fnc_openApp` opens it from anywhere.

A fifth panel, **SETTINGS**, is the gear directly under the reader — one cell,
the whole strip wide, that opens a settings screen covering scheme, text size,
opacity, which panels are shown, reader density and a reset for panel positions.
It writes the same CBA settings Addon Options writes, so there is one set of
values rather than two that can disagree.

The scheme section's **MISSION PRESETS** row is the mission's own, not the mod's.
A unit writes a row of ready-made palettes into its
`config\config_tacpad.hpp` — a `GHOST_TacpadSchemes` class, one entry per
preset, each a `name` and the three tokens `ground`, `ink` and `accent` in hex —
and everyone in that mission gets the same cards, drawn exactly like the shipped
six. It is read once per mission by `ghost_tacpad_apps_fnc_missionSchemes`; a
mission with nothing to say about colour draws no row at all.

**A mission preset *is* the custom scheme.** Pressing one writes the three custom
tokens and switches the scheme to `custom`, so nothing downstream learns a
seventh scheme name that would mean nothing in the next mission — which is also
why the card says ACTIVE on the tokens matching rather than on a name. Without
it the only way to a unit palette was twenty people reassembling the same three
colours by hand off the swatch strips.

A sixth, **PANELS**, is HIDE ALL and the SHOW ALL that undoes it. It is its own
panel because of what it survives: it was a second cell inside the settings
strip, and the strip had to be pinned against the master switch for it — so
hiding the suite left a gear on the map with nothing left to configure. Split,
HIDE ALL takes the gear with everything else and leaves exactly one control
behind, drawn in the accent so it can be found without hunting.

A seventh, **CONTACT**, is the TROOPS IN CONTACT button under the rail — the one
control in the suite that is loud on purpose. One press files the deck's own TIC
report on the command net, which is what marks the map for your side, alerts
every player on it and opens the thread: the engine already does all three off
the template's broadcast flag, so a TIC fired from the button is identical to one
filled in by hand. The marker and the alert carry the same label, `TIC <callsign>
<time>`, because a mark and the shout that sent you to it have to be the same
contact. It holds for 30 seconds after a press — a man under fire presses a big
red button more than once, and one contact is one report.

Every list in the suite is drawn by `fnc_row`, so the roster, the traffic list
and the tool strip cannot drift apart in padding, type size or divider weight —
which is exactly what happens when three panels each draw their own.

## Map tools are PLP's

The strip **does not reimplement the tools**. Compass, distance, terrain
profile, line of sight, building marking, grid placement and find-flat are PLP
Map Tools Remastered's and stay PLP's; this calls them and does nothing else. No
PLP code is copied into ghost, which is both the licensing answer and the
maintenance one — their mod updates and this keeps working. With PLP absent the
buttons draw greyed and the panel says so.

## Hue is the data, once

Squad health is the one place in the system allowed to break the near-mono rule:
green up, amber wounded, grey unconscious, black killed. A player scanning the
rail is looking for the row that is not green, and colour answers that in a
glance where a number does not. Everything else is ink on ground with the accent
reserved for selection, FLASH traffic and alert states.

## Reading beside the map, sending in the app

Clicking a thread in the reader opens it **in the rail**, not over the map.
Reading a report and looking at the ground it is about are the same act — a
MEDEVAC grid means nothing without the map under it — so the thread and the map
sit side by side and `< BACK TO LIST` returns.

Nothing in the rail can send. `REPLY` and `NEW` open the full TAC//MSG reader
with its right pane in compose — see the tacpad README. That split is
deliberate: composing needs room the rail has not got, and a WILCO fired off a
panel you were only scanning ends up on somebody else's task.

The quick replies under an open thread are **the unit's own**, set in
`ghost_tacpad_quickReplies` as a comma-separated list, five to a row. An entry
naming a reply template — `roger`, `wilco`, `inprogress`, `cantco`, `close` —
sends that template, so the thread's state still moves; anything else is sent as
those words, as free text. Either way the button is only drawn when the engine
would accept it in the thread being read, so the row can never offer something
the server would refuse.

That list used to be whichever reply templates happened to need no fields —
a list nobody chose. The design draws six phrases a unit actually says, and
which six is a unit decision.

Beside + TEMPLATE are the design's other two: **+ GRID**, which drops your own
grid into the reply box, and **+ MARKER**, a quick reply that is a dropdown of
the map markers, nearest first, and sends the marker's name and grid in one
press.

The squad app's **FILE CASEVAC FOR** *name* opens the CASEVAC card with the
pick-up site already set to that man's position: the one location in the suite
filled in for you, because the button names the man it is filling it in for.

A man's own **A/C/E letters are published the moment he presses them**, not when
anything is sent: the roster table draws that column off the same variable, so
pressing AMBER and watching your own row stay green was the screen disagreeing
with itself. **There is no SEND TEAM ACE REPORT any more** — the platoon view
reads every squad's letters at once, live, so the filed roll-up (and the `ace`
template behind it) was a second, staler copy of a state the screens already
carry. The letters are the report.

## The intrusion suite on a tile

`ghost_hacking`'s suite is reached from the **HACK** tile, and *only* from there
— its old entry lived on the cTab device and went into the archive with it. So
the tile says whether it can be opened **before** it is pressed: not cleared,
nothing in range, or a target in range. "Nothing happened" is the worst answer a
tile can give.

*Only* from there is literal. The DRONES and JAMMING apps each grew an OPEN
INTRUSION button, and they are gone: those screens read a sensor, the suite has
its own tile, and a second door into it from every screen that mentions it is how
one app becomes four half-apps. Both still say in words what can be done about
what they are showing.

**The session is the suite's, not its dialog's.** It was created inside
`ghost_hacking_fnc_tabletOpen`, so it existed only once that addon's own screen
had been opened — and this app never opens it. `tabletAdvance` found no session
and returned on its first line every tick, so the device list was never scanned:
the tile said a tower was in range and the app said NOTHING IN RANGE for the
whole mission. The session is created in `ghost_hacking`'s postInit now, and the
app scans once before drawing its first frame.

The suite itself was not rebuilt. Device cards, intel choice, the progress bar
and the session that survives the dialog closing all already work; what was
missing was a way in from the map and a palette matching everything around it.
`fnc_themeTablet` repaints its controls from the tacpad tokens on open.

That repaint lives **here, not in `ghost_hacking`** — the suite has to keep
working on a mission that never loads the tacpad, so it cannot depend on a theme
it might not have. It raises `ghost_hacking_tabletOpened` and this listens. That
is the entire coupling, and its config colours remain the fallback, so removing
the tacpad leaves the suite exactly as it was.

Opening the map to hack is the accepted cost of that. Pressing the tile closes
the map first — every reason to hack is something in front of you, and two
full-screen things fighting for the same close key is not a UI.

## Not built yet

- **Glove mode (1c)** and the **admin template builder (1d panel 04)**. The
  picker and the fill-out card are built - in the reader's right pane, not as a
  window - but a template is still something a mission declares in
  `templates.inc.sqf` rather than something a unit builds in game.
- **Net tabs** on the reader — it currently shows every box the player can see,
  which is what `ALL` selects anyway.
- **Tile apps.** Only `comms` and `squad` are registered, and `squad` raises an
  event rather than drawing a screen. Drones, jam, weather and radio have tile
  states but no screens in the handoff either.
- **Radio tile source.** Deliberately a placeholder — ghost's ACRE rack readout
  port is in `backups/ctab` and TFAR reports differently again, and picking one
  before the radio layer is settled would be inventing a source, not reading one.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `ghost_tacpad`
- `cba_xeh` _(external)_

## Ships

35 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_tacpad_apps_show_tiles` | CHECKBOX | Show live tiles |
| `ghost_tacpad_apps_tileRows` | LIST | Live tile rows |
| `ghost_tacpad_apps_show_squad` | CHECKBOX | Show squad list |
| `ghost_tacpad_apps_show_reader` | CHECKBOX | Show message reader |
| `ghost_tacpad_apps_show_tic` | CHECKBOX | Show troops in contact button |
| `ghost_tacpad_apps_show_tools` | CHECKBOX | Show map tools |
| `ghost_tacpad_apps_readerDense` | CHECKBOX | Reader: high density |
| `ghost_tacpad_apps_show_settings` | CHECKBOX | Show settings gear |

## Functions

<details><summary>35</summary>

- `ghost_tacpad_apps_fnc_alarmAtDelay`
- `ghost_tacpad_apps_fnc_ammoState`
- `ghost_tacpad_apps_fnc_appComms`
- `ghost_tacpad_apps_fnc_appDrones`
- `ghost_tacpad_apps_fnc_appHack`
- `ghost_tacpad_apps_fnc_appJamming`
- `ghost_tacpad_apps_fnc_appRadio`
- `ghost_tacpad_apps_fnc_appScanner`
- `ghost_tacpad_apps_fnc_appSettings`
- `ghost_tacpad_apps_fnc_appSquad`
- `ghost_tacpad_apps_fnc_appSupport`
- `ghost_tacpad_apps_fnc_appTimer`
- `ghost_tacpad_apps_fnc_appWeather`
- `ghost_tacpad_apps_fnc_missionSchemes`
- `ghost_tacpad_apps_fnc_panelHide`
- `ghost_tacpad_apps_fnc_panelReader`
- `ghost_tacpad_apps_fnc_panelSettings`
- `ghost_tacpad_apps_fnc_panelSquad`
- `ghost_tacpad_apps_fnc_panelTic`
- `ghost_tacpad_apps_fnc_panelTiles`
- `ghost_tacpad_apps_fnc_panelTools`
- `ghost_tacpad_apps_fnc_panelToolsBtn`
- `ghost_tacpad_apps_fnc_radioPublish`
- `ghost_tacpad_apps_fnc_radioState`
- `ghost_tacpad_apps_fnc_radioTune`
- `ghost_tacpad_apps_fnc_readerRow`
- `ghost_tacpad_apps_fnc_roleTiles`
- `ghost_tacpad_apps_fnc_row`
- `ghost_tacpad_apps_fnc_setSetting`
- `ghost_tacpad_apps_fnc_themeTablet`
- `ghost_tacpad_apps_fnc_ticSend`
- `ghost_tacpad_apps_fnc_tileData`
- `ghost_tacpad_apps_fnc_timerSet`
- `ghost_tacpad_apps_fnc_timerState`
- `ghost_tacpad_apps_fnc_toggleNet`

</details>
