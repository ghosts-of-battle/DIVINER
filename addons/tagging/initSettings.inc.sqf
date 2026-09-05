
if (EGVAR(common,aceTagging)) then {
    [
        QGVAR(enabled),
        "CHECKBOX",
        ["Enable ACE Tagging markers", "Automatically create markers on buildings sprayed with ACE Spray."],
        ["Ghosts of Battle", "Ghosts of Battle - Tagging"],
        false,
        true
    ] call CBA_fnc_addSetting;
};
