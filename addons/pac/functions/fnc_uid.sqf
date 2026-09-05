#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_uid

Description:
    A player's stable id for the store - getPlayerUID, with a fallback for
    the EDITOR and singleplayer, where getPlayerUID returns "" and every
    record keyed on it would fail to match (a tester's own record, rank and
    skills read as empty - "storage did not load" when testing from the
    editor, user 2026-09-05).

    THE FALLBACK IS STABLE ACROSS A SESSION and derived from the profile
    name, so the same tester keeps the same record between spawns. It is
    marked with an "SP:" prefix so it is never mistaken for a real 17-digit
    Steam id (a CSV import, an admin list, a merge across servers all stay
    Steam-id only). In a real game - hosted, dedicated, JIP - getPlayerUID
    is the id and this is a passthrough.

Parameters:
    0: Unit <OBJECT> (optional, default player)

Returns:
    The id <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", player, [objNull]]];

private _uid = getPlayerUID _unit;
if (_uid isNotEqualTo "") exitWith {_uid};

// EDITOR / SP: no Steam id. If the tester set one (the "Test as Steam id"
// setting), be that operator so the database's own record loads; else a
// stable per-profile throwaway id so testing at least has a record of its own.
private _test = if (_unit isEqualTo player) then {trim (missionNamespace getVariable [QGVAR(testUid), ""])} else {""};
private _digits = (toArray _test) select {_x >= 48 && _x <= 57};
if (_test isNotEqualTo "" && count _digits >= 17) exitWith {_test};

private _who = if (_unit isEqualTo player) then {profileName} else {name _unit};
private _clean = (toArray _who) select {(_x >= 48 && _x <= 57) || (_x >= 65 && _x <= 90) || (_x >= 97 && _x <= 122)};
"SP:" + (toString _clean)
