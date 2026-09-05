#define COMPONENT adminpanel
#define COMPONENT_BEAUTIFIED Admin Panel
#include "\z\ghostD\addons\main\script_mod.hpp"

// The engine's own control styles and grid constants - ST_LEFT, ST_CENTER and
// friends. The console is a real dialog rather than something drawn onto the
// map, so unlike the tacpad's panels it declares its controls in config.
#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "\a3\ui_f\hpp\defineResincl.inc"
#include "\a3\ui_f\hpp\defineResinclDesign.inc"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_ADMINPANEL
    #define DEBUG_MODE_FULL
#endif
    #ifdef DEBUG_SETTINGS_ADMINPANEL
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ADMINPANEL
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// The tacpad's shared geometry - PAD, RULE_THICK, and where the ADMIN strip sits
// on the map screen. The console is a dialog of its own, but the button that
// opens it is a panel on the map like everything else in the suite.
#include "\z\ghostD\addons\tacpad\shared.inc.hpp"

// EVERY CONTROL NUMBER, ONCE. The ported functions each carried their own copy
// of the handful of idcs they touched - forty-five files with a #define block at
// the top, which is forty-five places for a number to fall out of step with the
// dialog. They are declared here and the copies are gone.
#include "ui\idcs.inc.hpp"
