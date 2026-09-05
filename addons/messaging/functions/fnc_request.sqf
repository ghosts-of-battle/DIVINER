#include "script_component.hpp"
/*
 * Author: Ghost
 * Asks the server for this player's index - one row per thread they can see,
 * with no message bodies. Called once when the player exists and again after a
 * reconnect, because the client cache is disposable by design and refetching is
 * cheaper than keeping it correct across a disconnect.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ghostD_messaging_fnc_request
 *
 * Public: Yes
 */

if (isNull player) exitWith {};

[QGVAR(requestIndex), [player]] call CBA_fnc_serverEvent;
