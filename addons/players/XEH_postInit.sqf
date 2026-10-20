#include "script_component.hpp"

// BASE-GAME VOICE (VON), 2026-10-20. Only when neither TFAR nor ACRE is loaded -
// EGVAR(common,von), decided once at preInit. With either radio mod this file
// does nothing and every radio path in the mod is as it was.
if (!EGVAR(common,von)) exitWith {};

if (isServer) then {
    // the clients ask for a reconcile at spawn, respawn, squad change and JIP
    [QGVAR(vonSync), {[] call FUNC(vonSync)}] call CBA_fnc_addEventHandler;
    // a man who leaves comes off his nets once the engine has let go of him
    addMissionEventHandler ["PlayerDisconnected", {
        [{[] call FUNC(vonSync)}, [], VON_LEAVE_DELAY] call CBA_fnc_waitAndExecute;
    }];

    GVAR(vonReady) = true;
    [] call FUNC(vonApply);

    // and a slow sweep, for what nobody raises - a squad leader changing hands
    [{[] call FUNC(vonSync)}, VON_SYNC_INTERVAL] call CBA_fnc_addPerFrameHandler;
};

if (hasInterface) then {
    [{[] call FUNC(vonClient)}, VON_CLIENT_INTERVAL] call CBA_fnc_addPerFrameHandler;
};
