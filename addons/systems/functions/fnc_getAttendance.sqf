#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV tinkered with by YonV
 * This function return players that have connected to the server.
 * It will print it to your RPT log.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Array of players
 *
 * Example:
 * call ghostD_systems_fnc_getAttendance
 *
 */

private _playerLog = missionNamespace getVariable [QEGVAR(log,players), []];

// Rpt 
["=================================================== START", "Attendance"] call EFUNC(diag,info);
[format ["Attendance (Entries: %1)", count _playerLog], "Attendance"] call EFUNC(diag,info);
{
    _x params ["_name"];
    [_name, "Attendance",  false, false] call EFUNC(diag,info);
} forEach _playerLog;

["=================================================== END", "Attendance"] call EFUNC(diag,info);


// Notification
["Attendance", "All attended players have been written to your RPT log.", NOTE_INFO] call GHOSTFUNC(notify,notify);

_playerLog
