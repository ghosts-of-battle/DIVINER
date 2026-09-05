#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {QGVAR(drop), "ghostD_moduleIntelPackage"};
        weapons[] = {QGVAR(intelItem), QGVAR(intelMap), QGVAR(intelGps), QGVAR(dropItem)};
        requiredVersion = REQUIRED_VERSION;
        // ace_interact_menu + ace_common for the self-interaction + progress bar.
        // The terminal and the scanner are this addon's own items now, so there
        // is nothing left to check for at runtime.
        requiredAddons[] = {
            "ghostD_main",
            "ace_interact_menu",
            "ace_common",
            "ghostD_notify",
            "ghostD_common",
            "cba_xeh"
        };
        author = QAUTHOR;
        authors[] = {"Ghost"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgFactionClasses.hpp"
#include "CfgWeapons.hpp"
#include "CfgVehicles.hpp"
#include "CfgUIGrids.hpp"
