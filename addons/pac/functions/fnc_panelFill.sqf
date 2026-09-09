#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelFill

Description:
    Draws the middle column of the admin page - the one open player - from
    GVAR(editRecord), which is whatever the server last sent for
    GVAR(editUid).

    THREE STATES. No uid: the column says so and everything is empty. A uid
    with an empty record: the request is in flight, the column says loading.
    A record: the lot - header, combos set to the record's ids, group text,
    the skills list with every skill in the structure ticked or not, the
    player's awards and notes.

    COMBOS ARE SET UNDER GVAR(panelFilling). lbSetCurSel fires onLBSelChanged,
    and FUNC(panelCombo) would otherwise write back the value it had just been
    shown.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _rec = GVAR(editRecord);
private _uid = GVAR(editUid);

private _ctrlName = _display displayCtrl PAC_IDC_M_NAME;
private _ctrlSkills = _display displayCtrl PAC_IDC_SKILLS_LIST;
private _ctrlAwards = _display displayCtrl PAC_IDC_AWARDS_LIST;
private _ctrlNotes = _display displayCtrl PAC_IDC_NOTES_LIST;
private _ctrlTraining = _display displayCtrl PAC_IDC_TRAINING_LIST;

GVAR(panelFilling) = true;

lbClear _ctrlSkills;
lbClear _ctrlAwards;
lbClear _ctrlNotes;
lbClear _ctrlTraining;

private _fnc_selectId = {
    params ["_idc", "_id"];
    private _combo = _display displayCtrl _idc;
    private _found = -1;
    for "_i" from 0 to (lbSize _combo) - 1 do {
        if ((_combo lbData _i) isEqualTo _id) exitWith {_found = _i};
    };
    _combo lbSetCurSel _found;
};

if (_uid isEqualTo "" || {count _rec isEqualTo 0}) exitWith {
    _ctrlName ctrlSetStructuredText parseText (["<t size='0.9'>Select a player from the roster.</t>", "<t size='0.9'>loading ...</t>"] select (_uid isNotEqualTo ""));
    {[_x, "__none__"] call _fnc_selectId} forEach [PAC_IDC_RANK_COMBO, PAC_IDC_GROUP_COMBO, PAC_IDC_STATUS_COMBO];
    ["", ""] call FUNC(panelRoleCombo);
    {(_display displayCtrl _x) ctrlSetText ""} forEach [PAC_IDC_ENLISTED, PAC_IDC_PROMOTED];
    (_display displayCtrl PAC_IDC_SERVICE_LINE) ctrlSetStructuredText parseText "";
    GVAR(panelFilling) = false;
};

// ---- header ----------------------------------------------------------------
private _online = _uid in (allPlayers apply {getPlayerUID _x});
_ctrlName ctrlSetStructuredText parseText format [
    "<t size='1.15' font='RobotoCondensedBold'>%1</t>  <t size='0.8'>%2</t>   <t size='0.8'>%6</t><br/><t size='0.75'>%3   ·   updated %4%5</t>",
    _rec getOrDefault ["name", _uid],
    ["offline", "online"] select _online,
    _uid,
    _rec getOrDefault ["updatedAt", "-"],
    ["", format ["   ·   from %1", _rec getOrDefault ["serverId", ""]]] select ((_rec getOrDefault ["serverId", ""]) isNotEqualTo ""),
    _rec getOrDefault ["operatorId", ""]
];

// ---- the dates, and what they count to ---------------------------------------
// Enlisted defaults to the day the unit first saw them and promoted to the day
// the rank last changed; both are typed over and SET to back-date. Time in
// service and time in grade are days from each to today.
private _enlisted = _rec getOrDefault ["enlistedAt", ""];
private _promoted = _rec getOrDefault ["promotedAt", ""];
if !(_enlisted isEqualType "") then {_enlisted = ""};
if !(_promoted isEqualType "") then {_promoted = ""};
(_display displayCtrl PAC_IDC_ENLISTED) ctrlSetText _enlisted;
(_display displayCtrl PAC_IDC_PROMOTED) ctrlSetText _promoted;

private _fnc_span = {
    params ["_from"];
    if (count _from < 10) exitWith {"-"};
    private _nowMin = ([[] call FUNC(stamp)] call FUNC(stampMinutes)) # 0;
    private _fromMin = ([_from + " 00:00"] call FUNC(stampMinutes)) # 0;
    private _days = floor ((_nowMin - _fromMin) / 1440);
    if (_days < 0) exitWith {"in the future"};
    private _y = floor (_days / 365);
    private _rest = _days mod 365;
    private _m = floor (_rest / 30);
    private _d = _rest mod 30;
    private _parts = [];
    if (_y > 0) then {_parts pushBack format ["%1 y", _y]};
    if (_m > 0) then {_parts pushBack format ["%1 mo", _m]};
    _parts pushBack format ["%1 d", _d];
    format ["%1 (%2 days)", _parts joinString " ", _days]
};
// ---- promotion points: computed on the server from the unit's editable
// formula (structure section "promotion") and sent on the record copy as
// "_promotion" - see FUNC(promotionPoints). Second line of the service block.
(_rec getOrDefault ["_promotion", [0, [], "", 0, 0]]) params [["_pts", 0], ["_parts", []], ["_nextId", ""], ["_needed", 0]];
private _fnc_q = {params ["_n"]; if (_n isEqualType 0) then {if (_n isEqualTo floor _n) then {str _n} else {format ["%1", (round (_n * 10)) / 10]}} else {"0"}};
private _detail = (_parts select {(_x # 2) isNotEqualTo 0}) apply {format ["%1 %2", [_x # 1] call _fnc_q, _x # 0]};
private _ladder = if (_nextId isEqualTo "") then {
    ["no ladder in the formula", "top of the ladder"] select ((_parts findIf {(_x # 2) isNotEqualTo 0}) >= 0)
} else {
    format ["next  <t font='RobotoCondensedBold'>%1</t>  at %2,  %3 to go", ["ranks", _nextId] call FUNC(lookup), _pts + _needed, _needed]
};
(_display displayCtrl PAC_IDC_SERVICE_LINE) ctrlSetStructuredText parseText format [
    "<t size='0.8'>time in service  <t font='RobotoCondensedBold'>%1</t>     time in grade  <t font='RobotoCondensedBold'>%2</t><br/>promotion  <t font='RobotoCondensedBold'>%3 pts</t>   %4%5</t>",
    [_enlisted] call _fnc_span,
    [[_promoted, _enlisted] select (_promoted isEqualTo "")] call _fnc_span,
    _pts,
    _ladder,
    ["", format ["   <t size='0.9'>(%1)</t>", _detail joinString ", "]] select (_detail isNotEqualTo [])
];

// ---- combos ----------------------------------------------------------------
[PAC_IDC_RANK_COMBO, _rec getOrDefault ["rankId", ""]] call _fnc_selectId;
[PAC_IDC_GROUP_COMBO, _rec getOrDefault ["groupId", ""]] call _fnc_selectId;
[PAC_IDC_STATUS_COMBO, _rec getOrDefault ["statusId", ""]] call _fnc_selectId;
// The role list is the group's - see FUNC(panelRoleCombo).
[_rec getOrDefault ["groupId", ""], _rec getOrDefault ["roleId", ""]] call FUNC(panelRoleCombo);

// ---- skills: every skill in the structure, ticked or not -------------------
private _has = _rec getOrDefault ["skillIds", []];
private _rows = [];
{
    _rows pushBack [_y getOrDefault ["name", _x], _x];
} forEach (GVAR(structure) getOrDefault ["skills", createHashMap]);
_rows sort true;
{
    _x params ["_name", "_id"];
    private _idx = _ctrlSkills lbAdd format ["%1  %2", ["[   ]", "[ X ]"] select (_id in _has), _name];
    _ctrlSkills lbSetData [_idx, _id];
} forEach _rows;

// ---- awards ----------------------------------------------------------------
{
    _x params ["_id", "_when", "_by", ["_citation", ""]];
    private _idx = _ctrlAwards lbAdd format ["%1  %2  (%3)%4", _when, ["awards", _id] call FUNC(lookup), _by, ["", "  -  " + _citation] select (_citation isNotEqualTo "")];
    _ctrlAwards lbSetData [_idx, _id];
} forEach (_rec getOrDefault ["awards", []]);

// ---- training, newest first; each row carries its index into the stored
// list so REMOVE takes out exactly the entry shown ------------------------------
private _training = _rec getOrDefault ["training", []];
for "_i" from (count _training) - 1 to 0 step -1 do {
    (_training # _i) params [["_when", ""], ["_by", ""], ["_text", ""], ["_course", ""]];
    // the course by name off the catalogue, the note after it; an old entry
    // with no course id is just its text
    private _what = if (_course isEqualTo "") then {_text} else {
        private _cn = ["trainings", _course] call FUNC(lookup);
        [_cn, format ["%1 - %2", _cn, _text]] select (_text isNotEqualTo "")
    };
    private _idx = _ctrlTraining lbAdd format ["%1  %2  (%3)", _when select [0, 16], _what, _by];
    _ctrlTraining lbSetData [_idx, str _i];
};

// ---- notes, newest first ---------------------------------------------------
private _notes = +(_rec getOrDefault ["notes", []]);
reverse _notes;
{
    _x params ["_when", "_by", "_text"];
    _ctrlNotes lbAdd format ["%1  %2:  %3", _when, _by, _text];
} forEach _notes;

GVAR(panelFilling) = false;
