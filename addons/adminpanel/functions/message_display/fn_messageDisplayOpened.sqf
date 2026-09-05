/*
    Author: TheTimidShade

    Description:
        Is executed when admin message interface is opened. Populates controls with relevant data.

    Parameters:
        NONE
        
    Returns:
        NOTHING
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;

// load possible recipients
[] call admp_fnc_populateRecipientList;

// load message history
[] call admp_fnc_loadMessageList;

