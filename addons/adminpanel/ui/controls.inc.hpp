// THE CONSOLE'S CONTROL TEMPLATES.
//
// The panel arrived with its own RscADMP* set - rounded buttons, orange fills,
// PuristaBold, a 3px border on everything - which is a different mod's look. The
// classes keep their names so the dialog reads the same as upstream, and every
// one of them is restyled to what the rest of the suite is drawn in: a flat
// ground, an exact rule, RobotoCondensed, and no corner radius anywhere.
//
// COLOURS HERE ARE ONLY THE OPENING FRAME. Every one is set again at runtime
// from the player's tacpad scheme - see FUNC(style) - so switching to Night
// Olive in the settings screen repaints this screen too. What is baked in is the
// dark scheme, so a display that somehow opens before the theme is read still
// looks like the suite rather than like nothing.

class RscText;
class RscPicture;
class RscButton;
class RscEdit;
class RscCombo;
class RscListBox;
class RscStructuredText;
class RscMapControl;
class RscCheckBox;

class RscADMPText: RscText {
    idc = -1;
    style = ST_LEFT;
    font = "RobotoCondensed";
    sizeEx = "0.8 * (0.025 * safezoneH)";
    colorText[] = {0.90, 0.90, 0.88, 1};
    colorBackground[] = {0, 0, 0, 0};
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

class RscADMPPicture: RscPicture {
    idc = -1;
    text = "";
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// A BUTTON IS A LABELLED RECTANGLE. Not a bevel, not a gradient, not a rounded
// corner: the suite's outlined cell, filling to the accent when the pointer is
// on it. offsetX/Y are zeroed because the engine's default shadow offset is the
// one thing that makes a flat button look like it is coming apart.
class RscADMPButton: RscButton {
    idc = -1;
    style = ST_CENTER;
    font = "RobotoCondensedBold";
    sizeEx = "0.8 * (0.025 * safezoneH)";
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    colorText[] = {0.90, 0.90, 0.88, 1};
    colorActive[] = {1, 1, 1, 1};
    colorBackground[] = {0.10, 0.10, 0.10, 1};
    colorBackgroundActive[] = {0.5, 0.5, 0.5, 0.30};
    colorBackgroundDisabled[] = {0.10, 0.10, 0.10, 1};
    colorDisabled[] = {0.55, 0.55, 0.53, 1};
    colorFocused[] = {0.5, 0.5, 0.5, 0.16};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0, 0, 0, 0};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.06, 1};
    soundEnter[] = {"", 0, 1};
    soundPush[] = {"", 0, 1};
    soundEscape[] = {"", 0, 1};
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

class RscADMPEdit: RscEdit {
    idc = -1;
    style = ST_LEFT;
    font = "RobotoCondensed";
    sizeEx = "0.8 * (0.025 * safezoneH)";
    colorText[] = {0.90, 0.90, 0.88, 1};
    colorSelection[] = {0.85, 0.28, 0.20, 0.5};
    colorDisabled[] = {0.55, 0.55, 0.53, 1};
    colorBackground[] = {0.07, 0.07, 0.07, 1};
    autocomplete = "";
    canModify = 1;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

class RscADMPCombo: RscCombo {
    idc = -1;
    style = ST_LEFT;
    font = "RobotoCondensed";
    sizeEx = "0.8 * (0.025 * safezoneH)";
    colorText[] = {0.90, 0.90, 0.88, 1};
    colorBackground[] = {0.07, 0.07, 0.07, 1};
    colorSelect[] = {0, 0, 0, 1};
    colorSelectBackground[] = {0.5, 0.5, 0.5, 0.35};
    colorScrollbar[] = {0.85, 0.28, 0.20, 1};
    colorDisabled[] = {0.55, 0.55, 0.53, 1};
    arrowEmpty = "\A3\ui_f\data\gui\rscCommon\rscCombo\arrow_combo_ca.paa";
    arrowFull = "\A3\ui_f\data\gui\rscCommon\rscCombo\arrow_combo_active_ca.paa";
    wholeHeight = 0.3;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// ROW SELECTION IS A FILL, NOT A TINT. The design's selected row is solid accent
// with the ground colour written on it, which is the one place in the suite
// where the text goes dark - and it is why the list reads at a glance.
class RscADMPListbox: RscListBox {
    idc = -1;
    style = ST_LEFT;
    font = "RobotoCondensed";
    sizeEx = "0.8 * (0.025 * safezoneH)";
    rowHeight = "1.15 * (0.025 * safezoneH)";
    colorText[] = {0.90, 0.90, 0.88, 1};
    colorBackground[] = {0.07, 0.07, 0.07, 1};
    colorSelect[] = {0.05, 0.05, 0.05, 1};
    colorSelect2[] = {0.05, 0.05, 0.05, 1};
    colorSelectBackground[] = {0.5, 0.5, 0.5, 0.35};
    colorSelectBackground2[] = {0.5, 0.5, 0.5, 0.35};
    colorDisabled[] = {0.55, 0.55, 0.53, 1};
    period = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;

    class ScrollBar {
        color[] = {0.55, 0.55, 0.53, 1};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {0.30, 0.30, 0.30, 1};
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        width = 0;
        height = 0;
        scrollSpeed = 0.01;
    };
};

class RscADMPStructuredText: RscStructuredText {
    idc = -1;
    size = "0.8 * (0.025 * safezoneH)";
    colorBackground[] = {0, 0, 0, 0};
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;

    class Attributes {
        font = "RobotoCondensed";
        color = "#E6E6E1";
        align = "left";
        shadow = 0;
    };
};

class RscADMPMapControl: RscMapControl {
    idc = -1;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

class RscADMPCheckbox: RscCheckBox {
    idc = -1;
    colorBackground[] = {0.07, 0.07, 0.07, 1};
    colorFocused[] = {0.5, 0.5, 0.5, 0.16};
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};
