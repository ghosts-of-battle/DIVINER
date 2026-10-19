#include "script_component.hpp"
/*
    File: fnc_uiName.sqf
    Author: YonV
    Description: A player's name off the published roster, from a uid - or
        the uid itself when they are not on it, so a page never shows a
        blank where a person should be.

    Parameters:
        0: UID <STRING>

    Returns:
        Name <STRING>
*/

params [["_uid", "", [""]]];

if (_uid isEqualTo "") exitWith {""};
private _row = (missionNamespace getVariable [QGVAR(roster), []]) select {(_x # 0) isEqualTo _uid};
if (_row isEqualTo []) exitWith {_uid};
(_row # 0) # 1
