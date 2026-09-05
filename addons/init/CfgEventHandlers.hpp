class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

// THE MISSION'S OWN INIT ORDER, KEPT. description.ext ran scripts\preInit.sqf
// and scripts\postInit.sqf through CBA's extended handlers; these are the same
// two files in the same two slots, so nothing about the sequence changed when
// they moved into the mod.
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
