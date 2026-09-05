#include "script_component.hpp"
/*
 * Author: YonV
 * Sends whatever the window has been building.
 *
 * TWO SERVICES, ONE DOOR. Artillery fires each gun that can reach;
 * CAS hands Simplex a request hashmap and lets it fly the aircraft. Both go
 * through this function so there is one place to look when a mission does not
 * arrive, and both call Simplex by name because EFUNC does not cross mods.
 *
 * IT ASKS AGAIN BEFORE IT FIRES. canFire was answered when the target was
 * placed, which may have been a minute ago - a gun can have died, been moved,
 * or run its magazine dry since. The list is rebuilt here so what goes downrange
 * is what can actually shoot now, not what could when the man was deciding.
 *
 * ROUNDS ARE PER GUN, which is what the window says. Four rounds from a
 * four-gun battery is sixteen on the ground.
 *
 * THE CALL IS SIMPLEX'S, BY NAME. EFUNC does not reach across mods, and this is
 * deliberately the only place in the app that fires anything - one function to
 * look at when a mission does not arrive.
 *
 * Arguments:
 * 0: The dialog <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _entity = _display getVariable [QGVAR(entity), objNull];
private _target = _display getVariable [QGVAR(target), []];
private _rounds = _display getVariable [QGVAR(rounds), 4];

if (isNull _entity || {_target isEqualTo []}) exitWith {};

private _asl = ATLToASL _target;
private _service = toUpper (_display getVariable [QGVAR(service), ""]);
private _callsign = _entity getVariable ["sss_callsign", "SUPPORT"];

// --- CAS: the point is the whole request ------------------------------------
// Simplex dispatches on the entity's own supportType - a strafe run or a loiter
// station - so the request carries the position and nothing this window has any
// business deciding. Altitude, aim range, ingress and egress all have defaults
// there, and ADVANCED is where somebody who wants to set them goes.
if (_service isNotEqualTo "ARTILLERY") exitWith {
    if (isNil "sss_cas_fnc_request") exitWith {
        ["SUPPORT", "That service cannot be tasked from here.", "high"] call EFUNC(messaging,notify);
    };

    [ACE_player, _entity, createHashMapFromArray [["posASL", _asl]]] call sss_cas_fnc_request;

    ["SUPPORT", format ["%1 - tasked, %2.", _callsign, mapGridPosition _target], "normal"]
        call EFUNC(messaging,notify);

    INFO_2("CAS request: %1, %2",_callsign,mapGridPosition _target);
    _display closeDisplay 2;
};

// --- artillery: every gun that can still reach ------------------------------
private _fired = 0;

{
    if ([_x, _asl, "", false] call sss_artillery_fnc_canFire) then {
        if ([_x, _asl, "", _rounds] call sss_artillery_fnc_fire) then {
            _fired = _fired + 1;
        };
    };
} forEach ((_entity getVariable ["sss_vehicles", []]) select {alive _x});

if (_fired isEqualTo 0) exitWith {
    ["SUPPORT", format ["%1 cannot fire that mission.", _callsign], "high"] call EFUNC(messaging,notify);
};

// THE GRID IS IN THE MESSAGE, because a man who has just sent a mission is
// about to tell somebody else where it is going, and reading it off the
// notification is faster than reopening the window.
["SUPPORT", format [
    "%1 - shot, %2 rounds, %3.",
    _callsign, _fired * _rounds, mapGridPosition _target
], "normal"] call EFUNC(messaging,notify);

INFO_3("fire mission: %1, %2 guns, %3",_callsign,_fired,mapGridPosition _target);

_display closeDisplay 2;

nil
