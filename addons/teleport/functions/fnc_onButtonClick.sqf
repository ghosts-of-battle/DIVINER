#include "script_component.hpp"
/*
 * Author: Reeveli
 * OK: move the player to the selected point.
 *
 * Arguments: None
 *
 * Return Value: None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

private _listing = uiNamespace getVariable [QGVAR(listCtrl), controlNull];
if (isNull _listing) exitWith {};

private _sel = lbCurSel _listing;
if (_sel < 0) exitWith {
    playSound "FD_Start_F";
    ["Teleport", "No teleport point selected.", [ARR_4(1,0.3,0.3,1)]] call EFUNC(notify,notify);
};

private _name = _listing lbData _sel;
private _list = missionNamespace getVariable [QTP_LIST, []];
private _index = _list findIf {(_x # 1) isEqualTo _name};

// Same guard as the selection handler: the point can go while the menu is up.
if (_index < 0) exitWith {
    ["Teleport", "That point is gone.", [ARR_4(1,0.3,0.3,1)]] call EFUNC(notify,notify);
    closeDialog 1;
};

private _object = (_list # _index) # 0;
if (isNull _object) exitWith {
    ["Teleport", "That point is gone.", [ARR_4(1,0.3,0.3,1)]] call EFUNC(notify,notify);
    closeDialog 1;
};

[player, _object] call FUNC(teleport);

closeDialog 1;
