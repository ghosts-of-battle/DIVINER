
[
    QGVAR(enabled),
    "CHECKBOX",
    ["Enable group markers", "Blue Force Tracking: every group that has its tracker on is drawn on the map for everyone who shares one of its networks."],
    ["Ghosts of Battle", "BFT"],
    true,
    1,
    {
        params ["_value"];
        if (_value) then {
            [] call FUNC(init);
        };
    }
] call CBA_fnc_addSetting;

[
    QGVAR(autoEnable),
    "LIST",
    ["Auto enable for", "None: nothing is tracked until switched on by hand. Player or All: groups nobody has configured are tracked automatically."],
    ["Ghosts of Battle", "BFT"],
    // The draw default follows this being non-None; see FUNC(draw) - the
    // distinction that made AI-only friendly groups invisible lives in
    // saved profiles, so the fix could not be a new default here.
    [[0, 1, 2], ["None", "Player", "All"], 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(memberMarkers),
    "LIST",
    ["Member markers", "Individual marks for the men inside tracked groups, coloured by fire team. Own squad: your group's members. All tracked: every same-side tracked group's members too."],
    ["Ghosts of Battle", "BFT"],
    [[0, 1, 2], ["Off", "Own squad", "All tracked"], 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(hideOwnGroup),
    "CHECKBOX",
    ["Hide own group marker", "Your own group's marker is not drawn on your map - it sits on top of you and hides the ground. Everyone else on the net still sees it, and your own men keep their member marks."],
    ["Ghosts of Battle", "BFT"],
    true,
    0
] call CBA_fnc_addSetting;

[
    QGVAR(updateDelay),
    "SLIDER",
    ["Update delay", "Delay between group marker updates."],
    ["Ghosts of Battle", "BFT"],
    [1, 60, 5, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(markerShape),
    "LIST",
    ["Marker shape", "Warning! Taking this off automatic will also affect enemy groups."],
    ["Ghosts of Battle", "BFT"],
    [["a", "b", "o", "n"], ["Automatic", "Blufor", "Opfor", "Independent"], 0],
    1
] call CBA_fnc_addSetting;

// Position
[
    QGVAR(trackingMode),
    "LIST",
    ["Position: tracking mode", "The way a group's position is calculated."],
    ["Ghosts of Battle", "BFT"],
    [["leader", "weightedAverage"], ["Leader", "Weighted average"], 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(trailingMode),
    "LIST",
    ["Position: trailing mode", "Lets a group's position trail behind its actual position."],
    ["Ghosts of Battle", "BFT"],
    [["none", "weightedAverage", "delayed"], ["None", "Weighted average", "Delayed"], 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(trailingCount),
    "SLIDER",
    ["Position: trailing count", "Amount of recent positions considered."],
    ["Ghosts of Battle", "BFT"],
    [1, 25, 5, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(trailingWeight),
    "SLIDER",
    ["Position: trailing weight", "Factor with which the weight decreases with per position."],
    ["Ghosts of Battle", "BFT"],
    [0, 1, 0.75, 2],
    1
] call CBA_fnc_addSetting;

// Map settings menu
[
    QGVAR(mapSettings),
    "CHECKBOX",
    ["Map settings menu", "Allows group leaders to change their own marker with ACE self interaction while the map is open."],
    ["Ghosts of Battle", "BFT"],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(nameOptions),
    "EDITBOX",
    ["Group name options", "Names available in the ACE BFT settings, separated by comma."],
    ["Ghosts of Battle", "BFT"],
    ["Zulu,Lima,Uniform,Echo,Whiskey,Tango"],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(preferredIcons),
    "EDITBOX",
    ["Preferred icons", "Icons offered first, before the Other icons submenu."],
    ["Ghosts of Battle", "BFT"],
    ["inf, motor_inf, mech_inf, air, armor, recon"],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(iconsBlacklist),
    "EDITBOX",
    ["Icons blacklist", "Icons a group leader may never pick."],
    ["Ghosts of Battle", "BFT"],
    ["unknown, uav"],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(preferredColors),
    "EDITBOX",
    ["Preferred colors", "Colors offered first, before the Other colors submenu."],
    ["Ghosts of Battle", "BFT"],
    ["ColorBLUFOR, ColorOPFOR, ColorIndependent, ColorCivilian, ColorUNKNOWN"],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(colorsBlacklist),
    "EDITBOX",
    ["Colors blacklist", "Colors a group leader may never pick."],
    ["Ghosts of Battle", "BFT"],
    ["Default, ColorWEST, ColorEAST, ColorGUER, ColorCIV, Color1_FD_F, Color2_FD_F, Color3_FD_F, Color4_FD_F, Color5_FD_F, Color6_FD_F"],
    1
] call CBA_fnc_addSetting;

// Crypto
[
    QGVAR(fuzzOtherSides),
    "CHECKBOX",
    ["Obfuscate other sides", "Groups of another side show as an unknown icon with their side's name and colour, rather than their own."],
    ["Ghosts of Battle", "BFT"],
    true,
    1
] call CBA_fnc_addSetting;

// Admin
[
    QGVAR(adminGodView),
    "CHECKBOX",
    ["Admin sees everything", "A logged-in admin draws every group: networks, tracker state and side obfuscation are all ignored for them. Admins can still switch it off for themselves with #ghost bft.view."],
    ["Ghosts of Battle", "BFT"],
    true,
    1
] call CBA_fnc_addSetting;
