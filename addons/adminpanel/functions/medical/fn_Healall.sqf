#include "\z\ghostD\addons\adminpanel\script_component.hpp"

{
    [_x, _x] call ace_medical_treatment_fnc_fullHeal;
    [_x, _x]  call ACM_core_fnc_resetVariables;
    [_x, _x]  call ACM_airway_fnc_resetVariables;
    [_x, _x]  call ACM_breathing_fnc_resetVariables;
    [_x, _x]  call ACM_circulation_fnc_resetVariables;
    [_x, _x]  call ACM_damage_fnc_resetVariables;
    [_x, _x]  call ACM_disability_fnc_resetVariables;
} forEach allPlayers;

// Everyone was healed, so everyone hears about it - once, rather than once per player healed.
["Thy Lord Almighty Admin", "Healed everyone.", [0.4, 0.702, 0.4, 1]] call EFUNC(notify,broadcast);
