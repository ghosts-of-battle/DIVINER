#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function sets a player's radio channels based on their squad name.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * ["bob"] call ymf_fnc_setRadioChannel
 *
 * Public: No
 */

params [["_player", objNull, [objNull]]];

if (!EGVAR(Patches,usesACRE) && !EGVAR(Patches,usesTFAR)) exitWith {};
if (!EGVAR(Settings,enableRadios)) exitWith {};
if (!EGVAR(init,isPlayer)) exitWith {};


// ACRE
if (EGVAR(patches,usesACRE)) exitWith {
    _player setVariable [QEGVAR(Player,RadioChannel), []];
    private _playerRadios = [_player] call acre_api_fnc_getCurrentRadioList;
    {
        if (_x != "") then {
            private _radio = [_x] call acre_api_fnc_getBaseRadio;
            private _channel = [[_player] call EFUNC(players,unit_getSquadName), _radio] call FUNC(getRadioChannel);

            [_x, _channel] call acre_api_fnc_setRadioChannel;
            INFO_3("Radio","%1 radio (%2) has its channel set to %3",_player,_x,_channel);

            // Store radio channels in variable.
            private _radioAndChannel = _player getVariable [QEGVAR(Player,RadioChannel), []];
            _radioAndChannel pushBack [_radio, _channel];
            _player setVariable [QEGVAR(Player,RadioChannel), _radioAndChannel];

        } else {
            SHOW_SERVER_WARNING_1("Radio","Empty radio is trying to get it's channel applied for %1",_player);
        };
    } forEach _playerRadios;
};


// TFAR - write the SW/LR channel plans into the player's radios and tune each to their squad net.
// SW (pnr1000a) everyone carries; LR only if the player has a backpack radio. Frequencies are set
// per channel (1-based); the active channel is selected 0-based (matches TFAR_fnc_set*Channel).
if (EGVAR(patches,usesTFAR)) exitWith {
    private _squad = toUpper ([_player] call EFUNC(players,unit_getSquadName));
    private _swIdx = ghostFR_radio_tfarSwFallback;
    private _lrIdx = ghostFR_radio_tfarLrFallback;
    {
        _x params ["_name","_sw","_lr"];
        if (toUpper _name isEqualTo _squad) exitWith { _swIdx = _sw; _lrIdx = _lr; };
    } forEach ghostFR_radio_tfarNets;

    // SW handheld
    private _sw = call TFAR_fnc_activeSwRadio;
    if (!isNil "_sw" && {_sw isEqualType "" && _sw isNotEqualTo ""}) then {
        { [_sw, _forEachIndex + 1, _x] call TFAR_fnc_setChannelFrequency; } forEach ghostFR_radio_tfarSrFreqs;
        [_sw, _swIdx] call TFAR_fnc_setSwChannel;
        INFO_3("Radio","%1 SW radio (%2) tuned to net index %3",_player,_sw,_swIdx);
    };

    // LR backpack (only if carried)
    if (call TFAR_fnc_haveLRRadio) then {
        private _lr = call TFAR_fnc_activeLrRadio;
        if (!isNil "_lr" && {_lr isEqualType "" && _lr isNotEqualTo ""}) then {
            { [_lr, _forEachIndex + 1, _x] call TFAR_fnc_setChannelFrequency; } forEach ghostFR_radio_tfarLrFreqs;
            [_lr, _lrIdx] call TFAR_fnc_setLrChannel;
            INFO_3("Radio","%1 LR radio (%2) tuned to net index %3",_player,_lr,_lrIdx);
        };
    };
};

SHOW_CHAT_ERROR("Radio","Fatal");
