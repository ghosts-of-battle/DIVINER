// THE JAMMING METER'S THREE CONTROLS, AS ROOT-LEVEL CLASSES FOR ctrlCreate.
//
// THE RESOURCE THIS REPLACES NEVER EXISTED. FUNC(jamHud) raised
// "ghostD_jamming_jamHud" with cutRsc from the day it was written, and no
// RscTitles class of that name was ever in the config - so every pass inside a
// jam field was a "Resource title ... not found" warning in the RPT, two
// seconds apart, and no meter. Building the missing title layer was the
// obvious repair and the wrong one: a cutRsc layer survives the mission that
// raised it, which is how the hacking scanner sat over the main menu for eight
// builds - addons/hud/gui.hpp tells that story in full. The meter's controls
// are created on the MISSION DISPLAY (findDisplay 46) instead, which the
// engine destroys with the mission.
//
// NO POSITIONS IN HERE. FUNC(jamHud) places everything off
// EFUNC(common,hudPos) each time it builds the meter - the same bespoke store
// the hacking strip still uses.

class RscText;
class RscProgress;

class GVAR(jamPanel): RscText {
    idc = IDC_JAM_PANEL;
    colorBackground[] = {0, 0, 0, 0.55};
    x = "safeZoneX"; y = "safeZoneY"; w = 0; h = 0;
};

class GVAR(jamLabel): RscText {
    idc = IDC_JAM_LABEL;
    font = "RobotoCondensed";
    colorText[] = {0.933, 0.910, 0.863, 1};
    sizeEx = "0.8 * (pixelH * pixelGrid)";
    shadow = 1;
    x = "safeZoneX"; y = "safeZoneY"; w = 0; h = 0;
};

// Amber, because the meter only exists while something is wrong - the same
// band colour the HUD's jamming tile turns when the spectrum is partly sat on.
// The texture is a flat procedural white so the colour is the colour, rather
// than the vanilla bar art showing through it.
class GVAR(jamBar): RscProgress {
    idc = IDC_JAM_BAR;
    colorFrame[] = {0, 0, 0, 0};
    colorBar[] = {0.914, 0.651, 0.235, 1};
    texture = "#(argb,8,8,3)color(1,1,1,1)";
    x = "safeZoneX"; y = "safeZoneY"; w = 0; h = 0;
};
