#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_reapplyLocal

Description:
    Puts this machine's OWN rank and skills back on the player from the
    published roster - what the host does when it publishes, since it never
    hears its own publicVariable (FUNC(hostRefresh)). It was the personnel
    panel's CLOSE (user, 2026-09-05: "closing pac does a reapply", "i was
    still a pvt in game"); renamed from panelReapply when that panel went
    (2026-09-09).

    THE LOCAL HALF OF FUNC(applyOnClient) ONLY. Rank and skills, off the
    roster row, applied here - not the server round-trips applyOnClient makes
    (auto-slot, kept loadouts, the OPORD ask), which have no business firing
    because a screen closed. So it never re-slots anybody or re-sends a
    loadout; it just makes the rank on the unit match the record.

Parameters:
    None

Returns:
    Whether a row was found and applied <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!hasInterface || {isNull player} || {!alive player}) exitWith {false};

private _uid = [player] call FUNC(uid);
private _row = (missionNamespace getVariable [QGVAR(roster), []]) select {(_x # 0) isEqualTo _uid};
if (_row isEqualTo []) exitWith {false};

(_row # 0) params ["", "", "_rankId", "", "", "", "_skillIds"];

[player, _rankId] call FUNC(applyRank);
[player, _skillIds] call FUNC(applySkills);

TRACE_2("PAC reapplied locally",_rankId,count _skillIds);
true
