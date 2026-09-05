# Back To Game

`ghost_back_to_game`

Reconnect handling: a player who drops and returns is offered
their position, loadout, vehicle and group back rather than starting over.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`

## Ships

11 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_back_to_game_enableAddon` | CHECKBOX | Enable Back To Game |
| `ghost_back_to_game_teleportToLeader` | CHECKBOX | Teleport to leader |
| `ghost_back_to_game_teleportToVehicle` | CHECKBOX | Teleport to vehicle |
| `ghost_back_to_game_removeBody` | CHECKBOX | Remove body |

## Functions

<details><summary>11</summary>

- `ghost_back_to_game_fnc_addHandler`
- `ghost_back_to_game_fnc_deletePlayerData`
- `ghost_back_to_game_fnc_dialogConfirm`
- `ghost_back_to_game_fnc_dialogReject`
- `ghost_back_to_game_fnc_getPlayerData`
- `ghost_back_to_game_fnc_handleConnected`
- `ghost_back_to_game_fnc_handleDisconnected`
- `ghost_back_to_game_fnc_handleTeleport`
- `ghost_back_to_game_fnc_hasDisconnected`
- `ghost_back_to_game_fnc_savePlayerData`
- `ghost_back_to_game_fnc_teleportPlayer`

</details>
