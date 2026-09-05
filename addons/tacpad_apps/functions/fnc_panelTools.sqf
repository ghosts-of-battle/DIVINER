#include "script_component.hpp"
/*
 * Author: Ghost
 * The MAP TOOLS strip, restyled into the tacpad and put back on the vanilla map.
 * A four-across grid of outlined cells. Each is a TOGGLE: press to start, press
 * again to stop, and the running one inverts to an ink fill so the strip says
 * what is on. OFF is the one accent-outlined cell and stops whatever is.
 *
 * IT DOES NOT REIMPLEMENT THE TOOLS. Compass, distance, terrain profile, line
 * of sight, building marking, grid placement and find-flat are PLP Map Tools
 * Remastered's, and they stay PLP's - this is a front end that calls them and
 * nothing more. No PLP code is copied into ghost, which is both the licensing
 * answer and the maintenance one: their mod updates and this keeps working.
 *
 * With PLP absent those buttons draw dimmed and the header says so. It is a
 * front end for a mod that may not be loaded, so that is a state, not a fault.
 *
 * TWO CELLS ARE OURS AND ALWAYS WORK. CENTRE puts the map back on the player,
 * and OFF stops whatever tool is running. Neither asks PLP for anything, so
 * neither dims with it - a strip on which every button is dead is a strip a
 * player stops looking at.
 *
 * Arguments:
 * 0: Body <CONTROL>
 * 1: Panel id <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_body", controlNull, [controlNull]], ["_id", "", [""]]];

if (isNull _body) exitWith {};

{ctrlDelete _x} forEach (allControls (ctrlParent _body) select {(ctrlParentControlsGroup _x) isEqualTo _body});

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _w = (ctrlPosition _body) # 2;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.35];

// [label, the PLP function to call, ours]. Held as strings so a missing mod is
// a nil check rather than a compile error. The two marked ours are not PLP's and
// are not toggles: CENTRE is a momentary action, OFF is how a player stops
// whatever tool is running without knowing which one it was.
//
// CENTRE IS FIRST because it is the one pressed most and the one that always
// works. A man looking at his own map has usually panned away from himself.
private _tools = [
    ["CENTRE", "", true],
    ["COMPASS", "PLP_fnc_SMT_compass", false],
    ["DISTANCE", "PLP_fnc_SMT_distance", false],
    ["PROFILE", "PLP_fnc_SMT_height", false],
    ["SIGHT", "PLP_fnc_SMT_LineOfSight", false],
    ["BUILDINGS", "PLP_fnc_SMT_markHouses", false],
    ["GRID", "PLP_fnc_SMT_placeGrid", false],
    ["FIND FLAT", "PLP_fnc_SMT_findFlat", false]
];

// OFF LIVES ON THE TITLE BAR - the user's ask: it had a third grid row to
// itself. Drawn into the GROUP's header, over the meta slot the strip never
// used for a readout.
private _entry = (missionNamespace getVariable [QEGVAR(tacpad,open), createHashMap]) getOrDefault [_id, []];
_entry params [["_group", controlNull]];
if (!isNull _group) then {
    (ctrlPosition _group) params ["", "", "_gw"];
    private _headerH = HEADER_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
    private _offW = _gw * 0.18;
    private _offX = _gw - _offW - _pad - RULE_THICK * pixelW;

    [_group, [_offX, RULE_THICK * pixelH + _padY * 0.3, _offW, _headerH - _padY * 0.6], _accent, RULE_THICK] call EFUNC(tacpad,drawFrame);
    [_group, [_offX, RULE_THICK * pixelH + _padY * 0.3, _offW, _headerH - _padY * 0.6], "CANCEL", _accent, 0.7, true, "center"] call EFUNC(tacpad,drawText);
    [_group, [_offX, RULE_THICK * pixelH + _padY * 0.3, _offW, _headerH - _padY * 0.6], {
        params ["_ctrl"];
        private _map = (ctrlParent _ctrl) displayCtrl 51;
        private _ehId = uiNamespace getVariable [QGVAR(toolEH), -1];
        if (_ehId >= 0 && {!isNull _map}) then {
            _map ctrlRemoveEventHandler ["Draw", _ehId];
        };
        uiNamespace setVariable [QGVAR(toolEH), nil];
        GVAR(activeTool) = "";
        {["tools"] call EFUNC(tacpad,rebuild)} call CBA_fnc_execNextFrame;
    }] call EFUNC(tacpad,drawHit);
};

[_id, ["", "PLP NOT LOADED"] select (isNil "PLP_fnc_SMT_Main"), isNil "PLP_fnc_SMT_Main"] call EFUNC(tacpad,headerMeta);

private _cols = 4;
private _rows = ceil (count _tools / _cols);
private _cellW = (_w - 2 * _pad) / _cols;

// SIZED OFF THE LABEL, not off a row. A fixed fraction of ROW_H is a gamble on
// the player's UI scale: at anything above the default the label was taller than
// the cell and the cell's own bottom edge was drawn straight through the middle
// of the word. The box is the line plus a pad, so it fits at any scale.
private _labelSize = 0.9;
private _cellH = ([_labelSize] call EFUNC(tacpad,textH)) + 2 * _padY;

{
    _x params ["_label", "_fnc", ["_own", false]];

    private _off = _label in ["OFF", "CANCEL"];
    private _available = _own || _off || {!isNil _fnc};
    private _running = !_off && {!_own} && _fnc == GVAR(activeTool);

    private _cx = _pad + (_forEachIndex mod _cols) * _cellW;
    private _cy = _padY + floor (_forEachIndex / _cols) * (_cellH + _padY);

    // Cells sit in the grid with a gap, so the outlines never double up into a
    // 4px rule where two of them meet.
    private _boxW = _cellW - _pad;

    private _edge = switch (true) do {
        case (!_available): {_dim};
        case (_off): {_accent};
        default {_ink};
    };

    private _label2Ink = switch (true) do {
        case (!_available): {_dim};
        case (_running): {_ground};
        case (_off): {_accent};
        default {_ink};
    };

    // The running tool is the one filled cell - the design's pressed state, held
    // rather than momentary, because the tool is still on the map.
    if (_running) then {
        [_body, [_cx, _cy, _boxW, _cellH], _ink] call EFUNC(tacpad,drawFill);
    } else {
        [_body, [_cx, _cy, _boxW, _cellH], _edge, RULE_THICK] call EFUNC(tacpad,drawFrame);
    };

    [_body, [_cx + _pad, _cy, _boxW - 2 * _pad, _cellH], _label, _label2Ink, _labelSize, true] call EFUNC(tacpad,drawText);

    if (!_available) then {continue};

    // A TRUE TOGGLE, now that stopping one is possible at all.
    //
    // PLP'S TOOLS DO NOT TOGGLE. Every one of them adds a "Draw" handler to the
    // map control and stores its id in uiNamespace under PLP_SMT_EH - and none
    // of them ever removes one. Calling a tool a second time therefore starts a
    // SECOND handler and overwrites the id of the first, which is then drawing
    // forever with nothing left that can reach it. That is why pressing a tool
    // again, pressing OFF, and closing the map all failed to stop anything: the
    // suite was calling the start function and calling it a stop.
    //
    // The handler id is taken off PLP the instant the tool registers it, and
    // stopping is ctrlRemoveEventHandler, which is the only thing that works.
    // One at a time, so one id is enough - and matches PLP's own single slot.
    private _hit = [_body, [_cx, _cy, _boxW, _cellH], {
        params ["_ctrl"];

        private _name = _ctrl getVariable [QGVAR(toolFnc), ""];
        private _map = (ctrlParent _ctrl) displayCtrl 51;
        private _running = GVAR(activeTool);

        // CENTRE is a momentary action, not a toggle: it moves the map and
        // leaves everything else exactly as it was, including whichever PLP tool
        // happens to be running. Stopping a distance measurement because
        // somebody wanted to see where they were would be its own small betrayal.
        if (_ctrl getVariable [QGVAR(toolOwn), false]) exitWith {
            if (isNull _map) exitWith {};

            // The vehicle when there is one - on a fast mover the man and the
            // aircraft are not in the same grid square by the time the map
            // finishes moving.
            private _at = player;
            if !(isNull objectParent player) then {_at = objectParent player};

            // The zoom is left where the player put it. This is CENTRE, not
            // RESET VIEW, and taking somebody's zoom away is how a button gets
            // pressed once.
            ctrlMapAnimClear _map;
            _map ctrlMapAnimAdd [0.2, ctrlMapScale _map, getPosATL _at];
            ctrlMapAnimCommit _map;
        };

        private _id = uiNamespace getVariable [QGVAR(toolEH), -1];
        if (_id >= 0 && {!isNull _map}) then {
            _map ctrlRemoveEventHandler ["Draw", _id];
        };
        uiNamespace setVariable [QGVAR(toolEH), nil];
        GVAR(activeTool) = "";

        // Pressing the tool that was already running has now stopped it, so it
        // is not started again - that is the toggle. OFF names no tool and stops
        // there. Anything else starts, on the map the player is already looking
        // at rather than after closing it.
        if (_name != "" && _name != _running && {!isNil _name}) then {
            [] call (missionNamespace getVariable _name);
            uiNamespace setVariable [QGVAR(toolEH), uiNamespace getVariable ["PLP_SMT_EH", -1]];
            GVAR(activeTool) = _name;
        };

        // Next frame: the rebuild deletes this very button, so it is deferred
        // out of its own handler rather than pulled out from under it.
        {["tools"] call EFUNC(tacpad,rebuild)} call CBA_fnc_execNextFrame;
    }] call EFUNC(tacpad,drawHit);
    _hit setVariable [QGVAR(toolFnc), _fnc];
    _hit setVariable [QGVAR(toolOwn), _own];
} forEach _tools;

[_id, 0, (_rows * (_cellH + _padY) + 2 * _padY) / safeZoneH] call EFUNC(tacpad,fit);
