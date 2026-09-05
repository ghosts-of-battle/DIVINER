#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        // NOT QGVAR - these two carry no component in their names. QGVAR(moduleJamming)
        // is "ghostD_jamming_moduleJamming", which is not the class in
        // CfgVehicles and left both of them unlisted.
        units[] = {"ghostD_moduleJamming", "ghostD_moduleJammerSite"};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_common",
            "ghostD_notify",
            "cba_xeh"
        };
        skipWhenMissingDependencies = 1;
        author = QAUTHOR;
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "gui.hpp"
