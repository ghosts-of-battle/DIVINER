#include "script_component.hpp"

if (hasInterface && !isServer) exitWith {};

params [
    ["_logic",objNull,[objNull]],
    ["_units",[],[[]]],
    ["_activated", true]
];



if (_activated) then {
    private _groupSide = _logic getVariable ["groupSide", "WEST"];
    // Blank resolves here rather than in the attribute's defaultValue: the path
    // is SQF source full of double quotes, and a config default carrying those
    // cannot survive macro expansion. Blank is also the better field to look at.
    private _groupConfig = _logic getVariable ["groupConfig", ""];
    if (_groupConfig isEqualTo "") then {
        _groupConfig = "configFile >> ""CfgGroups"" >> ""West"" >> ""BLU_F"" >> ""Infantry"" >> ""BUS_InfSquad""";
    };
    private _moveMarker1 = _logic getVariable ["moveMarker1", ""];
    private _moveMarker2 = _logic getVariable ["moveMarker2", ""];
    private _waves = _logic getVariable ["waves", -1];
    private _huntCondition = _logic getVariable ["huntCondition", "false"];
    private _huntTrigger = _logic getVariable ["huntTrigger", "ghost_huntTrigger"];
    private _sadTrigger = _logic getVariable ["sadTrigger", "objNull"];

    /* format ["%1\n%2\n%3\n%4\n%5\n%6\n%7\n%8\n%9\n%10", _logic,_units,_activated,_groupSide,_groupConfig,_moveMarker1,_moveMarker2,_waves,_huntCondition,_huntTrigger, _sadTrigger] remoteExec ["hint", 0]; */

    // Hunt Immediately is what the separate AI Hunter module used to be: the
    // same spawn and the same waves, but the group goes straight after the
    // players rather than walking a route and waiting on a condition. The move
    // markers, hunt condition and SAD trigger are all route furniture, so they
    // are simply not read on this path.
    if (_logic getVariable ["startHunting", false]) exitWith {
        [
            call compile _groupSide,
            call compile _groupConfig,
            getPos _logic,
            _waves,
            call compile _huntTrigger
        ] call FUNC(aiHunter);
    };

    [(call compile _groupSide),(call compile _groupConfig),getPos _logic,[getMarkerPos _moveMarker1,getMarkerPos _moveMarker2], _waves,_huntCondition,(call compile _huntTrigger),(call compile _sadTrigger)] call FUNC(aiSpawner);
};
