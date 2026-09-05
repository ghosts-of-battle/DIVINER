#include "script_component.hpp"
/*
 * Author: BaerMitUmlaut, CPL.Brostrom.A
 * This function runs on postInit unsceduled via made sure by postInitProxy
 *
 * Arguments:
 * none
 *
 * Return Value:
 * nothing
 *
 * Example:
 * call ghostD_gear_fnc_postInit
 *
 */
// Server programs the ACRE preset and raises the flag that gates vehicle-rack setup
// (fn_vehicle_addRadio waits on GVAR(Radio)). Each client programs its own local preset
// in fn_init_playerpost - ACRE presets are per-machine.
if (isServer) then {
    GVAR(Radio) = false;
    call EFUNC(gear,setupRadios);
    GVAR(Radio) = true;
};


if (hasInterface) then {
    ["ace_arsenal_displayClosed", {
        [player, 'BIS'] call EFUNC(players,setRank);
        call (missionNamespace getVariable ["ghost_w28fixes_fnc_player_set_name", {}]);
        player linkItem "ItemCompass";
        if ("B_UavTerminal" in (player getSlotItemName 612)) then { 
            if !([player, "ItemAndroidMisc"] call ace_common_fnc_hasItem)  
                then {player addItem "ItemAndroidMisc"}; 
            } else { 
                if !([player, "ItemAndroid"] call ace_common_fnc_hasItem) then {player linkItem "ItemAndroid"}; 
        };
        player call EFUNC(gear,saveLoadout);
    }] call CBA_fnc_addEventHandler;
};
