#include "script_component.hpp"

// THE PANEL'S OWN SETUP, VERBATIM FROM ITS fn_init - see the note at the top of
// the file. It is included rather than PREP'd because it is a block of variable
// assignments and not a function, and because keeping it recognisable as the
// mission's own init is what makes a fix upstream a re-copy.
#include "XEH_postInit_panel.inc.sqf"

// --- Admin surface ----------------------------------------------------------
// #ghost commands, which ghost_common already gates on the admin flag and
// swallows for everyone else. They exist because a console you cannot open is a
// console you cannot diagnose - and because the list this addon reads is the
// MISSION's, so "why am I not an admin" has an answer that is not "rebuild".

["admin.list", "who this mission lets into TAC//ADMIN", {
    private _ids = missionNamespace getVariable ["admp_authorisedIDs", []];
    if (_ids isEqualTo []) exitWith {"no admin list - see CfgGhostAdmins in description.ext"};
    format ["%1 uid(s): %2", count _ids, _ids joinString ", "]
}] call EFUNC(common,addDebugCommand);

["admin.reload", "re-read the mission's admin list", {
    admp_authorisedIDs = [] call FUNC(adminList);
    {admp_authorisedIDs pushBackUnique _x} forEach ["_SP_AI_", "_SP_PLAYER_"];
    format ["%1 uid(s) loaded", count admp_authorisedIDs]
}] call EFUNC(common,addDebugCommand);

["admin.me", "whether this machine's player is an admin, and why", {
    params ["", "_caller"];

    private _listed = (getPlayerUID _caller) in (missionNamespace getVariable ["admp_authorisedIDs", []]);
    private _flag = _caller getVariable [QEGVAR(common,isAdmin), false];

    format [
        "uid %1 - on the mission list: %2, ghost admin flag: %3",
        getPlayerUID _caller, _listed, _flag
    ]
}] call EFUNC(common,addDebugCommand);
