#include "script_component.hpp"
/*
    File: fnc_orbat.sqf
    Author: YonV
    Description: The unit's ORBAT - the squads and their slots, the platoon
        tabs, the shared radio nets and the faction's name - from ONE place.
        TAC//PAC keeps it in the unit's database (or the profile) as the
        structure's "orbat" section when that is loaded and has one;
        otherwise it is the mission's Dynamic_Groups, read the way it always
        was. Every reader of group_setup / Platoons / RadioNets /
        faction_name in the mod asks this instead, so a unit that edits its
        ORBAT in the database sees the edit in the group menu, the radio
        plan, the platoon tags and the nets alike.

        Shapes, the mission's own:
            groups     [[name, [roleClass, ...], conditionString], ...]  - order
                       is the SR radio block order, so it is never re-sorted
            platoons   [[id, name, callsign, net, [squadName, ...]], ...]
            radioNets  [[id, net, [squadName, ...]], ...]   - nets that cross a
                       platoon boundary; asked before the platoon's own net
            faction    the name over the role screen
            side       "WEST" | "EAST" | "GUER" | "CIV" - which side of the war
                       the unit's groups are created on. Added 2026-09-09; a
                       unit that never says answers "WEST", which is what every
                       caller assumed before it existed.

    Parameters:
        None

    Returns:
        ARRAY - [groups, platoons, radioNets, faction, side]
*/

private _pac = (missionNamespace getVariable ["ghostD_pac_structure", createHashMap]) getOrDefault ["orbat", createHashMap];
if !(_pac isEqualType createHashMap) then {_pac = createHashMap};

private _groups = _pac getOrDefault ["groups", []];
private _platoons = _pac getOrDefault ["platoons", []];
private _radioNets = _pac getOrDefault ["radioNets", []];
private _faction = _pac getOrDefault ["faction", ""];
private _side = _pac getOrDefault ["side", ""];

private _root = missionConfigFile >> "Dynamic_Groups";
if !(_faction isEqualType "") then {_faction = ""};
if (_faction isEqualTo "") then {_faction = getText (_root >> "faction_name")};

// THE SIDE, from the database, then the mission, then WEST. A side the engine
// does not have is a side nothing can be created on and the failure is silent
// at mission start, so anything unrecognised is treated as unsaid.
if !(_side isEqualType "") then {_side = ""};
if (_side isEqualTo "") then {_side = getText (_root >> "side")};
_side = toUpper _side;
if !(_side in ["WEST", "EAST", "GUER", "CIV"]) then {_side = "WEST"};

if (_groups isEqualType [] && {_groups isNotEqualTo []}) exitWith {
    [_groups, [_platoons, []] select !(_platoons isEqualType []), [_radioNets, []] select !(_radioNets isEqualType []), _faction, _side]
};

// the mission's
_groups = getArray (_root >> "group_setup");
_platoons = [];
{
    _platoons pushBack [configName _x, getText (_x >> "name"), getText (_x >> "callsign"), getText (_x >> "net"), getArray (_x >> "squads")];
} forEach (configProperties [_root >> "Platoons", "isClass _x", true]);
_radioNets = [];
{
    _radioNets pushBack [configName _x, getText (_x >> "net"), getArray (_x >> "squads")];
} forEach (configProperties [_root >> "RadioNets", "isClass _x", true]);

[_groups, _platoons, _radioNets, _faction, _side]
