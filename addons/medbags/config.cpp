#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        author = QAUTHOR;
        name = COMPONENT_NAME;
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "A3_Props_F_Orange",
            "ghostD_common"
        };
        units[] = {
            QGVAR(Item_FirstAid),
            QGVAR(Item_Fluid),
            QGVAR(Item_MedicKit),
            QGVAR(Item_DrugKit),
            QGVAR(Item_Trauma)
        };
        weapons[] = {
            QGVAR(FirstAid),
            QGVAR(Fluid),
            QGVAR(MedicKit),
            QGVAR(DrugKit),
            QGVAR(Trauma)
        };
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgSounds.hpp"
#include "CfgVehicles.hpp"
#include "CfgWeapons.hpp"
