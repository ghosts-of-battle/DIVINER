#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_conditionalPFEH

Description:
    Runs a CBA per-frame handler only while a condition holds, then runs an exit
    block once and removes itself. Stands in for a `while` loop in unscheduled
    environments, where you cannot suspend.

Parameters:
    _codeToRun  : CODE   - run each tick while _condition is true.
    _parameters : ANY    - passed as _this to _codeToRun, _exitCode and _condition. (default: [])
    _exitCode   : CODE   - run once when _condition first fails. (default: {})
    _condition  : CODE   - must return BOOL. (default: {true})
    _delay      : NUMBER - seconds between ticks, 0 = every frame. (default: 0)

Returns:
    NUMBER - the CBA PFEH handle.

Example:
    [
        { hint str (_this select 0) },
        [player],
        { hint format ["Player %1 has died", _this select 0] },
        { alive player },
        2
    ] call ghostD_common_fnc_conditionalPFEH;

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params [
    ["_codeToRun", {}, [{}]],
    ["_parameters", []],
    ["_exitCode", {}, [{}]],
    ["_condition", {true}, [{}]],
    ["_delay", 0, [0]]
];

[
    {
        params ["_args", "_handle"];
        _args params ["_codeToRun", "_parameters", "_exitCode", "_condition"];

        if (_parameters call _condition) then {
            _parameters call _codeToRun;
        } else {
            [_handle] call CBA_fnc_removePerFrameHandler;
            _parameters call _exitCode;
            TRACE_1("conditionalPFEH removed",_handle);
        };
    },
    _delay,
    [_codeToRun, _parameters, _exitCode, _condition]
] call CBA_fnc_addPerFrameHandler
