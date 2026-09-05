#define COMPONENT medbags
#define COMPONENT_BEAUTIFIED MedBags
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_MEDBAGS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MEDBAGS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MEDBAGS
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// EVERY BAG THIS ADDON ISSUES, in one place. fnc_canTake and fnc_doTake both
// walk it, and a sixth bag added to CfgWeapons is takeable the moment its class
// is added here - a list kept in two functions is a list that ends up wrong.
#define MEDBAG_ITEMS [ARR_5(QGVAR(FirstAid),QGVAR(MedicKit),QGVAR(Trauma),QGVAR(Fluid),QGVAR(DrugKit))]
