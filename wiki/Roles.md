# Roles

> **In storage since 2026-09-05.** Everything a role file says is also what the
> unit's database holds, one document per role, and the group menu reads either -
> see [config_roles](config_roles). The shape below is the shape of the document.

One class per file, one folder per element. `config\config_roles.hpp` is nothing
but the include list that assembles them into `class Dynamic_Roles`.

```cpp
class Dynamic_Roles {
    // --------------------------------- C2 - the command element, GHOST 6 --
    #include "ghost_6\config_co.hpp"
    #include "ghost_6\config_xo.hpp"

    // ------------------------------------ BANSHEE - the rifle platoon, 1 --
    #include "banshee\config_teamlead.hpp"
    #include "banshee\config_recon.hpp"
};
```

> **Add a role file and you must add it here**, or the class does not exist and
> the slot draws empty with no card beside it.

---

## The schema

Every role class carries the same thirteen properties.

| Property | Type | What it does |
|---|---|---|
| `name` | string | The row label on the role screen — "Team Lead", "ISR Operator" |
| `description` | string | The card beside the tree. What the job actually is |
| `icon` | string | Row icon, a `vehicleicons` paa |
| `nets[]` | `{net, condition}` | Which TAC//MSG mailboxes he reads. See [Nets](Nets) |
| `tiles[]` | `{tile, condition}` | Which TAC//PAD apps he gets |
| `traits[]` | `{trait, value}` | Engine unit traits |
| `customVariables[]` | `{name, value, global}` | ACE and mod variables |
| `defaultLoadout[]` | array | A full `setUnitLoadout` array |
| `groupArsenal` | string | Names the element's `Arsenal_<X>` class |
| `arsenalWeapons[]` | array | The role's own arsenal additions |
| `arsenalMagazines[]` | array | ” |
| `arsenalItems[]` | array | ” |
| `arsenalBackpacks[]` | array | ” |

### A complete example

```cpp
class reconBanshee {
    name = "Recon Specialist";
    description = "Flex: scout, security, marksman or anti-armor standing default per mission.";
    icon = "a3\ui_f\data\map\vehicleicons\iconManRecon_ca.paa";

    // His own platoon's arm net and nothing else named. His own SQUAD's net is
    // never listed - he reads it because he is in it.
    nets[] = {
        {"BANSHEE","true"}
    };

    tiles[] = {
        {"drones","true"},
        {"jam","true"},
        {"weather","true"},
        {"timer","true"},
        {"radio","true"}
    };

    traits[] = {};
    customVariables[] = {
        {"ace_medical_medicClass",0,"true"},
        {"isISR","false","true"}
    };

    defaultLoadout[] = { /* a setUnitLoadout array */ };

    groupArsenal = "Arsenal_Banshee";

    arsenalWeapons[] = {};
    arsenalMagazines[] = {};
    arsenalItems[] = {};
    arsenalBackpacks[] = {};
};
```

---

## `tiles[]` — the TAC//PAD apps

| Tile | Gives him |
|---|---|
| `drones` | The UAV contact picture |
| `jam` | EW and jamming state |
| `support` | Combat support tasking |
| `hack` | The intrusion suite |
| `weather` | Light and weather readout |
| `timer` | Mission clock |
| `radio` | His radio rack |

A common shape: everyone gets `weather`, `timer`, `radio`; specialists get the
one or two that match their trade; the lead gets `support`.

---

## `customVariables[]` — the ones that matter

How to add, remove and edit these, and the rule about what gets cleared between
roles, is on [Custom Traits](Custom-Traits).

| Variable | Effect |
|---|---|
| `isLeader` | **The marker other systems key off.** Set it on the first two slots of every element |
| `ace_medical_medicClass` | `0` none, `1` combat life saver, `2` medic |
| `ace_isEngineer` | `0` none, `1` engineer, `2` advanced |
| `ace_isEOD` | Explosives disposal |
| `isJFO`, `isISR` | Ghost's own role flags |
| `UAVHacker`, `draAccessDrones`, `draAccessSensors` | Drone and sensor access |

Keep `isLeader` consistent with your [Rank Gates](Rank-Gates) — in the reference
mission the eighteen roles carrying it are exactly the gated slots, and exactly
the roles that read all four arm nets.

---

## Sharing a set between elements

Four identical crews do not need four copies of three files. Put one set in a
folder named for the group that shares it and point every element's
`group_setup` row at the same classes:

```cpp
{"NOMAD 2-1",{"tcNomad","driverNomad","crewNomad","crewNomad"},"true"},
{"NOMAD 2-2",{"tcNomad","driverNomad","crewNomad","crewNomad"},"true"},
```

The cost is that they share a rank gate and a description. Give one element
something of its own and it needs its own set back — a copy of the files and a
change of names in the rows.

**Class names are internal.** `group_setup` is the only thing that pairs a class
to a squad, so a squad can be renamed without touching its roles. Name them for
the element anyway: a class called `teamleadCharon` in a folder called
`wraith_4-2` is a trap for whoever reads it next.

Next: [Rank Gates](Rank-Gates).
