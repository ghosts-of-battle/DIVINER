#include "..\script_component.hpp"
/*
 * Author: YonV
 * Mirrors the quick connect settings into profileNamespace, where the main menu
 * can reach them.
 *
 * WHY A MIRROR AT ALL. Extended_PreInit_EventHandlers fires when a MISSION
 * starts, not when the game does - so on the main menu, which is the first thing
 * drawn after launch, the CBA settings variables simply do not exist yet.
 * profileNamespace does: it is loaded with the profile, before any of this, and
 * it survives a restart. So the settings are the place they are edited and the
 * profile is the place the menu reads.
 *
 * WHAT THAT COSTS. A change made in Addon Options reaches the main menu on the
 * NEXT launch, not this one. For a server address that is the right way round -
 * the alternative is a menu that cannot be configured at all, which is what this
 * replaces.
 *
 * ONE ENTRY PER BUTTON, WHOLE. Each is [name, address, port, password, colour],
 * so the only thing the display side has to know is which index is which button
 * - 0 left, 1 centre, 2 right. Parallel lists that had to stay in step were the
 * alternative, and they stay in step exactly until somebody adds a fourth
 * server.
 *
 * WRITTEN ONCE PER SETTINGS INIT and once per change, not per frame - the
 * settings' onChange calls this, and so does XEH_preInit through
 * EFUNC(common,runAfterSettingsInit) so that a player who never opens Addon
 * Options still gets the shipped defaults into their profile.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// getVariable rather than the GVARs: this is called from the settings' own
// onChange, and a read that assumes the variable is there is a read that throws
// the one time it is not.
//
// Trimmed, because an address with a space on the end connects to nothing and
// says nothing about why.
private _servers = [
    [ARR_5(QGVAR(server1Name),QGVAR(server1Address),QGVAR(server1Port),QGVAR(server1Password),QGVAR(server1Colour))],
    [ARR_5(QGVAR(server2Name),QGVAR(server2Address),QGVAR(server2Port),QGVAR(server2Password),QGVAR(server2Colour))],
    [ARR_5(QGVAR(server3Name),QGVAR(server3Address),QGVAR(server3Port),QGVAR(server3Password),QGVAR(server3Colour))]
] apply {
    _x params ["_nameVar", "_addressVar", "_portVar", "_passwordVar", "_colourVar"];

    // A port that is not a port lands as 0, which is how a button is removed -
    // so a typo takes the button away rather than dialling nowhere.
    private _port = parseNumber (trim (missionNamespace getVariable [_portVar, ""]));

    // A COLOR setting hands back [r,g,b,a] already; the default here is only
    // for the case where the setting has not been registered yet.
    private _colour = missionNamespace getVariable [_colourVar, [0.8, 0.263, 0.192, 1]];
    if (!(_colour isEqualTypeArray [0,0,0,0])) then {_colour = [0.8, 0.263, 0.192, 1]};

    [
        trim (missionNamespace getVariable [_nameVar, ""]),
        trim (missionNamespace getVariable [_addressVar, ""]),
        [_port, 0] select (_port < 1 || _port > 65535),
        missionNamespace getVariable [_passwordVar, ""],
        _colour
    ]
};

profileNamespace setVariable [QGVAR(servers), _servers];

saveProfileNamespace;

TRACE_1("Quick connect cached",_servers);

nil
