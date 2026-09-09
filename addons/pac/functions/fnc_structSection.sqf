#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structSection

Description:
    Fills the editor for the section picked in the combo: the item list on
    the left, the field labels on the right (they differ per section), and
    the hint. Also called when the server republishes the structure while
    the editor is open, so an edit made elsewhere shows up.

    THE FIELD TABLE is the one place that knows which section has which
    fields, matched to FUNC(adminStructure)'s on the server.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(structDisplay), displayNull];
if (isNull _display) exitWith {};

private _combo = _display displayCtrl PAC_IDC_ST_SECTION;
private _sel = lbCurSel _combo;
if (_sel >= 0) then {GVAR(structSection) = _combo lbData _sel};
private _section = GVAR(structSection);
// The screen and the section it edits are two different things: a role has
// eight screens and they all read and write "roles". See FUNC(structBase).
private _base = [_section] call FUNC(structBase);

// [label, field, hint] x3 per section, from the one table - the labelled
// entries, padded to the three rows the screen has.
private _fields = (([_section] call FUNC(structFields)) select {(_x # 2) isNotEqualTo ""}) apply {[_x # 2, _x # 0, _x # 3]};
while {count _fields < 3} do {_fields pushBack ["", "", ""]};
GVAR(structFields) = _fields;

{
    _x params ["_labelIdc", "_editIdc", "_i"];
    (_fields # _i) params ["_label", "", "_hint"];
    (_display displayCtrl _labelIdc) ctrlSetStructuredText parseText format ["<t size='0.85'>%1</t>", _label];
    private _edit = _display displayCtrl _editIdc;
    _edit ctrlShow (_label isNotEqualTo "");
    _edit ctrlSetTooltip _hint;
} forEach [[PAC_IDC_ST_F1_LABEL, PAC_IDC_ST_F1, 0], [PAC_IDC_ST_F2_LABEL, PAC_IDC_ST_F2, 1], [PAC_IDC_ST_F3_LABEL, PAC_IDC_ST_F3, 2]];

(_display displayCtrl PAC_IDC_ST_ID_LABEL) ctrlSetStructuredText parseText (switch (_base) do {
    case "admins": {"<t size='0.85'>STEAM ID</t>"};
    case "nets": {"<t size='0.85'>NET</t>"};
    case "roles": {"<t size='0.85'>CLASS</t>"};
    case "traits": {"<t size='0.85'>TRAIT</t>"};
    case "promotion": {"<t size='0.85'>KEY</t>"};
    case "trainings": {"<t size='0.85'>COURSE</t>"};
    default {"<t size='0.85'>ID</t>"};
});

// THE NAME BOX BELONGS TO THE SCREEN THAT NAMES THE THING. A role's identity
// screen names it; its tiles screen does not, and showing an empty box there
// invites somebody to type in it and wipe the name. FUNC(structSave) only
// sends the box when it is shown.
private _namesIt = !(_section in ["roles_gates", "roles_nets", "roles_tiles",
    "roles_traits", "roles_vars", "roles_loadout", "roles_arsenal", "roles_items"]);
{(_display displayCtrl _x) ctrlShow _namesIt} forEach [PAC_IDC_ST_NAME, PAC_IDC_ST_NAME_LABEL];

// The spare button is ADD ME on the admin list and CAPTURE on a role's
// loadout - two things a screen can do that nothing else can.
private _spare = _display displayCtrl PAC_IDC_ST_ME;
_spare ctrlShow (_section in ["admins", "roles_loadout"]);
_spare ctrlSetText (["ADD ME", "CAPTURE"] select (_section isEqualTo "roles_loadout"));
_spare ctrlSetTooltip (["Admins: put your own Steam id and name in the fields",
    "Take the loadout off yourself as you stand and put it in the box. Nothing is written until SAVE"]
    select (_section isEqualTo "roles_loadout"));

private _hint = switch (_section) do {
    case "ranks": {"A rank maps to one of Arma's seven through ARMA RANK - that is what setRank, the scoreboard and Role_Access read. Any number of unit ranks may map to one. The ID is what every player record holds: renaming one in use orphans the players who hold it."};
    case "skills": {"A skill is a name for a set of effects, applied to the player and cleared when the skill is taken away. Effects: medic:N (ACE class 0/1/2), engineer:N, eod:N, trait:NAME (unit variable true, broadcast), var:NAME=VALUE."};
    case "awards": {"Awards are given from the roster page and stamped with the date and who gave them. TYPE, IMAGE and CAMPAIGN are for display and are free text."};
    case "statuses": {"A status is a label on the roster - Active, Leave, Reserve - and what it means is the unit's business. Sample data uses index 1 for 'on leave' and 2 for 'reserve'."};
    case "roles_gates": {"WHO MAY TAKE THE SLOT. All three are optional and empty means no gate. MIN RANK is a rank id and the player's rank must map to the same or a higher Arma rank. REQUIRED SKILLS are skill ids he must hold. LOCKED TO is Steam ids: anything here makes the slot theirs alone, an admin grant aside."};
    case "roles_nets": {"THE NETS HE READS in TAC//MSG, comma-separated. A net he is not on is a net he cannot see - there is no 'all nets', and that IS the privacy rule. Sub-nets are the dotted ones and are separate: listing C2 does not give him C2.reports. The names come from the NETS section."};
    case "roles_tiles": {"THE TAC//PAD TILES HE SEES, comma-separated: drones, jam, hack, weather, timer, radio, intel, support, pac. A tile not listed is not drawn at all and the app behind it cannot be reached - clicking a tile is the only way in. If NO role in the unit lists any, the gate is off entirely and everybody sees every tile."};
    case "roles_traits": {"ENGINE TRAITS - setUnitTrait - comma-separated. The engine's own are audibleCoef, camouflageCoef, loadCoef, medic, engineer, explosiveSpecialist and UAVHacker; anything else is one of the unit's own, listed under CUSTOM TRAITS. Whatever a PAC skill owns is applied by PAC after the role and is skipped here, so set those as skills."};
    case "roles_vars": {"CUSTOM VARIABLES - setVariable on the man when he slots in, comma-separated: draWhitelisted, isISR, isJFO. Not the same thing as a trait, and not the same thing as a skill."};
    case "roles_loadout": {"WHAT HE SPAWNS IN, as the array a config file writes. CAPTURE takes the loadout off you exactly as you stand - go to an arsenal, dress the man, come back and press it - which is how you actually build one. Nothing is written until SAVE."};
    case "roles_arsenal": {"WHAT HE MAY DRAW, on top of the common arsenal and his platoon's and his squad's. They ADD UP; nothing here takes anything away. GROUP ARSENAL names a shared list this role also draws from. The two boxes are this role's own, for the kit the job needs and nobody else gets."};
    case "roles_items": {"The other two arsenal lists - items and backpacks - on their own screen because three boxes is all there is. Same rule: on top of everything else, never instead of it."};
    case "traits": {"THE UNIT'S OWN TRAIT NAMES, as opposed to the seven the engine already has. A role assigns them by name and the custom flag setUnitTrait needs is set from this list - which is the argument that silently throws a trait away when it is wrong. KIND is bool for a yes/no or number for a value."};
    case "roles": {"THE WHOLE ROLE LIVES HERE - name, description, icon, nets, tiles, traits, variables, default loadout and arsenal arrays (config_roles.hpp's shape) plus its gates - and the group menu reads it from here. The id is the class name and keeps its spelling. This screen is its IDENTITY; the seven ROLE screens below it in the section list are the rest, one subject each - the same eight the website has. Everything a screen does not show rides along untouched, so editing a role's tiles cannot lose its loadout. REMOVE puts a role the mission still declares back to the mission's own."};
    case "nets": {"The named nets TAC//MSG opens a mailbox for and the rail draws - C2, FIRES.cas, the four platoon nets - by the name the radio plan and the roles' nets[] use. NAME is the description, ORDER the place on the rail. The squad nets are not listed: they exist because the squads do."};
    case "admins": {"Who may open the admin console and the TAC//PAC pages, in addition to the mission's own admin list and Ghost's admin flag. Keyed by Steam id. You cannot remove yourself. With 'Everyone is an admin (testing)' on, this list is not consulted."};
    case "trainings": {"THE TRAINING CATALOGUE - every course the unit runs, one entry each. The player page's TRAINING dropdown lists these; ADD there logs the course on the man's record with the day. The COURSE id is what the record keeps, so renaming a course renames it on every record; removing one leaves the entries, shown by id. CATEGORY groups the list, DESCRIPTION is the tooltip. The promotion formula counts entries, whatever the course."};
    case "promotion": {"THE PROMOTION FORMULA - the points a player earns and the rungs of the ladder, as data you edit here. WEIGHTS, points per unit: hour (per hour on the server), op (per op attended), serviceMonth (per 30 days since enlisted), gradeMonth (per 30 days since promoted), training (per training entry), award (per award). RUNGS: rank_<rank id> = points required to hold that rank, e.g. rank_sergeant = 100. The player page and the operator file show the total, the breakdown and the next rung. A key that is not listed counts as 0."};
    default {""};
};
(_display displayCtrl PAC_IDC_ST_HINT) ctrlSetStructuredText parseText format ["<t size='0.8'>%1<br/><br/>Changes are written by the server after an admin check, kept in the unit's database (or the profile without one), and sent to every client at once.</t>", _hint];

// ---- the list ----------------------------------------------------------------
private _list = _display displayCtrl PAC_IDC_ST_LIST;
private _items = GVAR(structure) getOrDefault [_base, createHashMap];
private _rows = [];
{
    _rows pushBack [format ["%1  (%2)", _y getOrDefault ["name", _x], _x], _x];
} forEach _items;
_rows sort true;

lbClear _list;
private _keep = -1;
{
    _x params ["_text", "_id"];
    private _i = _list lbAdd _text;
    _list lbSetData [_i, _id];
    if (_id isEqualTo GVAR(structId)) then {_keep = _i};
} forEach _rows;
if (_keep >= 0) then {_list lbSetCurSel _keep};

(_display displayCtrl PAC_IDC_ST_COUNT) ctrlSetStructuredText parseText format ["<t size='0.8'>%1 in %2</t>", count _rows, _base];
