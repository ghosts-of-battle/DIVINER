# Players

`ghost_players`

The two-argument INFO/WARNING/ERROR/LOG the Roomba scripts were written against, plus the notification colours and the logistics shorthand. Included AFTER ghost's macros so the #undef in there lands on the right definitions.

## Base-game voice (VON)

Added 2026-10-20. When neither TFAR nor ACRE is loaded (`ghostD_common_von`,
decided once in common's preInit), the radio plan's `vonNets` become custom
radio channels: `vonApply` (server) makes or relabels one channel per net,
`vonSync` (server) reconciles who is on each from the players' squad names,
roles and PAC skills (first matching net of each kind; 2026-10-21) -
raised by the clients at spawn, respawn, squad change and JIP, after a
disconnect, and every 10 s - and `vonClient` (each client) sets which engine
channels may carry voice (`vonSide`, `vonCommand`, `vonGlobalAdminsOnly`;
Group, Vehicle, Direct on). `vonState` is the radio readout's answer: the
squad's team net (`vonTeamNets`, else the squad name) on the Group channel.
With no `vonNets` the plan is one C2 net of every squad leader and the engine
channels are left alone. With TFAR or ACRE loaded the postInit returns at once.

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
