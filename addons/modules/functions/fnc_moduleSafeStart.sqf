#include "script_component.hpp"

if (hasInterface && !isServer) exitWith {};

params [
    ["_logic",objNull,[objNull]],
    ["_units",[],[[]]],
    ["_activated", true]
];



if (_activated) then {
    private _area = _logic getVariable ["objectArea",[0,0,0,false,0]];
    private _spDisable = _logic getVariable ["spDisable", true];

    if ((_area param [0, 0]) == 0) exitWith {WARNING_1("Bad size? %1",_area);};

    /* format ["%1\n%2\n%3\n%4\n%5\n%6", _logic,_units,_activated,_area,_spDisable,(getPos _logic)] remoteExec ["hint", 0]; */
    /* hint str (allVariables _logic); */

    if (_spDisable and !(isMultiplayer))then{
    }else{
        // UNFINISHED, AND NOW IT SAYS SO. The trigger was created with an
        // area and an activation but NO statements, and nothing anywhere
        // read it - a placed module did exactly nothing, silently, in SP
        // and MP alike. Until the zone behaviour is specified, the honest
        // thing this module can do is warn the mission maker in the RPT
        // instead of pretending.
        WARNING("the Safe Start module is unfinished - it currently does nothing; the ghost_safestart addon's mission-start safety is separate and unaffected");
    };

};
