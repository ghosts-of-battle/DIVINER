#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_svcSections

Description:
    EVERY CONFIG THE DATABASE HOLDS, in one table - the document's section
    name, the shape it is stored in, and the setting a MISSION uses to name
    which version of it to run.

    THIS TABLE IS THE CONTRACT. A section missing from it is a document the
    game never reads however carefully somebody fills it in on the website -
    which is exactly what had happened to cosmetics, logistics, pylons and
    the AI skill block (2026-09-09): the readers existed, the documents
    existed, and nothing carried them across.

    THE VERSION SETTING IS THE MISSION'S (user, 2026-09-09: "part of the
    conection to mongo I want the mission config to define the orbat template
    to use, and all the common templates used in the mission"). A mission
    names the versions it runs in its own CfgGFA_PAC settings; the database
    holds the default for a mission that does not care. See
    FUNC(structureAdopt), which is where the mission's choice is kept.

    SHAPES:
        "items"    {section, items: {id: {...}}}   - most of them
        "lists"    {section, lists: {name: [...]}} - the arsenal's shape;
                   these also carry named VARIANTS, fetched by prefix
        "code"     {section, code: "..."}          - a block of SQF
        "special"  its own shape and its own fetch - the ORBAT and the
                   welcome screen, handled by name in FUNC(svcStructure)

Parameters:
    None

Returns:
    [[section, shape, settingName], ...] <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

[
    // ---- the unit's own records. No version setting: a unit has one ladder,
    // one set of skills and one admin list, whatever mission is running.
    ["admins",         "items", ""],
    ["settings",       "items", ""],
    ["ranks",          "items", ""],
    ["skills",         "items", ""],
    ["awards",         "items", ""],
    ["statuses",       "items", ""],
    ["promotion",      "items", ""],
    ["trainings",      "items", ""],
    ["traits",         "items", ""],

    // ---- the mission's config. Every one of these was a file in config\ and
    // every one can have versions, because two missions on one unit do not
    // want the same nets, the same motorpool or the same paint.
    ["nets",           "items", "currentNets"],
    ["radio",          "items", "currentRadio"],
    ["templates",      "items", "currentTemplates"],       // the report deck
    ["schemes",        "items", "currentSchemes"],         // TAC//PAD colours
    ["motorpool",      "items", "currentMotorpool"],
    ["cosmetics",      "items", "currentCosmetics"],
    ["arsenal",        "lists", "currentArsenal"],
    // NO RADAR. The radar network is a CBA setting - ghostD_Settings_radarNetwork
    // and ghostD_Settings_radarClasses - and nothing else (user, 2026-09-09).
    // <unit>.radar is dead data; delete it.
    ["logistics",      "code",  "currentLogistics"],
    ["pylons",         "code",  "currentPylons"],
    ["skill",          "code",  "currentSkill"]

    // "orbat" and "welcome" are fetched by name in FUNC(svcStructure): neither
    // is {items}, {lists} or {code}, and both need a fallback to the common
    // document when the named version is not there.
]
