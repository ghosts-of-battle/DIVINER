# config_cosmetics.hpp

Paint schemes and bolt-on fittings, as data.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `GHOST_Cosmetics`.
**Read by:** `ghost_vehicle_fnc_addCosmeticSelection` (the ACE self-interaction
menu) and `fnc_motorpool_select` (the MOTORPOOL screen).

**Two readers, one list** — a scheme added here appears in both without a second
edit.

---

## An entry

```cpp
class GHOST_Cosmetics {
    class Rhino_ToggleSlats {
        vehicle = "AFV_Wheeled_01_base_F";
        name = "Toggle Slats";
        icon = "";
        code = "_vehicle animateSource ['showSLATHull',[1,0] select (_vehicle animationSourcePhase 'showSLATHull' == 1),true];";
    };

    class Rhino_Woodland {
        vehicle = "B_AFV_Wheeled_01_cannon_F";
        name = "Woodland Paint";
        icon = "";
        code = "[_vehicle,[[0,'a3\armor_f_tank\afv_wheeled_01\data\afv_wheeled_01_ext1_green_co.paa'],[1,'...']]] call ghost_vehicle_fnc_applyTextures;";
    };
};
```

| Property | What |
|---|---|
| `vehicle` | The base class it applies to. Matched with **`isKindOf`**, so a base class covers every variant that inherits from it |
| `name` | What the action and the motorpool list say. **A name beginning "Toggle" is treated as a FITTING**; anything else is a PAINT |
| `icon` | Action icon, `""` for none |
| `code` | SQF run when it is chosen, **as a string** |

---

## Rules

### Single quotes inside `code`

A double quote inside a config string has to be doubled, which turns every
texture path into something nobody can read. SQF treats `'` and `"` the same —
use single quotes.

### `code` reads `_vehicle`

It is compiled once by `ghost_vehicle_fnc_cosmeticEntries` and reads `_vehicle`
from the caller's scope. Do not declare it; do not rename it.

### "Toggle" is load-bearing

The reader splits paints from fittings on that prefix. A fitting called
"Deploy Slats" lands in the paint list.

### No loops in a config

Families that used to be built by `forEach` — the QAV fittings, the AbramsX
paints — are written out flat. A list you can read top to bottom is worth the
lines.

---

## Instructions

**Add a paint:** one class. `vehicle` is the most general base class the paint
suits; `code` calls `ghost_vehicle_fnc_applyTextures` with
`[index, "path"]` pairs.

**Add a fitting:** the same, with a `name` starting "Toggle" and `code` that
calls `animateSource`. The `[1,0] select (... == 1)` idiom flips it.

**Find the texture indices** by opening the model in the editor and using
`setObjectTextureGlobal` until each index is identified.

Related: [Motorpool and Vehicles](Motorpool-and-Vehicles#cosmetics)
