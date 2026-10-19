# Element folder files

Each element folder holds up to two kinds of file. Name the folder for the
element it serves; where several elements share one set of role classes, name it
for the group that shares them.

```
config/
    banshee/                    BANSHEE 1-1 to 1-4 - one set, four squads
        config_teamlead.hpp
        config_atl.hpp
        config_recon.hpp
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

Full detail: [Roles](Roles).

---

## `config_arsenal.hpp` - GONE (2026-09-09)

A folder used to carry `Arsenal_<Element>`, and every role in it a
`groupArsenal` naming that class. **Both are gone.** The property is no longer
part of the role contract, TAC//PAC's role editor no longer offers it and the
website no longer writes it - a name typed by hand could name a class that did
not exist, and on the reference unit all five of them named empty documents.

Gear narrower than the common arsenal is a **document named after what it
belongs to**:

| Document | Who draws from it | Edited on |
| --- | --- | --- |
| `<unit>.arsenal.plt_<PLATOON>` | everyone in that platoon | the platoon page |
| `<unit>.arsenal.sqd_<SQUAD>` | everyone in that squad | the squad page |
| `<unit>.arsenal.role_<CLASS>` | that role only | the role page, ARSENAL |

The id is the platoon id, squad name or role class UPPER CASE with anything
else an underscore, so **creating one is creating the document and nothing
else**. `Common_Arsenal` in a mission file still works and is still read first;
the database adds to it. See [Arsenal](Arsenal).

The array-name contract is unchanged: `weapons`, `magazines`, `backpacks`,
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

Every file in every element folder is one of the two kinds above.

| Folder | Serves | Role files | Motorpool |
|---|---|---|---|
| `ghost_6\` | GHOST 6 | `config_co`, `config_xo`, `config_jtac`, `config_medical`, `config_isr`, `config_security` | `MotorPool_Ghost` |
| `banshee\` | BANSHEE 1-1 … 1-4 | `config_teamlead`, `config_atl`, `config_medical`, `config_demo`, `config_jfo`, `config_isr`, `config_recon` | — common pool |
| `nomad_2\` | NOMAD 2-1 … 2-4 | `config_tc`, `config_driver`, `config_crew` | `MotorPool_Nomad` |
| `talon_3\` | TALON 3-1 … 3-4 | `config_pilot`, `config_copilot`, `config_crew` | `MotorPool_Talon` |
| `wraith_4-1\` | WRAITH 4-1 | `config_teamlead`, `config_atl`, `config_medical`, `config_jfo`, `config_isr`, `config_support` | `MotorPool_Wraith` |
| `wraith_4-2\` | WRAITH 4-2 | the same six | — shares 4-1's |

Two things to read off that table:

- **`banshee\` has one set of seven for four squads.** They were four copies of
  the same files; the only difference was the rifle, and every role carries the
  same one now. `group_setup` is what puts one set in four elements.
- **`wraith_4-2\` has no motorpool file.** A pool is per callsign, so both
  WRAITH elements draw on the one filed with 4-1.

Related: [Roles](Roles) &middot; [Arsenal](Arsenal) &middot; [Motorpool and Vehicles](Motorpool-and-Vehicles)
