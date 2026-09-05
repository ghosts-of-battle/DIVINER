#include "script_component.hpp"

// ACTIVE PROTECTION, 2040. Drongo's APS rebuilt inside this mod (no DAPS
// dependency, no DAPS conflict - if DAPS is loaded too both will try to
// delete the same round and the first one wins, harmlessly), with a second
// effector on top, the RF burst of docs/rf_aps_2040_spec.json, a high-power
// microwave that strips guidance from missiles and drops drones, and jams
// every radio near the emitter while it does.
//
// WHO GETS WHAT IS THE FACTION'S TIER (user, 2026-08-28): near-peer fields a
// basic hard-kill on its tanks and its cannon IFVs and nothing else; peer
// fits every armoured vehicle and puts the RF burst on its tanks; peer+ has
// the complete set, the RF burst on everything armoured and on its
// helicopters as the DIRCM. See fnc_fitFor.
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {"ghostD_moduleAPS"};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ghostD_main",
            "ghostD_common",
            "ghostD_notify",
            "cba_xeh",
            "cba_settings"
        };
        skipWhenMissingDependencies = 1;
        authorUrl = URL;
        author = QAUTHOR;
        authors[] = {"Ghost", "Drongo (the original DAPS design)"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgAmmo.hpp"
#include "CfgVehicles.hpp"
