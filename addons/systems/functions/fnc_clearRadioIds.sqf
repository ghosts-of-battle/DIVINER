#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function return a funtion icon path or path provided.
 *
 * Arguments:
 * nothing
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call ymf_fnc_clearRadioIds
 *
 */

if (!EGVAR(Patches,usesACRE) && !EGVAR(Patches,usesTFAR)) exitWith {};
if (!EGVAR(Settings,enableRadios)) exitWith {};
if (!EGVAR(init,isPlayer)) exitWith {};

// ACRE
if (EGVAR(patches,usesACRE)) exitWith {
    private _playerRadios = [] call acre_api_fnc_getCurrentRadioList;

    {
        private _base = [_x] call acre_api_fnc_getBaseRadio;
        player removeItem _x;
        player addItem _base;
    } forEach _playerRadios;

    [{
        [player] call EFUNC(players,setRadioChannel);
        [ghostFR_radio_acreActiveRadio] call EFUNC(players,setActiveRadio);
    }] call CBA_fnc_execNextFrame;

    ["Radios", "Your radios have been reset.", NOTE_GOOD] call GHOSTFUNC(notify,notify);

    SHOW_CHAT_SERVER_INFO_1("ClearRadioID","%1: Your radios have been reset",name player)
};

// TFAR - re-apply the channel plan and active radio (TFAR has no stuck radio-ID issue to clear)
if (EGVAR(patches,usesTFAR)) exitWith {
    [{
        [player] call EFUNC(players,setRadioChannel);
        [ghostFR_radio_tfarActiveRadio] call EFUNC(players,setActiveRadio);
    }] call CBA_fnc_execNextFrame;

    ["Radios", "Your radios have been reset.", NOTE_GOOD] call GHOSTFUNC(notify,notify);

    SHOW_CHAT_SERVER_INFO_1("ClearRadioID","%1: Your radios have been reset",name player)
};

SHOW_CHAT_ERROR("ClearRadioID","Fatal");
