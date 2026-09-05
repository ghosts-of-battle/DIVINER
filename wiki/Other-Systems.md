# Other systems

The remaining configs. All optional — add them when you want them.

---

## Admins

`config\config_admins.hpp`. **One Steam ID list, three grants:** the debug
console, the CBA settings whitelist, and TAC//ADMIN.

```cpp
#define ADMINS \
    "76561198000000000", /* You */ \
    "76561198000000001"  /* Someone else */

/* Nothing to edit below here. */
#define DEBUG_ADMINS ADMINS
#define CBA_ADMINS ADMINS

class CfgGhostAdmins {
    admins[] = {ADMINS};
};
```

Then in `description.ext`:

```cpp
enableDebugConsole[] = {DEBUG_ADMINS};
cba_settings_whitelist[] = {CBA_ADMINS};
```

> **Include it first** in `description.ext` — the arrays below expand its macros.

This used to be two files saying the same thing, which is two lists to keep in
step and one of them always out of date.

---

## Logistics

`config\config_logistics.sqf` — crate contents keyed by name. An **SQF** config;
see [How Config Loads](How-Config-Loads).

```sqf
[
    ["crate_rifle", [
        ["ACE_fieldDressing", 40],
        ["SmokeShell", 15],
        ["30Rnd_65x39_caseless_mag", 30]
    ]],
    ["crate_medical", [
        ["ACE_bloodIV", 12],
        ["ACE_morphine", 20]
    ]]
]
```

Handed over as `ghost_missionConfig_logistics`; the mod turns it into hashmaps.
The shape of the data is the mission's business, the shape of the database is
the mod's.

---

## AI skill

`config\config_skill.hpp` — the only config in the tree that is **statements
rather than data**. Conditionals on difficulty setting, ambient light, whether
the unit has a headset, and faction.

```sqf
if (ghost_Settings_setAiSystemDifficulty == 1) then {
    _unit setSkill ["aimingspeed",    0.420];
    _unit setSkill ["aimingaccuracy", 0.500];
    _unit setSkill ["spottime",       0.800];
};

if (ghost_Settings_setAiSystemDifficulty == 2) then {
    if (getLighting select 1 <= 5) then {
        if (hmd _unit != "") then {
            _unit setSkill ["spottime", 0.015];   // he has night vision
        } else {
            _unit setSkill ["spottime", 0.520];   // he does not
        };
    };
};
```

It is compiled into a function the mod calls **per unit**, with the unit bound:

```sqf
ghost_missionConfig_skillBlock = compile ("private _unit = _this; " + preprocessFileLineNumbers "config\config_skill.hpp");
```

> The file is written against the name `_unit`. Rename that variable and every
> `setSkill` in it stops resolving.

---

## TAC//PAD colour schemes

`config\config_tacpad.hpp` — your unit's own presets, shown in the tacpad
SETTINGS app under COLOUR SCHEME as a second row headed MISSION PRESETS, drawn
exactly like the six the mod ships.

```cpp
class GHOST_TacpadSchemes {
    class NightBlue {
        name = "NIGHT BLUE";        // uppercased on screen; about 12 characters fit
        ground = "#0B1016";
        ink    = "#DCE3EA";
        accent = "#3C7DD9";
    };
};
```

**Three tokens and nothing else.** Divider weight, tints and pressed states are
all derived from those, which is why there is no fourth field.

- Hex, with or without the hash. The older `"r,g,b"` 0–1 form still reads.
- An entry missing any of the three is skipped with an RPT warning rather than
  drawn as a black card.
- **Three cards per row.** Six is two rows and still fits; past that the row
  starts eating the swatch strips under it.

Why it is here and not in the mod: the alternative was every player reassembling
the same three colours by hand off the swatch strips, which is a colouring
exercise twenty people get slightly differently.

---

## The welcome screen

`config\config_welcome.hpp` — shown once the mission display is up, drawn by the
mod's modal.

```cpp
class GHOST_Welcome {
    title = "GHOSTS OF BATTLE";
    subtitle = "TASK FORCE ROOMBA - HORIZON ISLANDS, 2040";
    lines[] = {
        // {text, size, {r,g,b}, align}   align: 0 left, 1 centre, 2 right
        {"SITUATION", 1.15, {1,0.33,0.33}, 0},
        {"Long paragraph of structured text. <br/> works inside it.", 0.9, {1,1,1}, 0}
    };
};
```

`title` and `subtitle` are the two halves of the title bar. Text is structured
text, so `<br/>` works.

Read by `initPlayerLocal.sqf` → `ghost_common_fnc_modal`. **Delete the whole
class and nothing is shown.**

---

## Sounds

`config\config_sounds.hpp` — mission `CfgSounds`.

```cpp
class CfgSounds {
    sounds[] = {};
};
```

Ship it empty. It is here so that adding a sound is an edit to one file rather
than a new file and a new include.

---

Back to [Home](Home).
