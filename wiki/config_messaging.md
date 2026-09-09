# config_messaging.hpp

The smart-card deck of TAC//MSG, the threaded messaging system: every report a
player can send — each one opens a thread — and every reply a report can be
answered with — each one goes under that thread and can move its state.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `GHOSTFR_Templates`.
**Read by:** `ghostD_messaging_fnc_loadTemplates`.

This was several hundred lines of SQF inside the mod. It is config now, so a new
card or an extra line needs **no mod rebuild**.

---

## A template

```cpp
class GHOSTFR_Templates {
    class casevac {
        title = "6-LINE CASEVAC";
        short = "CASEVAC";
        priority = "high";
        anchor = "Line1.A";
        transitionsTo = "ISSUED";
        replyableWith[] = {"roger","wilco","inprogress","cantco","freetext","close"};
        subject = "CASEVAC {Line2.A} pax - {Line1.A}";
        lineOrder[] = {"Line1","Line2","Line3","Line4","Line5","Remarks"};

        class Lines {
            class Line1 {
                name = "Line 1";                    // THE FIELD KEY
                label = "PICK-UP SITE LOCATION";    // what the player reads
                class Fields {
                    class A {
                        prefix = "";
                        hint = "Grid / map position of the pick-up site";
                        type = "grid";
                        required = 1;
                        source = "mapClick";
                    };
                };
            };
        };
    };
};
```

| Property | What |
|---|---|
| `title` | The card's name in the picker |
| `short` | The compressed label on a thread row |
| `priority` | `"high"` rings; anything else badges |
| `anchor` | Which field supplies the map marker |
| `transitionsTo` | The thread status the card sets |
| `replyableWith[]` | Which reply cards may answer it |
| `subject` | The thread subject. `{Line2.A}` interpolates a field |
| `lineOrder[]` | **The order the card is filled in** |

Per field: `prefix`, `hint`, `type` (`grid`, `text`, `number`, …), `required`,
`source` (e.g. `mapClick`).

---

## Two things here are contracts, not presentation

### 1. A line's `name` **is** its field key

Whitespace is stripped and a letter appended per field:

| `name` | Produces |
|---|---|
| `"Line 1"` | `Line1.A`, `Line1.B`, … |
| `"S"` | `S.A` |
| `"Callsign"` | `Callsign.A` |

Everything that reads a filed report — the reader card, the OPORD and
METT-TC autofill, the CASEVAC anchor — finds a CONTACTREP's S/A/L/U/T/E/R
and a SITREP's Callsign/Location/Enemy/Friendly/Civ/Status/Remarks **by
those keys**.

> **Rename a line's `name` and you have renamed a field.** Renaming its `label`
> or a field's `prefix` is safe — those are only what the player reads.

### 2. `lineOrder[]` is the order

The card is filled top to bottom in the order named there, not the order the
classes appear. **A line missing from `lineOrder[]` is not shown.**

> It is not called `lines[]` and it cannot be. Config names are
> **case-insensitive**, so `lines[]` and `class Lines` are the same identifier —
> the parser says "Member already defined" and the file will not load.

---

## Instructions

**Add a card:** a class under `GHOSTFR_Templates`; give it `title`, `short`,
`lineOrder[]` and a `class Lines`; list every line class in `lineOrder[]`.

**Add a line to an existing card:** the line class, then its name in
`lineOrder[]`. Forget the second step and the line exists, validates, and is
never drawn.

**Copy an existing card's keys** rather than inventing new ones — the
reader and the autofills look a field up by name, and a new name is a field
nothing reads.

---

## When there is no config_messaging.hpp

A mission whose config lives in the **database** does not ship this file at all.
`frameworkmongo.Stratis` is the worked example: its `config\` folder has no
`config_messaging.hpp`, and none of `config_groups.hpp`, `config_nets.hpp`,
`config_radio.hpp`, `config_roles.hpp` or `config_tacpad.hpp` either. That is
not a missing file - it is where the deck lives.

The deck is the `<unit>.templates` document instead, one entry per template
under `items`, in the shape `ghostD_messaging_fnc_registerTemplate` takes
(`title`, `short`, `lines`, `options`). `ghostD_pac_fnc_templatesApply`
registers it on the server after the structure is final, and on every client as
it takes the server's structure - so the registry is identical everywhere
before anyone composes.

**The file wins where both exist.** `ghostD_messaging_fnc_loadTemplates` runs at
preInit and registers `GHOSTFR_Templates` if the mission has it;
`templatesApply` then skips any id already registered. So a mission that ships
the file gets the file's deck, and a mission that does not gets the database's.
Nothing merges the two card by card.

You will see this in the server `.rpt` when the file is absent, which is
information rather than a fault:

```
no GHOSTFR_Templates class in the mission config - the report deck comes with
TAC//PAC's structure, if the unit keeps one
```

To add a card to a database-backed unit, edit the `<unit>.templates` document -
through the web manager, or `pac_sync.py`, or the admin page's STRUCTURE
IN/OUT. It is read at the next mission start.

Related: [Messaging Deck](Messaging-Deck) &middot; [config_nets](config_nets)
