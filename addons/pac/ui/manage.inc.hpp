// TAC//PAC - the management window. One screen, several sections picked from
// a combo, the same left-list / right-fields shape as the structure editor:
//
//   LOG                every dated action an admin took, newest first
//   ORBAT - SQUADS     the squads and their slots (row order = SR channel)
//   ORBAT - PLATOONS   the tabs over the role screen, each with its net
//   ORBAT - RADIO NETS the nets that cross a platoon boundary
//   ORBAT - FACTION    the name over the role screen
//   OPERATORS          the operator file: identity, service, assignment,
//                      qualifications, attendance, awards, actions
//
// Six free field rows under an ID row; which are shown, and what they mean,
// is FUNC(manageSection)'s business. Every SAVE and REMOVE goes to the server
// (FUNC(adminOrbat), FUNC(adminSet)) after an admin check; EXPORT puts the
// section on the clipboard.

class GVAR(manage) {
    idd = 69702;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(manageDisplay),_this select 0)]; [] call FUNC(manageStyle); [] call FUNC(manageOpened););
    onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(manageDisplay),displayNull)];);

    class controlsBackground {
        class BACKGROUND: RscADMPText {
            idc = PAC_IDC_MG_BACKGROUND;
            x = "safezoneX"; y = "safezoneY"; w = "safezoneW"; h = "safezoneH";
            colorBackground[] = {0.05, 0.05, 0.05, 0.96};
        };
    };

    class controls {
        class TITLE: RscADMPStructuredText {
            idc = PAC_IDC_MG_TITLE; text = "";
            x = "0.008 * safezoneW + safezoneX"; y = "0.008 * safezoneH + safezoneY"; w = "0.200 * safezoneW"; h = "0.036 * safezoneH";
        };
        class SUBTITLE: RscADMPStructuredText {
            idc = PAC_IDC_MG_SUBTITLE; text = "";
            x = "0.212 * safezoneW + safezoneX"; y = "0.008 * safezoneH + safezoneY"; w = "0.690 * safezoneW"; h = "0.036 * safezoneH";
        };
        class CLOSE: RscADMPButton {
            idc = PAC_IDC_MG_CLOSE; text = "CLOSE";
            x = "0.912 * safezoneW + safezoneX"; y = "0.008 * safezoneH + safezoneY"; w = "0.080 * safezoneW"; h = "0.036 * safezoneH";
            onButtonClick = QUOTE(closeDialog 0;);
        };

        class L_BACK: RscADMPText {
            idc = PAC_IDC_MG_L_BACK; text = "";
            x = "0.008 * safezoneW + safezoneX"; y = "0.056 * safezoneH + safezoneY"; w = "0.360 * safezoneW"; h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };
        class R_BACK: RscADMPText {
            idc = PAC_IDC_MG_R_BACK; text = "";
            x = "0.376 * safezoneW + safezoneX"; y = "0.056 * safezoneH + safezoneY"; w = "0.616 * safezoneW"; h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };

        // ---- left: section, filter, items --
        class SECTION: RscADMPCombo {
            idc = PAC_IDC_MG_SECTION;
            x = "0.012 * safezoneW + safezoneX"; y = "0.064 * safezoneH + safezoneY"; w = "0.352 * safezoneW"; h = "0.032 * safezoneH";
            onLBSelChanged = QUOTE([] call FUNC(manageSection););
        };
        class FILTER_EDIT: RscADMPEdit {   // not FILTER - that is a CBA macro
            idc = PAC_IDC_MG_FILTER; text = "";
            tooltip = "Filter the list";
            x = "0.012 * safezoneW + safezoneX"; y = "0.104 * safezoneH + safezoneY"; w = "0.352 * safezoneW"; h = "0.032 * safezoneH";
            onKeyUp = QUOTE([] call FUNC(manageSection););
        };
        class LIST: RscADMPListbox {
            idc = PAC_IDC_MG_LIST;
            x = "0.012 * safezoneW + safezoneX"; y = "0.144 * safezoneH + safezoneY"; w = "0.352 * safezoneW"; h = "0.802 * safezoneH";
            onLBSelChanged = QUOTE([] call FUNC(manageSelect););
        };
        class COUNT: RscADMPStructuredText {
            idc = PAC_IDC_MG_COUNT; text = "";
            x = "0.012 * safezoneW + safezoneX"; y = "0.952 * safezoneH + safezoneY"; w = "0.352 * safezoneW"; h = "0.026 * safezoneH";
        };

        // ---- right: the item --
        class ID_LABEL: RscADMPStructuredText {
            idc = PAC_IDC_MG_ID_LABEL; text = "";
            x = "0.384 * safezoneW + safezoneX"; y = "0.064 * safezoneH + safezoneY"; w = "0.100 * safezoneW"; h = "0.032 * safezoneH";
        };
        class ID: RscADMPEdit {
            idc = PAC_IDC_MG_ID; text = ""; tooltip = "";
            x = "0.488 * safezoneW + safezoneX"; y = "0.064 * safezoneH + safezoneY"; w = "0.500 * safezoneW"; h = "0.032 * safezoneH";
        };
        class F1_LABEL: ID_LABEL { idc = PAC_IDC_MG_F1_LABEL; y = "0.104 * safezoneH + safezoneY"; };
        class F1: ID { idc = PAC_IDC_MG_F1; y = "0.104 * safezoneH + safezoneY"; };
        class F2_LABEL: ID_LABEL { idc = PAC_IDC_MG_F2_LABEL; y = "0.144 * safezoneH + safezoneY"; };
        class F2: ID { idc = PAC_IDC_MG_F2; y = "0.144 * safezoneH + safezoneY"; };
        class F3_LABEL: ID_LABEL { idc = PAC_IDC_MG_F3_LABEL; y = "0.184 * safezoneH + safezoneY"; };
        class F3: ID { idc = PAC_IDC_MG_F3; y = "0.184 * safezoneH + safezoneY"; };
        class F4_LABEL: ID_LABEL { idc = PAC_IDC_MG_F4_LABEL; y = "0.224 * safezoneH + safezoneY"; };
        class F4: ID { idc = PAC_IDC_MG_F4; y = "0.224 * safezoneH + safezoneY"; };
        class F5_LABEL: ID_LABEL { idc = PAC_IDC_MG_F5_LABEL; y = "0.264 * safezoneH + safezoneY"; };
        class F5: ID { idc = PAC_IDC_MG_F5; y = "0.264 * safezoneH + safezoneY"; };
        class F6_LABEL: ID_LABEL { idc = PAC_IDC_MG_F6_LABEL; y = "0.304 * safezoneH + safezoneY"; };
        class F6: ID { idc = PAC_IDC_MG_F6; y = "0.304 * safezoneH + safezoneY"; };

        class HINT: RscADMPStructuredText {
            idc = PAC_IDC_MG_HINT; text = "";
            x = "0.384 * safezoneW + safezoneX"; y = "0.350 * safezoneH + safezoneY"; w = "0.604 * safezoneW"; h = "0.586 * safezoneH";
        };

        class NEW: RscADMPButton {
            idc = PAC_IDC_MG_NEW; text = "NEW"; tooltip = "Clear the fields for a new item";
            x = "0.384 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.144 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(manageNew););
        };
        class SAVE: RscADMPButton {
            idc = PAC_IDC_MG_SAVE; text = "SAVE"; tooltip = "Write this item to the server";
            x = "0.536 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.144 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(manageSave););
        };
        class REMOVE: RscADMPButton {
            idc = PAC_IDC_MG_REMOVE; text = "REMOVE"; tooltip = "Remove the selected item. Asks first.";
            x = "0.688 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.144 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(manageRemove););
        };
        class EXPORT: RscADMPButton {
            idc = PAC_IDC_MG_EXPORT; text = "EXPORT"; tooltip = "This section to your clipboard and the .rpt";
            x = "0.840 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.148 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(manageExport););
        };
    };
};
