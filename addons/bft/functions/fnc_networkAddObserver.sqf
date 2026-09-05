#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Puts a group on a network as an observer: it sees everyone transmitting on
 * that net and gives nothing back. The groups it is watching see its marker
 * faded, so nobody is watched without knowing it.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Network name <STRING>
 *
 * Return Value:
 * The group's listen list <ARRAY>
 *
 * Example:
 * [group this, "recon"] call ghostD_bft_fnc_networkAddObserver
 *
 * Public: Yes
 */

params [["_group", grpNull, [grpNull]], ["_netName", "", [""]]];

if (isNull _group || _netName isEqualTo "") exitWith {[]};

private _codes = _group getVariable [QGVAR(decryptCodes), []];
_codes pushBackUnique _netName;
_group setVariable [QGVAR(decryptCodes), _codes, true];

_codes
