#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_scannerClose

Description:
    Puts the scanner away and stops its loop.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!hasInterface) exitWith {};

// The readings are controls on the mission display now, so putting the handset
// away is deleting them - there is no title layer left to blank.
private _display = uiNamespace getVariable [QGVAR(scanner), displayNull];
uiNamespace setVariable [QGVAR(scanner), displayNull];

if (!isNull _display) then {
    {
        private _ctrl = _display displayCtrl _x;
        if (!isNull _ctrl) then {ctrlDelete _ctrl};
    } forEach [
        IDC_SCN_BEZEL, IDC_SCN_TITLE,
        IDC_SCN_ICO_DRONE, IDC_SCN_DRONE_L, IDC_SCN_DRONE_V,
        IDC_SCN_ICO_JAM, IDC_SCN_JAM_L, IDC_SCN_JAM_V,
        IDC_SCN_ICO_MESH, IDC_SCN_MESH_L, IDC_SCN_MESH_V,
        IDC_SCN_NETHEAD, IDC_SCN_ICO_NET, IDC_SCN_NET_L, IDC_SCN_NET_V,
        IDC_SCN_ALARM, IDC_SCN_TIMER, IDC_SCN_STATUS
    ];
};

private _pfh = missionNamespace getVariable [QGVAR(scannerPFH), -1];
if (_pfh >= 0) then { [_pfh] call CBA_fnc_removePerFrameHandler };
GVAR(scannerPFH) = -1;
