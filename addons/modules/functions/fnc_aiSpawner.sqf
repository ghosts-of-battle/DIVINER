#include "script_component.hpp"

params ["_side","_groupConfig", "_spawnPos", "_moveMarker", "_waves", "_con", "_huntTrigger", "_sadTrigger"];

private _group = [_spawnPos, _side, _groupConfig] call BIS_fnc_spawnGroup;
_group deleteGroupWhenEmpty true;


private _marker = _moveMarker select (floor random 2);
private _wp1 = _group addWaypoint [_marker, 0];
_wp1 setWaypointType "MOVE";

// The adopt-flag handshake survives the removed ALiVE integration: with no
// listener the flag stays false and the wave-watch runs normally. If a future
// integration adopts the wave, the wave-watch below must never run: it would read
// that deletion as a wipe and spawn the next wave immediately, forever. The
// respawn spec carries this function's own name and next-wave arguments, and
// the bridge runs it when the profiles actually die. Hunt/SAD behaviour is
// forfeit for an adopted wave - it is OPCOM's to command, which is the point.
private _adopt = [false];
private _next = if (_waves == -1 || _waves > 1) then {
    [QFUNC(aiSpawner), [_side, _groupConfig, _spawnPos, _moveMarker,
        [_waves - 1, -1] select (_waves == -1), _con, _huntTrigger, _sadTrigger]]
} else {[]};
[QEGVAR(common,groupSpawned), [_group, _next, _adopt]] call CBA_fnc_localEvent;
if (_adopt select 0) exitWith {};

// Compiled once, here, rather than inside the handler. The condition comes off
// a module attribute and never changes, so recompiling it every 15 s for the
// life of every wave buys nothing. The string is still carried in the args -
// the next wave is invoked with it.
private _conCode = compile _con;

[{
    (_this select 0) params ["_group", "_side","_groupConfig", "_spawnPos", "_moveMarker", "_waves", "_con", "_huntTrigger", "_sadTrigger", "_conCode"];
    //hint format ["%1 \n%2 \n%3 \n%4 \n%5", _group, _side, _groupType, _spawnMarker, _moveMarker];
    private _errorCode = -1;
    if (call _conCode) then{
        _errorCode = 1;
    }else{
        if (({alive _x} count units _group) == 0) then{
            deleteGroup _group;
            if (_waves == -1) then{
                _errorCode = 0;
            }else{
                if (_waves > 1)then{
                    _errorCode = 0;
                    _waves = _waves -1;
                }else{
                    _errorCode = 2;
                };
            };
        }else {
            private _marker = _moveMarker select (floor random 2);
            if (!isNull _sadTrigger && {(getPos leader _group) inArea _sadTrigger}) then {
                if !(isClass(configFile >> "CfgPatches" >> "Vcm_AIMod")) then {
                    while {(count (waypoints _group)) > 0} do{
                        deleteWaypoint ((waypoints _group) select 0);
                    };
                    private _wp1 = _group addWaypoint [_marker, 0];
                    _wp1 setWaypointType "SAD";
                };
            }else{
                while {(count (waypoints _group)) > 0} do{
                    deleteWaypoint ((waypoints _group) select 0);
                };
                private _wp1 = _group addWaypoint [_marker, 0];
                _wp1 setWaypointType "MOVE";
            };
        };
    };
    if (_errorCode != -1) then {
        //Error or Success, close dialog and remove PFEH
        [_this select 1] call CBA_fnc_removePerFrameHandler;

        if (_errorCode == 0) then{
            [_side, _groupConfig, _spawnPos, _moveMarker, _waves, _con, _huntTrigger, _sadTrigger] call FUNC(aiSpawner);
        };

        if (_errorCode == 1) then{
            //hint "ai spawner end";
            [_group, _huntTrigger] call FUNC(aiFollower);
        };
    };

},15 , [_group, _side, _groupConfig, _spawnPos, _moveMarker, _waves, _con, _huntTrigger, _sadTrigger, _conCode]] call CBA_fnc_addPerFrameHandler;
