#include "script_component.hpp"
/*
 * Author: veteran29
 * Handle initialization of server status panel.
 *
 * Arguments:
 * 0: Server status panel control group <CONTROL>
 *
 * Return Value:
 * None
 *
 *
 * Public: No
 */

params ["_ctrlGroup"];

TRACE_1("Server status panel init",_ctrlGroup);

if (getClientState == "NONE" && !is3DEN) exitWith {
    LOG("Not joining, hidding status panel");

    _ctrlGroup ctrlShow false;
};

private _ctrlText = _ctrlGroup controlsGroupCtrl IDC_SERVERSTATUS_TITLE;
private _ctrlDesc = _ctrlGroup controlsGroupCtrl IDC_SERVERSTATUS_DESCRIPTION;
private _ctrlLoginInput = _ctrlGroup controlsGroupCtrl IDC_SERVERSTATUS_PASSWORD;
private _ctrlLoginButton = _ctrlGroup controlsGroupCtrl IDC_SERVERSTATUS_LOGIN;
private _ctrlMissionsButton = _ctrlGroup controlsGroupCtrl IDC_SERVERSTATUS_MISSIONS;

_ctrlMissionsButton ctrlEnable IS_ADMIN;

// Server status update loop
[_ctrlText, _ctrlDesc] spawn {
    params ["_ctrlTitle", "_ctrlDesc"];

    private _dots = "";

    waitUntil {
        if (getClientStateNumber < 3) then {
            if (count _dots > 3) then {
                _dots = "";
            };

            _ctrlTitle ctrlSetText (["Joining", _dots] joinString "");
            _dots = [_dots, "."] joinString "";

            _ctrlDesc ctrlSetText "Trying to establish connection with the server, please wait.";
        } else {
            _ctrlTitle ctrlSetText "Connected to server";

            private _desc = ["You're connected to the server. Please wait for the admin to select mission.<br />(You can use #login command to log in as admin)", "You're connected to the server as admin.<br />(You can use #missions command to show missions list)"] select IS_ADMIN;
            _ctrlDesc ctrlSetStructuredText parseText _desc;
        };

        uiSleep 1;

        isNull _ctrlTitle;
    };
};

[_ctrlLoginInput, _ctrlLoginButton, _ctrlMissionsButton] call FUNC(addMultiplayerButtonsLogic);

// TODO find a way to show cursor on loading screen, tabbing to this panel is not so useful / intuitive
// hidden for now
ctrlParentControlsGroup _ctrlLoginInput ctrlShow false;

nil
