#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelBackup

Description:
    The BACKUP row on the admin page.

        export     the store as JSON, to the clipboard and the .rpt
        structure  the structure as JSON plus its hash - the delta tool's
                   input, for comparing two servers' configs
        import     merge whatever JSON is on the clipboard into the store
        restore    replace the store with the clipboard's JSON, after asking

    Import and restore read the clipboard HERE - the server has no clipboard
    - and send the text up; FUNC(import) does the checking and answers with
    a notification.

Parameters:
    0: Mode <STRING> - "export" | "structure" | "import" | "restore"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_mode", "", [""]]];

private _red = [0.831, 0.267, 0.267, 1];

switch (_mode) do {
    case "export": {
        [player, "export", ""] remoteExec [QFUNC(adminText), 2];
    };
    case "structure": {
        [player, "structure", ""] remoteExec [QFUNC(adminText), 2];
    };
    case "structureImport": {
        private _text = copyFromClipboard;
        if (_text isEqualTo "") exitWith {["TAC//PAC", "The clipboard is empty.", _red] call EFUNC(notify,notify)};
        // guiMessage blocks until answered, so it runs scheduled.
        [_text] spawn {
            params ["_text"];
            private _yes = ["Replace the structure - ranks, skills, roles, ORBAT, nets, radio plan, deck, orders - with the config on your clipboard? It takes effect at once and is kept in the server's profile (and the service).", "TAC//PAC - STRUCTURE IN", "Import", "Cancel"] call BIS_fnc_guiMessage;
            if (_yes) then {
                [player, _text] remoteExec ["ghostD_pac_fnc_structureImport", 2];
            };
        };
    };
    case "import": {
        private _text = copyFromClipboard;
        if (_text isEqualTo "") exitWith {["TAC//PAC", "The clipboard is empty.", _red] call EFUNC(notify,notify)};
        [player, _text, "merge"] remoteExec [QFUNC(import), 2];
    };
    case "restore": {
        private _text = copyFromClipboard;
        if (_text isEqualTo "") exitWith {["TAC//PAC", "The clipboard is empty.", _red] call EFUNC(notify,notify)};
        // guiMessage blocks until answered, so it runs scheduled.
        [_text] spawn {
            params ["_text"];
            private _yes = ["Replace EVERY player record, session and window on the server with the clipboard's contents? This cannot be undone from the panel.", "TAC//PAC - RESTORE FULL", "Restore", "Cancel"] call BIS_fnc_guiMessage;
            if (_yes) then {
                [player, _text, "restore"] remoteExec [QFUNC(import), 2];
            };
        };
    };
};
