class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

// The radar brings itself on the air when it is created - placed in Eden,
// spawned by Zeus or dropped by a script, all the same. Extended_Init rather
// than a class EventHandlers on the vehicle: the latter severs CBA's own XEH
// on anything that inherits it.
class Extended_Init_EventHandlers {
    class GVAR(radar) {
        class ADDON {
            init = QUOTE(call FUNC(radarInit));
        };
    };
    // The launcher does the same, and for the same reason - there is no module
    // to hand it a config any more, so it builds its own from the settings and
    // starts its own clock.
    class GVAR(launcher) {
        class ADDON {
            init = QUOTE(call FUNC(launcherInit));
        };
    };
};
