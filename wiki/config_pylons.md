# config_pylons.sqf

Pylon and turret loadout presets, offered on the ACE self-interaction menu and
the MOTORPOOL screen.

**Loads:** compiled at CBA preInit by [loadConfigs](loadConfigs) into
`ghost_missionConfig_pylons`. **SQF**, not a class config.
**Read by:** `ghost_vehicle_fnc_addPylonSelection`.

---

## Shape

The whole file is one array of `[base class, [presets]]`.

```sqf
[
    ["B_AFV_Wheeled_01_up_cannon_F", [

        ["default", [
            ["displayName", "Heavy HEATFS-T"],
            ["icon", ""],
            ["loadout", [
                //  magazine                          turret path   rounds
                ["FA_30Rnd_120mm_HEATMP_T_Blue",       [0],          8],
                ["4Rnd_120mm_LG_cannon_missiles",      [0],          4],
                ["SmokeLauncherMag",                   [0,0],        6]
            ]]
        ]],

        ["balanced", [
            ["displayName", "Balanced"],
            ["icon", ""],
            ["loadout", [
                ["FA_30Rnd_120mm_HEATMP_T_Blue", [0], 12],
                ["FA_30Rnd_120mm_APFSDS_T_Blue", [0], 12]
            ]]
        ]]
    ]]
]
```

| Level | What |
|---|---|
| Outer | `["<base class>", [presets]]` |
| Preset | `["<preset id>", [["displayName", …], ["icon", …], ["loadout", […]]]]` |
| Loadout row | `["<magazine>", <turret path>, <rounds>]` |

**Turret path** is the standard Arma turret path — `[0]` is the main turret,
`[0,0]` a turret on it, `[]` the driver's position.

---

## The key is a base class

> Matched with **`isKindOf`**, so one entry covers every variant that inherits
> from it: `"VVE_APC_Wheeled_01_mgs_QAV"` covers
> `B_T_APC_Wheeled_01_mgs_QAV` and everything else descended from it.

A motorpool class with **no ancestor in this file simply gets no preset menu** —
that is not an error, just no menu.

---

## Instructions

**Add a preset to an existing vehicle:** another `["<id>", [...]]` entry in that
vehicle's list.

**Add a vehicle:** a new `["<base class>", [...]]` entry. Use the most general
base class that should get the menu.

**Repeat a magazine row** to fill several pylons with the same thing — the rows
are applied in order, one per pylon.

**Check the rounds count** against the magazine's real capacity; over-filling is
silently clamped and looks like the preset did nothing.

Related: [Motorpool and Vehicles](Motorpool-and-Vehicles#pylons) &middot; [loadConfigs](loadConfigs)
