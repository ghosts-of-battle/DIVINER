class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
        };
        class ModuleDescription;
    };

    // ------------------------------------------------------------------------
    // Ambient shelling: every so often a short stonk lands on a building near
    // somebody, inside the named markers. War theatre, not a fire mission -
    // it never aims at the players, only at the neighbourhood they are in.
    // ------------------------------------------------------------------------
    class ghostD_moduleAmbientShelling: Module_F {
        scope = 2;
        scopeCurator = 2;
        displayName = "Ghost - Ambient Shelling";
        author = QAUTHOR;
        category = "ghostD_modules";
        function = QUOTE(DFUNC(shellingModule));
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        canSetArea = 1;
        icon = "\A3\UI_F\Data\Map\Markers\NATO\o_art.paa";

        class Attributes: AttributesBase {
            class markers: Edit {
                property = QGVAR(shellMarkers);
                displayName = "Extra Area Markers";
                tooltip = "Extra area markers, comma separated, ADDED to the module's own drawn area. Resize the module itself for the ordinary case. With neither, shells fall near players anywhere.";
                typeName = "STRING";
                defaultValue = "''";
                expression = QUOTE(_this setVariable [ARR_2('markers',_value)]);
            };
            class intervalMin: Edit {
                property = QGVAR(shellIntervalMin);
                displayName = "Interval Min (sec)";
                tooltip = "Shortest wait between stonks.";
                typeName = "NUMBER";
                defaultValue = "240";
                expression = QUOTE(_this setVariable [ARR_2('intervalMin',_value)]);
            };
            class intervalMax: Edit {
                property = QGVAR(shellIntervalMax);
                displayName = "Interval Max (sec)";
                tooltip = "Longest wait between stonks.";
                typeName = "NUMBER";
                defaultValue = "600";
                expression = QUOTE(_this setVariable [ARR_2('intervalMax',_value)]);
            };
            class roundsMin: Edit {
                property = QGVAR(shellRoundsMin);
                displayName = "Rounds Min";
                tooltip = "Fewest shells in one stonk.";
                typeName = "NUMBER";
                defaultValue = "2";
                expression = QUOTE(_this setVariable [ARR_2('roundsMin',_value)]);
            };
            class roundsMax: Edit {
                property = QGVAR(shellRoundsMax);
                displayName = "Rounds Max";
                tooltip = "Most shells in one stonk.";
                typeName = "NUMBER";
                defaultValue = "5";
                expression = QUOTE(_this setVariable [ARR_2('roundsMax',_value)]);
            };
            class shellClasses: Edit {
                property = QGVAR(shellClasses);
                displayName = "Shell Classes";
                tooltip = "Comma-separated CfgAmmo classes; each stonk draws one. BLANK mixes 155 mm and 82 mm HE.";
                typeName = "STRING";
                control = "ghost_ClassPick_Ammo";
                defaultValue = "''";
                expression = QUOTE(_this setVariable [ARR_2('shellClasses',_value)]);
            };
            class bandMin: Edit {
                property = QGVAR(shellBandMin);
                displayName = "Distance Min (m)";
                tooltip = "Closest to a player a targeted building may stand. The safety margin.";
                typeName = "NUMBER";
                defaultValue = "150";
                expression = QUOTE(_this setVariable [ARR_2('bandMin',_value)]);
            };
            class bandMax: Edit {
                property = QGVAR(shellBandMax);
                displayName = "Distance Max (m)";
                tooltip = "Furthest from a player a targeted building may stand.";
                typeName = "NUMBER";
                defaultValue = "450";
                expression = QUOTE(_this setVariable [ARR_2('bandMax',_value)]);
            };
        };

        class ModuleDescription: ModuleDescription {
            description = "Ambient war: every few minutes a short artillery stonk lands on a building near a player inside the named markers. It never targets the players themselves - the distance band keeps it off their heads - and every impact area is announced on the alert bus first.";
        };
    };

    // ------------------------------------------------------------------------
    // Ambient kamikaze: a one-way drone flies in and dives on a building near
    // somebody. It is a real aircraft - it can be heard, seen and shot down,
    // and killing it is the whole counterplay.
    // ------------------------------------------------------------------------
    class ghostD_moduleAmbientKamikaze: Module_F {
        scope = 2;
        scopeCurator = 2;
        displayName = "Ghost - Ambient Kamikaze Drones";
        author = QAUTHOR;
        category = "ghostD_modules";
        function = QUOTE(DFUNC(kamikazeModule));
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        canSetArea = 1;
        icon = "\A3\UI_F\Data\Map\Markers\NATO\o_air.paa";

        class Attributes: AttributesBase {
            class markers: Edit {
                property = QGVAR(kamMarkers);
                displayName = "Extra Area Markers";
                tooltip = "Extra area markers, comma separated, ADDED to the module's own drawn area. Resize the module itself for the ordinary case. With neither, drones come for buildings near players anywhere.";
                typeName = "STRING";
                defaultValue = "''";
                expression = QUOTE(_this setVariable [ARR_2('markers',_value)]);
            };
            class intervalMin: Edit {
                property = QGVAR(kamIntervalMin);
                displayName = "Interval Min (sec)";
                tooltip = "Shortest wait between runs.";
                typeName = "NUMBER";
                defaultValue = "420";
                expression = QUOTE(_this setVariable [ARR_2('intervalMin',_value)]);
            };
            class intervalMax: Edit {
                property = QGVAR(kamIntervalMax);
                displayName = "Interval Max (sec)";
                tooltip = "Longest wait between runs.";
                typeName = "NUMBER";
                defaultValue = "900";
                expression = QUOTE(_this setVariable [ARR_2('intervalMax',_value)]);
            };
            class droneClasses: Edit {
                property = QGVAR(kamDroneClasses);
                displayName = "Drone Classes";
                tooltip = "Comma-separated UAV classes; each run draws one. BLANK flies the side's vanilla quadcopter.";
                typeName = "STRING";
                control = "ghost_ClassPick_Uav";
                defaultValue = "''";
                expression = QUOTE(_this setVariable [ARR_2('droneClasses',_value)]);
            };
            class diveSpeed: Edit {
                property = QGVAR(kamDiveSpeed);
                displayName = "Speed (m/s)";
                tooltip = "How fast the drone flies its run. Keep it low enough to be shot at.";
                typeName = "NUMBER";
                defaultValue = "40";
                expression = QUOTE(_this setVariable [ARR_2('diveSpeed',_value)]);
            };
            class bandMin: Edit {
                property = QGVAR(kamBandMin);
                displayName = "Distance Min (m)";
                tooltip = "Closest to a player a targeted building may stand. The safety margin.";
                typeName = "NUMBER";
                defaultValue = "150";
                expression = QUOTE(_this setVariable [ARR_2('bandMin',_value)]);
            };
            class bandMax: Edit {
                property = QGVAR(kamBandMax);
                displayName = "Distance Max (m)";
                tooltip = "Furthest from a player a targeted building may stand.";
                typeName = "NUMBER";
                defaultValue = "500";
                expression = QUOTE(_this setVariable [ARR_2('bandMax',_value)]);
            };
        };

        class ModuleDescription: ModuleDescription {
            description = "Ambient war: every few minutes a one-way drone flies in and dives on a building near a player inside the named markers. It is a real aircraft on the map - audible, visible and killable, and shooting it down is the counterplay. It never dives at the players themselves.";
        };
    };
};
