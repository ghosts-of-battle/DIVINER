
// ENGINE CONTROL CLASSES THE PICKER INHERITS FROM. Declared HERE, at the root
// of the config, never inside Cfg3DEN >> Attributes: declaring them there makes
// shadow classes at Cfg3DEN/Attributes/ctrl* that rapify resolves ABOVE BI's
// global ctrl* classes, and every BI attribute that chains through ctrlStatic
// (Type, EditCode, ...) then breaks - "No entry .../Attributes/Type/Controls/
// Title.type". ALiVE learnt this the hard way (ALiVE.OS addons/main/
// CfgVehicles.hpp:6-21); the lesson is copied, not relearnt.
class ctrlControlsGroupNoScrollbars;
class ctrlListBox;
class ctrlStatic;
class ctrlEdit;
class ctrlButton;

class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class PREFIX {
                displayName = GHOST_ATTRIBUTES;
                collapsed = 1;
                class Attributes {};
            };
        };
    };

    // Custom module-attribute control (the faction dropdown) for the drone / EW
    // modules. Kept in a separate file, included here so there is exactly one
    // `class Cfg3DEN` in this addon (HEMTT rejects reopening it).
    class Attributes {
        #include "CfgEdenDrone.hpp"
    };
};
