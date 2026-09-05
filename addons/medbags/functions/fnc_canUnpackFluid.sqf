#include "..\script_component.hpp"
/*

 * \ghost_medical\supplies\functions\fn_canUnpackMedicKit.sqf
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
 * [player] call ghostD_medbags_fnc_canUnpackMedicKit;
 *
 */

// -------------------------------------------------------------------------------------------------

private _unit = param [0, objNull, [objNull]];

// -------------------------------------------------------------------------------------------------

if (isNull _unit) exitWith {false};

// -------------------------------------------------------------------------------------------------

(
    ("ghostD_medbags_Fluid" in items _unit) &&
    (alive _unit) &&
    [player] call ace_common_fnc_isMedic &&
    !(_unit getVariable ["ace_captives_isSurrendering", false]) &&
    !(_unit getVariable ["ace_captives_isHandcuffed", false]) &&
    !(_unit getVariable ["ace_isUnconscious", false]) &&
    (not visibleMap)
);
