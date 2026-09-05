
if (EGVAR(common,aceFinger)) then {
    private _aceKeybind = ["ACE3 Common", "ace_finger_finger"] call CBA_fnc_getKeybind select 5;
    private _keybind = [_aceKeybind, [41, [true, false, false]]] select isNil "_aceKeybind";

    [
        "Ghosts of Battle - Pointing",
        QGVAR(pointVehicle),
        ["Point direction (vehicle)", "Point direction to the rest of the current vehicle crew."],
        {
            if (!GVAR(vehicleEnabled)) exitWith {false};

            _this call FUNC(keyPressVehicle) // return
        },
        {},
        _keybind
    ] call CBA_fnc_addKeybind;

};
