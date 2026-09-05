/*
    Author: TheTimidShade

    Description:
        Continously checks for spectator display so that adminpanel EH can be added

    Parameters:
        NONE
        
    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;

while {true} do { // scary infinite loop of doom
    waitUntil {sleep 1; !isNull (findDisplay 60492)}; // wait until spectator display exists
    
    (findDisplay 60492) displayAddEventHandler ["KeyDown",{
        params ["_disp", "_key", "_shift", "_ctrl", "_alt"];
        private _yourKey = 0xC5; // Pause Break -- https://community.bistudio.com/wiki/DIK_KeyCodes

        if ((_key == _yourKey) && _shift && !dialog) then {
            if (player call admp_fnc_isAdmin) then {
                createDialog "ghostD_adminpanel_console";
                true
            } else {
                createDialog "ghostD_adminpanel_message";
                true
            };
        }; 
    }];

    waitUntil {sleep 1; isNull (findDisplay 60492)}; // wait until spectator display is closed as to not add more EHs
};
