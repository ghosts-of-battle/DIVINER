# Config reference

**One page per file.** Each has the format, a worked example, the rules, and
what breaks if you get it wrong.

The topic pages — [Roster and Squads](Roster-and-Squads), [Roles](Roles),
[Nets](Nets) and the rest — are the narrative guide to building a task force.
These are the per-file reference you look up while editing.

---

## Entry points

| File | Instructions | What it is |
|---|---|---|
| `description.ext` | [description.ext](description-ext) | The mission's root config, and the first door in |
| `config\loadConfigs.sqf` | [loadConfigs](loadConfigs) | The second door — compiles the four SQF configs |

## The roster

| File | Instructions | Declares |
|---|---|---|
| `config_groups.hpp` | [config_groups](config_groups) | `Dynamic_Groups` — elements, platoon tabs, radio nets. **Or the `<unitId>.orbat` document** |
| `config_roles.hpp` | [config_roles](config_roles) | `Dynamic_Roles` — an include list. **Or one `<unitId>.role.<class>` document per role** |
| `config_ranks.hpp` | [config_ranks](config_ranks) | **Gone** — ranks and gates are TAC//PAC's ([config_pac](config_pac)); legacy `Dynamic_Ranks`, `Role_Access` still read |
| `<element>\config_<role>.hpp` | [Element Folder Files](Element-Folder-Files) | One role class |

## Comms

| File | Instructions | Declares |
|---|---|---|
| `config_nets.hpp` | [config_nets](config_nets) | `GHOST_Nets` — every named mailbox. **Or the `<unitId>.nets` document** |
| `config_radio.hpp` | [config_radio](config_radio) | `ghost_radio_*` — the channel plans. **SQF. Or the `<unitId>.radio` document** |
| `config_messaging.hpp` | [config_messaging](config_messaging) | `GHOST_Templates` — the report deck |

## Gear

| File | Instructions | Declares |
|---|---|---|
| `arsenal\config_arsenal_common.hpp` | [config_arsenal_common](config_arsenal_common) | `Common_Arsenal` |
| `<element>\config_arsenal.hpp` | [Element Folder Files](Element-Folder-Files#config_arsenalhpp--the-elements-own-gear) | `Arsenal_<Element>` |

## Vehicles

| File | Instructions | Declares |
|---|---|---|
| `config_motorpool_common.hpp` | [config_motorpool_common](config_motorpool_common) | `MotorPool_Common` |
| `<element>\config_motorpool.hpp` | [Element Folder Files](Element-Folder-Files#config_motorpoolhpp--the-callsigns-vehicles) | `MotorPool_<Callsign>` |
| `config_cosmetics.hpp` | [config_cosmetics](config_cosmetics) | `GHOST_Cosmetics` — paints and fittings |
| `config_pylons.sqf` | [config_pylons](config_pylons) | Turret and pylon presets. **SQF** |
| `config_radar.hpp` | [config_radar](config_radar) | `Radar_Network` |

## Systems and presentation

| File | Instructions | Declares |
|---|---|---|
| `config_logistics.sqf` | [config_logistics](config_logistics) | Crate contents. **SQF** |
| `config_skill.hpp` | [config_skill](config_skill) | AI skill. **SQF statements**, not data |
| `config_admins.hpp` | [config_admins](config_admins) | `CfgGhostAdmins` + the `ADMINS` macro |
| `config_tacpad.hpp` | [config_tacpad](config_tacpad) | `GHOST_TacpadSchemes` |
| `config_welcome.hpp` | [config_welcome](config_welcome) | `GHOST_Welcome` |
| `config_pac.hpp` | [config_pac](config_pac) | `CfgGFA_PAC` — TAC//PAC personnel: ranks, skills, roles, OPORDs |
| `config_sounds.hpp` | [config_sounds](config_sounds) | `CfgSounds` |

---

## Which files are SQF

Four, and they cannot be `#include`d into `description.ext` whatever their
extension says:

- `config_radio.hpp` — **note the extension**
- `config_skill.hpp` — **note the extension**
- `config_logistics.sqf`
- `config_pylons.sqf`

They are compiled by [loadConfigs](loadConfigs) at CBA preInit. See
[How Config Loads](How-Config-Loads).

---

## The role class schema

Every role file declares one class with these thirteen properties.

| Property | Type | What it does |
|---|---|---|
| `name` | string | The row label on the role screen |
| `description` | string | The card beside the tree |
| `icon` | string | Row icon, a `vehicleicons` paa |
| `nets[]` | `{net, condition}` | TAC//MSG mailboxes he reads |
| `tiles[]` | `{tile, condition}` | TAC//PAD apps he gets |
| `traits[]` | `{trait, value}` | Engine unit traits |
| `customVariables[]` | `{name, value, global}` | ACE and mod variables |
| `defaultLoadout[]` | array | A full `setUnitLoadout` array |
| `groupArsenal` | string | The element's `Arsenal_<X>` class |
| `arsenalWeapons[]` | array | The role's own arsenal additions |
| `arsenalMagazines[]` | array | ” |
| `arsenalItems[]` | array | ” |
| `arsenalBackpacks[]` | array | ” |

## The arsenal array names

Only these four are recognised. Anything else is read by nobody.

| Array | Contents |
|---|---|
| `weapons[]` | Every weapon |
| `magazines[]` | Every magazine |
| `backpacks[]` | Every pack |
| `items*[]` | Anything else — `itemsOptics`, `itemsVests`, `itemsMedical`, … |

---

Before shipping: [Cross-File Contracts](Cross-File-Contracts).
