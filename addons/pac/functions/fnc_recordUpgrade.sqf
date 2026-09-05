#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_recordUpgrade

Description:
    Gives every record every key FUNC(recordFields) names, so a store
    written by an older PAC reads exactly like one written today. Runs
    after every load, adoption, import and sample seed. Two keys are
    filled with facts rather than blanks: an operator id
    (FUNC(operatorSeq)) and the enlistment date - the earliest session the
    unit has for them, else the record's own stamp, else today.

Parameters:
    None

Returns:
    How many records were changed <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {0};

private _fields = [] call FUNC(recordFields);
private _today = ([] call FUNC(stamp)) select [0, 10];
private _n = 0;

{
    private _uid = _x;
    private _rec = _y;
    if !(_rec isEqualType createHashMap) then {continue};
    private _changed = false;

    {
        _x params ["_key", "_empty"];
        if !(_key in _rec) then {
            _rec set [_key, if (_empty isEqualType [] || {_empty isEqualType createHashMap}) then {+_empty} else {_empty}];
            _changed = true;
        };
    } forEach _fields;

    if ((_rec getOrDefault ["operatorId", ""]) isEqualTo "") then {
        _rec set ["operatorId", [] call FUNC(operatorSeq)];
        _changed = true;
    };

    if ((_rec getOrDefault ["enlistedAt", ""]) isEqualTo "") then {
        private _first = "";
        private _firstMin = -1;
        {
            if ((_x # 0) isEqualTo _uid) then {
                private _m = ([_x # 2] call FUNC(stampMinutes)) # 0;
                if (_firstMin < 0 || _m < _firstMin) then {_firstMin = _m; _first = _x # 2};
            };
        } forEach GVAR(sessions);
        if (_first isEqualTo "") then {_first = _rec getOrDefault ["updatedAt", ""]};
        if (_first isEqualTo "") then {_first = _today};
        _rec set ["enlistedAt", _first select [0, 10]];
        _changed = true;
    };

    if (_changed) then {_n = _n + 1};
} forEach GVAR(players);

if (_n > 0) then {INFO_1("records upgraded to the operator shape: %1",_n)};

_n
