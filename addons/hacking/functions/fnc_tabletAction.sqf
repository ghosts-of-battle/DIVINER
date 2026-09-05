#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_tabletAction

Description:
    START / ABORT. Starting validates the target the way the old ACE actions did
    - cooldowns for towers, range for everything - and refuses with a reason
    rather than silently doing nothing.

    Aborting throws the progress away deliberately. Closing the tablet is the way
    to pause; the button is the way to give up.

Author:
    Ghost
---------------------------------------------------------------------------- */
private _session = GVAR(session);

if (_session get "running") exitWith {
    private _device = _session get "device";
    _session set ["running", false];
    _session set ["progress", 0];
    if (!isNull _device) then { _device setVariable [QGVAR(progress), 0, true] };
    ["Hack", "Intrusion aborted.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
};

private _device = _session get "device";
if (isNull _device) exitWith {
    ["Hack", "No device selected.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
};

if !([_device, _session] call FUNC(tabletInRange)) exitWith {
    ["Hack", "Out of range of that device.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
};

private _kind = _session get "kind";

// NO GATE HERE. There was one - it refused to start when the product menu was
// empty, on the reasoning that a minute spent to be told "Nothing to report" is
// a minute wasted. It was the wrong trade: a button that refuses looks exactly
// like a button that is broken, and the bar sitting at 0% is indistinguishable
// from a hack that never ran. The hack runs; FUNC(serverPick) says honestly that
// there was nothing on the network.

// Towers hold a cooldown; -1 makes them one-shot.
if (_kind isEqualTo "tower") then {
    private _cd = [QGVAR(cfg_hack_cooldown)] call FUNC(hackSetting);
    private _last = _device getVariable [QGVAR(lastHack), -1e9];
    if (_cd < 0 && {_last > -1e8}) exitWith {
        ["Hack", "That tower is spent.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
    };
    if (_cd >= 0 && {(CBA_missionTime - _last) < _cd}) exitWith {
        ["Hack", format ["Tower cooling down - %1s.", round (_cd - (CBA_missionTime - _last))], [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
    };
};

// Each kind runs on its own clock.
private _time = switch (_kind) do {
    case "unit": { missionNamespace getVariable [QGVAR(rh_hack_time), RH_TIME_DEF] };
    case "drone": { HACK_DURATION };
    // A wreck has no security left to beat, only a card to copy.
    case "wreck": { HACK_WRECK_DURATION };
    default { [QGVAR(cfg_hack_time)] call FUNC(hackSetting) };
};

_session set ["time", _time max 1];

// A pop is public furniture - being seen starting on one has a price.
if (_device getVariable ["ghost_leaders_pop", false]) then {
    [player, _device] call FUNC(popWitness);
};
_session set ["last", CBA_missionTime];
_session set ["running", true];

