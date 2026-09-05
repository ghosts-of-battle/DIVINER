#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV tinkered with by YonV
 * This function print messages on player connect.
 *
 * THE WAIT FOR `player` IS THE CALLER'S. This used to open with
 * `waitUntil {!isNull player && player == player}`, and FUNC(playerpost)
 * `call`s it from XEH postInit - which is UNSCHEDULED. waitUntil cannot
 * suspend there, so it threw "Suspending not allowed in this context",
 * the statement was abandoned, and the rest of the function ran anyway
 * against a null player. FUNC(playerpost) now does the waiting where CBA
 * can do it without suspending; see the note there.
 *
 * Example:
 * call ghostD_init_fnc_message
 *
 * Public: No
 */

// Belt and braces: a future caller from an unscheduled context fails soft
// rather than writing the "already said this" flag onto <NULL-object>, which
// would silently cost the real player their message.
if (isNull player) exitWith {};
if (!isMultiplayer || {is3DENMultiplayer}) exitWith {};
if (!isNil{player getVariable QEGVAR(player,message)}) exitWith {};

// if (difficulty != 2) then {
//     systemChat "[YMF] (Difficulty) WARNING: Mission difficulty is not set to Veteran." 
// };

player setVariable [QEGVAR(player,message), true];
