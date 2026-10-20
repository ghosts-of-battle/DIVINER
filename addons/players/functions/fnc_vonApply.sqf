#include "script_component.hpp"
/*
 * Author: YonV
 * Puts the base-game voice (VON) plan on the server's custom radio channels:
 * one channel per net in FUNC(vonNets), labelled with the net's name, then
 * hands membership to FUNC(vonSync).
 *
 * ONLY WITHOUT A RADIO MOD. EGVAR(common,von) is decided once at preInit - no
 * TFAR, no ACRE - and every ACRE and TFAR path in the mod is untouched by this.
 *
 * CHANNELS ARE KEPT, NOT REMADE. The engine has ten custom channels and no way
 * to delete one, so a plan that changes mid-mission (an admin edit, the
 * database's plan arriving after the mission's) relabels the channels it
 * already made, makes more only when it needs more, and empties and blanks
 * (VON_UNUSED_LABEL) any it no longer uses. GVAR(vonPool) holds every id this
 * server has created.
 *
 * THE SIDE is the mission's player side as the ORBAT says it
 * (ghostD_groups_fnc_orbat, "WEST" when unsaid). A custom channel has no side of
 * its own in the engine, so it decides the channel's colour and which players
 * FUNC(vonSync) may put on it.
 *
 * Called by this addon's postInit (GVAR(vonReady) is what says it has run) and
 * by ghostD_pac_fnc_radioApply whenever the plan's globals change. Before the
 * postInit it does nothing - the postInit will.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Whether the channels were (re)applied <BOOL>
 *
 * Example:
 * [] call ghostD_players_fnc_vonApply
 *
 * Public: No
 */

if (!isServer || {!EGVAR(common,von)}) exitWith {false};
if !(missionNamespace getVariable [QGVAR(vonReady), false]) exitWith {false};
if !(missionNamespace getVariable [QEGVAR(Settings,enableRadios), true]) exitWith {false};

([] call FUNC(vonNets)) params ["_nets", "_fallback"];

private _sideText = "WEST";
if (!isNil "ghostD_groups_fnc_orbat") then {
    _sideText = ([] call ghostD_groups_fnc_orbat) param [3, "WEST"];
};
GVAR(vonSide) = [_sideText, west] call EFUNC(common,sideFromText);
private _colour = [GVAR(vonSide)] call BIS_fnc_sideColor;

if (isNil QGVAR(vonPool)) then {GVAR(vonPool) = []};
if (isNil QGVAR(vonMembers)) then {GVAR(vonMembers) = createHashMap};

private _channels = [];
{
    _x params ["_name", "_kind", "_squads"];
    private _id = GVAR(vonPool) param [_forEachIndex, 0];
    if (_id > 0) then {
        _id radioChannelSetLabel _name;
    } else {
        _id = radioChannelCreate [_colour, _name, VON_CALLSIGN, [], true];
        if (_id <= 0) then {
            WARNING_1("VON","radioChannelCreate refused net '%1' - no custom channel left",_name);
            continue;
        };
        GVAR(vonPool) pushBack _id;
    };
    _channels pushBack [_id, _name, _kind, _squads, _fallback];
    INFO_4("VON","net '%1' (%2) on custom channel %3, squads %4",_name,_kind,_id,_squads);
} forEach _nets;

// a channel the plan no longer uses: nobody on it, and no name
private _used = _channels apply {_x # 0};
{
    private _id = _x;
    if (_id in _used) then {continue};
    private _members = (GVAR(vonMembers) getOrDefault [_id, []]) select {!isNull _x};
    if (_members isNotEqualTo []) then {_id radioChannelRemove _members};
    GVAR(vonMembers) set [_id, []];
    _id radioChannelSetLabel VON_UNUSED_LABEL;
} forEach GVAR(vonPool);

GVAR(vonChannels) = _channels;
// what a client needs to name a custom channel: [[id, netName, kind], ...]
GVAR(vonLabels) = _channels apply {[_x # 0, _x # 1, _x # 2]};
publicVariable QGVAR(vonLabels);

[] call FUNC(vonSync);
true
