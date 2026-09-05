#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structureApply

Description:
    Puts a structure that has just become final INTO EFFECT on the server:
    the report deck registered (FUNC(templatesApply)), the live slot table
    rebuilt from the ORBAT (ghostD_groups_fnc_orbatApply - nobody seated is
    thrown out), the platoon-tag cache dropped, the radio plan written to
    the ghostFR_radio_* globals (FUNC(radioApply)), a mailbox opened for
    every net that has none (ghostD_messaging_fnc_netsApply). Called by
    the boot once the structure is settled, and by FUNC(structureImport)
    when an admin pastes a new one. Clients do their part in
    FUNC(takeServer).

Parameters:
    0: From the boot <BOOL> - narrate through FUNC(bootLog) rather than the
       .rpt alone (optional, default false)

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_boot", false, [false]]];

if (!isServer) exitWith {};

private _fnc_say = {
    params ["_msg"];
    if (_boot) then {["3/6", _msg] call FUNC(bootLog)} else {INFO_1("%1",_msg)};
};

private _deckN = [] call FUNC(templatesApply);
if (_deckN > 0) then {[format ["report deck from the structure: %1 template(s) registered", _deckN]] call _fnc_say};

if (!isNil "ghostD_groups_fnc_orbatApply") then {
    if ([] call ghostD_groups_fnc_orbatApply) then {
        [format ["ORBAT from the structure applied to the slot table: %1 squad(s)", count YMF_dynamicGroups]] call _fnc_say;
    };
};
missionNamespace setVariable ["ghostD_messaging_platoonTagCache", nil];

if ([GVAR(structure) getOrDefault ["radio", createHashMap]] call FUNC(radioApply)) then {
    ["radio plan from the structure written to the ghostFR_radio_* globals"] call _fnc_say;
};

if (!isNil "ghostD_messaging_fnc_netsApply") then {
    private _boxes = [] call ghostD_messaging_fnc_netsApply;
    if (_boxes > 0) then {[format ["nets from the structure: %1 mailbox(es) opened", _boxes]] call _fnc_say};
};
