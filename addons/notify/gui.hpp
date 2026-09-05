// Stackable notification HUD. An RscTitles layer with SLOT_COUNT pre-built
// rows; FUNC(show) fills a free row and FUNC(tick) expires and restacks them.
// Pre-built rather than ctrlCreate'd: the stack is capped anyway, and fixed
// IDCs keep every position change to a ctrlSetPosition + ctrlCommit.
//
// Each row is: a translucent panel, a colour bar down its left edge (the
// notification's severity colour) and the structured text.

class RscText;
class RscStructuredText;

#define SLOT_DEF(N) \
    class DOUBLES(slotPanel,N): RscText { \
        idc = IDC_SLOT(N); \
        colorBackground[] = {0, 0, 0, 0.55}; \
        x = "safezoneX"; y = "safezoneY"; w = 0; h = 0; \
    }; \
    class DOUBLES(slotBar,N): RscText { \
        idc = IDC_BAR(N); \
        colorBackground[] = {0.871, 0.361, 0.188, 1}; \
        x = "safezoneX"; y = "safezoneY"; w = 0; h = 0; \
    }; \
    class DOUBLES(slotText,N): RscStructuredText { \
        idc = IDC_TEXT(N); \
        x = "safezoneX"; y = "safezoneY"; w = 0; h = 0; \
        /* Size and face are both set at runtime from the CBA settings - \
           FUNC(place) sets the height, FUNC(show) bakes the font into the \
           markup. What is here is only a sane starting point. */ \
        size = "0.8 * (pixelH * pixelGrid)"; \
        class Attributes { \
            font = "RobotoCondensed"; \
            color = "#EEE8DC"; \
            align = "left"; \
            shadow = 1; \
        }; \
    }

class RscTitles {
    class GVAR(hud) {
        idd = -1;
        movingEnable = 0;
        fadeIn = 0;
        fadeOut = 0;
        duration = "1e+011";
        onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(hud),_this select 0)]);
        class controls {
            SLOT_DEF(0);
            SLOT_DEF(1);
            SLOT_DEF(2);
            SLOT_DEF(3);
            SLOT_DEF(4);
            SLOT_DEF(5);
        };
    };
};
