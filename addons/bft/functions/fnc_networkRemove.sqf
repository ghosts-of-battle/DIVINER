#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Takes a group off a network it transmits on. "*" takes it off all of them,
 * which leaves it transmitting on nothing - invisible to everyone, including its
 * own side, until it is given a net back.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Network name, "*" for all <STRING> (default: "*")
 *
 * Return Value:
 * The group's transmit list <ARRAY>
 *
 * Example:
 * [group this, "recon"] call ghostD_bft_fnc_networkRemove
 *
 * Public: Yes
 */

params [["_group", grpNull, [grpNull]], ["_netName", "*", [""]]];

if (isNull _group) exitWith {[]};

private _codes = _group getVariable [QGVAR(encryptCodes), []];

if (_netName isEqualTo "*") then {
    _codes = [];
} else {
    private _index = _codes find _netName;
    if (_index > -1) then {
        _codes deleteAt _index;
    };
};

_group setVariable [QGVAR(encryptCodes), _codes, true];

_codes
