#include "script_component.hpp"
/*
 * Author: Reeveli
 * Fills the menu's list box and puts the target marker on the map.
 *
 * Arguments:
 * 0: The list box <CONTROL>
 *
 * Return Value: None
 *
 * Public: No
 */

params [["_control", controlNull, [controlNull]]];

if (!hasInterface || {isNull _control}) exitWith {false};

// ONLY THE POINTS THIS PLAYER MAY USE. The list was drawn from every point on
// the map, so a man could see - and select - somewhere his side's action would
// never have offered him.
private _mine = side player;

{
    _x params ["_object", "_name", ["_pside", sideEnemy]];
    if (isNull _object) then {continue};
    if (_pside isNotEqualTo _mine) then {continue};

    // THE ROW'S OWN INDEX, not the loop's. lbSetData was being given
    // _forEachIndex, which is the position in the POINT LIST - so as soon as
    // one point was skipped or dead, every row carried another row's name and
    // OK sent you to the wrong place.
    private _row = _control lbAdd _name;
    _control lbSetData [_row, _name];
} forEach (missionNamespace getVariable [QTP_LIST, []]);

createMarkerLocal [QGVAR(marker), [0, 0, 0]];
QGVAR(marker) setMarkerShapeLocal "ICON";
QGVAR(marker) setMarkerTypeLocal "respawn_inf";
QGVAR(marker) setMarkerColorLocal ([_mine, true] call BIS_fnc_sideColor);
QGVAR(marker) setMarkerAlphaLocal 0;

_control lbSetCurSel 0;
