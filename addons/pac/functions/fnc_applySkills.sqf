#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_applySkills

Description:
    Applies a player's PAC skills to their unit, as the effects each skill
    declares in the structure.

    A SKILL IS A NAME FOR A SET OF EFFECTS. The handoff lists what an effect can
    be: an ACE medic, engineer or EOD class; a custom trait such as isISR or
    isJFO; and arbitrary setVariable pairs for anything else, Simplex gates
    included. So an effect is a string in one of three shapes -

        "medic:1"                ACE medical class  (0 none, 1 CLS, 2 medic)
        "engineer:2"             ACE engineer class (0, 1, 2)
        "eod:1"                  ACE explosives
        "trait:isISR"            a unit variable set true, broadcast
        "var:someName=someValue" any setVariable, value compiled if it is
                                 true/false/number, kept as a string otherwise

    - and this is the one place that knows what those shapes mean.

    CLEARED FIRST, THEN APPLIED. Every variable this function has ever set on
    the unit is set back to nil before the new set goes on, so a skill taken
    away actually goes away. The list of what it set is kept on the unit for
    that purpose - the same trick FUNC(setupPlayer) plays with
    YMF_myCustomVariables, and for the same reason.

    NO SKILLS IS NO SKILLS. A player nobody has
    assigned anything to arrives with the ACE classes at 0 and no traits, and
    that is the handoff's DECIDED answer, not an oversight. Assigning is the
    admin panel's job.

    LOCAL TO THE UNIT. setUnitTrait needs the unit local, so this is
    remoteExec'd to the owner.

Parameters:
    0: The unit <OBJECT>
    1: skillIds <ARRAY of STRING>

Returns:
    How many effects were applied <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_skillIds", [], [[]]]];

if (isNull _unit || {!local _unit}) exitWith {0};

// ---- clear what we set last time -------------------------------------------
{
    _unit setVariable [_x, nil, true];
} forEach (_unit getVariable [QGVAR(setVars), []]);

_unit setVariable ["ace_medical_medicClass", 0, true];
_unit setVariable ["ACE_IsEngineer", 0, true];
_unit setVariable ["ACE_isEOD", false, true];
_unit setUnitTrait ["Medic", false];
_unit setUnitTrait ["Engineer", false];
_unit setUnitTrait ["ExplosiveSpecialist", false];

private _setVars = [];
private _applied = 0;
private _skills = GVAR(structure) getOrDefault ["skills", createHashMap];

private _fnc_effect = {
    params ["_effect"];
    private _parts = _effect splitString ":";
    if (count _parts < 2) exitWith {
        WARNING_1("skill effect '%1' is not kind:value - skipped",_effect);
        false
    };
    private _kind = toLower trim (_parts # 0);
    private _val = trim ((_parts select [1]) joinString ":");
    switch (_kind) do {
        case "medic": {
            private _n = (parseNumber _val) max 0 min 2;
            _unit setVariable ["ace_medical_medicClass", _n, true];
            _unit setUnitTrait ["Medic", _n > 0];
        };
        case "engineer": {
            private _n = (parseNumber _val) max 0 min 2;
            _unit setVariable ["ACE_IsEngineer", _n, true];
            _unit setUnitTrait ["Engineer", _n > 0];
        };
        case "eod": {
            private _on = (parseNumber _val) > 0;
            _unit setVariable ["ACE_isEOD", _on, true];
            _unit setUnitTrait ["ExplosiveSpecialist", _on];
        };
        case "trait": {
            _unit setVariable [_val, true, true];
            _setVars pushBackUnique _val;
        };
        case "var": {
            private _kv = _val splitString "=";
            if (count _kv < 2) exitWith {
                WARNING_1("skill effect '%1' is var without name=value - skipped",_effect);
                false
            };
            private _name = trim (_kv # 0);
            private _raw = trim ((_kv select [1]) joinString "=");
            private _value = switch (true) do {
                case (_raw isEqualTo "true"): {true};
                case (_raw isEqualTo "false"): {false};
                case (_raw isEqualTo str (parseNumber _raw)): {parseNumber _raw};
                default {_raw};
            };
            _unit setVariable [_name, _value, true];
            _setVars pushBackUnique _name;
        };
        default {
            WARNING_2("skill effect '%1' has unknown kind '%2' - skipped",_effect,_kind);
            false
        };
    };
    true
};

{
    private _skill = _skills getOrDefault [_x, createHashMap];
    if (count _skill isEqualTo 0) then {
        WARNING_1("skill '%1' is not in the structure - skipped",_x);
        continue;
    };
    {
        if ([_x] call _fnc_effect) then {_applied = _applied + 1};
    } forEach (_skill getOrDefault ["effects", []]);
} forEach _skillIds;

// THEN THE SESSION'S TEMPORARY EFFECTS on top - what the admin console applied
// for tonight (ghostD_pac_tempEffects). Cleared at respawn, never stored.
{
    if ([_x] call _fnc_effect) then {_applied = _applied + 1};
} forEach (_unit getVariable [QGVAR(tempEffects), []]);

_unit setVariable [QGVAR(setVars), _setVars];

TRACE_3("skills applied",name _unit,count _skillIds,_applied);

_applied
