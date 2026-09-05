# Hacking

`ghost_hacking`

The intel economy. Towers and enemy handsets are things you can
break into, and what you get out is one product of your choosing.

Every product is a SNAPSHOT drawn by one renderer - a circle that was true when
it was earned, never a live feed - so products can differ in what they know and
never in how they look. That matters more than it sounds: it is what makes a
poisoned product indistinguishable from an honest one, by design.

The tightening ladder is the other half. Repeat hacks on one target step the
circle down a size, and the throw is cached per tier so repetition CONFIRMS
without ever narrowing - which closes the intersect-three-circles exploit while
leaving cross-tier overlap working as intended.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ace_interact_menu` _(external)_
- `ace_common` _(external)_
- `ghost_notify`
- `ghost_common`
- `cba_xeh` _(external)_

## Ships

1 unit class, 6 weapon/item classes, 60 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_hacking_enabled` | CHECKBOX | Enable Hacking |
| `ghost_hacking_condition` | EDITBOX | Hack Condition |
| `ghost_hacking_towerClasses` | EDITBOX | Hackable Tower Classes |
| `ghost_hacking_droneClasses` | EDITBOX | Downable Drone Classes |
| `ghost_hacking_requireISR` | CHECKBOX | Require ISR operator |
| `ghost_hacking_scannerVariable` | EDITBOX | Scanner Variable |
| `ghost_hacking_alarmVolume` | SLIDER | Scanner Alarm Volume |
| `ghost_hacking_remoteEnable` | CHECKBOX | Remote Unit Hack |
| `ghost_hacking_remoteRange` | SLIDER | Remote Hack Range (m) |
| `ghost_hacking_towerTaor` | EDITBOX | Tower TAOR Marker(s) |
| `ghost_hacking_phonePct` | SLIDER | Enemy Cell Phone Carriers (%) |
| `ghost_hacking_perHint` | SLIDER | Deposits per Hint |
| `ghost_hacking_docChance` | SLIDER | Documents on Bodies (%) |
| `ghost_hacking_netFailStep` | SLIDER | Extra detection per net |
| `ghost_hacking_netFailWindow` | SLIDER | Detection memory |
| `ghost_hacking_netTargets` | LIST | Hackable nets |

## Functions

<details><summary>60</summary>

- `ghost_hacking_fnc_alarmAdd`
- `ghost_hacking_fnc_alarmArm`
- `ghost_hacking_fnc_alarmRing`
- `ghost_hacking_fnc_alarmSilence`
- `ghost_hacking_fnc_canDeposit`
- `ghost_hacking_fnc_canHack`
- `ghost_hacking_fnc_canPlaceDrop`
- `ghost_hacking_fnc_canSearch`
- `ghost_hacking_fnc_depositIntel`
- `ghost_hacking_fnc_droneTag`
- `ghost_hacking_fnc_hackComplete`
- `ghost_hacking_fnc_hackSetting`
- `ghost_hacking_fnc_hasPhone`
- `ghost_hacking_fnc_hasRadio`
- `ghost_hacking_fnc_hasScanner`
- `ghost_hacking_fnc_intelHint`
- `ghost_hacking_fnc_intelId`
- `ghost_hacking_fnc_intelOptions`
- `ghost_hacking_fnc_ladderCircle`
- `ghost_hacking_fnc_nearestDrone`
- `ghost_hacking_fnc_nearestTower`
- `ghost_hacking_fnc_nearestWreck`
- `ghost_hacking_fnc_netBroken`
- `ghost_hacking_fnc_netFailChance`
- `ghost_hacking_fnc_onBodyKilled`
- `ghost_hacking_fnc_packDrop`
- `ghost_hacking_fnc_placeDrop`
- `ghost_hacking_fnc_popWitness`
- `ghost_hacking_fnc_productInstallation`
- `ghost_hacking_fnc_productLocateAA`
- `ghost_hacking_fnc_productLocateArty`
- `ghost_hacking_fnc_productLocateCamp`
- `ghost_hacking_fnc_productLocateCoastal`
- `ghost_hacking_fnc_productLocateHub`
- `ghost_hacking_fnc_productLocateRadar`
- `ghost_hacking_fnc_remoteHackFail`
- `ghost_hacking_fnc_renderProduct`
- `ghost_hacking_fnc_scanDevices`
- `ghost_hacking_fnc_scannerAlarm`
- `ghost_hacking_fnc_scannerClose`
- `ghost_hacking_fnc_scannerLayout`
- `ghost_hacking_fnc_scannerRead`
- `ghost_hacking_fnc_scannerTick`
- `ghost_hacking_fnc_scannerTimer`
- `ghost_hacking_fnc_scannerToggle`
- `ghost_hacking_fnc_searchBody`
- `ghost_hacking_fnc_serverPick`
- `ghost_hacking_fnc_tabletAction`
- `ghost_hacking_fnc_tabletAdvance`
- `ghost_hacking_fnc_tabletClosed`
- `ghost_hacking_fnc_tabletInRange`
- `ghost_hacking_fnc_tabletLayout`
- `ghost_hacking_fnc_tabletOpen`
- `ghost_hacking_fnc_tabletRefresh`
- `ghost_hacking_fnc_tabletSelectDevice`
- `ghost_hacking_fnc_tabletSelectIntel`
- `ghost_hacking_fnc_tabletTick`
- `ghost_hacking_fnc_taorType`
- `ghost_hacking_fnc_towerInTaor`
- `ghost_hacking_fnc_towersInRange`

</details>
