#include "script_component.hpp"
/*
 * Author: YonV
 * Sets which of the engine's own voice channels this player may talk on, under
 * a base-game voice (VON) plan.
 *
 * THE PLAN'S SWITCHES. Side voice only when ghostFR_radio_vonSide, Command only
 * when ghostFR_radio_vonCommand, Global only for an admin when
 * ghostFR_radio_vonGlobalAdminsOnly (the default) - and Group, Vehicle and
 * Direct always on. VOICE ONLY: each channel's text chat is left as the mission
 * set it.
 *
 * NO PLAN, NO CHANGE. With no vonNets written the plan is the fallback C2 net
 * (FUNC(vonNets)) and nothing else is changed - so this puts back whatever it
 * changed before, from GVAR(vonBaseline), the channels as they were the first
 * time it ran.
 *
 * WHO IS AN ADMIN is the mod's one answer, ghostD_adminpanel_fnc_isAdmin, else
 * the `#login` flag ghostD_common_isAdmin. It is asked again every
 * VON_CLIENT_INTERVAL seconds (the postInit), so logging in mid-mission opens
 * Global; a call with nothing changed does nothing.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ghostD_players_fnc_vonClient
 *
 * Public: No
 */

if (!hasInterface || {!EGVAR(common,von)} || {isNull player}) exitWith {};
if !(missionNamespace getVariable [QEGVAR(Settings,enableRadios), true]) exitWith {};

private _all = [VON_CH_GLOBAL, VON_CH_SIDE, VON_CH_COMMAND, VON_CH_GROUP, VON_CH_VEHICLE, VON_CH_DIRECT];
if (isNil QGVAR(vonBaseline)) then {
    GVAR(vonBaseline) = _all apply {(channelEnabled _x) # 1};
};

private _voice = +GVAR(vonBaseline);
if !(([] call FUNC(vonNets)) # 1) then {
    private _admin = if (isNil "ghostD_adminpanel_fnc_isAdmin") then {
        player getVariable ["ghostD_common_isAdmin", false]
    } else {
        [player] call ghostD_adminpanel_fnc_isAdmin
    };
    // REAL BOOLEANS IN THE DATABASE (the website stores JSON true/false and
    // fromJson hands them over as such), but a hand-written plan or a
    // stringified copy may say "true", "false", 1 or 0 - all read the same.
    // Anything else is the key's default: Side and Command shut, Global
    // admins-only.
    private _fnc_bool = {
        params ["_value", "_default"];
        switch (true) do {
            case (_value isEqualType true): {_value};
            case (_value isEqualType 0): {_value != 0};
            case (_value isEqualType "" && {(toLower trim _value) in ["true", "1"]}): {true};
            case (_value isEqualType "" && {(toLower trim _value) in ["false", "0"]}): {false};
            default {_default};
        }
    };
    private _adminsOnly = [missionNamespace getVariable ["ghostFR_radio_vonGlobalAdminsOnly", true], true] call _fnc_bool;
    _voice = [
        _admin || {!_adminsOnly},
        [missionNamespace getVariable ["ghostFR_radio_vonSide", false], false] call _fnc_bool,
        [missionNamespace getVariable ["ghostFR_radio_vonCommand", false], false] call _fnc_bool,
        true,
        true,
        true
    ];
};

if (_voice isEqualTo (missionNamespace getVariable [QGVAR(vonVoice), []])) exitWith {};
GVAR(vonVoice) = _voice;

{
    _x enableChannel [(channelEnabled _x) # 0, _voice # _forEachIndex];
} forEach _all;

INFO_1("VON","voice channels (global, side, command, group, vehicle, direct): %1",_voice);
