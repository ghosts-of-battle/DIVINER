#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structSelect

Description:
    The item list's onLBSelChanged: puts the selected item's fields into
    the edits on the right. Arrays (a skill's effects) are shown
    comma-separated, the way SAVE reads them back.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(structDisplay), displayNull];
if (isNull _display) exitWith {};

private _list = _display displayCtrl PAC_IDC_ST_LIST;
private _sel = lbCurSel _list;
if (_sel < 0) exitWith {};

private _id = _list lbData _sel;
GVAR(structId) = _id;
private _rec = (GVAR(structure) getOrDefault [[GVAR(structSection)] call FUNC(structBase), createHashMap]) getOrDefault [_id, createHashMap];

(_display displayCtrl PAC_IDC_ST_ID) ctrlSetText _id;
(_display displayCtrl PAC_IDC_ST_NAME) ctrlSetText (_rec getOrDefault ["name", ""]);

{
    _x params ["_editIdc", "_i"];
    ((GVAR(structFields) # _i) params ["", "_field"]);
    // A ROLE'S FIELDS ARE NOT ALL LISTS OF WORDS - nets and tiles are pairs,
    // traits and variables are triples, and the loadout is nested ten deep.
    // FUNC(roleFieldText) writes each shape the way a person would, and
    // FUNC(roleFieldParse) reads exactly that back. Everything else joins.
    private _v = if (_field isEqualTo "") then {""} else {_rec getOrDefault [_field, ""]};
    if ((([GVAR(structSection)] call FUNC(structBase))) isEqualTo "roles") then {
        _v = [_field, _v] call FUNC(roleFieldText);
    } else {
        if (_v isEqualType []) then {_v = _v joinString ", "};
        if !(_v isEqualType "") then {_v = str _v};
    };
    (_display displayCtrl _editIdc) ctrlSetText _v;
} forEach [[PAC_IDC_ST_F1, 0], [PAC_IDC_ST_F2, 1], [PAC_IDC_ST_F3, 2]];
