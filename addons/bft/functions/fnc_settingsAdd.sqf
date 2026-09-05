#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Builds the group leader's BFT menu: name, icon, colour and the tracker switch,
 * under ACE self interaction while the map is open. Added to CAManBase with
 * inheritance rather than to the player object, so it survives respawn and unit
 * switching without being rebuilt.
 *
 * Only the leader of a group sees it - one marker, one owner.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ghostD_bft_fnc_settingsAdd
 *
 * Public: No
 */

if (!hasInterface || GVAR(settingsAdded)) exitWith {};
GVAR(settingsAdded) = true;

private _path = ["ACE_SelfActions", QGVAR(main)];

// The map is the only place this makes sense, and only for the man whose marker
// it is. Everything below inherits that check by hanging off this entry.
private _main = [
    QGVAR(main),
    "BFT",
    QPATHTOF(ui\icons\BFT.paa),
    {},
    {
        GVAR(enabled)
        && GVAR(mapSettings)
        && {visibleMap}
        && {leader group ACE_player isEqualTo ACE_player}
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions"], _main, true] call ace_interact_menu_fnc_addActionToClass;

// --- Colour ----------------------------------------------------------------
// Two entries onto one builder: the preferred list first, the rest folded away
// behind "Other colors", so a full CfgMarkerColors does not bury the six a
// mission actually uses.
private _colors = [
    QGVAR(colors),
    "Color",
    QPATHTOF(ui\icons\colorWheel.paa),
    {},
    {true},
    FUNC(settingsColors),
    [true]
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path, _colors, true] call ace_interact_menu_fnc_addActionToClass;

private _colorsOther = [
    QGVAR(colorsOther),
    "Other colors",
    QPATHTOF(ui\icons\plus.paa),
    {},
    {true},
    FUNC(settingsColors)
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path + [QGVAR(colors)], _colorsOther, true] call ace_interact_menu_fnc_addActionToClass;

// --- Name ------------------------------------------------------------------
private _name = [
    QGVAR(names),
    "Name",
    QPATHTOF(ui\icons\pen.paa),
    {},
    {true},
    FUNC(settingsNames)
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path, _name, true] call ace_interact_menu_fnc_addActionToClass;

// --- Icon ------------------------------------------------------------------
private _icons = [
    QGVAR(icons),
    "Icon",
    QPATHTOF(ui\icons\BFT.paa),
    {},
    {true},
    FUNC(settingsIcons),
    [true]
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path, _icons, true] call ace_interact_menu_fnc_addActionToClass;

private _iconsOther = [
    QGVAR(iconsOther),
    "Other icons",
    QPATHTOF(ui\icons\plus.paa),
    {},
    {true},
    FUNC(settingsIcons)
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path + [QGVAR(icons)], _iconsOther, true] call ace_interact_menu_fnc_addActionToClass;

// --- Tracker on / off ------------------------------------------------------
private _enable = [
    QGVAR(enable),
    "Enable tracker",
    QPATHTOF(ui\icons\on.paa),
    {
        group ACE_player setVariable [QGVAR(visible), true, true];
    },
    {!(group ACE_player getVariable [QGVAR(visible), false])}
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path, _enable, true] call ace_interact_menu_fnc_addActionToClass;

private _disable = [
    QGVAR(disable),
    "Disable tracker",
    QPATHTOF(ui\icons\off.paa),
    {
        group ACE_player setVariable [QGVAR(visible), false, true];
    },
    {group ACE_player getVariable [QGVAR(visible), false]}
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, _path, _disable, true] call ace_interact_menu_fnc_addActionToClass;
