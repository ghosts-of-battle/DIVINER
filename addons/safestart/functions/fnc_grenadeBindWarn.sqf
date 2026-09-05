#include "script_component.hpp"
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

if (!(call FUNC(grenadeBindCondition))) exitWith { nil };

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
                profileNamespace setVariable [QGVAR(grenadeConfirmed), true];
                saveProfileNamespace;
            }
        ] call EFUNC(common,modal);
    }] call CBA_fnc_execNextFrame;
};

[{!isNull MISSION_DISPLAY}, {
    params ["_fnc_onClose"];
    // Both arms are now plain strings rather than stringtable lookups, so this
    // is a pick between two constants - select, not if/then/else.
    private _warnMessage = [
        "Hey!<br />You have bound 'Throw' (Grenade) key to G which is easy to press and is considered a 'Dangerous' bind.<br />It's recommended to bind it to 2xG.<br />Do you want to rebind the action?",
        "Hey!<br />You have bound 'Throw' (Grenade) key to G which is easy to press and is considered a 'Dangerous' bind.<br />It's recommended to unbind the key as you can use ACE Throwing (Shift+G) or bind it to 2xG.<br />Do you want to rebind the action?"
    ] select (EGVAR(common,aceThrowing));

    [
        "Dangerous bind detected!",
        _warnMessage,
        false,
        {},
        _this
    ] call EFUNC(common,modal);
}, _fnc_secondWarning] call CBA_fnc_waitUntilAndExecute;

nil
