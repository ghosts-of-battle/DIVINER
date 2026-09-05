# config_logistics.sqf

The supply catalogue — crate contents, keyed by name.

**Loads:** compiled at CBA preInit by [loadConfigs](loadConfigs) into
`ghost_missionConfig_logistics`. **SQF**, not a class config.
**Read by:** the logistics system, which turns it into hashmaps.

The shape of the data is the mission's business; the shape of the database is
the mod's.

---

## Shape

The whole file is one array of `[crate name, [contents]]`.

```sqf
[
    //REQUIRED
    ["crate_medicalInfantry", [
        // Catastrophic Bleeding
        ["ACE_tourniquet", 24],
        // Circulation
        ["ACE_epinephrine", 10]
    ]],

    ["crate_tow", [
        ["launch_B_Titan_short_F", 1],
        ["Titan_AT", 4]
    ]],

    ["crate_mo", [
        ["ACE_1Rnd_82mm_Mo_HE_Guided", 8],
        ["ACE_1Rnd_82mm_Mo_HE", 16],
        ["ACE_1Rnd_82mm_Mo_Smoke", 8]
    ]]
]
```

Each content row is `["<classname>", <count>]`.

---

## Instructions

**Add an item to a crate:** one row.

**Add a crate:** a new `["crate_<name>", [...]]` entry, then have whatever
places it ask for that name.

**Crates marked `//REQUIRED`** are ones the mod or the mission scripts expect by
name. Renaming one breaks the thing that asks for it — add a new crate instead.

**Comment your groupings.** The medical crates in the reference mission are
grouped by the MARCH order (catastrophic bleeding, airway, breathing,
circulation, disability), with empty headings left in place so the next person
knows where a new item goes.

**Commented-out crates are fine** — SQF, so `//` works, unlike in a config
class.

Related: [Other Systems](Other-Systems#logistics) &middot; [loadConfigs](loadConfigs)
