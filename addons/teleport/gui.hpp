// Reeveli's teleport menu: a map on the left, the list of points on the right.
// Selecting a point flies the map to it and drops a marker; OK moves you.
//
// The layout is his, in pixel-grid units so it holds its shape on any screen.

class RscText;
class RscButton;
class RscListBox;
class RscMapControl;

#define TP_GRID             54
#define TP_PANEL_W          (TP_GRID * pixelGridNoUIScale * pixelW)
#define TP_STD_H            (TP_GRID * 0.5 * pixelGridNoUIScale * pixelH)
#define TP_BAR_H            (2 * pixelGridNoUIScale * pixelH)
#define TP_GAP_W            (0.2 * pixelGridNoUIScale * pixelW)
#define TP_GAP_H            (0.2 * pixelGridNoUIScale * pixelH)
#define TP_BUTTON_W         (TP_PANEL_W * 0.2)

#define TP_X                (safeZoneX + (safeZoneW * 0.5) - (TP_PANEL_W * 0.5))
#define TP_Y                (safeZoneY + (safeZoneH * 0.5) - (TP_BAR_H * 0.5) - (TP_GAP_H * 0.5) - (TP_STD_H * 0.5))

class GVAR(dialog) {
    idd = IDD_TP;
    movingEnable = 1;
    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),_this select 0)]; private _map = uiNamespace getVariable [ARR_2(QQGVAR(map),controlNull)]; _map ctrlMapAnimAdd [ARR_3(0,0.3,getMarkerPos QQGVAR(marker))]; ctrlMapAnimCommit _map);
    onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),displayNull)]; deleteMarkerLocal QQGVAR(marker););

    class ControlsBackground {
        class BarTitle: RscText {
            x = QUOTE(TP_X);
            y = QUOTE(TP_Y);
            w = QUOTE(TP_PANEL_W);
            h = QUOTE(TP_BAR_H);
            text = "Teleport list";
            font = "PuristaSemibold";
            style = 2 + 512;
            // GHOST RED, #CC4331, rather than the player's own interface
            // colour - the mission version read GUI_BCG_RGB from the profile,
            // so the title bar was a different colour on every machine.
            colorBackground[] = {0.8, 0.263, 0.192, 0.8};
            moving = 1;
            sizeEx = "1.6 * pixelGridNoUIScale * pixelH";
        };
        class Map: RscMapControl {
            idc = IDC_TP_MAP;
            moving = 0;
            x = QUOTE(TP_X);
            y = QUOTE(TP_Y + TP_BAR_H + TP_GAP_H);
            w = QUOTE(TP_PANEL_W * 0.5);
            h = QUOTE(TP_STD_H);
            onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(map),_this select 0)]);
            onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(map),controlNull)]);
        };
        class BgMain: RscText {
            x = QUOTE(TP_X + TP_PANEL_W * 0.5);
            y = QUOTE(TP_Y + TP_BAR_H + TP_GAP_H);
            w = QUOTE(TP_PANEL_W * 0.5);
            h = QUOTE(TP_STD_H);
            colorBackground[] = {0, 0, 0, 0.8};
            moving = 1;
        };
    };

    class Controls {
        class ListLocations: RscListBox {
            idc = IDC_TP_LIST;
            onLoad = QUOTE(params ['_control']; uiNamespace setVariable [ARR_2(QQGVAR(listCtrl),_control)]; [_control] call FUNC(onLoad));
            onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(listCtrl),controlNull)]);
            onLBSelChanged = QUOTE(params [ARR_2('_control','_lbCurSel')]; [ARR_2(_control,_lbCurSel)] call FUNC(onLBSelChanged));
            x = QUOTE(TP_X + TP_PANEL_W * 0.5 + TP_GAP_W);
            y = QUOTE(TP_Y + TP_BAR_H + 2 * TP_GAP_H);
            w = QUOTE(TP_PANEL_W * 0.5 - (TP_GAP_W * 2));
            h = QUOTE(TP_STD_H - (TP_GAP_H * 3) - TP_BAR_H);
            colorBackground[] = {1, 1, 1, 0};
            sizeEx = "1.4 * pixelGridNoUIScale * pixelH";
        };
        class ButtonOk: RscButton {
            idc = IDC_TP_OK;
            x = QUOTE(TP_X + TP_PANEL_W - TP_GAP_W - TP_BUTTON_W);
            y = QUOTE(TP_Y + TP_STD_H);
            w = QUOTE(TP_BUTTON_W);
            h = QUOTE(TP_BAR_H);
            text = "Ok";
            colorBackground[] = {0, 0, 0, 1};
            colorFocused[] = {0.2, 0.2, 0.2, 1};
            colorBackgroundActive[] = {0.2, 0.2, 0.2, 1};
            sizeEx = "1.5 * pixelGridNoUIScale * pixelH";
            onButtonClick = QUOTE([] call FUNC(onButtonClick));
        };
        class ButtonCancel: ButtonOk {
            idc = IDC_TP_CANCEL;
            x = QUOTE(TP_X + TP_PANEL_W * 0.5 + TP_GAP_W);
            text = "Cancel";
            onButtonClick = QUOTE(closeDialog 2);
        };
    };
};
