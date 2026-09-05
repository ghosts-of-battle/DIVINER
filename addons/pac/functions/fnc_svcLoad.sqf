#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_svcLoad

Description:
    Asks the pacdb extension for the unit's store and waits for the answer.
    Server only, scheduled (it waits). See tools/pacdb/README.md for the
    extension, the service behind it, and the protocol.

    THE EXTENSION ANSWERS THROUGH A CALLBACK, in chunks, and the handler in
    XEH_postInit assembles them into GVAR(svcChunks) and sets
    GVAR(svcState). This waits on that state, up to PAC_SVC_TIMEOUT seconds.
    A service that is down costs that wait and nothing else: the caller
    falls back to the file or profile copy.

Parameters:
    0: Document key, or a key prefix for "list" <STRING> (optional, default
       settings.unitId - the store)
    1: Verb <STRING> - "get" (a document) | "list" (the keys under the
       prefix, as an array) (optional, default "get")

Returns:
    [document or empty hashmap, status] - status "ok" | "empty" | "error"
    | "off" <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {[createHashMap, "off"]};
if ((GVAR(settings) getOrDefault ["sync", "off"]) isNotEqualTo "service") exitWith {[createHashMap, "off"]};

params [["_key", "", [""]], ["_fn", "get", [""]]];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
if (_key isEqualTo "") then {_key = _unit};
if (_unit isEqualTo "") exitWith {
    WARNING("sync = service but settings.unitId is empty - nothing to ask for");
    [createHashMap, "error"]
};

// A SERVER WITHOUT THE EXTENSION is told once and every later ask answers
// "error" at once, so the boot does not wait a timeout per document for a
// library that is not there (tools/pacdb/README.md says where it goes).
if (GVAR(svcMissing)) exitWith {[createHashMap, "error"]};

GVAR(svcState) = "waiting";
GVAR(svcChunks) = [];

("ghostd_pacdb" callExtension [_fn, [_key]]) params [["_text", "", [""]], ["_code", 0, [0]], ["_err", 0, [0]]];
if (_err isNotEqualTo 0 || _text isNotEqualTo "queued") exitWith {
    WARNING_3("pacdb extension did not take the request (error %1, code %2, said '%3') - is ghostd_pacdb_x64.dll (Windows) / ghostd_pacdb_x64.so (Linux) in the mod folder or the server's Arma root, and is the database address set (CBA setting 'Database', or GHOSTD_PACDB_URL / pacdb.json)?",_err,_code,_text);
    if (_err isNotEqualTo 0) then {GVAR(svcMissing) = true};
    GVAR(svcState) = "error";
    [createHashMap, "error"]
};

private _t0 = diag_tickTime;
waitUntil {
    sleep 0.2;
    GVAR(svcState) isNotEqualTo "waiting" || {diag_tickTime - _t0 > PAC_SVC_TIMEOUT}
};

switch (GVAR(svcState)) do {
    case "ok": {
        ([GVAR(svcChunks) joinString ""] call FUNC(fromJson)) params ["_doc", "_ok", "_where"];
        if (_ok && _fn isEqualTo "list" && {_doc isEqualType []}) exitWith {[_doc, "ok"]};
        if (_ok && {_doc isEqualType createHashMap}) exitWith {[_doc, "ok"]};
        WARNING_1("service answered with something that is not a store document (JSON error at %1)",_where);
        [createHashMap, "error"]
    };
    case "empty": {[createHashMap, "empty"]};
    case "waiting": {
        WARNING_1("service did not answer within %1 s - using the local copy",PAC_SVC_TIMEOUT);
        GVAR(svcState) = "error";
        [createHashMap, "error"]
    };
    default {[createHashMap, "error"]};
};
