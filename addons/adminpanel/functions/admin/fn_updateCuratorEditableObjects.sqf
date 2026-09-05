/*
    Author: JohnnyShootos (Edited by TheTimidShade, then by Ghost)

    Description:
        Keeps a Zeus curator's editable-object list current while the admin
        holds Zeus.

        WHY IT POLLS AT ALL. ghost_curator keeps curators up to date from
        events - but only CuratorObjectPlaced and CuratorGroupPlaced, which
        fire for things ZEUS places. ALiVE spawns its profiles without raising
        anything, so an admin who took Zeus at mission start could not edit a
        single unit ALiVE had stood up since. Hence a poll.

        WHY IT ONLY ADDS WHAT IS NEW, AND THAT IS THE FIX. This used to hand
        the curator EVERY entity in the mission every ten seconds:

            _entities = entities [[], ["Logic"], true];
            _curatorLogic addCuratorEditableObjects [_entities, true];

        addCuratorEditableObjects is a GLOBAL command - it synchronises the
        whole editable list to every machine - and it is cumulative, so
        re-sending several hundred objects that were already on it bought
        nothing and cost a mission-wide network sync on a ten-second timer. On
        an ALiVE battlefield running 170+ AI that is a hitch every ten seconds
        for as long as anybody holds Zeus, and the client RPT shows exactly
        that: a run of "Network message ... is pending" through the whole
        session and fifteen curator item-list rebuilds during play, the gaps
        between them sitting at 43, 47, 49, 58, 61 and 65 seconds.

        Now the list is diffed and only genuinely new entities are sent. The
        usual tick sends nothing at all.

    Parameters:
        0: OBJECT - Player to update editable objects for
        1: OBJECT - Curator logic assigned to given player

    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

params ["_player", "_curatorLogic"];

// Held across ticks so the diff has something to diff against. Replaced
// wholesale rather than appended to, so entities that have since died drop out
// and the list cannot grow for the whole mission.
private _known = [];

while {alive _player && !isNull _curatorLogic} do {
    private _entities = entities [[], ["Logic"], true];
    private _fresh = _entities - _known;

    if (_fresh isNotEqualTo []) then {
        _curatorLogic addCuratorEditableObjects [_fresh, true];
    };

    // Replaced every tick, not only when something was added, so entities that
    // have died drop out instead of the list growing dead references for the
    // whole mission.
    _known = _entities;

    sleep 10;
};
