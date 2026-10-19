#include "script_component.hpp"
/*
    File: fnc_uiSectionLabel.sqf
    Author: YonV
    Description: What a structure section is called on screen, and the one
        line under it - the website's labels and blurbs for the same
        documents, so Configs reads the same in both places.

    Parameters:
        0: Section <STRING>

    Returns:
        [label, blurb] <ARRAY>
*/

params [["_sec", "", [""]]];

switch (_sec) do {
    case "ranks": {["Ranks", "The ladder. Abbrev, pay grade, which Arma rank each maps to, and the points required to reach it."]};
    case "skills": {["Skills", "What a man can hold. Effects are what having it does: medic:1, engineer:1, eod:1, var:<name>."]};
    case "awards": {["Awards", "Badges, ribbons and medals an admin can give."]};
    case "statuses": {["Statuses", "Active, on leave, reserve - one word an operator is in."]};
    case "promotion": {["Promotion", "The weights points are earned at, and the rung each rank sits on (rank_<id>)."]};
    case "trainings": {["Trainings", "Courses a man can be put through."]};
    case "settings": {["Settings", "autoSlot 1 or 0 - slotMatch role or slot - savedLoadouts a count, 0 for off."]};
    case "admins": {["Admins", "Who may open this. A Steam id and a name."]};
    case "traits": {["Custom variables", "The unit's own variables a role can set on a man - name, yes/no or a number, what it does."]};
    case "nets": {["Messaging nets", "The mailboxes a role reads. Order is the order they list in."]};
    case "schemes": {["Colour schemes", "Ground, ink and accent for the tacpad."]};
    case "motorpool": {["Motorpool", "Headings and the vehicle classes under them."]};
    case "cosmetics": {["Vehicle cosmetics", "Per vehicle class: a name, an icon, and the SQF that dresses it."]};
    case "logistics": {["Logistics crates", "Each crate and what is in it - a classname and a count per line."]};
    case "pylons": {["Pylon presets", "Per vehicle class: presets, each a name and its magazines."]};
    case "arsenal": {["Common arsenal", "The lists every arsenal box starts from."]};
    case "welcome": {["Welcome screen", "Title, subtitle and the text shown on joining."]};
    case "templates": {["Report deck", "The message and task cards the tacpad composes."]};
    case "opords": {["Operation orders", "The orders the mission can run."]};
    default {[_sec, ""]};
};
