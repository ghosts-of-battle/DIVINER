# Roster and squads

> **In storage since 2026-09-05.** The whole of `Dynamic_Groups` is the
> `<unitId>.orbat` document when TAC//PAC holds it - see
> [config_groups](config_groups). The shape below is the shape of the document's
> `groups`, `platoons` and `radioNets` arrays.

`config\config_groups.hpp` declares `class Dynamic_Groups`. It is the spine of
the whole config tree — everything else is a view of it.

Three parts.

---

## `group_setup[]` — every element

This is the roster.

```cpp
group_setup[] = {
    //  name          roles, one per slot, in slot order                        condition
    {"ALPHA 1-1", {"teamleadAlpha","atlAlpha","medicalAlpha","reconAlpha"}, "true"},
    {"ALPHA 1-2", {"teamleadAlpha","atlAlpha","medicalAlpha","reconAlpha"}, "true"}
};
```

- The **name** is the element's callsign as everyone sees it. It also becomes the
  squad's TAC//MSG net, automatically — see [Nets](Nets).
- The **roles** are class names from `Dynamic_Roles`, one per slot, in the order
  the slots appear. Repeat a class to get several of that slot.
- The **condition** is SQF compiled at draw time. `"true"` always shows.

> ### Order matters
> A squad's row here is its short-range radio channel index, unless
> `ghost_radio_srSquadChannel` names it explicitly. Reorder the roster and every
> team's radio moves with it. See [Comms Plan](Comms-Plan).

The **first word of the name is the callsign**, and the motorpool resolves off
exactly that — `"NOMAD 2-3"` gets `MotorPool_Nomad`. See
[Motorpool and Vehicles](Motorpool-and-Vehicles).

---

## `Platoons` — the tabs on the role screen

Optional. Without this class you get one flat list, which is what most missions
want.

```cpp
class Platoons {
    class Plt1 {
        name = "1ST PLT INF";    // top line: what the element IS
        callsign = "BANSHEE";    // bold line under it: what it is CALLED
        net = "BANSHEE";         // its arm net
        squads[] = {"BANSHEE 1-1", "BANSHEE 1-2", "BANSHEE 1-3", "BANSHEE 1-4"};
    };
    class Plt2 {
        name = "2ND PLT MECH";
        callsign = "NOMAD";
        net = "NOMAD";
        squads[] = {"NOMAD 2-1", "NOMAD 2-2", "NOMAD 2-3", "NOMAD 2-4"};
    };
};
```

| Property | What |
|---|---|
| `name` | The tab's top line. What kind of element it is |
| `callsign` | The bold word under it. Drop it and the tab draws one line |
| `net` | The platoon's arm net — a mailbox and an MR channel. See [Nets](Nets) |
| `squads[]` | Which `group_setup` entries sit under it. Matched without regard to case |

Rules:

- **Up to ten tabs, five to a row.** An eleventh is dropped with a line in the RPT.
- **A squad in no tab is not hidden.** It gets an `UNASSIGNED` tab of its own and
  an RPT line naming it — a role nobody can see is a role nobody can take.
- **The tabs are a view, and nothing more.** Which squads the tree draws is all
  they change. Roles, their order, conditions, who may take what and the OPEN
  count at the top right all still come off `group_setup`.

---

## `RadioNets` — nets that cross a platoon

Optional, and asked **before** `Platoons`. Use it when a net does not follow the
platoon structure — a rifle squad and the crew that carries it, say.

```cpp
class RadioNets {
    class Ground1 {
        net = "GROUND 1";
        squads[] = {"BANSHEE 1-1", "NOMAD 2-1"};
    };
    class Air1 {
        net = "AIR 1";
        squads[] = {"TALON 3-1"};
    };
};
```

`ghost_players_fnc_platoonNet` asks `RadioNets` first and `Platoons` second, so
a net that crosses a boundary lives here and a plain arm net does not have to be
written twice.

> **Watch what this shadows.** If `RadioNets` covers every squad in a platoon,
> nobody in that platoon ever falls through to its `Platoons` net — the MR
> channel exists but nothing spawns on it.

---

## Worked example

The reference mission's order of battle:

| Tab | Callsign | Net | Elements | Slots |
|---|---|---|---|---|
| C2 | GHOST | `C2` | GHOST 6 | 8 |
| 1ST PLT INF | BANSHEE | `BANSHEE` | 1-1 … 1-4 | 40 |
| 2ND PLT MECH | NOMAD | `NOMAD` | 2-1 … 2-4 | 16 |
| 3RD PLT AIR | TALON | `TALON` | 3-1 … 3-4 | 16 |
| 4TH PLT SPT | WRAITH | `WRAITH` | 4-1, 4-2 | 20 |

Fifteen elements, one hundred slots, five tabs on one row.

Next: [Roles](Roles).
