#include "script_component.hpp"
/*
    File: fnc_pgWindowStart.sqf
    Author: YonV
    Description: Start an operation window - a name, and START. Attendance
        counts against it until an admin stops it on the dashboard.

    Parameters:
        None

    Returns:
        Nothing
*/

["Start an operation window", "Dashboard"] call FUNC(uiTitle);

private _y = [[
    ["name", "Name", "t", ""]
], PAC_UI_TOP] call FUNC(uiForm);
["A window is what attendance is counted against. It stays open across a server restart; stop it on the dashboard when the op is over.", _y + 0.006, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);

[[
    ["START", {
        private _f = [] call FUNC(uiFormRead);
        private _name = trim (_f getOrDefault ["name", ""]);
        if (_name isEqualTo "") exitWith {["Give the window a name.", true] call FUNC(uiHint)};
        [player, "start", _name] remoteExec [QFUNC(windowSet), 2];
        [] call FUNC(uiBack);
    }]
]] call FUNC(uiButtons);
