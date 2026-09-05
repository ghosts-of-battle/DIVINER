# Patrol Base

`ghost_patrol_base`

A buildable patrol base anyone can deploy - kit items and props,
a Zeus drop, a name popup and a map marker.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_notify`

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

2 unit classes, 2 weapon/item classes, 12 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_patrol_base_enabled` | CHECKBOX | Enabled |
| `ghost_patrol_base_maxCount` | SLIDER | Max patrol bases |
| `ghost_patrol_base_kitCount` | SLIDER | Kits required |
| `ghost_patrol_base_kitRange` | SLIDER | Kit gather range (m) |
| `ghost_patrol_base_beaconClass` | EDITBOX | Base object |
| `ghost_patrol_base_onDeployCode` | EDITBOX | On-deploy init (SQF) |
| `ghost_patrol_base_onUndeployCode` | EDITBOX | On-undeploy init (SQF) |

## Functions

<details><summary>12</summary>

- `ghost_patrol_base_fnc_addUnbuildAction`
- `ghost_patrol_base_fnc_addZeusModule`
- `ghost_patrol_base_fnc_canPickupKit`
- `ghost_patrol_base_fnc_countKits`
- `ghost_patrol_base_fnc_establishPatrolBase`
- `ghost_patrol_base_fnc_initPlayer`
- `ghost_patrol_base_fnc_kitPickup`
- `ghost_patrol_base_fnc_promptName`
- `ghost_patrol_base_fnc_runHook`
- `ghost_patrol_base_fnc_serverBuild`
- `ghost_patrol_base_fnc_serverUnbuild`
- `ghost_patrol_base_fnc_spawnKits`

</details>
