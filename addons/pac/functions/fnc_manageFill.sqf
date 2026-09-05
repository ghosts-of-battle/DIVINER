#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageFill

Description:
    Draws the open operator's file in the management window - the six
    editable fields and, in the hint, everything else the file holds -
    from GVAR(editRecord), whatever the server last sent for
    GVAR(editUid) (FUNC(adminGet) attaches the attendance count). No-op
    unless the window is open on OPERATORS.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display || GVAR(mgSection) isNotEqualTo "operators") exitWith {};

private _rec = GVAR(editRecord);
private _uid = GVAR(editUid);
private _hint = _display displayCtrl PAC_IDC_MG_HINT;

{
    _x params ["_editIdc", "_i"];
    ((GVAR(mgFields) # _i) params ["", "_field"]);
    private _v = if (_field isEqualTo "") then {""} else {_rec getOrDefault [_field, ""]};
    if !(_v isEqualType "") then {_v = str _v};
    (_display displayCtrl _editIdc) ctrlSetText _v;
} forEach [[PAC_IDC_MG_F1, 0], [PAC_IDC_MG_F2, 1], [PAC_IDC_MG_F3, 2], [PAC_IDC_MG_F4, 3], [PAC_IDC_MG_F5, 4], [PAC_IDC_MG_F6, 5]];

if (_uid isEqualTo "" || {count _rec isEqualTo 0}) exitWith {
    _hint ctrlSetStructuredText parseText (["<t size='0.8'>Pick an operator from the list.</t>", "<t size='0.8'>loading ...</t>"] select (_uid isNotEqualTo ""));
};

// ---- the file, read-only ----------------------------------------------------
private _rank = (GVAR(structure) getOrDefault ["ranks", createHashMap]) getOrDefault [_rec getOrDefault ["rankId", ""], createHashMap];
if !(_rank isEqualType createHashMap) then {_rank = createHashMap};
private _squad = _rec getOrDefault ["groupId", ""];
private _platoon = "";
if (_squad isNotEqualTo "" && {!isNil "ghostD_groups_fnc_orbat"}) then {
    {
        _x params ["", ["_pName", ""], ["_pCallsign", ""], "", ["_pSquads", []]];
        if ((toUpper _squad) in (_pSquads apply {toUpper _x})) exitWith {_platoon = [_pName, _pCallsign] select (_pName isEqualTo "")};
    } forEach (([] call ghostD_groups_fnc_orbat) # 1);
};
(_rec getOrDefault ["attendanceSummary", [0, 0, 0, 0, 0]]) params [["_sched", 0], ["_on", 0], ["_loa", 0], ["_awol", 0], ["_pct", 0]];

private _lines = [];
_lines pushBack format ["<t size='1.05' font='RobotoCondensedBold'>%1</t>   %2", _rec getOrDefault ["name", _uid], _rec getOrDefault ["operatorId", ""]];
_lines pushBack "";
_lines pushBack format ["rank  <t font='RobotoCondensedBold'>%1</t>  %2  pay grade %3   promoted %4   status <t font='RobotoCondensedBold'>%5</t>",
    _rank getOrDefault ["name", "-"], _rank getOrDefault ["abbrev", ""], [_rank getOrDefault ["payGrade", ""], "-"] select ((_rank getOrDefault ["payGrade", ""]) isEqualTo ""),
    [_rec getOrDefault ["promotedAt", ""], "-"] select ((_rec getOrDefault ["promotedAt", ""]) isEqualTo ""),
    ["statuses", _rec getOrDefault ["statusId", ""]] call FUNC(lookup)];
_lines pushBack format ["platoon  <t font='RobotoCondensedBold'>%1</t>   squad  <t font='RobotoCondensedBold'>%2</t>   billet  <t font='RobotoCondensedBold'>%3</t>",
    [_platoon, "-"] select (_platoon isEqualTo ""), [_squad, "-"] select (_squad isEqualTo ""), ["roles", _rec getOrDefault ["roleId", ""]] call FUNC(lookup)];
_lines pushBack (format ["attendance  <t font='RobotoCondensedBold'>%1</t> of %2 ops   LOA %3   AWOL %4   <t font='RobotoCondensedBold'>%5</t>", _on, _sched, _loa, _awol, _pct] + "%");
_lines pushBack "";

private _quals = _rec getOrDefault ["qualifications", []];
_lines pushBack "QUALIFICATIONS  " + ([(_quals apply {
    _x params [["_sid", ""], ["_sname", ""], ["_when", ""]];
    format ["%1 (%2)", [_sname, toUpper _sid] select (_sname isEqualTo ""), [_when select [0, 10], "-"] select (_when isEqualTo "")]
}) joinString ", ", "none"] select (_quals isEqualTo []));
_lines pushBack "SKILLS NOW  " + ([((_rec getOrDefault ["skillIds", []]) apply {["skills", _x] call FUNC(lookup)}) joinString ", ", "none"] select ((_rec getOrDefault ["skillIds", []]) isEqualTo []));

private _awards = _rec getOrDefault ["awards", []];
_lines pushBack "AWARDS  " + ([(_awards apply {
    _x params [["_aid", ""], ["_when", ""], "", ["_cit", ""]];
    format ["%1 (%2)%3", ["awards", _aid] call FUNC(lookup), _when select [0, 10], ["", " - " + _cit] select (_cit isNotEqualTo "")]
}) joinString ", ", "none"] select (_awards isEqualTo []));
_lines pushBack "";

private _actions = +(_rec getOrDefault ["adminActions", []]);
reverse _actions;
_lines pushBack format ["ADMIN ACTIONS  (%1, newest first)", count _actions];
{
    if (_forEachIndex >= 8) exitWith {};
    _x params [["_lid", ""], ["_type", ""], ["_when", ""], "", ["_byName", ""], ["_notes", ""]];
    _lines pushBack format ["  %1  %2  %3  %4:  %5", _when select [0, 16], _lid, _type, _byName, _notes];
} forEach _actions;
if (_actions isEqualTo []) then {_lines pushBack "  none"};

_lines pushBack "";
_lines pushBack format ["updated %1  from %2", _rec getOrDefault ["updatedAt", "-"], _rec getOrDefault ["serverId", "-"]];

_hint ctrlSetStructuredText parseText ("<t size='0.8'>" + (_lines joinString "<br/>") + "</t>");
