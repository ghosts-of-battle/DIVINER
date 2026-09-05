class ace_arsenal_actions {
    class ADDON {
        displayName = "Backpack on Chest";
        condition = QUOTE((_this select 0) call FUNC(canMovePack) && {backpack (_this select 0) != '' || {(_this select 0) call FUNC(chestpack) != ''}});
        scopeEditor = 0; // editor modules exist for chestpacks
        tabs[] = {5};
        class GVAR(chestpack) {
            condition = QUOTE((_this select 0) call FUNC(chestpack) != '');
            textStatement = QUOTE(getText (configFile >> 'CfgVehicles' >> (_this select 0) call FUNC(chestpack) >> 'displayName'));
        };
        class GVAR(onChest) {
            label = "Put backpack on chest";
            condition = QUOTE((_this select 0) call FUNC(canMovePack) && {backpack (_this select 0) != ''} && {(_this select 0) call FUNC(chestpack) == ''});
            statement = QUOTE((_this select 0) call FUNC(actionOnChest));
        };
        class GVAR(onBack) {
            label = "Put backpack on back";
            condition = QUOTE((_this select 0) call FUNC(canMovePack) && {backpack (_this select 0) == ''} && {(_this select 0) call FUNC(chestpack) != ''});
            statement = QUOTE((_this select 0) call FUNC(actionOnBack));
        };
        class GVAR(swap) {
            label = "Swap rucksacks";
            condition = QUOTE((_this select 0) call FUNC(canMovePack) && {backpack (_this select 0) != ''} && {(_this select 0) call FUNC(chestpack) != ''});
            statement = QUOTE((_this select 0) call FUNC(actionSwap));
        };
    };
};
