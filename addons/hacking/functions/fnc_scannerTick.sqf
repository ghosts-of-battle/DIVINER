#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_scannerTick

Description:
    Paints one sweep onto the device. Colour carries the state and the text
    carries the detail, so a glance tells you whether to worry and a look tells
    you why - there is no separate lamp to read, the reading itself is the lamp.

    UAV: green nothing within 2 km, amber something inside 2 km, red inside 1 km.
    JAM: green clear, amber partial, red smothered. MESH: green if someone
    friendly is close enough to relay, red if you are on your own.

    The footer is the summary line: STAND BY while nothing is wrong, and a
    blinking red ALERT the moment anything is, because the footer is the part you
    can read out of the corner of your eye while looking somewhere else.

Parameters (CBA PFH): 0: args, 1: handle

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_args", "_handle"];

// NO PLAYER, NO HANDSET - AND THIS IS THE ONE HOOK THAT ACTUALLY RUNS.
// The menu-side display handlers fire when the main menu is CREATED, which
// is once, at game launch: coming back from a mission reuses that display,
// raises no event, and every teardown hung there never ran. This tick is
// still going when the mission ends, so it is where the scanner comes
// down.
if (isNull player) exitWith {
    [] call FUNC(scannerClose);
    GVAR(scannerPFH) = -1;
    [_handle] call CBA_fnc_removePerFrameHandler;
};

private _display = uiNamespace getVariable [QGVAR(scanner), displayNull];
if (isNull _display) exitWith {
    GVAR(scannerPFH) = -1;
    [_handle] call CBA_fnc_removePerFrameHandler;
};

// A DIALOG OWNS THE SCREEN, SO THE HANDSET GETS OUT OF THE WAY.
//
// This does not trust render order, because render order has been wrong twice.
// The handset was an RscTitles layer, which draws OVER dialogs; moving it onto
// the mission display was supposed to put it under them and DID NOT - build 759
// still showed it across the TAC//ADMIN player list. Rather than keep guessing
// at how the engine stacks two displays, the tick simply hides it whenever a
// dialog is up and shows it again when the dialog closes.
//
// `dialog` is true for a real dialog only - the tacpad and the map are not
// dialogs, so the handset stays visible over those, which is where a man
// actually wants to read it.
//
// STATE-CHANGE ONLY. Eighteen ctrlShow calls every tick for a thing that
// changes when a menu opens would be eighteen calls a second for nothing.
private _hidden = uiNamespace getVariable [QGVAR(scannerHidden), false];

if (dialog isNotEqualTo _hidden) then {
    uiNamespace setVariable [QGVAR(scannerHidden), dialog];
    private _show = !dialog;
    {
        private _ctrl = _display displayCtrl _x;
        if (!isNull _ctrl) then {_ctrl ctrlShow _show};
    } forEach [
        IDC_SCN_BEZEL, IDC_SCN_TITLE,
        IDC_SCN_ICO_DRONE, IDC_SCN_DRONE_L, IDC_SCN_DRONE_V,
        IDC_SCN_ICO_JAM, IDC_SCN_JAM_L, IDC_SCN_JAM_V,
        IDC_SCN_ICO_MESH, IDC_SCN_MESH_L, IDC_SCN_MESH_V,
        IDC_SCN_NETHEAD, IDC_SCN_ICO_NET, IDC_SCN_NET_L, IDC_SCN_NET_V,
        IDC_SCN_ALARM, IDC_SCN_TIMER, IDC_SCN_STATUS
    ];
};

// Nothing to paint while it is hidden.
if (dialog) exitWith {};


// Putting the item away puts the device away.
if !([player] call FUNC(hasScanner)) exitWith { [] call FUNC(scannerClose) };

([] call FUNC(scannerRead)) params
    ["_droneState", "_droneDist", "_droneDir", "_jam", "_chanText", "_freqText", "_mesh"];

#define SCN_C_GREEN [0, 0.67, 0.22, 1]
#define SCN_C_AMBER [0.914, 0.651, 0.235, 1]
#define SCN_C_RED   [0.816, 0.271, 0.227, 1]
#define SCN_C_DIM   [0, 0.34, 0.12, 1]

// Sets a whole reading. Glyph, label and value share the state colour, so the
// row reads as one thing rather than as three things that happen to be adjacent.
private _row = {
    params ["_iIdc", "_lIdc", "_vIdc", "_text", "_colour"];
    (_display displayCtrl _iIdc) ctrlSetTextColor _colour;
    (_display displayCtrl _lIdc) ctrlSetTextColor _colour;
    (_display displayCtrl _vIdc) ctrlSetTextColor _colour;
    (_display displayCtrl _vIdc) ctrlSetText _text;
};

// --- drones ----------------------------------------------------------------
// Bearing before range, and zero-padded to three digits so the column does not
// jump about as the drone circles. A range tells you to worry; a bearing tells
// you which way to look and which way to move.
private _droneText = "CLEAR";
if (_droneState > 0) then {
    private _brg = str _droneDir;
    while { count _brg < 3 } do { _brg = "0" + _brg };
    _droneText = format ["%1 %2m", _brg, round _droneDist];
};

[
    IDC_SCN_ICO_DRONE, IDC_SCN_DRONE_L, IDC_SCN_DRONE_V,
    _droneText,
    [SCN_C_GREEN, SCN_C_AMBER, SCN_C_RED] select _droneState
] call _row;

// --- jamming ---------------------------------------------------------------
private _jamState = switch (true) do {
    case (_jam <= 0): { 0 };
    case (_jam >= 0.75): { 2 };
    default { 1 };
};
[
    IDC_SCN_ICO_JAM, IDC_SCN_JAM_L, IDC_SCN_JAM_V,
    if (_jamState == 0) then { "CLEAR" } else { format ["%1%2", round (_jam * 100), "%"] },
    [SCN_C_GREEN, SCN_C_AMBER, SCN_C_RED] select _jamState
] call _row;
// Smothered is a different picture from noisy, so it gets a different glyph.
(_display displayCtrl IDC_SCN_ICO_JAM) ctrlSetText
    ([QPATHTOF(data\icons\jam.paa), QPATHTOF(data\icons\broken.paa)] select (_jamState == 2));

// --- mesh stand-in ---------------------------------------------------------
[
    IDC_SCN_ICO_MESH, IDC_SCN_MESH_L, IDC_SCN_MESH_V,
    if (_mesh > 0) then { format ["%1 NODE%2", _mesh, ["", "S"] select (_mesh > 1)] } else { "ALONE" },
    [SCN_C_RED, SCN_C_GREEN] select (_mesh > 0)
] call _row;

// --- own net ---------------------------------------------------------------
// Dim rather than green: your own radio is context, not a warning.
private _netColour = if (_freqText isEqualTo "") then { SCN_C_DIM } else { SCN_C_GREEN };
private _netL = _display displayCtrl IDC_SCN_NET_L;
private _netV = _display displayCtrl IDC_SCN_NET_V;
_netL ctrlSetText _chanText;
_netL ctrlSetTextColor _netColour;
_netV ctrlSetText _freqText;
_netV ctrlSetTextColor _netColour;
(_display displayCtrl IDC_SCN_ICO_NET) ctrlSetTextColor _netColour;

// --- stopwatch -------------------------------------------------------------
// Bright while it runs, amber while it holds a value you have not cleared, dim
// at zero - so a stopped clock still tells you it is holding something.
private _elapsed = GVAR(timerHeld);
if (GVAR(timerState) == SCN_T_RUNNING) then { _elapsed = _elapsed + (time - GVAR(timerFrom)) };
private _pad = { if (_this < 10) then { "0" + str _this } else { str _this } };
(_display displayCtrl IDC_SCN_TIMER) ctrlSetText format [
    "%1 %2:%3",
    ["T", "T", "H"] select GVAR(timerState),
    (floor (_elapsed / 60)) call _pad,
    (floor (_elapsed % 60)) call _pad
];
(_display displayCtrl IDC_SCN_TIMER) ctrlSetTextColor
    ([SCN_C_DIM, SCN_C_GREEN, SCN_C_AMBER] select GVAR(timerState));

// --- alarm -----------------------------------------------------------------
// Four looks, one line: blinking red while it rings, green while you dial one
// in, amber counting down the soonest of the armed ones (with how many more
// are queued behind it), dim when there is nothing to wake up for. The list is
// the server's, so every scanner on the net shows the same countdown.
private _alarm = _display displayCtrl IDC_SCN_ALARM;
private _mmss = {
    private _s = 0 max floor _this;
    format ["%1:%2", (floor (_s / 60)) call _pad, (_s % 60) call _pad]
};
switch (true) do {
    case (time < GVAR(alarmRingUntil)): {
        _alarm ctrlSetText (["", "* ALARM *"] select ((floor (diag_tickTime * 2)) % 2 == 0));
        _alarm ctrlSetTextColor SCN_C_RED;
    };
    case (GVAR(alarmPending) > 0): {
        _alarm ctrlSetText format ["A> %1", GVAR(alarmPending) call _mmss];
        _alarm ctrlSetTextColor SCN_C_GREEN;
    };
    default {
        private _next = -1;
        private _armed = 0;
        {
            _x params ["", "_at"];
            private _left = _at - CBA_missionTime;
            if (_left > 0) then {
                _armed = _armed + 1;
                if (_next < 0 || _left < _next) then { _next = _left };
            };
        } forEach GVAR(alarms);
        if (_armed > 0) then {
            _alarm ctrlSetText format ["A %1%2",
                _next call _mmss,
                ["", format [" +%1", _armed - 1]] select (_armed > 1)];
            _alarm ctrlSetTextColor SCN_C_AMBER;
        } else {
            _alarm ctrlSetText "A --:--";
            _alarm ctrlSetTextColor SCN_C_DIM;
        };
    };
};

// --- footer ----------------------------------------------------------------
private _status = _display displayCtrl IDC_SCN_STATUS;
if ((_droneState == 2) || _jamState == 2 || {time < GVAR(alarmRingUntil)}) then {
    // Half a second on, half off. Slow enough to read as a warning rather than
    // as a strobe you end up tuning out.
    _status ctrlSetText (["", "== ALERT =="] select ((floor (diag_tickTime * 2)) % 2 == 0));
    _status ctrlSetTextColor SCN_C_RED;
} else {
    _status ctrlSetText "== STAND BY ==";
    _status ctrlSetTextColor SCN_C_DIM;
};
