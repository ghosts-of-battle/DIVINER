#include "..\script_component.hpp"
/*

 * \ghost_medical\supplies\functions\fn_doUnpackFirstAid.sqf
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
 * [player] call ghostD_medbags_fnc_doUnpackFirstAid;
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
        playSound QGVAR(Medical_FirstAid_Open_1);
    } else {
        playSound3D ["z\ghostD\addons\medbags\data\sounds\FirstAid_Open_1.ogg", _unit];
    };

    ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS = false;
    ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE = false;

    [
        2,
        [],
        { ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS = true; },
        { ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE = true; },
        "Unpacking Boo Boo Bag....",
        {true},
        ["isNotInside", "isNotSitting", "isNotSwimming"]
    ] call ACE_common_fnc_progressBar;

    waitUntil {if ((ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS) || (ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE)) exitWith {true}; false};

    if (ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS) exitWith {

        _unit removeItem "ghostD_medbags_FirstAid";

        [_unit, GVAR(contentsFirstAid)] call FUNC(issueContents);
    };

    if (ghost_MEDICAL_SUPPLIES_UNPACK_FAILURE) exitWith {};
};
