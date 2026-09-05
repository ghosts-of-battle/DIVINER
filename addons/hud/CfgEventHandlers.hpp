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

// NO MENU HOOKS. There is nothing left for them to do and they never worked.
//
// The HUD used to be a title layer, which outlived the mission and sat on the
// Arma 3 main menu showing the SCANNER readout. Eight builds tried to take it
// down from the menu side - RscDisplayMain, RscDisplayLoading, the pause menu,
// layer sweeps, finite durations - and every one of them failed for the same
// reason: a title layer raised inside a mission cannot be addressed from
// outside it, and the main menu display is REUSED rather than created, so it
// raises no load event to hook in the first place.
//
// The HUD is now built as controls on the mission display (findDisplay 46),
// which the engine destroys with the mission. See gui.hpp and FUNC(open).
