#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structFields

Description:
    THE ONE TABLE of what each editable structure section holds. The config
    loader, the server's editor door and the client's editor screen all read
    it, so a field added here is read from config, coerced on save, and
    offered in the editor with one change.

        [field, kind, label, hint]
        kind   "t" text | "a" array (comma-separated in the editor) |
               "n" number
        label  "" = kept but not shown in the editor (the editor has three
               free rows; ID and NAME are fixed)

    `name` is not listed - every section has it and the editor has its own
    row for it.

Parameters:
    0: Section <STRING>

Returns:
    The field table, [] for an unknown section <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_section", "", [""]]];

switch (_section) do {
    // insignia rides along unlabelled: a texture path is not typed in game
    case "ranks": {[
        ["abbrev", "t", "ABBREV", "e.g. SGT"],
        ["payGrade", "t", "PAY GRADE", "e.g. E-4 - shown on the operator file"],
        ["armaRank", "t", "ARMA RANK", "PRIVATE CORPORAL SERGEANT LIEUTENANT CAPTAIN MAJOR COLONEL"],
        ["insignia", "t", "", ""]
    ]};
    // colour: the squad panel draws a man's skill letters in it, so MED and
    // CLS read green down the whole section at a glance (user, 2026-09-05).
    case "skills": {[
        ["abbrev", "t", "ABBREV", "2-4 letters for the squad panel, e.g. MED; empty = the id in capitals"],
        ["effects", "a", "EFFECTS", "comma-separated: medic:2, engineer:1, eod:1, trait:isJFO, var:name=value"],
        ["color", "t", "COLOUR", "R,G,B 0-255 for the skill letters on the squad panel, e.g. 76,175,80; empty = the ink colour"]
    ]};
    case "awards": {[
        ["type", "t", "TYPE", "badge / ribbon / medal - free text"],
        ["image", "t", "IMAGE", "texture path, may be empty"],
        ["campaign", "t", "CAMPAIGN", "may be empty"]
    ]};
    case "statuses": {[]};
    case "admins": {[]};
    // THE PROMOTION FORMULA AS DATA (2026-09-05). Every item is {name, value};
    // the id says what the value means - a weight (hour, op, serviceMonth,
    // gradeMonth, training, award = points per unit) or a rung on the ladder
    // (rank_<rankId> = points required to hold that rank). FUNC(promotionPoints)
    // reads it; nothing is hard-coded.
    case "promotion": {[
        ["value", "n", "VALUE", "points per unit for a weight (hour, op, serviceMonth, gradeMonth, training, award); points required for a rank_<rankId> rung"]
    ]};
    // THE TRAINING CATALOGUE (2026-09-05): the courses a unit runs, one item
    // each, keyed by course id. The player page's TRAINING dropdown lists them;
    // a course held is logged on the record by its id, so a rename follows.
    case "trainings": {[
        ["category", "t", "CATEGORY", "free text that groups the list - Medical, Leadership, Fires, Aviation ..."],
        ["description", "t", "DESCRIPTION", "one line - what the course covers"]
    ]};
    // A net's id is its name on the rail and the radio; NAME is the
    // description. ORDER is its place on the rail, first = 0.
    case "nets": {[
        ["order", "n", "ORDER", "position on the rail and in the mailbox list, 0 first"]
    ]};
    // A role's id is its Dynamic_Roles class. THE WHOLE ROLE lives here -
    // the three gates the editor shows, and every property the group menu,
    // the slot setup, the net and tile gates read (the mission's
    // config_roles.hpp shape, by the same names - see
    // ghostD_groups_fnc_roleFields). The unlabelled fields ride along
    // untouched when the editor saves.
    // A ROLE IS EIGHT SCREENS ON ONE SECTION (2026-09-09), the same eight the
    // website has: identity, gates, nets, tiles, traits, variables, loadout,
    // arsenal. Every screen returns the WHOLE field list and labels only its
    // own three - an unlabelled field is not drawn and rides along untouched
    // when the editor saves, which is how a role's loadout survives somebody
    // editing its tiles. FUNC(structBase) maps every one of them to "roles".
    case "roles";
    case "roles_gates";
    case "roles_nets";
    case "roles_tiles";
    case "roles_traits";
    case "roles_vars";
    case "roles_loadout";
    case "roles_arsenal";
    case "roles_items": {
        private _labels = createHashMapFromArray (switch (_section) do {
            case "roles_gates": {[
                ["minRank", ["MIN RANK", "a rank id, e.g. sergeant; empty = no rank gate"]],
                ["requiredSkills", ["REQUIRED SKILLS", "skill ids, comma-separated, e.g. pilot; empty = no skill gate"]],
                ["uids", ["LOCKED TO", "Steam ids, comma-separated; non-empty = only these players (and admin grants) may take it"]]
            ]};
            case "roles_nets": {[
                ["nets", ["NETS", "TAC//MSG nets he reads, comma-separated - C2, FIRES.cas. A net he is not on is a net he cannot see; there is no 'all nets'"]]
            ]};
            case "roles_tiles": {[
                ["tiles", ["TILES", "TAC//PAD tiles he sees, comma-separated - drones, jam, hack, weather, timer, radio, intel, support, pac. A tile not listed is not drawn and its app cannot be reached"]]
            ]};
            case "roles_traits": {[
                ["traits", ["TRAITS", "engine traits, comma-separated - UAVHacker, audibleCoef. Anything a PAC skill owns (medic, engineer, EOD) is applied by PAC afterwards and ignored here"]]
            ]};
            case "roles_vars": {[
                ["customVariables", ["CUSTOM VARIABLES", "setVariable on the man when he slots in, comma-separated - draWhitelisted, isISR, isJFO"]]
            ]};
            case "roles_loadout": {[
                ["defaultLoadout", ["DEFAULT LOADOUT", "what he spawns in, as the array a config file writes. CAPTURE takes it off you as you stand"]]
            ]};
            case "roles_arsenal": {[
                ["groupArsenal", ["GROUP ARSENAL", "a named arsenal this role also draws from - Arsenal_Banshee. Empty for the common one only"]],
                ["arsenalWeapons", ["WEAPONS", "classnames only this role may draw, comma-separated. ON TOP of the common arsenal, never instead of it"]],
                ["arsenalMagazines", ["MAGAZINES", "classnames, comma-separated"]]
            ]};
            case "roles_items": {[
                ["arsenalItems", ["ITEMS", "classnames, comma-separated - ACE_Vector, ACRE_PRC117F"]],
                ["arsenalBackpacks", ["BACKPACKS", "classnames, comma-separated"]]
            ]};
            // "roles" itself is the identity screen; NAME is the box above.
            default {[
                ["description", ["DESCRIPTION", "what the job is - read on the slot card"]],
                ["icon", ["ICON", "a paa path; empty is fine"]],
                ["slotTag", ["SLOT TAG", "how the HUD labels the slot; empty means the class name"]]
            ]};
        });
        private _all = [
            ["name", "t"], ["description", "t"], ["icon", "t"], ["slotTag", "t"],
            ["minRank", "t"], ["requiredSkills", "a"], ["uids", "a"],
            ["nets", "a"], ["tiles", "a"], ["traits", "a"], ["customVariables", "a"],
            ["defaultLoadout", "a"], ["groupArsenal", "t"],
            ["arsenalWeapons", "a"], ["arsenalMagazines", "a"],
            ["arsenalItems", "a"], ["arsenalBackpacks", "a"],
            ["arsenalWhitelist", "a"], ["defaultSkills", "a"]
        ];
        _all apply {
            _x params ["_field", "_kind"];
            private _lab = _labels getOrDefault [_field, ["", ""]];
            [_field, _kind, _lab # 0, _lab # 1]
        };
    };
    // THE UNIT'S OWN TRAIT NAMES (2026-09-09). setUnitTrait's third argument
    // says whether a name is a custom one, and a name with that flag wrong is
    // thrown away without a word. Listing them means a role ticks a name off a
    // list instead of anybody having to remember which is which.
    case "traits": {[
        ["label", "t", "SHOWN AS", "what the role editor calls it - 'DRA whitelisted'"],
        ["kind", "t", "KIND", "bool for a yes/no, number for a value. Anything else is read as bool"],
        ["help", "t", "WHAT IT DOES", "one line, read by whoever is deciding whether a role should have it"]
    ]};
    default {[]};
};
