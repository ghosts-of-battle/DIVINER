#include "script_component.hpp"

if (hasInterface && !isServer) exitWith {};

/*
 * The AI Hunter module's own controller - the module class always named
 * DFUNC(moduleAiHunter) and no such function existed, so placing it did
 * nothing at all. Reads the module's arguments the way the spawner module
 * reads its own and hands them straight to FUNC(aiHunter): same spawn, same
 * waves, but the group goes for the players immediately - no route, no
 * hunt condition.
 */

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true]
];

if (_activated) then {
    private _groupSide = _logic getVariable ["groupSide", "WEST"];
    // Blank resolves here rather than in the attribute's defaultValue - the
    // path is SQF source full of double quotes, and a config default
    // carrying those cannot survive macro expansion.
    private _groupConfig = _logic getVariable ["groupConfig", ""];
    if (_groupConfig isEqualTo "") then {
        _groupConfig = "configFile >> ""CfgGroups"" >> ""West"" >> ""BLU_F"" >> ""Infantry"" >> ""BUS_InfSquad""";
    };
    private _waves = _logic getVariable ["waves", -1];
    private _huntTrigger = _logic getVariable ["huntTrigger", "ghost_huntTrigger"];

    [
        call compile _groupSide,
        call compile _groupConfig,
        getPos _logic,
        _waves,
        call compile _huntTrigger
    ] call FUNC(aiHunter);
};
