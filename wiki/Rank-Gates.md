# Rank gates

> **Gone since 2026-09-05.** Neither framework mission carries this file. The rank
> ladder is `CfgGFA_PAC >> ranks` (or the `<unitId>.ranks` document), a player's
> rank is his TAC//PAC record (put on him at spawn), and the slot gates are the
> roles' `minRank` / `requiredSkills` / `uids` - see
> [config_pac](config_pac#roles) and [TAC-PAC](TAC-PAC). `Dynamic_Ranks` and
> `Role_Access` are still honoured if a mission has them; what follows describes
> that legacy shape.

`config\config_ranks.hpp`. Two classes: who holds what rank, and which roles a
rank is needed for.

---

## `Dynamic_Ranks` — who is what

```cpp
class Dynamic_Ranks {
    // rank given to any player not listed below
    default_rank = "Private";

    // order: Private < Corporal < Sergeant < Lieutenant < Captain < Major < Colonel
    class Colonel    { uids[] = {}; };
    class Major      { uids[] = {}; };
    class Captain    { uids[] = {}; };
    class Lieutenant { uids[] = {}; };
    class Sergeant   {
        uids[] = {
            "76561198000002705", /* YonV */
            "76561198083000561"  /* Wobba */
        };
    };
    class Corporal   { uids[] = {}; };
};
```

Rank does two things: it gates roles, and it is shown against a player's name.

---

## `Role_Access` — which roles need one

```cpp
class Role_Access {
    // roles NOT listed here are open to everyone

    // element leaders
    class coC2            { minRank = "Sergeant"; };
    class teamleadBanshee { minRank = "Sergeant"; };
    class tcNomad         { minRank = "Sergeant"; };
    class pilotTalon      { minRank = "Sergeant"; };

    // seconds in command
    class xoC2            { minRank = "Corporal"; };
    class atlBanshee      { minRank = "Corporal"; };
    class driverNomad     { minRank = "Corporal"; };
    class copilotTalon    { minRank = "Corporal"; };
};
```

An optional `uids[]` on an entry whitelists those players regardless of rank:

```cpp
class pilotTalon {
    minRank = "Sergeant";
    uids[] = {"76561198000000000"};   // qualified, whatever his rank
};
```

Admin role grants always bypass the gate.

---

## Gate the job, not the word

A useful rule: **gate every element's first two slots, whatever that element
calls them.**

The crews rename their leaders — NOMAD's is the vehicle commander and his second
is the driver, TALON's are the pilot and the copilot — so a gate that only knew
the word `teamlead` would leave eight of them open to anyone the day the crews
were written.

Keep this list consistent with which roles carry `isLeader` in their
`customVariables[]`, and with which roles read all four arm nets. In the
reference mission those three sets are the same set.

---

## Two ways to get this wrong

### A gate that names nothing

```cpp
class teamleadBanshee { minRank = "Sergeant"; };   // works
class teamleadBanshe  { minRank = "Sergeant"; };   // typo - gates nothing
```

Both read identically. The second leaves the slot open to everybody, silently.
Class names here must match role class names **exactly**.

### A gate nobody can pass

If nobody in `Dynamic_Ranks` holds Lieutenant, then:

```cpp
class coC2 { minRank = "Lieutenant"; };
```

is a slot **nobody can take**. That is worse than an open one — it looks correct
in the file and the slot simply never fills.

Set the gate to a rank someone actually holds, and raise it the day that
changes.

Next: [Nets](Nets).
