#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_managedNames

Description:
    The trait and variable names PAC owns - every name any skill in the
    structure can set. The groups addon asks this so a role stops applying
    those and applies everything else it carries (tile access, nets, DRA
    flags), which is how PAC is the source of truth for skills without
    taking anything that is not a skill.

    Derived from the effects, not listed: a unit that adds a skill setting
    "var:isRTO=true" has, by that, taken isRTO away from the roles.

Parameters:
    None

Returns:
    Lowercase names <ARRAY of STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

private _names = ["medic", "engineer", "explosivespecialist", "ace_medical_medicclass", "ace_isengineer", "ace_iseod"];

{
    {
        private _parts = _x splitString ":";
        if (count _parts < 2) then {continue};
        private _kind = toLower trim (_parts # 0);
        private _val = trim ((_parts select [1]) joinString ":");
        switch (_kind) do {
            case "trait": {_names pushBackUnique toLower _val};
            case "var": {_names pushBackUnique toLower trim ((_val splitString "=") # 0)};
        };
    } forEach (_y getOrDefault ["effects", []]);
} forEach (GVAR(structure) getOrDefault ["skills", createHashMap]);

_names
