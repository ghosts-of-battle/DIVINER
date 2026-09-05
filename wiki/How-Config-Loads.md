# How config loads

There are exactly **two paths** from your `config\` folder into the mod, and
which one a file takes depends on what is inside it.

Getting this wrong is the most common setup failure, because the symptom is
silence — the file is simply never read, and nothing errors.

---

## Path A — class configs

Anything that declares a `class`. These are `#include`d into `description.ext`,
so the game preprocesses them into the mission config at load, and the mod reads
them **by name** through `missionConfigFile`.

```
description.ext
   └── #include "config\config_groups.hpp"
          └── class Dynamic_Groups { ... }
                 ↓
       missionConfigFile >> "Dynamic_Groups"
```

Fourteen files take this path. In `description.ext`:

```cpp
#include "config\config_admins.hpp"          // FIRST - defines macros used below

/* ... settings, branding, garbage collection ... */

#include "config\config_groups.hpp"          // Dynamic_Groups, Dynamic_Roles, arsenals
#include "config\config_nets.hpp"
#include "config\config_cosmetics.hpp"
#include "config\config_messaging.hpp"
#include "config\config_ranks.hpp"
#include "config\config_radar.hpp"
#include "config\config_sounds.hpp"
#include "config\config_motorpool_common.hpp"
#include "config\config_tacpad.hpp"
#include "config\config_welcome.hpp"
#include "config\config_pac.hpp"
```

> **Include order matters once.** `config_admins.hpp` must come first, because it
> `#define`s `DEBUG_ADMINS` and `CBA_ADMINS`, which the arrays below it expand.

`config_groups.hpp` pulls in `config_roles.hpp`, the common arsenal and the
per-element arsenals at its own foot, so one include carries the whole roster.

---

## Path B — SQF configs

Files that contain **data or statements rather than classes**. These cannot be
`#include`d into `description.ext` — whatever their extension says — because
`description.ext` only understands config syntax.

They are compiled at CBA preInit by `config\loadConfigs.sqf`, which
`description.ext` registers:

```cpp
class Extended_PreInit_EventHandlers {
    class GHOST_MissionConfigs {
        init = "call compile preprocessFileLineNumbers 'config\loadConfigs.sqf'";
    };
};
```

Four files take this path:

| File | Becomes |
|---|---|
| `config_logistics.sqf` | `ghost_missionConfig_logistics` |
| `config_pylons.sqf` | `ghost_missionConfig_pylons` |
| `config_radio.hpp` | assigns `ghost_radio_*` globals directly — running it **is** the handover |
| `config_skill.hpp` | `ghost_missionConfig_skillBlock`, compiled with `_unit` bound to it |

### Why it runs from the mission

`loadConfigs.sqf` lives in the mission and runs from there, so every path in it
is relative to the mission wherever that mission happens to live.

An earlier version had the mod do this, and it broke three ways:

- a relative path resolves against the **caller**, and the caller was a PBO
- `getMissionPath` returns an **absolute** path, which
  `preprocessFileLineNumbers` refuses outright
- the mod initialises in **every** mission, including the main-menu scene, which
  has no `config` folder at all

### The handover

CBA runs addon preInit handlers *before* the mission's, so the mod has already
passed the point where it wanted this data. The last thing `loadConfigs.sqf`
does is tell it:

```sqf
if (!isNil "ghost_init_fnc_missionConfigsReady") then {
    call ghost_init_fnc_missionConfigsReady;
};
```

---

## The line to check first

`loadConfigs.sqf` logs one line to the RPT naming all four counts. **When a
catalogue looks empty in game, read this before anything else.**

```
[ghost] (mission) INFO: configs handed to the mod - logistics 24, pylons 18, radio true, skill true
```

A `0` or a `false` there means that file failed to compile, and the RPT will
have the parse error above it.

---

## Which path does my file take?

| It contains | Path | Where it goes |
|---|---|---|
| `class Something { ... }` | A | `#include` in `description.ext` |
| An array assignment, e.g. `ghost_radio_srChannels = [...]` | B | Named in `loadConfigs.sqf` |
| Statements — `if`, `switch`, `setSkill` | B | Named in `loadConfigs.sqf`, compiled to a function |

Next: [Config Reference](Config-Reference).
