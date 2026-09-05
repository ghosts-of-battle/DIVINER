// Modern 3DEN attribute system, as used across the ghost modules.

#define AEDIT(NAME,TYPE,DEF,LBL,DESC) \
    class NAME: Edit { \
        property = QUOTE(TRIPLES(ghost,COMPONENT,NAME)); \
        displayName = LBL; \
        tooltip = DESC; \
        typeName = TYPE; \
        defaultValue = DEF; \
        expression = QUOTE(_this setVariable [ARR_2('NAME',_value)]); \
    }

#define ABOOL(NAME,DEFONOFF,LBL,DESC) \
    class NAME: Combo { \
        property = QUOTE(TRIPLES(ghost,COMPONENT,NAME)); \
        displayName = LBL; \
        tooltip = DESC; \
        typeName = "STRING"; \
        defaultValue = DEFONOFF; \
        expression = QUOTE(_this setVariable [ARR_2('NAME',_value isEqualTo 'true')]); \
        class Values { \
            class off { name = "Off"; value = "false"; }; \
            class on  { name = "On";  value = "true"; }; \
        }; \
    }

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
            class Combo;
        };
        class ModuleDescription;
    };

    class ghostD_moduleTimedRepair: Module_F {
        scope = 2;
        scopeCurator = 2;
        displayName = "Timed Repair";
        author = QAUTHOR;
        category = "ghostD_modules";
        function = QUOTE(DFUNC(moduleController));
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        icon = "\a3\ui_f\data\igui\cfg\actions\repair_ca.paa";

        class Attributes: AttributesBase {
            AEDIT(interval,"NUMBER","300","Interval (sec)","Seconds between service passes.");
            AEDIT(repair_amount,"NUMBER","1","Repair Per Pass","Damage healed each pass, 0 to 1. 1 restores it fully; a smaller number means sustained fire still beats the repair rate. 0 = never repair.");
            ABOOL(rearm,"'true'","Rearm","Refill weapons each pass. Inert on anything unarmed.");
            ABOOL(refuel,"'true'","Refuel","Refill fuel each pass.");
            ABOOL(replace_crew,"'false'","Replace Crew","Give a new crew to something that started crewed and has had its crew shot out. Off by default because conjuring people into a vehicle surprises people; on, it is what keeps a manned emplacement manned.");

            ABOOL(respawn,"'false'","Respawn Destroyed","On: a destroyed object is rebuilt where it stood. What comes back is a NEW object - same class, place and facing, but not its name, variables or scripted event handlers.");
            AEDIT(respawn_delay,"NUMBER","60","Respawn Delay (sec)","Counted from the moment it died, not from the next service pass.");

            ABOOL(debug,"'false'","Debug","Logs deaths, respawns and failures to the RPT.");
        };

        class ModuleDescription: ModuleDescription {
            description = "Keeps everything synchronised to it serviceable: rearmed, refuelled and repaired on a timer, and optionally rebuilt if destroyed. A snapshot of each object is taken at mission start while it is still intact, and that is what a respawn is rebuilt from - so a respawned object comes back where it was placed, not where the blast left it.";
            sync[] = {"AnyVehicle", "AnyStaticObject"};
        };
    };
};
