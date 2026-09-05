#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This adds a adda ction as well as a ACE interaction reGear selection. The script reapplyes the players start loadout.
 *
 * Arguments:
 * 0: Object <OBJECT>
 *
 * Example:
 * [this] call ghostD_systems_fnc_addHeal;
 */

params [
    ["_object", objNull, [objNull]],
    ["_category", ["ACE_MainActions"], [["ACE_MainActions"]]]
];

// Make addAction
if (!isPlayer _object) then {
    _object addAction ["   <t color='#ff3333'>Heal</t>", {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [_target, _caller] call ace_medical_treatment_fnc_fullHeal;
        // [_target, _caller] call ACM_core_fnc_resetVariables;
        // [_target, _caller] call ACM_airway_fnc_resetVariables;
        // [_target, _caller] call ACM_breathing_fnc_resetVariables;
        // [_target, _caller] call ACM_circulation_fnc_resetVariables;
        // [_target, _caller] call ACM_damage_fnc_resetVariables;
        // [_target, _caller] call ACM_disability_fnc_resetVariables;
        ["Medical", "You have been healed.", NOTE_GOOD] call GHOSTFUNC(notify,notify);
    }, [], 1.5, true, true, "", "true", 5];
};

// Make ACE Interaction for ReGear
private _healStatement = {
    [_this select 0, player] call ace_medical_treatment_fnc_fullHeal;
    // [_this select 0, player] call ACM_core_fnc_resetVariables;
    // [_this select 0, player] call ACM_airway_fnc_resetVariables;
    // [_this select 0, player] call ACM_breathing_fnc_resetVariables;
    // [_this select 0, player] call ACM_circulation_fnc_resetVariables;
    // [_this select 0, player] call ACM_damage_fnc_resetVariables;
    // [_this select 0, player] call ACM_disability_fnc_resetVariables;

    ["Medical", "You have been healed.", NOTE_GOOD] call GHOSTFUNC(notify,notify);
};

private _actionType = parseNumber (isPlayer _object);

private _healAction = [QEGVAR(Actions,HealAction), "Heal", "\z\ACE\addons\medical_gui\ui\cross.paa", _healStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _category, _healAction] call ace_interact_menu_fnc_addActionToObject;

true
