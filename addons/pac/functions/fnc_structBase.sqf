#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structBase

Description:
    The real structure section behind a screen id.

    THE ROLE EDITOR IS EIGHT SCREENS ON ONE SECTION (2026-09-09, to match the
    website: "would love for each section to be a page to it self"). A role
    carries twenty properties and the screen has three edit boxes, so it is
    split the way the website splits it - identity, gates, nets, tiles, traits,
    variables, loadout, arsenal - and each of those is an entry in the section
    combo. They all read and write ONE section, "roles"; only the labels differ.

    So: everything before the first underscore. "roles_nets" is the roles
    section; "ranks" is itself. Anything that has no underscore is unchanged,
    which is every section that existed before this.

Parameters:
    0: Screen section id <STRING>

Returns:
    The structure section it reads and writes <STRING>

Example:
    ["roles_loadout"] call ghostD_pac_fnc_structBase   // "roles"

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_section", "", [""]]];

private _at = _section find "_";
if (_at < 0) exitWith {_section};

_section select [0, _at]
