// Control templates the panels are built from at runtime. They live at config
// root rather than inside a display class because ctrlCreate resolves a class
// name against configFile, and these have to be creatable on the vanilla map
// display - which is not ours to add a controls block to.
//
// NOTHING HERE CARRIES A COLOUR. Every colour is set at runtime by
// FUNC(theme), so a scheme change repaints what is already on screen instead of
// needing a rebuild.
//
// There is no separate header class: a header is a fill with a hit button over
// it, like everything else that is both painted and pressed.

class RscText;
class RscStructuredText;
class RscControlsGroupNoScrollbars;
class RscControlsGroup;
class RscButton;
class RscPicture;
class RscEdit;

// The frame. A controls group so its children scroll and clip with it, and so
// moving the panel is one ctrlSetPosition rather than one per child.
class GVAR(panel): RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// Border and ground are two flat rectangles rather than a bordered texture:
// zero radius, exact 2px, and both are recoloured independently by the theme.
class GVAR(fill): RscText {
    idc = -1;
    text = "";
    colorBackground[] = {0, 0, 0, 0};
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// Uppercase, tracked, flush left - the kicker style the whole system is set in.
class GVAR(label): RscStructuredText {
    idc = -1;
    size = "1.45 * (pixelH * pixelGrid)";
    class Attributes {
        font = "RobotoCondensedBold";
        color = "#FFFFFF";
        align = "left";
        shadow = 0;
    };
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// Panel bodies are scrolling groups: a 16-man roster and a net's traffic both
// outgrow their frame, and the design draws a square scrollbar for exactly that
// reason.
class GVAR(body): RscControlsGroup {
    idc = -1;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// THE REPLY BOX, AS A RUNTIME CONTROL. It used to be declared into the
// reader's dialog, and a config-declared control is created BEFORE every
// runtime one - so the reader's own screen group, which is ctrlCreate'd
// over the whole dialog, sat on top of it and swallowed every click. The
// box could never be typed into. It is ctrlCreate'd into the screen's
// content group by FUNC(readerInput) now, last - the same home as the
// compose pane's edits, which is what makes it clickable at all.
class GVAR(input): RscEdit {
    idc = -1;
    colorBackground[] = {0, 0, 0, 0};
    sizeEx = "0.028 * safezoneH";
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// THE SAME BODY WITHOUT THE BARS, for the chromeless strips. A one-cell
// button whose hit area is deliberately taller than the fitted body counts
// as content overflowing a scrolling group, and the engine drew it a
// scrollbar - the bars under ADMIN and HIDE ALL in the screenshot. A button
// has nothing to scroll.
class GVAR(bodyPlain): RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// A row, a tile and a button are the same control with different geometry - all
// three are a flat ground with text on it that reacts to the mouse.
class GVAR(cell): RscStructuredText {
    idc = -1;
    size = "1.45 * (pixelH * pixelGrid)";
    class Attributes {
        font = "RobotoCondensed";
        color = "#FFFFFF";
        align = "left";
        shadow = 0;
    };
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// THE HITBOX, and the reason everything is clickable at all.
//
// Structured text and fills raise no ButtonClick, so nothing a panel paints can
// be the thing that is pressed. Anything that reacts to a mouse gets one of
// these laid over it: a real button, completely transparent, CARRYING THE
// HANDLER ITSELF. The text underneath stays presentation and the button stays
// interaction.
//
// The handler is the part that was missing. These were created and left bare
// while the clicks were meant to be read by a dispatcher on the map control -
// which the button consumed the event before ever reaching. See FUNC(hotspot).
// HOVER IS HERE AND NOWHERE ELSE. A button shows colorBackgroundActive while
// the mouse is on it and no script command changes that, so the one hover the
// whole suite has is this mid-grey wash - lighter on a dark scheme, darker on
// a light one, never another scheme's accent. Focus stays clear so the last
// thing pressed does not sit lit.
class GVAR(hit): RscButton {
    idc = -1;
    text = "";
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    colorBackground[] = {0, 0, 0, 0};
    colorBackgroundActive[] = {0.5, 0.5, 0.5, 0.22};
    colorBackgroundDisabled[] = {0, 0, 0, 0};
    colorText[] = {0, 0, 0, 0};
    colorActive[] = {0, 0, 0, 0};
    colorDisabled[] = {0, 0, 0, 0};
    colorFocused[] = {0, 0, 0, 0};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0, 0, 0, 0};
    soundClick[] = {"", 0, 1};
    soundEnter[] = {"", 0, 1};
    soundPush[] = {"", 0, 1};
    soundEscape[] = {"", 0, 1};
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

// An image. Used for the one icon in the suite - the gear that opens settings.
// The design specifies no iconography anywhere else and that stands; a settings
// affordance is the exception because a word for it is always the wrong word.
class GVAR(icon): RscPicture {
    idc = -1;
    text = "";
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};
