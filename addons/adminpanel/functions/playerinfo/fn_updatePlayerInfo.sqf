/*
    Author: TheTimidShade

    Description:
        Updates player info displays + group name

    Parameters:
        0: ARRAY - Array of stats from admp_fnc_getPlayerInfo
        
    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


//#define IDC_ADMINPANEL_PLAYER_GROUP_GROUPNAME        4330

params ["_dataArray"];

private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

// get all playerInfo display controls
private _name_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_INFO_NAME;
private _side_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_INFO_SIDE;
private _grid_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_INFO_GRID;
private _fps_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_INFO_FPS;
private _vehicleState_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_INFO_VEHICLE_INFO;
//private _groupname_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_GROUP_GROUPNAME;

// update status on controls
//
// LABEL AND VALUE, not "Name: X" in one colour - see EFUNC(adminpanel,infoRow).
[_name_display, "NAME", _dataArray # 0] call FUNC(infoRow);
[_side_display, "SIDE", toUpper (_dataArray # 1)] call FUNC(infoRow);
[_grid_display, "GRID", _dataArray # 2, true] call FUNC(infoRow);
[_fps_display, "FPS", _dataArray # 3] call FUNC(infoRow);
[_vehicleState_display, "IN VEHICLE", _dataArray # 4] call FUNC(infoRow);
//_groupname_display ctrlSetText ("Group: " + _dataArray#5);

// THE STRIP UNDER THE CAMERA. Grid, height and heading of whoever is being
// watched - the three numbers you read out over the radio while you are
// watching him, and the reason the feed is worth having at all.
private _readout = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_CAMDISPLAY_READOUT;
if (!isNull _readout) then {
    private _unit = admp_camera_attachedObject;
    _readout ctrlSetStructuredText parseText (
        if (isNull _unit) then {
            "<t font='RobotoCondensedBold' size='0.75'>NO FEED</t>"
        } else {
            format [
                "<t font='RobotoCondensedBold' size='0.75'>%1   %2 M ASL   HDG %3</t>",
                mapGridPosition _unit,
                round ((getPosASL _unit) # 2),
                round (getDir _unit)
            ]
        }
    );
};

// REMOTE names the man it would send to, and the selection moves under it.
[] call FUNC(execTabs);
