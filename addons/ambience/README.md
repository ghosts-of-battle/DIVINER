# Ambience

`ghost_ambience`

Ambient war: every few minutes a short artillery stonk lands on a building near a player inside the named markers. It never targets the players themselves - the distance band keeps it off their heads - and every impact area is announced on the alert bus first.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `cba_xeh` _(external)_

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

2 unit classes, 4 functions.

## Eden modules

### Ghost - Ambient Shelling

`ghost_moduleAmbientShelling`, category ghost_modules

Ambient war: every few minutes a short artillery stonk lands on a building near a player inside the named markers. It never targets the players themselves - the distance band keeps it off their heads - and every impact area is announced on the alert bus first.

<details><summary>8 attributes</summary>

- `bandMax`
- `bandMin`
- `intervalMax`
- `intervalMin`
- `markers`
- `roundsMax`
- `roundsMin`
- `shellClasses`

</details>

### Ghost - Ambient Kamikaze Drones

`ghost_moduleAmbientKamikaze`, category ghost_modules

Ambient war: every few minutes a one-way drone flies in and dives on a building near a player inside the named markers. It is a real aircraft on the map - audible, visible and killable, and shooting it down is the counterplay. It never dives at the players themselves.

<details><summary>7 attributes</summary>

- `bandMax`
- `bandMin`
- `diveSpeed`
- `droneClasses`
- `intervalMax`
- `intervalMin`
- `markers`

</details>

## Functions

<details><summary>4</summary>

- `ghost_ambience_fnc_kamikazeModule`
- `ghost_ambience_fnc_kamikazeRun`
- `ghost_ambience_fnc_pickBuilding`
- `ghost_ambience_fnc_shellingModule`

</details>
