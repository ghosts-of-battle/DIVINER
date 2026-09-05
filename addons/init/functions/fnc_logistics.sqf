#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function initzializes the logistical database
 *
 * Return Value:
 * HashMap
 *
 * Example:
 * call ghostD_init_fnc_logistics
 *
 * Public: No
 */


INFO("Logistics","Creating logistical database");

// HANDED OVER BY THE MISSION, NOT READ OUT OF IT. config\loadConfigs.sqf runs
// in the mission at preInit and leaves the raw catalogue here. A PBO resolving
// paths inside a mission was wrong three different ways - see that file.
private _dataArray = missionNamespace getVariable ["ghostFR_missionConfig_logistics", []];

if (_dataArray isEqualTo []) exitWith {
    INFO("Logistics","This mission handed over no logistics catalogue - empty database.");
    createHashMap
};


private _return = createHashMapFromArray _dataArray;

if (!(_return isEqualType createHashMap)) exitWith {
    SHOW_CHAT_ERROR_1("LogisticsDatabase","Fatal error creating database (database base type faulty %1)...",typeName _return);
    createHashMapFromArray [["", []]];
};

_return;
