#include "script_component.hpp"

#include "XEH_PREP.hpp"

// The console's own state. Everything the panel keeps in admp_* is set up in
// XEH_postInit; these four are ghost's, and they are set here so a keybind
// pressed in the first second of a mission finds them.
GVAR(listFilter) = "";
GVAR(mapFilter) = "players";
GVAR(execTarget) = 1;
GVAR(endArmedAt) = -1e9;

#include "initSettings.inc.sqf"

// THE ADMIN BUTTON, between SETTINGS and HIDE ALL under the message reader.
//
// REGISTERED FROM HERE, not from ghost_tacpad_apps, and that is a licence
// decision as much as a design one: this addon is GPL-3 and the suite is
// APL-SA, so the suite must not carry a line that knows this console exists.
// The dependency points this way instead - the GPL addon asks the APL shell for
// a slot, using its public FUNC(register), which is what that function is for.
//
// The condition is checked on every map open, so a player granted admin
// mid-mission gets the button on their next one and nobody else ever sees it.
["admin", "", DEFAULT_ADMIN, FUNC(panelAdmin), {}, 2, false, {
    (missionNamespace getVariable [QGVAR(enabled), true]) && {[player] call FUNC(isAdmin)}
}] call EFUNC(tacpad,register);
