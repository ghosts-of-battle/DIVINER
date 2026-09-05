#include "script_component.hpp"
/*
 * Author: YonV
 * Opens a mailbox for every named net that has none yet. Server only.
 *
 * The server opens the mission's nets once settings are in (XEH_postInit).
 * A unit whose nets live in TAC//PAC's database gets them a little later -
 * when PAC's boot has adopted the structure - and PAC calls this then, so
 * the boxes exist before anyone can address them. Idempotent: a box that is
 * already open is left exactly as it is, traffic and all.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * How many mailboxes were opened <NUMBER>
 *
 * Example:
 * [] call ghostD_messaging_fnc_netsApply
 *
 * Public: Yes
 */

if (!isServer) exitWith {0};

private _made = 0;
{
    if !(("B:" + _x) in GVAR(boxes)) then {
        [_x, "named", _x] call FUNC(srvBox);
        _made = _made + 1;
    };
} forEach ([] call FUNC(netNames));

if (_made > 0) then {INFO_1("nets from the structure: %1 mailbox(es) opened",_made)};

_made
