class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

// PreInit AS WELL AS PreStart. See XEH_preInit.sqf - a preStart-only PREP does
// not survive into a mission, which is why nothing in this addon existed in game.
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};

// The base-game voice nets (2026-10-20) - see XEH_postInit.sqf.
class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};
