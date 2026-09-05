#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_towerInTaor

Description:
    Is this tower inside the hacking TAOR? Every tower inside the TAOR is
    hackable; outside it none are. With no TAOR set, the whole map is - the
    plain behaviour, and the right one for a mission that never drew an area.

    A TAOR is just an area marker (any shape), named in the towerTaor setting;
    several may be listed.

Parameters:
    _obj : OBJECT - the tower.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_obj"];

private _markers = ((missionNamespace getVariable [QGVAR(towerTaor), ""]) splitString ", ")
    select { _x != "" && {markerShape _x != ""} };

if (_markers isEqualTo []) exitWith {true};

(_markers findIf { _obj inArea _x }) > -1
