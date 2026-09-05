#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelCsv

Description:
    IMPORT CSV on the admin page: asks the server to read pac_roster.csv from
    the mission and write it into the store (FUNC(csvImport)). Asks first,
    because it changes the roster.

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
    private _yes = ["Import pac_roster.csv from the mission into the roster? Rows update the records they name by Steam id and leave the rest; new ids are added.", "TAC//PAC - IMPORT CSV", "Import", "Cancel"] call BIS_fnc_guiMessage;
    if (_yes) then {
        [player, "pac_roster.csv"] remoteExec ["ghostD_pac_fnc_csvImport", 2];
    };
};
