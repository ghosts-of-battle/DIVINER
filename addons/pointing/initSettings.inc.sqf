
if (EGVAR(common,aceFinger)) then {
    [
        QGVAR(vehicleEnabled),
        "CHECKBOX",
        ["Enable pointing in vehicles", "Allows to point current camera direction in vehicles to rest of the crew."],
        ["Ghosts of Battle", "Ghosts of Battle - Pointing"],
        true,
        true
    ] call CBA_fnc_addSetting;
};
