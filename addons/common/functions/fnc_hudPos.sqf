#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_hudPos

Description:
    Where a HUD overlay should draw itself. Reads the player's saved position for
    this HUD and clamps it into the current safe zone - a position saved on an
    ultrawide monitor must not put the panel off the edge of a 16:9 one.

Parameters:
    _id      : STRING - HUD identifier, e.g. "hackStrip".
    _default : ARRAY  - [x, y] in safezone fractions to use when unset.
    _size    : ARRAY  - [w, h] in safezone fractions, for the clamp. Optional.

Returns:
    ARRAY - [x, y] in screen coordinates, ready for ctrlSetPosition.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_id", "", [""]], ["_default", [0.4, 0.9], [[]]], ["_size", [0.2, 0.06], [[]]]];

private _fr = profileNamespace getVariable [format [QGVAR(hud_%1), _id], _default];
if (!(_fr isEqualType []) || {count _fr < 2}) then { _fr = _default };

_fr params ["_fx", "_fy"];
_size params ["_fw", "_fh"];

_fx = 0 max (_fx min (1 - _fw));
_fy = 0 max (_fy min (1 - _fh));

[safeZoneX + _fx * safeZoneW, safeZoneY + _fy * safeZoneH]
