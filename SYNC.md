# Sync record

DIVINER was copied from **ghost** and re-prefixed `ghost` -> `ghostD`.

| | |
|---|---|
| Source | `ghosts-of-battle/ghost` |
| Commit | `c47d7484b917b58b84d9eebee140f34b5f53d45b` |
| Date | 2026-09-03 |
| Addons | 69 |

## What came over

The 61 addons ticked on the manifest, plus:

| Addon | Why |
|---|---|
| `diag` | dependency of `groups`, `vehicle`, `systems` |
| `main` | every addon requires it |
| `adapter_alive` | `jamming` declares it in `requiredAddons`; **temporary**, see below |
| `systems` | 65 hard `EFUNC` calls from `mission`, `vehicle`, `zenmodules` |
| `logistics` | 47 hard `EFUNC` calls from `vehicle`, `zenmodules`, `diag` |
| `players` | 14 hard `EFUNC` calls from `groups`, `gear`, `zenmodules` |
| `init` | `loadConfigs.sqf` calls `ghostD_init_fnc_missionConfigsReady` - without it the mission never hands its configs over |
| `aps` | asked for; the `hud` APS widget reads `ghostD_aps_*` and had nothing to read |

The last four were not on the ticked list. They are not optional: the addons
that were ticked call them directly, and a missing `EFUNC` target resolves to
nothing rather than erroring.

## Added in DIVINER

Not in `ghost`; do not port back without deciding to.

| Addon / change | What |
|---|---|
| `pac` | TAC//PAC personnel - structure in mission config (`CfgGFA_PAC`), player data in the server profile, admin page off the console, tacpad app and tile, attendance and op windows, backups to the .rpt, OPORD to C2 messaging. Wiki: `TAC-PAC`, `config_pac`. Touches `groups` (one guarded line in `fnc_setupPlayer`), `gear` (one in `fnc_saveLoadout`), `tacpad` (`pac:` autoFill in `fnc_composeCard`), `adminpanel` (a button), `tacpad_apps` (the tile). |
| vehicle spawner removed | `fnc_vehicleSpawner` and the mission's `config_vehicleSpawner.hpp` are gone; the motorpool is the only vehicle-issuing screen. `ghost` still has both. |

Every entry above is written up in `CHANGES.md` with a sync verdict.

## Outstanding

- **`airdefence`, `leaders`, `reaction` and `w28fixes`** are named by guarded
  references in code that came over and do not exist here. `ghost` has three of
  them - `airdefence` it does not. Every reference degrades rather than breaks,
  but LOCATE AA has no producer, TRACE NETWORK has no producer, and the hack
  fail roll never fires.

- **`main_menu`** stays as it is; it needs a wiki page on how to change its
  graphics, because it draws before any mission exists and cannot read mission
  config.
- **`media`** came over whole (285 MB) and wants pruning.
- **Tech debt pass** on `common` and `main`.

## Dropped

- **The hackphone and soldiertab models.** Their texture paths were baked into
  the `.p3d` at the old prefix, and a binary model cannot be re-pathed by a text
  rewrite, so both rendered untextured. The two items - Intrusion Tablet and
  Signal Scanner - are still here and still work; without a `model=` they
  inherit `ACE_ItemCore`'s, which is a real model that ships with ACE. The
  inventory icons are still ours.
- **`GHOST_Apap`**, ghost's painkiller. Three bags issued it - the Boo Boo Bag,
  the Medic Bag and the Trauma Kit - and DIVINER defines it nowhere, so it
  arrived as nothing at all. It is out of the shipped bag contents. A ghost
  server that has the class can put it back without a rebuild now that the
  contents are settings: add `GHOST_Apap:4` to the bag's list in Addon Options.
- **`loading`, the whole addon.** DIVINER shows Arma's own loading screen.
  `ghost` keeps its copy - and with it the 23 background images that cannot be
  shipped, the "bunny" background class that resolves to nothing for a month
  every Easter, and the seasonal logo switch whose four branches all set the
  same picture. Dropping the addon here fixed none of that for ghost; see
  CHANGES.md, where those entries are still marked to port.
- **ALiVE, and `adapter_alive` with it.** The adapter was the one addon allowed
  to know ALiVE existed; nine addons asked it for commanders, TAORs, objectives,
  profiles, combat support, the intelligence model and the campaign save. All
  nine were taken off it and the addon is deleted - 48 files, 38 functions. What
  replaced each is in CHANGES.md; the shape of it is that a mission maker or a
  Zeus now places what the simulation used to decide. `ghost` keeps ALiVE, so
  none of that ports as-is.
- **cTab, entirely.** `include/cTab`, the `/tacmap` marker exemption and the
  "use a cTab" wording in `initnc_mapDrawing.sqf`, `ItemcTab` from the
  framework arsenal, and the `htmlLoad` whitelist from `description.ext`.
- **`difficulty`, the whole addon.** It set the game's default difficulty preset
  (`Difficulty_GHOST`), the global `CfgAISkill` coefficients and a `CfgSurfaces`
  `Default` override - a `ghost` addon doing `ghost` things, and outside
  DIVINER's scope, which is TAC//PAC, messaging and UI. `ghost` keeps it. No
  addon here named `ghostD_difficulty` in `requiredAddons`, so nothing broke
  with it gone. The one consequence: DIVINER ships no `defaultPreset` any more,
  so `difficultyOption "mapContent"` is whatever the host runs rather than a
  forced `0` - which `addons/bft/functions/fnc_draw.sqf` already asks about at
  runtime rather than assuming. See CHANGES.md.

## References left pointing at ghost

These are guarded (`isNil` checks and `getVariable` defaults), so they degrade
rather than break, but they name addons that did not come over:

| Names | Used by | Effect |
|---|---|---|
| `ghost_leaders_*` | `hacking` | leader intel products unavailable |
| `ghost_reaction_*` | `hacking` | no reaction roll on a hack |
| `ghost_vs17_vs17` | `equipment` | one arsenal item silently absent |

**The wiki no longer points at `ghost` at all** (2026-09-05, before its first
publish to GitHub): `_Sidebar` says DIVINER Wiki, `_Footer`, `Home` and
`Installation` link the DIVINER and 2040 repositories, and the ALiVE-forwarder
passages (`Messaging-Deck`, `config_messaging`, `Cross-File-Contracts`,
`Intel-Packages`) and the cTab-whitelist wording (`description-ext`) are
rewritten to what DIVINER actually does. **Do not port those wiki edits back**:
`ghost` still has ALiVE and its wiki still describes the forwarder. The wiki is
published with `tools/wiki/publish_wiki.sh`.

A second pass the same day, after the first publish, renamed every mod name the
pages cite to the DIVINER prefix: the 23 `ghost_<addon>_fnc_*` functions (all
verified to exist under `addons/`), the `init` addon (`ghostD_init`) and the
CBA setting `ghostD_Settings_setAiSystemDifficulty`, plus the product name on
`Home`, `Installation` and `Roles`. Left as they are on purpose: the vehicle
class names `ghost_US_JTF_tna_*` and the callsign `ghost_6` (not mod
identifiers), and the Eden module name **Ghost - Intel Package**, because that
is what `addons/hacking/CfgVehicles.hpp` still declares - rename the module and
the wiki together if that changes.


## The prefix

`PREFIX ghost` -> `ghostD` in `addons/main/script_mod.hpp` does most of it: every
`GVAR`, `FUNC`, `QGVAR` and `EFUNC` macro derives from it. On top of that:

| What | Count |
|---|---|
| `$PBOPREFIX$` files | 69 |
| `\z\ghostddons\` include paths | 303 |
| `"ghost_<shipping>"` literals | all of them; zero left |
| Eden module classes, `units[]` entries and the 12-character prefix check in `common` | 15 + 11 + 1 |

**Mission-side globals stay `ghost_`.** `ghost_missionConfig_*`, `ghost_radio_*`
and `GHOST_Nets` are the contract between a mission and the mod, and the
framework mission sets them under those names. Both sides agree, so both sides
were left alone - and it means the framework mission also runs against ghost.
