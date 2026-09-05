#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Builds the icon children of the BFT menu. Called twice from two entries: once
 * for the preferred icons and once for everything else, which is why the split
 * is a parameter rather than two lists.
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
 * [player, player, [true]] call ghostD_bft_fnc_settingsIcons
 *
 * Public: No
 */

params ["_target", "_player", "_params"];
_params params [["_showPreferred", false, [true]]];

private _blacklist = (GVAR(iconsBlacklist) splitString ",") apply {toLower trim _x} select {_x isNotEqualTo ""};
private _preferred = (GVAR(preferredIcons) splitString ",") apply {toLower trim _x} select {_x isNotEqualTo ""};

private _markerShape = [group ACE_player] call FUNC(getGroupMarkerShape);

// The group's current colour, as the tint for every icon in the list - you pick
// an icon and see it in the colour it will actually appear in.
private _iconColour = group ACE_player getVariable [QGVAR(color), [side group ACE_player, true] call BIS_fnc_sideColor];
_iconColour = (getArray (configFile >> "CfgMarkerColors" >> _iconColour >> "color")) call BIS_fnc_colorConfigToRGBA;
_iconColour = _iconColour call BIS_fnc_colorRGBtoHTML;

private _actions = [];

{
    private _icon = toLower _x;

    if (_icon in _blacklist) then {continue};

    // This list is one half or the other, never both.
    if ((_icon in _preferred) isNotEqualTo _showPreferred) then {continue};

    private _marker = configFile >> "CfgMarkers" >> format ["%1_%2", _markerShape, _icon];

    private _statement = {
        params ["_target", "_player", "_params"];
        group ACE_player setVariable [QGVAR(type), _params, true];
    };

    _actions pushBack [
        [
            format ["%1_%2", QGVAR(icons), _icon],
            getText (_marker >> "name"),
            [getText (_marker >> "icon"), _iconColour],
            _statement,
            {true},
            {},
            _icon
        ] call ace_interact_menu_fnc_createAction,
        [],
        _target
    ];
} forEach GVAR(availableMarkerIcons);

_actions
