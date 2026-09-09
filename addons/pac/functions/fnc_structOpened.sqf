#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structOpened

Description:
    onLoad of the structure editor: fills the section combo and shows the
    section that was open last (ranks the first time).

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
if !([player] call ghostD_adminpanel_fnc_isAdmin) exitWith {closeDialog 2};

private _display = uiNamespace getVariable [QGVAR(structDisplay), displayNull];
if (isNull _display) exitWith {};

private _combo = _display displayCtrl PAC_IDC_ST_SECTION;
lbClear _combo;
private _sel = 0;
{
    _x params ["_id", "_label"];
    private _i = _combo lbAdd _label;
    _combo lbSetData [_i, _id];
    if (_id isEqualTo GVAR(structSection)) then {_sel = _i};
// ONE SECTION, ONE SCREEN - and a role is eight screens, the same eight the
// website has. They all read and write the "roles" section; FUNC(structBase)
// is what maps the screen id back to it.
} forEach [
    ["ranks", "RANKS"],
    ["skills", "SKILLS"],
    ["awards", "AWARDS"],
    ["statuses", "STATUSES"],
    ["nets", "NETS"],
    ["traits", "CUSTOM TRAITS"],
    ["roles", "ROLE - IDENTITY"],
    ["roles_gates", "ROLE - WHO MAY TAKE IT"],
    ["roles_nets", "ROLE - MESSAGING NETS"],
    ["roles_tiles", "ROLE - TAC//PAD TILES"],
    ["roles_traits", "ROLE - TRAITS"],
    ["roles_vars", "ROLE - CUSTOM VARIABLES"],
    ["roles_loadout", "ROLE - DEFAULT LOADOUT"],
    ["roles_arsenal", "ROLE - ARSENAL"],
    ["promotion", "PROMOTION"],
    ["trainings", "TRAINING"],
    ["admins", "ADMINS"]
];
_combo lbSetCurSel _sel;     // fires structSection
