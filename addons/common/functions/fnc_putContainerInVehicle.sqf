#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_putContainerInVehicle

Description:
    Strips a unit's uniform or vest and drops it into a vehicle's cargo with its
    contents intact -- used to make divers change out of their rig without
    losing what was in it.

Parameters:
    _unit    : OBJECT - unit to strip.
    _vehicle : OBJECT - vehicle to receive the container.
    _type    : STRING - "UNIFORM" or "VEST". (default: "UNIFORM")

Returns:
    Nothing.

Author:
    Larrow (original snippet, BI forums), modified by Mr H. (MRHMilsimTools,
    ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_unit", "_vehicle", ["_type", "UNIFORM", [""]]];

private _isVest = (toUpper _type) isEqualTo "VEST";
private _container = if (_isVest) then {vest _unit} else {uniform _unit};
if (_container isEqualTo "") exitWith {};

private _contents = if (_isVest) then {vestItems _unit} else {uniformItems _unit};

// the new container is whatever lands last in the vehicle's container list
private _index = count (everyContainer _vehicle);
_vehicle addItemCargoGlobal [_container, 1];
private _dropped = ((everyContainer _vehicle) select _index) select 1;

{
    _dropped addItemCargoGlobal [_x, 1];
} forEach _contents;

if (_isVest) then { removeVest _unit } else { removeUniform _unit };

TRACE_3("container moved to vehicle",_unit,_type,count _contents);
