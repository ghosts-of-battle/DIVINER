#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_gpsApply

Description:
    Takes this player's GPS away while they stand in a GPS-denied field, and
    gives it back when they walk out. Client-local, called once a tick by
    FUNC(jammerLoop) with the DOM_GPS factor that tick already measured.

    IT NEVER TOUCHES THE PLAYER'S GEAR (user, 2026-08-31: "never remove gear to
    make a function work"). showGPS is a UI switch: the receiver stays in the
    slot, in the inventory, exactly where the player put it, and the display
    simply goes dark. Nothing is unassigned, removed, remembered or handed
    back, so there is no state to get wrong across a respawn, a disconnect or
    a mission end - and no way for the system to lose somebody's kit.

    Two earlier cuts of this did touch gear and both were wrong: the first
    unlinkItem'd, which DELETES the item off the unit, and the second
    unassignItem'd, which is reversible but still reaches into a loadout to
    produce a UI effect.

    THE SELF-ICON GOES WITH IT, which is the whole point. On this difficulty the
    player's own marker on the map comes from carrying a GPS; take the GPS and
    the map stops telling you where you are, which is the thing that makes GPS
    denial worth fielding at all. Nothing else has to be switched off.

    WHAT IT CANNOT DO. showGPS hides the GPS/minimap display. The player's own
    icon on the MAP is drawn by the engine off the receiver being carried, and
    there is no scripting command for it - so under this rule the self-icon
    stays. Taking it as well would mean taking the item, which is the thing
    this function is forbidden to do.

    IT IS DELIBERATELY NOT A GRADIENT. Anything under the DENIED band leaves the
    kit alone: a half-jammed GPS that works half the time is unreadable, and the
    band is messaging's own 0.75, so "DATA OUT" and "GPS OUT" mean the same
    strength of field.

Parameters:
    _factor : NUMBER - the DOM_GPS jamming factor at this player, 0..1.

Returns:
    BOOL - true if the player is currently denied.

Example:
    [([getPosASL player, 0, DOM_GPS] call FUNC(jamFactor)) select 0] call FUNC(gpsApply)

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_factor", 0, [0]]];

if (!hasInterface || {isNull player}) exitWith { false };

private _denied = _factor >= JAM_DENIED_BAND && {alive player};
private _was = missionNamespace getVariable [QGVAR(gpsDenied), false];

// EDGES ONLY. showGPS is a global UI switch that other systems reach for too -
// ALiVE's C2ISTAR and its radio dialog both set it - so this writes it when the
// state CHANGES and leaves it alone the rest of the time. Setting it every tick
// would stomp anything else that had a reason to hide the receiver.
if (_denied isEqualTo _was) exitWith { _denied };

missionNamespace setVariable [QGVAR(gpsDenied), _denied];
showGPS (!_denied);

if (_denied) then {
    // Told once, on the edge. Amber: a warning, not a refusal. Nothing is said
    // on the way out - getting your receiver back is not news, and the meter is
    // already saying GPS OK.
    ["Jamming", "GPS NONET - receiver has no lock.",
        [0.914, 0.651, 0.235, 1]] call EFUNC(notify,notify);
};

TRACE_1("GPS denial",_denied);

_denied
