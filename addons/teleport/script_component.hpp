#define COMPONENT teleport
#define COMPONENT_BEAUTIFIED Teleport
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_TELEPORT
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_TELEPORT
    #define DEBUG_SETTINGS DEBUG_SETTINGS_TELEPORT
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// The menu. IDCs are ghost's own block rather than the 7000s the mission
// version used - 7000 is inside the range other people's dialogs sit in.
#define IDD_TP              9600
#define IDC_TP_MAP          9601
#define IDC_TP_LIST         9602
#define IDC_TP_OK           9603
#define IDC_TP_CANCEL       9604
#define IDC_TP_TITLE        9605
#define IDC_TP_BG           9606

// The list itself: [object, display name, side] per point, published to
// everyone. Held in missionNamespace so a JIP client gets it with the rest of
// the mission state.
#define TP_LIST             GVAR(list)
#define QTP_LIST            QGVAR(list)
