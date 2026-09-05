#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV tinkered with by YonV
 * This function run a para jump simulation on a given player. 
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["bob"] call ghostD_systems_fnc_para_equipment
 *
 * Public: No
 */

params [
    ["_player", player], 
    ["_KeepNVG", false, [false]]
];

private _blacklist_headgear = ["H_Bandanna_gry","H_Bandanna_blu","H_Bandanna_cbr","H_Bandanna_khk_hs","H_Bandanna_khk","H_Bandanna_mcamo","H_Bandanna_sgg","H_Bandanna_sand","H_Bandanna_surfer","H_Bandanna_surfer_blk","H_Bandanna_surfer_grn","H_Bandanna_camo","H_Watchcap_blk","H_Watchcap_cbr","H_Watchcap_camo","H_Watchcap_khk","DAR_Beret_Blk","DAR_Beret_Mar","H_Beret_blk","H_Beret_gen_F","H_Beret_02","H_Beret_Colonel","H_Booniehat_khk_hs","H_Booniehat_khk","H_Booniehat_mcamo","H_Booniehat_oli","H_Booniehat_tan","H_Booniehat_tna_F","H_Booniehat_dgtl","H_Cap_grn_BI","H_Cap_blk","H_Cap_Black_IDAP_F","H_Cap_blu","H_Cap_blk_CMMG","H_Cap_grn","H_Cap_blk_ION","H_Cap_oli","H_Cap_oli_hs","H_Cap_Orange_IDAP_F","H_Cap_police","H_Cap_press","H_Cap_red","H_Cap_surfer","H_Cap_tan","H_Cap_khaki_specops_UK","H_Cap_usblack","H_Cap_tan_specops_US","H_Cap_White_IDAP_F","H_Cap_blk_Raven","H_Cap_brn_SPECOPS","DAR_Stetson","H_Hat_blue","H_Hat_brown","H_Hat_camo","H_Hat_checker","H_Hat_grey","H_Hat_tan","DAR_JMCap_Blk","H_MilCap_blue","H_MilCap_gen_F","H_MilCap_ghex_F","H_MilCap_gry","H_MilCap_ocamo","H_MilCap_mcamo","H_MilCap_tna_F","H_MilCap_dgtl","H_Hat_Safari_olive_F","H_Hat_Safari_sand_F","H_Shemag_olive","H_Shemag_olive_hs","H_ShemagOpen_tan","H_ShemagOpen_khk","H_StrawHat","H_StrawHat_dark","tf47_beret"];
private _blacklist_glasses = ["G_Aviator","G_Spectacles","G_Sport_Red","G_Sport_Blackyellow","G_Sport_BlackWhite","G_Sport_Checkered","G_Sport_Blackred","G_Sport_Greenblack","G_Squares_Tinted","G_Squares","G_Spectacles_Tinted"];

private _nvgRandom = random [1, 4, 10];
private _hatRandom = random [1, 4, 10];
private _glaRandom = random [1, 4, 10];

switch (EGVAR(Settings,jumpSimulation)) do {
    case (1): { // Basic

        if (!_KeepNVG && EGVAR(Settings,jumpSimulationNVG) && ((hmd _player != "") && (_nvgRandom > 4))) then {
            private _baseHmd = hmd _player;
            _player unassignItem _baseHmd;
            [
                "Jump Simulation",
                format ["You almost lost your %1 during the jump - it is in your inventory.", getText (configFile >> "CfgWeapons" >> _baseHmd >> "displayName")],
                NOTE_WARN
            ] call GHOSTFUNC(notify,notify);

            INFO_2("JumpSimulation","Jump simulation %1 lost NVG (%2>4)",_player,_nvgRandom);
        };

        if (EGVAR(Settings,jumpSimulationHat) && ((headgear _player in _blacklist_headgear) && (_hatRandom > 3))) then {
            private _baseHeadgear = headgear _player;
            _player unassignItem _baseHeadgear;
            [
                "Jump Simulation",
                format ["You almost lost your %1 during the jump - it is in your inventory.", getText (configFile >> "CfgWeapons" >> _baseHeadgear >> "displayName")],
                NOTE_WARN
            ] call GHOSTFUNC(notify,notify);

            INFO_2("JumpSimulation","Jump simulation %1 lost Hat (%2>3)",_player,_hatRandom);
        };

        if (EGVAR(Settings,jumpSimulationGlasses) && ((goggles _player in _blacklist_glasses) && (_glaRandom > 2))) then {
            private _baseGoggles = goggles _player;
            _player unassignItem _baseGoggles;
            [
                "Jump Simulation",
                format ["You almost lost your %1 during the jump - it is in your inventory.", getText (configFile >> "CfgGlasses" >> _baseGoggles >> "displayName")],
                NOTE_WARN
            ] call GHOSTFUNC(notify,notify);
            
            INFO_2("JumpSimulation","Jump simulation %1 lost Glasses (%2>2)",_player,_glaRandom);
        };
    };
    case (2): { // Advanced

        if (!_KeepNVG && EGVAR(Settings,jumpSimulationNVG) && ((hmd _player != "") && (_nvgRandom > 4))) then {
            private _advHmd = hmd _player;
            _player unlinkItem _advHmd;
            [
                "Jump Simulation",
                format ["You lost your %1 during the jump.", getText (configFile >> "CfgWeapons" >> _advHmd >> "displayName")],
                NOTE_BAD
            ] call GHOSTFUNC(notify,notify);
            
            INFO_2("JumpSimulation","Jump simulation %1 lost Glasses (%2>4)",_player,_nvgRandom);
        };

        if (EGVAR(Settings,jumpSimulationHat) && ((headgear _player in _blacklist_headgear) && (_hatRandom > 3))) then {
            private _advHeadgear = headgear _player;
            _player unlinkItem _advHeadgear;
            [
                "Jump Simulation",
                format ["You lost your %1 during the jump.", getText (configFile >> "CfgWeapons" >> _advHeadgear >> "displayName")],
                NOTE_BAD
            ] call GHOSTFUNC(notify,notify);
            
            INFO_2("JumpSimulation","Jump simulation %1 lost Glasses (%2>3)",_player,_hatRandom);
        };

        if (EGVAR(Settings,jumpSimulationGlasses) && ((goggles _player in _blacklist_glasses) && (_glaRandom > 2))) then {
            private _advGoggles = goggles _player;
            _player unlinkItem _advGoggles;
            [
                "Jump Simulation",
                format ["You lost your %1 during the jump.", getText (configFile >> "CfgGlasses" >> _advGoggles >> "displayName")],
                NOTE_BAD
            ] call GHOSTFUNC(notify,notify);
            
            INFO_2("JumpSimulation","Jump simulation %1 lost Glasses (%2>2)",_player,_glaRandom);
        };
    };
    default {};
};
