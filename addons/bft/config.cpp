#include "script_component.hpp"

// Blue Force Tracking, by Jacco Douma. Ported from the TCA_bft addon of Team
// Collaboration Aides (https://github.com/Jaccodouma/TCA-A3) with attribution -
// see README.md for what ghost changed and what came over untouched.

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // ace_interact_menu + ace_common for the map self-interaction that lets a
        // group leader set their own name, icon and colour. ghost_common for the
        // admin flag and the #ghost command harness the admin surface hangs off.
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_common",
            "ace_interact_menu",
            "ace_common",
            "cba_xeh"
        };
        author = QAUTHOR;
        authors[] = {"Jacco Douma", "Ghost"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
