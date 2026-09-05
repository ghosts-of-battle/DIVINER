#include "script_component.hpp"

// PROBE - macro-free on purpose. Every ghost_* addon that came out of the
// mission logged nothing at all, and the question "did preStart even run"
// cannot be answered by a line that itself depends on the functions preStart
// is supposed to compile.
diag_log text "[GHOST-PROBE] ghost_diag XEH_preStart ran";
#include "XEH_PREP.hpp"

diag_log text format ["[GHOST-PROBE] after PREP, ghostD_diag_fnc_info is %1", isNil "ghostD_diag_fnc_info"];
