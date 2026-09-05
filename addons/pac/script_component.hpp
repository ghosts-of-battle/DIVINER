#define COMPONENT pac
#define COMPONENT_BEAUTIFIED TAC//PAC
#include "\z\ghostD\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_PAC
    #define DEBUG_MODE_FULL
#endif

#include "\z\ghostD\addons\main\script_macros.hpp"

// The tacpad's drawing grammar - row heights, padding, rule weights - so the
// PAC app is drawn in the same hand as every other app in the suite.
#include "\z\ghostD\addons\tacpad\shared.inc.hpp"

// ---------------------------------------------------------------------------
// TAC//PAC's own logic uses VANILLA PLUMBING, per the design handoff: mission
// event handlers, remoteExec, profileNamespace, createHashMap, scheduled loops.
// No CBA settings, no CBA events, no CBA per-frame handlers.
//
// It cannot be literally CBA-free and still be an addon in this mod - PREP is
// CBA_fnc_compileFunction and every PBO here requires cba_xeh - so the rule is
// read as its intent: nothing in PAC's behaviour depends on CBA, and its
// configuration is CfgGFA_PAC - with ONE exception, asked 2026-09-05: where
// the pacdb service is (initSettings.inc.sqf), because a rented game server
// can take a CBA server setting and cannot take a file in its root.
// ---------------------------------------------------------------------------

// THE STORE. Keys in the server's profileNamespace, exactly as the handoff
// names them - they are the backup format as much as the runtime one, so they
// are not ours to rename. The profile is always the store; the service
// (sync = "service") is on top of it.
#define PAC_KEY_PLAYERS   "gfa_pac_players"
#define PAC_KEY_SESSIONS  "gfa_pac_sessions"
#define PAC_KEY_WINDOWS   "gfa_pac_windows"
#define PAC_KEY_META      "gfa_pac_meta"
#define PAC_KEY_OPORDS    "gfa_pac_opords"
#define PAC_KEY_STRUCTURE "gfa_pac_structure"
#define PAC_KEY_LOG       "gfa_pac_log"

// The action log keeps this many rows; older ones drop off (a record's own
// actions are never dropped).
#define PAC_LOG_MAX       2000

// How long the boot waits for the pacdb service before running on the local copy.
#define PAC_SVC_TIMEOUT   20

#define PAC_SCHEMA        1

// Saves are debounced - phase 2's target, honoured from the start because a
// saveProfileNamespace per edit is the hitch it warns about.
#define PAC_SAVE_DEBOUNCE 30

// The attendance heartbeat, for crash safety: a session that never saw a
// disconnect is closed at the last beat rather than lost.
#define PAC_HEARTBEAT     60

// The admin page addresses its controls by these.
#include "ui\idcs.inc.hpp"
