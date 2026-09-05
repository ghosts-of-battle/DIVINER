#include "script_component.hpp"
/*
    File: fn_motorpool_fill.sqf
    Author: YonV/Ghost
    Description: Fills the vehicle list for the active tab, filtered by the
        search box. The SPAWNED tab lists this controller's ledger instead -
        vehicle, spawner's name - and flips the action button to REMOVE.
        Row data carries the classname, or "s:<index>" into the ledger.

    Example:
    [] call ghostD_vehicle_fnc_motorpool_fill;
*/

private _d = uiNamespace getVariable ["YMF_motorpool_dlg", displayNull];
if (isNull _d) exitWith {};

private _cats = uiNamespace getVariable ["YMF_motorpool_cats", []];
private _tab = uiNamespace getVariable ["YMF_motorpool_tab", 0];
(uiNamespace getVariable ["YMF_motorpool_ctx", [objNull, objNull]]) params ["_controller"];
(uiNamespace getVariable ["YMF_motorpool_theme", []]) params ["", "_ink"];
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];

(_cats param [_tab, ["", []]]) params ["_label", "_classes"];
private _spawnedMode = _label isEqualTo "SPAWNED";

private _lnb = _d displayCtrl 130;
lnbClear _lnb;

private _needle = toUpper ctrlText (_d displayCtrl 120);

if (_spawnedMode) then {
    // prune the dead so the list and the ledger agree
    private _spawned = (_controller getVariable ["YMF_spawnedVehicles", []]) select {!isNull (_x select 0)};
    _controller setVariable ["YMF_spawnedVehicles", _spawned, true];

    {
        _x params ["_veh", "_owner"];
        private _name = toUpper getText (configOf _veh >> "displayName");
        if (_needle isEqualTo "" || {_needle in _name}) then {
            private _row = _lnb lnbAddRow [_name, toUpper _owner];
            _lnb lnbSetData [[_row, 0], format ["s:%1", _forEachIndex]];
            _lnb lnbSetColor [[_row, 0], _ink];
            _lnb lnbSetColorRight [[_row, 1], _mute];
        };
    } forEach _spawned;

    (_d displayCtrl 121) ctrlSetText format ["%1 HERE", count _spawned];
    (_d displayCtrl 127) ctrlSetText "Spawned at this pad - REMOVE deletes the selected vehicle when it is empty";
    (_d displayCtrl 170) ctrlSetText "REMOVE VEHICLE";
} else {
    {
        private _class = _x;
        private _name = toUpper getText (configFile >> "CfgVehicles" >> _class >> "displayName");
        if (_needle isEqualTo "" || {_needle in _name}) then {
            private _crew = [_class, true] call BIS_fnc_crewCount;
            private _pax = getNumber (configFile >> "CfgVehicles" >> _class >> "transportSoldier");
            private _seats = if (_pax > 0) then {
                format ["%1 SEAT%2 + %3 PAX", _crew, ["S", ""] select (_crew == 1), _pax]
            } else {
                format ["%1 SEAT%2", _crew, ["S", ""] select (_crew == 1)]
            };

            private _row = _lnb lnbAddRow [_name, _seats];
            _lnb lnbSetData [[_row, 0], _class];
            _lnb lnbSetColor [[_row, 0], _ink];
            _lnb lnbSetColorRight [[_row, 1], _mute];
        };
    } forEach _classes;

    (_d displayCtrl 121) ctrlSetText format ["%1 TYPES", lnbSize _lnb select 0];
    (_d displayCtrl 127) ctrlSetText "Spawns on the pad, facing its heading";
    (_d displayCtrl 170) ctrlSetText "SPAWN VEHICLE";
};

if ((lnbSize _lnb select 0) > 0) then {
    _lnb lnbSetCurSelRow 0;
} else {
    [] call ghostD_vehicle_fnc_motorpool_select;
};
