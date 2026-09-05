#include "script_component.hpp"
params [
    ["_groups",[],[[]]],
    ["_oldSelectionPath",[],[[]]],
    ["_newSelectionPath",[],[[]]],
    ["_unit",objNull,[objNull]]
];

YMF_dynamicGroups = _groups;

private _display = findDisplay 9702;
if !(isNull _display) then {
    private _tree = _display displayCtrl 1500;

    // SQUAD INDEX IN, TREE PATH OUT. This is broadcast to every client, and with
    // platoon tabs no two clients need be looking at the same squads - the
    // sender's row 0 is not the receiver's row 0. The squad rows carry their
    // index into YMF_dynamicGroups (see FUNC(fillRoleTree)), so the path is
    // searched for rather than assumed, and a squad on a tab this client does
    // not have open resolves to [] and is skipped. It is not lost: switching to
    // that tab redraws it from YMF_dynamicGroups, which was updated above.
    private _fnc_path = {
        params ["_p"];
        if (_p isEqualTo []) exitWith {[]};
        _p params ["_gi", "_ui"];
        private _out = [];
        for "_i" from 0 to ((_tree tvCount []) - 1) do {
            if ((_tree tvValue [_i]) isEqualTo _gi) exitWith {_out = [_i, _ui]};
        };
        _out
    };

    _oldSelectionPath = [_oldSelectionPath] call _fnc_path;
    _newSelectionPath = [_newSelectionPath] call _fnc_path;

    if (_oldSelectionPath isNotEqualTo []) then {
        private _oldData = parseSimpleArray (_tree tvData _oldSelectionPath);
        _oldData set [0,netId objNull];
        _tree tvSetData [_oldSelectionPath,str(_oldData)];

        private _roleName = ([_oldData select 1] call FUNC(role)) getOrDefault ["name", _oldData select 1];
        _tree tvSetText [_oldSelectionPath,format["%1: ",_roleName]];
        _tree tvSetColor [_oldSelectionPath,[1,1,1,1]];

        _tree tvSetPictureColor [_oldSelectionPath,[1,1,1,1]];
        _tree tvSetPictureRightColor [_oldSelectionPath,[1,1,1,1]];
    };

    if (_newSelectionPath isNotEqualTo []) then {
        private _newData = parseSimpleArray (_tree tvData _newSelectionPath);
        _newData set [0,netId _unit];
        _tree tvSetData [_newSelectionPath,str(_newData)];

        private _roleName = ([_newData select 1] call FUNC(role)) getOrDefault ["name", _newData select 1];
        _tree tvSetText [_newSelectionPath,format["%1: %2",_roleName,name _unit]];
        _tree tvSetColor [_newSelectionPath,[1,1,1,0.4]];

        _tree tvSetPictureColor [_newSelectionPath,[1,1,1,0.4]];
        _tree tvSetPictureRightColor [_newSelectionPath,[1,1,1,0.4]];
    };

    _tree tvSetCurSel (tvCurSel _tree);
};
