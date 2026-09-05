#include "script_component.hpp"
params [
    ["_unit",objNull,[objNull]],
    ["_selectionPath",[],[[]]],
    ["_desiredRole","",[""]],
    ["_isRespawn",false,[true]]
];

_selectionPath params [["_groupIndex",-1,[0]],["_unitIndex",-1,[0]]];
private _groupToUpdate = YMF_dynamicGroups param [_groupIndex, []];
if (_groupToUpdate isEqualTo []) exitWith {};
private _unitsInGroup = _groupToUpdate select 4;
if (_unitIndex < 0 || {_unitIndex >= count _unitsInGroup}) exitWith {};
private _desiredUnit = _unitsInGroup select _unitIndex;

// THE SERVER IS THE DOOR. The group menu asks the gate before it sends, but a
// client that remoteExecs this straight bypasses that, so the gate is asked
// again here - against the role the SLOT holds, not the one the message
// claims. A respawn re-seats a man who already passed.
private _slotRole = (_groupToUpdate select 1) param [_unitIndex, ""];
if (_slotRole isNotEqualTo _desiredRole) exitWith {
    WARNING_3("Groups","assignPlayer: %1 asked for %2 in a slot that holds %3 - refused",name _unit,_desiredRole,_slotRole);
};
private _gate = if (_isRespawn) then {[true, "", ""]} else {[_unit, _slotRole] call FUNC(roleGate)};
if !(_gate # 0) exitWith {
    private _why = _gate # 1;
    WARNING_3("Groups","assignPlayer: %1 refused %2 - %3",name _unit,_slotRole,_why);
    [
        QGHOSTGVAR(notify,post),
        ["Role Access", _gate # 1, NOTE_BAD, sideUnknown],
        _unit
    ] call CBA_fnc_targetEvent;
};

if (!isNull _desiredUnit && {!_isRespawn}) exitWith {
    [
        QGHOSTGVAR(notify,post),
        ["Group Menu", "Role already taken.", NOTE_BAD, sideUnknown],
        _unit
    ] call CBA_fnc_targetEvent;
};

private _oldSelectionPath = if (_isRespawn) then {[]} else {[_unit] call ghostD_groups_fnc_removeFromGroup};

private _selectedGroup = _groupToUpdate select 3;
if (isNull _selectedGroup) then {
    _selectedGroup = createGroup [side _unit,true];
    _selectedGroup setGroupIdGlobal [_groupToUpdate select 0];
    _groupToUpdate set [3,_selectedGroup];
};

if !(_unit in (units _selectedGroup)) then {
    [_unit] joinSilent _selectedGroup;
};

_unitsInGroup set [_unitIndex,_unit];
[_desiredRole,_isRespawn] remoteExecCall ["ghostD_groups_fnc_setupPlayer",_unit];

[_selectedGroup,_unit] remoteExecCall ["selectLeader",groupOwner _selectedGroup];

[YMF_dynamicGroups,_oldSelectionPath,_selectionPath,_unit] remoteExecCall ["ghostD_groups_fnc_updateGroups",-2,"YMF_DG_JIP"];

player setVariable ["YMF_oldgroup",_selectedGroup,true];
player setVariable ["YMF_oldrole",_desiredRole,true];
