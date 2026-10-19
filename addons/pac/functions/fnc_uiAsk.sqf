#include "script_component.hpp"
/*
    File: fnc_uiAsk.sqf
    Author: YonV
    Description: Have we got this from the server yet? If not, ask for it
        and say "loading" - the answer comes back through FUNC(uiRecv),
        which redraws the page.

        A page that needs the tickets, the applications, the document list,
        one document, or one operator's whole record calls this first and
        stops if it answers false.

    Parameters:
        0: What <STRING> - "tickets" | "applications" | "questions" |
           "ticketKinds" | "docs" | "doc:<key>" | "record:<uid>" | "opordDef"
        1: Arguments for the server <ARRAY> (optional)
        2: Ask again even if it is here <BOOL> (optional)

    Returns:
        Whether the data is here <BOOL>
*/

params [["_what", "", [""]], ["_args", [], [[]]], ["_again", false, [false]]];

if (isNil QGVAR(uiData)) then {GVAR(uiData) = createHashMap};
if (_again) then {GVAR(uiData) deleteAt _what};
if (_what in GVAR(uiData)) exitWith {true};

GVAR(uiWaiting) pushBackUnique _what;
["Loading from the database ...", false] call FUNC(uiHint);

if ((_what select [0, 7]) isEqualTo "record:") then {
    [player, _what select [7]] remoteExec [QFUNC(adminGet), 2];
} else {
    [player, _what, _args] remoteExec [QFUNC(adminDocs), 2];
};
false
