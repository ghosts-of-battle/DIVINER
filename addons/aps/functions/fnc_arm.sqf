#include "script_component.hpp"
/*
 * Arm the system: set the switches, read the overrides, start the sweep.
 *
 * THE MODULE USED TO BE THE ONLY WAY IN, AND THAT WAS WRONG (user, 2026-08-29:
 * "no live tile for aps in a vehicle with aps", "never told me about the
 * module"). A mission with no Ghost - APS module placed got nothing at all from
 * this addon: no vehicle was ever registered, so every vehicle reported
 * ghost_aps_fit = "NONE" and the HUD tile correctly drew "NO APS". So APS arms
 * ITSELF from its CBA settings at postInit, and the module is an override for
 * a mission that wants different switches or a tier/fit table of its own.
 *
 * THE MODULE'S WORD BEATS THE SETTINGS WHENEVER IT ARRIVES. Module init runs
 * after most postInits, so the common order is settings first, module second -
 * and the first version dropped the module's tables on the floor in that case
 * with a warning nobody reads. Now a module arriving after the system armed
 * re-reads the switches and the tables and refits every vehicle to them
 * (fnc_refit). A second arming from settings alone changes nothing. The sweep
 * is started exactly once either way.
 *
 * Arguments:
 * 0: The module logic, or objNull when arming from settings alone <OBJECT>
 *
 * Return Value:
 * Applied <BOOL> - false when switched off in settings, or already armed and
 * nothing new to apply
 */

params [["_logic", objNull, [objNull]]];

if (!isServer) exitWith { false };
if (!GVAR(enabled)) exitWith {
    INFO("APS is switched off in settings - not arming");
    false
};

private _again = GVAR(moduleUp);
if (_again && {isNull _logic}) exitWith { false };
GVAR(moduleUp) = true;

// The module's own switches beat the settings; with no module the settings
// stand as they are.
private _flag = {
    params ["_name", "_default"];
    if (isNull _logic) exitWith { _default };
    (_logic getVariable [_name, [0, 1] select _default]) > 0
};

GVAR(hardKill) = ["hardKill", GVAR(hardKill)] call _flag;
GVAR(rfBurst) = ["rfBurst", GVAR(rfBurst)] call _flag;
GVAR(rfAir) = ["rfAir", GVAR(rfAir)] call _flag;
GVAR(debug) = ["debug", GVAR(debug)] call _flag;

private _parsePairs = {
    params ["_text", "_into", "_valueFn"];
    {
        private _pair = _x splitString ": ";
        if (count _pair >= 2) then {
            private _v = [_pair select 1] call _valueFn;
            if (!isNil "_v") then { _into set [toLower (_pair select 0), _v] };
        };
    } forEach ((_text splitString ",;") apply { trim _x } select { _x isNotEqualTo "" });
};

// The setting's table first, then the module's on top of it.
private _tierFn = {
    private _n = parseNumber (_this select 0);
    if (_n >= 0 && _n <= 4) then { _n }
};
GVAR(tierOverride) = createHashMap;
[GVAR(tierOverrides), GVAR(tierOverride), _tierFn] call _parsePairs;
if (!isNull _logic) then {
    [_logic getVariable ["tierOverrides", ""], GVAR(tierOverride), _tierFn] call _parsePairs;
};

GVAR(fitOverride) = createHashMap;
if (!isNull _logic) then {
    [_logic getVariable ["fitOverrides", ""], GVAR(fitOverride), {
        private _spec = toUpper (_this select 0);
        private _rf = "+RF" in _spec;
        private _fit = (_spec splitString "+") param [0, ""];
        if (_fit in [FIT_NONE, FIT_BASIC, FIT_LIGHT, FIT_MEDIUM, FIT_HEAVY, FIT_ENHANCED]) then { [_fit, _rf] }
    }] call _parsePairs;
};

// hoisted: a comma inside an array literal splits a macro argument, and
// INFO_4 then sees six of them
private _how = ["settings", "module"] select (!isNull _logic);
if (_again) then { _how = "module, after settings - refitting" };
private _overrides = count GVAR(tierOverride) + count GVAR(fitOverride);
INFO_4("APS armed (%1) - hard kill %2, RF burst %3, %4 override(s)",_how,GVAR(hardKill),GVAR(rfBurst),_overrides);

if (_again) then {
    call FUNC(refit);
} else {
    [LINKFUNC(sweep), APS_SWEEP, []] call CBA_fnc_addPerFrameHandler;
};
true
