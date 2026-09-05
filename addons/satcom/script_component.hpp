#define COMPONENT satcom
#define COMPONENT_BEAUTIFIED SatCom
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_SATCOM
    #define DEBUG_MODE_FULL
#endif
#ifdef DEBUG_SETTINGS_SATCOM
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SATCOM
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// How far in front of the operator the mast is planted, and how long the
// kneel-down animation runs before it appears.
#define SATCOM_PLACE_DIST   2
#define SATCOM_PLACE_TIME   1

// The variable patrol_base stamps on its beacon. Written out rather than
// imported: this addon does not depend on patrol_base, it just declines to let
// anyone pocket a mast that is holding a base together.
#define SATCOM_BASE_VAR     "ghostD_patrol_base_isBase"
