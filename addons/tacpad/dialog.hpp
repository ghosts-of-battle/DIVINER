// THE DIALOG. One of them: the reader.
//
// The old note here said controls on the map display never take a click and so
// everything had to be a dialog. That was wrong and is fixed - see
// FUNC(hotspot). What is true is narrower: an EDIT control wants a display with
// keyboard focus, so the two screens that are typed into are dialogs and
// everything else is drawn on the map.

// A SHELL, NOT A LAYOUT. Everything inside is ctrlCreate'd by FUNC(readerDraw)
// through the same drawFill/drawFrame/drawText vocabulary the map panels use -
// which is the only way this screen and the ones behind it can be the same
// design. What is declared here is what cannot be drawn: the display itself, a
// backdrop that dims the world, and the one control that has to take keyboard
// focus.
//
// It was two listboxes and four buttons in flat grey. That is a functioning
// reader and it is not the design; a listbox row cannot carry a precedence chip,
// a subject and a preview on three lines.
class GVAR(reader) {
    idd = IDD_READER;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(reader),_this select 0)]);
    onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(reader),displayNull)]);

    class controlsBackground {
        class Backdrop: RscText {
            idc = IDC_RD_BG;
            x = "safezoneXAbs";
            y = "safezoneY";
            w = "safezoneWAbs";
            h = "safezoneH";
            colorBackground[] = {0, 0, 0, 0.55};
        };
    };

    // NO CONTROLS ARE DECLARED HERE. The reply box used to be, and that is
    // exactly why it never worked: a declared control is created before
    // every runtime one, so the screen group this dialog draws over itself
    // sat on top of the edit and ate every click. It is ctrlCreate'd into
    // the screen's own content group instead - see FUNC(readerInput).
    class controls {};
};

// NO BUTTONS ARE DECLARED INTO THE MAP DISPLAY. There were two - a TAC//MSG and
// a SETTINGS bolted to the bottom of the screen - from when nothing the suite
// drew could be pressed and they were the only way in. They are redundant now
// and were sitting on top of the map tools: the reader's own OPEN FULL opens the
// reader, the settings strip opens settings, and the keybind still works.
//
// Panels are ctrlCreate'd and clickable, which is the whole of it - see
// FUNC(hotspot).

// THERE IS NO COMPOSE DIALOG. There was one, and it was the wrong shape: a
// second window over the reader, which hid the thread being answered behind the
// answer. Composing is a state of the reader's right pane now - see
// FUNC(composePane) - and every edit it needs is created into that pane, which
// is already a display with keyboard focus.
