/*
    Author: TheTimidShade

    Description:
        Returns true if the player is an admin (Steam64 ID is in admp_authorisedIDs)

    Parameters:
        0: OBJECT - Player to check for admin permissions
        
    Returns:
        BOOL - True if player is an admin, false if not
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

params [["_player", objNull, [objNull]]];

// ONE GATE, AND IT IS GHOST'S. This took a unit and then tested `player` - the
// LOCAL one - so every name in the list was marked with the admin's own status
// and every row got a star as soon as one admin opened the console.
//
// It delegates now rather than being fixed in place, because there were two
// answers to "is this man an admin" in this addon and they could disagree.
[_player] call FUNC(isAdmin)
