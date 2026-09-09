# config_skill.hpp

AI skill. **The only config in the tree that is statements rather than data.**

**Loads:** compiled at CBA preInit by [loadConfigs](loadConfigs) into
`ghost_missionConfig_skillBlock`. **SQF**, not a class config.
**Read by:** the mod, called **per unit**.

---

## How it is compiled

```sqf
ghost_missionConfig_skillBlock = compile ("private _unit = _this; " + preprocessFileLineNumbers "config\config_skill.hpp");
```

> The unit is bound to **`_unit`**, and the file is written against that name.
> Rename the variable and every `setSkill` in it stops resolving.

There is no wrapping class and no `class` keyword — the file is a bare block of
SQF that runs once per unit.

---

## Shape

```sqf
if (ghostD_Settings_setAiSystemDifficulty == 1) then {
    _unit setSkill ["aimingspeed",     0.420];
    _unit setSkill ["aimingaccuracy",  0.500];
    _unit setSkill ["aimingshake",     0.360];
    _unit setSkill ["spottime",        0.800];
    _unit setSkill ["spotdistance",    1.000];
    _unit setSkill ["commanding",      1.0];
    _unit setSkill ["general",         1.0];
};

if (ghostD_Settings_setAiSystemDifficulty == 2) then {

    // Light level, and whether he can see in it
    if (getLighting select 1 <= 5) then {
        if (hmd _unit != "") then {
            _unit setSkill ["spottime",     0.015];   // he has night vision
            _unit setSkill ["spotdistance", 0.015];
        } else {
            _unit setSkill ["spottime",     0.520];   // he does not
            _unit setSkill ["spotdistance", 0.520];
        };
    } else {
        _unit setSkill ["spottime",     1.000];
        _unit setSkill ["spotdistance", 1.000];
    };

    // And who he is
    switch (faction _unit) do {
        default {
            _unit setSkill ["general",    0.900];
            _unit setSkill ["commanding", 0.750];
            _unit setSkill ["aimingspeed",0.620];
        };
    };
};
```

---

## What you can branch on

| | |
|---|---|
| `ghostD_Settings_setAiSystemDifficulty` | The CBA setting — the top-level switch |
| `getLighting select 1` | Ambient light. `<= 5` is night |
| `hmd _unit` | Whether he has night vision |
| `faction _unit` | Who he fights for |
| `typeOf _unit`, `getUnitTrait` | Anything else the engine knows |

---

## Instructions

**Change a difficulty band:** edit the matching `if` block.

**Add a faction:** a `case` in the `switch (faction _unit)`. Keep `default` last
and populated — an unlisted faction falls to it.

**Add a condition:** any SQF that reads `_unit`. Keep it cheap; this runs for
every AI the mission spawns.

**Do not** `private` a new `_unit` or reassign it.

Related: [Other Systems](Other-Systems#ai-skill) &middot; [loadConfigs](loadConfigs)
