#include "..\script_component.hpp"
/*

 * \ghost_medical\supplies\functions\fn_canUnpackFirstAid.sqf
 * by YonV
 *
 * check if medical supplies can be unpacked
 *
 * Arguments:
 * 0: unit - <OBJECT>
 *
 * Return:
 * <BOOLEAN>
 *
 * Example:
 * [player] call ghostD_medbags_fnc_canUnpackFirstAid;
 *
 */

// -------------------------------------------------------------------------------------------------

private _unit = param [0, objNull, [objNull]];

// -------------------------------------------------------------------------------------------------

if (isNull _unit) exitWith {false};

// -------------------------------------------------------------------------------------------------

(
    ("ghostD_medbags_FirstAid" in items _unit) &&
    (alive _unit) &&
    !(_unit getVariable ["ace_captives_isSurrendering", false]) &&
    !(_unit getVariable ["ace_captives_isHandcuffed", false]) &&
    !(_unit getVariable ["ace_isUnconscious", false]) &&
    (not visibleMap)
);
