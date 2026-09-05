// CBA Settings [ADDON: ghost_uas]

// WHAT IS LEFT AFTER THE MODULE TOOK ITS SHARE. One module is one patrol and
// carries its own side, airframe, count and artillery - so what remains here is
// only the supply economy, which is genuinely map-wide: caches belong to a side
// rather than to a patrol, and an outage thins every patrol that side has.
//
// ghost_moduleUAS's ceilings and per-side airframe fields are gone entirely. A
// patrol's size is the number on its own module now, which is the question
// "how many drones over THIS ground" rather than "how many does this side own".
//
// ALL SERVER-SIDE.

[
    QGVAR(windowMin), "SLIDER",
    ["Outage minimum (s)", "Shortest time a destroyed cache holds the ceiling down. Outages extend rather than stack, so supply raids are raids and not a win button."],
    ["Ghosts of Battle", "Drones"],
    [60, 3600, 600, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(windowMax), "SLIDER",
    ["Outage maximum (s)", "Longest time a destroyed cache holds the ceiling down."],
    ["Ghosts of Battle", "Drones"],
    [60, 7200, 1800, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(cachesPerSide), "SLIDER",
    ["Supply caches per side", "Unmarked crates placed inside that side's patrol zones, split across them. Finding them is what the intel economy is for; killing one drops the ceiling."],
    ["Ghosts of Battle", "Drones"],
    [0, 12, 3, 0],
    true
] call CBA_fnc_addSetting;

// WHICH AIRFRAME EACH SIDE FLIES. A faction name, resolved by FUNC(factionUav) -
// empty scans for a UAV belonging to that side and falls back to the vanilla
// one. It was a module field per side and is the same thing here, minus the
// module.

// WHAT A SWARM MAY BE MADE OF. The Ghost - Drone Swarm module's picker offers
// every UAV the game has, because an Eden attribute is read from config and
// cannot know about a CBA setting; this is the list that actually gets fielded,
// and a module naming anything outside it is refused when it is placed.
//
// Empty means no restriction - whatever was picked flies. That is the right
// default for a mission maker on their own machine and the wrong one for a
// unit that has decided which drones exist in its world, which is why the
// setting is here at all.
[
    QGVAR(swarmClasses), "EDITBOX",
    ["Swarm airframes", "Comma-separated UAV classes a Drone Swarm module may field. Empty allows any. A module naming a class outside this list refuses to launch and says so when it is placed."],
    ["Ghosts of Battle", "Drones"],
    "O_UAV_01_F,B_UAV_01_F,I_UAV_01_F",
    true
] call CBA_fnc_addSetting;
