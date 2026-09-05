class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};

// EVERY MENU-SIDE DISPLAY takes the scanner overlay down - see
// XEH_menuClear. A cutRsc title layer survives the mission that raised it,
// and the one thing that must never be on the main menu is a handset
// screen nobody can interact with.
class Extended_DisplayLoad_EventHandlers {
    // The pause menu is the last moment the mission is still alive - see
    // XEH_interrupt. Both classes, because SP and MP use different ones.
    class RscDisplayInterrupt {
        ADDON = QUOTE(call COMPILE_FILE(XEH_interrupt));
    };
    class RscDisplayMPInterrupt {
        ADDON = QUOTE(call COMPILE_FILE(XEH_interrupt));
    };
    class RscDisplayMain {
        ADDON = QUOTE(call COMPILE_FILE(XEH_menuClear));
    };
    // NOT RscDisplayMainMap - that is the IN-GAME MAP (idd 12), not a menu
    // display. Hooking it ran the teardown every time the player opened
    // their map. Harmless only because of the isNull player guard, and
    // wrong regardless.
    // NOT RscDisplayLoading. That display is shown while a MISSION LOADS,
    // not only on the way to the menu - hooking it meant the layer sweep
    // ran seconds into a live mission and wiped the scanner the moment it
    // was raised. The menu displays below are the only safe ones.
};
