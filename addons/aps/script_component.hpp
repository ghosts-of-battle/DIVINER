#define COMPONENT aps
#define COMPONENT_BEAUTIFIED APS
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define CBA_DEBUG_SYNCHRONOUS
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_APS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_APS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_APS
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// --- tuning constants (everything a mission maker might want is a CBA setting) ---
#define APS_SWEEP        5       // s between the server's scans for vehicles it has not looked at
#define APS_TICK         0.05    // s between a fitted vehicle's incoming-round checks
#define APS_RF_TICK      0.5     // s between a fitted vehicle's RF threat checks
#define APS_KILL_RANGE   30      // m - the hard kill fires when the round is this close
#define APS_SHELL_RANGE  300     // m - the enhanced fit sees a tank round this far out
#define APS_SEEN_TTL     20      // s a handled projectile stays on a vehicle's seen list

// the map panel: at most this many vehicles, and where it lands the first
// time - right of the squad rail, under the tile band (see tacpad shared.inc.hpp)
#define APS_PANEL_MAX    6
#define DEFAULT_APS      [0.165, 0.15, 0.24, 0.30]

// the fits, worst to best - see fnc_fitFor
#define FIT_NONE         "NONE"
#define FIT_BASIC        "BASIC"
#define FIT_LIGHT        "LIGHT"
#define FIT_MEDIUM       "MEDIUM"
#define FIT_HEAVY        "HEAVY"
#define FIT_ENHANCED     "ENHANCED"
