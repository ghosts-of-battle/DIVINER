# BFT

`ghost_bft`

Blue Force Tracking. Every group that has its tracker on draws a marker on the
map for everyone entitled to see it, updated on a server-time tick so two people
looking at the same map see the same picture.

Entitlement is a NETWORK, not a side. A group transmits on a list of codes and
listens on another; a marker is drawn when one of the viewer's codes appears in
the target's transmit list. A group nobody has configured transmits on its own
side's name, so out of the box it behaves like a side tracker - and the moment a
mission calls `ghost_bft_fnc_networkAdd`, that group is off the side net and on
whatever nets it was given. Faded markers are the other half of that contract:
they mean you can see them and they cannot see you.

Position is deliberately not the truth. Tracking picks where the group is - the
leader, or an average pulled towards the rest of the group - and trailing decides
how far behind that the marker is allowed to lag, so a tracker reads like a radio
report rather than a live feed. All of it is drawn locally off group variables:
the update rate costs nothing on the network.

**The tracker switch is a property of the group, not of the man**, and that is
right — a group is what gets a marker — but it means the answer follows the group
you are in. Move into another group, get given your own team, slot somewhere
else, and you arrive in a group nobody has switched on: your marker vanishes and
the tracker looks broken while doing exactly what it was told. `autoEnable` runs
on CBA's `group` and `unit` player events as well as at start, so a group with no
answer gets the default one. A group whose visibility somebody *has* set — a
mission init field, its leader through the map menu, an admin — keeps it.

Group leaders own their own marker through ACE self interaction with the map
open - name, icon, colour, tracker on or off. A logged-in admin sees every group
regardless of nets, tracker state or side obfuscation, and drives the whole
system from chat with `#ghost bft.*`; `#ghost help` lists them.

Not ghost's design. This is **Jacco Douma's** BFT, ported over from Team
Collaboration Aides - see Credits.

## Admin commands

| Command | What it does |
|---|---|
| `#ghost bft.list [group\|side\|all]` | Tracker state, icon, colour and nets of every matching group |
| `#ghost bft.on <group>` / `bft.off <group>` | Force a group's tracker on or off |
| `#ghost bft.name <group> <new name>` | Rename a group |
| `#ghost bft.icon <group> <icon>` | Set its marker icon |
| `#ghost bft.color <group> <class>` | Set its marker colour, a `CfgMarkerColors` class |
| `#ghost bft.net add\|remove\|clear <group> [net]` | Nets the group transmits on |
| `#ghost bft.obs add\|remove\|clear <group> [net]` | Nets the group only listens to |
| `#ghost bft.view` | Toggle your own god view, to see what the players see |

The group token is a fragment of a call sign - `alpha` finds `B Alpha 1-1` - or
a side name (`west`, `east`, `guer`, `civ`), or `all`.

## Mission maker

Group variables, all public, all safe to set from an init field:

- `ghost_bft_visible` BOOL - tracker on
- `ghost_bft_type` STRING - `CfgMarkers` icon suffix, e.g. `"recon"`
- `ghost_bft_color` STRING - `CfgMarkerColors` class
- `ghost_bft_encryptCodes` ARRAY - nets it transmits on
- `ghost_bft_decryptCodes` ARRAY - nets it only listens to

The TCA names (`BFT_groupMarker_visible`, `_type`, `_color`) are NOT read here -
a mission written against TCA has to be renamed to these.

## Credits

**Jacco Douma** wrote this. The original is the `TCA_bft` addon of
[Team Collaboration Aides](https://github.com/Jaccodouma/TCA-A3) (TCA, by Jacco
& Hightower) - the tracker loop, the weighted-average and trailing position
model, the encrypt/decrypt network idea, the ACE map settings menu and every icon
in [ui/icons/](ui/icons/) are all theirs, carried over as they were.

TCA ships no licence file. It is here with attribution and nothing more: ask
before redistributing it further.

Ghost's part is the port and the plumbing around it:

- re-prefixed to `ghost_bft` on ghost's macros, settings categories and the
  `initSettings.inc.sqf` layout
- group variables renamed `BFT_groupMarker_*` -> `ghost_bft_*`
- `TCA_BFT_Interact_Icons` config class dropped; the icons are addressed
  directly with `QPATHTOF`
- the menu moved off the player object onto `CAManBase` with inheritance, so it
  survives respawn and unit switching
- markers named by index rather than by call sign - two groups can share a
  `groupId`, and `createMarkerLocal` returns `""` on a name already taken
- `mapSettings` was declared but never read upstream; it gates the menu here
- the unreachable `projected` trailing mode dropped
- the admin surface: god view, `#ghost bft.*`, gated on `ghost_common_isAdmin`

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `ace_interact_menu` _(external)_
- `ace_common` _(external)_
- `cba_xeh` _(external)_

## Ships

21 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_bft_enabled` | CHECKBOX | Enable group markers |
| `ghost_bft_autoEnable` | LIST | Auto enable for |
| `ghost_bft_memberMarkers` | LIST | Member markers |
| `ghost_bft_hideOwnGroup` | CHECKBOX | Hide own group marker |
| `ghost_bft_showVirtual` | CHECKBOX | Show virtual friendlies |
| `ghost_bft_updateDelay` | SLIDER | Update delay |
| `ghost_bft_markerShape` | LIST | Marker shape |
| `ghost_bft_trackingMode` | LIST | Position: tracking mode |
| `ghost_bft_trailingMode` | LIST | Position: trailing mode |
| `ghost_bft_trailingCount` | SLIDER | Position: trailing count |
| `ghost_bft_trailingWeight` | SLIDER | Position: trailing weight |
| `ghost_bft_mapSettings` | CHECKBOX | Map settings menu |
| `ghost_bft_nameOptions` | EDITBOX | Group name options |
| `ghost_bft_preferredIcons` | EDITBOX | Preferred icons |
| `ghost_bft_iconsBlacklist` | EDITBOX | Icons blacklist |
| `ghost_bft_preferredColors` | EDITBOX | Preferred colors |
| `ghost_bft_colorsBlacklist` | EDITBOX | Colors blacklist |
| `ghost_bft_fuzzOtherSides` | CHECKBOX | Obfuscate other sides |
| `ghost_bft_adminGodView` | CHECKBOX | Admin sees everything |

## Functions

<details><summary>21</summary>

- `ghost_bft_fnc_autoEnable`
- `ghost_bft_fnc_describeGroup`
- `ghost_bft_fnc_draw`
- `ghost_bft_fnc_drawMembers`
- `ghost_bft_fnc_findGroups`
- `ghost_bft_fnc_getGroupMarkerShape`
- `ghost_bft_fnc_getGroupPosition`
- `ghost_bft_fnc_init`
- `ghost_bft_fnc_isAdmin`
- `ghost_bft_fnc_loop`
- `ghost_bft_fnc_networkAdd`
- `ghost_bft_fnc_networkAddObserver`
- `ghost_bft_fnc_networkClear`
- `ghost_bft_fnc_networkClearObserved`
- `ghost_bft_fnc_networkRemove`
- `ghost_bft_fnc_networkRemoveObserver`
- `ghost_bft_fnc_remove`
- `ghost_bft_fnc_settingsAdd`
- `ghost_bft_fnc_settingsColors`
- `ghost_bft_fnc_settingsIcons`
- `ghost_bft_fnc_settingsNames`

</details>
