#include "script_component.hpp"

if (!isServer) exitWith {};

// side text -> time the outage ends. Read by FUNC(ceilingFor).
GVAR(outages) = createHashMap;
// side text -> [profileID, ...] of the patrols that side is flying.
GVAR(patrols) = createHashMap;
// Sides whose drones ALiVE declined to profile, so the reason is logged once
// rather than once per airframe. See FUNC(topUp).
GVAR(unprofilable) = [];
// Sides skipped for being on the players' team, said once each rather than
// every planning tick. See FUNC(planPatrols).
GVAR(friendlySaid) = [];

// A ZONE IS THE ENABLE. This file only sets up state and the report command;
// the first Ghost - Drone Patrol Zone module to arm is what starts the system,
// so a mission that draws no zone gets nothing from this addon.
// GVAR(moduleUp) is declared in XEH_preInit, NOT here - see there for why.

["ghostuas", {
    [QGVAR(report), []] call CBA_fnc_serverEvent;
}, "all"] call CBA_fnc_registerChatCommand;

[QGVAR(report), {
    // Built with an explicit loop rather than `apply` over the hashmaps:
    // apply is an ARRAY command, and running it on a HashMap threw before
    // this could print anything at all - which is why the command looked
    // like it did nothing.
    private _fleet = [];
    {
        private _side = _x;
        private _want = 0;
        {
            _want = _want + ([_side, _x # 5] call FUNC(ceilingFor));
        } forEach ([_side] call FUNC(zonesFor));

        _fleet pushBack format ["%1=%2/%3", _side, [_side] call FUNC(livePatrols), _want];
    } forEach [west, east, independent];

    private _out = [];
    {
        _out pushBack format ["%1 for %2s", _x, round (_y - CBA_missionTime)];
    } forEach GVAR(outages);

    private _txt = format ["patrols/ceiling %1 | outages %2",
        _fleet, ["none", str _out] select (_out isNotEqualTo [])];
    diag_log text format ["[ghostD_uas] %1", _txt];
    [format ["UAS: %1", _txt]] remoteExec ["systemChat", 0];
}] call CBA_fnc_addEventHandler;

// THE IED PELICAN IS DDT'S TO FLY. Drongo's Drone Tweaks gives the AI drones
// from its own class lists; ours is not on them, so it goes on once DDT has
// built them (ddtReady). ddtClassesFPV is "fly it into something soft";
// its InArray is case-insensitive, so the spelling here is only for reading.
// No DDT in the load order: nothing waits, nothing breaks - the timeout is
// there so the wait does not sit forever in a mission without it.
[{missionNamespace getVariable ["ddtReady", false]}, {
    ddtClassesFPV pushBackUnique QGVAR(UAV_06_IED_I);
    diag_log text "[ghostD_uas] IED Pelican registered with Drongo's Drone Tweaks as an FPV";
}, [], 600] call CBA_fnc_waitUntilAndExecute;
