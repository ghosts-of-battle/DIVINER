#include "script_component.hpp"
/*
    File: fnc_fileFed.sqf
    Author: YonV
    Description: Which STRUCTURE sections this mission's config\ folder feeds,
        and therefore which ones the in-game editor must not offer.

        WHY. With sync = "off" there is no database. Every section then comes
        from a file in config\ - config_roles.hpp, config_pac.hpp,
        arsenal\config_arsenal_common.hpp - and THE GAME CANNOT WRITE A FILE.
        An editor for one of those is a screen that takes a change, saves it
        into the profile, and is silently overruled by the file on the next
        mission start. So it is not offered (user, 2026-09-09: "if no mongo
        hide the in gsme ui elemtnes to edit fucking mongo for each config
        file").

        WITH A DATABASE it is the other way round: the file is the fallback and
        the document wins, so every section stays editable and nothing here
        hides anything.

        WHAT STAYS EITHER WAY. The roster - MY RECORD, ROSTER, OPORD - is the
        store, not the structure, and is untouched by this. So is STRUCTURE IN
        / OUT: the profile's own data still has to be able to leave and come
        back ("you need to export the data save in the mission profile and be
        able to export it and inport it").

        The list is worked out ONCE, at boot, from what FUNC(loadStructure)
        found - before the profile's edits and the service's documents are
        merged over the top, which is the only moment the mission's own
        contribution can still be seen on its own.

    Parameters:
        0: STRING - a section id, or a role sub-screen id ("roles_gates")

    Returns:
        BOOL - true when this mission's files feed it AND there is no database,
               so the editor for it must not be shown

    Example:
        if (["ranks"] call FUNC(fileFed)) then {_sections deleteAt _i};
*/

params [["_section", "", [""]]];

// A DATABASE MAKES EVERY SECTION EDITABLE. The document wins over the file, so
// an edit sticks and the screen is honest.
if ((GVAR(settings) getOrDefault ["sync", "off"]) isEqualTo "service") exitWith {false};

// The role screens are seven views of one section.
private _base = [_section] call FUNC(structBase);

(_base in (missionNamespace getVariable [QGVAR(fromMission), []]))
