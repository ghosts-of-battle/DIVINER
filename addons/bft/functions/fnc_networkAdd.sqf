#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Puts a group on a network as a full member: it transmits its position to
 * everyone on that net, and it can see everyone else who transmits on it.
 *
 * For a group that should listen without being seen, use FUNC(networkAddObserver).
 *
 * A group that has never been given a net transmits on its own side's name, so
 * adding the first net takes it OFF the side net unless the side is added back.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Network name <STRING>
 *
 * Return Value:
 * The group's transmit list <ARRAY>
 *
 * Example:
 * [group this, "recon"] call ghostD_bft_fnc_networkAdd
 *
 * Public: Yes
 */

params [["_group", grpNull, [grpNull]], ["_netName", "", [""]]];

if (isNull _group || _netName isEqualTo "") exitWith {[]};

private _codes = _group getVariable [QGVAR(encryptCodes), []];
_codes pushBackUnique _netName;
_group setVariable [QGVAR(encryptCodes), _codes, true];

_codes
