#include "script_component.hpp"
/*
    File: fnc_uiFilter.sqf
    Author: YonV
    Description: The filter box on a table page was typed in. A page that
        offered it (FUNC(uiFilterShow)) is redrawn with the text; the box
        itself is not touched, so the caret stays where the admin is typing.

    Parameters:
        None

    Returns:
        Nothing
*/

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};
if !(missionNamespace getVariable [QGVAR(uiFilterable), false]) exitWith {};

GVAR(uiFilterText) = ctrlText (_display displayCtrl PAC_IDC_FILTER);
[] call FUNC(uiDraw);
