#include "script_component.hpp"


params ["_side","_groupType", "_spawnPos", "_waves", "_huntTrigger"];

private _group = [_spawnPos, _side, _groupType] call BIS_fnc_spawnGroup;
_group deleteGroupWhenEmpty true;


// The adoption offer, exactly as FUNC(aiSpawner) makes it: adopted waves are
// adopted by an external population system and this wave-watch must
// stand down - the bridge re-invokes with the next wave's arguments when the
// profiles die. The hunt trigger is forfeit for an adopted wave.
private _adopt = [false];
private _next = if (_waves == -1 || _waves > 1) then {
    [QFUNC(aiHunter), [_side, _groupType, _spawnPos,
        [_waves - 1, -1] select (_waves == -1), _huntTrigger]]
} else {[]};
[QEGVAR(common,groupSpawned), [_group, _next, _adopt]] call CBA_fnc_localEvent;
if (_adopt select 0) exitWith {};


[{
    (_this select 0) params ["_group", "_side","_groupType", "_spawnPos", "_waves", "_huntTrigger"];

    //hint format ["%1 \n%2 \n%3 \n%4 \n%5", _group, _side, _groupType, _spawnMarker, _moveMarker];
    private _errorCode = -1;

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
        private _huntTargets = allPlayers inAreaArray _huntTrigger;
        if (_huntTargets isNotEqualTo []) then {
            while {(count (waypoints _group)) > 0} do{
                deleteWaypoint ((waypoints _group) select 0);
            };

            private _wp1 = _group addWaypoint [getPos (_huntTargets select 0), 0];
            _wp1 setWaypointType "SAD";
        };
    };

    if (_errorCode != -1) then {

        //Error or Success, close dialog and remove PFEH
        [_this select 1] call CBA_fnc_removePerFrameHandler;

        if (_errorCode == 0) then{
            [_side, _groupType, _spawnPos, _waves, _huntTrigger] call FUNC(aiHunter);
        };

    };

},15 , [_group, _side, _groupType, _spawnPos, _waves, _huntTrigger]] call CBA_fnc_addPerFrameHandler;
