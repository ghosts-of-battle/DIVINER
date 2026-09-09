#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// The one CBA-settings exception: where the pacdb service is. See the file.
#include "initSettings.inc.sqf"

// THE RUNTIME STATE, declared before anything can reach it. There are no CBA
// settings here and there will not be: TAC//PAC's configuration is CfgGFA_PAC
// and nothing else, which is what makes a unit's whole setup one file to copy.
GVAR(structure) = createHashMap;
GVAR(settings) = createHashMap;
GVAR(structureHash) = 0;

// THE RADIO GLOBALS EXIST FROM HERE ON - config_radio.hpp's vocabulary at its
// "no plan" defaults (FUNC(radioKeys)) - so a mission whose plan lives in the
// database does not throw on the first bare read. The mission's own preInit,
// which runs after this addon's, overwrites them when it ships a plan; the
// server's boot and every client's FUNC(takeServer) write the structure's
// plan over the lot.
[createHashMap, true] call FUNC(radioApply);

GVAR(players) = createHashMap;
GVAR(sessions) = [];
GVAR(windows) = [];
GVAR(meta) = createHashMap;

GVAR(orphans) = [];
GVAR(readOnly) = false;
GVAR(dirty) = false;
GVAR(lastSave) = -1e9;

// Attendance. An op window is open or it is not, and that is a fact the tile
// shows and the report applies after the fact - see the handoff on windows.
GVAR(windowOpen) = "";           // id of the manually started op window, "" for none

// What clients see. Filled by FUNC(publish), never written anywhere else.
GVAR(roster) = [];
GVAR(summary) = createHashMap;

// The app's own view state, per client: which tab, which OPORD is open, and
// whose record the RECORD tab is showing ("" is your own - a name tapped on
// the ROSTER tab puts that man's uid here).
GVAR(view) = "record";
GVAR(openOpord) = "";
GVAR(viewUid) = "";

ADDON = true;

// The admin page's working state: which player is open, the full record the
// server sent for them, and a flag that silences combo handlers while the page
// is being filled - lbSetCurSel fires onLBSelChanged, and a fill that wrote
// back what it had just read would be a write per open.
GVAR(editUid) = "";
GVAR(editRecord) = createHashMap;
GVAR(panelFilling) = false;
GVAR(panelUnassigned) = false;

// Whether the current OPORD has been posted to C2 messaging this mission - the
// server flips it when it picks the admin who posts (FUNC(opordAsk)).
GVAR(opordPosted) = false;

// Every OPORD this server has ever compiled, keyed by id - the mission only
// carries the current one, and this is how the app still shows the last five.
GVAR(opordArchive) = createHashMap;

// When the store last reached the profile - the status block shows it, so an
// admin can see persistence happening rather than take it on trust.
GVAR(savedAt) = "";


// THE BOOT GATE. False until the server has loaded the store and published it;
// publicVariable'd so a client - or a mission script - can wait on it rather
// than act on a roster that is not there yet. Async stores (a database) will
// take longer to raise it; nothing should assume it is up at mission start.
GVAR(ready) = false;

// The pacdb service (sync = "service", through the ghostd_pacdb extension):
// the callback assembles an answer here.
GVAR(svcState) = "idle";      // idle | waiting | ok | empty | error
GVAR(svcChunks) = [];
GVAR(svcUp) = false;
GVAR(svcMissing) = false;


// The boot sequence as lines, for the log and the page.
GVAR(bootLog) = [];
GVAR(bootStep) = 0;
GVAR(testUid) = "";

// Sections edited in game - what the profile keeps so an edit outlives a restart
// on a server with no database. The editor's own state follows.
GVAR(structureEdited) = createHashMap;
GVAR(structSection) = "ranks";
GVAR(structId) = "";

// THE ACTION LOG - server-held rows (FUNC(logAction)); a client holds what
// FUNC(adminLog) last sent it. And the management window's own state.
GVAR(log) = [];
GVAR(logRows) = [];
GVAR(logTotal) = 0;
GVAR(mgSection) = "log";
GVAR(mgKey) = "";
GVAR(mgFields) = [];
