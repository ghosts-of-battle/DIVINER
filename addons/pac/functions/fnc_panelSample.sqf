#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelSample

Description:
    SEED SAMPLE / REMOVE SAMPLE on the admin page - see FUNC(seedSample).
    Seeding is additive and reversible so it does not ask; removing asks,
    because it is the one that deletes.

Parameters:
    0: Mode <STRING> - "add" | "remove"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_mode", "add", [""]]];

if (_mode isEqualTo "add") exitWith {
    [player, "add"] remoteExec [QFUNC(seedSample), 2];
};

[] spawn {
    private _yes = ["Remove every sample record, its sessions and the sample op window? Real players are not touched.", "TAC//PAC - REMOVE SAMPLE", "Remove", "Cancel"] call BIS_fnc_guiMessage;
    if (_yes) then {
        [player, "remove"] remoteExec [QFUNC(seedSample), 2];
    };
};
