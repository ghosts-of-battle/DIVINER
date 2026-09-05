#include "script_component.hpp"
/*
    File: fnc_roleGate.sqf
    Author: YonV
    Description: Whether a player may take a role, and why not, and the
        short requirement to print on the slot. The one gate; FUNC(canTakeRole)
        is its yes/no wrapper.

        ORDER. An admin grant (YMF_roleGrants) opens everything. Then TAC//PAC,
        when it is loaded and the role carries a gate there - a minimum rank,
        required skills, or a lock to Steam ids - decides on its own and the
        mission's Role_Access is not consulted at all (so a Role_Access uids[]
        whitelist does not apply to a PAC-gated role; the grant is the
        whitelist). Otherwise Role_Access, exactly as it always worked:
        unlisted is open, uids[] passes, minRank compares Arma ranks.

    Parameters:
        0: OBJECT - the unit
        1: STRING - the role class (Dynamic_Roles, or the database's - FUNC(role))

    Returns:
        ARRAY - [ok, why, need]: why a sentence, "" when ok; need the short
        requirement ("SGT+", "PLT", "LOCKED"), "" when the role is open
*/

params [
    ["_unit", objNull, [objNull]],
    ["_roleClass", "", [""]]
];

private _uid = getPlayerUID _unit;
if (_uid in (missionNamespace getVariable ["YMF_roleGrants", []])) exitWith {[true, "", ""]};

// PAC first. Assigned, then tested: an exitWith inside `then {}` would only
// leave that block.
private _pac = if (!isNil "ghostD_pac_fnc_canTake") then {[_unit, _roleClass] call ghostD_pac_fnc_canTake} else {[true, "", ""]};
if ((_pac # 2) isNotEqualTo "") exitWith {_pac};

private _roleName = ([_roleClass] call FUNC(role)) getOrDefault ["name", ""];
if (_roleName isEqualTo "") then {_roleName = _roleClass};

private _accessConfig = missionConfigFile >> "Role_Access" >> _roleClass;
if (!isClass _accessConfig) exitWith {[true, "", ""]};
if (_uid in getArray (_accessConfig >> "uids")) exitWith {[true, "", ""]};

private _minRank = getText (_accessConfig >> "minRank");
if (_minRank isEqualTo "") exitWith {[false, format ["%1 is locked to named players.", _roleName], "LOCKED"]};

private _required = ARMA_RANK_INDEX(_minRank);
if (_required isEqualTo -1) exitWith {[true, "", ""]};   // bad minRank in config - do not lock the role

private _have = ARMA_RANK_INDEX([_unit] call EFUNC(players,getRank));
[
    _have >= _required,
    ["", format ["%1 needs %2 or above.", _roleName, _minRank]] select (_have < _required),
    (toUpper (_minRank select [0, 3])) + "+"
]
