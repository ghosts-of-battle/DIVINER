class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
            class Combo;
        };
        class ModuleDescription;
    };

    // PLACING THIS MODULE IS THE ENABLE, and SYNCHRONISING IS THE WIRING.
    // Sync the objects players press - a sign, a table, a flagpole - and,
    // if you want particular transport, sync the vehicles too. Nothing is
    // asked for here that the mission has already said by placing things.
    class ghostD_moduleBoarding: Module_F {
        scope = 2;
        scopeCurator = 2;
        displayName = "Ghost - Boarding Point";
        author = QAUTHOR;
        category = "ghostD_modules";
        function = QUOTE(DFUNC(moduleController));
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        icon = "\a3\ui_f\data\map\markers\nato\b_service.paa";

        class Attributes: AttributesBase {
            class range: Edit {
                property = QGVAR(range);
                displayName = "Pickup Range (m)";
                tooltip = "How far from THIS MODULE a player may be standing and still be loaded. Measured from the module, not from the object pressed - the object is the switch, the module is the muster point.";
                typeName = "NUMBER";
                defaultValue = "50";
                expression = QUOTE(_this setVariable [ARR_2('range',_value)]);
            };
            class title: Edit {
                property = QGVAR(title);
                displayName = "Action Name";
                tooltip = "What the ACE action on the synchronised object is called.";
                typeName = "STRING";
                defaultValue = "'Board Transport'";
                expression = QUOTE(_this setVariable [ARR_2('title',_value)]);
            };
            class sideOnly: Combo {
                property = QGVAR(sideOnly);
                displayName = "Who Is Loaded";
                tooltip = "PRESSER'S SIDE: only players on the same side as whoever pressed are loaded. EVERYONE: every player in range, whatever their side.";
                typeName = "NUMBER";
                defaultValue = "0";
                expression = QUOTE(_this setVariable [ARR_2('sideOnly',_value)]);
                class Values {
                    class ownSide { name = "Presser's side"; value = 0; default = 1; };
                    class anyone { name = "Everyone in range"; value = 1; };
                };
            };
            class includePresser: Combo {
                property = QGVAR(includePresser);
                displayName = "Load The Presser";
                tooltip = "Whether the player who pressed the action is loaded too. Off leaves them standing - useful when one person is dispatching everybody else.";
                typeName = "NUMBER";
                defaultValue = "0";
                expression = QUOTE(_this setVariable [ARR_2('includePresser',_value)]);
                class Values {
                    class yes { name = "Yes"; value = 0; default = 1; };
                    class no { name = "No - dispatcher stays"; value = 1; };
                };
            };
        };

        class ModuleDescription: ModuleDescription {
            description = "A muster point that loads players into transport. Synchronise the OBJECT players press - a sign, a crate, a flagpole - and it carries an ACE action; pressing it moves every player within the module's range into cargo. Synchronise VEHICLES too to say which transport is theirs; with none synced it uses whatever has free cargo near the module. Players already in a vehicle are left alone, and anyone who does not fit is told so rather than being silently left behind.";
            sync[] = {"AnyVehicle", "AnyStaticObject", "AnyThing"};
        };
    };
};
