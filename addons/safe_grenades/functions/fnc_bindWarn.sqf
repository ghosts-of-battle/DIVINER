#include "..\script_component.hpp"
/*
 * Author: veteran29
 * Warns the player that he has default bind "G" to throw grenade.
 * It's considered good pratice to rebind it ;-)
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

#define CONFIRMED 1
#define DISCARDED 2
#define THROW_KEYBIND "STR_USRACT_THROW"

if (!(call FUNC(bindCondition))) exitWith { nil };

private _fnc_secondWarning = {
    params ["", "_confirm"];
    if (_confirm isEqualTo CONFIRMED) exitWith {
        // Open rebinding screen
        [{
            [THROW_KEYBIND] call FUNC(openKeybinding);
        }] call CBA_fnc_execNextFrame;
    };

    // Ask again
    [{
        [
            "Dangerous bind detected!",
            "Are you completly sure!? By confirming this you take full responsblity for all possible accidents.",
            false,
            {},
            {
                params ["", "_confirm"];
                if (_confirm isEqualTo CONFIRMED) exitWith {
                    // Open rebinding screen
                    [{
                        [THROW_KEYBIND] call FUNC(openKeybinding);
                    }] call CBA_fnc_execNextFrame;
                };

                // Do not ask again
                profileNamespace setVariable [QGVAR(bindConfirmed), true];
                saveProfileNamespace;
            }
        ] call EFUNC(common,modal);
    }] call CBA_fnc_execNextFrame;
};

[{!isNull (findDisplay 46)}, {
    params ["_fnc_onClose"];

    [
        "Dangerous bind detected!",
        "Hey!<br />You have bound 'Throw' (Grenade) key to G which is easy to press and is considered a 'Dangerous' bind.<br />It's recommended to unbind the key as you can use ACE Throwing (Shift+G) or bind it to 2xG.<br />Do you want to rebind the action?",
        false,
        {},
        _this
    ] call EFUNC(common,modal);
}, _fnc_secondWarning] call CBA_fnc_waitUntilAndExecute;

nil
