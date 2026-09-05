#include "script_component.hpp"

private _display = findDisplay 9702;
private _tree = _display displayCtrl 1500;
private _selectionPath = tvCurSel _tree;

_selectionPath params ["_treeGroup","_unitIndex"];

// THE SERVER IS TOLD WHICH SQUAD, NOT WHICH ROW. With platoon tabs the tree
// holds only the squads on the open tab, so row 0 is whatever that tab starts
// with - see FUNC(fillRoleTree), which stamps the real index on the squad row.
private _groupIndex = _tree tvValue [_treeGroup];

(parseSimpleArray (_tree tvData _selectionPath)) params ["_unitNetID","_desiredRole"];
private _unit = objectFromNetId _unitNetID;
if !(isNull _unit) exitWith {_tree tvSetCurSel _selectionPath}; //role selected already

([player,_desiredRole] call FUNC(roleGate)) params ["_ok","_why"];
if (!_ok) exitWith {
    ["Role Access", _why + " Ask an admin for a role access grant.", NOTE_BAD] call GHOSTFUNC(notify,notify);
    playSound "addItemFailed";
};

[player,[_groupIndex,_unitIndex],_desiredRole] remoteExecCall ["ghostD_groups_fnc_assignPlayer",2];
closeDialog 0;
