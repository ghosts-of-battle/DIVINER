#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        author = QAUTHOR;
        name = QUOTE(ADDON);
        requiredAddons[] = {
            "ghostD_main"
        };
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.52;
        VERSION_CONFIG;
        authors[] = {"Fusselwurm"};
    };
};

#include "CfgEventHandlers.hpp"

class CfgVehicles {
    class Boat_Transport_02_base_F;
    class Rubber_duck_base_F: Boat_Transport_02_base_F {
        rudderForceCoef = 0.3;
    };
};
