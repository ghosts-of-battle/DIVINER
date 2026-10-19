#include "script_component.hpp"
/*
    File: fnc_docsSort.sqf
    Author: YonV
    Description: Sort documents (hashmaps) by one string field. `sort` on
        [[key, hashmap], ...] pairs would compare the hashmaps when two keys
        tie, which it cannot do - so the index is the tie-breaker and the
        documents are picked back out afterwards.

    Parameters:
        0: Documents <ARRAY of HASHMAP>
        1: Field <STRING>
        2: Ascending <BOOL> (optional, default true)

    Returns:
        The documents, sorted <ARRAY>
*/

params [["_docs", [], [[]]], ["_field", "", [""]], ["_asc", true, [true]]];

private _pairs = [];
{
    private _k = if (_x isEqualType createHashMap) then {_x getOrDefault [_field, ""]} else {""};
    if !(_k isEqualType "") then {_k = str _k};
    _pairs pushBack [_k, _forEachIndex];
} forEach _docs;
_pairs sort _asc;
_pairs apply {_docs # (_x # 1)}
