#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function setup the staging system and automaticly creates respawn marker staging zones.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call ghostD_init_fnc_staging
 *
 * Public: No
 */

if !(EGVAR(Settings,enableStagingSystem)) exitWith {};

INFO("Staging","Setting up Staging");

private _stagingZoneMarkers = [];
{
    private _markerName = [_x, 0, 11] call BIS_fnc_trimString;
    _markerName = toLower _markerName;
    if (_markerName in ["zone_staging", "respawn_west", "YMF_staging_zone","TLZ"]) then {
        private _type = markerShape _x;
        private _pos = getMarkerPos _x;
        _x setMarkerAlpha 0;
        _stagingZoneMarkers append [[_x, _type, _pos]];
    };
} forEach allMapMarkers;

{
    _x params["_marker", "_type", "_pos"];
    private _size = [_type,60] select (_type == "ICON");
    private _zone = [_marker,_pos] select (_type == "ICON");
    [_zone, _size] call EFUNC(mission,addStagingZone);
} forEach _stagingZoneMarkers;


// Player specific actions
if !(GVAR(isPlayer)) exitWith {};

// Interaction system
private _condition1 = { call EFUNC(systems,checkStagingZone) };
private _condition2 = { isNull objectParent player && call EFUNC(systems,checkStagingZone) };
private _condition3 = { isNull objectParent player && {player getVariable ["ace_arsenal_virtualItems",[]] isNotEqualTo [] && call EFUNC(systems,checkStagingZone)} };

private _stagingCat = [
    QEGVAR(Actions,StagingCategory), 
    "Staging Zone", 
    "z\ghostD\addons\media\images\Icons\ghosticon.paa", 
    {true}, 
    _condition1
    ] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions"], _stagingCat] call ace_interact_menu_fnc_addActionToObject;

private _category = ["ACE_SelfActions", QEGVAR(Actions,StagingCategory)];

// addAction notice
player addAction [
    "<img image='z\ghostD\addons\media\images\Icons\ghosticon.paa' /> <t color='#ffc61a'>GOB Staging Zone</t> <img image='z\ghostD\addons\media\images\Icons\ghosticon.paa' />",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [
            "Staging Zone",
            "You are in a staging zone - change loadouts and so on from your ACE self interact.",
            NOTE_WARN
        ] call GHOSTFUNC(notify,notify);
        playSound "hint";
    }, nil, 10, false, false, "",
    QUOTE(call EFUNC(systems,checkStagingZone)),
    0
];

// Menu option
/* group ------------------------------------------------------------------------------------------------------------ */
if EGVAR(patches,usesACE) then {
    private _groupCategory = [
        "groupCategory",
        "Group Menu",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
        {[] call EFUNC(groups,initGroupMenu)},
        _condition2
    ] call ace_interact_menu_fnc_createAction;
    [player,1,_category,_groupCategory] call ace_interact_menu_fnc_addActionToObject;

/* heal ------------------------------------------------------------------------------------------------------------- */
    private _healCategory = [
        "healCategory",
        "Heal",
        "\z\ACE\addons\medical_gui\ui\cross.paa",
        {
            [_this select 0, player] call ace_medical_treatment_fnc_fullHeal;
            // [_this select 0, player] call ACM_core_fnc_resetVariables;
            // [_this select 0, player] call ACM_airway_fnc_resetVariables;
            // [_this select 0, player] call ACM_breathing_fnc_resetVariables;
            // [_this select 0, player] call ACM_circulation_fnc_resetVariables;
            // [_this select 0, player] call ACM_damage_fnc_resetVariables;
            // [_this select 0, player] call ACM_disability_fnc_resetVariables;
            ["Medical", "You have been healed.", NOTE_GOOD] call GHOSTFUNC(notify,notify);
        },
        _condition2
    ] call ace_interact_menu_fnc_createAction;
    [player,1,_category,_healCategory] call ace_interact_menu_fnc_addActionToObject;


/* arsenal ---------------------------------------------------------------------------------------------------------- */
    private _arsenalCategory = [
        "arsenalCategory",
        "Arsenal",
        "z\ghostD\addons\media\images\Icons\icon_arsenal_ca.paa",
        {[player,player,false] call ace_arsenal_fnc_openBox},
        _condition3
    ] call ace_interact_menu_fnc_createAction;
    [player,1,_category,_arsenalCategory] call ace_interact_menu_fnc_addActionToObject;

/* TP ---------------------------------------------------------------------------------------------------------- */

    private _tpCategory = [
        "TPCategory",
        "TP",
        "z\ghostD\addons\media\images\Icons\Teleport_Pos_64x64.paa",
        {[] call ghostD_teleport_fnc_open},
        _condition3
    ] call ace_interact_menu_fnc_createAction;
    [player,1,_category,_tpCategory] call ace_interact_menu_fnc_addActionToObject;
    };


INFO_1("Staging","Staging options for %1 have been setup.",name player)
