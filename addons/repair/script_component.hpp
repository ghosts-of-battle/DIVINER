#define COMPONENT repair
#define COMPONENT_BEAUTIFIED Repair
#include "\z\ghostD\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_REPAIR
    #define DEBUG_MODE_FULL
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// How often the module looks at its charges. Deliberately faster than any
// sensible repair interval, because a respawn delay needs finer resolution than
// the repair cadence - a thing destroyed just after a pass should not wait a
// whole interval before its delay even starts counting.
#define REP_TICK        5

#define REP_INTERVAL_DEF    300
#define REP_RESPAWN_DEF     60
