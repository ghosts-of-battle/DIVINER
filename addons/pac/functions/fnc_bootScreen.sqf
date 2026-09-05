#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_bootScreen

Description:
    The client's boot overlay - the mark, a progress bar and the boot steps
    as the server reports them - held until the unit is READY, then faded,
    the way ALiVE shows its init. Spawned on every client from XEH_postInit.

    IT DOES NOT FLASH ON A FAST BOOT. A profile-only mission is READY almost
    at once; the screen is shown only if the boot is still running a moment
    after the player exists, so a mission that initialises instantly never
    shows it. A JIP client that arrives after READY shows nothing.

    STEPS COME FROM GVAR(bootLog), published per line (FUNC(bootLog)), and the
    bar from GVAR(bootStep). On the server's own machine (hosted, editor) both
    are the live locals; on a dedicated client they are the published copies.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

// wait for the player, then a breath - a boot that is already done here is one
// the player never needed to see.
waitUntil {sleep 0.25; !isNull player};
sleep 0.75;
if (missionNamespace getVariable [QGVAR(ready), false]) exitWith {};

private _layer = QGVAR(bootScreen) call BIS_fnc_rscLayer;
_layer cutRsc [QGVAR(bootScreen), "PLAIN", 0, false];

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent"];
private _inkHex = [_ink # 0, _ink # 1, _ink # 2, 1] call BIS_fnc_colorRGBAtoHTML;
private _muteHex = [_ink # 0, _ink # 1, _ink # 2, 0.6] call BIS_fnc_colorRGBAtoHTML;
private _accentHex = [_accent # 0, _accent # 1, _accent # 2, 1] call BIS_fnc_colorRGBAtoHTML;

private _barW = 0.30;
private _t0 = diag_tickTime;

while {!(missionNamespace getVariable [QGVAR(ready), false])} do {
    private _disp = uiNamespace getVariable [QGVAR(bootDisp), displayNull];
    if (!isNull _disp) then {
        (_disp displayCtrl PAC_IDC_BS_TITLE) ctrlSetStructuredText parseText format [
            "<t align='center' font='RobotoCondensedBold' size='1.9' color='%1'>TAC//PAC</t><br/><t align='center' size='0.9' color='%2'>I N I T I A L I S I N G   T H E   U N I T</t>",
            _inkHex, _muteHex
        ];

        private _frac = (missionNamespace getVariable [QGVAR(bootStep), 0.05]) max 0.05 min 1;
        private _bar = _disp displayCtrl PAC_IDC_BS_BAR;
        (ctrlPosition _bar) params ["_bx", "_by", "", "_bh"];
        _bar ctrlSetPosition [_bx, _by, _frac * _barW * safeZoneW, _bh];
        _bar ctrlCommit 0;

        // the last few boot lines, the newest brightest
        private _log = missionNamespace getVariable [QGVAR(bootLog), []];
        private _tail = _log select [(count _log - 5) max 0];
        private _rows = [];
        {
            private _dim = (count _tail - 1 - _forEachIndex);
            private _a = [1, 0.75, 0.55, 0.4, 0.3] select (_dim min 4);
            private _line = _x;
            private _b = _line find "]";
            if (_b > 0) then {_line = _line select [_b + 2]};   // drop the "[TAC//PAC BOOT n/6] " prefix
            _rows pushBack format ["<t align='center' size='0.8' color='%1'>%2</t>", [_ink # 0, _ink # 1, _ink # 2, _a] call BIS_fnc_colorRGBAtoHTML, _line];
        } forEach _tail;
        (_disp displayCtrl PAC_IDC_BS_STEP) ctrlSetStructuredText parseText (_rows joinString "<br/>");
    };

    // A boot that never comes up must not trap the player forever.
    if (diag_tickTime - _t0 > (PAC_SVC_TIMEOUT + 30)) exitWith {};
    sleep 0.3;
};

// Ready: fill the bar, say so for a beat, then fade.
private _disp = uiNamespace getVariable [QGVAR(bootDisp), displayNull];
if (!isNull _disp) then {
    private _bar = _disp displayCtrl PAC_IDC_BS_BAR;
    (ctrlPosition _bar) params ["_bx", "_by", "", "_bh"];
    _bar ctrlSetPosition [_bx, _by, _barW * safeZoneW, _bh];
    _bar ctrlCommit 0.2;
    (_disp displayCtrl PAC_IDC_BS_STEP) ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='0.95' color='%1'>READY</t>", _accentHex];
};

sleep 0.8;
_layer cutFadeOut 0.6;
