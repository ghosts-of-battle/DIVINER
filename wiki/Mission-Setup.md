# Mission setup

The smallest mission that boots, then the order to build it up in.

---

## The smallest mission that boots

You need `description.ext`, a roster, and at least one role. Everything else is
optional and can be added later.

### `description.ext`

```cpp
respawn = 3;
respawnButton = 1;
skipLobby = 1;

#include "config\config_groups.hpp"

class Extended_PreInit_EventHandlers {
    class GHOST_MissionConfigs {
        init = "call compile preprocessFileLineNumbers 'config\loadConfigs.sqf'";
    };
};
```

### `config\config_groups.hpp`

```cpp
class Dynamic_Groups {
    faction_name = "Your Unit";

    group_setup[] = {
        {"ALPHA 1-1", {"teamleadAlpha", "reconAlpha", "reconAlpha"}, "true"}
    };
};

#include "config_roles.hpp"
```

### `config\config_roles.hpp`

```cpp
class Dynamic_Roles {
    #include "alpha\config_teamlead.hpp"
    #include "alpha\config_recon.hpp"
};
```

### `config\alpha\config_recon.hpp`

```cpp
class reconAlpha {
    name = "Rifleman";
    description = "Rifle, radio, and whatever the day needs.";
    icon = "a3\ui_f\data\map\vehicleicons\iconMan_ca.paa";

    nets[] = {};
    tiles[] = {{"weather","true"},{"timer","true"},{"radio","true"}};
    traits[] = {};
    customVariables[] = {};

    defaultLoadout[] = {};   // empty = whatever the unit already wears

    arsenalWeapons[] = {};
    arsenalMagazines[] = {};
    arsenalItems[] = {};
    arsenalBackpacks[] = {};
};
```

### `config\loadConfigs.sqf`

Copy it from the reference mission unchanged.

That boots. You get a role screen with one squad and three slots.

---

## Build it up, in this order

Each step depends on the ones above it.

| Step | File | Page |
|---|---|---|
| 1 | `config_admins.hpp` | [Other Systems](Other-Systems#admins) |
| 2 | `config_groups.hpp` | [Roster and Squads](Roster-and-Squads) |
| 3 | `config_roles.hpp` + element folders | [Roles](Roles) |
| 4 | `config_ranks.hpp` | [Rank Gates](Rank-Gates) |
| 5 | `config_nets.hpp` | [Nets](Nets) |
| 6 | `config_radio.hpp` | [Comms Plan](Comms-Plan) |
| 7 | `arsenal\` + per-element arsenals | [Arsenal](Arsenal) |
| 8 | `config_motorpool_common.hpp` and friends | [Motorpool and Vehicles](Motorpool-and-Vehicles) |
| 9 | Everything else | [Other Systems](Other-Systems) |

---

## Folder layout

Name element folders for the element they serve. Where several elements share
one set of role classes, name the folder for the group that shares it:

```
config/
    config_groups.hpp
    config_roles.hpp
    config_ranks.hpp
    config_nets.hpp
    config_radio.hpp
    loadConfigs.sqf
    arsenal/
        config_arsenal_common.hpp
        common/
            weapons.hpp
            magazines.hpp
            items_optics.hpp
            ...
    alpha_1-1/                  one squad
        config_teamlead.hpp
        config_recon.hpp
        config_arsenal.hpp
        config_motorpool.hpp
    nomad_2/                    four crews, one set of role classes
        config_tc.hpp
        config_driver.hpp
        config_crew.hpp
        config_arsenal.hpp
```

The reference mission uses `ghost_6`, `banshee`, `nomad_2`, `talon_3`,
`wraith_4-1` and `wraith_4-2`.

Next: [How Config Loads](How-Config-Loads).
