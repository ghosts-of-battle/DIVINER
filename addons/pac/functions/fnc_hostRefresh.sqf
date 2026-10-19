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
    it's made in PAC, and it is showing in game"). Since 2026-09-09 there is
    one dialog and one redraw, FUNC(uiRefresh). Since 2026-09-09 there is
    one dialog and one redraw, FUNC(uiRefresh). Since 2026-09-09 there is
    one dialog and one redraw, FUNC(uiRefresh).

    Called by every server function right after it publishes. On a dedicated
    server (no interface) or on a client it does nothing.

    WHY NOT FUNC(applyOnClient) FOR THE ROSTER. The remote handler calls it,
    and it asks the server for slotting, loadouts and the OPORD - round trips
    that on the host would run FUNC(seedFromUnit) and publish again, and this
    again. FUNC(reapplyLocal) is the local half - the host's own rank and
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
        [] call FUNC(reapplyLocal);
        ["roster"] call FUNC(uiRefresh);      // the one dialog, if a table page is open
    };
    case "structure": {
        [] call FUNC(takeServer);
        ["structure"] call FUNC(uiRefresh);
    };
};
