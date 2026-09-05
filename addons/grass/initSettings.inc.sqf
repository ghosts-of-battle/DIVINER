[
    QGVAR(enabled),
    "CHECKBOX",
    ["Force Grass", "Forces grass for all players"],
    ["Ghosts of Battle", "Ghosts of Battle - Grass"],
    false,
    1,
    {[_this] call FUNC(toggle)}
] call CBA_fnc_addSetting;
