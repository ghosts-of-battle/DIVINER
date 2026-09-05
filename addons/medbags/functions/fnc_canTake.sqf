#include "..\script_component.hpp"
/*
 * Author: YonV
 * Whether the player may strip the medical bags off a casualty.
 *
 * A DOWNED MAN, NOT A DEAD ONE AND NOT A STANDING ONE. Taking a bag off someone
 * still on his feet is pickpocketing and belongs in ACE's own inventory
 * interaction; taking it off a body is looting, which ACE already does through
 * the corpse's inventory. The gap this fills is the one ACE leaves: a casualty
 * who is unconscious cannot open his own inventory to hand his kit over, and the
 * medic working on him should not have to wait for him to wake up to use it.
 *
 * ANY BAG, NOT THE BOO BOO BAG. The half-written version of this function asked
 * only about ghost_medbags_FirstAid, on the wrong unit - it read the player's
 * own items and the player's own unconsciousness - so it could never have been
 * true at the moment the action was offered. It now asks the casualty, about
 * every bag in MEDBAG_ITEMS.
 *
 * Arguments:
 * 0: Player <OBJECT>
 * 1: Casualty <OBJECT>
 *
 * Return Value:
 * Whether the take action should be offered <BOOL>
 *
 * Example:
 * [player, cursorObject] call ghostD_medbags_fnc_canTake;
 *
 * Public: No
 */

params [["_player", objNull, [objNull]], ["_target", objNull, [objNull]]];

if (isNull _player || {isNull _target}) exitWith {false};
if (_target isEqualTo _player) exitWith {false};
if !(_target isKindOf "CAManBase") exitWith {false};
if (!alive _target) exitWith {false};
if !(_target getVariable ["ace_isUnconscious", false]) exitWith {false};
if (visibleMap) exitWith {false};

// The casualty's items, read once. `items` covers the uniform, vest and
// backpack together, which is where a bag can be.
private _carried = items _target;

MEDBAG_ITEMS findIf {_x in _carried} > -1
