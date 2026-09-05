#include "script_component.hpp"
/*
 * Author: Reeveli
 * A point was picked: fly the map to it and show the marker.
 *
 * Arguments:
 * 0: The list box <CONTROL>
 * 1: Selected row <NUMBER>
 *
 * Return Value: None
 *
 * Public: No
 */

params [
    ["_control", controlNull, [controlNull]],
    ["_lbCurSel", -1, [0]]
];

if (isNull _control) exitWith {};

if (_lbCurSel < 0) exitWith {
    playSound "FD_Start_F";
    ["Teleport", "No teleport point selected.", [ARR_4(1,0.3,0.3,1)]] call EFUNC(notify,notify);
};

private _name = _control lbData _lbCurSel;
private _list = missionNamespace getVariable [QTP_LIST, []];
private _index = _list findIf {(_x # 1) isEqualTo _name};

// A point can be destroyed while the menu is open, and the list is published -
// so the row can outlive the entry. Reading (_list # -1) # 0 threw here.
if (_index < 0) exitWith {};

private _object = (_list # _index) # 0;
if (isNull _object) exitWith {};

private _map = uiNamespace getVariable [QGVAR(map), controlNull];
if (!isNull _map) then {
    _map ctrlMapAnimAdd [0, 0.3, getPos _object];
    ctrlMapAnimCommit _map;
};

QGVAR(marker) setMarkerPosLocal (getPos _object);
QGVAR(marker) setMarkerAlphaLocal 1;
