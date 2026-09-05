// Reposition dialog shared by every ghost HUD overlay.
//
// A cutRsc title layer receives no mouse input, so a live HUD can never be
// dragged. Placement therefore works the way DUI and ACE do it: the HUD itself
// is non-interactive, and this dialog puts a draggable stand-in on screen so the
// player can put it where they want. The result is stored per player in
// profileNamespace, so it survives missions and sessions.

class RscButton;   // RscText comes from ui/RscModal.hpp, included above

class GVAR(hudMove) {
    idd = IDD_HUDMOVE;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(hudMove),_this select 0)]);

    class controls {
        // Full-screen catcher so a drag that outruns the box still tracks.
        class Catcher: RscText {
            idc = IDC_HUDMOVE_CATCH;
            x = "safeZoneXAbs"; y = "safeZoneY";
            w = "safeZoneWAbs"; h = "safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class Hint: RscText {
            idc = -1;
            x = "safeZoneX"; y = "safeZoneY + 0.04 * safeZoneH";
            w = "safeZoneW"; h = "0.05 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
            colorText[] = {0.871, 0.361, 0.188, 1};
            style = 2;  // centred
            sizeEx = "0.9 * (pixelH * pixelGrid)";
            text = "Drag the panel where you want it";
        };
        // The stand-in. Sized by the caller to match the real HUD.
        class Ghost: RscText {
            idc = IDC_HUDMOVE_BOX;
            x = "safeZoneX"; y = "safeZoneY";
            w = "0.2 * safeZoneW"; h = "0.06 * safeZoneH";
            colorBackground[] = {0.871, 0.361, 0.188, 0.55};
            colorText[] = {0.933, 0.910, 0.863, 1};
            sizeEx = "0.8 * (pixelH * pixelGrid)";
            text = "";
        };
        class SaveBtn: RscButton {
            idc = IDC_HUDMOVE_SAVE;
            x = "safeZoneX + 0.5 * safeZoneW - 0.24 * safeZoneW";
            y = "safeZoneY + safeZoneH - 0.10 * safeZoneH";
            w = "0.14 * safeZoneW"; h = "0.04 * safeZoneH";
            text = "Save";
        };
        class ResetBtn: RscButton {
            idc = IDC_HUDMOVE_RESET;
            x = "safeZoneX + 0.5 * safeZoneW - 0.07 * safeZoneW";
            y = "safeZoneY + safeZoneH - 0.10 * safeZoneH";
            w = "0.14 * safeZoneW"; h = "0.04 * safeZoneH";
            text = "Reset";
        };
        class CancelBtn: RscButton {
            idc = IDC_HUDMOVE_CANCEL;
            x = "safeZoneX + 0.5 * safeZoneW + 0.10 * safeZoneW";
            y = "safeZoneY + safeZoneH - 0.10 * safeZoneH";
            w = "0.14 * safeZoneW"; h = "0.04 * safeZoneH";
            text = "Cancel";
        };
    };
};
