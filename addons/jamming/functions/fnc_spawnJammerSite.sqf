#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_spawnJammerSite

Description:
    Builds one jammer site: a terminal that denies a domain, an omnidirectional
    antenna and a satellite dish around it, and an ALiVE objective over the lot.

    THE TERMINAL IS THE EMITTER. It holds the zone and it is what LOCATE JAMMER
    plots, what the hacking tower pool picks up by classname, and what killing
    ends the denial. The antenna and the dish are the installation: they cost
    nothing, they carry no zone, and shooting them achieves exactly what shooting
    a fence achieves. They are here because a site has to READ as a site from
    three hundred metres out - one box on a hillside does not, and a player who
    cannot recognise the thing they are meant to attack is not being given a
    choice (user, 2026-08-31).

    ONE CLASS PER DOMAIN, so the site says what it does before you reach it:
        hub          -> GPS      the satellite uplink
        plain        -> DATA     TAC//MSG and the other groups' markers
        comms        -> RADIO    the voice net
    The dressing is rolled from three colours each, so no two sites are the
    same object twice over.

    THE UPLINK IS AN ALiVE OBJECTIVE. THE MASTS ARE NOT, and that is a
    correction, not the original design: registering every site cost 3m47s of
    frozen server in the 14:48 run and left OPCOM permanently worse off.

    registerSite walks the commander's whole objective list with a hashGet per
    entry to dedup, so 248 registrations against a list growing from 132 to 380
    is around ninety thousand ALiVE hash lookups on the main thread - and every
    one of them ADDS an objective, tripling the world OPCOM and TACOM iterate
    every tick from then on. One uplink on the map is worth that; two hundred
    and forty-eight masts are not. The masts are still findable: LOCATE JAMMER
    plots them off the jamming registry and the hacking pool takes them from the
    same place, neither of which needs ALiVE to have heard of them.

    THE DRESSING FOLLOWS THE SAME RULE. Three props at 248 sites is 744 objects
    in one frame; the antenna and dish are there so the ONE installation worth
    assaulting reads as an installation, and a mast beside a road does not need
    them to be recognised as a mast.

Parameters:
    _side   : SIDE   - the commander this site belongs to.
    _pos    : ARRAY  - where the terminal stands, AGL.
    _domain : STRING - DOM_GPS, DOM_DATA or DOM_RADIO.
    _radius : NUMBER - the zone's outer radius.

Returns:
    ARRAY - [_zoneId, _terminal]. _zoneId is "" on failure.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith { ["", objNull] };

params [["_side", sideUnknown, [sideUnknown]], ["_pos", [0,0,0], [[]]],
        ["_domain", DOM_RADIO, [""]], ["_radius", 300, [0]]];

private _prop = switch (_domain) do {
    case DOM_GPS: { JAM_PROP_GPS };
    case DOM_DATA: { JAM_PROP_DATA };
    default { JAM_PROP_RADIO };
};

if (!isClass (configFile >> "CfgVehicles" >> _prop)) exitWith {
    INFO_2("terminal '%1' is not in this mod set - no %2 site",_prop,_domain);
    ["", objNull]
};

// --- the emitter ------------------------------------------------------------
([_pos, _radius, _prop, "jam", [_domain]] call FUNC(spawnZoneAt)) params ["_id", "_obj"];

// WHOSE SITE IT IS, stamped on the zone. The registry never carried a side -
// it did not need one while the only consumer was "how jammed am I here" -
// but the intel ladder reports a target side, so LOCATE JAMMER cannot file a
// spotrep the way LOCATE ARTILLERY does without it.
if (_id isNotEqualTo "") then {
    private _z = GVAR(jammers) select (GVAR(jammers) findIf { (_x param [ZONE_ID, ""]) isEqualTo _id });
    (_z param [ZONE_MODEL, createHashMap]) set ["side", _side];
};
if (_id isEqualTo "") exitWith { ["", objNull] };

// --- the installation around it ---------------------------------------------
// GPS only - see the note above. A radio or data mast is one prop, which is
// what it was before the three-prop site and what the frame budget allows.
if (_domain isEqualTo DOM_GPS) then {
    // Placed on a ring at opposite bearings so the three read as an arrangement
    // rather than a heap, and setVectorUp so they sit on the slope the terminal
    // is on. createVehicle NONE, not CAN_COLLIDE: a dish shoved off a hillside
    // by collision resolution ends up somewhere the site does not own.
    private _bearing = random 360;
    {
        _x params ["_classes", "_offset"];
        private _cls = selectRandom _classes;
        if (!isClass (configFile >> "CfgVehicles" >> _cls)) then { continue };

        private _at = _pos getPos [JAM_SITE_SPREAD, _bearing + _offset];
        private _dressing = createVehicle [_cls, _at, [], 0, "NONE"];
        if (isNull _dressing) then { continue };
        _dressing setPosATL _at;
        _dressing setDir (_bearing + _offset + 180);
        _dressing setVectorUp surfaceNormal (getPosATL _dressing);

        // Remembered on the terminal so a mission that cleans up a dead site
        // has the pieces to hand. Nothing here deletes them: the wreckage of a
        // jammer site is worth leaving on the map.
        private _kit = _obj getVariable [QGVAR(siteProps), []];
        _kit pushBack _dressing;
        _obj setVariable [QGVAR(siteProps), _kit];
    } forEach [[JAM_PROP_OMNI, 0], [JAM_PROP_DISH, 140]];
};

INFO_3("%1 site up: %2 at %3",_domain,_prop,mapGridPosition _pos);

[_id, _obj]
