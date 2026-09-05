#define COMPONENT groups
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\z\ghostD\addons\main\script_macros.hpp"

// The two-argument INFO/WARNING/ERROR/LOG the Roomba scripts were written
// against, plus the notification colours and the logistics shorthand. Included
// AFTER ghost's macros so the #undef in there lands on the right definitions.
#include "\z\ghostD\addons\diag\roomba_macros.hpp"

// ST_CENTER, ST_LEFT and the pixel-grid defines the dialog geometry is written
// in. The mission got these from its own defines.hpp; a mod takes them from
// the game's own headers.
#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "\a3\ui_f\hpp\defineResincl.inc"

// THE PLATOON TAB ROW. Two consecutive runs of controls in gui.hpp, read back
// by index in fn_initGroupMenu, fn_selectPlatoon and fn_hoverTab. Named once
// here so all four files agree.
//
// TWO CONTROLS PER TAB, and it takes two. A tab carries a type line and a
// callsign under it (user, 2026-09-03: "make the buttons double height to add
// second row to call signs") and an Arma button draws one line of text, full
// stop - no ST_MULTI, no newline in `text`. So the label is a structured text
// control, which does wrap, and a button sits on top of it with no text and no
// fill of its own to catch the click. The button's own hover fill would paint
// over the label under it, so the lift is repainted onto the LABEL instead -
// see fn_hoverTab.
//
// IDC_PLT_TAB + i is tab i's label, IDC_PLT_TAB_BTN + i its button.
#define IDC_PLT_TAB 9720
#define IDC_PLT_TAB_BTN 9730

// TEN TABS, FIVE TO A ROW (user, 2026-09-03: "make 5 fit across"). It was
// four in one row, and the fifth was dropped with a line in the RPT - which a
// task force that has just grown a C2 element on the front of the row would
// have hit on day one. Five across is the whole task force on ONE row, which
// is what the rail is 0.390 wide for. The row wraps to a second line of five
// and the tree is pushed down by exactly one row when it does; past ten the
// drop and the RPT line are still there.
#define MAX_PLT_TABS 10
#define PLT_TABS_PER_ROW 5
