#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_alarmAdd

Description:
    Server side of an armed alarm. The list is kept here and publicVariable'd
    rather than left on the setter's machine, for the reason alarm clocks are
    not worn on the wrist of the person who set them: the wake-up has to happen
    whether or not that person is still around. Each entry carries an id so a
    clear can pull it out from under its own waiter, which then simply finds
    its id gone and does nothing.

    Firing removes the entry first and rings second, so a ring can never be
    doubled by a clear racing it.

Parameters:
    _delay : NUMBER - seconds from now.
    _name  : STRING - who set it, for the ring notification.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_delay", 0, [0]], ["_name", "someone", [""]]];

if (_delay <= 0) exitWith {};

private _id = GVAR(alarmNextId);
GVAR(alarmNextId) = _id + 1;
private _at = CBA_missionTime + _delay;

GVAR(alarms) pushBack [_id, _at, _name];
publicVariable QGVAR(alarms);

[{
    params ["_id", "_at"];
    CBA_missionTime >= _at || {GVAR(alarms) findIf { (_x select 0) == _id } == -1}
}, {
    params ["_id", "", "_name"];
    private _i = GVAR(alarms) findIf { (_x select 0) == _id };
    if (_i == -1) exitWith {};      // cleared while it waited
    GVAR(alarms) deleteAt _i;
    publicVariable QGVAR(alarms);
    [QGVAR(alarmRing), [_name]] call CBA_fnc_globalEvent;
}, [_id, _at, _name]] call CBA_fnc_waitUntilAndExecute;
