# DIVINER

**DIVINER** is the mission framework used by Ghosts of Battle. It ships the
role-selection screen, the tablet suite, the arsenal and loadout system, the
radio programmer, the threaded messaging system, the motorpool and the
battlefield systems — as a mod. Your mission supplies the roster, the gear and
the comms plan, as configuration. It is a two-part system: this mod, and a
mission built on it from the
[2040 repository](https://github.com/ghosts-of-battle/2040).

The rule the whole framework is built on:

> **The mission is configuration. The code is the mod.**

If you find yourself writing SQF to add a squad, a role or a weapon — stop.
There is a config for it, and changing it needs no mod rebuild.

---

## Start here

| | |
|---|---|
| [Installation](Installation) | What you need loaded, and in what order |
| [Mission Setup](Mission-Setup) | The smallest mission that boots, then build it up |
| [How Config Loads](How-Config-Loads) | The two paths in — and why some files are never read |
| [Config Reference](Config-Reference) | Every config file, what it declares, who reads it |
| [Quick start: the database](Quick-Start-Database) | MongoDB Atlas in twenty minutes: the cluster, the mission, the setting, the seed |
| [Atlas IP allowlist](Atlas-IP-Allowlist) | Letting your server's IP reach the cluster, and why the whole internet is the wrong answer |
| [FAQ](FAQ) | How do I add an op order, a squad, a role, promote someone, count attendance ... |

## Building a task force

| | |
|---|---|
| [Roster and Squads](Roster-and-Squads) | `Dynamic_Groups` — elements, platoon tabs, radio nets |
| [Roles](Roles) | One class per file: loadout, traits, nets, tiles |
| [Rank Gates](Rank-Gates) | `Dynamic_Ranks` and `Role_Access` |

## Comms

| | |
|---|---|
| [Nets](Nets) | The mailboxes of TAC//MSG, the threaded messaging system, and who may read each one |
| [Comms Plan](Comms-Plan) | ACRE and TFAR channel plans, SR / MR / LR |

## Gear and vehicles

| | |
|---|---|
| [Arsenal](Arsenal) | The three merged sources, and the array-name contract |
| [Motorpool and Vehicles](Motorpool-and-Vehicles) | Pools, paints, pylons, radar |

## Mission systems

| | |
|---|---|
| [Messaging Deck](Messaging-Deck) | TAC//MSG, the threaded messaging system — the report cards that open a thread and the replies that answer one |
| [TAC//PAC personnel](TAC-PAC) | Ranks, roles, skills, awards, attendance, orders, the log - and where it all lives |
| [Other Systems](Other-Systems) | Logistics, AI skill, tacpad colours, welcome, admins |
| [Editor and Zeus modules](Editor-and-Zeus-Modules) | Every module the mod adds to Eden and to Zeus, with its attributes |

## Reference

| | |
|---|---|
| [Cross-File Contracts](Cross-File-Contracts) | The pairs that must agree — nothing checks them |
| [Common Tasks](Common-Tasks) | Add a squad, a platoon, a role, a weapon |
| [Troubleshooting](Troubleshooting) | Symptom → where to look |

---

## Mod documentation

The wiki is the mission maker's side. The mod's own settings are listed in
game under Addon Options, one category per system, every one of them with a
description. The source is the
[DIVINER repository](https://github.com/ghosts-of-battle/DIVINER); the
missions it runs are the other half of a two-part system and live in the
[2040 repository](https://github.com/ghosts-of-battle/2040).
