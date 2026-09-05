# Common

`ghost_common`

The shared floor everything else stands on.

Three things here matter more than the rest. The THREAT BOARD is where every
ghost sensor files what it saw, as a belief carrying its own doubt - position,
error, and confidence that decays - so N sensors and M shooters cost N+M wires
instead of N times M. The ALERT BUS is how any system tells players what it just
did to them, because a system you cannot perceive is indistinguishable from bad
luck. And findSite is the placement service every auto-sited asset goes through,
so "radar in a lake" is solved once.

Also hosts Ghost - Core and Ghost - Enemy, the two module classes that are facts
about a mission rather than about one feature.

## The admin surface

`#ghost <command>` in any chat channel. Every addon registers its own commands
through `addDebugCommand`; `#ghost help` lists what is loaded. The message is
swallowed — it is never broadcast, and a non-admin typing the same thing gets no
reply and no hint that the surface is there.

**Who is an admin.** Anyone who has `#login`-ed, *and* the machine running the
server — a host or a single player is already the admin and has nothing to log in
to. That second half was missing, and `#login` waits on
`serverCommandAvailable "#kick"`, which never becomes true in single player: on a
dev box the flag was never set, so every `#ghost` command was silently swallowed.
Because the surface is deliberately silent to non-admins, that looks exactly like
a broken mod rather than a permission you have not got.

## The pre-spawn gate

`taorGate` answers one question — *may this side put something at this
position?* — for every system that spawns at a computed position, because
wrong-side sightings kept coming back one addon at a time and the answer belongs
in one place.

The rule has two halves, and which half applies depends on whether the side
declared any ground of its own:

| | |
|---|---|
| **has a TAOR** | inside it, minus its own blacklist markers. Overlaps with
 other sides' TAORs are *kept* — an insurgency draws the insurgents' ground over
 the players' on purpose, and subtracting it leaves them nowhere to operate |
| **has none** | the whole map, minus everybody else's hostile ground. This is
 the hole the gate was written to close: an undeclared side — usually the
 players' — used to be waved through anywhere, red TAOR included |

A refusal names the caller in the RPT, so the log says which system held its
fire and where. Bulk callers filtering a whole list pass `_quiet` and report a
count instead.

`sideOfFaction` is the other half of `sideFromText`: a faction CLASS
(`OPF_T_F`) turned back into a side, read from `CfgFactionClasses`. ALiVE's
modules hold factions where this mod's modules hold side names, and telling
whose ground is whose starts there.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`

## Ships

53 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_common_isrVariable` | EDITBOX | ISR unit variable |
| `ghost_common_boardDebug` | CHECKBOX | Threat Board Debug |

## Functions

<details><summary>53</summary>

- `ghost_common_fnc_addDebugCommand`
- `ghost_common_fnc_addItem`
- `ghost_common_fnc_addMultipleParachutesToObject`
- `ghost_common_fnc_addParachuteToObject`
- `ghost_common_fnc_alert`
- `ghost_common_fnc_bloodType`
- `ghost_common_fnc_conditionalPFEH`
- `ghost_common_fnc_contactBest`
- `ghost_common_fnc_contactGet`
- `ghost_common_fnc_contactReport`
- `ghost_common_fnc_createPlayerMarker`
- `ghost_common_fnc_debugCommand`
- `ghost_common_fnc_debugReply`
- `ghost_common_fnc_easterDate`
- `ghost_common_fnc_edenClassPickLoad`
- `ghost_common_fnc_edenClassPickSave`
- `ghost_common_fnc_edenDroneFactionLoad`
- `ghost_common_fnc_edenDroneFactionSave`
- `ghost_common_fnc_ensureSafeLanding`
- `ghost_common_fnc_findSite`
- `ghost_common_fnc_fireBarrage`
- `ghost_common_fnc_hudMove`
- `ghost_common_fnc_hudPos`
- `ghost_common_fnc_hudSetPos`
- `ghost_common_fnc_isISR`
- `ghost_common_fnc_isOverWater`
- `ghost_common_fnc_isUnconscious`
- `ghost_common_fnc_lambsOff`
- `ghost_common_fnc_listClasses`
- `ghost_common_fnc_listFactionDrones`
- `ghost_common_fnc_listGroupsWithPlayers`
- `ghost_common_fnc_modal`
- `ghost_common_fnc_objectFromString`
- `ghost_common_fnc_onAlert`
- `ghost_common_fnc_onModalClose`
- `ghost_common_fnc_onModalOpen`
- `ghost_common_fnc_playerSides`
- `ghost_common_fnc_putContainerInVehicle`
- `ghost_common_fnc_readConfigToNamespace`
- `ghost_common_fnc_realisticGrid`
- `ghost_common_fnc_renderIntelCircle`
- `ghost_common_fnc_renderIntelIcons`
- `ghost_common_fnc_returnDepth`
- `ghost_common_fnc_runAfterSettingsInit`
- `ghost_common_fnc_scatterPosition`
- `ghost_common_fnc_setCtrlHeightToText`
- `ghost_common_fnc_setDatalink`
- `ghost_common_fnc_sideFromText`
- `ghost_common_fnc_sideOfFaction`
- `ghost_common_fnc_sideToText`
- `ghost_common_fnc_sortGroupsBySide`
- `ghost_common_fnc_taorGate`
- `ghost_common_fnc_uiSquare`

</details>
