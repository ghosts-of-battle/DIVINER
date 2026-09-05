class CfgVehicles {
    // The folded solar tents. NOT vanilla - they are not in Contact, Enoch,
    // Orange or the base structures PBOs - so whichever mod supplies them has to
    // be loaded or these two classes inherit from nothing and the props lose
    // their model. Named in requiredAddons once we know which mod it is.
    class Land_TentSolar_01_folded_olive_F;
    class Land_TentSolar_01_folded_sand_F;

    // Deployed patrol-base kit objects (drop these to build). Plain ThingX props
    // (a folded solar tent), NOT weapon holders - the engine deletes
    // ground weapon holders whose cargo is empty, which made these vanish a second
    // after Zeus dropped them. They are counted by class, and ACE-carryable /
    // pick-up-able back into the matching CfgWeapons kit item.
    class GVAR(kit_sand_object): Land_TentSolar_01_folded_sand_F {
        scope = 2;
        scopeCurator = 2;
        author = QAUTHOR;
        displayName = "Patrol Base Kit (Sand)";
        vehicleClass = "Items";
        editorSubcategory = "EdSubcat_InventoryItems";
        correspondingItem = QGVAR(kit_sand);
        ace_dragging_canCarry = 1;
        ace_dragging_carryPosition[] = {0, 1.2, 0};
        ace_dragging_carryDirection = 0;
        ace_dragging_canDrag = 1;
        ace_dragging_dragPosition[] = {0, 1.2, 0};
        ace_dragging_dragDirection = 0;
        class ACE_Actions {
            class ACE_MainActions {
                displayName = "$STR_ACE_interaction_MainAction";
                position = "[0, 0, 0]";
                distance = 3;
                condition = "true";

                class GVAR(kitPickup) {
                    displayName = "Pick up Patrol Base Kit";
                    condition = QUOTE([ARR_2(_target,_player)] call FUNC(canPickupKit));
                    statement = QUOTE([ARR_2(_target,_player)] call FUNC(kitPickup));
                    showDisabled = 0;
                    icon = "\A3\ui_f\data\IGUI\Cfg\Actions\take_ca.paa";
                };
            };
        };
    };

    class GVAR(kit_olive_object): Land_TentSolar_01_folded_olive_F {
        scope = 2;
        scopeCurator = 2;
        author = QAUTHOR;
        displayName = "Patrol Base Kit (Olive)";
        vehicleClass = "Items";
        editorSubcategory = "EdSubcat_InventoryItems";
        correspondingItem = QGVAR(kit_olive);
        ace_dragging_canCarry = 1;
        ace_dragging_carryPosition[] = {0, 1.2, 0};
        ace_dragging_carryDirection = 0;
        ace_dragging_canDrag = 1;
        ace_dragging_dragPosition[] = {0, 1.2, 0};
        ace_dragging_dragDirection = 0;
        class ACE_Actions {
            class ACE_MainActions {
                displayName = "$STR_ACE_interaction_MainAction";
                position = "[0, 0, 0]";
                distance = 3;
                condition = "true";

                class GVAR(kitPickup) {
                    displayName = "Pick up Patrol Base Kit";
                    condition = QUOTE([ARR_2(_target,_player)] call FUNC(canPickupKit));
                    statement = QUOTE([ARR_2(_target,_player)] call FUNC(kitPickup));
                    showDisabled = 0;
                    icon = "\A3\ui_f\data\IGUI\Cfg\Actions\take_ca.paa";
                };
            };
        };
    };
};
