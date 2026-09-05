#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV
 * The mission's postInit, as an addon's - was scripts\postInit.sqf.
 */

if (is3DEN) exitWith {};

INFO("postInit","Initializing...");

call FUNC(playerpost);

INFO("postInit","Initialization completed.");
