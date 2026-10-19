#include "script_component.hpp"
/*
    File: fnc_uiSlug.sqf
    Author: YonV
    Description: A platoon, squad or role name as it appears in a variant id
        - plt_<PLATOON>, sqd_<SQUAD>, role_<CLASS>: upper case, every run of
        anything that is not a letter or a digit one underscore, none at
        the ends. The same rule as the website's ghostd_slug and the groups
        addon's _fnc_slug, so the three name the same document.

    Parameters:
        0: Name <STRING>

    Returns:
        Slug <STRING>
*/

params [["_name", "", [""]]];

private _out = [];
private _wasSep = true;
{
    private _alnum = (_x >= 48 && _x <= 57) || (_x >= 65 && _x <= 90);
    if (_alnum) then {
        _out pushBack _x;
        _wasSep = false;
    } else {
        if (!_wasSep) then {_out pushBack 95};
        _wasSep = true;
    };
} forEach (toArray (toUpper _name));
if (_out isNotEqualTo [] && {(_out # ((count _out) - 1)) isEqualTo 95}) then {_out deleteAt ((count _out) - 1)};
toString _out
