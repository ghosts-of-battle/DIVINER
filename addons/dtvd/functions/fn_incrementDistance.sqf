/*
    File: fn_incrementDistance.sqf
    Author: Dom
    Description: Handles an update to view distance when the increment hotkey is pressed
*/
if !(DT_viewDistanceEnabled) exitWith {};
params [
    ["_value",100,[0]],
    ["_add",true,[false]]
];

private _newViewDistance = if (_add) then {(viewDistance + _value) min DT_viewDistanceMax} else {(viewDistance - _value) max 200};
setViewDistance _newViewDistance;
setObjectViewDistance _newViewDistance;

private _viewVar = [] call DT_fnc_getVarByVehicle;
_viewVar set [0,_newViewDistance];
_viewVar set [1,_newViewDistance];

if (DT_notificationsEnabled) then {
    private _symbol = ["-", "+"] select (_add);
    ["View Distance", format ["View distance changed: %1m (%2%3m).",_newViewDistance,_symbol,_value], [0.61, 0.67, 0.73, 1]] call ghostD_notify_fnc_notify;
};
