# Element folder files

Each element folder holds up to three kinds of file. Name the folder for the
element it serves; where several elements share one set of role classes, name it
for the group that shares them.

```
config/
    banshee/                    BANSHEE 1-1 to 1-4 - one set, four squads
        config_teamlead.hpp
        config_atl.hpp
        config_recon.hpp
        config_arsenal.hpp
        config_motorpool.hpp
```

---

## `config_<role>.hpp` — one role class

**Loads:** `#include`d by [config_roles](config_roles).
**Declares:** one member of `Dynamic_Roles`.

Thirteen properties, all of them worth setting:

```cpp
class reconBanshee {
    name = "Recon Specialist";
    description = "Flex: scout, security, marksman or anti-armor.";
    icon = "a3\ui_f\data\map\vehicleicons\iconManRecon_ca.paa";

    nets[] = {{"BANSHEE","true"}};
    tiles[] = {{"drones","true"},{"weather","true"},{"timer","true"},{"radio","true"}};
    traits[] = {};
    customVariables[] = {{"ace_medical_medicClass",0,"true"}};

    defaultLoadout[] = { /* a setUnitLoadout array */ };

    groupArsenal = "Arsenal_Banshee";

    arsenalWeapons[] = {};
    arsenalMagazines[] = {};
    arsenalItems[] = {};
    arsenalBackpacks[] = {};
};
```

| Property | Notes |
|---|---|
| `nets[]` | **Never list his own squad's net** — he reads it by being in it |
| `tiles[]` | `drones`, `jam`, `support`, `hack`, `weather`, `timer`, `radio` |
| `traits[]` | Engine traits: `medic`, `engineer`, `explosiveSpecialist`, `UAVHacker` |
| `customVariables[]` | `isLeader` is the one other systems key off |
| `defaultLoadout[]` | Build it in the Arsenal, export, paste |
| `groupArsenal` | Must name a **top-level** `Arsenal_<X>` class |

Full detail: [Roles](Roles).

---

## `config_arsenal.hpp` — the element's own gear

**Loads:** `#include`d at the **foot of** [config_groups](config_groups),
outside `Dynamic_Roles`.
**Declares:** `Arsenal_<Element>`.

```cpp
class Arsenal_Banshee {
    weapons[] = {};
    magazines[] = {};
    backpacks[] = {};
    items[] = {};
};
```

Two things to get right:

1. **Every role in the folder points at it** — `groupArsenal = "Arsenal_Banshee";`
2. **It must be top-level.** It is looked up as
   `missionConfigFile >> "Arsenal_Banshee"`. Nest it inside `Dynamic_Roles` by
   mistake and the lookup finds nothing, with no error — the role just gets the
   common arsenal.

The same array-name contract applies: `weapons`, `magazines`, `backpacks`,
`items*`.

---

## `config_motorpool.hpp` — the callsign's vehicles

**Loads:** `#include`d by [config_motorpool_common](config_motorpool_common).
**Declares:** `MotorPool_<Callsign>`.

```cpp
class MotorPool_Nomad {
    class Armor {
        displayName = "ARMOR";
        vehicles[] = {"B_APC_Tracked_01_rcws_F"};
    };
};
```

> **One pool per CALLSIGN, not per element.** It is resolved off the **first
> word** of a group id, so `MotorPool_Wraith` serves `WRAITH 4-1` and
> `WRAITH 4-2` alike. File it with the first element of its callsign.

A callsign with no pool is not an error — it gets the common one. **An empty
`MotorPool_X` is dead config**: it merges nothing and behaves exactly as having
no class at all. Delete it rather than keeping it as a placeholder.

---

## The reference mission's folders

Every file in every element folder is one of the three kinds above.

| Folder | Serves | Role files | Arsenal | Motorpool |
|---|---|---|---|---|
| `ghost_6\` | GHOST 6 | `config_co`, `config_xo`, `config_jtac`, `config_medical`, `config_isr`, `config_security` | `Arsenal_Ghost6` | `MotorPool_Ghost` |
| `banshee\` | BANSHEE 1-1 … 1-4 | `config_teamlead`, `config_atl`, `config_medical`, `config_demo`, `config_jfo`, `config_isr`, `config_recon` | `Arsenal_Banshee` | — common pool |
| `nomad_2\` | NOMAD 2-1 … 2-4 | `config_tc`, `config_driver`, `config_crew` | `Arsenal_Nomad` | `MotorPool_Nomad` |
| `talon_3\` | TALON 3-1 … 3-4 | `config_pilot`, `config_copilot`, `config_crew` | `Arsenal_Talon` | `MotorPool_Talon` |
| `wraith_4-1\` | WRAITH 4-1 | `config_teamlead`, `config_atl`, `config_medical`, `config_jfo`, `config_isr`, `config_support` | `Arsenal_Wraith41` | `MotorPool_Wraith` |
| `wraith_4-2\` | WRAITH 4-2 | the same six | `Arsenal_Wraith42` | — shares 4-1's |

Two things to read off that table:

- **`banshee\` has one set of seven for four squads.** They were four copies of
  the same files; the only difference was the rifle, and every role carries the
  same one now. `group_setup` is what puts one set in four elements.
- **`wraith_4-2\` has no motorpool file.** A pool is per callsign, so both
  WRAITH elements draw on the one filed with 4-1.

Related: [Roles](Roles) &middot; [Arsenal](Arsenal) &middot; [Motorpool and Vehicles](Motorpool-and-Vehicles)
