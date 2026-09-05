#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_diag",
            "ghostD_notify",
            "cba_xeh"
        };
        skipWhenMissingDependencies = 1;
        author = QAUTHOR;
        // Brought into ghost from the Task Force Roomba mission's scripts\ folder.
        authors[] = {"CPL.Brostrom.A", "YonV"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"

#include "gui.hpp"
