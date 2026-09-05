#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {
            QGVAR(launcher),
            QGVAR(radar),
            QGVAR(decoy_west),
            QGVAR(decoy_east),
            QGVAR(decoy_guer)
        };
        weapons[] = {};
        ammo[] = {QGVAR(missile)};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_common",
            "cba_xeh"
        };
        skipWhenMissingDependencies = 1;
        author = QAUTHOR;
        authors[] = {"Ghost"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgAmmo.hpp"
#include "CfgVehicles.hpp"
