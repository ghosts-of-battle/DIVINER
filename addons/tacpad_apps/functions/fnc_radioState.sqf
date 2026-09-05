#include "script_component.hpp"
/*
 * Author: Ghost
 * The local player's radio channel, as a line short enough for a table column.
 *
 * BOTH RADIO MODS ONLY ANSWER FOR YOU. ACRE and TFAR expose the channel of the
 * radio in the caller's own hands and neither will tell you what someone else is
 * set to - so a squad table cannot ask, and every client has to publish its own.
 * FUNC(radioPublish) is the other half of that.
 *
 * Neither mod loaded is a state, not a fault: the suite is meant to be assembled
 * from whatever a mission has, and the column says so rather than inventing a
 * frequency.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Channel, "" when there is no radio mod or no radio in hand <STRING>
 *
 * Example:
 * private _ch = [] call ghostD_tacpad_apps_fnc_radioState
 *
 * Public: No
 */

if (!hasInterface) exitWith {""};

// ACRE first, arbitrarily - a mission with both loaded has bigger problems than
// which one this column reads.
if (!isNil "acre_api_fnc_getCurrentRadio") exitWith {
    private _radio = [] call acre_api_fnc_getCurrentRadio;
    if (_radio isEqualTo "") exitWith {""};

    private _channel = [_radio] call acre_api_fnc_getRadioChannel;
    private _name = "";
    if (!isNil "acre_api_fnc_getRadioChannelName") then {
        _name = [_radio, _channel] call acre_api_fnc_getRadioChannelName;
    };

    if (_name isEqualType "" && _name isNotEqualTo "") exitWith {format ["CH %1 - %2", _channel, _name]};
    format ["CH %1", _channel]
};

if (!isNil "TFAR_fnc_activeSwRadio") exitWith {
    private _radio = call TFAR_fnc_activeSwRadio;
    if (isNil "_radio") then {_radio = ""};
    if (_radio isEqualTo "") exitWith {""};

    private _channel = [_radio] call TFAR_fnc_getSwChannel;
    private _freq = "";
    if (!isNil "TFAR_fnc_getSwFrequency") then {
        _freq = str ([_radio] call TFAR_fnc_getSwFrequency);
    };

    if (_freq != "") exitWith {format ["CH %1 - %2", _channel + 1, _freq]};
    format ["CH %1", _channel + 1]
};

""
