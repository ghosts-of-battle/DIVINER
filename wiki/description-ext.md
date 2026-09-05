# description.ext

The mission's root config, and one of the two doors into the framework. Not
under `config\` itself, but it is what pulls everything there in.

**Loads:** the engine reads it at mission load.

---

## What it must contain

```cpp
/* Admins FIRST - it defines macros the arrays below expand. */
#include "config\config_admins.hpp"

respawn = 3;
respawnButton = 1;
skipLobby = 1;
disabledAI = 1;

enableDebugConsole[] = {DEBUG_ADMINS};
cba_settings_whitelist[] = {CBA_ADMINS};

/* Class configs - reached by name through missionConfigFile */
#include "config\config_groups.hpp"          // Dynamic_Groups, Dynamic_Roles, arsenals
#include "config\config_nets.hpp"
#include "config\config_ranks.hpp"
#include "config\config_messaging.hpp"
#include "config\config_cosmetics.hpp"
#include "config\config_motorpool_common.hpp"
#include "config\config_radar.hpp"
#include "config\config_tacpad.hpp"
#include "config\config_welcome.hpp"
#include "config\config_pac.hpp"             // CfgGFA_PAC - TAC//PAC personnel
#include "config\config_sounds.hpp"

/* SQF configs - compiled at CBA preInit */
class Extended_PreInit_EventHandlers {
    class GHOST_MissionConfigs {
        init = "call compile preprocessFileLineNumbers 'config\loadConfigs.sqf'";
    };
};
```

---

## Rules

- **`config_admins.hpp` goes first.** It `#define`s `DEBUG_ADMINS` and
  `CBA_ADMINS`; the arrays below expand them. Put it lower and the file will not
  parse.
- **`config_groups.hpp` carries the roster, the roles and every arsenal.** It
  includes `config_roles.hpp` and the arsenal files at its own foot, so one line
  here covers all of them.
- **A file with no `class` in it cannot be included here.** See
  [How Config Loads](How-Config-Loads).

---

## Other things worth setting

| | |
|---|---|
| `onLoadName`, `onLoadMission`, `author` | Branding on the loading screen |
| `loadScreen`, `overviewPicture` | Loading and browser art |
| `corpseManagerMode`, `corpseLimit`, `corpseRemovalMinTime` | Garbage collection |
| `forceRotorLibSimulation` | `0` player's option, `1` advanced, `2` basic |
| `class CfgCommands { allowedHTMLLoadURIs[] += {...}; }` | URL whitelist for in-game HTML controls. DIVINER ships nothing that loads web pages, so it is only needed if you add something that does; harmless to keep. Server config wins on a dedicated server |
| `class CfgDebriefingSections` | ACE killtracker, behind `__has_include` so it is optional |

Related: [How Config Loads](How-Config-Loads) &middot; [loadConfigs](loadConfigs)
