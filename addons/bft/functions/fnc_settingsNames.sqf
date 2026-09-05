#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Builds the call sign children of the BFT menu from the mission's name list.
 * The name is the group id itself, so it follows the group everywhere the game
 * shows it, not just onto the marker.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Player <OBJECT>
 * 2: Parameters <ARRAY>
 *
 * Return Value:
 * ACE child actions <ARRAY>
 *
 * Example:
 * [player, player, []] call ghostD_bft_fnc_settingsNames
 *
 * Public: No
 */

params ["_target", "_player", "_params"];

private _iconColour = group ACE_player getVariable [QGVAR(color), [side group ACE_player, true] call BIS_fnc_sideColor];
_iconColour = (getArray (configFile >> "CfgMarkerColors" >> _iconColour >> "color")) call BIS_fnc_colorConfigToRGBA;
_iconColour = _iconColour call BIS_fnc_colorRGBtoHTML;

private _actions = [];

{
    private _name = _x;

    private _statement = {
        params ["_target", "_player", "_params"];
        group ACE_player setGroupIdGlobal [_params];
    };

    // Only A-Z have a letter tile; anything else borrows the pen.
    private _letter = toUpper (_name select [0, 1]);
    private _icon = QPATHTOF(ui\icons\pen.paa);
    if (_letter in ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]) then {
        _icon = format [QPATHTOF(ui\icons\letter\%1.paa), _letter];
    };

    _actions pushBack [
        [
            format ["%1_%2", QGVAR(names), _name],
            _name,
            [_icon, _iconColour],
            _statement,
            {true},
            {},
            _name
        ] call ace_interact_menu_fnc_createAction,
        [],
        _target
    ];
} forEach ((GVAR(nameOptions) splitString ",") apply {trim _x} select {_x isNotEqualTo ""});

_actions
