#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_repair_fnc_tick

Description:
    One pass over the module's charges. Servicing what is standing, and rebuilding
    what is not if the module is allowed to.

    Two clocks, not one. Servicing runs on the module's interval; the respawn
    delay is counted from the moment a thing actually died. Sharing one clock
    would make the delay anything between zero and a full interval depending on
    where in the cycle the object happened to be destroyed, which is not a
    setting anybody could reason about.

Parameters (CBA PFH): 0: [logic], 1: handle

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_args", "_handle"];
_args params ["_logic"];

if (isNull _logic) exitWith { [_handle] call CBA_fnc_removePerFrameHandler };

private _cfg = _logic getVariable [QGVAR(cfg), nil];
if (isNil "_cfg") exitWith {};

private _records = _logic getVariable [QGVAR(records), []];
private _now = CBA_missionTime;

{
    _x params ["_obj", "_class", "_pos", "_dir", "_up", "_wasCrewed", "_diedAt", "_next"];

    // --- gone or destroyed ---------------------------------------------------
    if (isNull _obj || {!alive _obj}) then {
        if !(_cfg get "respawn") then { continue };

        // Stamp the time of death once, on the first pass that notices it.
        if (_diedAt < 0) then {
            _x set [6, _now];
            if (_cfg get "debug") then {
                diag_log text format ["[ghost_repair] %1 down, respawning in %2s",
                    _class, _cfg get "respawnDelay"];
            };
            continue;
        };

        if (_now - _diedAt < (_cfg get "respawnDelay")) then { continue };

        private _new = [_x, _cfg] call FUNC(respawnOne);
        if (!isNull _new) then {
            _x set [0, _new];
            _x set [6, -1];
            _x set [7, _now + (_cfg get "interval")];
        };
        continue;
    };

    // --- standing ------------------------------------------------------------
    if (_now < _next) then { continue };
    _x set [7, _now + (_cfg get "interval")];

    // Both commands take LOCAL arguments and a vehicle somebody is driving
    // is local to their client, not this server - said at the owner or the
    // pad silently neither rearmed nor refuelled in MP while the (global)
    // repair below kept working.
    if (_cfg get "rearm") then { [_obj, 1] remoteExec ["setVehicleAmmo", _obj] };
    if (_cfg get "refuel") then { [_obj, 1] remoteExec ["setFuel", _obj] };

    private _amount = _cfg get "amount";
    if (_amount > 0 && {damage _obj > 0}) then {
        _obj setDamage (0 max ((damage _obj) - _amount));
    };

    // A vehicle whose crew has been shot out is scenery. Off by default because
    // conjuring people into a truck surprises people; on, it is what keeps a
    // manned emplacement manned.
    if ((_cfg get "recrew") && _wasCrewed && {(crew _obj) findIf {alive _x} < 0}) then {
        { deleteVehicle _x } forEach (crew _obj);
        private _grp = createVehicleCrew _obj;
        if ((units _grp) isEqualTo []) then { deleteGroup _grp };
    };
} forEach _records;
