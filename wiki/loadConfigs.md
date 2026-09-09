# loadConfigs.sqf

`config\loadConfigs.sqf` — the second door in. It compiles the four SQF configs
and hands them to the mod.

**Loads:** registered as a CBA preInit handler in
[description.ext](description-ext).

Copy it from the reference mission unchanged. It is the same in every mission;
only the four filenames it names would ever change.

---

## What it does

```sqf
// Raw catalogues. The mod turns these into hashmaps; the shape of the data is
// the mission's business, the shape of the database is the mod's.
ghost_missionConfig_logistics = call compileFinal preprocessFileLineNumbers "config\config_logistics.sqf";
ghost_missionConfig_pylons    = call compileFinal preprocessFileLineNumbers "config\config_pylons.sqf";

// The radio plan assigns its own ghost_radio_* globals, so running it IS the
// handover - there is nothing for the mod to fetch afterwards.
call compile preprocessFileLineNumbers "config\config_radio.hpp";

// The AI skill block is STATEMENTS, not data. It is compiled into a function
// the mod calls per unit, with the unit bound to the name the file expects.
ghost_missionConfig_skillBlock = compile ("private _unit = _this; " + preprocessFileLineNumbers "config\config_skill.hpp");

// AND TELL THE MOD.
if (!isNil "ghostD_init_fnc_missionConfigsReady") then {
    call ghostD_init_fnc_missionConfigsReady;
};
```

---

## Why it runs from the mission

It lives in the mission and runs from there, so every path is relative to the
mission wherever that mission lives.

Having the **mod** do this broke three ways:

- a relative path resolves against the **caller**, and the caller was a PBO
- `getMissionPath` returns an **absolute** path, which
  `preprocessFileLineNumbers` refuses outright
- the mod initialises in **every** mission, including the main-menu scene, which
  has no `config` folder at all

## Why the handover call exists

CBA runs addon preInit handlers **before** the mission's, so the mod's `init`
addon (`ghostD_init`) has already gone past the point where it wanted this
data. It leaves the build to
whoever gets there with real data — which is that last line.

---

## The line to check first

```
[ghost] (mission) INFO: configs handed to the mod - logistics 24, pylons 18, radio true, skill true
```

A `0` or a `false` means that file failed to compile, and the parse error is
above it in the RPT. **Read this before debugging anything else.**

---

## Adding your own SQF config

1. Write the file under `config\`.
2. Add a line here assigning it to a global.
3. Have the mod read that global — or, if it assigns its own globals like the
   radio plan does, running it is enough.
4. Add it to the `diag_log` line so a failure is visible.

Related: [How Config Loads](How-Config-Loads) &middot; [Troubleshooting](Troubleshooting)
