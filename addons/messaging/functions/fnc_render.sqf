#include "script_component.hpp"
/*
 * Author: Ghost
 * Renders a message as plain text, line by line, the way it would be read out
 * over the net. There is no UI yet, so this is how a message is seen at all -
 * in a notification, in a systemChat line, in the debug console. When a UI does
 * arrive it renders from the same payload, not from this string.
 *
 * Empty fields are skipped. A form with eleven lines of which two are filled is
 * a two line report, not nine blank rows.
 *
 * Arguments:
 * 0: Template id <STRING>
 * 1: Payload <ARRAY> - [fieldKey, value] pairs
 * 2: Include the template's own title as a first line <BOOL> (optional, default true)
 *
 * Return Value:
 * Rendered report <STRING>
 *
 * Example:
 * private _text = ["sitrep", _payload] call ghostD_messaging_fnc_render
 *
 * Public: Yes
 */

params [["_templateId", "", [""]], ["_payload", [], [[]]], ["_withTitle", true, [false]]];

private _template = [_templateId] call FUNC(template);
if (_template isEqualTo createHashMap) exitWith {""};

private _values = createHashMapFromArray _payload;
private _out = [];

if (_withTitle) then {
    _out pushBack (_template get "title");
};

// THE CARD'S OWN SHAPE, not a flattened paragraph - the user's spec, in red:
// every filled line renders as its key and title ("M - MECHANISM OF INJURY &
// TIME"), the answer on the next line, and a blank line after, for every
// template. A report should read back the way the card was filled in.
{
    _x params ["_lineKey", "_lineTitle", "_lineLabel", "_fields"];

    private _parts = [];

    {
        private _key = _x get "key";
        private _value = _values getOrDefault [_key, ""];
        private _prefix = _x get "prefix";

        private _text = switch (_x get "type") do {
            case "bool": {
                // A bool slot is not always a BOOL: reply prefills and edit
                // harvests leave STRINGS here, and the old eager && handed
                // that string straight to the and - 274 errors in one RPT,
                // and every abort killed the composer that called this,
                // which is what "the marker button does not work" and
                // "cannot send" looked like from the outside. Truthy
                // strings count as ticked.
                private _on = if (_value isEqualType false) then {_value} else {
                    _value isEqualType "" && {(toLower _value) in ["true", "yes", "x", "1"]}
                };
                if (_on) then {
                    [_prefix, "yes"] select (_prefix == "")
                } else {
                    ""
                };
            };
            case "grid": {
                // A grid field usually holds a position, but a player who typed
                // the grid rather than clicking the map leaves a string there.
                if (_value isEqualType [] && {count _value >= 2}) then {
                    mapGridPosition _value
                } else {
                    if (_value isEqualType "") then {trim _value} else {""};
                };
            };
            default {
                if (_value isEqualType "") then {trim _value} else {str _value};
            };
        };

        if (_text != "") then {
            // A prefix is the label the card prints in front of the value -
            // "URGENT 2", "EKIA 4" - so it is joined to the value, not listed
            // beside it. A bool has already folded its prefix into the text.
            if (_prefix != "" && {_x get "type" != "bool"}) then {
                _text = format ["%1%2", _prefix, _text];
            };
            _parts pushBack _text;
        };
    } forEach _fields;

    if (_parts isNotEqualTo []) then {
        _out pushBack format ["%1 - %2", toUpper _lineTitle, _lineLabel];
        _out pushBack (_parts joinString ", ");
        _out pushBack "";
    };
} forEach (_template get "lines");

_out joinString endl
