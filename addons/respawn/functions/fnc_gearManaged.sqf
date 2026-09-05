#include "..\script_component.hpp"
/*
 * Author: YonV
 * Whether this addon's respawn template is the one dressing a player when he
 * comes back.
 *
 * ONE SYSTEM DRESSES THE RESPAWN. Two of them strip each other and the player
 * arrives naked, so whatever is about to put a loadout on a respawned man has to
 * ask first whether something already has. FUNC(onPlayerRespawn) restores the
 * loadout saved at mission start, and it only runs when the mission actually
 * selected our template - so the answer is whether that template is in play, not
 * whether this addon happens to be loaded.
 *
 * WHERE THIS CAME FROM. It was EFUNC(adapter_alive,respawnGearManaged), which
 * asked ALiVE whether its multispawn was restoring gear. The question outlived
 * the answer: something in this mod still needs to know, and the addon that
 * knows is the one doing the restoring.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Whether the respawn template will dress the player itself <BOOL>
 *
 * Example:
 * if (!(call ghostD_respawn_fnc_gearManaged)) then { dress him yourself };
 *
 * Public: Yes
 */

// EVERY LIST, because respawnTemplates can be given once for the mission or per
// side, and a mission that sets only respawnTemplatesWest is the ordinary case
// for a one-sided op.
private _templates = [];

{
    _templates append getArray (missionConfigFile >> _x);
} forEach [
    "respawnTemplates",
    "respawnTemplatesWest", "respawnTemplatesEast",
    "respawnTemplatesGuer", "respawnTemplatesCiv"
];

QGVAR(default) in _templates
