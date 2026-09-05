#include "script_component.hpp"
/*
    File: fn_motorpool_tab.sqf
    Author: YonV/Ghost
    Description: Activates one category tab - restyles the row (active tab
        inverted, the mockup's treatment), clears the search and refills.

    Arguments:
    0: Tab index <NUMBER>

    Example:
    [0] call ghostD_vehicle_fnc_motorpool_tab;
*/

params [["_idx", 0, [0]]];

private _d = uiNamespace getVariable ["YMF_motorpool_dlg", displayNull];
if (isNull _d) exitWith {};

private _cats = uiNamespace getVariable ["YMF_motorpool_cats", []];
if (_idx >= count _cats) exitWith {};
uiNamespace setVariable ["YMF_motorpool_tab", _idx];

(uiNamespace getVariable ["YMF_motorpool_theme", []]) params ["_ground", "_ink"];

for "_i" from 0 to 7 do {
    private _ctrl = _d displayCtrl (110 + _i);
    if (_i < count _cats) then {
        _ctrl ctrlSetText ((_cats select _i) select 0);
        _ctrl ctrlShow true;
        if (_i isEqualTo _idx) then {
            _ctrl ctrlSetBackgroundColor _ink;
            _ctrl ctrlSetTextColor _ground;
        } else {
            _ctrl ctrlSetBackgroundColor _ground;
            _ctrl ctrlSetTextColor _ink;
        };
    } else {
        _ctrl ctrlShow false;
    };
};

(_d displayCtrl 120) ctrlSetText "";
[] call ghostD_vehicle_fnc_motorpool_fill;
