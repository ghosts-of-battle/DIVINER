#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_cfgList

Description:
    One named list out of a config document the unit keeps in the database.

    THE ONE-LINE FORM FOR A MISSION. A mission that wants to add the database's
    radar classes to its own writes

        forEach ((getArray (missionConfigFile >> "Radar_Network" >> "classes"))
                 + (["radar", "classes"] call ghostD_pac_fnc_cfgList));

    which is why this exists beside FUNC(cfgLists): the hashmap form needs a
    getOrDefault and a nil guard around it, and doing that inline in a mission
    invites the precedence mistakes that make an array quietly empty.

    ALWAYS AN ARRAY, never nil - so it can be appended to something without a
    check. An unconfigured unit gets [], which appends to nothing.

Parameters:
    0: Document <STRING> - "arsenal", "radar"
    1: List name <STRING> - "classes", "weapons"

Returns:
    The values <ARRAY>, empty when there is no such document or list

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_doc", "", [""]], ["_name", "", [""]]];

if (_doc isEqualTo "" || _name isEqualTo "") exitWith {[]};

private _v = ([_doc] call FUNC(cfgLists)) getOrDefault [_name, []];
if !(_v isEqualType []) exitWith {[]};

_v
