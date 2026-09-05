#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_jamHud

Description:
    Shows the jamming meter while the player is in a field, hides it when clear.
    Reads the four figures the jam loop already published - the meter never
    evaluates jamming a second time, so it cannot disagree with what the radios,
    the handset and the map are actually doing.

    ONE ROW PER DOMAIN (user, 2026-08-31): RADIO, DATA, GPS. A single bar
    stopped meaning anything the moment the terminal could take the net without
    touching TAC//MSG - a player read 60% and could not tell what they had lost.
    All three rows are drawn whenever the meter is up, dim and empty for a
    domain that is clear, so the answer to "what still works" is one glance
    rather than three experiments.

    ON THE MISSION DISPLAY, NOT A TITLE LAYER. The first shape of this cut an
    RscTitles resource that was never defined, so every pass inside a jam field
    was a "Resource title ghost_jamming_jamHud not found" warning two seconds
    apart, and no meter. The honest fix was not to add the missing class: a
    title layer survives the mission that raised it, which is the main-menu bug
    the HUD and the scanner were both rebuilt to end - addons/hud/gui.hpp tells
    it in full. Display 46 is created with the mission and destroyed with it,
    so the meter cannot outlive the world it is reporting on. No display yet
    means the mission is still coming up, and the two-second beat retries.

    THE LABEL SPEAKS THE HUD TILE'S OWN BAND WORDS - DEGRADED, and SMOTHERED
    from 75% - so the meter and the tile can never call the same sky two
    different things.

Parameters (CBA PFH): 0: args, 1: handle

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!hasInterface) exitWith {};

private _display = findDisplay 46;
if (isNull _display) exitWith {};

// The rows, in the order they are drawn. DOM_ANY is what decides whether the
// meter is up at all - it is the max of the three, published by the loop.
private _rows = [
    ["RADIO", missionNamespace getVariable [QGVAR(localJamFactor), 0]],
    ["DATA",  missionNamespace getVariable [QGVAR(localJamData), 0]],
    ["GPS",   missionNamespace getVariable [QGVAR(localJamGps), 0]]
];
private _any = missionNamespace getVariable [QGVAR(localJamAny), 0];
private _panel = _display displayCtrl IDC_JAM_PANEL;

if (_any <= 0 || {!GVAR(jamHudEnabled)}) exitWith {
    if (!isNull _panel) then {
        {
            ctrlDelete (_display displayCtrl (IDC_JAM_LABEL0 + _forEachIndex));
            ctrlDelete (_display displayCtrl (IDC_JAM_BAR0 + _forEachIndex));
        } forEach _rows;
        ctrlDelete _panel;
    };
};

if (isNull _panel) then {
    // _px/_py, not _x/_y: the row loop below binds _x to the row array, and the
    // corner would have been read as an array the moment it did.
    ([JAM_HUD_ID, [JAM_HUD_DEF_X, JAM_HUD_DEF_Y], [JAM_HUD_W, JAM_HUD_H]] call EFUNC(common,hudPos)) params ["_px", "_py"];
    private _w = JAM_HUD_W * safeZoneW;
    private _h = JAM_HUD_H * safeZoneH;
    private _rowH = _h / (count _rows);

    private _ctrl = _display ctrlCreate [QGVAR(jamPanel), IDC_JAM_PANEL];
    _ctrl ctrlSetPosition [_px, _py, _w, _h];
    _ctrl ctrlCommit 0;

    {
        private _top = _py + _rowH * _forEachIndex;

        // The name sits left and keeps a fixed column, so the three bars line
        // up under each other and the block reads as one instrument.
        _ctrl = _display ctrlCreate [QGVAR(jamLabel), IDC_JAM_LABEL0 + _forEachIndex];
        _ctrl ctrlSetPosition [_px + _w * 0.04, _top, _w * 0.34, _rowH * 0.9];
        _ctrl ctrlCommit 0;

        _ctrl = _display ctrlCreate [QGVAR(jamBar), IDC_JAM_BAR0 + _forEachIndex];
        _ctrl ctrlSetPosition [_px + _w * 0.40, _top + _rowH * 0.32, _w * 0.56, _rowH * 0.3];
        _ctrl ctrlCommit 0;
    } forEach _rows;
};

// THE BAND WORDS ARE THE HUD TILE'S, unchanged - DEGRADED, and SMOTHERED from
// 75%, which is also where messaging calls the data link DENIED. A clear row
// says OK in the dim colour rather than going blank: an empty row would read as
// a broken meter, and "GPS OK" while the net is smothered is the single most
// useful thing this instrument can tell anyone.
{
    _x params ["_name", "_f"];

    private _label = _display displayCtrl (IDC_JAM_LABEL0 + _forEachIndex);
    private _bar = _display displayCtrl (IDC_JAM_BAR0 + _forEachIndex);

    switch (true) do {
        case (_f >= JAM_DENIED_BAND): {
            _label ctrlSetText format ["%1 NONET", _name];
            _label ctrlSetTextColor JAM_COL_OUT;
        };
        case (_f > 0): {
            _label ctrlSetText format ["%1 DEG", _name];
            _label ctrlSetTextColor JAM_COL_DEG;
        };
        default {
            _label ctrlSetText format ["%1 OK", _name];
            _label ctrlSetTextColor JAM_COL_OK;
        };
    };

    _bar progressSetPosition _f;
} forEach _rows;
