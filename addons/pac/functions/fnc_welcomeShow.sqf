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
    private _lines = _w getOrDefault ["lines", []];

    private _title = "";
    private _subtitle = "";

    if (_lines isEqualType [] && {count _lines > 0}) then {
        _title = _w getOrDefault ["title", ""];
        _subtitle = _w getOrDefault ["subtitle", ""];
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
