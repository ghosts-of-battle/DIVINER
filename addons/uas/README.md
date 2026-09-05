# UAS

`ghostD_uas`

Patrol drones and the supply that limits them.

**One module is one patrol.** Place a *Ghost - Drone Patrol* module in Eden or in
Zeus, resize it, and it says everything about that patrol: whose drones, how
many, which airframe, and whether a drone that sees somebody calls artillery on
them. Several patrols, several modules. In ghost this addon flew drones over each
ALiVE commander's own objectives with one shared per-side ceiling - there are no
commanders and no objective lists, and a number on the module you placed is a
better answer than a ceiling shared across the map.

**Supply caches** are real crates inside those zones, unmarked and unhinted -
finding them is what the intel economy is for. Kill one and that side's airframe
ceiling drops for a random window: the sky visibly thins, then comes back.
Outages extend rather than stack, so supply raids are raids and not a win button.

**Nobody near, nothing flying.** A patrol exists to be met. One orbiting ground
four kilometres from the nearest player is an airframe, a crew and an AI pilot
simulated for an audience of nobody, so a zone with nobody inside 3.2 km is not
patrolled and the patrols whose audience has left are retired. An empty map costs
nothing.

**A patrol never grows past its own number**, and the supply outage only ever
reduces it: while a side's cache is down every one of its patrols thins to one
airframe, then fills again when the window closes. Outage windows and the cache
count are CBA settings under *Ghosts of Battle > Drones*; everything else about a
patrol is on its own module.

A drone that actually sees a player - `knowsAbout`, not proximity - reports it
down the same path a failed hack takes.

    #ghostuas    ceilings, patrol counts, live outages

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghostD_main`
- `ghostD_common`
- `cba_xeh` _(external)_

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

3 unit classes, 14 functions.

## Eden modules

### Ghost - Enemy Drones

`ghostD_moduleUAS`, category ghostD_modules

Placing this module turns on enemy drones. Without it, the system is off.<br>Airframes Per Side - How many drones a commander flies at once while its supply is intact West / East / Independent Airframes - That side's own ceiling; -1 uses Airframes Per Side, 0 grounds it After A Cache Is Lost - The ceiling while a supply cache is down Outage Min (sec) - Shortest time a destroyed cache holds the ceiling down Outage Max (sec) - Longest time Caches Per Side - Supply caches placed in each commander's area for players to find

<details><summary>12 attributes</summary>

- `baseMax`
- `cachesPerSide`
- `maxEast`
- `maxGuer`
- `maxWest`
- `patrolOver`
- `reducedMax`
- `uavEast`
- `uavGuer`
- `uavWest`
- `windowMax`
- `windowMin`

</details>

## Functions

<details><summary>14</summary>

- `ghostD_uas_fnc_cacheDown`
- `ghostD_uas_fnc_ceilingFor`
- `ghostD_uas_fnc_factionUav`
- `ghostD_uas_fnc_iedDrone`
- `ghostD_uas_fnc_livePatrols`
- `ghostD_uas_fnc_moduleController`
- `ghostD_uas_fnc_placeCaches`
- `ghostD_uas_fnc_planPatrols`
- `ghostD_uas_fnc_playerNear`
- `ghostD_uas_fnc_respondTo`
- `ghostD_uas_fnc_spotSweep`
- `ghostD_uas_fnc_standDown`
- `ghostD_uas_fnc_start`
- `ghostD_uas_fnc_topUp`

</details>
