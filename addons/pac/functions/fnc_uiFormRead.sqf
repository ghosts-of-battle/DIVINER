#include "script_component.hpp"
/*
    File: fnc_uiFormRead.sqf
    Author: YonV
    Description: Read the form back - every row FUNC(uiForm) laid out, as
        key -> value. Text comes back as typed, a number parsed, a choice as
        the value behind the label, yes/no as a boolean.

    Parameters:
        None

    Returns:
        key -> value <HASHMAP>
*/

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
private _out = createHashMap;
if (isNull _display) exitWith {_out};

{
    _x params ["_key", "_kind", "_n"];
    private _v = switch (_kind) do {
        case "c": {
            private _combo = _display displayCtrl PAC_IDC_FORM_COMBO(_n);
            private _i = lbCurSel _combo;
            if (_i < 0) then {""} else {_combo lbData _i}
        };
        case "b": {
            private _combo = _display displayCtrl PAC_IDC_FORM_COMBO(_n);
            private _i = lbCurSel _combo;
            _i >= 0 && {(_combo lbData _i) isEqualTo "true"}
        };
        case "n": {parseNumber (ctrlText (_display displayCtrl PAC_IDC_FORM_EDIT(_n)))};
        default {ctrlText (_display displayCtrl PAC_IDC_FORM_EDIT(_n))};
    };
    _out set [_key, _v];
} forEach GVAR(uiFormKeys);

_out
