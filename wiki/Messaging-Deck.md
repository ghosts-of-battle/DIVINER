# Messaging deck

`config\config_messaging.hpp` declares `class GHOST_Templates` — the TAC//MSG
smart-card deck. Every report a player can send, and every reply a report can be
answered with.

This was several hundred lines of SQF inside the mod. It is config now, read at
preInit through `missionConfigFile`, so a new card or an extra line on an
existing one needs **no mod rebuild**.

---

## Two things here are contracts, not presentation

### 1. A line's `name` **is** its field key

The engine strips whitespace from it and appends a letter per field:

| `name` | Produces |
|---|---|
| `"Line 1"` | `Line1.A`, `Line1.B`, `Line1.C`, … |
| `"S"` | `S.A` |
| `"Callsign"` | `Callsign.A` |

The ALiVE forwarder finds a CONTACTREP's S/A/L/U/T/E/R and a SITREP's
Callsign/Location/Enemy/Friendly/Civ/Status/Remarks **by those keys**.

> **Rename a line's `name` and you have renamed a field.** Renaming its `prefix`
> is safe — that is only what the player reads on screen.

### 2. `lineOrder[]` is the order

The cards are filled in top to bottom in the order named there, not in the order
the classes happen to appear. **Add a line and you must add its class name to
`lineOrder[]` or it is not shown.**

> It is not called `lines[]`, and it cannot be. Config names are
> **case-insensitive**, so an array called `lines[]` and a class called `Lines`
> are the same identifier — the parser says "Member already defined" and the
> file will not load.

---

## Shape

```cpp
class GHOST_Templates {
    class CONTACTREP {
        displayName = "CONTACT REPORT";
        short = "CONTACT";
        lineOrder[] = {"S", "A", "L", "U", "T", "E", "R"};

        class Lines {
            class S {
                name = "S";            // the field key
                prefix = "SIZE";       // what the player reads
                fields[] = { /* ... */ };
            };
            class A {
                name = "A";
                prefix = "ACTIVITY";
                fields[] = { /* ... */ };
            };
        };
    };
};
```

---

## Adding a card

1. Add a class under `GHOST_Templates`.
2. Give it `displayName` and `short`.
3. Write its `class Lines`, one class per line.
4. **List every line class name in `lineOrder[]`.**
5. If the report is meant to forward to ALiVE, use the field keys the forwarder
   expects — see the existing CONTACTREP and SITREP.

## Adding a line to an existing card

1. Add the line class under that card's `class Lines`.
2. Add its class name to `lineOrder[]` in the position you want it.

Forget step 2 and the line exists, validates, and is never drawn.

---

## Related

- Which nets a card can be sent on comes from the player's role — see
  [Nets](Nets).
- The reply buttons under the reader (ROGER / WILCO / WAIT ONE / …) are part of
  the same deck.

Next: [Other Systems](Other-Systems).
