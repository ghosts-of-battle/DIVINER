# config_roles.hpp

> **In storage since 2026-09-05.** With TAC//PAC the *whole* role - every property
> below - is a record of the unit's structure and, with Mongo, **one document per
> role**, `<unitId>.role.<class>` (`{section: "role", id, role: {...}}`). The mod
> reads roles through `ghostD_groups_fnc_role`, which answers the structure's copy
> when there is one and this file's class otherwise. This file is the **seed**: a
> mission that ships it pushes it up on a first boot and keeps working as before;
> `frameworkmongo.Stratis` has no role files at all - only the arsenals
> ([config_arsenal_common](config_arsenal_common) and one `Arsenal_*` per element,
> included from `config_arsenal.hpp`). The gates - `minRank`, `requiredSkills`,
> `uids` - are edited in game; everything else on the site. See [TAC-PAC](TAC-PAC).

An include list, and nothing else. It assembles `class Dynamic_Roles` from the
role files in the element folders.

**Loads:** `#include`d by [config_groups](config_groups).
**Declares:** `Dynamic_Roles`.
**Read by:** `ghostD_groups_fnc_setupPlayer`, via `Dynamic_Roles >> <class>`.

---

## Shape

```cpp
class Dynamic_Roles {
    // --------------------------------- C2 - the command element, GHOST 6 --
    #include "ghost_6\config_co.hpp"
    #include "ghost_6\config_xo.hpp"

    // ------------------------------------ BANSHEE - the rifle platoon, 1 --
    #include "banshee\config_teamlead.hpp"
    #include "banshee\config_atl.hpp"
    #include "banshee\config_recon.hpp"

    // ---------------------------------- NOMAD - the mechanised platoon, 2 --
    // Three classes, four crews - NOMAD 2-1 to 2-4 all draw on these.
    #include "nomad_2\config_tc.hpp"
    #include "nomad_2\config_driver.hpp"
    #include "nomad_2\config_crew.hpp"
};
```

---

## Instructions

**Adding a role:** write the file, then add it here. **A role file not on this
list does not exist** — the slot in `group_setup` that names it draws empty with
no card beside it, and nothing errors.

**Removing a role:** delete the include *and* every reference in
`group_setup[]`, *and* its `Role_Access` entry.

**Order does not matter** for behaviour. Group them by element and comment the
groups — this file is the table of contents for the roster.

---

## Naming

Class names are internal. `group_setup` is the only thing that pairs a class to
a squad, so a squad can be renamed without touching its roles.

**Name them for the element anyway.** A class called `teamleadCharon` sitting in
a folder called `wraith_4-2` is a trap for whoever reads it next, and the
callsign it names stopped existing three renames ago.

## Sharing a set between elements

Four identical crews do not need four copies of three files. Point every
element's `group_setup` row at the same classes:

```cpp
{"NOMAD 2-1",{"tcNomad","driverNomad","crewNomad","crewNomad"},"true"},
{"NOMAD 2-2",{"tcNomad","driverNomad","crewNomad","crewNomad"},"true"},
```

The cost is a shared rank gate and a shared description. Give one element
something of its own and it needs its own set back — a copy of the files and a
change of names in the rows.

Related: [Roles](Roles) &middot; [Element Folder Files](Element-Folder-Files)
