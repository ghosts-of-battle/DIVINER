#include "script_component.hpp"
/*
    Author: YMF (restyled to the ghost suite), platoon filter by Ghost

    Description:
        Fills the role tree, optionally with only one platoon's squads in it.

        LIFTED OUT OF fn_initGroupMenu so the tab row has something to call.
        The screen used to build its tree once, on open, inside the function
        that created the dialog; a tab press has to build it again against a
        different filter. One function, called from both, so a role drawn by
        the tab is drawn exactly the way the first draw drew it.

    Parameters:
        0: CONTROL - the tree
        1: ARRAY   - squad names this tab shows, upper-cased. [] is every squad,
                     which is what a mission with no Platoons class gets.

    Returns:
        ARRAY - tree path of the player's own slot, [0,0] when he holds none
*/

params [["_tree", controlNull, [controlNull]], ["_only", [], [[]]]];

if (isNull _tree) exitWith {[0,0]};

tvClear _tree;

(missionNamespace getVariable ["YMF_groupMenu_theme", [[0.05,0.05,0.05,1],[0.90,0.90,0.88,1],[0.85,0.28,0.20,1],[0.35,0.35,0.34,1]]]) params ["","_ink","_accent"];

private _myPath = [0,0];

{
    _x params ["_groupName","_roles","_conditions","","_units"];

    // CAPTURED BEFORE THE INNER LOOP SHADOWS IT. The roles below run their own
    // forEach, so _forEachIndex stops meaning "which squad" the moment it does.
    private _realIndex = _forEachIndex;

    // THE FILTER, and the only line that knows tabs exist. An empty list is
    // every squad - see the header - so the untabbed screen runs the same code.
    if (_only isNotEqualTo [] && {!(toUpper _groupName in _only)}) then {continue};

    private _treeIndex = _tree tvAdd [[],toUpper _groupName];
    _tree tvSetColor [[_treeIndex],_ink];

    // THE SQUAD ROW CARRIES ITS INDEX INTO YMF_dynamicGroups, and it has to.
    // Every squad used to be drawn, in order, so a tree row number and a
    // YMF_dynamicGroups index were the same number and the whole screen leaned
    // on that: fn_selectPosition sends tvCurSel to the server as a group index,
    // and fn_updateGroups is handed one back and writes it into the tree as a
    // path. A tab that draws two squads out of five breaks that in both
    // directions at once - a man taking Ghost's team lead would have filled
    // Reaper's. The two functions translate through this.
    //
    // tvSetValue, NOT tvSetData. Every row's data on this tree is the pair
    // [netId, role] that fn_onGroupMenuTvSelectChange parses to write the card,
    // and a squad row has always answered "" to that - harmlessly. Putting a
    // number there instead would hand parseSimpleArray something that is not a
    // pair the first time somebody clicked a squad heading. Value is a separate
    // number slot on the same row and is exactly this.
    _tree tvSetValue [[_treeIndex],_realIndex];

    if (call compile _conditions) then {
        // one gate answer per role class per redraw, not per slot
        private _gates = createHashMap;
        {
            // the role, from wherever the unit keeps it - see FUNC(role)
            private _roleInfo = [_x] call FUNC(role);
            private _roleName = _roleInfo getOrDefault ["name", _x];
            private _roleIcon = _roleInfo getOrDefault ["icon", ""];

            private _playerInRole = _units select _forEachIndex;
            private _taken = !isNull _playerInRole;

            // A TAKEN ROLE READS AS TAKEN AT A GLANCE. It was the role name with
            // a colon and the player's name run together at 40% alpha; the name
            // is what you are scanning for, so it goes after a separator and the
            // row is dimmed rather than half-erased.
            // A LOCKED SLOT SAYS SO. It drew like a free one, and a corporal
            // learned it was a sergeant's slot at the press. The requirement
            // goes on the row - [SGT+], [PLT], [LOCKED] - and the row dims.
            private _gate = if (_taken) then {[true, "", ""]} else {_gates getOrDefaultCall [_x, {[player, _x] call FUNC(roleGate)}, true]};
            private _locked = !(_gate # 0);

            private _name = switch (true) do {
                case (_taken): {format ["%1  -  %2",_roleName,name _playerInRole]};
                case (_locked): {format ["%1  [%2]",_roleName,_gate # 2]};
                default {_roleName};
            };

            private _colour = switch (true) do {
                case (_taken): {[_ink#0, _ink#1, _ink#2, 0.4]};
                case (_locked): {[_ink#0, _ink#1, _ink#2, 0.55]};
                default {_ink};
            };

            private _unitIndex = _tree tvAdd [[_treeIndex],_name];
            _tree tvSetColor [[_treeIndex,_unitIndex],_colour];

            private _data = [netId _playerInRole,_x];
            _tree tvSetData [[_treeIndex,_unitIndex],str(_data)];

            _tree tvSetPicture [[_treeIndex,_unitIndex],_roleIcon];
            _tree tvSetPictureColor [[_treeIndex,_unitIndex],_colour];

            if (player isEqualTo _playerInRole) then {
                _myPath = [_treeIndex,_unitIndex];

                // Your own slot in the accent, so you can find yourself in a
                // list of forty without reading it.
                _tree tvSetColor [[_treeIndex,_unitIndex],_accent];
                _tree tvSetPictureColor [[_treeIndex,_unitIndex],_accent];
            };
        } forEach _roles;
    };
} forEach YMF_dynamicGroups;

tvExpandAll _tree;
_tree tvSetCurSel _myPath;

_myPath
