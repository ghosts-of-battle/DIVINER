#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structMe

Description:
    The spare button, which does one of two things depending on the screen.

    ADD ME (admins): puts the player's own Steam id and name into the
    fields, ready to SAVE - the first admin on a fresh database.

    CAPTURE (a role's default loadout): puts the loadout the player is
    WEARING into the loadout box, written the way a config file writes it.
    Typing a nested array into an Arma edit box is not something anybody
    should be asked to do; going to an arsenal, dressing the man and
    pressing this is how a loadout actually gets built. Nothing is written
    until SAVE.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(structDisplay), displayNull];
if (isNull _display) exitWith {};
if (GVAR(structSection) isEqualTo "roles_loadout") exitWith {
    if (GVAR(structId) isEqualTo "") exitWith {
        ["TAC//PAC", "Pick a role first - CAPTURE fills that role's loadout.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
    };
    // WHICH BOX IS THE LOADOUT is not assumed: the screen's field table says,
    // and a change to that table must not silently write into the wrong one.
    private _at = GVAR(structFields) findIf {(_x # 1) isEqualTo "defaultLoadout"};
    if (_at < 0) exitWith {};
    private _edit = _display displayCtrl ([PAC_IDC_ST_F1, PAC_IDC_ST_F2, PAC_IDC_ST_F3] select _at);

    // The array getUnitLoadout answers, written as a config writes it: braces,
    // double quotes, no spaces. FUNC(structSave) sends the text and
    // FUNC(adminStructure) parses it back.
    _edit ctrlSetText ([getUnitLoadout player] call FUNC(sqfText));
    ["TAC//PAC", format ["Loadout captured for %1. SAVE to keep it.", GVAR(structId)], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
};

if (GVAR(structSection) isNotEqualTo "admins") exitWith {};

(_display displayCtrl PAC_IDC_ST_ID) ctrlSetText ([player] call FUNC(uid));
(_display displayCtrl PAC_IDC_ST_NAME) ctrlSetText name player;
