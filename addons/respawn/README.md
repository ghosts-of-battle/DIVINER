# Respawn

`ghost_respawn`

Respawn handling, including the force-respawn call a trigger can make:

    [west] call ghost_respawn_fnc_forceRespawn;

Only the dead are affected, which is why it is safe to fire from a trigger that
may run more than once.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_common`
- `ghost_notify`

## Ships

9 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_respawn_enabled` | CHECKBOX | Enable respawn |
| `ghost_respawn_time` | SLIDER | Respawn delay |

## Functions

<details><summary>9</summary>

- `ghost_respawn_fnc_addZeusModules`
- `ghost_respawn_fnc_adjustTime`
- `ghost_respawn_fnc_adjustTimeLocal`
- `ghost_respawn_fnc_disable`
- `ghost_respawn_fnc_enable`
- `ghost_respawn_fnc_forceRespawn`
- `ghost_respawn_fnc_onPlayerKilled`
- `ghost_respawn_fnc_onPlayerRespawn`
- `ghost_respawn_fnc_toggle`

</details>
