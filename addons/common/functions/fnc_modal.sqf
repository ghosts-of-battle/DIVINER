#include "script_component.hpp"
/*
 * Author: veteran29
 * Open modal dialog
 *
 * Arguments:
 * 0: Title <STRING,ARRAY>
 *  1: Left title  <STRING>
 *  2: Right title <STRING>
 * 1: Dialog content (lines) <STRING,ARRAY>
 *  1: Line 1 <ARRAY>
 *  2: Line 2 <ARRAY>
 *  ...
 *  N: Line N <ARRAY>
 *   1: Line text or path to image <STRING>
 *   2: Text size mutiplier, default 1 <NUMBER>
 *   3: RGB or RGBA color <ARRAY>
 *   4: Alignmnet 0 - left, 1 - center, 2 - right, default 1 <NUMBER>
 * 3: Use wider dialog <BOOL>
 * 4: On open callback <CODE>
 *   Arguments passed: [_display, _contentGroupCtrl, _textCtrl, _leftTitleCtrl, _rightTitleCtrl]
 * 5: On close callback <CODE>
 *   Arguments passed: [_display, _exitCode]
 *
 * Return Value:
 * None
 *
 * Example:
 *  ["Some title", "This is a content."] call ghostD_common_fnc_modal
 *  [
 *      ["Left", "Right"],
 *      [
 *          "This is a content.",
 *          ["Second bigger red line", 2, [1,0,0], 2],
 *          ["Green line", 1, [0,1,0], 0],
 *          [getText (configFile >> "CfgWeapons" >> currentWeapon player >> "picture"), 5]
 *      ],
 *      true, {systemChat "Open!"}, {systemChat "Close!"}
 *  ] call ghostD_common_fnc_modal
 *
 * Public: Yes
 */

params [
    ["_title", "", ["", []]],
    ["_content", [], ["", []]],
    ["_wide", false, [false]],
    ["_onOpen", {}, [{}]],
    ["_onClose", {}, [{}]]
];


private _modalClass = [QGVAR(Modal), QGVAR(ModalWide)] select _wide;
private _display = (uiNamespace getVariable "RscDisplayMission") createDisplay _modalClass;

private _leftTitleCtrl = _display displayCtrl IDC_MODAL_TITLE_L;
_leftTitleCtrl ctrlSetText (_title param [0, "", [""]]);

private _rightTitleCtrl = _display displayCtrl IDC_MODAL_TITLE_R;
_rightTitleCtrl ctrlSetText (_title param [1, "", [""]]);

_display setVariable [QGVAR(onClose), _onClose];

private _contentGroupCtrl = _display displayCtrl IDC_MODAL_GROUP_CONTENT;
private _textCtrl = _contentGroupCtrl controlsGroupCtrl IDC_MODAL_CONTENT_TEXT;

[_display, _contentGroupCtrl, _textCtrl, _leftTitleCtrl, _rightTitleCtrl] call {
    private ["_display", "_contentGroupCtrl", "_textCtrl"];
    _this call _onOpen;
};

if !(_content isEqualType []) then {
    _content = [_content];
};

private _composition = [];

// create structured text composition
{
    _composition pushBack lineBreak;

    _x params [
        ["_text", "", ["", 0]],
        ["_size", 1, [0]],
        ["_color", [], [[]], [3,4]],
        ["_alignment", 1, [0]]
    ];

    if (_text isEqualType 0) then {
        _text = str _text;
    };

    _size = _size * 0.65 / (getResolution select 5);

    _color params [
        ["_r", 1, [0]],
        ["_g", 1, [0]],
        ["_b", 1, [0]],
        ["_a", 1, [0]]
    ];
    _color = [_r, _g, _b, _a] call BIS_fnc_colorRGBAtoHTML;

    private _alignment = switch (_alignment) do {
        case 0: {"left"};
        case 1: {"center"};
        case 2: {"right"};
        default {
            ERROR_1("Invalid alignment! %1",_alignment);
            "center"
        };
    };

    private _isImage = toLower _text select [count _text - 4] in [".paa", ".jpg"];
    if (_isImage) then {
        _composition pushBack parseText format ["<img align='%4' size='%2' color='%3' image='%1'/>", _text, _size, _color, _alignment];
    } else {
        _composition pushBack parseText format ["<t align='%4' size='%2' color='%3'>%1</t>", _text, _size, _color, _alignment];
    };

} forEach _content;

// remove leading lineBreak
_composition deleteAt 0;

_textCtrl ctrlSetStructuredText composeText _composition;

// LET A LONG BRIEFING SCROLL (user, 2026-09-01: "include a scroll bar if the
// text is longer"). A controls group scrolls what its controls cover, not what
// their text says, so a text control left at the panel's height simply clipped
// everything past the last visible line. Grown to the height of its own text,
// the group has something to scroll and draws its bar; a briefing that fits
// leaves the control the size config gave it and no bar appears.
//
// The width is not touched here - config already keeps the bar's column clear
// (see RscModal.hpp), so this height is measured at the width the text keeps
// and needs no second pass to correct for a rewrap.
private _needed = ctrlTextHeight _textCtrl;
private _panelH = (ctrlPosition _contentGroupCtrl) select 3;

if (_needed > _panelH) then {
    (ctrlPosition _textCtrl) params ["_textX", "_textY", "_textW"];
    _textCtrl ctrlSetPosition [_textX, _textY, _textW, _needed];
    _textCtrl ctrlCommit 0;
};

nil
