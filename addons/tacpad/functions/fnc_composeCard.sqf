#include "script_component.hpp"
/*
 * Author: Ghost
 * The inserted template's card, drawn into the compose pane the way the card is
 * printed: numbered lines, two columns, a control per field of the type that
 * field actually is.
 *
 * A LINE IS A LINE. The form used to lay every field out flat, so CASEVAC line 4
 * arrived as three unlabelled boxes called GREEN, YELLOW and RED with nothing on
 * screen saying they were LZ SECURITY or that you were meant to pick one.
 *
 * A FIELD IS ITS OWN TYPE. A field that is one of a set is drawn as that set
 * with one of them pressed; only text, numbers, grids and times are typed.
 *
 * NO LOCATION IS AUTO-FILLED. A grid that fills itself in with where you are
 * standing is a grid nobody reads before sending, and a CASEVAC pick-up that is
 * quietly your own position is how a bird goes to the wrong field. A location is
 * asked for, and there are three honest ways to answer it: CURRENT LOC for where
 * you are, MAP MARKER for somewhere already marked, or type it. A field that
 * names a marker rather than holding a position - an LZ name, a DZ mark - gets
 * the same list and takes the marker's NAME from it.
 *
 * A call sign and a time still prefill, because neither is a place: they are
 * facts the game already knows about the sender, and both are typed over in the
 * box they are shown in.
 *
 * Arguments:
 * 0: [x, width, top y, available height] of the pane, in the content group's own
 *    coordinates <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_pane", [0, 0, 0, 0], [[]], 4]];

_pane params ["_dx", "_dw", "_top", "_availH"];

private _display = uiNamespace getVariable [QGVAR(reader), displayNull];
if (isNull _display) exitWith {};

private _root = (_display displayCtrl IDC_RD_ROOT) controlsGroupCtrl IDC_RD_CONTENT;
if (isNull _root) exitWith {};

private _template = [GVAR(composeTemplate)] call EFUNC(messaging,template);
private _lines = _template getOrDefault ["lines", []];

([] call FUNC(theme)) params ["_ground", "_ink", "_accent", "_line"];

private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _rowH = ROW_H * GVAR(textScale) * GVAR(uiScale) * safeZoneH;
private _btnH = ([0.72] call FUNC(textH)) + 2 * _padY;
private _fontH = ([0.85] call FUNC(textH)) / 1.25;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _bodyW = _dw - 2 * _pad;
private _body = _display ctrlCreate [QGVAR(body), -1, _root];
_body ctrlSetPosition [_dx + _pad, _top, _bodyW, _availH];
_body ctrlSetBackgroundColor [0, 0, 0, 0];
_body ctrlCommit 0;

if (_lines isEqualTo []) exitWith {
    [_body, [0, 0, _bodyW, _rowH], "THIS REPORT HAS NOTHING TO FILL IN - PRESS SEND", _dim, 0.85] call FUNC(drawText);
};

private _scrollW = 14 * pixelW;
private _colW = (_bodyW - _scrollW - _pad * 2) / 2;

// What a field currently reads as. A grid picked off the map is held as a real
// position and shown as its grid; anything typed is held as it was typed; a
// call sign or a time nobody has touched shows what the game already knows.
private _fnc_shown = {
    params ["_key", ["_field", createHashMap]];

    private _grid = GVAR(composeGridText) getOrDefault [_key, ""];
    if (_grid isNotEqualTo "") exitWith {_grid};

    private _v = GVAR(composeValues) getOrDefault [_key, ""];
    if (_v isNotEqualTo "") exitWith {
        if (_v isEqualType "") then {_v} else {str _v}
    };

    switch (_field getOrDefault ["autoFill", "none"]) do {
        case "ownCallsign": {groupId (group player)};
        case "missionTime": {
            date params ["", "", "", "_hh", "_mm"];
            format ["%1%2", [_hh, 2] call CBA_fnc_formatNumber, [_mm, 2] call CBA_fnc_formatNumber]
        };
        default {
            // "pac:section.field" - a line of the current OPORD, when the pac
            // addon is loaded. METT-TC pre-fills its M, E and C from it.
            private _auto = _field getOrDefault ["autoFill", "none"];
            if ((_auto select [0, 4]) isEqualTo "pac:" && {!isNil "ghostD_pac_fnc_opordField"}) exitWith {
                [_auto select [4]] call ghostD_pac_fnc_opordField
            };
            ""
        };
    }
};

// One typed box.
private _fnc_edit = {
    params ["_key", "_x", "_y", "_w", "_h", ["_field", createHashMap], ["_multi", false]];

    [_body, [_x, _y, _w, _h], _line, RULE_THIN] call FUNC(drawFrame);

    // THE FIELD META, flush right inside the box, the design's full set: REQ
    // (never an asterisk), a number's range, AUTO on a prefilled fact, MARKER
    // on a field the marker list can answer. The edit stops short of it, so
    // the label cannot eat a click meant for the box; on a textarea it sits in
    // the first line's height rather than floating mid-void. Accent only when
    // REQ is among them - the design spends the accent on required and
    // nothing else here.
    private _tokens = [];
    if (_field getOrDefault ["required", false]) then {_tokens pushBack "REQ"};
    private _min = _field getOrDefault ["min", -1e10];
    private _max = _field getOrDefault ["max", 1e10];
    if ((_field getOrDefault ["type", "text"]) isEqualTo "number" && {_min > -1e9} && _max < 1e9) then {
        _tokens pushBack format ["%1-%2", _min, _max];
    };
    if ((_field getOrDefault ["autoFill", "none"]) isNotEqualTo "none") then {_tokens pushBack "AUTO"};
    if ((_field getOrDefault ["source", "manual"]) isEqualTo "marker") then {_tokens pushBack "MARKER"};

    private _metaW = 0;
    if (_tokens isNotEqualTo []) then {
        private _metaText = _tokens joinString " - ";
        _metaW = (_w * ((count _metaText) * 0.017 + 0.03)) min (_w * 0.4);
        [
            _body, [_x + _w - _metaW - _pad * 0.5, _y, _metaW, _h min _btnH],
            _metaText, ([_mute, _accent] select ("REQ" in _tokens)), 0.55, true, "right"
        ] call FUNC(drawText);
    };

    private _class = ["RscEdit", "RscEditMulti"] select (_multi && {isClass (configFile >> "RscEditMulti")});
    private _edit = _display ctrlCreate [_class, -1, _body];
    _edit ctrlSetPosition [_x + _pad, _y + _padY * 0.4, _w - 2 * _pad - _metaW, _h - _padY * 0.8];
    _edit ctrlSetBackgroundColor [0, 0, 0, 0];
    _edit ctrlSetTextColor _ink;
    _edit ctrlSetFontHeight _fontH;
    _edit ctrlSetTooltip (_field getOrDefault ["hint", ""]);
    _edit ctrlSetText ([_key, _field] call _fnc_shown);
    _edit setVariable [QGVAR(fieldKey), _key];

    // THE FLAG THAT SAYS "I HOLD TEXT". FUNC(composeHarvest) reads ctrlText off
    // every control carrying a fieldKey, and an empty one means the player
    // cleared the field - so it deletes the answer. Hit areas carry a fieldKey
    // too (a bool tick, a choice segment, CURRENT LOC, MAP MARKER) and ctrlText
    // on one is always "", so harvest was deleting the value of every button on
    // the card each time anything was pressed. This is the one control on a
    // field that actually holds typing.
    _edit setVariable [QGVAR(fieldEdit), true];
    _edit ctrlCommit 0;

    // Every keystroke feeds the preview - harvest, render, rewrite the one
    // control in place. No redraw, so focus never leaves the box being typed
    // in.
    _edit ctrlAddEventHandler ["KeyUp", {
        [] call FUNC(composeHarvest);

        private _pv = uiNamespace getVariable [QGVAR(previewCtrl), controlNull];
        if (isNull _pv) exitWith {false};

        ([] call FUNC(theme)) params ["", "_ink"];
        private _pvText = [([GVAR(composeTemplate), GVAR(composeValues) toArray false, false] call EFUNC(messaging,render))] call FUNC(xmlSafe);
        _pv ctrlSetStructuredText parseText format [
            "<t font='RobotoCondensed' size='0.72' color='%1'>%2</t>",
            _ink call BIS_fnc_colorRGBAtoHTML,
            _pvText regexReplace ["\r\n", "<br/>"]
        ];
        false
    }];
};

// The marker list, under whichever field asked for it. Two modes, because two
// kinds of field want it: a grid field takes the marker's POSITION - so the
// thread still anchors somewhere the map can pin - and a name field takes its
// NAME. Both are typed over afterwards like anything else.
private _fnc_markerDrop = {
    params ["_key", "_mode", ["_cur", true]];

    private _open = GVAR(composeMarker) isEqualTo _key;
    private _halfW = (_colW - _pad) / 2;

    // An ingress or an egress is never where the sender is standing, so a
    // noCur grid keeps the marker list and loses the CURRENT LOC cell - see
    // the field option in registerTemplate.
    private _grid = _mode isEqualTo "pos" && _cur;

    if (_grid) then {
        [_body, [_cx, _cy, _halfW, _btnH], _line, RULE_THIN] call FUNC(drawFrame);
        [_body, [_cx, _cy, _halfW, _btnH], "CURRENT LOC", _ink, 0.64, true, "center"] call FUNC(drawText);

        private _hit = [_body, [_cx, _cy, _halfW, _btnH], {
            params ["_ctrl"];
            [] call FUNC(composeHarvest);

            private _k = _ctrl getVariable [QGVAR(fieldKey), ""];
            private _at = getPosATL player;

            // The POSITION is what is stored - the thread anchors on it and PIN
            // TO MAP has something to pin. The grid is what is shown.
            GVAR(composeValues) set [_k, _at];
            GVAR(composeGridText) set [_k, mapGridPosition _at];
            GVAR(composeMarker) = "";

            {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
        }] call FUNC(drawHit);
        _hit setVariable [QGVAR(fieldKey), _key];
    };

    private _mx = _cx + ([0, _halfW + _pad] select _grid);
    private _mw = [_colW, _halfW] select _grid;

    [_body, [_mx, _cy, _mw, _btnH], ([_line, _accent] select _open), ([RULE_THIN, RULE_THICK] select _open)] call FUNC(drawFrame);
    [_body, [_mx, _cy, _mw, _btnH], "MAP MARKER", ([_ink, _accent] select _open), 0.64, true, "center"] call FUNC(drawText);

    private _hitM = [_body, [_mx, _cy, _mw, _btnH], {
        params ["_ctrl"];
        [] call FUNC(composeHarvest);
        private _k = _ctrl getVariable [QGVAR(fieldKey), ""];
        GVAR(composeMarker) = [_k, ""] select (GVAR(composeMarker) isEqualTo _k);
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
    _hitM setVariable [QGVAR(fieldKey), _key];

    _cy = _cy + _btnH + _padY;

    if (!_open) exitWith {};

    // The list drops under the field it belongs to, and pushes the rest of this
    // column down rather than covering it.
    private _markers = [10] call FUNC(markerGrids);

    if (_markers isEqualTo []) exitWith {
        [_body, [_cx + _pad, _cy, _colW - _pad, _rowH * 0.9], "NO MAP MARKERS", _dim, 0.66] call FUNC(drawText);
        _cy = _cy + _rowH * 0.9;
    };

    {
        _x params ["_label", "_pos"];
        private _my = _cy + _forEachIndex * _rowH * 0.9;

        [_body, [_cx + _pad, _my, _colW * 0.6 - _pad, _rowH * 0.9], _label, _ink, 0.7] call FUNC(drawText);
        [_body, [_cx + _colW * 0.6, _my, _colW * 0.4 - _pad, _rowH * 0.9], mapGridPosition _pos, _mute, 0.66, false, "right"] call FUNC(drawText);
        [_body, [_cx, _my + _rowH * 0.9 - RULE_THIN * pixelH, _colW, RULE_THIN * pixelH], _line] call FUNC(drawFill);

        private _hitP = [_body, [_cx, _my, _colW, _rowH * 0.9], {
            params ["_ctrl"];
            [] call FUNC(composeHarvest);

            private _k = _ctrl getVariable [QGVAR(fieldKey), ""];
            if (_k isEqualTo "") exitWith {};

            if (_ctrl getVariable [QGVAR(markerMode), "pos"] isEqualTo "name") then {
                GVAR(composeValues) set [_k, _ctrl getVariable [QGVAR(markerName), ""]];
                GVAR(composeGridText) deleteAt _k;
            } else {
                private _at = _ctrl getVariable [QGVAR(markerPos), []];
                if (_at isEqualTo []) exitWith {};
                GVAR(composeValues) set [_k, _at];
                GVAR(composeGridText) set [_k, mapGridPosition _at];
            };

            GVAR(composeMarker) = "";
            {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
        }] call FUNC(drawHit);
        _hitP setVariable [QGVAR(fieldKey), _key];
        _hitP setVariable [QGVAR(markerMode), _mode];
        _hitP setVariable [QGVAR(markerPos), _pos];
        _hitP setVariable [QGVAR(markerName), _label];
    } forEach _markers;

    _cy = _cy + (count _markers) * _rowH * 0.9 + _padY;
};

// The four colours the deck's bools and choices answer in. Green and amber are
// the design's; red and black are the theme's own accent and ink, which is
// what the design means by them.
private _gyrb = createHashMapFromArray [
    ["GREEN", [0.29, 0.58, 0.31, 1]],
    ["YELLOW", [0.85, 0.68, 0.28, 1]],
    ["AMBER", [0.85, 0.68, 0.28, 1]],
    ["RED", _accent],
    ["BLACK", _ink]
];

// A choice's segmented row, the design's: one row however many segments, the
// selected cell an INK fill - the accent is spent on required and priority,
// not on which smoke colour is picked - and a swatch in any segment whose
// answer IS a colour.
private _fnc_options = {
    params ["_key", "_options", "_selected", "_handler"];

    private _perRow = count _options;
    private _segW = _colW / _perRow;

    {
        _x params ["_value", "_label"];
        private _on = _selected isEqualTo _value;
        private _sx = _cx + (_forEachIndex % _perRow) * _segW;
        private _sy = _cy;

        if (_on) then {
            [_body, [_sx, _sy, _segW - _pad, _btnH], _ink] call FUNC(drawFill);
        } else {
            [_body, [_sx, _sy, _segW - _pad, _btnH], _line, RULE_THIN] call FUNC(drawFrame);
        };

        private _sw = _gyrb getOrDefault [toUpper _value, []];
        private _lx = _sx + _pad * 0.5;
        if (_sw isNotEqualTo []) then {
            private _swh = _btnH * 0.38;
            [_body, [_lx, _sy + (_btnH - _swh) * 0.5, _swh * pixelW / pixelH, _swh], _sw] call FUNC(drawFill);
            _lx = _lx + _swh * pixelW / pixelH + _pad * 0.5;
        };

        [
            _body, [_lx, _sy, _sx + _segW - _pad - _lx, _btnH], _label,
            ([_ink, _ground] select _on), 0.6, true,
            ["center", "left"] select (_sw isNotEqualTo [])
        ] call FUNC(drawText);

        private _hit = [_body, [_sx, _sy, _segW - _pad, _btnH], _handler] call FUNC(drawHit);
        _hit setVariable [QGVAR(fieldKey), _key];
        _hit setVariable [QGVAR(choice), _value];
        _hit setVariable [QGVAR(exclusiveKeys), _options apply {_x # 0}];
    } forEach _options;

    _cy = _cy + _btnH + _padY;
};

// ------------------------------------------------------------ badge strip ---
// The card's facts, the design's strip: what sending this DOES - the task it
// opens, where it anchors on the map, who else it reaches - said once at the
// top rather than discovered after SEND.
private _badges = [];
private _transitions = _template getOrDefault ["transitionsTo", ""];
if (_transitions isNotEqualTo "") then {_badges pushBack format ["OPENS TASK - %1", _transitions]};

private _anchorKey = ((_template getOrDefault ["anchor", ""]) splitString ".") param [0, ""];
if (_anchorKey isNotEqualTo "") then {
    private _ai = _lines findIf {(_x param [0, ""]) isEqualTo _anchorKey};
    if (_ai > -1) then {
        _badges pushBack format ["MAP ANCHOR - %1", toUpper ((_lines # _ai) param [1, _anchorKey])];
    };
};

if ((_template getOrDefault ["broadcast", ""]) isNotEqualTo "") then {
    _badges pushBack format ["BROADCAST - %1", toUpper (_template get "broadcast")];
};
if ((_template getOrDefault ["reportable", ""]) isNotEqualTo "") then {
    _badges pushBack format ["ALIVE FWD - %1", toUpper (_template get "reportable")];
};
if ((_template getOrDefault ["routing", ""]) isNotEqualTo "") then {_badges pushBack "ROUTING - CMD TICK"};
if ((_template getOrDefault ["kind", "root"]) isEqualTo "both") then {_badges pushBack "ROOT + REPLY"};

private _stripH = 0;
if (_badges isNotEqualTo []) then {
    _stripH = ([0.52] call FUNC(textH)) + _padY;
    [_body, [0, 0, _bodyW - _scrollW, _stripH], [_ink # 0, _ink # 1, _ink # 2, 0.07]] call FUNC(drawFill);
    [
        _body, [_pad, 0, _bodyW - _scrollW - 2 * _pad, _stripH],
        _badges joinString "  |  ", _mute, 0.52, true
    ] call FUNC(drawText);
    _stripH = _stripH + _padY;
};

// TEMPLATE ON THE LEFT, THE MESSAGE ON THE RIGHT - the split the design
// draws and the user asked for three times. Every line stacks down the left
// column; the right column is the preview, drawn after the loop.
private _colY = [_stripH, _stripH];
private _half = count _lines;

{
    _x params ["", "_lineTitle", "_lineLabel", "_fields", ""];

    private _col = parseNumber (_forEachIndex >= _half);
    private _cx = _col * (_colW + _pad * 2);
    private _cy = _colY # _col;

    // ------------------------------------------------------- the line head ---
    // THE KEY BOX, the design's: the verbatim key - "Line 1", "S", "Warno 3A"
    // - in an ink border with the line title beside it. It replaces a bare
    // counter, and it is the field-key contract made visible: the key on the
    // box is the key the payload files under.
    private _keyW = (_colW * (0.085 + 0.021 * count _lineTitle)) min (_colW * 0.32);
    private _keyH = ([0.6] call FUNC(textH)) + _padY * 0.6;
    [_body, [_cx, _cy + (_rowH - _keyH) * 0.5, _keyW, _keyH], _ink, RULE_THICK] call FUNC(drawFrame);
    [_body, [_cx, _cy + (_rowH - _keyH) * 0.5, _keyW, _keyH], toUpper _lineTitle, _ink, 0.6, true, "center"] call FUNC(drawText);
    [_body, [_cx + _keyW + _pad, _cy, _colW - _keyW - _pad, _rowH], _lineLabel, _ink, 0.7, true, "left", true] call FUNC(drawText);
    _cy = _cy + _rowH;

    // ----------------------------------------------------------- the fields ---
    // Plain typed fields run side by side under one line - "URGENT 2 PRIORITY 1
    // ROUTINE 0" is one answer - and anything that needs a row of its own takes
    // one. The run is flushed in order, so nothing is reordered on the card.
    private _run = [];

    private _fnc_flushRun = {
        if (_run isEqualTo []) exitWith {};

        private _n = count _run;
        private _cellW = _colW / _n;

        // A PREFIXED FIELD TAKES ITS LABEL BESIDE THE BOX, bold, the way the
        // design draws EKIA and ALT - a caption row over a third-of-a-column
        // cell wrapped "FRIENDLY FORCES / POSTURE" straight into the input
        // under it. Only unprefixed fields keep a caption line, small and
        // untracked so it fits the cell it names; with one field on the line
        // the line label is the caption. No asterisk anywhere - required is
        // the REQ meta inside the field, drawn by _fnc_edit.
        private _capH = 0;
        if (_n > 1 && {(_run findIf {(_x getOrDefault ["prefix", ""]) isEqualTo ""}) > -1}) then {
            _capH = ([0.5] call FUNC(textH)) + _padY * 0.3;
        };

        {
            private _key = _x getOrDefault ["key", ""];
            private _sx = _cx + _forEachIndex * _cellW;
            private _prefix = _x getOrDefault ["prefix", ""];

            private _capW = 0;
            if (_n > 1) then {
                if (_prefix isEqualTo "") then {
                    [_body, [_sx, _cy, _cellW - _pad, _capH], _x getOrDefault ["hint", ""], _mute, 0.5, true] call FUNC(drawText);
                } else {
                    // SIZED TO THE WORD, not to a flat third of the cell (user,
                    // 2026-09-03). URGENT / PRIORITY / ROUTINE over three cells
                    // of a third-width column had 34% each, and PRIORITY wrapped
                    // onto a second line - so the caption for a 0-99 box was
                    // twice the height of the box beside it.
                    //
                    // A NUMBER BOX HOLDS TWO DIGITS. It does not need the two
                    // thirds it was taking, so the label may have what it needs
                    // and the box keeps the rest - never less than 30%, which is
                    // still wider than "99" plus its range meta.
                    private _fh = ([0.62] call FUNC(textH)) / 1.25;
                    private _need = (count _prefix) * _fh * 0.55 * pixelW / pixelH + _pad;
                    _capW = _need min ((_cellW - _pad) * 0.70);
                    [_body, [_sx, _cy + _capH, _capW - _pad * 0.5, _btnH], toUpper _prefix, _ink, 0.62, true] call FUNC(drawText);
                };
            };

            [_key, _sx + _capW, _cy + _capH, _cellW - _pad - _capW, _btnH, _x, false] call _fnc_edit;
        } forEach _run;

        _cy = _cy + _capH + _btnH + _padY;
        _run = [];
    };

    {
        private _field = _x;
        private _key = _field getOrDefault ["key", ""];
        private _type = _field getOrDefault ["type", "text"];
        private _choices = _field getOrDefault ["choices", []];

        // ------------------------------------------------------------ choice --
        if (_type isEqualTo "choice" && {_choices isNotEqualTo []}) then {
            call _fnc_flushRun;

            // THE ROW SAYS WHAT IT CHOOSES. A line holding several choice
            // fields - SITREP's STATUS is four - drew them as four unlabelled
            // colour rows, and nobody could tell AMMO from CE without counting.
            // One field under a line needs no caption; the line label is it.
            if (count _fields > 1) then {
                private _cap = _field getOrDefault ["prefix", ""];
                if (_cap isEqualTo "") then {_cap = _field getOrDefault ["hint", ""]};
                if (_cap isNotEqualTo "") then {
                    [_body, [_cx, _cy, _colW, _rowH * 0.65], _cap, _mute, 0.55, true, "left", true] call FUNC(drawText);
                    _cy = _cy + _rowH * 0.65;
                };
            };

            [
                _key,
                _choices apply {[_x, _x]},
                GVAR(composeValues) getOrDefault [_key, ""],
                {
                    params ["_ctrl"];
                    [] call FUNC(composeHarvest);
                    GVAR(composeValues) set [
                        _ctrl getVariable [QGVAR(fieldKey), ""],
                        _ctrl getVariable [QGVAR(choice), ""]
                    ];
                    {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
                }
            ] call _fnc_options;

            continue;
        };

        // -------------------------------------------------------------- bool --
        // THE DESIGN'S SELECTOR ROW: a square tick, a colour swatch where the
        // key IS a colour, the key in bold, the description dimmed - and an
        // exclusive set is these rows behaving as radios. They were a
        // segmented strip once, which read as one wide button rather than
        // three answers, and a lone bool was a YES/NO box that said neither
        // what YES meant nor which way was the default.
        if (_type isEqualTo "bool") then {
            call _fnc_flushRun;

            private _on = (GVAR(composeValues) getOrDefault [_key, false]) isEqualTo true;
            private _rowB = _btnH * 0.9;
            private _boxH = _btnH * 0.5;
            private _boxW = _boxH * pixelW / pixelH;

            if (_on) then {
                [_body, [_cx, _cy + (_rowB - _boxH) * 0.5, _boxW, _boxH], _ink] call FUNC(drawFill);
            } else {
                [_body, [_cx, _cy + (_rowB - _boxH) * 0.5, _boxW, _boxH], _ink, RULE_THIN] call FUNC(drawFrame);
            };

            private _label = _field getOrDefault ["prefix", ""];
            private _desc = _field getOrDefault ["hint", ""];
            if (_label isEqualTo "") then {_label = _desc; _desc = ""};

            private _tx = _cx + _boxW + _pad;
            private _sw = _gyrb getOrDefault [toUpper _label, []];
            if (_sw isNotEqualTo []) then {
                private _swh = _boxH * 0.8;
                [_body, [_tx, _cy + (_rowB - _swh) * 0.5, _swh * pixelW / pixelH, _swh], _sw] call FUNC(drawFill);
                _tx = _tx + _swh * pixelW / pixelH + _pad;
            };

            private _labW = _colW * 0.3;
            [_body, [_tx, _cy, _labW, _rowB], toUpper _label, _ink, 0.64, true] call FUNC(drawText);
            if (_desc isNotEqualTo "") then {
                [_body, [_tx + _labW + _pad, _cy, _cx + _colW - _tx - _labW - 2 * _pad, _rowB], _desc, _dim, 0.58, false] call FUNC(drawText);
            };

            private _hit = [_body, [_cx, _cy, _colW, _rowB], {
                params ["_ctrl"];
                [] call FUNC(composeHarvest);
                private _k = _ctrl getVariable [QGVAR(fieldKey), ""];
                private _ex = _ctrl getVariable [QGVAR(exclusiveKeys), []];
                private _was = (GVAR(composeValues) getOrDefault [_k, false]) isEqualTo true;

                // A radio stays pressed; a lone tick toggles.
                if (_ex isEqualTo []) then {
                    GVAR(composeValues) set [_k, !_was];
                } else {
                    {GVAR(composeValues) deleteAt _x} forEach _ex;
                    GVAR(composeValues) set [_k, true];
                };
                {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
            }] call FUNC(drawHit);
            _hit setVariable [QGVAR(fieldKey), _key];

            private _exTag = _field getOrDefault ["exclusive", ""];
            private _sibs = [];
            if (_exTag isNotEqualTo "") then {
                _sibs = (_fields select {(_x getOrDefault ["exclusive", ""]) isEqualTo _exTag}) apply {_x getOrDefault ["key", ""]};
            };
            _hit setVariable [QGVAR(exclusiveKeys), _sibs];

            _cy = _cy + _rowB + _padY * 0.4;
            continue;
        };

        // -------------------------------------------------------------- grid --
        if (_type isEqualTo "grid") then {
            call _fnc_flushRun;

            [_key, _cx, _cy, _colW, _btnH, _field, false] call _fnc_edit;
            _cy = _cy + _btnH + _padY * 0.5;

            [_key, "pos", !(_field getOrDefault ["noCur", false])] call _fnc_markerDrop;
            continue;
        };

        // ---------------------------------------------------------- textarea --
        if (_type isEqualTo "textarea") then {
            call _fnc_flushRun;
            [_key, _cx, _cy, _colW, _btnH * 2.4, _field, true] call _fnc_edit;
            _cy = _cy + _btnH * 2.4 + _padY;
            continue;
        };

        // A field that names a marker rather than holding one: the same list,
        // and it puts the marker's name in the box.
        if ((_field getOrDefault ["source", "manual"]) isEqualTo "marker") then {
            call _fnc_flushRun;

            [_key, _cx, _cy, _colW, _btnH, _field, false] call _fnc_edit;
            _cy = _cy + _btnH + _padY * 0.5;

            [_key, "name"] call _fnc_markerDrop;
            continue;
        };

        // Everything else is a box, and boxes share a row.
        _run pushBack _field;
    } forEach _fields;

    call _fnc_flushRun;

    _cy = _cy + _padY * 0.5;
    [_body, [_cx, _cy, _colW, RULE_THIN * pixelH], _line] call FUNC(drawFill);
    _colY set [_col, _cy + _padY * 1.5];
} forEach _lines;

// ------------------------------------------------------------ the preview ---
// THE MESSAGE AS IT WILL READ, rendered off the same values the form holds,
// through the same renderer every reader uses - so what the sender sees on
// the right is literally what everyone else gets.
private _px = _colW + _pad * 2;
private _pvH = ((_colY # 0) max (_colY # 1)) - _stripH;
[_body, [_px - _pad, _stripH, RULE_THICK * pixelW, _pvH max (_rowH * 4)], _ink] call FUNC(drawFill);
[_body, [_px + _pad, _stripH, _colW - _pad, _rowH], "MESSAGE PREVIEW", _mute, 0.65, true, "left", true] call FUNC(drawText);

// ONE LIVE CONTROL, updated on every keystroke - "preview should preview the
// message", in red. The edits' KeyUp harvests and rewrites this in place, so
// the right column reads back what is being typed as it is typed.
private _pv = _display ctrlCreate [QGVAR(cell), -1, _body];
_pv ctrlSetPosition [_px + _pad, _stripH + _rowH, _colW - 2 * _pad, ((_colY # 0) max (_rowH * 8)) - _stripH];
_pv ctrlSetFontHeight (TEXT_BASE * pixelH * pixelGrid * GVAR(textScale) * GVAR(uiScale));
_pv ctrlCommit 0;
uiNamespace setVariable [QGVAR(previewCtrl), _pv];

private _pvText = [([GVAR(composeTemplate), GVAR(composeValues) toArray false, false] call EFUNC(messaging,render))] call FUNC(xmlSafe);
_pv ctrlSetStructuredText parseText format [
    "<t font='RobotoCondensed' size='0.72' color='%1'>%2</t>",
    _ink call BIS_fnc_colorRGBAtoHTML,
    _pvText regexReplace ["\r\n", "<br/>"]
];

// --------------------------------------------------------------- the foot ---
// SUBJ, the design's footer: the thread-subject pattern verbatim, so the
// sender knows what the row in everyone's reader will say before pressing
// SEND - which sits one rule down in the pane, where it always was.
private _subject = _template getOrDefault ["subject", ""];
if (_subject isNotEqualTo "") then {
    private _fy = (_colY # 0) max (_colY # 1);
    [_body, [0, _fy, _bodyW - _scrollW, RULE_THICK * pixelH], _ink] call FUNC(drawFill);
    _fy = _fy + _padY;
    [_body, [_pad, _fy, _bodyW * 0.1, _rowH * 0.8], "SUBJ", _mute, 0.55, true, "left", true] call FUNC(drawText);
    [
        _body, [_pad + _bodyW * 0.1, _fy, _bodyW - _scrollW - _bodyW * 0.1 - 2 * _pad, _rowH * 0.8],
        _subject, _ink, 0.6, true
    ] call FUNC(drawText);
};
