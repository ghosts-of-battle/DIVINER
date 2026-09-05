# config_ranks.hpp

> **Gone since 2026-09-05.** Neither framework mission carries this file. The rank
> ladder is `CfgGFA_PAC >> ranks` (or the `<unitId>.ranks` document), a player's
> rank is his TAC//PAC record (put on him at spawn), and the slot gates are the
> roles' `minRank` / `requiredSkills` / `uids` - see
> [config_pac](config_pac#roles) and [TAC-PAC](TAC-PAC). `Dynamic_Ranks` and
> `Role_Access` are still honoured if a mission has them; what follows describes
> that legacy shape.

Who holds what rank, and which roles need one.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `Dynamic_Ranks`, `Role_Access`.
**Read by:** `ghost_groups_fnc_canTakeRole`, `ghost_players_fnc_getRank`.

---

## `Dynamic_Ranks`

```cpp
class Dynamic_Ranks {
    // rank given to any player not listed below
    default_rank = "Private";

    // order: Private < Corporal < Sergeant < Lieutenant < Captain < Major < Colonel
    class Colonel    { uids[] = {}; };
    class Major      { uids[] = {}; };
    class Captain    { uids[] = {}; };
    class Lieutenant { uids[] = {}; };
    class Sergeant   { uids[] = {"76561198000000000" /* YonV */}; };
    class Corporal   { uids[] = {}; };
};
```

## `Role_Access`

```cpp
class Role_Access {
    // roles NOT listed here are open to everyone

    class teamleadBanshee { minRank = "Sergeant"; };
    class atlBanshee      { minRank = "Corporal"; };

    // an optional whitelist bypasses the rank
    class pilotTalon {
        minRank = "Sergeant";
        uids[] = {"76561198000000000"};
    };
};
```

Admin role grants always bypass the gate.

---

## Instructions

**Gate the job, not the word.** Gate every element's **first two slots**,
whatever that element calls them — the crews rename their leaders (NOMAD's is
the vehicle commander, TALON's is the pilot), so a gate that only knew
`teamlead` would leave eight of them open to anyone.

Keep this list consistent with which roles carry `isLeader` in
`customVariables[]`, and with which roles read all four arm nets. In the
reference mission those three sets are the same set.

---

## Two ways to get this wrong

### A gate that names nothing

```cpp
class teamleadBanshee { minRank = "Sergeant"; };   // works
class teamleadBanshe  { minRank = "Sergeant"; };   // typo - gates nothing
```

Both read identically in the file. Class names here must match role class names
**exactly**.

### A gate nobody can pass

If nobody in `Dynamic_Ranks` holds Lieutenant, then `minRank = "Lieutenant"` is
a slot **nobody can take**. It looks correct and simply never fills. Set the gate
to a rank someone actually holds.

Related: [Rank Gates](Rank-Gates) &middot; [config_roles](config_roles)
