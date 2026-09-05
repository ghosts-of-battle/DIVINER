#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_edenDroneFactionLoad

Description:
    Eden attributeLoad handler for the ghost_DroneFactionChoice combo. Fills
    the dropdown (IDC 100) with every faction that owns at least one drone
    (see fnc_listFactionDrones), grouped by side, storing the faction
    classname STRING. Restores the saved value case-insensitively; a stored
    value that no longer matches any loaded faction is surfaced as an
    "(unrecognised)" row at the top so it is never silently lost.

    Reads the current value from the Cfg3DEN `_value` slot (authoritative in
    the editor) with the module logic variable as a secondary source, so
    reopening the panel restores the last pick.

Parameters:
    _this : DISPLAY - the combo's controlsGroup display (legacy call), OR
            [_display, _value] when invoked with the SQM value passed through.

Author:
    Ghost
---------------------------------------------------------------------------- */

private _display = _this;
private _sqmValue = "";
if (_this isEqualType []) then {
    _display = _this select 0;
    if (count _this > 1 && {(_this select 1) isEqualType ""}) then { _sqmValue = _this select 1 };
};
if (isNull _display) exitWith {};

private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith {};
lbClear _ctrl;

// --- resolve stored value: logic var > SQM value > default -----------------
private _selectedLogic = get3DENSelected "logic";
private _logicObj = if (count _selectedLogic > 0) then { _selectedLogic select 0 } else { objNull };
private _storedFromLogic = if (!isNull _logicObj) then { _logicObj getVariable ["faction", ""] } else { "" };
private _edenValue = _display getVariable ["value", ""];

private _value = "";
if (_edenValue isEqualType "" && _edenValue isNotEqualTo "") then { _value = _edenValue };
if (_sqmValue != "") then { _value = _sqmValue };
if (_storedFromLogic isEqualType "" && _storedFromLogic isNotEqualTo "") then { _value = _storedFromLogic };

// --- collect distinct drone-owning factions --------------------------------
private _drones = [""] call FUNC(listFactionDrones);
if (isNil "_drones" || {!(_drones isEqualType [])}) then { _drones = [] };

private _entries = [];   // [classname, displayName, side]
private _facSeen = createHashMap;
{
    private _cn = _x select 0;
    private _facTag = getText (configFile >> "CfgVehicles" >> _cn >> "faction");
    if (_facTag != "" && {!(toLower _facTag in _facSeen)}) then {
        _facSeen set [toLower _facTag, true];
        private _fc = configFile >> "CfgFactionClasses" >> _facTag;
        private _dn = getText (_fc >> "displayName");
        if (_dn == "") then { _dn = _facTag };
        private _side = if (isNumber (_fc >> "side")) then { getNumber (_fc >> "side") } else { -1 };
        _entries pushBack [_facTag, _dn, _side];
    };
} forEach _drones;

// --- unrecognised stored value at the very top -----------------------------
private _valueLower = toLower _value;
private _hasMatch = (_entries findIf { (toLower (_x select 0)) == _valueLower }) >= 0;
private _foundIdx = -1;
if (!_hasMatch && _value != "") then {
    private _idx = _ctrl lbAdd format ["(unrecognised) %1", _value];
    _ctrl lbSetData [_idx, _value];
    _foundIdx = _idx;
};

// --- populate grouped by side ----------------------------------------------
private _buckets = [[0, "OPFOR"], [1, "BLUFOR"], [2, "INDFOR"], [3, "CIVILIAN"], [-1, "OTHER"]];
{
    _x params ["_sv", "_sl"];
    private _bucket = _entries select { (_x select 2) == _sv };
    _bucket sort true;
    {
        _x params ["_cn", "_dn"];
        private _label = if (_dn == _cn) then { format ["%1 - %2", _sl, _cn] } else { format ["%1 - %2 (%3)", _sl, _dn, _cn] };
        private _idx = _ctrl lbAdd _label;
        _ctrl lbSetData [_idx, _cn];
        if (_foundIdx == -1 && {(toLower _cn) == _valueLower}) then { _foundIdx = _idx };
    } forEach _bucket;
} forEach _buckets;

if (_foundIdx < 0) then { _foundIdx = 0 };
_ctrl lbSetCurSel _foundIdx;
