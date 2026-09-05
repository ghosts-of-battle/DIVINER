#include "script_component.hpp"
/*
 * Author: Ghost
 * Retunes the local player's current radio to another unit's published
 * channel - the platoon roster's TUNE button.
 *
 * The target's channel arrives as the [system, channel] pair their own client
 * published - see FUNC(radioPublish) - because neither radio mod will answer
 * for anybody but the caller. Tuning only works within one system: a mission
 * runs ACRE or TFAR, not both, and a pair from the other system is refused
 * rather than guessed at.
 *
 * Arguments:
 * 0: Unit whose channel to tune to <OBJECT>
 *
 * Return Value:
 * Tuned <BOOL>
 *
 * Example:
 * [ghost_tacpad_apps_squadSelected] call ghostD_tacpad_apps_fnc_radioTune
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {false};

(_unit getVariable [QGVAR(radioRaw), []]) params [["_sys", "", [""]], ["_ch", -1, [0]]];
if (_sys isEqualTo "" || _ch < 0) exitWith {false};

if (_sys isEqualTo "acre" && {!isNil "acre_api_fnc_getCurrentRadio"}) exitWith {
    private _radio = [] call acre_api_fnc_getCurrentRadio;
    if (_radio isEqualTo "") exitWith {false};
    [_radio, _ch] call acre_api_fnc_setRadioChannel;
    true
};

if (_sys isEqualTo "tfar" && {!isNil "TFAR_fnc_activeSwRadio"}) exitWith {
    private _radio = call TFAR_fnc_activeSwRadio;
    if (isNil "_radio") then {_radio = ""};
    if (_radio isEqualTo "") exitWith {false};
    if (isNil "TFAR_fnc_setSwChannel") exitWith {false};
    [_radio, _ch] call TFAR_fnc_setSwChannel;
    true
};

false
