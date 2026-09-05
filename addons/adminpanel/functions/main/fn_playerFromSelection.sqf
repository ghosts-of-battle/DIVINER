/*
    Author: TheTimidShade

    Description:
        Gets the player object corresponding to the currently selected player using the passed display

    Parameters:
        1: DISPLAY - Display to retrieve selection from
        
    Returns:
        OBJECT - Player object corresponding to currently selected list item. Returns objNull if there are no entries in the list
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;

params ["_display"];

if (lbSize _display == 0) then {
    objNull
} else {
    private _selectedPlayerIndex = _display lbValue (lbCurSel _display);
    private _player = admp_playerlist_playerArray#_selectedPlayerIndex;
    _player
};
