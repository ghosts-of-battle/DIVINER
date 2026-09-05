#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageExport

Description:
    EXPORT in the management window: the log as text (from the rows this
    machine holds), an operator's file as JSON in the unit's own shape
    (FUNC(adminText) "operator" -> FUNC(operatorJson)), or the ORBAT as
    JSON - to the clipboard and the .rpt.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

switch (GVAR(mgSection)) do {
    case "log": {
        private _lines = [format ["TAC//PAC action log - %1 of %2 row(s), newest first, generated %3", count GVAR(logRows), GVAR(logTotal), [] call FUNC(stamp)], ""];
        {
            _x params [["_id", ""], ["_when", ""], ["_byUid", ""], ["_byName", ""], ["_type", ""], ["_targetUid", ""], ["_target", ""], ["_detail", ""]];
            _lines pushBack format ["%1  %2  %3 (%4)  %5  %6%7  %8", _id, _when, _byName, _byUid, _type, _target, ["", " (" + _targetUid + ")"] select (_targetUid isNotEqualTo ""), _detail];
        } forEach GVAR(logRows);
        ["Action log", _lines joinString endl] call FUNC(textRecv);
    };
    case "operators": {
        if (GVAR(editUid) isEqualTo "") exitWith {["TAC//PAC", "Pick an operator first.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};
        [player, "operator", GVAR(editUid)] remoteExec [QFUNC(adminText), 2];
    };
    default {
        [player, "orbat", ""] remoteExec [QFUNC(adminText), 2];
    };
};
