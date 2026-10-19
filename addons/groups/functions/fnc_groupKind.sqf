#include "script_component.hpp"
/*
    File: fnc_groupKind.sqf
    Author: YonV
    Description: Put a squad's KIND on its live group - the icon the blue
        force tracker draws it with (inf, motor_inf, mech_inf, air, armor,
        recon ...). The kind is the ORBAT row's fourth element, written by
        the website's and TAC//PAC's squad page; until 2026-09-10 nothing in
        the game read it, so every squad drew as infantry whatever was set
        ("Kind ... does not change the inf").

        AN EMPTY KIND LEAVES THE GROUP ALONE - a squad that says nothing is
        infantry by the tracker's own default, and a man who picked an icon
        for his group on the tacpad keeps it. A kind the tracker does not
        know is refused with a line in the .rpt rather than drawn as a
        missing marker.

    Parameters:
        0: The group <GROUP>
        1: Kind <STRING>

    Returns:
        Whether it was set <BOOL>
*/

params [["_group", grpNull, [grpNull]], ["_kind", "", [""]]];

if (isNull _group) exitWith {false};
_kind = toLower (trim _kind);
if (_kind isEqualTo "") exitWith {false};

private _known = missionNamespace getVariable [QEGVAR(bft,availableMarkerIcons), []];
if (_known isNotEqualTo [] && {!(_kind in _known)}) exitWith {
    WARNING_2("Groups","squad %1: kind '%2' is not a tracker icon - not set",groupId _group,_kind);
    false
};
if ((_group getVariable [QEGVAR(bft,type), ""]) isEqualTo _kind) exitWith {true};
_group setVariable [QEGVAR(bft,type), _kind, true];
true
