#include "script_component.hpp"
/*
 * Author: Ghost
 * Receives this player's whole index from the server and replaces the local one.
 * A replace rather than a merge: the server's answer is the truth, and a merge
 * would keep rows for threads the player has since lost access to.
 *
 * Arguments (CBA event):
 * 0: Index entries <ARRAY> - each the array form of an index HashMap
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_entries", [], [[]]]];

GVAR(index) = _entries apply {createHashMapFromArray _x};

[QGVAR(indexRefreshed), []] call CBA_fnc_localEvent;
