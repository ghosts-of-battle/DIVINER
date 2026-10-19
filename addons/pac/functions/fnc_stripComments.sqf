#include "script_component.hpp"
/*
    File: fnc_stripComments.sqf
    Author: YonV
    Description: Take the comments out of a block of SQF so `compile` will
        take it.

        WHY THIS HAS TO EXIST. Stripping comments is the PREPROCESSOR's job -
        `preprocessFile` does it - and `compile` does not. A document kept as
        SQF text is compiled straight from the string, so the first `//` in it
        ends the mission's ability to read it:

            Error in expression <[
                //REQUIRED
                ["crate_medicalInfantry",>
            Error Invalid number in expression

        config_logistics.sqf, config_pylons.sqf and config_skill.hpp are all
        written by people and all carry comments, so every one of them failed
        this way the moment it was kept in the database instead of on disk
        (seen in the .rpt 2026-09-09; all three documents, twice each).

        STRING LITERALS ARE NOT TOUCHED. "http://..." is a URL, not a comment,
        and a magazine classname could hold anything - so the scan tracks
        whether it is inside a "..." or a '...' and only looks for comment
        markers when it is outside both. SQF escapes a quote by doubling it,
        which needs no special case here: the closing quote of the pair simply
        flips the flag off and the doubled one flips it straight back on.

    Parameters:
        0: STRING - SQF text, comments and all

    Returns:
        STRING - the same text with line and block comments removed

    Example:
        private _code = compile ([_text] call FUNC(stripComments));
*/

params [["_text", "", [""]]];

if (_text isEqualTo "") exitWith {""};

private _in = toArray _text;
private _n = count _in;
private _out = [];

private _i = 0;
private _inDouble = false;
private _inSingle = false;

while {_i < _n} do {
    private _c = _in # _i;
    private _next = if (_i + 1 < _n) then {_in # (_i + 1)} else {-1};

    // 34 = "   39 = '   47 = /   42 = *   10 = newline
    switch (true) do {
        case (_inDouble): {
            if (_c isEqualTo 34) then {_inDouble = false};
            _out pushBack _c;
            _i = _i + 1;
        };
        case (_inSingle): {
            if (_c isEqualTo 39) then {_inSingle = false};
            _out pushBack _c;
            _i = _i + 1;
        };
        case (_c isEqualTo 34): {
            _inDouble = true;
            _out pushBack _c;
            _i = _i + 1;
        };
        case (_c isEqualTo 39): {
            _inSingle = true;
            _out pushBack _c;
            _i = _i + 1;
        };
        // // to the end of the line. The newline is KEPT, so a line comment
        // cannot glue the line before it to the line after.
        case (_c isEqualTo 47 && _next isEqualTo 47): {
            while {_i < _n && {(_in # _i) isNotEqualTo 10}} do {_i = _i + 1};
        };
        // /* to the matching */, replaced by one space so it cannot glue two
        // tokens together either.
        case (_c isEqualTo 47 && _next isEqualTo 42): {
            _i = _i + 2;
            while {_i + 1 < _n && {!((_in # _i) isEqualTo 42 && (_in # (_i + 1)) isEqualTo 47)}} do {
                _i = _i + 1;
            };
            _i = _i + 2;
            _out pushBack 32;
        };
        default {
            _out pushBack _c;
            _i = _i + 1;
        };
    };
};

toString _out
