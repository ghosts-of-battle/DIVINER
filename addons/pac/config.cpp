#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_common",
            "ghostD_adminpanel",
            "ghostD_tacpad",
            "ghostD_notify"
        };
        skipWhenMissingDependencies = 1;
        author = QAUTHOR;
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"

// The admin page inherits the console's control classes so the two screens are
// one family - same type, same edges, same combos - and repaints itself from the
// same tacpad theme.
// Vanilla bases for the boot screen RscTitles (ui/bootscreen.hpp).
class RscText;
class RscPicture;
class RscStructuredText;

class RscADMPText;
class RscADMPButton;
class RscADMPEdit;
class RscADMPCombo;
class RscADMPListbox;
class RscADMPStructuredText;

#include "ui\dialog.inc.hpp"
#include "ui\structure.inc.hpp"
#include "ui\manage.inc.hpp"
#include "ui\bootscreen.hpp"
