#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageRemove

Description:
    REMOVE in the management window: asks, then takes the selected ORBAT
    item out through FUNC(adminOrbat). Only the ORBAT sections offer it.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display) exitWith {};

private _section = GVAR(mgSection);
private _kind = switch (_section) do {
    case "squads": {"squad"};
    case "platoons": {"platoon"};
    case "radionets": {"radioNet"};
    default {""};
};
if (_kind isEqualTo "" || GVAR(mgKey) isEqualTo "") exitWith {};

[_kind, GVAR(mgKey)] spawn {
    params ["_kind", "_key"];
    private _what = switch (_kind) do {
        case "squad": {format ["Remove squad '%1' and its slots? Anyone seated in it goes back to the role screen, and every squad below it moves up one SR channel.", _key]};
        case "platoon": {format ["Remove platoon tab '%1'? Its squads show under UNASSIGNED and lose the platoon net.", _key]};
        default {format ["Remove radio net '%1'? Its squads fall back to their platoon's net.", _key]};
    };
    private _yes = [_what, "TAC//PAC - REMOVE", "Remove", "Cancel"] call BIS_fnc_guiMessage;
    if (_yes) then {
        ghostD_pac_mgKey = "";
        [player, _kind, "remove", _key, createHashMap] remoteExec ["ghostD_pac_fnc_adminOrbat", 2];
    };
};
