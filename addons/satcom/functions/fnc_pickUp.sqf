#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_satcom_fnc_pickUp

Description:
    Packs the mast back into an item.

    Any connected radio is disconnected first. Deleting an antenna with a radio
    still attached leaves ACRE holding a reference to an object that no longer
    exists, and the radio keeps behaving as though it were still plugged into
    something.

Parameters:
    _unit   : OBJECT - the player.
    _target : OBJECT - the mast.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit", "_target"];

if !([_unit, _target] call FUNC(canPickUp)) exitWith {};

if ([] call FUNC(hasAcre)
    && {(_target getVariable ["acre_sys_gsa_connectedRadio", ""]) isNotEqualTo ""}) then {
    [_unit, _target] call acre_sys_gsa_fnc_disconnect;
};

if (stance _unit isEqualTo "STAND") then {
    [_unit, "AmovPercMstpSrasWrflDnon_diary"] call ace_common_fnc_doAnimation;
};

[{
    params ["_unit", "_target"];
    // Re-checked: the mast can be blown up, or somebody else can grab it, during
    // the kneel-down.
    if (isNull _target) exitWith {};
    _unit addItem QGVAR(item);
    deleteVehicle _target;
}, [_unit, _target], SATCOM_PLACE_TIME] call CBA_fnc_waitAndExecute;
