# Motorpool and vehicles

Five files decide what can be spawned, how it is painted, what hangs off it, and
what it can see.

---

## The motorpool

`config\config_motorpool_common.hpp` — the pool every element draws from, plus
the include list for the per-element pools.

```cpp
class MotorPool_Common {
    class Cars {
        displayName = "CARS";
        vehicles[] = {
            "ghost_US_JTF_tna_EF_B_MRAP_01_LAAD_NATO_T",
            "ghost_US_JTF_tna_B_T_LSV_01_armed_F"
        };
    };
    class Heli {
        displayName = "HELI";
        vehicles[] = {};
    };
};

#include "nomad_2\config_motorpool.hpp"
#include "talon_3\config_motorpool.hpp"
```

- Each subclass is a **category tab**; its `configName` — or `displayName` if
  set — is the label.
- Categories **merge by name** across common and element. Empty ones disappear.
- Classes absent from the loaded modset are **skipped by the UI**, so listing
  optional-mod vehicles is safe.

### Per-element pools

```cpp
// config\nomad_2\config_motorpool.hpp
class MotorPool_Nomad {
    class Armor {
        displayName = "ARMOR";
        vehicles[] = {"ghost_US_JTF_tna_B_T_APC_Wheeled_01_apc_QAV"};
    };
};
```

> **A pool is per CALLSIGN, not per element.** `ghost_vehicle_fnc_motorpool_squadClass`
> resolves off the **first word** of a group id, so `MotorPool_Nomad` serves
> `NOMAD 2-1` through `NOMAD 2-4`, and `MotorPool_Wraith` serves both `WRAITH 4-1`
> and `WRAITH 4-2`. File it with the first element of its callsign.

A callsign with no pool is **not an error** — it gets the common one. Only
declare a pool when an element needs vehicles nobody else should have.

An empty `MotorPool_X` is dead config: it merges nothing and behaves exactly as
having no class at all. Delete it rather than keeping it as a placeholder.

---

## Cosmetics

`config\config_cosmetics.hpp` — paint schemes and bolt-on fittings, as data,
under `class GHOST_Cosmetics`.

**Two readers share one list** — the ACE self-interaction menu
(`ghost_vehicle_fnc_addCosmeticSelection`) and the MOTORPOOL spawner screen
(`fnc_motorpool_select`) — so a scheme added here appears in both without a
second edit.

---

## Pylons

`config\config_pylons.sqf` — pylon and turret loadout presets, offered on the
ACE self-interaction menu and the motorpool screen. This is an **SQF** config;
see [How Config Loads](How-Config-Loads).

```sqf
["<base class>", [
    ["<preset id>", [
        ["displayName", "AA loadout"],
        ["icon", "..."],
        ["loadout", [
            ["<magazine>", <turret path>, <rounds>]
        ]]
    ]]
]]
```

> **The key is a base class, matched with `isKindOf`** — so one entry covers
> every variant that inherits from it. A motorpool class with no ancestor in
> this file simply gets no preset menu.

---

## Radar and datalink

`config\config_radar.hpp` — the smallest file in the tree. One array.

```cpp
class Radar_Network {
    classes[] = {
        "B_Radar_System_01_F",
        "O_Radar_System_02_F"
    };
};
```

Every vehicle of a listed class gets datalink reporting, remote-target receive
and radar switched on **as it is created** — a class event handler, so placed
and spawned alike. Read by `initServer.sqf`.

Next: [Messaging Deck](Messaging-Deck).
