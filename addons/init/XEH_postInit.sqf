#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV
 * The mission's postInit, as an addon's - was scripts\postInit.sqf.
 */

if (is3DEN) exitWith {};

INFO("postInit","Initializing...");

call FUNC(playerpost);

// THE TWELVE GOB ZEN MODULES REGISTER HERE, AND NOT IN preInit, WHICH IS WHERE
// THEY WERE. `zen_custom_modules_fnc_register` is not reliably there to be
// called that early: the registration either never reached Zeus's module tree
// or was dropped when ZEN built its own, so the modules showed nothing to fill
// in and did nothing when placed - even though ten of the twelve open a proper
// `zen_dialog_fnc_create` card and every target function exists. Every other
// addon here already registers at postInit: `respawn`, `patrol_base`,
// `teleport`. This was the odd one out.
call FUNC(zenModuels);

INFO("postInit","Initialization completed.");
