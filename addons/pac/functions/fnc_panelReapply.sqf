#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelReapply

Description:
    Puts the closing admin's OWN rank and skills back on their unit from the
    published roster - the reason CLOSE reapplies (user, 2026-09-05: "closing
    pac does a reapply", "i was still a pvt in game"). An admin who edits
    their own rank and skills should carry them the moment they close the
    page, not wait for the next respawn or a stray publish.

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

TRACE_2("PAC reapplied on panel close",_rankId,count _skillIds);
true
