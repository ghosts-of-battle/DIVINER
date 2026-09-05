#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_radarSweep

Description:
    One pass over every registered surface search radar: decide whether the set
    is radiating, and if it is, write down what it can see.

    Three things bound what a radar sees, and all three are the reason siting it
    matters:

      instrumented range - how far the set was built to look
      radar horizon      - 4.12 * (sqrt(antenna height) + sqrt(mast height)) km.
                           The sea curves away. An antenna 20 m up sees a
                           destroyer's mast about 30 km off; put the same set on
                           a 200 m headland and it sees 45. Height is range.
      line of sight      - a hull behind a headland is not there. This is what
                           lets a ship hug the coast and come in unseen, and
                           what makes one radar not enough to cover a bay.

    EMCON is the fourth: the set radiates for a while and is silent for a while,
    so it cannot simply be waited out, and so that a player with direction
    finding has something intermittent to chase rather than a permanent beacon.
    Contacts are NOT cleared while it is silent - they age out (AS_RADAR_TRACK),
    which is what gives a destroyed radar a last few seconds of usable track and
    then blindness.

Parameters (CBA PFH): 0: args (unused), 1: handle

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["", "_handle"];

private _radars = (missionNamespace getVariable [QGVAR(radars), []]) select {!isNull _x};
missionNamespace setVariable [QGVAR(radars), _radars];

if (_radars isEqualTo []) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable [QGVAR(sweepHandle), nil];
};

private _now = CBA_missionTime;
private _period = AS_RADAR_ON + AS_RADAR_OFF;

// THE HULL LIST, ONCE. This used to be a nearestObjects out to instrumented
// range - tens of kilometres - run per radar per sweep, and a nearestObjects
// that large walks the whole object tree. There are never many ships on a map,
// and `vehicles` is already the short list, so gather the hulls once for the
// whole pass and let each radar range-test against them. The horizon and
// line-of-sight tests below are unchanged; only the way the candidates are
// found is cheaper.
private _hulls = vehicles select {
    private _v = _x;
    alive _v && {AS_RADAR_TYPES findIf {_v isKindOf _x} > -1}
};
if (_hulls isEqualTo []) exitWith {};

{
    private _radar = _x;

    // A wrecked set is off the air, and its tracks go with it
    if (!alive _radar || {damage _radar > AS_RADAR_DAMAGE}) then {
        _radar setVariable [QGVAR(contacts), []];
        _radar setVariable [QGVAR(radiating), false];
        continue;
    };

    private _phase = (_now + (_radar getVariable [QGVAR(emconOffset), 0])) mod _period;
    private _radiating = _phase < AS_RADAR_ON;
    // Server-local. It was broadcast to every client on every EMCON flip for a
    // reader that does not exist; when one does - a device page showing which
    // sets are radiating - broadcast it then, and only then.
    _radar setVariable [QGVAR(radiating), _radiating];
    // silent: hold what it had, let it age
    if (!_radiating) then {continue};

    private _range = _radar getVariable [QGVAR(range), AS_RADAR_RANGE];
    private _eye = getPosASL _radar;
    // the antenna, not the ground under it
    private _mast = (boundingBoxReal _radar select 1 select 2) max 0;
    _eye set [2, (_eye select 2) + _mast];
    private _hRadar = (_eye select 2) max 1;

    private _seen = [];
    {
        private _hull = _x;
        if (!alive _hull) then {continue};

        private _tPos = getPosASL _hull;
        // a ship's own mast lifts it over the horizon too
        private _tMast = (boundingBoxReal _hull select 1 select 2) max 1;
        _tPos set [2, (_tPos select 2) + _tMast];

        private _horizon = AS_RADAR_HORIZON * (sqrt _hRadar + sqrt _tMast);
        if ((_eye distance _tPos) > (_range min _horizon)) then {continue};

        // terrain between the two and there is no contact
        if (terrainIntersectASL [_eye, _tPos]) then {continue};

        _seen pushBack [_hull, getPosASL _hull, _now];

        // Onto the mod's threat board as well as into this radar's own track
        // file. A hull the coastal net has painted is a fact the whole side
        // owns - the enemy commander can escalate off it, the devices can show
        // it - rather than something only this battery's missiles know about.
        private _rSide = _radar getVariable [QGVAR(side), side _radar];
        if (_rSide isNotEqualTo sideUnknown && {(_rSide getFriend (side _hull)) < 0.6}) then {
            [QEGVAR(common,contact), [_rSide, side _hull, ASLToAGL getPosASL _hull, 0, "radar"]] call CBA_fnc_localEvent;
        };
    } forEach _hulls;

    // Refresh what was seen this pass, keep what was seen recently. A contact
    // that has drifted out of the beam still has a last known position, which
    // is what a battery shoots at.
    private _kept = (_radar getVariable [QGVAR(contacts), []]) select {
        _x params ["_obj", "", "_t"];
        !isNull _obj
            && {_now - _t < AS_RADAR_TRACK}
            && {_seen findIf {(_x select 0) isEqualTo _obj} < 0}
    };
    _radar setVariable [QGVAR(contacts), _seen + _kept];
} forEach _radars;
