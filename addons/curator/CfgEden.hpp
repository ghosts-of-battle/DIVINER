class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class PREFIX {
                class Attributes {
                    class GVAR(isZeus) {
                        displayName = "Zeus";
                        tooltip = "Controls whether unit will have Zeus interface.";
                        property = QGVAR(isZeus);
                        control = "Checkbox";
                        expression = QUOTE(if (_value) then {ARR_2([{[_this] call FUNC(assignZeus)},_this]) call CBA_fnc_execNextFrame});
                        defaultValue = "false";
                        condition = "objectControllable";
                    };
                };
            };
        };
    };
};
