#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_welcomeShow

Description:
    The welcome panel, from the database if the unit has written one, from the
    mission's config if not.

    ONE CALL FOR THE MISSION. initPlayerLocal.sqf used to read
    missionConfigFile >> "GHOSTFR_Welcome" itself and hand it to the modal.
    That is fine while the text lives in the mission, and impossible once it
    lives in the database - a mission cannot know whether a document exists.
    So the mission calls this instead and the mod decides where the text came
    from; a mission that ships no config folder and one that ships a full one
    both call the same line.

    THE DATABASE WINS, BUT ONLY IF IT HAS SOMETHING. An empty or absent
    <unit>.welcome leaves the mission's own class in charge, so turning the
    template on is additive and nothing breaks the day the database is empty.

    THE TEXT IS WRITTEN, NOT ASSEMBLED (user, 2026-09-09: "instead of all this
    crap how about a simple editor that you can insert returns and set the html
    stuff arma uses"). "text" is one block of Arma structured text - the
    writer's own returns and his own <t>, <br/>, <img> and <a> tags - and it is
    handed to the panel as a single line, so the tags do the work the per-line
    size/colour/align records used to. The returns become <br/> here because a
    real newline in structured text is not a line break.

    A welcome that predates this has "lines" instead and still draws: the two
    are read in the same place and "text" wins when both are set.

    IT WAITS FOR THE MISSION DISPLAY, because the modal draws on display 46 and
    this can be called while the loading screen is still up.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

[{
    // The structure arrives by publicVariable, so a client that joins before
    // the server has adopted the database waits for it rather than falling
    // back to the mission's config and showing the wrong panel.
    !isNull findDisplay 46 && {!isNil QGVAR(ready)}
}, {
    private _w = (GVAR(structure) getOrDefault ["welcome", createHashMap]);
    private _text = _w getOrDefault ["text", ""];
    if !(_text isEqualType "") then {_text = ""};
    private _lines = _w getOrDefault ["lines", []];
    if !(_lines isEqualType []) then {_lines = []};

    private _title = "";
    private _subtitle = "";

    if (_text isNotEqualTo "" || {count _lines > 0}) then {
        _title = _w getOrDefault ["title", ""];
        _subtitle = _w getOrDefault ["subtitle", ""];

        if (_text isNotEqualTo "") then {
            // ONE LINE, THE WRITER'S MARKUP. The panel draws a content entry
            // as <t align size color>%1</t>, so a whole briefing goes in as a
            // single entry and every heading, colour and break inside it is a
            // tag the writer put there. 0.9 is the size the old per-line
            // editor gave body text, so an untagged paragraph reads exactly as
            // it did before.
            // A real newline is not a line break in structured text, so the
            // writer's returns become <br/>. CRLF first: a paragraph typed on
            // Windows would otherwise break twice.
            private _markup = _text regexReplace [toString [13, 10], "<br/>"];
            _markup = _markup regexReplace ["[" + toString [13, 10] + "]", "<br/>"];
            _lines = [[_markup, 0.9, [1, 1, 1], 0]];
        };
    } else {
        // Nothing in the database - the mission's own class, as before.
        // TWO CLASS NAMES: the framework missions call it GHOSTFR_Welcome and
        // the older unit missions GHOST_Welcome. Checking both means neither
        // has to be edited to keep the panel it already had.
        private _cfg = missionConfigFile >> "GHOSTFR_Welcome";
        if (!isClass _cfg) then {_cfg = missionConfigFile >> "GHOST_Welcome"};
        if (!isClass _cfg) exitWith {_lines = []};
        _title = getText (_cfg >> "title");
        _subtitle = getText (_cfg >> "subtitle");
        _lines = getArray (_cfg >> "lines");
    };

    if !(_lines isEqualType []) exitWith {};
    if (count _lines isEqualTo 0) exitWith {};

    [[_title, _subtitle], _lines, true] call EFUNC(common,modal);
}, []] call CBA_fnc_waitUntilAndExecute;
