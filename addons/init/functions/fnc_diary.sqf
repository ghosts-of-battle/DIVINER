#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function add diary records.
 *
 * THE WAIT FOR `player` AND `profileName` IS THE CALLER'S. This used to open
 * with two waitUntils, and FUNC(playerpost) `call`s it from XEH postInit -
 * which is UNSCHEDULED. waitUntil cannot suspend there, so it threw
 * "Suspending not allowed in this context", the statement was abandoned, and
 * the function carried on regardless. Every RPT on record proves the damage
 * on the line straight after the error:
 *
 *     Applying Diary Records to <NULL-object>
 *
 * The records were being written to nothing, every session, since forever.
 * FUNC(playerpost) now does the waiting where CBA can do it without
 * suspending; see the note there.
 *
 * Example:
 * call ymf_fnc_init_diary
 *
 * Public: No
 */

// Belt and braces: a future caller from an unscheduled context fails soft
// rather than repeating the <NULL-object> bug in silence.
if (isNull player) exitWith {};
if (!isNil{player getVariable QEGVAR(player,documents)}) exitWith {SHOW_WARNING_1("initDiary","Diary Records already applied for %1.",player)};

INFO_1("initDiary","Applying Diary Records to %1...",player);

// THE DIARY (user, 2026-08-29: "in game on the map the diary menu is missing").
// It was missing because this whole body was commented out - the function was
// still called from FUNC(playerpost), still logged "Applying Diary Records",
// and still set the "already applied" flag, so it looked like it had run. What
// it never did was create a single record.
//
// The commented-out version also created its own "trainobj" subject before
// calling Doc_mission_Info. That was wrong twice over: the subject was named
// for a training mission this is not, and Doc_mission_Info creates its OWN
// subject ("gobinfo", GOB Info) as its first act. Creating one here as well
// left an empty tab beside the real one.
call EFUNC(documents,Doc_mission_Info);

// NOT Doc_mission_map. That function still exists, but every line of its body
// is commented out too, so calling it would create the "gobmap" subject's tab
// and nothing to put in it. Uncomment it there first if the map notes come
// back.


player setVariable [QEGVAR(player,documents), true];
