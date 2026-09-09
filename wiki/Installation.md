# Installation

## What you need loaded

| | |
|---|---|
| **DIVINER** | This mod — the Steam Workshop item, a [release](https://github.com/ghosts-of-battle/DIVINER/releases), or build it yourself with `hemtt release` |
| **A framework mission** | Required — the other half of a two-part system. The mod does nothing without one. Take a mission from the [2040 repository](https://github.com/ghosts-of-battle/2040) and edit its `config` folder |
| **CBA_A3** | Required. [Releases](https://github.com/CBATeam/CBA_A3/releases) |
| **ACE3** | Required. [Releases](https://github.com/acemod/ACE3/releases) |
| **DUI - Squad Radar** | Required. [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1638341685) |
| **ACRE2** *or* **TFAR** | Optional. The comms plan holds a block for each; the mission uses whichever is loaded, or in-game radio if neither |
| **Simplex Support Services** | Optional — the fire-support tasking (TAC//SUPPORT) is built over it |

DIVINER is built with [HEMTT](https://brettmayson.github.io/HEMTT/). Building it
yourself:

```
hemtt build      # debug build into .hemttout/build
hemtt release    # staged release + archive in releases/
hemtt launch     # launch Arma with the profile's mod set
```

Before committing anything, run the verification gate:

```
python tools/check_all.py
```

## Your mission folder

At minimum:

```
YourMission.YourMap/
    description.ext
    mission.sqm
    config/
        loadConfigs.sqf
        config_groups.hpp
        config_roles.hpp
        <element>/
            config_<role>.hpp
```

Copy `config\loadConfigs.sqf` from the reference mission. It is the same in
every mission — only the four filenames it names would change.

## The reference mission

`Task_Force_Roomba_dev.Tanoa` is the working example every page here quotes
from. If a snippet on the wiki is ambiguous, that mission is the answer.

## Where things live

| | |
|---|---|
| `addons/` | The mod. 153 addons, ACE-style layout |
| `docs/` | Generated mod reference — addons, settings, modules |
| `tools/` | Python generators and checkers. Never shipped in a PBO |
| `optionals/` | Optional addons |
| `3rdparty/` | Merged into a release by a build hook — never copied into `addons/` |

Next: [Mission Setup](Mission-Setup).
