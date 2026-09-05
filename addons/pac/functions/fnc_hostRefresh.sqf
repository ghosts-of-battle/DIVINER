#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_hostRefresh

Description:
    THE PLAYER-HOSTED SERVER'S OWN COPY OF THE CLIENT HANDLERS. On a hosted
    game the host is server and client in one namespace, and publicVariable
    does not fire the sender's own addPublicVariableEventHandler - so every
    time the server publishes for its clients, the host's screen is the one
    machine that does not hear it. The middle column of the admin page came
    back through a direct reply (FUNC(adminRecv)); the roster list, the
    summary block, the structure editor and the management window did not
    (user, 2026-09-05: "the admin panel is not showing my rank change after
    it's made in PAC, and it is showing in game").

    Called by every server function right after it publishes. On a dedicated
    server (no interface) or on a client it does nothing.

    WHY NOT FUNC(applyOnClient) FOR THE ROSTER. The remote handler calls it,
    and it asks the server for slotting, loadouts and the OPORD - round trips
    that on the host would run FUNC(seedFromUnit) and publish again, and this
    again. FUNC(panelReapply) is the local half - the host's own rank and
    skills off the roster row - which is all a publish should change.

Parameters:
    0: What was published <STRING> - "roster" | "structure"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_what", "roster", [""]]];

if (!isServer || !hasInterface) exitWith {};

switch (_what) do {
    case "roster": {
        [] call FUNC(panelReapply);
        [] call FUNC(panelFillRoster);    // no-op unless the admin page is open
        [] call FUNC(manageSection);      // the operator list in the management window
    };
    case "structure": {
        [] call FUNC(takeServer);
        [] call FUNC(structSection);      // no-op unless the editor is open
        [] call FUNC(panelOpened);        // combos on the roster page re-list too
        [] call FUNC(manageSection);      // the ORBAT lists in the management window
    };
};
