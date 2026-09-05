
if (EGVAR(common,aceSafemode)) then {
    [
        QGVAR(startLocked),
        "CHECKBOX",
        ["Lock weapon", "Locks your weapon safety on game start"],
        ["Ghosts of Battle", "Ghosts of Battle - safestart"],
        true,
        2
    ] call CBA_fnc_addSetting;
};
