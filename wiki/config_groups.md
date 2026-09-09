# config_groups.hpp

> **In storage since 2026-09-05.** `Dynamic_Groups` - `faction_name`, `group_setup`,
> `Platoons`, `RadioNets` - is the `<unitId>.orbat` document
> (`{section, faction, groups, platoons, radioNets}`) when TAC//PAC holds it;
> `ghostD_groups_fnc_orbat` answers `[groups, platoons, radioNets, faction]` from
> the document, else from this file, and every reader in the mod asks it. The
> roles moved with it ([config_roles](config_roles)); `frameworkmongo.Stratis`
> replaces this file with `config_arsenal.hpp` - the arsenal includes that used
> to sit at its foot, which is all of it that stays on disk.

The roster, and the spine of the whole config tree. Everything else is a view of
it.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `Dynamic_Groups` — and includes `config_roles.hpp` and every
arsenal at its foot.
**Read by:** `ghostD_groups_fnc_platoons`, `fnc_fillRoleTree`,
`ghostD_messaging_fnc_squadNets`, `ghostD_players_fnc_platoonNet`.

---

## Shape

```cpp
class Dynamic_Groups {
    faction_name = "Ghosts of Battle";

    class Platoons { /* the role-screen tabs */ };
    class RadioNets { /* nets that cross a platoon */ };

    group_setup[] = { /* every element */ };
};

#include "config_roles.hpp"
#include "arsenal\config_arsenal_common.hpp"
#include "banshee\config_arsenal.hpp"      // top-level Arsenal_ classes
```

> The arsenal includes are **outside** `Dynamic_Groups` on purpose — they are
> looked up as `missionConfigFile >> "Arsenal_X"` and must be top-level.

---

## `group_setup[]` — every element

```cpp
group_setup[] = {
    //  name          roles, one per slot, in slot order                    condition
    {"BANSHEE 1-1", {"teamleadBanshee","atlBanshee","reconBanshee"}, "true"},
    {"BANSHEE 1-2", {"teamleadBanshee","atlBanshee","reconBanshee"}, "true"}
};
```

| Element | What |
|---|---|
| name | The callsign everyone sees. Also becomes the squad's TAC//MSG net, automatically |
| roles | Class names from `Dynamic_Roles`, one per slot. Repeat a class for several of that slot |
| condition | SQF compiled at draw time. `"true"` always shows |

**Two things resolve off this name:**

- the **first word** is the callsign, and `MotorPool_<Callsign>` is looked up
  from it
- the **row index** is the squad's short-range radio channel, unless
  `ghost_radio_srSquadChannel` names it

> **Reorder this list and every team's radio moves with it.** List every squad
> in `ghost_radio_srSquadChannel` and that never bites you.

---

## `Platoons` — the tabs

Optional. Without it you get one flat list.

```cpp
class Platoons {
    class Plt1 {
        name = "1ST PLT INF";     // tab top line - what it IS
        callsign = "BANSHEE";     // bold line under - what it is CALLED
        net = "BANSHEE";          // its arm net: a mailbox and an MR channel
        squads[] = {"BANSHEE 1-1", "BANSHEE 1-2"};
    };
};
```

- **Ten tabs maximum, five to a row.** An eleventh is dropped with an RPT line.
- Drop `callsign` and the tab draws one line.
- A squad in no tab gets an `UNASSIGNED` tab and an RPT line naming it.
- The tabs change **which squads the tree draws and nothing else**.

## `RadioNets` — nets that cross a platoon

```cpp
class RadioNets {
    class Ground1 {
        net = "GROUND 1";
        squads[] = {"BANSHEE 1-1", "NOMAD 2-1"};
    };
};
```

Asked **before** `Platoons`. If it covers every squad in a platoon, nobody in
that platoon ever falls through to the platoon's own net.

---

## Instructions

**Add a squad:** a row in `group_setup[]`; add it to a tab's `squads[]`; give it
an SR channel; add it to `ghost_radio_tfarNets` if you run TFAR.

**Add a platoon:** its squads, then a `Platoons` class, then declare its `net`
in [config_nets](config_nets), then add a matching MR channel in
[config_radio](config_radio), then list that net in the roles that should read
it.

**Rename a platoon:** see [Common Tasks](Common-Tasks#rename-a-platoon) — it
touches eight places.

Related: [Roster and Squads](Roster-and-Squads) &middot; [config_roles](config_roles)
