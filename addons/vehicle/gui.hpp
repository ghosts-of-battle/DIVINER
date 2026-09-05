// The base classes come from the game config - see the note in ghost_groups.
class RscText;
class RscStructuredText;
class RscButton;
class RscEdit;
class RscListBox;
class RscListNBox;

// MOTORPOOL - the vehicle pool as a screen, laid out to
// docs\Arma 3 Messaging UI Mockups\motorpool-vehicle-spawner.png:
// category tabs + searchable list on the left, spec sheet + customize +
// the accent SPAWN button on the right.
//
// EVERY COLOUR IS PAINTED AT OPEN from ghostD_tacpad_fnc_theme (mod settings),
// falling back to the design's Field Grey when the mod is absent - see
// fn_motorpool_open. The colours in this file are only that fallback, so the
// dialog is legible even if the repaint never runs. Selection colours are
// config-only (the engine reads them once), so they stay neutral dark.
//
// Base control classes come from defines.hpp via CfgGUI.hpp's include order.

#define MP_IDD 46600

class YMF_MotorPool {
    idd = MP_IDD;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['YMF_motorpool_dlg', _this select 0]";
    onUnload = "uiNamespace setVariable ['YMF_motorpool_dlg', displayNull]";

    class controlsBackground {
        class MP_Ground: RscText {
            idc = 900;
            x = "safezoneX";
            y = "safezoneY";
            w = "safezoneW";
            h = "safezoneH";
            colorBackground[] = {0.953, 0.949, 0.949, 1};
        };
        // the divider between the two panes
        class MP_Divider: RscText {
            idc = 903;
            x = "safezoneX + 0.4875 * safezoneW";
            y = "safezoneY";
            w = "0.0025 * safezoneW";
            h = "safezoneH";
            colorBackground[] = {0.125, 0.118, 0.114, 1};
        };
        // header bands, both panes
        class MP_HeadLeft: RscText {
            idc = 100;
            x = "safezoneX";
            y = "safezoneY";
            w = "0.4875 * safezoneW";
            h = "0.045 * safezoneH";
            colorBackground[] = {0.953, 0.949, 0.949, 1};
        };
        class MP_HeadRight: RscText {
            idc = 105;
            x = "safezoneX + 0.49 * safezoneW";
            y = "safezoneY";
            w = "0.51 * safezoneW";
            h = "0.045 * safezoneH";
            colorBackground[] = {0.953, 0.949, 0.949, 1};
        };
        class MP_HeadRule: RscText {
            idc = 904;
            x = "safezoneX";
            y = "safezoneY + 0.045 * safezoneH";
            w = "safezoneW";
            h = "0.0022 * safezoneH";
            colorBackground[] = {0.125, 0.118, 0.114, 1};
        };
        // list kicker band
        class MP_ListKick: RscText {
            idc = 125;
            x = "safezoneX";
            y = "safezoneY + 0.124 * safezoneH";
            w = "0.4875 * safezoneW";
            h = "0.028 * safezoneH";
            colorBackground[] = {0.87, 0.865, 0.86, 1};
        };
        // customize kicker band
        class MP_CustKick: RscText {
            idc = 160;
            x = "safezoneX + 0.49 * safezoneW";
            y = "safezoneY + 0.21 * safezoneH";
            w = "0.51 * safezoneW";
            h = "0.028 * safezoneH";
            colorBackground[] = {0.87, 0.865, 0.86, 1};
        };
    };

    class controls {
        class MP_Title: RscText {
            idc = 101;
            text = "MOTORPOOL";
            x = "safezoneX + 0.008 * safezoneW";
            y = "safezoneY + 0.004 * safezoneH";
            w = "0.25 * safezoneW";
            h = "0.037 * safezoneH";
            colorText[] = {0.125, 0.118, 0.114, 1};
            font = "RobotoCondensedBold";
        };
        class MP_HeadMeta: RscText {
            idc = 102;
            text = "";
            style = 1;          // right
            x = "safezoneX + 0.24 * safezoneW";
            y = "safezoneY + 0.004 * safezoneH";
            w = "0.24 * safezoneW";
            h = "0.037 * safezoneH";
            sizeEx = "0.028 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };
        class MP_VehTitle: RscText {
            idc = 106;
            text = "";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.004 * safezoneH";
            w = "0.33 * safezoneW";
            h = "0.037 * safezoneH";
            colorText[] = {0.125, 0.118, 0.114, 1};
            font = "RobotoCondensedBold";
        };
        class MP_VehTag: RscText {
            idc = 107;
            text = "";
            style = 1;
            x = "safezoneX + 0.75 * safezoneW";
            y = "safezoneY + 0.004 * safezoneH";
            w = "0.242 * safezoneW";
            h = "0.037 * safezoneH";
            sizeEx = "0.026 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };

        // ------------------------------------------------------ tabs -----
        // eight slots; fn_motorpool_open labels, shows and colours the ones
        // the configs actually declare, plus SPAWNED at the end.
        class MP_Tab0: RscButton {
            idc = 110;
            text = "";
            x = "safezoneX";
            y = "safezoneY + 0.049 * safezoneH";
            w = "0.0609 * safezoneW";
            h = "0.034 * safezoneH";
            colorBackground[] = {0.953, 0.949, 0.949, 1};
            colorBackgroundActive[] = {0.5, 0.5, 0.5, 0.30};
            colorFocused[] = {0.5, 0.5, 0.5, 0.16};
            colorText[] = {0.125, 0.118, 0.114, 1};
            sizeEx = "0.024 * safezoneH";
            onButtonClick = "[0] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab1: MP_Tab0 {
            idc = 111;
            x = "safezoneX + 0.0609 * safezoneW";
            onButtonClick = "[1] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab2: MP_Tab0 {
            idc = 112;
            x = "safezoneX + 0.1218 * safezoneW";
            onButtonClick = "[2] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab3: MP_Tab0 {
            idc = 113;
            x = "safezoneX + 0.1827 * safezoneW";
            onButtonClick = "[3] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab4: MP_Tab0 {
            idc = 114;
            x = "safezoneX + 0.2436 * safezoneW";
            onButtonClick = "[4] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab5: MP_Tab0 {
            idc = 115;
            x = "safezoneX + 0.3045 * safezoneW";
            onButtonClick = "[5] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab6: MP_Tab0 {
            idc = 116;
            x = "safezoneX + 0.3654 * safezoneW";
            onButtonClick = "[6] call ghostD_vehicle_fnc_motorpool_tab";
        };
        class MP_Tab7: MP_Tab0 {
            idc = 117;
            x = "safezoneX + 0.4263 * safezoneW";
            onButtonClick = "[7] call ghostD_vehicle_fnc_motorpool_tab";
        };

        // ---------------------------------------------------- search -----
        class MP_Search: RscEdit {
            idc = 120;
            x = "safezoneX + 0.008 * safezoneW";
            y = "safezoneY + 0.09 * safezoneH";
            w = "0.4 * safezoneW";
            h = "0.028 * safezoneH";
            sizeEx = "0.024 * safezoneH";
            colorText[] = {0.125, 0.118, 0.114, 1};
            onKeyUp = "[] call ghostD_vehicle_fnc_motorpool_fill";
        };
        class MP_Types: RscText {
            idc = 121;
            text = "";
            style = 1;
            x = "safezoneX + 0.41 * safezoneW";
            y = "safezoneY + 0.09 * safezoneH";
            w = "0.07 * safezoneW";
            h = "0.028 * safezoneH";
            sizeEx = "0.022 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };

        class MP_ListLabel: RscText {
            idc = 126;
            text = "VEHICLE";
            x = "safezoneX + 0.008 * safezoneW";
            y = "safezoneY + 0.1255 * safezoneH";
            w = "0.12 * safezoneW";
            h = "0.025 * safezoneH";
            sizeEx = "0.02 * safezoneH";
            colorText[] = {0.125, 0.118, 0.114, 1};
            font = "RobotoCondensedBold";
        };
        class MP_ListNote: RscText {
            idc = 127;
            text = "";
            style = 1;
            x = "safezoneX + 0.2 * safezoneW";
            y = "safezoneY + 0.1255 * safezoneH";
            w = "0.28 * safezoneW";
            h = "0.025 * safezoneH";
            sizeEx = "0.019 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };

        // ------------------------------------------------------ list -----
        class MP_List: RscListNBox {
            idc = 130;
            x = "safezoneX";
            y = "safezoneY + 0.152 * safezoneH";
            w = "0.4875 * safezoneW";
            h = "0.828 * safezoneH";
            columns[] = {0.01, 0.72};
            drawSideArrows = 0;
            idcLeft = -1;
            idcRight = -1;
            rowHeight = "0.034 * safezoneH";
            sizeEx = "0.025 * safezoneH";
            colorBackground[] = {0.953, 0.949, 0.949, 1};
            colorText[] = {0.125, 0.118, 0.114, 1};
            colorSelect[] = {0.953, 0.949, 0.949, 1};
            colorSelect2[] = {0.953, 0.949, 0.949, 1};
            colorSelectBackground[] = {0.5, 0.5, 0.5, 0.35};
            colorSelectBackground2[] = {0.5, 0.5, 0.5, 0.35};
            onLBSelChanged = "[] call ghostD_vehicle_fnc_motorpool_select";
        };

        // ------------------------------------------------- spec sheet ----
        class MP_Specs: RscStructuredText {
            idc = 150;
            text = "";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.055 * safezoneH";
            w = "0.494 * safezoneW";
            h = "0.15 * safezoneH";
            size = "0.026 * safezoneH";
        };

        class MP_CustLabel: RscText {
            idc = 161;
            text = "CUSTOMIZE";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.2115 * safezoneH";
            w = "0.15 * safezoneW";
            h = "0.025 * safezoneH";
            sizeEx = "0.02 * safezoneH";
            colorText[] = {0.125, 0.118, 0.114, 1};
            font = "RobotoCondensedBold";
        };
        class MP_CustNote: RscText {
            idc = 162;
            text = "Vehicles spawn fully fuelled and armed";
            style = 1;
            x = "safezoneX + 0.65 * safezoneW";
            y = "safezoneY + 0.2115 * safezoneH";
            w = "0.34 * safezoneW";
            h = "0.025 * safezoneH";
            sizeEx = "0.019 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };

        class MP_PaintLabel: RscText {
            idc = 163;
            text = "TEXTURE";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.25 * safezoneH";
            w = "0.09 * safezoneW";
            h = "0.026 * safezoneH";
            sizeEx = "0.02 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };
        class MP_Paints: RscListBox {
            idc = 164;
            // A press has to answer - see fn_motorpool_paintPick. Without
            // this the rows were selectable and silent, which reads as a
            // list that cannot be clicked at all.
            onLBSelChanged = "[] call ghostD_vehicle_fnc_motorpool_paintPick";
            x = "safezoneX + 0.60 * safezoneW";
            y = "safezoneY + 0.25 * safezoneH";
            w = "0.392 * safezoneW";
            h = "0.17 * safezoneH";
            sizeEx = "0.024 * safezoneH";
            colorBackground[] = {0.91, 0.905, 0.9, 1};
            colorText[] = {0.125, 0.118, 0.114, 1};
            colorSelect[] = {0.953, 0.949, 0.949, 1};
            colorSelect2[] = {0.953, 0.949, 0.949, 1};
            colorSelectBackground[] = {0.5, 0.5, 0.5, 0.35};
            colorSelectBackground2[] = {0.5, 0.5, 0.5, 0.35};
        };

        class MP_FitLabel: RscText {
            idc = 165;
            text = "FITTINGS";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.435 * safezoneH";
            w = "0.09 * safezoneW";
            h = "0.026 * safezoneH";
            sizeEx = "0.02 * safezoneH";
            colorText[] = {0.45, 0.44, 0.43, 1};
        };
        class MP_Fittings: RscListBox {
            idc = 166;
            x = "safezoneX + 0.60 * safezoneW";
            y = "safezoneY + 0.435 * safezoneH";
            w = "0.392 * safezoneW";
            h = "0.34 * safezoneH";
            sizeEx = "0.024 * safezoneH";
            colorBackground[] = {0.91, 0.905, 0.9, 1};
            colorText[] = {0.125, 0.118, 0.114, 1};
            colorSelect[] = {0.125, 0.118, 0.114, 1};
            colorSelect2[] = {0.125, 0.118, 0.114, 1};
            colorSelectBackground[] = {0.5, 0.5, 0.5, 0.35};
            colorSelectBackground2[] = {0.5, 0.5, 0.5, 0.35};
            onLBSelChanged = "[] call ghostD_vehicle_fnc_motorpool_fitToggle";
        };

        // ---------------------------------------------------- actions ----
        class MP_Spawn: RscButton {
            idc = 170;
            text = "SPAWN VEHICLE";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.86 * safezoneH";
            w = "0.494 * safezoneW";
            h = "0.05 * safezoneH";
            colorBackground[] = {0.925, 0.188, 0.075, 1};
            colorBackgroundActive[] = {0.5, 0.5, 0.5, 0.30};
            colorFocused[] = {0.5, 0.5, 0.5, 0.16};
            colorText[] = {0.953, 0.949, 0.949, 1};
            font = "RobotoCondensedBold";
            sizeEx = "0.03 * safezoneH";
            onButtonClick = "[] call ghostD_vehicle_fnc_motorpool_action";
        };
        class MP_Close: RscButton {
            idc = 171;
            text = "CLOSE";
            x = "safezoneX + 0.498 * safezoneW";
            y = "safezoneY + 0.918 * safezoneH";
            w = "0.494 * safezoneW";
            h = "0.04 * safezoneH";
            colorBackground[] = {0.953, 0.949, 0.949, 1};
            colorBackgroundActive[] = {0.5, 0.5, 0.5, 0.30};
            colorFocused[] = {0.5, 0.5, 0.5, 0.16};
            colorText[] = {0.125, 0.118, 0.114, 1};
            sizeEx = "0.026 * safezoneH";
            onButtonClick = "closeDialog 0";
        };
    };
};
