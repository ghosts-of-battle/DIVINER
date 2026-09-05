#define COMPONENT patrol_base
#define COMPONENT_BEAUTIFIED Patrol Base
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_PATROL_BASE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_PATROL_BASE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_PATROL_BASE
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// --- kit / world classes ---
#define KIT_ITEMS       [QGVAR(kit_sand), QGVAR(kit_olive)]
#define KIT_OBJECTS     [QGVAR(kit_sand_object), QGVAR(kit_olive_object)]
#define BASE_BEACON     "SatelliteAntenna_01_Black_F"
#define KIT_MASS        180     // 3x a vanilla ToolKit (mass 60)
#define MARKER_TYPE     "Contact_pencilTask2"
