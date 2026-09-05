#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {
            QGVAR(deployed)
        };
        weapons[] = {
            QGVAR(item)
        };
        requiredVersion = REQUIRED_VERSION;
        // ACRE2 is a SOFT dependency, deliberately. Without it this is still a
        // deployable mast - which is what patrol_base wants it for - and every
        // ACRE call is guarded at runtime. Requiring acre_main would make the
        // whole addon vanish on an ACRE-less server and take the base beacon
        // with it.
        requiredAddons[] = {
            "ghostD_main",
            "ace_interact_menu",
            "cba_xeh"
        };
        skipWhenMissingDependencies = 1;
        authorUrl = URL;
        author = QAUTHOR;
        authors[] = {"Ghost", "Alezm"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgAcreComponents.hpp"
#include "CfgWeapons.hpp"
#include "CfgVehicles.hpp"
