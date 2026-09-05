[
    QGVAR(enableAddon),
    "CHECKBOX",
    ["Enable Back To Game", "Activate teleport and loadout restore after reconnect."],
    ["Ghosts of Battle", "Ghosts of Battle - Back To Game"],
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(teleportToLeader),
    "CHECKBOX",
    ["Teleport to leader", "Allow player teleportation to his group leader."],
    ["Ghosts of Battle", "Ghosts of Battle - Back To Game"],
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(teleportToVehicle),
    "CHECKBOX",
    ["Teleport to vehicle", "Allow player teleportation to his last vehicle or group leader vehicle."],
    ["Ghosts of Battle", "Ghosts of Battle - Back To Game"],
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(removeBody),
    "CHECKBOX",
    ["Remove body", "Removes bodies of alive people who disconnected."],
    ["Ghosts of Battle", "Ghosts of Battle - Back To Game"],
    true,
    true
] call CBA_fnc_addSetting;
