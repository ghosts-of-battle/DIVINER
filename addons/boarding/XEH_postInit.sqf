#include "script_component.hpp"

// The old EGVAR(main,ghost_enabled) master gate stood here. Nothing in the
// repo, the settings or the mission ever WROTE that variable, so the isNil
// arm always fired and everything below this line was dead. Removed.

// The move itself happens on the SERVER. A player pressing the action is not
// the owner of the other players being loaded, and moveInCargo wants the unit
// local - so the action raises this and the server does the seating, sending
// each move to the machine that owns that player.
if (isServer) then {
    [QGVAR(board), {_this call FUNC(board)}] call CBA_fnc_addEventHandler;
};
