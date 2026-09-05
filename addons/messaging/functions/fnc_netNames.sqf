#include "script_component.hpp"
/*
 * Author: YonV
 * The named nets, in the order they are drawn and opened, from ONE place.
 *
 * THREE SOURCES, ASKED IN ORDER. TAC//PAC's structure first - its "nets"
 * section is the unit's database (or profile) copy of config_nets.hpp, each
 * net a record {id, name, order}, so a unit that keeps its nets in the
 * database gets them here without a mission file. Then the mission's own
 * GHOSTFR_Nets, read exactly as the server always read it. Then the addon
 * setting, for a mission that declares none.
 *
 * The server opens a mailbox per name (XEH_postInit, FUNC(netsApply)) and
 * every client draws its rail from the same list (FUNC(railNets)), which is
 * what keeps the two from drifting.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Net names, in order <ARRAY>
 *
 * Example:
 * private _nets = [] call ghostD_messaging_fnc_netNames
 *
 * Public: Yes
 */

private _pac = (missionNamespace getVariable ["ghostD_pac_structure", createHashMap]) getOrDefault ["nets", createHashMap];
if (_pac isEqualType createHashMap && {count _pac > 0}) exitWith {
    private _rows = [];
    {
        private _order = if (_y isEqualType createHashMap) then {_y getOrDefault ["order", 0]} else {0};
        if !(_order isEqualType 0) then {_order = 0};
        _rows pushBack [_order, _x];
    } forEach _pac;
    _rows sort true;
    _rows apply {_x # 1}
};

private _cfg = missionConfigFile >> "GHOSTFR_Nets" >> "nets";
if (isArray _cfg) exitWith {
    ((getArray _cfg) apply {
        if (_x isEqualType []) then {_x param [0, ""]} else {_x}
    }) select {_x isEqualType "" && _x isNotEqualTo ""}
};

(((missionNamespace getVariable [QGVAR(namedBoxes), ""]) splitString ",") apply {trim _x}) select {_x isNotEqualTo ""}
