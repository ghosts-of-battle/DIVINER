// THE REQUEST WINDOW, and why it is a dialog rather than a panel on the map.
//
// TAC//SUPPORT's board lives in the tacpad like every other app. Asking for a
// fire mission does not: it needs a map control the player can click a target
// on, and a map control embedded in a panel on the map display bleeds past its
// own frame and feeds its drags to the big map underneath. In a dialog it
// clips, it pans only itself, and CLOSE is a closeDisplay nothing can sit on
// top of. The old TAC//SUPPORT learned this the hard way and this is the same
// conclusion.
//
// GEOMETRY IS LITERAL NUMBERS HERE AND IN FUNC(supportRequest), which draws to
// the same ones. A config value cannot be built from a macro with commas in it
// and this addon has been caught by that before.

class RscText;
class RscMapControl;

class GVAR(supportDlg) {
    idd = 8960;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(supportDlg),_this select 0)]);
    onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(supportDlg),displayNull)]);

    class controlsBackground {
        // idc 8962 so FUNC(supportRequestDraw) can draw its text onto a control
        // (the tacpad draw helpers take a control parent, not the display).
        class Backdrop: RscText {
            idc = 8962;
            x = "safezoneXAbs";
            y = "safezoneY";
            w = "safezoneWAbs";
            h = "safezoneH";
            colorBackground[] = {0, 0, 0, 0.45};
        };
    };

    class controls {
        // The right half IS the map. Config-declared so the engine hosts it
        // properly; FUNC(supportRequest) hangs the click and draw handlers on it
        // when the window opens.
        class SupportMap: RscMapControl {
            idc = 8961;
            x = "safezoneX + 0.505 * safezoneW";
            y = "safezoneY + 0.215 * safezoneH";
            w = "0.315 * safezoneW";
            h = "0.505 * safezoneH";
        };
    };
};
