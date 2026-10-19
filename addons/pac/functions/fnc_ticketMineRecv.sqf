#include "script_component.hpp"
/*
    File: fnc_ticketMineRecv.sqf
    Author: YonV
    Description: The answer to FUNC(ticketMine), on the member's machine:
        their requests are kept and the tacpad's PAC tile redrawn if it is
        open on the REQUESTS view.

    Parameters:
        0: Tickets <ARRAY of HASHMAP>
        1: Whether the database answered <BOOL>

    Returns:
        Nothing
*/

params [["_tickets", [], [[]]], ["_ok", true, [true]]];

if (!hasInterface) exitWith {};
GVAR(myTickets) = _tickets;
GVAR(myTicketsOk) = _ok;
GVAR(myTicketsAt) = diag_tickTime;
GVAR(myTicketsSeen) = true;

if ((missionNamespace getVariable [QGVAR(view), ""]) in ["requests", "request"] && {!isNil "ghostD_tacpad_fnc_openApp"}) then {
    if !(isNull (uiNamespace getVariable ["ghostD_tacpad_appGroup", controlNull])) then {
        {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
    };
};
