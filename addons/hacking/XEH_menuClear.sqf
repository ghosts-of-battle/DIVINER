#include "script_component.hpp"

// THE SCANNER MUST NOT BE ON THE MAIN MENU. The handset overlay is a title
// layer put up with cutRsc, and a named title layer outlives the mission
// that raised it: the user photographed this sitting over QUICK PLAY three
// times. Clearing the layer by name is what FUNC(scannerClose) does and it
// is not enough once the mission is gone - there is nothing left for a
// title command to address - so the display is closed directly, by its own
// id, which still resolves in the menu.
//
// The tick handler goes too. A per-frame handler registered with CBA runs
// on in the menu, and one drawing into a display that has just been closed
// is the next stuck widget.
//
// Safe with nothing up: clearing a clear layer, closing a null display and
// removing a handler that is not running are all no-ops. This must never
// be the thing that throws in the main menu.

// Never while a mission is live - see the same guard in hud's menuClear.
if (!isNull player) exitWith {};

QGVAR(scanner) cutText ["", "PLAIN", 0];
QGVAR(scanner) cutFadeOut 0;

private _closed = 0;
{
    if (!isNull _x) then {
        _x closeDisplay 0;
        _closed = _closed + 1;
    };
} forEach [
    uiNamespace getVariable [QGVAR(scanner), displayNull],
    findDisplay IDD_SCANNER
];

uiNamespace setVariable [QGVAR(scanner), displayNull];

// EVERY DISPLAY ON SCREEN, NAMED - AND ANY OF OURS CLOSED.
//
// Both the stored handle and findDisplay came back null while the widget
// was plainly on the menu, which means neither can reach it: a title
// layer's display is not in the tree findDisplay walks, and a named layer
// string is resolved PER MISSION - clearing "ghostD_hacking_scanner" from
// the menu allocates a fresh empty layer in the MENU and leaves the one
// the dead mission raised exactly where it was.
//
// allDisplays is the one list that can still see it. A display prints as
// "Display #<idd>", so this both names every display in the RPT - which
// finally identifies the offender by number rather than by screenshot -
// and closes any that belongs to this mod.
private _mine = [IDD_SCANNER, 8920, 8900, 8960, 8700, 8400, 9439];
{
    private _d = _x;
    private _name = str _d;
    diag_log text format ["[GHOST] menu display present: %1", _name];

    {
        if ((_name find str _x) > -1) exitWith {
            _d closeDisplay 0;
            _closed = _closed + 1;
            diag_log text format ["[GHOST] menu display CLOSED: %1", _name];
        };
    } forEach _mine;
} forEach allDisplays;

if (!isNil QGVAR(scannerPFH)) then {
    [GVAR(scannerPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(scannerPFH) = nil;
};

diag_log text format ["[GHOST] (hacking) menu reached - scanner cleared, %1 display(s) closed", _closed];
