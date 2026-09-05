# config_messaging.hpp

The TAC//MSG smart-card deck: every report a player can send, and every reply a
report can be answered with.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `GHOST_Templates`.
**Read by:** `ghost_messaging_fnc_loadTemplates`.

This was several hundred lines of SQF inside the mod. It is config now, so a new
card or an extra line needs **no mod rebuild**.

---

## A template

```cpp
class GHOST_Templates {
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

The ALiVE forwarder finds a CONTACTREP's S/A/L/U/T/E/R and a SITREP's
Callsign/Location/Enemy/Friendly/Civ/Status/Remarks **by those keys**.

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

**Add a card:** a class under `GHOST_Templates`; give it `title`, `short`,
`lineOrder[]` and a `class Lines`; list every line class in `lineOrder[]`.

**Add a line to an existing card:** the line class, then its name in
`lineOrder[]`. Forget the second step and the line exists, validates, and is
never drawn.

**Forwarding to ALiVE:** use the field keys the forwarder expects — copy the
existing CONTACTREP and SITREP rather than inventing keys.

Related: [Messaging Deck](Messaging-Deck) &middot; [config_nets](config_nets)
