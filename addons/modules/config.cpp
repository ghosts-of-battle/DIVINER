#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {"ghostD_modulesafestart", "ghostD_moduleHealArea", "ghostD_moduleAiSpawner", "ghostD_moduleAiHunter"};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // ghost_common: the spawn-scale trim and the groupSpawned bus
        requiredAddons[] = {"ghostD_main", "ghostD_common"};
        author = "";
        authors[] = {""};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "CfgFactionClasses.hpp"
