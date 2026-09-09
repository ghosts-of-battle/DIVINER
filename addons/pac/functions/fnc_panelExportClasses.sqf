#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelExportClasses

Description:
    EXPORT CLASSES on the admin page: asks the server to write every classname
    it has loaded to <unit>.classes, for the web manager's editors.

    IT ASKS FIRST because it walks the whole config and writes a document that
    can run to tens of thousands of entries - not something to set off by
    brushing a button. It says roughly how big the answer will be, since that
    is the part an admin cannot guess.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

if (GVAR(summary) getOrDefault ["readOnly", false]) exitWith {
    ["TAC//PAC", "Store is read-only: it was written by a newer PAC.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

[] spawn {
    private _yes = [
        "Write every classname this server has loaded to the database?\n\nWeapons, magazines, items, backpacks and vehicles - scope 2 only. The web manager's arsenal and motorpool editors then offer real classnames instead of a text box.\n\nRun it again after changing the modset.",
        "TAC//PAC - EXPORT CLASSES",
        "Export",
        "Cancel"
    ] call BIS_fnc_guiMessage;

    if (_yes) then {
        [player] remoteExec [QFUNC(exportClasses), 2];
        ["TAC//PAC", "Exporting - the server will say how many when it is done.", [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
    };
};
