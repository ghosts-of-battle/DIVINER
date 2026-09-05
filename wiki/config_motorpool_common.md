# config_motorpool_common.hpp

The vehicle pool every element draws from, plus the include list for the
per-element pools.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `MotorPool_Common`, and includes each `MotorPool_<Callsign>`.
**Read by:** `ghost_vehicle_fnc_motorpool_open`, `fnc_motorpool_squadClass`.

---

## Shape

```cpp
class MotorPool_Common {
    class Cars {
        displayName = "CARS";
        vehicles[] = {
            "ghost_US_JTF_tna_EF_B_MRAP_01_LAAD_NATO_T",
            "ghost_US_JTF_tna_B_T_LSV_01_armed_F"
        };
    };
    class Armor  { displayName = "ARMOR";      vehicles[] = {}; };
    class Mech   { displayName = "MECHANIZED"; vehicles[] = {}; };
    class Heli   { displayName = "HELI";       vehicles[] = {}; };
    class Static { displayName = "STATIC";     vehicles[] = {}; };
};

// One pool per callsign that has vehicles of its own, and no others.
#include "nomad_2\config_motorpool.hpp"
#include "talon_3\config_motorpool.hpp"
#include "wraith_4-1\config_motorpool.hpp"
```

- Each subclass is a **category tab**; `configName`, or `displayName` if set, is
  the label.
- Categories **merge by name** across common and element. Empty ones disappear.
- **Classes absent from the loaded modset are skipped by the UI**, so listing
  optional-mod vehicles is safe.

---

## One pool per callsign

`fn_motorpool_squadClass` resolves off the **first word** of a group id:

```
"NOMAD 2-3"  ->  MotorPool_Nomad
"WRAITH 4-2" ->  MotorPool_Wraith
```

So a pool serves a **callsign**, not an element. File it with the first element
of its callsign — `wraith_4-1\config_motorpool.hpp` holds
`MotorPool_Wraith`, which `WRAITH 4-2` draws on too.

A callsign with no pool is **not an error** — it gets the common one.

---

## Instructions

**Add a vehicle everyone can spawn:** add the class to the right category in
`MotorPool_Common`.

**Add a vehicle only one callsign can spawn:** put it in that callsign's
`config_motorpool.hpp`, in a category of the same name to merge, or a new one to
add a tab.

**Add a category:** declare the class in either file. It becomes a tab.

**Delete empty pools.** An empty `MotorPool_X` merges nothing and behaves
exactly as having no class at all — it is dead config, not a placeholder.

Related: [Motorpool and Vehicles](Motorpool-and-Vehicles) &middot; [Element Folder Files](Element-Folder-Files)
