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

// THE IED PELICAN ARMS ITSELF ON SPAWN - whoever spawns it, however. See
// FUNC(iedDrone) for the fuze; CfgVehicles.hpp for the airframe.
class Extended_Init_EventHandlers {
    class GVAR(UAV_06_IED_I) {
        init = QUOTE(call FUNC(iedDrone));
    };
};
