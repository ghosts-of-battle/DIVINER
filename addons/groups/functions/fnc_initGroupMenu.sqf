#include "script_component.hpp"
/*
    Author: YMF (restyled to the ghost suite)

    Description:
        Opens the role selection screen, builds the platoon tab row and fills
        the tree behind it.

        THE TREE ROWS FOLLOW THE THEME. They were hard-coded [1,1,1,alpha] -
        white, on whatever ground the scheme happened to be - so on a light
        scheme the whole list vanished. The colour comes from
        YMF_groupMenu_theme, which ghostD_groups_fnc_styleGroupMenu leaves behind when the
        display opens.

        THE TABS ARE A VIEW, NOT A RULE (user, 2026-09-01). They decide which
        squads the tree draws and nothing else: the roles, the order, the
        conditions, who may take what and the OPEN count at the top right all
        still come off the whole of Dynamic_Groups. See FUNC(platoons) for the
        config and FUNC(fillRoleTree) for the draw.

        THIS FUNCTION DOES NOT DRAW A TAB. It shows the controls the mission
        earned, hides the rest, puts the tree under them and hands off to
        FUNC(selectPlatoon), which writes every label on the row. A tab is
        structured text carrying its own colours, so there is no half-drawn
        state worth writing here and then correcting there.

        THE ROW WRAPS AND THE TREE MOVES WITH IT. Four tabs to a row (gui.hpp);
        a fifth platoon opens a second row and the tree drops by exactly one row
        to make space for it. The drop is measured off the two rows' real
        positions rather than written as a number, so the player's UI scale -
        already applied to every control by the style pass in the display's
        onLoad - is carried with it.

        A MISSION WITH NO Platoons CLASS IS UNCHANGED. Every tab control is
        hidden and the tree is put back to the full height it had before there
        was a row above it, so the screen is the one that shipped.

    Parameters:
        NONE

    Returns:
        NOTHING
*/

disableSerialization;

// THE UNIT'S ROLES MAY STILL BE ON THEIR WAY. On a mission whose roles live
// in TAC//PAC's database this machine has none until the server's structure
// arrives, and a tree drawn now would be squads full of nameless slots. Wait
// for the boot gate once - then draw whatever there is, so a unit with no
// roles at all is not locked out of the screen.
if (!isNil "ghostD_pac_fnc_whenReady" && {!(missionNamespace getVariable ["ghostD_pac_ready", false])} && {count ([] call FUNC(roles)) isEqualTo 0} && {isNil QGVAR(waitedForPac)}) exitWith {
    GVAR(waitedForPac) = true;
    hintSilent "TAC//PAC - waiting for the unit's roles from the server ...";
    [{[] call ghostD_groups_fnc_initGroupMenu}, 60] call ghostD_pac_fnc_whenReady;
};

private _display = createDialog ["YMF_groupMenu",true];
private _tree = _display displayCtrl 1500;

private _factionName = ([] call FUNC(orbat)) # 3;
(_display displayCtrl 1000) ctrlSetText toUpper format ["%1  ROLE SELECTION",_factionName];

// Set by the style pass in the display's onLoad, which has already run by here.
(missionNamespace getVariable ["YMF_groupMenu_theme", [[0.05,0.05,0.05,1],[0.90,0.90,0.88,1],[0.85,0.28,0.20,1],[0.35,0.35,0.34,1]]]) params ["_ground","_ink","_accent"];

private _tabs = call FUNC(platoons);
GVAR(platoonTabs) = _tabs;

// Both controls of a tab, hidden or shown together - a label with no button
// over it is a chip that cannot be clicked, and a button with no label under
// it is an invisible one that can.
private _fnc_showTab = {
    params ["_i", "_show"];
    {
        private _ctrl = _display displayCtrl (_x + _i);
        if (!isNull _ctrl) then {_ctrl ctrlShow _show};
    } forEach [IDC_PLT_TAB, IDC_PLT_TAB_BTN];
};

// ------------------------------------------------------------- no tabs --
if (_tabs isEqualTo []) exitWith {
    for "_i" from 0 to (MAX_PLT_TABS - 1) do {[_i, false] call _fnc_showTab};

    // THE ROW'S HEIGHT GOES BACK TO THE TREE. Read off the tab that would have
    // sat above it rather than written as a number, so the player's UI scale -
    // already applied to every control by the style pass - is carried with it.
    private _tab = _display displayCtrl IDC_PLT_TAB_BTN;
    if (!isNull _tab) then {
        (ctrlPosition _tab) params ["", "_ty"];
        (ctrlPosition _tree) params ["_x0", "_y0", "_w0", "_h0"];
        _tree ctrlSetPosition [_x0, _ty, _w0, _h0 + (_y0 - _ty)];
        _tree ctrlCommit 0;
    };

    [_tree, []] call FUNC(fillRoleTree);
    [_tree, tvCurSel _tree] call FUNC(onGroupMenuTvSelectChange);
};

// ---------------------------------------------------------------- tabs --
for "_i" from 0 to (MAX_PLT_TABS - 1) do {
    [_i, _i < count _tabs] call _fnc_showTab;
};

// THE TREE DROPS ONE ROW PER EXTRA ROW OF TABS. The pitch is the distance
// between the first tab of row one and the first tab of row two, taken off the
// controls themselves so it is already in the player's scale.
private _rows = ceil ((count _tabs) / PLT_TABS_PER_ROW);
if (_rows > 1) then {
    private _row1 = _display displayCtrl IDC_PLT_TAB_BTN;
    private _row2 = _display displayCtrl (IDC_PLT_TAB_BTN + PLT_TABS_PER_ROW);
    if (!isNull _row1 && {!isNull _row2}) then {
        private _pitch = ((ctrlPosition _row2) # 1) - ((ctrlPosition _row1) # 1);
        private _drop = (_rows - 1) * _pitch;

        (ctrlPosition _tree) params ["_x0", "_y0", "_w0", "_h0"];
        _tree ctrlSetPosition [_x0, _y0 + _drop, _w0, _h0 - _drop];
        _tree ctrlCommit 0;
    };
};

// OPEN ON THE TAB THE PLAYER IS ALREADY ON. A man who has a slot and reopens
// this screen to change it should be looking at his own squad, not at whichever
// platoon happens to be first. Falls through to the first tab when he holds
// nothing, which is every man on mission start.
private _start = 0;
private _mine = "";
{
    _x params ["_groupName","","","","_units"];
    if (player in _units) exitWith {_mine = toUpper _groupName};
} forEach YMF_dynamicGroups;

if (_mine isNotEqualTo "") then {
    private _at = _tabs findIf {_mine in (_x select 1)};
    if (_at > -1) then {_start = _at};
};

[_start] call FUNC(selectPlatoon);
