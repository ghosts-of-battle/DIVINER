# Phone walking view - design

Device: phone (arsenal GPS slot). Spec: [SPEC_DEVICES.json](SPEC_DEVICES.json) `phone_ui`.
Status: design, for code. Date 2026-10-19.
Related: [DESIGN_BFT_MEMBERS.md](DESIGN_BFT_MEMBERS.md) (member icons), [DESIGN_SIDE_DEVICES.md](DESIGN_SIDE_DEVICES.md) (same content, portrait).

## What it is

The phone's always-on view. Display only, no mouse. Shown while walking around, toggled by a key. Replaces the DUI squad radar and the voice system's on-screen info. Fullscreen only for settings (separate doc).

## Images

In game, 1080p:

![in game](../art/images/phone_ingame.png)

On the device:

![device](../art/images/phone_device.png)

Screen only (2x design units):

![screen](../art/images/phone_screen.png)

Canvas: TAC//APP Phone (artifact 5gFo1QBBxnchSCmcXKofWw).

## Size and placement

| | 1080p px | Notes |
|---|---|---|
| Frame | 610 x 274 | bottom centre, 4 px off the bottom |
| Screen | 515 x 220 | inside the frame, offset 45, 28 |
| Design units | 1030 x 440 | all sizes below are 2x; halve for 1080p |

- Use `safeZone` / `pixelGrid` so it holds size at other resolutions and UI scales.
- Frame texture: `phone_wide_cut.png` (2313 x 1037, glass cut out). Glass rect in the texture: 171,105 - 2124,938. Screen draws under the frame.
- Frame was widened by repeating its middle band. Never stretch it.
- CBA setting for position: centre (default) / left / right. Opacity setting 0.4 - 1.

## Layout (top to bottom, 2x units)

| Row | Height | Content |
|---|---|---|
| Status icons | 44 | 8 equal cells |
| Notification line | 32 | count, newest line, time |
| Map | rest (~328) | centred on player, overlays on top |
| Net row | 36 | one cell per net |

### Status icons

Order: NET, MESH, JAM, GPS, DRONES, FIRES, MSG, BATT. Icon + short value, mono 20.

| Icon | Value | Source | Alert |
|---|---|---|---|
| NET | active net number | voice_tfrs active net | - |
| MESH | hops to nearest relay (`2H`) | RF `rf_reach` | red when no path |
| JAM | jam level % | jamming `jamFactor` | cell red when > threshold |
| GPS | OK / DEG / DENIED | RF GPS domain | red when denied |
| DRONES | mine + others (`2+1`) | uas | others in red |
| FIRES | time to next fires event | fires/CAS | - |
| MSG | unread count | messaging | red when > 0 |
| BATT | device battery % | devices | red below 15% |

### Notification line

- Red count box: number in the log not yet seen.
- Newest notification, one line, ellipsis. Priority word coloured (FLASH red).
- Time on the right.
- Source: every notification that would pop upper right (our notify addon, TFAR hints). In tablet mode the upper-right popups are suppressed and go here instead.
- All kept in a log the player can open (separate doc).

### Map

- A map control inside the display. Re-centred on the player every frame; north up.
- Zoomed in so ~50 m radius fits the height. Rings at 25 m and 50 m, labelled.
- Player: large icon, centre, dark pointer = facing.
- Squad: BFT member icons from [DESIGN_BFT_MEMBERS.md](DESIGN_BFT_MEMBERS.md). Hook the same `ghostD_bft_fnc_drawMembers` on this map control's Draw event. Do not write a second draw.
- Extra marks next to a member: red `+` wounded, `★` buddy. Dashed icon = no link to him.
- Other groups: the BFT's NATO marker + callsign, small, not numbered.
- Other small icons: drones (circle + callsign), jammers (red diamond `JAM`), targets (orange diamond `TGT`).
- No compass tape.

### Map overlays

- **Squad list**, top left, 210 wide: `<N> <NAME>` per member, number in team colour, from `ghostD_bft_fnc_memberNumber`. Right side flags: `TX` red (radio), `VOX` magenta (direct voice), `+` wounded, `··` no link, `★` buddy.
- **Who is talking**, top right: dark chip, red dot, `<N> <NAME> on <NET>`. Shows the last speaker for a few seconds.

### Net row

- One rounded cell per net the player can use, equal width, 28 high, 8 radius, 2 px outline.
- Text `<N> <NAME>`: number + name, 12 chars max (name 10).
- Outline green = net OK, red = problem (no reach, jammed, no fill).
- Active net: light fill, dark text.
- Small grey `R` = receive only.
- Only nets you are on are shown: VEH appears in a vehicle, CALL when a call is live or ringing. Cells show name + ear tag (L/B/R), no numbers.
- Numpad 0 / . move the active net left / right. Numpad 1-4 are the device keys F1-F4 (F1 accept call, F2 ear / quick add, F3 mute, F4 decline / hang up). See [DESIGN_VOICE.md](DESIGN_VOICE.md). Frequencies never shown.

## Colours

| Use | Hex |
|---|---|
| Bars | `#201e1d`, notification `#2a2927` |
| Map ground | `#d9d7cf`, grid `rgba(32,30,29,0.1)` |
| Alert | `#ff563c` |
| OK outline | `#43a047` |
| Problem outline | `#e53935` |
| Text light / dim | `#f3f2f2` / `#a9a9a2` |
| Team colours | per DESIGN_BFT_MEMBERS |

Font: IBM Plex Mono in the mockup. In game use the closest Arma font (`EtelkaMonospacePro` or `RobotoCondensed`); check legibility at 1080p - text is 9-10 px tall.

## Behaviour

- Toggle key (CBA keybind) shows/hides. State saved per profile.
- Hidden while in the map screen, in a vehicle with the vehicle tablet open, in the arsenal, dead, or in spectator.
- Only shown when the phone is in the GPS slot. Vanilla GPS minimap is not touched.
- Refresh: map every frame; rows 2 Hz; squad list 1 Hz.

## Build notes

- `RscTitles` display via `cutRsc` so it never takes input.
- Controls: frame picture, 2 bars as structured text, map control, list structured text, net row as N structured text cells.
- Map control in a title display: test that `ctrlMapAnimAdd` centring and Draw EH work there (cTab-style).

## Not in scope

- Notification log, settings fullscreen, apps.
- Side devices (own doc).
