# Repair

`ghost_repair`

Keeps synced objects serviceable: rearmed, refuelled, repaired and
optionally rebuilt.

A snapshot of each object is taken at mission start while it is still intact,
and that is what a respawn is rebuilt from - so it comes back where it was
placed, not where the blast left it. Driven by the Ghost - Maintenance module.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `cba_xeh` _(external)_

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

1 unit class, 3 functions.

## Eden modules

### Timed Repair

`ghost_moduleTimedRepair`, category ghost_modules

Keeps everything synchronised to it serviceable: rearmed, refuelled and repaired on a timer, and optionally rebuilt if destroyed. A snapshot of each object is taken at mission start while it is still intact, and that is what a respawn is rebuilt from - so a respawned object comes back where it was placed, not where the blast left it.

<details><summary>8 attributes</summary>

- `debug`
- `interval`
- `rearm`
- `refuel`
- `repair_amount`
- `replace_crew`
- `respawn`
- `respawn_delay`

</details>

## Functions

<details><summary>3</summary>

- `ghost_repair_fnc_moduleController`
- `ghost_repair_fnc_respawnOne`
- `ghost_repair_fnc_tick`

</details>
