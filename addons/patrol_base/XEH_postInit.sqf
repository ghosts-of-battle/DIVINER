#include "script_component.hpp"

// Player-facing "Establish Patrol Base" action + Zeus module registration.
if (hasInterface) then {
    [] call FUNC(initPlayer);
    [] call FUNC(addZeusModule);
};

// The Zeus kit drop lands here. Server side, because the objects have to be
// the server's - and on a channel the mission's CfgRemoteExec cannot close.
if (isServer) then {
    [QGVAR(dropKits), {
        params [["_pos", [], [[]]], ["_n", 0, [0]], ["_who", objNull, [objNull]]];
        private _made = [_pos, _n] call FUNC(spawnKits);
        diag_log text format ["[ghost_patrol_base] zeus drop: %1 of %2 kit(s) created at %3",
            count _made, _n, mapGridPosition _pos];
        if (!isNull _who) then {
            private _msg = if (_made isEqualTo []) then {
                "No kits could be placed there."
            } else {
                format ["%1 Patrol Base Kit(s) dropped.", count _made]
            };
            private _col = [[0.914, 0.651, 0.235, 1], [1, 0.3, 0.3, 1]] select (_made isEqualTo []);
            ["Patrol Base", _msg, _col] remoteExec [QEFUNC(notify,notify), _who];
        };
    }] call CBA_fnc_addEventHandler;
};
