#include "..\script_component.hpp"
/*

 * \ghost_medical\supplies\functions\fn_doUnpackMedicKit.sqf
 * by YonV
 *
 * unpack medical supplies
 *
 * Arguments:
 * 0: unit - <OBJECT>
 *
 * Return:
 * nothing
 *
 * Example:
 * [player] call ghostD_medbags_fnc_doUnpackMedicKit;
 *
 */

// -------------------------------------------------------------------------------------------------

private _unit = param [0, objNull, [objNull]];

// -------------------------------------------------------------------------------------------------

if (isNull _unit) exitWith {};

// -------------------------------------------------------------------------------------------------

[_unit] spawn {

    params ["_unit"];

    _unit playAction "Gear";

    if (!isNull objectParent _unit) then {
        playSound QGVAR(Medical_MedicKit_Open_1);
    } else {
        playSound3D ["z\ghostD\addons\medbags\data\sounds\medickit_open_1.ogg", _unit];
    };

    ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS = false;
    ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE = false;

    [
        2,
        [], { ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS = true; }, { ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE = true; },
        "Unpacking Medical Kit....",
        {true},
        ["isNotInside", "isNotSitting", "isNotSwimming"]
    ] call ACE_common_fnc_progressBar;

    waitUntil {if ((ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS) || (ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE)) exitWith {true}; false};

    if (ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS) exitWith {

        _unit removeItem "ghostD_medbags_MedicKit";

        [_unit, GVAR(contentsMedicKit)] call FUNC(issueContents);
    };
    if (ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE) exitWith {};
};
