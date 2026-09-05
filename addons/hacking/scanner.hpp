// The hand-held scanner screen.
//
// NOT AN RscTitles LAYER ANY MORE, AND THAT IS THE WHOLE POINT. It was one, and
// a title layer raised inside a mission has two faults that cannot be patched:
//
//   1. It outlives the mission. The handset sat on the Arma 3 main menu, over
//      QUICK PLAY, unclickable and unremovable - eight builds of menu-side
//      teardown could not reach it, because from outside the mission both the
//      stored handle and findDisplay come back null and the layer's duration
//      does not count down.
//   2. It draws OVER dialogs. The screenshot that prompted this had the scanner
//      showing through the TAC//ADMIN panel, on top of the player list.
//
// The controls are created on the MISSION DISPLAY (findDisplay 46) instead -
// see FUNC(scannerToggle). That display is created with the mission and
// destroyed with it by the engine, so the handset cannot reach the menu by any
// route; and it sits UNDER dialogs, where a heads-up device belongs. The same
// change was made to ghost_hud for the same two reasons.
//
// The classes below are therefore ROOT-LEVEL, because that is where ctrlCreate
// looks them up, and each keeps the idc FUNC(scannerLayout) addresses it by -
// so the layout and tick code did not have to change at all.
//
// The handset is MRHMilsimTools' art (ADPL-SA, see data/README.md). Everything
// on the screen is drawn as a monochrome terminal - green readings, red when
// something wants your attention - in EtelkaMonospacePro, the same face ACE's
// MicroDAGR uses, so the two devices read like they came out of the same crate.
//
// No control here carries a position: FUNC(scannerLayout) sets all of them from
// the screen rectangle, so the whole device scales as one and the text can never
// drift off the glass.

// RscText and RscPicture are already forward-declared by tablet.hpp, which is
// what includes this file - re-declaring them is L-C03.

#define SCN_GREEN {0, 0.67, 0.22, 1}

#define SCN_LINE(NAME,IDCV,STYLE) \
    class GVAR(NAME): RscText { \
        idc = IDCV; \
        style = STYLE; \
        x = 0; y = 0; w = 0; h = 0; \
        font = "EtelkaMonospacePro"; \
        colorBackground[] = {0, 0, 0, 0}; \
        colorText[] = SCN_GREEN; \
        sizeEx = "0.9 * (pixelH * pixelGrid)"; \
    }

// Row glyphs. The art is white on transparent, so colorText is the whole colour
// of the icon - which means an icon takes the state colour of its row for free
// and the screen never has two things saying the same thing in two colours.
#define SCN_ICON(NAME,IDCV,FILE) \
    class GVAR(NAME): RscPicture { \
        idc = IDCV; \
        x = 0; y = 0; w = 0; h = 0; \
        text = QPATHTOF(data\icons\FILE.paa); \
        colorText[] = SCN_GREEN; \
    }

// Creation order is paint order - FUNC(scannerToggle) walks the list below in
// this order. The handset art goes down first and the text straight onto it.
// There is no panel behind the text: the art's own glass is already black, and
// an opaque rectangle sized to it can only ever be slightly wrong, which shows
// up as a hard edge clipping over the moulding.
class GVAR(scnBezel): RscPicture {
    idc = IDC_SCN_BEZEL;
    text = QPATHTOF(data\phone.paa);
    x = 0; y = 0; w = 0; h = 0;
};

SCN_LINE(scnTitle,IDC_SCN_TITLE,2);

// Three readings. Glyph, then label hard left, then value hard right, so the
// eye runs down one column for "what" and another for "how bad".
SCN_ICON(scnDroneI,IDC_SCN_ICO_DRONE,signal);
SCN_LINE(scnDroneL,IDC_SCN_DRONE_L,0);
SCN_LINE(scnDroneV,IDC_SCN_DRONE_V,1);
SCN_ICON(scnJamI,IDC_SCN_ICO_JAM,jam);
SCN_LINE(scnJamL,IDC_SCN_JAM_L,0);
SCN_LINE(scnJamV,IDC_SCN_JAM_V,1);
SCN_ICON(scnMeshI,IDC_SCN_ICO_MESH,mesh);
SCN_LINE(scnMeshL,IDC_SCN_MESH_L,0);
SCN_LINE(scnMeshV,IDC_SCN_MESH_V,1);

SCN_LINE(scnNetHead,IDC_SCN_NETHEAD,2);
SCN_ICON(scnNetI,IDC_SCN_ICO_NET,antenna);
SCN_LINE(scnNetL,IDC_SCN_NET_L,0);
SCN_LINE(scnNetV,IDC_SCN_NET_V,1);

SCN_LINE(scnAlarm,IDC_SCN_ALARM,2);
SCN_LINE(scnTimer,IDC_SCN_TIMER,2);
SCN_LINE(scnStatus,IDC_SCN_STATUS,2);
