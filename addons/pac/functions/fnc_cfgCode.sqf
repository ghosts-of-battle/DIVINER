#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_cfgCode

Description:
    Compile a config document the unit keeps as SQF - <unit>.logistics,
    <unit>.pylons, <unit>.skill - and hand back the compiled code.

    THE ONE PLACE A BAD SAVE CAN REACH THE GAME. Everywhere else in this system
    a wrong value is a wrong value; here it is code, typed on a website, with no
    hemtt check between the box and the server. So this compiles defensively:
    an empty document, a document that will not compile, or one that throws on
    compile all return {} and log why. The caller then keeps whatever the
    mission's own file gave it.

    WHY IT IS ALLOWED AT ALL. config_logistics.sqf and config_pylons.sqf are
    tables written as code, and a unit that ships no config folder has nowhere
    else to put them. The alternative - inventing a data format for each - is a
    bigger and more surprising thing than an editor that says "this is code".

Parameters:
    0: Document <STRING> - "logistics", "pylons", "skill"
    1: What to put in front of it <STRING> (optional, default "") - the skill
       block wants "private _unit = _this; " so _unit is set

Returns:
    The compiled code <CODE>, or {} when there is nothing usable

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_doc", "", [""]], ["_wrap", "", [""]]];

if (_doc isEqualTo "") exitWith {{}};

private _sec = GVAR(structure) getOrDefault [_doc, createHashMap];
if !(_sec isEqualType createHashMap) exitWith {{}};

private _text = _sec getOrDefault ["code", ""];
if !(_text isEqualType "") exitWith {{}};
if (_text isEqualTo "") exitWith {{}};

// compile throws on bad syntax rather than returning nil, so it is caught -
// a mission must not fail to start because somebody left a bracket open.
private _code = {};
private _ok = false;
try {
    _code = compile (_wrap + _text);
    _ok = true;
} catch {
    ERROR_2("<unit>.%1 will not compile - keeping the mission's own file. %2",_doc,_exception);
};

if (!_ok) exitWith {{}};

INFO_2("<unit>.%1 compiled from the database (%2 characters)",_doc,count _text);
_code
