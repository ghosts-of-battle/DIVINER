# Players

`ghost_players`

The two-argument INFO/WARNING/ERROR/LOG the Roomba scripts were written against, plus the notification colours and the logistics shorthand. Included AFTER ghost's macros so the #undef in there lands on the right definitions.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_diag`
- `cba_xeh` _(external)_

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

14 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_players_enableClanTag` | CHECKBOX | Use squad tags in names |

## Functions

<details><summary>14</summary>

- `ghost_players_fnc_exportRanks`
- `ghost_players_fnc_getClanTag`
- `ghost_players_fnc_getRadioChannel`
- `ghost_players_fnc_getRank`
- `ghost_players_fnc_hasClanTag`
- `ghost_players_fnc_isCurator`
- `ghost_players_fnc_platoonNet`
- `ghost_players_fnc_setActiveRadio`
- `ghost_players_fnc_setRadioChannel`
- `ghost_players_fnc_setRank`
- `ghost_players_fnc_setRankOverride`
- `ghost_players_fnc_unit_getName`
- `ghost_players_fnc_unit_getSquadName`
- `ghost_players_fnc_unit_getVariables`

</details>
