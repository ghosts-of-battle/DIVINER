#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_tabletInRange

Description:
    Is the selected device still close enough to work on? One test for all three
    kinds - each carries its own range in the session, so a tower and a soldier
    are checked against their own numbers.

Parameters:
    _device  : OBJECT  - the target.
    _session : HASHMAP - the tablet session.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_device", "_session"];

if (isNull _device || {!alive _device}) exitWith { false };

// A SESSION WITHOUT A RANGE IS NOT OUT OF RANGE. `get` answered nil for a
// session that had never had a device picked on it, and `distance <= nil` is
// false - so the hack ran with the progress permanently refused and nothing on
// screen said why. The tower range is the honest default.
private _range = _session getOrDefault ["range", 0];
if (!(_range isEqualType 0)) then {_range = 0};
if (_range <= 0) then {
    _range = [QGVAR(cfg_hack_range)] call FUNC(hackSetting);
};

(player distance _device) <= _range
