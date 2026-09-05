#include "script_component.hpp"
/*
 * Author: Ghost
 * The scanner sweep, or [] when this player has no set.
 *
 * ONE READ FOR THE WHOLE HUD. The drones tile, the jamming tile and the combined
 * one all want the same sweep, and three calls a second to
 * EFUNC(hacking,scannerRead) to draw one frame is three answers that can differ
 * by a tick. This is the one place any of them asks.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * The sweep, or [] <ARRAY>
 *
 * Public: No
 */

if (isNil QEFUNC(hacking,scannerRead)) exitWith {[]};
if !([player] call EFUNC(hacking,hasScanner)) exitWith {[]};

[] call EFUNC(hacking,scannerRead)
