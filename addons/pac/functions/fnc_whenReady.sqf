#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_whenReady

Description:
    Runs code once the PAC store is loaded and published - at once if it
    already is, else when the server raises the flag. For mission scripts
    that must not open the role menu, slot anyone or read the roster before
    the data is there. Any machine.

    A boot sequence in one line:
        [{ [] call myMission_fnc_openSlotting }] call ghostD_pac_fnc_whenReady;

Parameters:
    0: Code to run <CODE>
    1: Seconds to wait before giving up, 0 = never <NUMBER> (optional, default 0)

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_code", {}, [{}]], ["_timeout", 0, [0]]];

if (missionNamespace getVariable [QGVAR(ready), false]) exitWith {call _code};

[_code, _timeout] spawn {
    params ["_code", "_timeout"];
    private _t0 = diag_tickTime;
    waitUntil {
        sleep 0.5;
        (missionNamespace getVariable [QGVAR(ready), false]) || {_timeout > 0 && {diag_tickTime - _t0 > _timeout}}
    };
    if !(missionNamespace getVariable [QGVAR(ready), false]) then {
        WARNING_1("whenReady: gave up after %1 s - the store never came up",_timeout);
    };
    call _code;
};
