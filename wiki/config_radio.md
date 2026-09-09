# config_radio.hpp

> **In storage since 2026-09-05.** Every `ghost_radio_*` global here is a key of
> the `<unitId>.radio` document (`items: {srRadios, srChannels, mrChannels,
> lrChannels, srSquadChannel, ...}` - the name after the prefix, the value as
> written). TAC//PAC writes the globals from it at boot and on every client
> (`ghostD_pac_fnc_radioApply`) and re-programs the ACRE presets when the plan
> changed. A mission that still ships this file seeds the document and keeps
> working; `frameworkmongo.Stratis` does not ship it. The rules below still hold -
> the names in `mrChannels` must match the ORBAT's platoon and radio nets.

The comms plan. **Despite the `.hpp`, this is SQF** — it is run by
[loadConfigs](loadConfigs) and assigns `ghost_radio_*` globals directly, so
running it *is* the handover.

**Loads:** compiled at CBA preInit by `loadConfigs.sqf`. **Not** `#include`d.
**Read by:** `ghostD_gear_fnc_setupRadios`, `ghostD_players_fnc_getRadioChannel`,
`ghostD_players_fnc_platoonNet`.

It holds an ACRE block and a TFAR block. The mission uses whichever radio mod is
loaded and ignores the other — edit the one you run.

---

## Five rules

1. **A radio class belongs to ONE tier list.** Whichever list names it decides
   which plan is programmed into it.
2. **Channel numbers are 1-based.**
3. **MR channel names must match** `Platoons >> net` and `RadioNets >> net`
   **exactly.** That match is how a man is tuned.
4. **The SR channel is a squad's row in `group_setup`**, unless the table names it.
5. **Change a channel and re-run the face generators**, or the card painted on
   the radio model is lying.

---

## Tiers

```sqf
ghost_radio_srRadios = ["ACRE_PRC148"];    // everyone; his team and nobody else
ghost_radio_mrRadios = ["ACRE_PRC152"];    // leaders and specialists; the named nets
ghost_radio_lrRadios = ["ACRE_PRC117F"];   // vehicle racks; detachment and ground

ghost_radio_acreActiveRadio = "ACRE_PRC148";   // made active on spawn

ghost_radio_srPower = 100;    // the 148 takes 100, 500, 1000, 3000 or 5000 only
ghost_radio_mrPower = 250;
ghost_radio_lrPower = 5000;
```

Plumbing you rarely touch:

```sqf
ghost_radio_acreNoProgram  = ["ACRE_SEM70", "PRC-77"];   // work differently; get no preset
ghost_radio_acreLabelField = [["ACRE_PRC148","label"],["ACRE_PRC152","description"]];
ghost_radio_acreChannelCount = [["ACRE_PRC148", 100]];
```

---

## SR — the team net

`[channel, frequency, label]`. **Labels are cut at eight characters.**

```sqf
ghost_radio_srChannels = [
    [1,401,"1 PLT"],
    [2,402,"1-1 SQD"],
    [3,403,"1-1 A"]
];
```

Optional banks for the 148's GR knob:

```sqf
ghost_radio_srGroups = [
    ["G1 INF",  [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]],
    ["G2 MECH", [17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]]
];
```

Which channel a squad spawns on:

```sqf
ghost_radio_srSquadChannel = [
    ["BANSHEE 1-1", 2],
    ["BANSHEE 1-2", 5]
];
```

> **A squad not in this table falls back to its row index** in `group_setup`,
> times `ghost_radio_srBlockSize`, plus one. List every squad and the fallback
> never fires.

## MR — the named nets

```sqf
ghost_radio_mrChannels = [
    [1,100,"C2"],
    [2,110,"BANSHEE"],       // the arm nets - names must match config_groups
    [3,120,"NOMAD"],
    [6,151,"GROUND 1"],      // a rifle squad and the crew that carries it
    [15,180,"MEDICAL"]
];
```

## LR — the racks

A row's fourth element is that channel's power in mW; omit it and it takes
`ghost_radio_lrPower`.

```sqf
ghost_radio_lrChannels = [
    [1,50,"DETNET",20000],
    [5,54,"GNDNET",1000]
];

ghost_radio_lrSatChannel   = 1;
ghost_radio_lrLocalChannel = 5;
```

## Before a man joins a squad

```sqf
ghost_radio_srFallback = 1;
ghost_radio_mrDefault  = 1;
ghost_radio_lrDefault  = 1;
```

---

## How a man gets tuned

1. `ghost_radio_srSquadChannel` names his squad → that SR channel.
2. Otherwise his row index in `group_setup`.
3. For MR: `RadioNets` is checked **first**, then `Platoons`. The net name it
   returns is matched against `ghost_radio_mrChannels`.
4. No match → `ghost_radio_mrDefault`.

---

## TFAR

By **platoon**, not by team — two tiers of eight channels.

```sqf
ghost_radio_tfarSrFreqs = ["500","100","101","200","201","300","301","400"];
ghost_radio_tfarLrFreqs = ["50","51","52","53","54","55","56","57"];

// [squad, SW channel index, LR channel index] - 0-based
ghost_radio_tfarNets = [["BANSHEE 1-1", 0, 3], ["NOMAD 2-1", 1, 4]];
ghost_radio_tfarSwFallback = 3;
ghost_radio_tfarLrFallback = 0;
```

**List every squad.** TFAR matches on the name and has no platoon fallback.

---

## After any channel change

```
python tools/gen_radio_faces.py
python tools/gen_prc148_faces.py
```

The card on the PRC-148 model is generated from this file and does not update
itself.

Related: [Comms Plan](Comms-Plan) &middot; [config_groups](config_groups) &middot; [config_nets](config_nets)
