#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageSection

Description:
    Fills the management window for the section picked in the combo: the
    field labels on the right (they differ per section), which buttons
    apply, the hint, and the list on the left - filtered by the FILTER
    edit. Also called when the server republishes the structure or the
    roster, and when the log arrives, so the list is never stale.

    THE FIELD TABLE - [label, field, hint] x6 per section - is the one
    place that knows which section has which fields; FUNC(manageSelect)
    reads it to fill the edits and FUNC(manageSave) to read them back.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display) exitWith {};

private _combo = _display displayCtrl PAC_IDC_MG_SECTION;
private _sel = lbCurSel _combo;
if (_sel >= 0) then {GVAR(mgSection) = _combo lbData _sel};
private _section = GVAR(mgSection);
private _filter = toLower trim ctrlText (_display displayCtrl PAC_IDC_MG_FILTER);

// ---- the fields ---------------------------------------------------------------
private _fields = switch (_section) do {
    case "squads": {[
        ["NAME", "name", "the squad's name - its group id, e.g. BANSHEE 1-1"],
        ["SLOTS", "roles", "one role class per slot, comma-separated, in slot order - e.g. teamleadBanshee, atlBanshee, reconBanshee"],
        ["CONDITION", "condition", "SQF that must be true for the squad to be offered; true for always"],
        ["POSITION", "position", "1 = first row. THE ROW IS THE SR RADIO CHANNEL ORDER - moving a squad moves its channel"]
    ]};
    case "platoons": {[
        ["NAME", "name", "the top line of the tab - 1ST PLT INF"],
        ["CALLSIGN", "callsign", "the bold word under it - BANSHEE"],
        ["NET", "net", "the platoon's net: a named net (NETS) and an MR channel of the same name"],
        ["SQUADS", "squads", "the squads under this tab, comma-separated, by name"]
    ]};
    case "radionets": {[
        ["NET", "net", "an MR channel name from the radio plan - GROUND 1"],
        ["SQUADS", "squads", "the squads on it, comma-separated, by name"]
    ]};
    case "faction": {[
        ["NAME", "name", "the name over the role screen"]
    ]};
    case "operators": {[
        ["MILSIM NAME", "milsimName", "the name the unit calls them - Cpl J. Miller"],
        ["DISCORD ID", "discordId", "their Discord user id"],
        ["ENLISTED", "enlistedAt", "YYYY-MM-DD - the day they joined the unit; attendance is counted from here"],
        ["CLEARANCE", "clearance", "what the unit lets them do in its apps - Clerk, S1, Admin ... free text"],
        ["COMPANY", "company", "Alpha Co. - free text; platoon and squad come off the ORBAT"],
        ["REPORTS TO", "reportsTo", "an operator id (OP-nnnnn) or a name"]
    ]};
    default {[]};
};
while {count _fields < 6} do {_fields pushBack ["", "", ""]};
GVAR(mgFields) = _fields;

{
    _x params ["_labelIdc", "_editIdc", "_i"];
    (_fields # _i) params ["_label", "", "_hint"];
    (_display displayCtrl _labelIdc) ctrlSetStructuredText parseText format ["<t size='0.85'>%1</t>", _label];
    private _edit = _display displayCtrl _editIdc;
    _edit ctrlShow (_label isNotEqualTo "");
    _edit ctrlSetTooltip _hint;
} forEach [
    [PAC_IDC_MG_F1_LABEL, PAC_IDC_MG_F1, 0], [PAC_IDC_MG_F2_LABEL, PAC_IDC_MG_F2, 1], [PAC_IDC_MG_F3_LABEL, PAC_IDC_MG_F3, 2],
    [PAC_IDC_MG_F4_LABEL, PAC_IDC_MG_F4, 3], [PAC_IDC_MG_F5_LABEL, PAC_IDC_MG_F5, 4], [PAC_IDC_MG_F6_LABEL, PAC_IDC_MG_F6, 5]
];

// the id row: what the item is keyed by
private _idLabel = switch (_section) do {
    case "squads": {"SQUAD"};
    case "platoons": {"TAB ID"};
    case "radionets": {"NET ID"};
    case "operators": {"STEAM ID"};
    default {""};
};
(_display displayCtrl PAC_IDC_MG_ID_LABEL) ctrlSetStructuredText parseText format ["<t size='0.85'>%1</t>", _idLabel];
private _idEdit = _display displayCtrl PAC_IDC_MG_ID;
_idEdit ctrlShow (_idLabel isNotEqualTo "");
_idEdit ctrlEnable (_section in ["platoons", "radionets"]);
_idEdit ctrlSetTooltip (switch (_section) do {
    case "platoons": {"Letters, digits, underscore. New tab: type an id; existing: shown"};
    case "radionets": {"Letters, digits, underscore. New net: type an id; existing: shown"};
    case "squads": {"The squad as it is now - rename it in NAME"};
    default {""};
});

// the buttons
(_display displayCtrl PAC_IDC_MG_NEW) ctrlShow (_section in ["squads", "platoons", "radionets"]);
(_display displayCtrl PAC_IDC_MG_REMOVE) ctrlShow (_section in ["squads", "platoons", "radionets"]);
(_display displayCtrl PAC_IDC_MG_SAVE) ctrlShow (_section isNotEqualTo "log");
(_display displayCtrl PAC_IDC_MG_EXPORT) ctrlSetText (switch (_section) do {
    case "log": {"LOG TO CLIPBOARD"};
    case "operators": {"OPERATOR FILE TO CLIPBOARD"};
    default {"ORBAT TO CLIPBOARD"};
});

// ---- the hint -------------------------------------------------------------------
private _hint = switch (_section) do {
    case "log": {"Every action an admin took, dated and signed: rank, role, group, status, skills, awards, notes, the operator fields, structure and ORBAT edits, op windows, imports, kicks and bans. Kept in the store and on the record of the player it was done to (their operator file lists it under admin actions). Type in the filter to narrow it; newest first."};
    case "squads": {"A squad is a name, its slots and a condition. SLOTS are role classes in slot order - the first is the element leader. The list order is the SR radio channel order (row one is channel one on the handheld), so POSITION is a real change and the card painted on the radio has to be regenerated after it. Saving a squad rebuilds the live slot table at once; nobody seated is thrown out - a man stays by squad name and slot number."};
    case "platoons": {"A tab groups squads on the role screen and carries the platoon's net - its mailbox and MR channel, tied to it here and nowhere else. Up to ten tabs, five to a row. A squad in no tab still appears, under UNASSIGNED."};
    case "radionets": {"Nets that cross a platoon boundary - GROUND 1 is a rifle squad and the crew that carries it. Asked before the platoon's net when a man is tuned. The name must be an MR channel in the radio plan."};
    case "faction": {"The name over the role screen - '<FACTION>  ROLE SELECTION'."};
    case "operators": {"Pick an operator to see their file: identity, service, assignment, qualifications, attendance, awards and every action logged against them. The six fields are the ones only a person can know; rank, role, group, status, skills and awards are set on the roster page and the platoon comes off the ORBAT."};
    default {""};
};
if (_section isNotEqualTo "operators" || GVAR(mgKey) isEqualTo "") then {
    (_display displayCtrl PAC_IDC_MG_HINT) ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", _hint];
};

// ---- the list ---------------------------------------------------------------------
private _list = _display displayCtrl PAC_IDC_MG_LIST;
private _rows = [];      // [text, key]
private _total = 0;

switch (_section) do {
    case "log": {
        {
            _x params [["_id", ""], ["_when", ""], "", ["_byName", ""], ["_type", ""], "", ["_target", ""], ["_detail", ""]];
            private _text = format ["%1  %2  %3%4  %5", _when, _byName, _type, ["", "  " + _target] select (_target isNotEqualTo ""), _detail];
            if (_filter isEqualTo "" || {_filter in toLower _text}) then {_rows pushBack [_text, _id]};
        } forEach GVAR(logRows);
        _total = GVAR(logTotal);
    };
    case "squads": {
        private _groups = if (!isNil "ghostD_groups_fnc_orbat") then {([] call ghostD_groups_fnc_orbat) # 0} else {[]};
        {
            _x params [["_name", ""], ["_roles", []]];
            private _text = format ["%1  %2  (%3 slots)", [_forEachIndex + 1, 2] call CBA_fnc_formatNumber, _name, count _roles];
            if (_filter isEqualTo "" || {_filter in toLower _text}) then {_rows pushBack [_text, _name]};
        } forEach _groups;
        _total = count _groups;
    };
    case "platoons": {
        private _platoons = if (!isNil "ghostD_groups_fnc_orbat") then {([] call ghostD_groups_fnc_orbat) # 1} else {[]};
        {
            _x params [["_id", ""], ["_name", ""], ["_callsign", ""], "", ["_squads", []]];
            private _text = format ["%1  %2  %3  (%4)", _id, _name, _callsign, count _squads];
            if (_filter isEqualTo "" || {_filter in toLower _text}) then {_rows pushBack [_text, _id]};
        } forEach _platoons;
        _total = count _platoons;
    };
    case "radionets": {
        private _nets = if (!isNil "ghostD_groups_fnc_orbat") then {([] call ghostD_groups_fnc_orbat) # 2} else {[]};
        {
            _x params [["_id", ""], ["_net", ""], ["_squads", []]];
            private _text = format ["%1  %2  (%3)", _id, _net, _squads joinString ", "];
            if (_filter isEqualTo "" || {_filter in toLower _text}) then {_rows pushBack [_text, _id]};
        } forEach _nets;
        _total = count _nets;
    };
    case "faction": {
        private _faction = if (!isNil "ghostD_groups_fnc_orbat") then {([] call ghostD_groups_fnc_orbat) # 3} else {""};
        _rows pushBack [format ["faction  %1", _faction], "faction"];
        _total = 1;
    };
    case "operators": {
        {
            _x params ["_uid", "_name", "_rankId", "_roleId", "_groupId"];
            private _text = ([["ranks", _rankId, "abbrev"] call FUNC(lookup), _name, _groupId, ["roles", _roleId] call FUNC(lookup)] select {_x isNotEqualTo ""}) joinString "  ";
            if (_filter isEqualTo "" || {_filter in toLower _text}) then {_rows pushBack [_text, _uid]};
        } forEach (missionNamespace getVariable [QGVAR(roster), []]);
        _total = count (missionNamespace getVariable [QGVAR(roster), []]);
    };
};

lbClear _list;
private _keep = -1;
{
    _x params ["_text", "_key"];
    private _i = _list lbAdd _text;
    _list lbSetData [_i, _key];
    if (_key isEqualTo GVAR(mgKey)) then {_keep = _i};
} forEach _rows;
if (_keep >= 0) then {_list lbSetCurSel _keep};

(_display displayCtrl PAC_IDC_MG_COUNT) ctrlSetStructuredText parseText format ["<t size='0.8'>%1 of %2</t>", count _rows, _total];
