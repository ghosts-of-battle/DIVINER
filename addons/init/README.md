# Init

`ghost_init`

The two-argument INFO/WARNING/ERROR/LOG the Roomba scripts were written against, plus the notification colours and the logistics shorthand. Included AFTER ghost's macros so the #undef in there lands on the right definitions.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_diag`
- `cba_xeh` _(external)_

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

13 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_init_QEGVAR(Settings,setMissionType)` | LIST | Mission Type |
| `ghost_init_QEGVAR(Settings,setAiSystemDifficulty)` | LIST | AI Setting |
| `ghost_init_QEGVAR(Settings,enableRadios)` | CHECKBOX | Enable |
| `ghost_init_QEGVAR(Settings,setRadio)` | CHECKBOX | Squad Radio Channels (ACRE) |
| `ghost_init_QEGVAR(Settings,showDiaryRecords)` | CHECKBOX | Documents |
| `ghost_init_QEGVAR(Settings,setPlayerRank)` | CHECKBOX | Rank |
| `ghost_init_QEGVAR(Settings,allowInsigniaApplication)` | CHECKBOX | Insignia |
| `ghost_init_QEGVAR(Settings,addEarplugs)` | CHECKBOX | Apply Earplugs |
| `ghost_init_QEGVAR(Settings,enableStagingSystem)` | CHECKBOX | Enable |
| `ghost_init_QEGVAR(Settings,enableVehicleSystem)` | CHECKBOX | Enable |
| `ghost_init_QEGVAR(Settings,enableVehiclePylon)` | CHECKBOX | Pylon |
| `ghost_init_QEGVAR(Settings,enableVehicleInventory)` | CHECKBOX | Inventory |
| `ghost_init_QEGVAR(Settings,enableVehicleRadios)` | CHECKBOX | Radio |
| `ghost_init_QEGVAR(Settings,vehicleFactions)` | EDITBOX | Factions |
| `ghost_init_QEGVAR(Settings,jumpSimulation)` | LIST | Simulation Type |
| `ghost_init_QEGVAR(Settings,jumpSimulationNVG)` | CHECKBOX | Include Night Vision Googles |
| `ghost_init_QEGVAR(Settings,jumpSimulationGlasses)` | CHECKBOX | Include Non-combat Googles |
| `ghost_init_QEGVAR(Settings,jumpSimulationHat)` | CHECKBOX | Include Non-combat Headgear |

## Functions

<details><summary>13</summary>

- `ghost_init_fnc_chatCommands`
- `ghost_init_fnc_diary`
- `ghost_init_fnc_eventHandlers`
- `ghost_init_fnc_logistics`
- `ghost_init_fnc_mapDrawing`
- `ghost_init_fnc_message`
- `ghost_init_fnc_missionConfigsReady`
- `ghost_init_fnc_playerpost`
- `ghost_init_fnc_pylons`
- `ghost_init_fnc_skillAdjustment`
- `ghost_init_fnc_staging`
- `ghost_init_fnc_vehicle`
- `ghost_init_fnc_zenModuels`

</details>
