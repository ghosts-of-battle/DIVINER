/*
    Author: JohnnyShootos (Edited by TheTimidShade)

    Description:
        Updates admin panel player list and group assignment combo box and reselects selected unit

    Parameters:
        NONE
        
    Returns:
        NOTHING
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;

//#define IDC_ADMINPANEL_PLAYER_GROUP_COMBO    5425

// get admin panel display
private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

// get player list listbox and group assignment combo box and populate
private _admp_playerlist_listbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYERLIST_LISTBOX;
//private _admp_player_groupcombo = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_GROUP_COMBO;
admp_playerlist_playerArray = [] call admp_fnc_getPlayerList;
admp_playerlist_playerCount = count admp_playerlist_playerArray; // save player count to check if playerlist update is necessary

lbClear _admp_playerlist_listbox;
//lbClear _admp_player_groupcombo;

// What the filter box has in it, if anything. Matched below rather than in a
// separate pass so a row's VALUE is still its index in the FULL array - every
// action on this screen resolves its target through that index.
private _filter = toLower (missionNamespace getVariable [QGVAR(listFilter), ""]);
private _shown = 0;

{
    private _name = name _x;
    private _displayName = name _x;
    private _playerArrayIndex = _forEachIndex;

    if (_filter isNotEqualTo "" && {(toLower _name) find _filter < 0}) then {continue};
    _shown = _shown + 1;

    if (_x call admp_fnc_isAdmin) then {_displayName = _displayName + "*"};

    // append rank (short US style) after the name, e.g. "YonV* [SGT]"
    //
    // THE RANK IS THE MISSION'S, IF IT HAS ONE. This was a straight call to the
    // Roomba framework's own rank map, which does not exist in an addon that
    // ships to every mission - and a nil call here emptied the whole list. With
    // no rank framework loaded the engine's own rank is used instead, which is
    // the same three letters for the same men in most missions.
    private _rank = if (isNil "ghostD_players_fnc_getRank") then {
        [rank _x] call EFUNC(tacpad,rankShort)
    } else {
        [_x, "USA"] call ghostD_players_fnc_getRank
    };
    if (_rank isNotEqualTo "") then {
        _displayName = format ["%1 [%2]", _displayName, _rank];
    };

    private _entryIndex = _admp_playerlist_listbox lbAdd _displayName;
    _admp_playerlist_listbox lbSetData [_entryIndex, _name];
    _admp_playerlist_listbox lbSetValue [_entryIndex, _playerArrayIndex]; // set value to index from player array so unit can be referenced

    /*
    _entryIndex = _admp_player_groupcombo lbAdd _name;
    _admp_player_groupcombo lbSetData [_entryIndex, _name];
    _admp_player_groupcombo lbSetValue [_entryIndex, _playerArrayIndex];
    */

} forEach (admp_playerlist_playerArray);
lbSort _admp_playerlist_listbox;
//lbSort _admp_player_groupcombo;

// THE TWO COUNTS. The one above the list is what the list is showing, which
// under a filter is not the same number as the one in the title bar - and an
// admin who cannot see that seven of thirty are hidden will conclude the server
// emptied out.
private _countCtrl = _admp_display displayCtrl IDC_ADMINPANEL_PLAYERLIST_COUNT;
if (!isNull _countCtrl) then {
    _countCtrl ctrlSetStructuredText parseText format [
        "<t font='RobotoCondensedBold' size='0.8' align='right'>%1</t>",
        [str _shown, format ["%1 / %2", _shown, admp_playerlist_playerCount]] select (_filter isNotEqualTo "")
    ];
};

private _headCount = _admp_display displayCtrl IDC_ADMINPANEL_HEADER_PLAYERCOUNT;
if (!isNull _headCount) then {
    _headCount ctrlSetStructuredText parseText format [
        "<t font='RobotoCondensedBold' size='0.8' align='right'>PLAYERS %1</t>",
        admp_playerlist_playerCount
    ];
};

private _foundUnitPlayer = false;
//private _foundUnitGroup = false;
// if the previosly selected unit can be found in the list, select them
for "_i" from 0 to (lbSize _admp_playerlist_listbox - 1) do {
    if (_admp_playerlist_listbox lbData (_i) == admp_playerlist_selectedPlayer) then {
        _admp_playerlist_listbox lbSetCurSel _i; // select the player
        _foundUnitPlayer = true;
    };
    /*
    if (_admp_player_groupcombo lbData (_i) == admp_groupcombo_selectedPlayer) then {
        _admp_player_groupcombo lbSetCurSel _i; // select the player
        _foundUnitGroup = true;
    };
    */
};

if (!_foundUnitPlayer) then {_admp_playerlist_listbox lbSetCurSel 0;}; // if can't find the unit, set to first in list
//if (!_foundUnitGroup) then {_admp_player_groupcombo lbSetCurSel 0;}; // if can't find the unit, set to first in list

// set map_markersActive variable to false to tell admp_fnc_updateMapMarkers to reload markers
admp_map_markersActive = false;
