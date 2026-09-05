# Troubleshooting

The framework **warns rather than fails** on most misconfiguration, so the
mission boots and the mistake is visible only in the log. Search the RPT for
`[ghost]`.

---

## Read this line first

`config\loadConfigs.sqf` logs one line naming all four SQF config counts:

```
[ghost] (mission) INFO: configs handed to the mod - logistics 24, pylons 18, radio true, skill true
```

A `0` or a `false` means that file failed to compile, and the parse error is
above it in the RPT. Nothing else on this page matters until that line is clean.

---

## Symptom → cause

### Roles and the role screen

| Symptom | Look at |
|---|---|
| Role screen is empty | `group_setup[]` exists, and `config_groups.hpp` is `#include`d in `description.ext` |
| A slot draws with no name or card | Its role class is missing from `config_roles.hpp`'s include list |
| A squad appears under `UNASSIGNED` | It is in `group_setup` but in no `Platoons` tab. The RPT names it |
| A platoon tab is missing | You have more than ten. The RPT names the dropped ones |
| Nobody can take a slot | Its `Role_Access` `minRank` is higher than any rank anyone in `Dynamic_Ranks` holds |
| A rank gate does nothing | The `Role_Access` class name does not match the role class name |

### Comms

| Symptom | Look at |
|---|---|
| Everyone is on the same radio channel | `ghost_radio_srSquadChannel` names are not matching `group_setup` names |
| A man is on the detachment default instead of his platoon net | The `net` value has no matching name in `ghost_radio_mrChannels` |
| An MR channel exists but nobody spawns on it | `RadioNets` covers those squads, and it is asked before `Platoons` |
| The radio's painted card disagrees with the plan | Re-run `tools/gen_radio_faces.py` and `tools/gen_prc148_faces.py` |
| A team's channel moved on its own | A squad was inserted above it in `group_setup`, and it has no `ghost_radio_srSquadChannel` row |

### Nets and messaging

| Symptom | Look at |
|---|---|
| The nets rail shows a net nobody can open | The net is declared but the role's `nets[]` does not list it |
| A role sees no nets at all | Its `nets[]` is empty. No configured value, no access — that is the rule |
| Every role sees every net | No role in the mission declares `nets[]`, so the gate is off entirely |
| Reports forward with empty fields | A line's `name` in `config_messaging.hpp` was renamed. Change the `prefix` instead |
| A new report card does not appear | Its class is not in `lineOrder[]` |

### Arsenal

| Symptom | Look at |
|---|---|
| An arsenal list is ignored | The array is not named `weapons`, `magazines`, `backpacks` or `items*` |
| A per-element arsenal is ignored | The `Arsenal_<X>` class is nested inside `Dynamic_Roles` instead of being top-level, or `groupArsenal` is missing from the role |
| A man spawns with a rifle and no ammunition | His `defaultLoadout[]` pairs a weapon with a magazine it does not take — check after any weapon swap |
| A man spawns without his suppressor or optic | The attachment is not compatible with the weapon class in `defaultLoadout[]` |

### Vehicles

| Symptom | Look at |
|---|---|
| A vehicle is missing from the motorpool | Normal if its mod is not loaded — absent classes are skipped. Otherwise check the category name matches between common and element |
| An element sees the common pool only | No `MotorPool_<Callsign>` for the first word of its group id. Often correct |
| A vehicle has no pylon preset menu | No entry in `config_pylons.sqf` whose base class it `isKindOf` |

---

## When a whole file seems to do nothing

Check which loading path it should be taking — see
[How Config Loads](How-Config-Loads).

- A file with `class` in it must be `#include`d in `description.ext`.
- A file with statements or bare arrays must be named in `loadConfigs.sqf`.
- A file on **neither** list is read by nobody, and nothing will say so.

---

## Verifying the mod itself

```
python tools/check_all.py     # the gate: hemtt check + 9 custom checks
hemtt check                   # HEMTT lints alone
```

Note that `check_all.py` does **not** catch every HEMTT lint level — some
`help`-level findings (undefined variables among them) only surface on
`hemtt build` or `hemtt release`. If you are touching mod SQF, run a build
before trusting the gate.
