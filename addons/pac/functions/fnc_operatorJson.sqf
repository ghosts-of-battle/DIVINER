#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_operatorJson

Description:
    One player's record as an OPERATOR FILE - the shape the unit asked for
    (2026-09-05), with the record's own fields, the rank's pay grade, the
    ORBAT's platoon, the attendance counted off the sessions and the log
    lines written against them, all in one document:

        operator_id
        identity          milsim_name, community_handle, discord_id,
                          steam_id_64, enlistment_date
        service_status    current_rank, rank_abbreviation, pay_grade,
                          promotion_date, time_in_grade_days, duty_status,
                          app_clearance_level
        orbat_assignment  company, platoon, squad, billet, reports_to_id
        personnel_logs    qualifications [{course_code, name, date_earned}],
                          attendance {total_operations_scheduled, attended,
                          excused_absence_loa, unexcused_absence_awol,
                          attendance_percentage},
                          awards [{award_id, ribbon_name, date_issued,
                          citation}],
                          admin_actions [{action_id, type, date, logged_by,
                          notes}], training [{date, logged_by, notes}]
        promotion         points, current_rank_threshold, next_rank,
                          next_rank_id, points_to_next, breakdown
                          [{factor, quantity, points_each, points}] - from
                          the unit's editable formula, FUNC(promotionPoints)

    Server only. FUNC(adminText) "operator" hands it to an admin as JSON.

Parameters:
    0: UID <STRING>

Returns:
    The document <HASHMAP>, empty when there is no record

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_uid", "", [""]]];

if (!isServer || _uid isEqualTo "") exitWith {createHashMap};
private _rec = GVAR(players) getOrDefault [_uid, createHashMap];
if (count _rec isEqualTo 0) exitWith {createHashMap};

private _today = [] call FUNC(stamp);
private _fnc_date = {
    params ["_s"];
    if !(_s isEqualType "") then {_s = ""};
    _s select [0, 10]
};
private _fnc_days = {
    params ["_from"];
    if (_from isEqualTo "") exitWith {0};
    private _a = ([_from + " 00:00"] call FUNC(stampMinutes)) # 0;
    private _b = ([_today] call FUNC(stampMinutes)) # 0;
    (floor ((_b - _a) / 1440)) max 0
};

// ---- the rank, the status, the billet, the platoon --------------------------
private _rank = (GVAR(structure) getOrDefault ["ranks", createHashMap]) getOrDefault [_rec getOrDefault ["rankId", ""], createHashMap];
if !(_rank isEqualType createHashMap) then {_rank = createHashMap};
private _status = ["statuses", _rec getOrDefault ["statusId", ""]] call FUNC(lookup);
private _billet = ["roles", _rec getOrDefault ["roleId", ""]] call FUNC(lookup);

private _squad = _rec getOrDefault ["groupId", ""];
private _platoon = "";
if (_squad isNotEqualTo "" && {!isNil "ghostD_groups_fnc_orbat"}) then {
    {
        _x params ["", ["_pName", ""], ["_pCallsign", ""], "", ["_pSquads", []]];
        if ((toUpper _squad) in (_pSquads apply {toUpper _x})) exitWith {
            _platoon = [_pName, _pCallsign] select (_pName isEqualTo "");
        };
    } forEach (([] call ghostD_groups_fnc_orbat) # 1);
};

private _promoted = [_rec getOrDefault ["promotedAt", ""]] call _fnc_date;
if (_promoted isEqualTo "") then {_promoted = [_rec getOrDefault ["enlistedAt", ""]] call _fnc_date};

// ---- who logged what: an admin's operator id when they have one ------------
private _fnc_who = {
    params ["_byUid", "_byName"];
    private _admin = GVAR(players) getOrDefault [_byUid, createHashMap];
    private _op = if (_admin isEqualType createHashMap) then {_admin getOrDefault ["operatorId", ""]} else {""};
    [_op, _byName] select (_op isEqualTo "")
};

// ---- qualifications: what was ever granted, with the day; older records
// only know what is held now
private _quals = _rec getOrDefault ["qualifications", []];
if (_quals isEqualTo []) then {
    _quals = (_rec getOrDefault ["skillIds", []]) apply {[_x, ["skills", _x] call FUNC(lookup), ""]};
};

([_uid] call FUNC(attendanceOf)) params ["_scheduled", "_on", "_loa", "_awol", "_pct"];
([_uid] call FUNC(promotionPoints)) params ["_points", "_breakdown", "_nextRank", "_needed", "_currentAt"];

createHashMapFromArray [
    ["operator_id", _rec getOrDefault ["operatorId", ""]],
    ["identity", createHashMapFromArray [
        ["milsim_name", _rec getOrDefault ["milsimName", ""]],
        ["community_handle", _rec getOrDefault ["name", ""]],
        ["discord_id", _rec getOrDefault ["discordId", ""]],
        ["steam_id_64", _uid],
        ["enlistment_date", [_rec getOrDefault ["enlistedAt", ""]] call _fnc_date]
    ]],
    ["service_status", createHashMapFromArray [
        ["current_rank", _rank getOrDefault ["name", ""]],
        ["rank_abbreviation", _rank getOrDefault ["abbrev", ""]],
        ["pay_grade", _rank getOrDefault ["payGrade", ""]],
        ["promotion_date", _promoted],
        ["time_in_grade_days", [_promoted] call _fnc_days],
        ["duty_status", _status],
        ["app_clearance_level", _rec getOrDefault ["clearance", ""]]
    ]],
    ["orbat_assignment", createHashMapFromArray [
        ["company", _rec getOrDefault ["company", ""]],
        ["platoon", _platoon],
        ["squad", _squad],
        ["billet", _billet],
        ["reports_to_id", _rec getOrDefault ["reportsTo", ""]]
    ]],
    ["personnel_logs", createHashMapFromArray [
        ["qualifications", _quals apply {
            _x params [["_sid", ""], ["_sname", ""], ["_when", ""]];
            createHashMapFromArray [["course_code", toUpper _sid], ["name", _sname], ["date_earned", [_when] call _fnc_date]]
        }],
        ["attendance", createHashMapFromArray [
            ["total_operations_scheduled", _scheduled],
            ["attended", _on],
            ["excused_absence_loa", _loa],
            ["unexcused_absence_awol", _awol],
            ["attendance_percentage", _pct]
        ]],
        ["awards", (_rec getOrDefault ["awards", []]) apply {
            _x params [["_aid", ""], ["_when", ""], "", ["_cit", ""]];
            createHashMapFromArray [["award_id", _aid], ["ribbon_name", ["awards", _aid] call FUNC(lookup)], ["date_issued", [_when] call _fnc_date], ["citation", _cit]]
        }],
        ["admin_actions", (_rec getOrDefault ["adminActions", []]) apply {
            _x params [["_lid", ""], ["_type", ""], ["_when", ""], ["_byUid", ""], ["_byName", ""], ["_notes", ""]];
            createHashMapFromArray [["action_id", _lid], ["type", _type], ["date", [_when] call _fnc_date], ["logged_by", [_byUid, _byName] call _fnc_who], ["notes", _notes]]
        }],
        // courses held - date, who logged it, what (2026-09-05)
        ["training", (_rec getOrDefault ["training", []]) apply {
            _x params [["_when", ""], ["_by", ""], ["_text", ""]];
            createHashMapFromArray [["date", [_when] call _fnc_date], ["logged_by", _by], ["notes", _text]]
        }]
    ]],
    // PROMOTION POINTS from the unit's editable formula (structure section
    // "promotion", document <unitId>.promotion) - see FUNC(promotionPoints)
    ["promotion", createHashMapFromArray [
        ["points", _points],
        ["current_rank_threshold", _currentAt],
        ["next_rank", ["ranks", _nextRank] call FUNC(lookup)],
        ["next_rank_id", _nextRank],
        ["points_to_next", _needed],
        ["breakdown", _breakdown apply {
            _x params ["_what", "_qty", "_w", "_p"];
            createHashMapFromArray [["factor", _what], ["quantity", _qty], ["points_each", _w], ["points", _p]]
        }]
    ]]
]
