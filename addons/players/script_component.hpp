#define COMPONENT players
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\z\ghostD\addons\main\script_macros.hpp"

// The two-argument INFO/WARNING/ERROR/LOG the Roomba scripts were written
// against, plus the notification colours and the logistics shorthand. Included
// AFTER ghost's macros so the #undef in there lands on the right definitions.
#include "\z\ghostD\addons\diag\roomba_macros.hpp"

// BASE-GAME VOICE (VON) - used only when neither TFAR nor ACRE is loaded; see
// EGVAR(common,von) and FUNC(vonApply).
#define VON_MAX_NETS 10
#define VON_FALLBACK_NET "C2"
#define VON_FALLBACK_KIND "c2"
#define VON_KINDS ["c2", "a2g"]
#define VON_CALLSIGN "%UNIT_NAME"
#define VON_UNUSED_LABEL "-"
// Seconds between the server's membership reconcile and the client's channel check.
#define VON_SYNC_INTERVAL 10
#define VON_CLIENT_INTERVAL 5
// Seconds after a disconnect before the reconcile, so the engine has let go of the unit.
#define VON_LEAVE_DELAY 1
// The engine's channel numbers; a custom channel n is (n + VON_CUSTOM_OFFSET).
#define VON_CH_GLOBAL 0
#define VON_CH_SIDE 1
#define VON_CH_COMMAND 2
#define VON_CH_GROUP 3
#define VON_CH_VEHICLE 4
#define VON_CH_DIRECT 5
#define VON_CUSTOM_OFFSET 5
