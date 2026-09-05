#include "script_component.hpp"
params ["_unit"];

private _oldSelectionPath = [_unit] call ghostD_groups_fnc_removeFromGroup;

[YMF_dynamicGroups,_oldSelectionPath] remoteExecCall ["ghostD_groups_fnc_updateGroups",-2,"YMF_DG_JIP"];
