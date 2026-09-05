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
    case "skills": {[
        ["abbrev", "t", "ABBREV", "2-4 letters for the squad panel, e.g. MED; empty = the id in capitals"],
        ["effects", "a", "EFFECTS", "comma-separated: medic:2, engineer:1, eod:1, trait:isJFO, var:name=value"]
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
    case "roles": {[
        ["minRank", "t", "MIN RANK", "a rank id, e.g. sergeant; empty = no rank gate"],
        ["requiredSkills", "a", "REQUIRED SKILLS", "skill ids, comma-separated, e.g. pilot; empty = no skill gate"],
        ["uids", "a", "LOCKED TO", "Steam ids, comma-separated; non-empty = only these players (and admin grants) may take it"],
        ["description", "t", "", ""],
        ["icon", "t", "", ""],
        ["nets", "a", "", ""],
        ["tiles", "a", "", ""],
        ["traits", "a", "", ""],
        ["customVariables", "a", "", ""],
        ["defaultLoadout", "a", "", ""],
        ["groupArsenal", "t", "", ""],
        ["arsenalWeapons", "a", "", ""],
        ["arsenalMagazines", "a", "", ""],
        ["arsenalItems", "a", "", ""],
        ["arsenalBackpacks", "a", "", ""],
        ["arsenalWhitelist", "a", "", ""],
        ["defaultSkills", "a", "", ""],
        ["slotTag", "t", "", ""]
    ]};
    default {[]};
};
