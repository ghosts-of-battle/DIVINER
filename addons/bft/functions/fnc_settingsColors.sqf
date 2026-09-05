#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Builds the colour children of the BFT menu. Same two-call split as the icons:
 * preferred first, the rest behind "Other colors".
 *
 * Each entry is drawn with the group's CURRENT icon in the candidate colour, so
 * the list previews the marker rather than a swatch.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Player <OBJECT>
 * 2: Parameters, 0: show preferred only <ARRAY>
 *
 * Return Value:
 * ACE child actions <ARRAY>
 *
 * Example:
 * [player, player, [true]] call ghostD_bft_fnc_settingsColors
 *
 * Public: No
 */

params ["_target", "_player", "_params"];
_params params [["_showPreferred", false, [true]]];

private _blacklist = (GVAR(colorsBlacklist) splitString ",") apply {toUpper trim _x} select {_x isNotEqualTo ""};
private _preferred = (GVAR(preferredColors) splitString ",") apply {toUpper trim _x} select {_x isNotEqualTo ""};

private _markerShape = [group ACE_player] call FUNC(getGroupMarkerShape);
private _markerType = group ACE_player getVariable [QGVAR(type), "inf"];
private _interactIcon = getText (configFile >> "CfgMarkers" >> format ["%1_%2", _markerShape, _markerType] >> "icon");

private _actions = [];

{
    private _color = _x;

    if (_color in _blacklist) then {continue};

    // This list is one half or the other, never both.
    if ((_color in _preferred) isNotEqualTo _showPreferred) then {continue};

    private _cfg = configFile >> "CfgMarkerColors" >> _color;
    private _iconColour = (getArray (_cfg >> "color")) call BIS_fnc_colorConfigToRGBA call BIS_fnc_colorRGBtoHTML;

    private _statement = {
        params ["_target", "_player", "_params"];
        group ACE_player setVariable [QGVAR(color), _params, true];
    };

    _actions pushBack [
        [
            format ["%1_%2", QGVAR(colors), _color],
            getText (_cfg >> "name"),
            [_interactIcon, _iconColour],
            _statement,
            {true},
            {},
            _color
        ] call ace_interact_menu_fnc_createAction,
        [],
        _target
    ];
} forEach GVAR(availableMarkerColors);

_actions
