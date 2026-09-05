// TAC//PAC - the admin page. Opened from the admin console's ADMIN ACTIONS
// column; the same screen-as-console layout as TAC//ADMIN, three columns on one
// grid: the roster down the left, the open player's record in the middle, the
// actions, the recent log and the database down the right.
//
// THIS IS THE ONLY PLACE PLAYER DATA IS EDITED. Every control here that changes
// something sends [player, uid, field, value] to FUNC(adminSet) on the server,
// which checks the sender against the admin list before it writes. The page
// never writes a record itself; it shows what the server sent back.
//
// COLOURS ARE PLACEHOLDERS, the dark scheme, so nothing flashes. FUNC(panelStyle)
// repaints from the player's tacpad scheme when the display opens. No structured
// text carries an inline color= for the reason the console gives: it would beat
// the theme.
//
// GEOMETRY IS IN SAFE-ZONE FRACTIONS, written out in full, so a control can be
// nudged by reading one line. Rows are 0.032 high on a 0.038 pitch.

class GVAR(panel) {
    idd = 69700;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),_this select 0)]; [] call FUNC(panelStyle); [] call FUNC(panelOpened););
    onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),displayNull)]; [] call FUNC(panelReapply););

    class controlsBackground {
        class BACKGROUND: RscADMPText {
            idc = PAC_IDC_BACKGROUND;
            x = "safezoneX";
            y = "safezoneY";
            w = "safezoneW";
            h = "safezoneH";
            colorBackground[] = {0.05, 0.05, 0.05, 0.96};
        };
    };

    class controls {
        // ------------------------------------------------------------ header --
        class TITLE: RscADMPStructuredText {
            idc = PAC_IDC_TITLE;
            text = "";      // wordmark written at runtime - see FUNC(panelStyle)
            x = "0.008 * safezoneW + safezoneX";
            y = "0.008 * safezoneH + safezoneY";
            w = "0.160 * safezoneW";
            h = "0.036 * safezoneH";
        };

        class SUBTITLE: RscADMPStructuredText {
            idc = PAC_IDC_SUBTITLE;
            text = "";
            x = "0.172 * safezoneW + safezoneX";
            y = "0.008 * safezoneH + safezoneY";
            w = "0.730 * safezoneW";
            h = "0.036 * safezoneH";
        };

        class CLOSE: RscADMPButton {
            idc = PAC_IDC_CLOSE;
            text = "CLOSE";
            x = "0.912 * safezoneW + safezoneX";
            y = "0.008 * safezoneH + safezoneY";
            w = "0.080 * safezoneW";
            h = "0.036 * safezoneH";
            onButtonClick = QUOTE(closeDialog 0;);
        };

        // ------------------------------------------------------------- rails --
        class L_BACK: RscADMPText {
            idc = PAC_IDC_L_BACK;
            text = "";
            x = "0.008 * safezoneW + safezoneX";
            y = "0.056 * safezoneH + safezoneY";
            w = "0.220 * safezoneW";
            h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };

        class M_BACK: RscADMPText {
            idc = PAC_IDC_M_BACK;
            text = "";
            x = "0.236 * safezoneW + safezoneX";
            y = "0.056 * safezoneH + safezoneY";
            w = "0.388 * safezoneW";
            h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };

        class R_BACK: RscADMPText {
            idc = PAC_IDC_R_BACK;
            text = "";
            x = "0.632 * safezoneW + safezoneX";
            y = "0.056 * safezoneH + safezoneY";
            w = "0.360 * safezoneW";
            h = "0.930 * safezoneH";
            colorBackground[] = {0.10, 0.10, 0.10, 1};
        };

        // -------------------------------------------------------- left: roster --
        class L_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_L_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>R O S T E R</t>";
            x = "0.012 * safezoneW + safezoneX";
            y = "0.060 * safezoneH + safezoneY";
            w = "0.212 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class L_FILTER: RscADMPEdit {
            idc = PAC_IDC_L_FILTER;
            text = "";
            tooltip = "Filter by name";
            x = "0.012 * safezoneW + safezoneX";
            y = "0.090 * safezoneH + safezoneY";
            w = "0.144 * safezoneW";
            h = "0.032 * safezoneH";
            onKeyUp = QUOTE([] call FUNC(panelFillRoster););
        };

        class L_UNASSIGNED: RscADMPButton {
            idc = PAC_IDC_L_UNASSIGNED;
            text = "UNASSIGNED";
            tooltip = "Only players with no rank, role or skills";
            x = "0.160 * safezoneW + safezoneX";
            y = "0.090 * safezoneH + safezoneY";
            w = "0.064 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(panelUnassigned););
        };

        class L_LIST: RscADMPListbox {
            idc = PAC_IDC_L_LIST;
            x = "0.012 * safezoneW + safezoneX";
            y = "0.128 * safezoneH + safezoneY";
            w = "0.212 * safezoneW";
            h = "0.818 * safezoneH";
            onLBSelChanged = QUOTE([] call FUNC(panelSelect););
        };

        class L_COUNT: RscADMPStructuredText {
            idc = PAC_IDC_L_COUNT;
            text = "";
            x = "0.012 * safezoneW + safezoneX";
            y = "0.952 * safezoneH + safezoneY";
            w = "0.212 * safezoneW";
            h = "0.026 * safezoneH";
        };

        // ------------------------------------------------------ middle: record --
        class M_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_M_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>P L A Y E R</t>";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.060 * safezoneH + safezoneY";
            w = "0.300 * safezoneW";
            h = "0.026 * safezoneH";
        };

        // SAVE - edits save on their own (debounced); this writes now and
        // reapplies to the player at once (user, 2026-09-05).
        class M_SAVE: RscADMPButton {
            idc = PAC_IDC_M_SAVE;
            text = "SAVE";
            tooltip = "Write the store now (profile and database) and reapply to everyone - edits also save on their own, this is immediate confirmation.";
            x = "0.548 * safezoneW + safezoneX";
            y = "0.058 * safezoneH + safezoneY";
            w = "0.072 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(panelSave););
        };

        class M_NAME: RscADMPStructuredText {
            idc = PAC_IDC_M_NAME;
            text = "";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.090 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.060 * safezoneH";
        };

        class RANK_LABEL: RscADMPStructuredText {
            idc = PAC_IDC_RANK_LABEL;
            text = "<t size='0.85'>RANK</t>";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.156 * safezoneH + safezoneY";
            w = "0.068 * safezoneW";
            h = "0.032 * safezoneH";
        };

        class RANK_COMBO: RscADMPCombo {
            idc = PAC_IDC_RANK_COMBO;
            x = "0.312 * safezoneW + safezoneX";
            y = "0.156 * safezoneH + safezoneY";
            w = "0.308 * safezoneW";
            h = "0.032 * safezoneH";
            onLBSelChanged = QUOTE(['rankId'] call FUNC(panelCombo););
        };

        class GROUP_LABEL: RANK_LABEL {
            idc = PAC_IDC_GROUP_LABEL;
            text = "<t size='0.85'>GROUP</t>";
            y = "0.194 * safezoneH + safezoneY";
        };

        // The group first, because the role list is the group's: a squad's
        // slots are its roles, and "Assistant Team Lead" three times over -
        // once per squad that has one - is not a list anybody can pick from.
        class GROUP_COMBO: RANK_COMBO {
            idc = PAC_IDC_GROUP_COMBO;
            y = "0.194 * safezoneH + safezoneY";
            onLBSelChanged = QUOTE(['groupId'] call FUNC(panelCombo););
        };

        class ROLE_LABEL: RANK_LABEL {
            idc = PAC_IDC_ROLE_LABEL;
            text = "<t size='0.85'>ROLE</t>";
            y = "0.232 * safezoneH + safezoneY";
        };

        class ROLE_COMBO: RANK_COMBO {
            idc = PAC_IDC_ROLE_COMBO;
            y = "0.232 * safezoneH + safezoneY";
            onLBSelChanged = QUOTE(['roleId'] call FUNC(panelCombo););
        };

        class STATUS_LABEL: RANK_LABEL {
            idc = PAC_IDC_STATUS_LABEL;
            text = "<t size='0.85'>STATUS</t>";
            y = "0.270 * safezoneH + safezoneY";
        };

        class STATUS_COMBO: RANK_COMBO {
            idc = PAC_IDC_STATUS_COMBO;
            y = "0.270 * safezoneH + safezoneY";
            onLBSelChanged = QUOTE(['statusId'] call FUNC(panelCombo););
        };

        // THE TWO DATES (user, 2026-09-05): enlisted - the day the unit first
        // saw them, editable so it can be back-dated - and promoted, stamped
        // when the rank changes, editable the same way. Time in service and
        // time in grade are counted from them, on the line below.
        class ENLISTED_LABEL: RANK_LABEL {
            idc = PAC_IDC_ENLISTED_LABEL;
            text = "<t size='0.85'>ENLISTED</t>";
            y = "0.308 * safezoneH + safezoneY";
        };

        class ENLISTED: RscADMPEdit {
            idc = PAC_IDC_ENLISTED;
            text = "";
            tooltip = "YYYY-MM-DD. Defaults to the day the unit first saw them; type an earlier date to back-date and press SET. Time in service counts from it.";
            x = "0.312 * safezoneW + safezoneX";
            y = "0.308 * safezoneH + safezoneY";
            w = "0.236 * safezoneW";
            h = "0.032 * safezoneH";
        };

        class ENLISTED_SET: RscADMPButton {
            idc = PAC_IDC_ENLISTED_SET;
            text = "SET";
            tooltip = "Write the enlistment date";
            x = "0.552 * safezoneW + safezoneX";
            y = "0.308 * safezoneH + safezoneY";
            w = "0.068 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['enlistedAt'] call FUNC(panelDate););
        };

        class PROMOTED_LABEL: RANK_LABEL {
            idc = PAC_IDC_PROMOTED_LABEL;
            text = "<t size='0.85'>PROMOTED</t>";
            y = "0.346 * safezoneH + safezoneY";
        };

        class PROMOTED: ENLISTED {
            idc = PAC_IDC_PROMOTED;
            tooltip = "YYYY-MM-DD. Stamped when the rank changes; type a date to back-date and press SET. Time in grade counts from it.";
            y = "0.346 * safezoneH + safezoneY";
        };

        class PROMOTED_SET: ENLISTED_SET {
            idc = PAC_IDC_PROMOTED_SET;
            tooltip = "Write the promotion date";
            y = "0.346 * safezoneH + safezoneY";
            onButtonClick = QUOTE(['promotedAt'] call FUNC(panelDate););
        };

        // Two lines: time in service / time in grade, and the promotion points
        // with the next rung (FUNC(panelFill), FUNC(promotionPoints)).
        class SERVICE_LINE: RscADMPStructuredText {
            idc = PAC_IDC_SERVICE_LINE;
            text = "";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.384 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.040 * safezoneH";
        };

        class SKILLS_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_SKILLS_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>S K I L L S</t>  <t size='0.7'>click to toggle</t>";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.428 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class SKILLS_LIST: RscADMPListbox {
            idc = PAC_IDC_SKILLS_LIST;
            x = "0.240 * safezoneW + safezoneX";
            y = "0.454 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.130 * safezoneH";
            onLBSelChanged = QUOTE([] call FUNC(panelToggleSkill););
        };

        class AWARDS_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_AWARDS_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>A W A R D S</t>";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.590 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class AWARDS_LIST: RscADMPListbox {
            idc = PAC_IDC_AWARDS_LIST;
            x = "0.240 * safezoneW + safezoneX";
            y = "0.616 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.074 * safezoneH";
        };

        class AWARD_COMBO: RscADMPCombo {
            idc = PAC_IDC_AWARD_COMBO;
            x = "0.240 * safezoneW + safezoneX";
            y = "0.694 * safezoneH + safezoneY";
            w = "0.240 * safezoneW";
            h = "0.032 * safezoneH";
        };

        class AWARD_ADD: RscADMPButton {
            idc = PAC_IDC_AWARD_ADD;
            text = "ADD";
            x = "0.484 * safezoneW + safezoneX";
            y = "0.694 * safezoneH + safezoneY";
            w = "0.066 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['add'] call FUNC(panelAward););
        };

        class AWARD_REMOVE: RscADMPButton {
            idc = PAC_IDC_AWARD_REMOVE;
            text = "REMOVE";
            tooltip = "Removes the selected award from the list above";
            x = "0.554 * safezoneW + safezoneX";
            y = "0.694 * safezoneH + safezoneY";
            w = "0.066 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['remove'] call FUNC(panelAward););
        };

        // ---- TRAINING: courses held - date, who logged it, what (2026-09-05).
        // Type the course; lead with YYYY-MM-DD to back-date it to the day it
        // was held. FUNC(panelTraining).
        class TRAINING_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_TRAINING_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>T R A I N I N G</t>  <t size='0.7'>lead with YYYY-MM-DD to back-date</t>";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.732 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class TRAINING_LIST: RscADMPListbox {
            idc = PAC_IDC_TRAINING_LIST;
            x = "0.240 * safezoneW + safezoneX";
            y = "0.758 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.066 * safezoneH";
        };

        class TRAIN_EDIT: RscADMPEdit {
            idc = PAC_IDC_TRAIN_EDIT;
            text = "";
            tooltip = "e.g.  2026-08-14 CLS course, passed";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.828 * safezoneH + safezoneY";
            w = "0.240 * safezoneW";
            h = "0.032 * safezoneH";
        };

        class TRAIN_ADD: RscADMPButton {
            idc = PAC_IDC_TRAIN_ADD;
            text = "ADD";
            x = "0.484 * safezoneW + safezoneX";
            y = "0.828 * safezoneH + safezoneY";
            w = "0.066 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['add'] call FUNC(panelTraining););
        };

        class TRAIN_REMOVE: RscADMPButton {
            idc = PAC_IDC_TRAIN_REMOVE;
            text = "REMOVE";
            tooltip = "Removes the selected training entry from the list above";
            x = "0.554 * safezoneW + safezoneX";
            y = "0.828 * safezoneH + safezoneY";
            w = "0.066 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['remove'] call FUNC(panelTraining););
        };

        class NOTES_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_NOTES_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>N O T E S</t>";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.866 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class NOTES_LIST: RscADMPListbox {
            idc = PAC_IDC_NOTES_LIST;
            x = "0.240 * safezoneW + safezoneX";
            y = "0.892 * safezoneH + safezoneY";
            w = "0.380 * safezoneW";
            h = "0.046 * safezoneH";
        };

        class NOTE_EDIT: RscADMPEdit {
            idc = PAC_IDC_NOTE_EDIT;
            text = "";
            x = "0.240 * safezoneW + safezoneX";
            y = "0.942 * safezoneH + safezoneY";
            w = "0.300 * safezoneW";
            h = "0.032 * safezoneH";
        };

        class NOTE_ADD: RscADMPButton {
            idc = PAC_IDC_NOTE_ADD;
            text = "ADD NOTE";
            x = "0.544 * safezoneW + safezoneX";
            y = "0.942 * safezoneH + safezoneY";
            w = "0.076 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(panelNote););
        };

        // ------------------------------------------------------ right: actions --
        class R_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_R_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>A C T I O N S</t>";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.060 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class KICK: RscADMPButton {
            idc = PAC_IDC_KICK;
            text = "KICK";
            tooltip = "Kicks the open player, if they are on the server";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.090 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['kick'] call FUNC(panelKickBan););
        };

        class BAN: RscADMPButton {
            idc = PAC_IDC_BAN;
            text = "BAN";
            tooltip = "Bans the open player, if they are on the server";
            x = "0.816 * safezoneW + safezoneX";
            y = "0.090 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['ban'] call FUNC(panelKickBan););
        };

        // The status block - tall enough for its six lines (it was clipped).
        class R_STATUS: RscADMPStructuredText {
            idc = PAC_IDC_R_STATUS;
            text = "";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.130 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.112 * safezoneH";
        };

        class ORPHANS_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_ORPHANS_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>O R P H A N S</t>  <t size='0.7'>records pointing at a rank, role, skill or status the structure no longer has - reassign them</t>";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.246 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class ORPHANS_LIST: RscADMPListbox {
            idc = PAC_IDC_ORPHANS_LIST;
            x = "0.636 * safezoneW + safezoneX";
            y = "0.272 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.076 * safezoneH";
        };

        // THE RECENT LOG - what admins did, dated. The whole log is in MANAGE.
        class LOG_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_LOG_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>R E C E N T   A C T I O N S</t>  <t size='0.7'>every admin action, dated - the whole log is under MANAGE</t>";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.354 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class LOG_LIST: RscADMPListbox {
            idc = PAC_IDC_LOG_LIST;
            x = "0.636 * safezoneW + safezoneX";
            y = "0.380 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.158 * safezoneH";
        };

        class WINDOW_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_WINDOW_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>O P   W I N D O W</t>  <t size='0.7'>START OP when the op begins, STOP OP when it ends - everyone on in between counts as attended</t>";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.548 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.026 * safezoneH";
        };

        class WINDOW_NAME: RscADMPEdit {
            idc = PAC_IDC_WINDOW_NAME;
            text = "";
            tooltip = "Optional: a name for tonight's op. Left empty, the window is named by its date.";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.578 * safezoneH + safezoneY";
            w = "0.176 * safezoneW";
            h = "0.032 * safezoneH";
        };

        class WINDOW_START: RscADMPButton {
            idc = PAC_IDC_WINDOW_START;
            text = "START OP";
            tooltip = "Opens an op window now - attendance is counted from here. A window already open is stopped first.";
            x = "0.816 * safezoneW + safezoneX";
            y = "0.578 * safezoneH + safezoneY";
            w = "0.084 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['start'] call FUNC(panelWindow););
        };

        class WINDOW_STOP: RscADMPButton {
            idc = PAC_IDC_WINDOW_STOP;
            text = "STOP OP";
            tooltip = "Closes the open window and saves. Its attendance is then final.";
            x = "0.904 * safezoneW + safezoneX";
            y = "0.578 * safezoneH + safezoneY";
            w = "0.084 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE(['stop'] call FUNC(panelWindow););
        };

        class REPORT: RscADMPButton {
            idc = PAC_IDC_REPORT;
            text = "ATTENDANCE TO CLIPBOARD";
            tooltip = "Who was on and for how long - the open window, else the last one - as text on your clipboard and in the .rpt";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.616 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.032 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(panelReport););
        };

        class HINT: RscADMPStructuredText {
            idc = PAC_IDC_HINT;
            text = "";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.656 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.134 * safezoneH";
        };

        // ---- the database: the store and the structure, out and in ----------
        class BACKUP_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_BACKUP_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>D A T A B A S E</t>  <t size='0.7'>the store and the structure as JSON, out to and in from your clipboard</t>";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.798 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.024 * safezoneH";
        };

        class EXPORT: RscADMPButton {
            idc = PAC_IDC_EXPORT;
            text = "EXPORT STORE";
            tooltip = "The whole store - every record, session, window, log row - as JSON on your clipboard and in the .rpt";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.824 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['export'] call FUNC(panelBackup););
        };

        class IMPORT: RscADMPButton {
            idc = PAC_IDC_IMPORT;
            text = "IMPORT STORE (MERGE)";
            tooltip = "Merge the store JSON on your clipboard into this one - the newer record wins, rows are appended";
            x = "0.816 * safezoneW + safezoneX";
            y = "0.824 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['import'] call FUNC(panelBackup););
        };

        class RESTORE: RscADMPButton {
            idc = PAC_IDC_RESTORE;
            text = "RESTORE STORE";
            tooltip = "Replace the whole store with the JSON on your clipboard. Asks first.";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.858 * safezoneH + safezoneY";
            w = "0.083 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['restore'] call FUNC(panelBackup););
        };

        class STRUCTURE: RscADMPButton {
            idc = PAC_IDC_STRUCTURE;
            text = "STRUCTURE OUT";
            tooltip = "The whole structure - ranks, skills, roles, ORBAT, nets, radio, deck, orders - as JSON on your clipboard; STRUCTURE IN on another server takes it";
            x = "0.724 * safezoneW + safezoneX";
            y = "0.858 * safezoneH + safezoneY";
            w = "0.083 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['structure'] call FUNC(panelBackup););
        };

        class STRUCT_IMPORT: RscADMPButton {
            idc = PAC_IDC_STRUCT_IMPORT;
            text = "STRUCTURE IN";
            tooltip = "Replace the structure with the JSON on your clipboard - from pac_sync.py pull (the database) or another server's STRUCTURE OUT. Takes effect at once, kept. Asks first.";
            x = "0.812 * safezoneW + safezoneX";
            y = "0.858 * safezoneH + safezoneY";
            w = "0.083 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['structureImport'] call FUNC(panelBackup););
        };

        // A roster CSV shipped in the mission (pac_roster.csv) into the store.
        class CSV_IMPORT: RscADMPButton {
            idc = PAC_IDC_CSV_IMPORT;
            text = "IMPORT CSV";
            tooltip = "Read pac_roster.csv from the mission and write it into the roster - one record per row, keyed by Steam id. Columns: steamId, name, milsimName, rank, group, role, status, skills, discordId, enlisted, ... Asks first.";
            x = "0.900 * safezoneW + safezoneX";
            y = "0.858 * safezoneH + safezoneY";
            w = "0.088 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(panelCsv););
        };

        // ---- the admin tools: the editors and the sample data ----------------
        class TOOLS_TITLE: RscADMPStructuredText {
            idc = PAC_IDC_TOOLS_TITLE;
            text = "<t font='RobotoCondensedBold' size='0.7'>A D M I N   T O O L S</t>  <t size='0.7'>the editors, and sample data for a look at the pages</t>";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.894 * safezoneH + safezoneY";
            w = "0.352 * safezoneW";
            h = "0.024 * safezoneH";
        };

        class STRUCT_OPEN: RscADMPButton {
            idc = PAC_IDC_STRUCT_OPEN;
            text = "EDIT STRUCTURE";
            tooltip = "Ranks, skills, awards, statuses, roles (gates), nets, admins - edited in game and kept.";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.920 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(structOpen););
        };

        class MANAGE_OPEN: RscADMPButton {
            idc = PAC_IDC_MANAGE_OPEN;
            text = "MANAGE - LOG, ORBAT, OPERATORS";
            tooltip = "The whole action log, the ORBAT editor (squads, slots, tabs, radio nets) and the operator files.";
            x = "0.816 * safezoneW + safezoneX";
            y = "0.920 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE([] call FUNC(manageOpen););
        };

        class SAMPLE_ADD: RscADMPButton {
            idc = PAC_IDC_SAMPLE_ADD;
            text = "SEED SAMPLE DATA";
            tooltip = "Sixteen made-up players with ranks, roles, skills, awards, notes and a closed op window, drawn from this mission's structure. Re-running overwrites the same sixteen.";
            x = "0.636 * safezoneW + safezoneX";
            y = "0.954 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['add'] call FUNC(panelSample););
        };

        class SAMPLE_REMOVE: RscADMPButton {
            idc = PAC_IDC_SAMPLE_REMOVE;
            text = "REMOVE SAMPLE";
            tooltip = "Takes out exactly what SEED SAMPLE put in. Asks first.";
            x = "0.816 * safezoneW + safezoneX";
            y = "0.954 * safezoneH + safezoneY";
            w = "0.172 * safezoneW";
            h = "0.030 * safezoneH";
            onButtonClick = QUOTE(['remove'] call FUNC(panelSample););
        };
    };
};
