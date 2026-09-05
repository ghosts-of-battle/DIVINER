#include "script_component.hpp"
/*
 * Author: Ghost
 * Everything a new message can be addressed to, as [mailbox id, label] pairs.
 *
 * THE ONE LIST. The nets, the squads and the people were rebuilt inline in the
 * compose pane, in the reader's rail and twice in the tile panels, all slightly
 * differently - so the CC line, the TO line and the picker would have been the
 * fifth, sixth and seventh copy. The three id forms are not interchangeable and
 * that is exactly why they belong in one function: a squad is a G: box, a named
 * mailbox is a B:, a person is a P:<uid>. See EFUNC(messaging,submit).
 *
 * EVERY PLAYER IS ADDRESSABLE - a person is a net of one. The player themselves
 * is not on the list: a message you send is already in your own box.
 *
 * The label is what the player reads and what the CC line takes an @ name from,
 * so it is uppercase here rather than at each call site.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Addressable targets <ARRAY> of [mailbox id <STRING>, label <STRING>]
 *
 * Example:
 * private _targets = [] call ghostD_tacpad_fnc_composeTargets
 *
 * Public: Yes
 */

private _targets = [];

// THE SAME NETS THE RAIL DRAWS, and for the same reason (user, 2026-09-03):
// a man should not be offered a net he cannot read. This listed every named
// box in the addon setting and then every squad in the task force; it asks
// EFUNC(messaging,railNets) now, which is the mission's GHOSTFR_Nets narrowed by
// his role, with his own squad on the end.
//
// A NET NAME IS NOT A BOX ID. His own squad is a G: box, everything the mission
// named is a B: - the rule FUNC(netBox) owns, applied here rather than repeated.
{
    _targets pushBack [[_x, true] call FUNC(netBox), toUpper _x];
} forEach ([] call EFUNC(messaging,railNets));

{
    if (_x isEqualTo player) then {continue};
    _targets pushBack [format ["P:%1", getPlayerUID _x], toUpper (name _x)];
} forEach (allPlayers select {side group _x isEqualTo side group player});

_targets
