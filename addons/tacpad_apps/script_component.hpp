#define COMPONENT tacpad_apps
#define COMPONENT_BEAUTIFIED Tacpad Apps
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\z\ghostD\addons\main\script_macros.hpp"

// Geometry and idcs only. The shell's own script_component.hpp is deliberately
// NOT included: it defines COMPONENT, which would redirect every PREP in this
// addon at the shell's function folder.
#include "\z\ghostD\addons\tacpad\shared.inc.hpp"

// The tile module from the design: 176x98 at 1600x900, carried over as
// fractions of the safe zone so it holds its proportions at any resolution.
// 0.086, not the design's 0.092. Six tiles, five gaps and two margins have to
// fit between the squad rail and the reader column - 0.562 of the safe zone -
// and at 0.092 they came to 0.585, which put the sixth tile through the reader's
// edge and made the band drop it entirely. The arithmetic is done with the
// panel's own borders counted, because the sixth tile is the one that pays for
// any rounding: 6 x 0.086 + 5 x 0.005 + margins leaves a thousandth spare.
// Trimmed from 0.086 when SUPPORT joined the band - compressed a little,
// with the band itself grown leftward for the rest of the room.
#define TILE_W 0.082
#define TILE_H 0.078
#define TILE_GAP 0.005

// Squad health swatches. Hue IS the data here and nowhere else in the suite -
// it is the one place allowed to break the near-mono rule, and only because
// "amber" and "black" mean something a shade of the accent cannot say.
#define HEALTH_OK [0.20, 0.55, 0.25, 1]
#define HEALTH_WIA [0.85, 0.68, 0.15, 1]
#define HEALTH_UNCON [0.55, 0.55, 0.55, 1]
#define HEALTH_KIA [0.10, 0.10, 0.10, 1]

// The state glyphs that go with them, carried over from the archived cTab
// device suite. See data\medical\NOTICE.md - they are MIRA Vehicle Medical's,
// under Apache 2.0.
#define ICON_OK QPATHTOF(data\medical\ok_green.paa)
#define ICON_WIA QPATHTOF(data\medical\bleeding_red.paa)
#define ICON_UNCON QPATHTOF(data\medical\unconscious_white.paa)
#define ICON_KIA QPATHTOF(data\medical\dead.paa)

// Weather glyphs. Alpha-only silhouettes, so they tint to whatever the scheme's
// ink is rather than carrying the source artwork's own blue and yellow onto a
// near-mono screen - see data\weather\NOTICE.md.
#define ICON_WX_CLEAR QPATHTOF(data\weather\clear.paa)
#define ICON_WX_CLEAR_NIGHT QPATHTOF(data\weather\clear_night.paa)
#define ICON_WX_FEW QPATHTOF(data\weather\few.paa)
#define ICON_WX_FEW_NIGHT QPATHTOF(data\weather\few_night.paa)
#define ICON_WX_CLOUD QPATHTOF(data\weather\cloud.paa)
#define ICON_WX_RAIN QPATHTOF(data\weather\rain.paa)
#define ICON_WX_STORM QPATHTOF(data\weather\storm.paa)
#define ICON_WX_SNOW QPATHTOF(data\weather\snow.paa)
#define ICON_WX_FOG QPATHTOF(data\weather\fog.paa)
#define ICON_WX_WIND QPATHTOF(data\weather\wind.paa)

// The three app glyphs. Base-game files rather than shipped ones - they are
// single-colour marks the suite tints like any other, so there is nothing to be
// gained by carrying a copy of them.
//
// EVERY ONE OF THESE IS A REAL FILE, checked against the unpacked base game.
// The UAV glyph was `b_uav_ca.paa`, which does not exist anywhere in A3 - the
// DRONES tile drew nothing and logged "Picture ... not found" once per mission.
// `uavconncetion_ca.paa` is spelled that way by Bohemia and is correct.
#define ICON_UAV "\A3\ui_f\data\gui\cfg\hints\uavbasic_ca.paa"
#define ICON_JAM "\A3\ui_f\data\gui\cfg\hints\uavconncetion_ca.paa"
#define ICON_RADIO "\A3\ui_f\data\igui\cfg\simpleTasks\types\radio_ca.paa"

// How many roster rows and traffic rows a docked panel draws before it stops.
// Both have an OPEN FULL behind them, so this is about what fits in a rail
// without becoming a wall of text.
#define ROSTER_MAX 16
#define TRAFFIC_MAX 12

// THE THREE POINTS A SUPPORT REQUEST CAN CARRY, and the variables each lives
// in. Written once, as a macro, because four separate places fill them - the
// form's rows, the map click, the marker list and the confirm - and three
// copies of "which variable is the ingress point" is three chances to write
// the target into the egress slot.
//
// Slot 0 is the target and keeps the ORIGINAL variable names: artillery and
// ALiVE's own CAS have always read supportPoint, and renaming it to suit a new
// asset type would have been a rename across a screen that already works.
#define SUP_SLOT_TARGET  0
#define SUP_SLOT_INGRESS 1
#define SUP_SLOT_EGRESS  2
#define SUP_SLOT_VARS [    [QGVAR(supportPoint), QGVAR(supportPointName)],    [QGVAR(supportIngress), QGVAR(supportIngressName)],    [QGVAR(supportEgress), QGVAR(supportEgressName)]]
