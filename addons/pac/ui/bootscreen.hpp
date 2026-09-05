// TAC//PAC boot screen - a full-plate overlay a client sees while the unit
// initialises, the way ALiVE shows its init: the mark, "INITIALISING THE
// UNIT", a progress bar, and the boot steps as the server reports them,
// until READY. Shown on an RscTitles layer (cutRsc) so it sits over the
// loading/briefing without being a dialog; FUNC(bootScreen) drives it and
// fades it out. The look is the suite's - flat ground, one accent, the
// hairline rule, RobotoCondensed - so it is not a different mod's poster.

class RscTitles {
    class GVAR(bootScreen) {
        idd = -1;
        movingEnable = 0;
        duration = 1e9;                  // held open until FUNC(bootScreen) cuts it
        fadein = 0;
        fadeout = 0.6;
        onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(bootDisp),_this select 0)]);
        onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(bootDisp),displayNull)]);

        class controls {
            class Ground: RscText {
                idc = -1;
                x = "safezoneXAbs"; y = "safezoneY"; w = "safezoneWAbs"; h = "safezoneH";
                colorBackground[] = {0.05, 0.05, 0.05, 0.96};
            };

            // SQUARE, whatever the aspect: pixelW and pixelH are one real pixel
            // each, so equal counts of them are a square - the main menu's own
            // idiom. Stretching w/h in safezone fractions is what squished it.
            class Logo: RscPicture {
                idc = PAC_IDC_BS_LOGO;
                text = QPATHTOEF(media,images\logo_512.paa);
                x = "0.5 - 15 * (pixelW * pixelGridNoUIScale)";
                y = "0.30 * safezoneH + safezoneY";
                w = "30 * (pixelW * pixelGridNoUIScale)";
                h = "30 * (pixelH * pixelGridNoUIScale)";
            };

            class Title: RscStructuredText {
                idc = PAC_IDC_BS_TITLE;
                text = "";
                x = "0.30 * safezoneW + safezoneX"; y = "0.470 * safezoneH + safezoneY";
                w = "0.40 * safezoneW"; h = "0.05 * safezoneH";
            };

            // The rule under the title, and the progress bar drawn over its left.
            class Rule: RscText {
                idc = -1;
                x = "0.35 * safezoneW + safezoneX"; y = "0.545 * safezoneH + safezoneY";
                w = "0.30 * safezoneW"; h = "0.003 * safezoneH";
                colorBackground[] = {0.35, 0.35, 0.34, 1};
            };
            class Bar: RscText {
                idc = PAC_IDC_BS_BAR;
                x = "0.35 * safezoneW + safezoneX"; y = "0.545 * safezoneH + safezoneY";
                w = "0"; h = "0.003 * safezoneH";
                colorBackground[] = {0.85, 0.28, 0.20, 1};
            };

            class Step: RscStructuredText {
                idc = PAC_IDC_BS_STEP;
                text = "";
                x = "0.30 * safezoneW + safezoneX"; y = "0.560 * safezoneH + safezoneY";
                w = "0.40 * safezoneW"; h = "0.10 * safezoneH";
            };
        };
    };
};
