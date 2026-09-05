/*
    File: fn_changeViewByHotkey.sqf
    Author: Dom
    Description: Handles an update to view distance when a hotkey is pressed
*/
if !(DT_viewDistanceEnabled) exitWith {};
params [
    ["_value",100,[0]],
    ["_hotkey","1",[""]]
];

if (viewDistance isNotEqualTo _value) then {
    setViewDistance _value;
};
if ((getObjectViewDistance select 0) isNotEqualTo _value) then {
    setObjectViewDistance _value;
};

private _viewVar = [] call DT_fnc_getVarByVehicle;
_viewVar set [0,_value];
_viewVar set [1,_value];

if (DT_notificationsEnabled) then {
    ["View Distance", format ["View distance changed: %1m (Hotkey %2).",_value,_hotkey], [0.61, 0.67, 0.73, 1]] call ghostD_notify_fnc_notify;
};
