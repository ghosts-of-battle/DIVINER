#include "script_component.hpp"
/*
 * Author: Ghost
 * Draws the tracked members on the map, the way the engine draws a squad:
 * the vanilla iconman circle - facing wedge baked into the texture, rotated
 * to the man's heading - coloured by his fire team, name beside it. Runs on
 * the map control's Draw event every frame, off the member list FUNC(draw)
 * rebuilds on its own tick; this file decides nothing about WHO, only how
 * they look.
 *
 * Arguments (Draw event):
 * 0: The map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

#define MEMBER_ICON "\A3\ui_f\data\map\VehicleIcons\iconman_ca.paa"
#define MEMBER_SIZE 24

params [["_map", controlNull, [controlNull]]];

if (!GVAR(enabled) || GVAR(memberMarkers) isEqualTo 0) exitWith {};

private _members = GVAR(memberUnits);
if (isNil "_members" || {_members isEqualTo []}) exitWith {};

// The engine's own team colours, near enough - MAIN stays white the way
// the vanilla squad view leaves the unassigned.
private _colors = createHashMapFromArray [
    ["MAIN", [1, 1, 1, 1]],
    ["RED", [0.9, 0.25, 0.25, 1]],
    ["GREEN", [0.2, 0.8, 0.25, 1]],
    ["BLUE", [0.25, 0.45, 0.9, 1]],
    ["YELLOW", [0.85, 0.85, 0.1, 1]]
];

{
    if (isNull _x || {!alive _x}) then {continue};

    _map drawIcon [
        MEMBER_ICON,
        _colors getOrDefault [assignedTeam _x, [1, 1, 1, 1]],
        getPosATLVisual _x,
        MEMBER_SIZE,
        MEMBER_SIZE,
        getDirVisual _x,
        name _x,
        1,
        0.035,
        "RobotoCondensed",
        "left"
    ];
} forEach _members;
