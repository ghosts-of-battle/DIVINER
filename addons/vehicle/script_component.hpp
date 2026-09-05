#define COMPONENT vehicle
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\z\ghostD\addons\main\script_macros.hpp"

// The two-argument INFO/WARNING/ERROR/LOG the Roomba scripts were written
// against, plus the notification colours and the logistics shorthand. Included
// AFTER ghost's macros so the #undef in there lands on the right definitions.
#include "\z\ghostD\addons\diag\roomba_macros.hpp"

// THE VEHICLE SAT LINK (user, 2026-09-02: "make sure there are 2 117s per
// vechicle"). The 117F in its own vehicle mount is what carries a crew past the
// terrain and what the radio mesh relays through; two of them because one set
// cannot sit on the platoon net and the detachment net at the same time, and a
// vehicle that can only hold one of those conversations is a vehicle somebody
// has to keep driving back to.
#define LR_RADIO    "ACRE_PRC117F"
#define LR_RACK     "ACRE_VRC103"
#define LR_RACKS    2

// THE TWO ARE NOT THE SAME RADIO (user, 2026-09-02: "make a low power version
// of the 117 and the other assume its satcom"). Same class - ACRE keeps power
// per channel and presets per class, so a second power level is a second set of
// channels rather than a second item - but the racks are named for what they
// are, tuned to their own half of the LR plan, and only the satcom one gets the
// mast antenna that makes terrain stop counting.
#define LR_RACK_SAT_NAME    "SATCOM"
#define LR_RACK_SAT_SHORT   "SAT"
#define LR_RACK_LOC_NAME    "Ground Net"
#define LR_RACK_LOC_SHORT   "GND"

// The 5000 cm mast ghost_satcom deploys, on the rack's VHF connector. This one
// line is the whole difference between the two sets in ACRE's propagation
// model; drop it and the satcom rack is a second local radio.
#define LR_SAT_ANTENNA      "ghostD_satcom_antenna"

// ST_CENTER, ST_LEFT and the pixel-grid defines the dialog geometry is written
// in. The mission got these from its own defines.hpp; a mod takes them from
// the game's own headers.
#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "\a3\ui_f\hpp\defineResincl.inc"
