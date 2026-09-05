#include "script_component.hpp"
/*
 * Author: Ghost
 * Puts the local player's radio channel where everyone else's squad table can
 * read it.
 *
 * ONLY WHEN IT CHANGES. A public variable is a network message, and sixteen
 * players broadcasting an unchanged string every few seconds is sixteen messages
 * a second saying nothing. Almost every tick is a no-op.
 *
 * Arguments (CBA per-frame handler):
 * 0: Arguments <ARRAY> - unused
 * 1: Handle <NUMBER> - unused
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["", ""];

if (isNull player) exitWith {};

private _channel = [] call FUNC(radioState);
if (_channel isEqualTo (player getVariable [QGVAR(radio), ""])) exitWith {};

player setVariable [QGVAR(radio), _channel, true];

// THE RAW SETTING RIDES ALONG - [system, channel] - because the display
// string can be read but not dialled. FUNC(radioTune) is what dials it.
private _raw = [];
if (!isNil "acre_api_fnc_getCurrentRadio") then {
    private _r = [] call acre_api_fnc_getCurrentRadio;
    if (_r isNotEqualTo "") then {_raw = ["acre", [_r] call acre_api_fnc_getRadioChannel]};
} else {
    if (!isNil "TFAR_fnc_activeSwRadio") then {
        private _r = call TFAR_fnc_activeSwRadio;
        if (isNil "_r") then {_r = ""};
        if (_r isNotEqualTo "") then {_raw = ["tfar", [_r] call TFAR_fnc_getSwChannel]};
    };
};
player setVariable [QGVAR(radioRaw), _raw, true];
