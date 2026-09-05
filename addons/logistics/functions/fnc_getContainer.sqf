#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A, SPC.Turn.J
 * This function return a array of content
 *
 * Arguments:
 * 0: Crate type <STRING>
 * 1: Return only keys <BOOLEAN>
 *
 * Return:
 * ARRAY of items and amounts or items or empty
 *
 * Example:
 * [""] call ghostD_logistics_fnc_getContainer;
 * ["", false] call ghostD_logistics_fnc_getContainer;
 *
 * Public: Yes
 */

params [
    ["_key", "", [""]], 
    ["_keysOnly", false, [false]]
];

if (_key == "") exitWith {
    // [] and not nil. Every caller feeds this straight into setCargo, which
    // wants an array, and a bare exitWith hands it nil instead.
    WARNING("Logistics","asked for a container with no key.");
    []
};

// THE MAP, BEFORE THE KEY. This read EGVAR(init,DATABASE) and went straight
// into getOrDefaultCall: with the database not yet built - or built empty,
// which is what a mission that hands over no catalogue gets - that returns nil
// WITHOUT running the default block, so nothing warned and the failure surfaced
// at the bottom as "<key> returned null", blaming a key that was fine.
private _containerMap = EGVAR(init,DATABASE);
if (isNil "_containerMap" || {!(_containerMap isEqualType createHashMap)}) exitWith {
    ERROR_1("Logistics","the logistics database is not built - cannot answer for %1.",_key);
    []
};

private _container = _containerMap getOrDefaultCall [_key, {
    WARNING_1("Logistics","%1 does not exist.",_key);
    []
}];

// Belt and braces: a hashmap CAN hold nil through some paths, and everything
// below and every caller above is written for an array.
if (isNil "_container") then {
    ERROR_1("Logistics","%1 is in the database with no value.",_key);
    _container = [];
};

if (_keysOnly) then {
     private _containerItemMap = createHashMapFromArray _container;
     _container = keys _containerItemMap;
};

_container
