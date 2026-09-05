# Comms plan

> **In storage since 2026-09-05.** Every `ghost_radio_*` global here is a key of
> the `<unitId>.radio` document (`items: {srRadios, srChannels, mrChannels,
> lrChannels, srSquadChannel, ...}` - the name after the prefix, the value as
> written). TAC//PAC writes the globals from it at boot and on every client
> (`ghost_pac_fnc_radioApply`) and re-programs the ACRE presets when the plan
> changed. A mission that still ships this file seeds the document and keeps
> working; `frameworkmongo.Stratis` does not ship it. The rules below still hold -
> the names in `mrChannels` must match the ORBAT's platoon and radio nets.

`config\config_radio.hpp`. Despite the `.hpp` this is **SQF** — it is run by
`loadConfigs.sqf` and assigns `ghost_radio_*` globals directly, so running it
*is* the handover. See [How Config Loads](How-Config-Loads).

It holds a block for ACRE and a block for TFAR. The mission uses whichever radio
mod is loaded and ignores the other; edit the one you run.

---

## Five rules

Break one of these and the symptom is a man on the wrong channel.

1. **A radio class belongs to ONE tier list.** Whichever list names it decides
   which plan gets programmed into it.
2. **Channel numbers are 1-based.**
3. **MR channel names must match** `Dynamic_Groups >> RadioNets >> net` and
   `>> Platoons >> net` **exactly.** That match is how a man is tuned.
4. **The SR channel is a squad's row in `group_setup`**, unless the table below
   names it. Reorder the roster and every team's channel moves.
5. **Change any channel and re-run the face generators**, or the card painted on
   the radio is lying to whoever reads it.

---

## Tiers

```sqf
ghost_radio_srRadios = ["ACRE_PRC148"];    // everyone; his team, and nobody else
ghost_radio_mrRadios = ["ACRE_PRC152"];    // leads, ATLs, JFOs, medics; the named nets
ghost_radio_lrRadios = ["ACRE_PRC117F"];   // vehicle racks; the detachment and the ground net
```

Transmit power, in mW:

```sqf
ghost_radio_srPower = 100;     // the 148 takes 100, 500, 1000, 3000 or 5000 only
ghost_radio_mrPower = 250;
ghost_radio_lrPower = 5000;
```

### Radio reference

Bands and channel counts read out of ACRE itself; strength and range from the
ACRE wiki.

| Radio | Band | Channels | Power | City | Open |
|---|---|---|---|---|---|
| PRC-343 | 2.400–2.483 GHz | 256 | 100 mW | 400 m | 850 m |
| PRC-148 | 30–512 MHz | 32 * | 5 W | 3–5 km | 5–7 km |
| PRC-152 | 30–512 MHz | 100 | 5 W | 3–5 km | 5–7 km |
| PRC-117F | 30–512 MHz | 100 | 20 W | 10–20 km | horizon |

\* the radio holds 100, but ACRE's four shipped 148 presets fill 32 and
`acre_api_fnc_setPresetChannelField` will not write past what a preset holds.

The 148, 152 and 117F share 30–512 MHz, so a frequency used on one tier is live
on the others.

---

## SR — the team net

`[channel, frequency, label]`. **Labels are cut at eight characters** on the
radio display.

```sqf
ghost_radio_srChannels = [
    [1,401,"1 PLT"],
    [2,402,"1-1 SQD"],
    [3,403,"1-1 A"],
    [4,404,"1-1 B"]
];
```

Optionally carve the flat list into banks for the 148's GR knob:

```sqf
ghost_radio_srGroups = [
    ["G1 INF", [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]],
    ["G2 MECH", [17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]]
];
```

Which channel a squad spawns on:

```sqf
ghost_radio_srSquadChannel = [
    ["GHOST 6", 14],
    ["BANSHEE 1-1", 2],
    ["BANSHEE 1-2", 5]
];
```

**A squad not in that table falls back to its row index in `group_setup`**,
multiplied by `ghost_radio_srBlockSize` plus one. List every squad and the
fallback never fires.

---

## MR — the named nets

```sqf
ghost_radio_mrChannels = [
    [1,100,"C2"],            // the detachment net
    [2,110,"BANSHEE"],       // the four arm nets - one per platoon, named for it
    [3,120,"NOMAD"],
    [4,130,"TALON"],
    [5,140,"WRAITH"],
    [6,151,"GROUND 1"],      // a rifle squad and the crew that carries it
    [10,161,"AIR 1"],        // one per airframe
    [14,170,"CAS"],
    [15,180,"MEDICAL"]
];
```

### How a man gets tuned

1. `ghost_radio_srSquadChannel` names his squad → that SR channel.
2. Otherwise his row index in `group_setup`.
3. For MR: `RadioNets` is checked **first**, then `Platoons`. Whichever names
   his squad gives a net name, matched against `ghost_radio_mrChannels`.
4. No match anywhere → `ghost_radio_mrDefault`.

> Step 3 has a consequence worth knowing. If `RadioNets` covers every squad in a
> platoon, nobody in that platoon ever reaches its `Platoons` net — the channel
> exists and nothing spawns on it.

---

## LR — the racks

Two PRC-117Fs ride in every vehicle. A row's fourth element is that channel's
power in mW; leave it off and it takes `ghost_radio_lrPower`.

```sqf
ghost_radio_lrChannels = [
    [1,50,"DETNET",20000],
    [2,360,"FIRES",20000],
    [5,54,"GNDNET",1000]
];

ghost_radio_lrSatChannel   = 1;    // what the SAT rack spawns on
ghost_radio_lrLocalChannel = 5;    // what the GND rack spawns on
```

---

## Before a man joins a squad

```sqf
ghost_radio_srFallback = 1;
ghost_radio_mrDefault  = 1;
ghost_radio_lrDefault  = 1;
```

---

## The painted radio faces

The card on the PRC-148 model is **generated from this file**. After changing
any channel, label or bank:

```
python tools/gen_radio_faces.py
python tools/gen_prc148_faces.py
```

Skip it and the radio in a player's hands shows last week's plan.

---

## TFAR

The TFAR block is by **platoon**, not by team — two tiers of eight channels.

```sqf
ghost_radio_tfarSrFreqs = ["500","100","101","200","201","300","301","400"];
ghost_radio_tfarLrFreqs = ["50","51","52","53","54","55","56","57"];

// [squad, SW channel index, LR channel index] - 0-based
ghost_radio_tfarNets = [
    ["BANSHEE 1-1", 0, 3],
    ["NOMAD 2-1",   1, 4]
];
```

**List every squad.** TFAR matches on the name and has no platoon fallback.

Next: [Arsenal](Arsenal).
