// TAC//PAC - the structure editor. One screen for the sections an admin may
// change in game: ranks, skills, awards, statuses, and the admin list. A
// section on the left, its items under it; the open item's fields on the
// right, with the labels swapped per section. Every SAVE and REMOVE goes to
// FUNC(adminStructure) on the server; the screen shows what came back.
//
// Ids are class names: lower case letters, digits, underscore - they are what
// every player record points at. Admins are keyed by Steam id.


class GVAR(structure) {
    idd = 69701;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(structDisplay),_this select 0)]; [] call FUNC(structStyle); [] call FUNC(structOpened););
    onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(structDisplay),displayNull)];);

    class controlsBackground {
        class BACKGROUND: RscADMPText {
            idc = PAC_IDC_ST_BACKGROUND;
            x = "safezoneX"; y = "safezoneY"; w = "safezoneW"; h = "safezoneH";
            colorBackground[] = {0.05, 0.05, 0.05, 0.96};
        };
    };

    class controls {
        class TITLE: RscADMPStructuredText {
            idc = PAC_IDC_ST_TITLE; text = "";
            x = "0.008 * safezoneW + safezoneX"; y = "0.008 * safezoneH + safezoneY"; w = "0.200 * safezoneW"; h = "0.036 * safezoneH";
        };
        class SUBTITLE: RscADMPStructuredText {
            idc = PAC_IDC_ST_SUBTITLE; text = "";
            x = "0.212 * safezoneW + safezoneX"; y = "0.008 * safezoneH + safezoneY"; w = "0.690 * safezoneW"; h = "0.036 * safezoneH";
        };
        class CLOSE: RscADMPButton {
            idc = PAC_IDC_ST_CLOSE; text = "CLOSE";
            x = "0.912 * safezoneW + safezoneX"; y = "0.008 * safezoneH + safezoneY"; w = "0.080 * safezoneW"; h = "0.036 * safezoneH";
            onButtonClick = QUOTE(closeDialog 0;);
        };

        class L_BACK: RscADMPText {
            idc = PAC_IDC_ST_L_BACK; text = "";
            x = "0.008 * safezoneW + safezoneX"; y = "0.056 * safezoneH + safezoneY"; w = "0.320 * safezoneW"; h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };
        class R_BACK: RscADMPText {
            idc = PAC_IDC_ST_R_BACK; text = "";
            x = "0.336 * safezoneW + safezoneX"; y = "0.056 * safezoneH + safezoneY"; w = "0.656 * safezoneW"; h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };

        // ---- left: section, items --
        class SECTION: RscADMPCombo {
            idc = PAC_IDC_ST_SECTION;
            x = "0.012 * safezoneW + safezoneX"; y = "0.064 * safezoneH + safezoneY"; w = "0.312 * safezoneW"; h = "0.032 * safezoneH";
            onLBSelChanged = QUOTE([] call FUNC(structSection););
        };
        class LIST: RscADMPListbox {
            idc = PAC_IDC_ST_LIST;
            x = "0.012 * safezoneW + safezoneX"; y = "0.104 * safezoneH + safezoneY"; w = "0.312 * safezoneW"; h = "0.842 * safezoneH";
            onLBSelChanged = QUOTE([] call FUNC(structSelect););
        };
        class COUNT: RscADMPStructuredText {
            idc = PAC_IDC_ST_COUNT; text = "";
            x = "0.012 * safezoneW + safezoneX"; y = "0.952 * safezoneH + safezoneY"; w = "0.312 * safezoneW"; h = "0.026 * safezoneH";
        };

        // ---- right: the item --
        class ID_LABEL: RscADMPStructuredText {
            idc = PAC_IDC_ST_ID_LABEL; text = "<t size='0.85'>ID</t>";
            x = "0.344 * safezoneW + safezoneX"; y = "0.064 * safezoneH + safezoneY"; w = "0.100 * safezoneW"; h = "0.032 * safezoneH";
        };
        class ID: RscADMPEdit {
            idc = PAC_IDC_ST_ID; text = "";
            tooltip = "Lower case letters, digits, underscore. What every record points at - do not rename one in use.";
            x = "0.448 * safezoneW + safezoneX"; y = "0.064 * safezoneH + safezoneY"; w = "0.540 * safezoneW"; h = "0.032 * safezoneH";
        };
        class NAME_LABEL: ID_LABEL { idc = PAC_IDC_ST_NAME_LABEL; text = "<t size='0.85'>NAME</t>"; y = "0.104 * safezoneH + safezoneY"; };
        class NAME: ID { idc = PAC_IDC_ST_NAME; tooltip = ""; y = "0.104 * safezoneH + safezoneY"; };
        class F1_LABEL: ID_LABEL { idc = PAC_IDC_ST_F1_LABEL; text = ""; y = "0.144 * safezoneH + safezoneY"; };
        class F1: ID { idc = PAC_IDC_ST_F1; tooltip = ""; y = "0.144 * safezoneH + safezoneY"; };
        class F2_LABEL: ID_LABEL { idc = PAC_IDC_ST_F2_LABEL; text = ""; y = "0.184 * safezoneH + safezoneY"; };
        class F2: ID { idc = PAC_IDC_ST_F2; tooltip = ""; y = "0.184 * safezoneH + safezoneY"; };
        class F3_LABEL: ID_LABEL { idc = PAC_IDC_ST_F3_LABEL; text = ""; y = "0.224 * safezoneH + safezoneY"; };
        class F3: ID { idc = PAC_IDC_ST_F3; tooltip = ""; y = "0.224 * safezoneH + safezoneY"; };

        class HINT: RscADMPStructuredText {
            idc = PAC_IDC_ST_HINT; text = "";
            x = "0.344 * safezoneW + safezoneX"; y = "0.270 * safezoneH + safezoneY"; w = "0.644 * safezoneW"; h = "0.200 * safezoneH";
        };

        class NEW: RscADMPButton {
            idc = PAC_IDC_ST_NEW; text = "NEW"; tooltip = "Clear the fields for a new item";
            x = "0.344 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.150 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(structNew););
        };
        class ME: RscADMPButton {
            idc = PAC_IDC_ST_ME; text = "ADD ME"; tooltip = "Admins: put your own Steam id and name in the fields";
            x = "0.500 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.150 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(structMe););
        };
        class SAVE: RscADMPButton {
            idc = PAC_IDC_ST_SAVE; text = "SAVE"; tooltip = "Write this item - new or changed - to the structure";
            x = "0.676 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.150 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(structSave););
        };
        class REMOVE: RscADMPButton {
            idc = PAC_IDC_ST_REMOVE; text = "REMOVE"; tooltip = "Remove the selected item. Records that point at it read as orphaned until reassigned.";
            x = "0.838 * safezoneW + safezoneX"; y = "0.946 * safezoneH + safezoneY"; w = "0.150 * safezoneW"; h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(structRemove););
        };
    };
};
