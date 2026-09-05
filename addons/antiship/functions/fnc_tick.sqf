#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_tick

Description:
    Scheduler. When the interval elapses, finds a hull and puts a missile into it.

    ONE LAUNCHER, ONE CLOCK. This hung off the battery module's logic in ghost,
    which owned several launchers and one interval between them. There is no
    module: a hand-placed launcher carries its own config and its own clock, so
    the thing passed in here is the launcher itself.

    The clock is reset whether or not anything was found. A battery that keeps
    retrying every tick because the sea happens to be empty would fire the
    instant a ship appeared, which is not a coastal battery, it is a trap.

Parameters (CBA PFH): 0: [launcher], 1: handle

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_args", "_handle"];
_args params ["_launcher"];

if (isNull _launcher) exitWith { [_handle] call CBA_fnc_removePerFrameHandler };

private _cfg = _launcher getVariable [QGVAR(cfg), nil];
if (isNil "_cfg") exitWith {};

if (CBA_missionTime < (_launcher getVariable [QGVAR(nextFire), 1e11])) exitWith {};
_launcher setVariable [QGVAR(nextFire), CBA_missionTime + (_cfg get "interval")];

private _tgt = [_cfg] call FUNC(pickTarget);
if (isNull _tgt) exitWith {
    if (_cfg get "debug") then {
        diag_log text "[ghostD_antiship] no hull in range this cycle";
    };
};

[_tgt, _cfg] call FUNC(launch);
