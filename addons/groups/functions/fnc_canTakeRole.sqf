#include "script_component.hpp"
/*
    File: fn_canTakeRole.sqf
    Author: Dom -- Tinkered with by YonV
    Description: Whether a player may take a role - the yes/no face of
        FUNC(roleGate), which is where the rules live (admin grants, then
        TAC//PAC's gates when the role carries any, else the mission's
        Role_Access). Kept for the callers that only want a BOOL.

    Parameters:
        0: OBJECT - the unit
        1: STRING - the role class

    Returns:
        BOOL
*/

(_this call FUNC(roleGate)) # 0
