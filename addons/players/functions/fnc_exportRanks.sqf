#include "script_component.hpp"
/*
    File: fn_player_exportRanks.sqf
    Author: YonV
    Description: Builds a config_ranks.hpp Dynamic_Ranks block from the live rank map
        (YMF_playerRanks), grouping every ranked Steam ID under its rank class in config
        order. Names of currently-connected players are added as inline comments. Offline
        UIDs (from config or earlier promotions) are preserved, so pasting the block back
        never drops anyone. Copies the block to the clipboard, echoes it to systemChat, and
        logs it to the RPT. Returns the block as a STRING.

    Arguments:
    None

    Example:
    call ghostD_players_fnc_exportRanks;

    Public: Yes
*/

private _tab = toString [9];
private _nl = toString [10];

// config order - Private is the default_rank and is NOT a class in Dynamic_Ranks
private _order = ["Colonel","Major","Captain","Lieutenant","Sergeant","Corporal"];

// uid -> name for connected players (best-effort name comments)
private _names = createHashMap;
{
    private _uid = getPlayerUID _x;
    if (_uid isNotEqualTo "") then {_names set [_uid, name _x]};
} forEach allPlayers;

private _map = missionNamespace getVariable ["YMF_playerRanks", createHashMap];

// group uids by rank class (case-insensitive), skipping Private/unknown
private _byRank = createHashMap;
{
    private _uid = _x;
    private _rank = _map get _uid;
    private _idx = _order findIf {toUpper _x isEqualTo toUpper _rank};
    if (_idx isEqualTo -1) then {continue};
    (_byRank getOrDefault [_order select _idx, [], true]) pushBack _uid;
} forEach keys _map;

// build the config block
private _out = "";
{
    private _rankName = _x;
    private _ids = _byRank getOrDefault [_rankName, []];
    _out = _out + _tab + format ["class %1 {", _rankName] + _nl;
    if (_ids isEqualTo []) then {
        _out = _out + _tab + _tab + "uids[] = {};" + _nl;
    } else {
        _out = _out + _tab + _tab + "uids[] = {" + _nl;
        {
            private _uid = _x;
            private _sep = [",",""] select (_forEachIndex >= (count _ids) - 1);
            private _pname = _names getOrDefault [_uid, ""];
            private _cmt = if (_pname isEqualTo "") then {""} else {format [" /* %1 */", _pname]};
            _out = _out + _tab + _tab + _tab + format ["""%1""%2%3", _uid, _sep, _cmt] + _nl;
        } forEach _ids;
        _out = _out + _tab + _tab + "};" + _nl;
    };
    _out = _out + _tab + "};" + _nl;
} forEach _order;

copyToClipboard _out;

// echo to chat and RPT
{systemChat _x} forEach (_out splitString _nl);
diag_log "===== YMF RANK EXPORT (paste into config_ranks.hpp >> Dynamic_Ranks) =====";
{diag_log _x} forEach (_out splitString _nl);
diag_log "===== END RANK EXPORT =====";
["Rank Export", "Ranks copied to clipboard - also echoed above and in your RPT.", NOTE_INFO] call GHOSTFUNC(notify,notify);

_out
