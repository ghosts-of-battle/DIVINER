# config_radar.hpp

The smallest file in the tree. One array of classes that get put on the
datalink.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `Radar_Network`.
**Read by:** `ghostD_init_fnc_radarNetwork`.

> **The setting is the place now (2026-09-09).** The network is switched on with
> the CBA setting **`ghostD_Settings_radarNetwork`** and the classes are typed
> into **`ghostD_Settings_radarClasses`** — comma or newline separated — in
> Addon Options. This file still works and is added to what the setting says,
> so a mission that ships it keeps working. **The database is not a source:**
> `<unit>.radar` is no longer fetched or read. Delete it.

---

## The whole file

```cpp
class Radar_Network {
    classes[] = {
        "B_Radar_System_01_F",
        "O_Radar_System_02_F",
        "O_R_Radar_System_02_F",
        "JK_O_RU_76n6_ClamShell_F"
    };
};
```

---

## What it does

Every vehicle of a listed class gets **datalink reporting, remote-target receive
and radar** switched on **as it is created** — a class event handler, so placed
and spawned alike.

Classes absent from the loaded modset are skipped.

---

## Instructions

**Add a radar:** one class name.

Use the **class the object actually is**, not a parent — this is an exact
match, not `isKindOf`. Add INDEP and mod radars as your modset needs.

Related: [Motorpool and Vehicles](Motorpool-and-Vehicles#radar-and-datalink)
