// Make settings name
private _YMFsettings = "Ghosts of Battle";

[ // Mission Type
    QEGVAR(Settings,setMissionType),
    "LIST",
    ["Mission Type", "This will deside on what kind of startup hint you get on mission start."],
    [_YMFsettings, "Mission"],
    [[0,1,2,3], ["Custom", "Operation", "Training", "Public"], 1],
    true,
    {},
    true
] call CBA_fnc_addSetting;
// AI SKILL ADJUSTMENT, OFF BY DEFAULT (user, 2026-09-01).
//
// "Arma Default" means config\config_skill.hpp does nothing at all - no
// setSkill call is made and every AI keeps the skill its own config and the
// difficulty profile give it. The other two run the mission's skill block on
// every AI the mission ever creates, which on an ALiVE mission is a four-figure
// number of units per session.
//
// This is the only switch: nothing else in the mod or the mission writes AI
// skill, so index 0 here is the whole off state.
[ // Ai setting
    QEGVAR(Settings,setAiSystemDifficulty),
    "LIST",
    ["AI Setting", "Adjusts AI skill so they are less godlike. Arma Default leaves every AI's skill exactly as its own config sets it and runs no skill script at all."],
    [_YMFsettings, "Mission"],
    [[0,1,2], ["Arma Default", "Adjusted", "Faction Based"], 0],
    true,
    {},
    true
] call CBA_fnc_addSetting;

// Radios
[ // Enable
    QEGVAR(Settings,enableRadios),
    "CHECKBOX",
    ["Enable","Allow mission to set up and handle radio distributution"],
    [_YMFsettings, "Radios"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
// [ // Long Range Radio Channels
//     QEGVAR(Settings,LRsetRadioChannelNames),
//     "EDITBOX",
//     ["Long Range Radio Channels (ACRE)","Array of radio channels used for ACRE the index of the array translate to channel."],
//     [_YMFsettings, "Radios"],
//     '["COMMAND","OUTLAW","THUNDER","PHOENIX","RHINO","TRAINING","FIRES","CAS-1","CAS-2","AIR-1","AIR-2","GROUND-TO-AIR","CONVOY","AUX-1","AUX-2","ZEUS"]',
//     true,
//     {},
//     true
// ] call CBA_fnc_addSetting;
// [ // Platoon Radio Channels
//     QEGVAR(Settings,MRsetRadioChannelNames),
//     "EDITBOX",
//     ["Mid Range Radio Channels (ACRE)","Array of radio channels used for ACRE the index of the array translate to channel."],
//     [_YMFsettings, "Radios"],
//     '["OUTLAW-HQ","OUTLAW-1/1","OUTLAW-1/2","OUTLAW-1/3","MED-NET","ENG-NET","WHYAREUHERE"]',
//     true,
//     {},
//     true
// ] call CBA_fnc_addSetting;

[ // Squad Radio Channels
    QEGVAR(Settings,setRadio),
    "CHECKBOX",
    ["Squad Radio Channels (ACRE)","Allow radio channels to be changed based on player squadname."],
    [_YMFsettings, "Radios"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;

[ // Documents
    QEGVAR(Settings,showDiaryRecords),
    "CHECKBOX",
    ["Documents","Allow the mission to write diary help documents."],
    [_YMFsettings, "Player"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Rank
    QEGVAR(Settings,setPlayerRank),
    "CHECKBOX",
    ["Rank","Allow mission to apply arma rank based on name rank prefixes."],
    [_YMFsettings, "Player"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;

[ // Insignia
    QEGVAR(Settings,allowInsigniaApplication),
    "CHECKBOX",
    ["Insignia","Automaticly apply insignias based on squad name."],
    [_YMFsettings, "Player"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Apply Earplugs
    QEGVAR(Settings,addEarplugs),
    "CHECKBOX",
    ["Apply Earplugs","Automaticly apply earplugs to players on spawn and respawn."],
    [_YMFsettings, "Player"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;


[ // Enable
    QEGVAR(Settings,enableStagingSystem),
    "CHECKBOX",
    ["Enable","Enables the staging system."],
    [_YMFsettings, "Staging"],
    true,
    true,
    {},
    false
] call CBA_fnc_addSetting;
[ // Enable
    QEGVAR(Settings,enableVehicleSystem),
    "CHECKBOX",
    ["Enable", "Enables scripted settings and functions to apply to vehicles."],
    [_YMFsettings, "Vehicle"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Pylon
    QEGVAR(Settings,enableVehiclePylon),
    "CHECKBOX",
    ["Pylon", "Enables scripted loadouts or pylon to be applied to vehicles based on faction"],
    [_YMFsettings, "Vehicle"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Loadouts
    QEGVAR(Settings,enableVehicleInventory),
    "CHECKBOX",
    ["Inventory", "Enables scripted inventory to be applied to vehicles based on faction"],
    [_YMFsettings, "Vehicle"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Radio
    QEGVAR(Settings,enableVehicleRadios),
    "CHECKBOX",
    ["Radio", "Enables vehicles radio to be enabled and set on vehicles"],
    [_YMFsettings, "Vehicle"],
    false,
    true,
    {},
    true
] call CBA_fnc_addSetting;

[ // Factions
    QEGVAR(Settings,vehicleFactions),
    "EDITBOX",
    ["Factions","Array of factions allowing system loadout and pylon changes"],
    [_YMFsettings, "Vehicle"],
    '["BLU_CTRG_F","BLU_W_F","BLU_T_F","BLU_NATO_lxWS","BLU_F","USAF","tweed_UA_21","ghost_EUDF","ghost_EUDF_arc","ghost_EUDF_des","ghost_EUDF_tna","ghost_EUDF_wdl","ghost_GEN","ghost_HIMF","ghost_Marine_des","ghost_Marine_wdl","ghost_MFRC_mtp","ghost_MFRC_ocp","ghost_MFRC_tna","ghost_MFRC_wdl","ghost_US_JTF_des","ghost_US_JTF_ocp","ghost_US_JTF_tna","ghost_US_JTF_wdl"]',
    true,
    {},
    true
] call CBA_fnc_addSetting;


// 7; Combat Jump Simulation
[ // Simulation Type
    QEGVAR(Settings,jumpSimulation),
    "LIST",
    ["Simulation Type","Combat jump simulation is a system that checks for lose equiped gear in the form of;\nnight vision googles, hats or glasses and make you lose the on a combat jump.\n    None: No simulation is done.\n    Basic: Lose gear unassigned.\n    Advanced: Lose gear is removed."],
    [_YMFsettings, "Combat Jump Simulation"],
    [[0,1,2], ["None", "Basic", "Advanced"], 2],
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Include Night Vision Googles
    QEGVAR(Settings,jumpSimulationNVG),
    "CHECKBOX",
    ["Include Night Vision Googles","Include equiped Night Vison Googles in the simulation."],
    [_YMFsettings, "Combat Jump Simulation"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Include Non-combat Googles
    QEGVAR(Settings,jumpSimulationGlasses),
    "CHECKBOX",
    ["Include Non-combat Googles","Include Non-combat Googles in the simulation. This refere to sunshades and simular non-safety googles."],
    [_YMFsettings, "Combat Jump Simulation"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Include Non-combat Headgear
    QEGVAR(Settings,jumpSimulationHat),
    "CHECKBOX",
    ["Include Non-combat Headgear","Include Non-combat Headgear in the simulation. This refere to hats bandanas and baretes."],
    [_YMFsettings, "Combat Jump Simulation"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
