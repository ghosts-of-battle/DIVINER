#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelFillRoster

Description:
    Draws the roster list down the left of the admin page, and the orphans
    list and the status block on the right - everything on the page that comes
    from what the server publishes rather than from the one open record.

    CALLED ON EVERY PUBLISH while the page is open (the roster and summary PV
    handlers in XEH_postInit), on the filter keystroke, and on the UNASSIGNED
    toggle. Exits at once when the page is not open, which is what lets the PV
    handlers call it without checking.

    THE OPEN ROW STAYS OPEN. A refill re-selects the row for GVAR(editUid), and
    does it under GVAR(panelFilling) so the list's onLBSelChanged does not take
    that for a click and fetch the record again.

    OFFLINE PLAYERS ARE MUTED, not hidden - the roster is the unit's, not the
    server's, and a man not on tonight is still a man with a rank.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink"];
private _inkFull = [_ink # 0, _ink # 1, _ink # 2, 1];
private _inkMute = [_ink # 0, _ink # 1, _ink # 2, 0.5];

private _list = _display displayCtrl PAC_IDC_L_LIST;
private _filter = toLower trim ctrlText (_display displayCtrl PAC_IDC_L_FILTER);
private _online = allPlayers apply {getPlayerUID _x};
private _roster = missionNamespace getVariable [QGVAR(roster), []];

GVAR(panelFilling) = true;
lbClear _list;

private _shown = 0;
{
    _x params ["_uid", "_name", "_rankId", "_roleId", "", "", "_skillIds"];

    private _unassigned = _rankId isEqualTo "" && _roleId isEqualTo "" && _skillIds isEqualTo [];
    if (GVAR(panelUnassigned) && {!_unassigned}) then {continue};
    if (_filter isNotEqualTo "" && {!(_filter in toLower _name)}) then {continue};

    private _abbrev = ["ranks", _rankId, "abbrev"] call FUNC(lookup);
    private _role = ["roles", _roleId] call FUNC(lookup);
    private _row = [_abbrev, _name, _role] select {_x isNotEqualTo ""} joinString "  ";

    private _idx = _list lbAdd _row;
    _list lbSetData [_idx, _uid];
    _list lbSetColor [_idx, [_inkMute, _inkFull] select (_uid in _online)];
    if (_uid isEqualTo GVAR(editUid)) then {_list lbSetCurSel _idx};
    _shown = _shown + 1;
} forEach _roster;

GVAR(panelFilling) = false;

(_display displayCtrl PAC_IDC_L_COUNT) ctrlSetStructuredText parseText format [
    "<t size='0.8'>%1 of %2%3</t>",
    _shown, count _roster,
    ["", "  ·  unassigned only"] select GVAR(panelUnassigned)
];

// ---- orphans, right rail ---------------------------------------------------
private _orphans = _display displayCtrl PAC_IDC_ORPHANS_LIST;
lbClear _orphans;
{
    _x params ["_uid", "_field", "_id"];
    private _who = _uid;
    private _hit = _roster select {(_x # 0) isEqualTo _uid};
    if (_hit isNotEqualTo []) then {_who = (_hit # 0) # 1};
    _orphans lbAdd format ["%1  %2 = %3", _who, _field, _id];
} forEach (GVAR(summary) getOrDefault ["orphans", []]);
if (lbSize _orphans isEqualTo 0) then {
    _orphans lbAdd "none";
    _orphans lbSetColor [0, _inkMute];
};

// ---- status block ----------------------------------------------------------
private _readOnly = GVAR(summary) getOrDefault ["readOnly", false];
(_display displayCtrl PAC_IDC_R_STATUS) ctrlSetStructuredText parseText format [
    "<t size='0.8'>structure hash  <t font='RobotoCondensedBold'>%1</t><br/>players  <t font='RobotoCondensedBold'>%2</t>   online  <t font='RobotoCondensedBold'>%3</t><br/>window  <t font='RobotoCondensedBold'>%4</t><br/>%5<br/>saved  <t font='RobotoCondensedBold'>%6</t></t>",
    (GVAR(summary) getOrDefault ["hash", 0]) toFixed 0,
    count _roster,
    count _online,
    [GVAR(summary) getOrDefault ["windowName", ""], "none open"] select ((GVAR(summary) getOrDefault ["window", ""]) isEqualTo ""),
    ([format ["store  read-write  (%1)", GVAR(summary) getOrDefault ["backend", "profile"]], "<t font='RobotoCondensedBold'>store  READ-ONLY - lost or written by a newer PAC; see the .rpt</t>"] select _readOnly),
    [GVAR(summary) getOrDefault ["savedAt", ""], "not yet this mission"] select ((GVAR(summary) getOrDefault ["savedAt", ""]) isEqualTo "")
];
