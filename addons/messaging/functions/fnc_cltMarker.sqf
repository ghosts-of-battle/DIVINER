#include "script_component.hpp"
/*
 * Author: Ghost
 * Draws or removes a message's map marker on this client. Local markers rather
 * than global ones, so a contact report marks the map of the side that sent it
 * and nobody else's.
 *
 * An empty position is the removal case, which keeps one event and one handler
 * for both halves of a marker's life - the alternative is two handlers and one
 * of them eventually not being called.
 *
 * Arguments (CBA event):
 * 0: Marker name <STRING>
 * 1: Position, [] to remove <ARRAY>
 * 2: Marker text <STRING> (optional, default "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_name", "", [""]], ["_pos", [], [[]]], ["_text", "", [""]]];

if (!hasInterface || _name == "") exitWith {};

if (_pos isEqualTo []) exitWith {
    deleteMarkerLocal _name;
};

private _marker = createMarkerLocal [_name, _pos];
if (_marker == "") exitWith {};

_marker setMarkerTypeLocal GVAR(ticMarkerType);
_marker setMarkerColorLocal GVAR(ticMarkerColor);
_marker setMarkerTextLocal _text;
