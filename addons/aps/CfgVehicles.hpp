class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
            class Combo;
        };
        class ModuleDescription;
    };

    // PLACING THIS MODULE IS THE ENABLE. No module, no active protection -
    // the same rule as every other Ghost system. The module says WHICH
    // effectors run and lets a mission bend the tier table; WHO gets what
    // is worked out from each vehicle's faction (fnc_fitFor), never placed
    // by hand - a mission that wants a specific vehicle fitted names it in
    // Fit Overrides.
    class ghostD_moduleAPS: Module_F {
        scope = 2;
        scopeCurator = 2;
        displayName = "Ghost - APS";
        author = QAUTHOR;
        category = "ghostD_modules";
        function = QUOTE(DFUNC(moduleAPS));
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        icon = "\a3\ui_f\data\map\markers\nato\b_armor.paa";

        class Attributes: AttributesBase {
            class hardKill: Combo {
                property = QGVAR(hardKill);
                displayName = "Hard Kill";
                tooltip = "The launcher-and-charge systems (Trophy, Afganit, GL-5, Iron Fist by side): incoming rockets, missiles and - at the top fit - tank rounds are destroyed short of the hull. Charges per side, rearmed at a supply vehicle.";
                typeName = "NUMBER";
                defaultValue = "1";
                expression = QUOTE(_this setVariable [ARR_2('hardKill',_value)]);
                class Values {
                    class on { name = "On"; value = 1; default = 1; };
                    class off { name = "Off"; value = 0; };
                };
            };
            class rfBurst: Combo {
                property = QGVAR(rfBurst);
                displayName = "RF Burst";
                tooltip = "The high-power microwave emitter: an automatic, omnidirectional soft-kill burst that strips guidance from missiles and drops drones in range, then goes cold for its cooldown. Every burst jams every radio near the emitter, friend and foe. Peer tanks and everything armoured at peer+.";
                typeName = "NUMBER";
                defaultValue = "1";
                expression = QUOTE(_this setVariable [ARR_2('rfBurst',_value)]);
                class Values {
                    class on { name = "On"; value = 1; default = 1; };
                    class off { name = "Off"; value = 0; };
                };
            };
            class rfAir: Combo {
                property = QGVAR(rfAir);
                displayName = "RF Burst On Helicopters";
                tooltip = "Peer+ helicopters carry the emitter as their DIRCM - IR and laser missiles lose the aircraft. Off keeps the burst on the ground.";
                typeName = "NUMBER";
                defaultValue = "1";
                expression = QUOTE(_this setVariable [ARR_2('rfAir',_value)]);
                class Values {
                    class on { name = "On"; value = 1; default = 1; };
                    class off { name = "Off"; value = 0; };
                };
            };
            class tierOverrides: Edit {
                property = QGVAR(tierOverrides);
                displayName = "Tier Overrides";
                tooltip = "faction:tier pairs, comma separated - 'ghost_AAF:3, OPF_F:4'. 0-1 irregular (nothing), 2 near-peer, 3 peer, 4 peer+. The mod's own factions are already placed; a mod's faction not listed anywhere takes the Default Tier setting.";
                typeName = "STRING";
                defaultValue = "''";
                expression = QUOTE(_this setVariable [ARR_2('tierOverrides',_value)]);
            };
            class fitOverrides: Edit {
                property = QGVAR(fitOverrides);
                displayName = "Fit Overrides";
                tooltip = "class:fit pairs, comma separated - 'B_MBT_01_cannon_F:ENHANCED, I_MRAP_03_F:NONE'. Fits: NONE, BASIC, LIGHT, MEDIUM, HEAVY, ENHANCED; add +RF for the emitter ('O_MRAP_02_F:LIGHT+RF'). Beats the tier table for that class.";
                typeName = "STRING";
                defaultValue = "''";
                expression = QUOTE(_this setVariable [ARR_2('fitOverrides',_value)]);
            };
            class debug: Combo {
                property = QGVAR(debug);
                displayName = "Debug";
                tooltip = "Logs every fit and intercept, draws the burst radius on the map for a few seconds.";
                typeName = "NUMBER";
                defaultValue = "0";
                expression = QUOTE(_this setVariable [ARR_2('debug',_value)]);
                class Values {
                    class off { name = "Off"; value = 0; default = 1; };
                    class on { name = "On"; value = 1; };
                };
            };
        };

        class ModuleDescription: ModuleDescription {
            description[] = {
                "Placing this module turns on the APS, the active protection. Without it, the system is off.",
                "",
                "Hard Kill - Launcher-and-charge systems that destroy incoming rockets and missiles short of the hull",
                "RF Burst - The microwave emitter: guided munitions lose guidance, drones drop, every radio nearby is jammed for a moment",
                "RF Burst On Helicopters - Peer+ helicopters carry the emitter as their DIRCM",
                "Tier Overrides - faction:tier pairs that bend the fit table for a mission",
                "Fit Overrides - class:fit pairs that name a vehicle's fit outright",
                "Debug - Log fits and intercepts, draw burst radii",
            };
        };
    };
};
