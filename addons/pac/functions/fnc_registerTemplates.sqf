#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_registerTemplates

Description:
    Registers the two message templates PAC uses, on every machine, unless
    the mission's own GHOSTFR_Templates already has them - a mission's deck
    wins, and this is the default behind it.

    "opord"  - what FUNC(opordPost) sends: the OPORD's sections as lines.
    "mettc"  - the METT-TC estimate a leader writes back against it:
               Mission, Enemy, Terrain and weather, Troops and support,
               Time, Civil considerations, and a LOCATION grid drawn from
               the map (the "add marker" control the handoff asks for).
               Mission, Enemy and Civil pre-fill from the current OPORD
               through autoFill = "pac:section.field", which the compose
               card answers with FUNC(opordField). ONLY A LEADER MAY SEND
               ONE - senderMustBe = "leader", which messaging answers off the
               mission's isLeader flag; the picker hides it from anyone else
               and the server refuses it from anyone else.

    Runs in postInit so messaging's preInit has already loaded the mission's
    templates; the check for an existing id is what makes the order matter.
    Every machine registers the same thing, which is messaging's rule: a
    template must be identical wherever a message is rendered.

Parameters:
    None

Returns:
    How many were registered <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

if (isNil "ghostD_messaging_fnc_registerTemplate") exitWith {0};

private _have = missionNamespace getVariable ["ghostD_messaging_templateIds", []];
private _made = 0;

private _fnc_text = {
    params ["_hint", ["_auto", "none"]];
    [["", _hint, "text", [["autoFill", _auto]]]]
};

if !("opord" in _have) then {
    private _lines = [
        ["Header", "OPORD", [["", "Title", "text"], ["", "Date", "text"]]],
        ["Situation", "1. SITUATION", ["Overview / enemy / friendly / civil"] call _fnc_text],
        ["Mission", "2. MISSION AND EXECUTION", ["Mission / execution"] call _fnc_text],
        ["AdminLog", "4. ADMIN AND LOGISTICS", ["Admin / logistics / special / Arma considerations"] call _fnc_text],
        ["CommandSignal", "5. COMMAND AND SIGNAL", ["Command / signal"] call _fnc_text],
        ["ROE", "ROE", ["Rules of engagement"] call _fnc_text]
    ];
    if ((["opord", "OPORD", "OPORD", _lines, [["kind", "root"], ["priority", "normal"], ["subject", "OPORD {Header.A}"], ["replyableWith", ["mettc", "roger", "freetext"]]]] call ghostD_messaging_fnc_registerTemplate) isNotEqualTo "") then {
        _made = _made + 1;
    };
};

if !("mettc" in _have) then {
    private _lines = [
        ["Callsign", "CALL SIGN", [["", "Call sign", "callsign", [["autoFill", "ownCallsign"]]]]],
        ["Mission", "M - MISSION", ["Mission as understood", "pac:mission.mission"] call _fnc_text],
        ["Enemy", "E - ENEMY", ["Enemy composition, disposition, strength, intent", "pac:situation.enemy"] call _fnc_text],
        ["Terrain", "T - TERRAIN AND WEATHER", ["Observation, cover, obstacles, key terrain, avenues; weather"] call _fnc_text],
        ["Troops", "T - TROOPS AND SUPPORT", ["Own troops, attachments, support available"] call _fnc_text],
        ["Time", "T - TIME", ["Time available, timings"] call _fnc_text],
        ["Civil", "C - CIVIL CONSIDERATIONS", ["Areas, structures, capabilities, organisations, people, events", "pac:situation.civilTerrain"] call _fnc_text],
        ["Location", "LOCATION", [["", "Grid or marker", "grid", [["source", "mapClick"]]]]]
    ];
    if ((["mettc", "METT-TC", "METT-TC", _lines, [["kind", "both"], ["priority", "normal"], ["subject", "METT-TC {Callsign.A}"], ["anchor", "Location.A"], ["senderMustBe", "leader"], ["replyableWith", ["roger", "wilco", "freetext", "close"]]]] call ghostD_messaging_fnc_registerTemplate) isNotEqualTo "") then {
        _made = _made + 1;
    };
};

TRACE_1("PAC templates registered",_made);
_made
