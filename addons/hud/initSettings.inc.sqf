// CBA Settings [ADDON: ghost_hud]
//
// DELIBERATELY SHORT. Where the two slots sit is the Layout editor's business -
// Options > Game > Layout, see gui.hpp - and what they are painted in is the
// tacpad's scheme. Neither belongs here.

[
    QGVAR(enabled), "CHECKBOX",
    ["Enable HUD", "Draws the two readout slots on the game screen. Off leaves the screen exactly as it was; the map suite is unaffected either way."],
    ["Ghosts of Battle", "HUD"],
    true,
    false,
    {[QGVAR(enabled_changed), []] call CBA_fnc_localEvent}
] call CBA_fnc_addSetting;

// A HUD IS FOR WHEN YOU CANNOT OPEN THE MAP. With the map open the same readings
// are on the tacpad in more detail, and two copies of the squad list on one
// screen is one too many.
[
    QGVAR(hideOnMap), "CHECKBOX",
    ["Hide with the map", "Takes the HUD off screen while the map is open, where the tacpad shows the same readings in more detail. Off leaves it up, over the map."],
    ["Ghosts of Battle", "HUD"],
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(opacity), "SLIDER",
    ["HUD opacity", "How solid the slot backgrounds are over the world. The text stays fully opaque at any setting."],
    ["Ghosts of Battle", "HUD"],
    [0, 1, 0.55, 2, true],
    false,
    {[QGVAR(enabled_changed), []] call CBA_fnc_localEvent}
] call CBA_fnc_addSetting;
