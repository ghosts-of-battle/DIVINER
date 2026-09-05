#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // ZEN IS NOT REQUIRED. The curator modules are registered only if it
        // is loaded - see XEH_postInit - so a server without ZEN still gets
        // the action, the menu and the Eden-placed points.
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_notify",
            "cba_settings",
            "cba_xeh"
        };
        skipWhenMissingDependencies = 1;
        author = QAUTHOR;
        // REEVELI WROTE THIS. It came into ghost from the Roomba mission's
        // scripts\Rev_teleport, function for function; the names are ghost's
        // now but the system is his.
        authors[] = {"Reeveli", QAUTHOR};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "gui.hpp"
