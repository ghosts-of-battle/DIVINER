#include "script_component.hpp"
/*
    File: fnc_applyRecv.sqf
    Author: YonV
    Description: The answer to FUNC(applyAsk) or FUNC(applySubmit), on the
        player's machine: their own application as it stands (status
        "none" when there is not one, "nodb" when the server has no
        database), kept for the tacpad's APPLICATION tab, which is redrawn
        if it is open.

    Parameters:
        0: The application <HASHMAP>

    Returns:
        Nothing
*/

params [["_app", createHashMap, [createHashMap]]];

if (!hasInterface) exitWith {};
GVAR(myApplication) = _app;
GVAR(applySeen) = true;
GVAR(applyAt) = diag_tickTime;

// the answers already given prefill the form, once
if (count GVAR(applyAnswers) isEqualTo 0) then {
    private _answers = _app getOrDefault ["answers", createHashMap];
    if (_answers isEqualType createHashMap) then {GVAR(applyAnswers) = +_answers};
};

if ((missionNamespace getVariable [QGVAR(view), ""]) isEqualTo "apply" && {!isNil "ghostD_tacpad_fnc_openApp"}) then {
    if !(isNull (uiNamespace getVariable ["ghostD_tacpad_appGroup", controlNull])) then {
        {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
    };
};
