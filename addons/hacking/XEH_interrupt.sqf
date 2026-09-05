#include "script_component.hpp"

// CLEARED FROM INSIDE THE MISSION, WHICH IS THE ONLY PLACE IT WORKS.
//
// Clearing the layer once the menu is up does nothing - proven three
// builds running: the teardown ran six times per menu visit and the
// scanner stayed on screen, with both the stored display handle and
// findDisplay coming back null. A title layer raised by a mission cannot
// be addressed from outside it.
//
// The pause menu is the last moment the mission is still alive. Every road
// out of a mission passes through it - ABORT is on it, and so is the exit
// after being kicked - so the overlay comes down here, while the layer
// name still means something, rather than being chased afterwards.
//
// AND IT COMES BACK IF THE PLAYER IS ONLY PAUSING. Resuming re-raises it
// on the display's own unload, so a man who pressed ESC to check a setting
// does not lose his scanner.

params [["_display", displayNull, [displayNull]]];

private _wasOpen = !isNull (uiNamespace getVariable [QGVAR(scanner), displayNull]);
uiNamespace setVariable [QGVAR(scannerWasOpen), _wasOpen];

if (_wasOpen) then {
    [] call FUNC(scannerClose);
};

// THE ONLY MOMENT THIS CAN BE DONE. Nothing of ours runs at the transition
// out of a mission - the ticks stop, and the main menu display raises no
// event because it is reused rather than created. The pause menu is the
// last thing that happens while the mission is still alive, so this is it.
diag_log text format ["[GHOST] (hacking) pause menu - scanner was up: %1, taken down", _wasOpen];

if (isNull _display) exitWith {};

_display displayAddEventHandler ["Unload", {
    // Back into the mission: put the handset back up if it was up.
    if (uiNamespace getVariable [QGVAR(scannerWasOpen), false]) then {
        uiNamespace setVariable [QGVAR(scannerWasOpen), false];
        [{
            if (!isNull player) then {[player] call FUNC(scannerToggle)};
        }, []] call CBA_fnc_execNextFrame;
    };
    false
}];
