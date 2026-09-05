#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // ghost_messaging feeds the reader and ghost_hacking feeds two of the
        // tiles, but neither is required: a panel whose source is absent draws
        // its rest state and says so, rather than refusing to load.
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_common",
            "ghostD_tacpad",
            "cba_xeh"
        };
        author = QAUTHOR;
        authors[] = {"Ghost"};
        authorUrl = URL;
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "dialog.hpp"


