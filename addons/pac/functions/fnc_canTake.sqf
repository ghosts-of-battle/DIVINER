#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_canTake

Description:
    PAC's answer to "may this player take this slot" - the role's gates in
    the structure against the player's roster row. Any machine: both hold
    the roster and the structure, so the group menu can say no before the
    press and the server can say no again after it.

    THREE GATES, ALL MUST PASS:
        uids            the role is locked to these Steam ids
        minRank         the player's PAC rank maps to an Arma rank at least
                        as high as the gate's rank does (ARMA_RANK_INDEX)
        requiredSkills  every listed skill is on the player's record

    A role with none of the three is not PAC's to gate, and the caller
    (groups' FUNC(roleGate)) falls back to the mission's Role_Access. A
    gate that names something the structure does not have - a rank id or
    skill id that was removed - is logged and does not lock: a typo must not
    make a slot nobody can pass.

    Admin grants (YMF_roleGrants) are the groups addon's business and are
    applied before this is asked.

Parameters:
    0: The unit <OBJECT>
    1: Role class <STRING> - the Dynamic_Roles class, which is the PAC role id

Returns:
    [ok, why, need] - why is a sentence ("" when ok); need is the short
    requirement for a slot label ("SGT+", "PLT", "LOCKED"), "" when the
    role is not gated by PAC <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_roleClass", "", [""]]];

private _role = (GVAR(structure) getOrDefault ["roles", createHashMap]) getOrDefault [_roleClass, createHashMap];
private _minRank = _role getOrDefault ["minRank", ""];
private _required = _role getOrDefault ["requiredSkills", []];
private _uids = _role getOrDefault ["uids", []];
if (_minRank isEqualTo "" && _required isEqualTo [] && _uids isEqualTo []) exitWith {[true, "", ""]};

private _roleName = ["roles", _roleClass] call FUNC(lookup);
private _uid = [_unit] call FUNC(uid);
private _row = (missionNamespace getVariable [QGVAR(roster), []]) select {(_x # 0) isEqualTo _uid};
private _rankId = "";
private _skillIds = [];
if (_row isNotEqualTo []) then {(_row # 0) params ["", "", "_r", "", "", "", "_s"]; _rankId = _r; _skillIds = _s};

private _need = [];
private _why = [];

// ---- locked to Steam ids ---------------------------------------------------
if (_uids isNotEqualTo []) then {
    _need pushBack "LOCKED";
    if !(_uid in (_uids apply {if (_x isEqualType "") then {_x} else {str _x}})) then {
        _why pushBack format ["%1 is locked to named players.", _roleName];
    };
};

// ---- rank ------------------------------------------------------------------
if (_minRank isNotEqualTo "") then {
    private _ranks = GVAR(structure) getOrDefault ["ranks", createHashMap];
    if !(_minRank in _ranks) then {
        WARNING_2("role '%1' gates on rank '%2', which the structure does not have - not locking",_roleClass,_minRank);
    } else {
        private _needArma = (_ranks get _minRank) getOrDefault ["armaRank", ""];
        private _haveArma = (_ranks getOrDefault [_rankId, createHashMap]) getOrDefault ["armaRank", ""];
        private _needIdx = ARMA_RANK_INDEX(_needArma);
        private _haveIdx = ARMA_RANK_INDEX(_haveArma);
        _need pushBack (((_ranks get _minRank) getOrDefault ["abbrev", toUpper _minRank]) + "+");
        if (_haveIdx < _needIdx) then {
            _why pushBack ([
                format ["%1 needs %2 or above; you have no rank on record.", _roleName, (_ranks get _minRank) getOrDefault ["name", _minRank]],
                format ["%1 needs %2 or above; you are %3.", _roleName, (_ranks get _minRank) getOrDefault ["name", _minRank], ["ranks", _rankId] call FUNC(lookup)]
            ] select (_rankId isNotEqualTo ""));
        };
    };
};

// ---- skills ----------------------------------------------------------------
if (_required isNotEqualTo []) then {
    private _skills = GVAR(structure) getOrDefault ["skills", createHashMap];
    private _missing = [];
    {
        if !(_x in _skills) then {
            WARNING_2("role '%1' requires skill '%2', which the structure does not have - ignoring it",_roleClass,_x);
            continue;
        };
        private _abbrev = (_skills get _x) getOrDefault ["abbrev", ""];
        _need pushBack ([toUpper _x, _abbrev] select (_abbrev isNotEqualTo ""));
        if !(_x in _skillIds) then {_missing pushBack ((_skills get _x) getOrDefault ["name", _x])};
    } forEach _required;
    if (_missing isNotEqualTo []) then {
        _why pushBack format ["%1 needs the %2 skill%3 - an admin assigns it in TAC//PAC.", _roleName, _missing joinString " and ", ["", "s"] select (count _missing > 1)];
    };
};

[_why isEqualTo [], _why joinString " ", _need joinString " "]
