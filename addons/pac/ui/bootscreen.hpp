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
            //
            // AND IT KEEPS THE TOP THIRD TO ITSELF. At 30 grid units the mark
            // stood nearly half the screen tall, from 0.30 to 0.78, and the
            // title, the rule and the boot lines were all laid out inside it -
            // white text over a picture, and the progress bar drawn straight
            // across the artwork (user, 2026-09-06: "not right"). 16 units ends
            // it well above the title.
            class Logo: RscPicture {
                idc = PAC_IDC_BS_LOGO;
                text = QPATHTOEF(media,images\logo_512.paa);
                x = "0.5 - 8 * (pixelW * pixelGridNoUIScale)";
                y = "0.10 * safezoneH + safezoneY";
                w = "16 * (pixelW * pixelGridNoUIScale)";
                h = "16 * (pixelH * pixelGridNoUIScale)";
            };

            // Two lines - the mark's name, then what it is doing.
            class Title: RscStructuredText {
                idc = PAC_IDC_BS_TITLE;
                text = "";
                x = "0.25 * safezoneW + safezoneX"; y = "0.420 * safezoneH + safezoneY";
                w = "0.50 * safezoneW"; h = "0.090 * safezoneH";
            };

            // The rule under the title, and the progress bar drawn over its
            // left. The bar's width is 0.30 of safezoneW in FUNC(bootScreen)
            // too - keep the two agreed.
            class Rule: RscText {
                idc = -1;
                x = "0.35 * safezoneW + safezoneX"; y = "0.535 * safezoneH + safezoneY";
                w = "0.30 * safezoneW"; h = "0.003 * safezoneH";
                colorBackground[] = {0.35, 0.35, 0.34, 1};
            };
            class Bar: RscText {
                idc = PAC_IDC_BS_BAR;
                x = "0.35 * safezoneW + safezoneX"; y = "0.535 * safezoneH + safezoneY";
                w = "0"; h = "0.003 * safezoneH";
                colorBackground[] = {0.85, 0.28, 0.20, 1};
            };

            // THE BOOT LINES NEED THE ROOM THEY ACTUALLY TAKE. Five entries,
            // each long enough to wrap twice, never fitted 0.10 of the screen
            // and the last was cut mid-sentence (user, 2026-09-06: "cut off").
            // Wider so they wrap less, and tall enough for ten laid-out lines.
            class Step: RscStructuredText {
                idc = PAC_IDC_BS_STEP;
                text = "";
                x = "0.22 * safezoneW + safezoneX"; y = "0.555 * safezoneH + safezoneY";
                w = "0.56 * safezoneW"; h = "0.380 * safezoneH";
            };
        };
    };
};
