# Messaging deck

`config\config_messaging.hpp` declares `class GHOSTFR_Templates` — the TAC//MSG
smart-card deck. Every report a player can send, and every reply a report can be
answered with.

**TAC//MSG is a threaded messaging system.** Every report a player sends opens
a thread with its own id (`T0001`); replies, acknowledgements and the quick
phrases go under it; the thread carries a state that the cards move
(`transitionsTo` — open, claimed, closed); and a player can follow or mute one
thread over the net's own setting. A net is read as one conversation, every
thread filed to it in order, and the map-side reader opens a thread beside the
ground it is about. The deck on this page is what starts a thread and what
answers one.

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

Everything that reads a filed report — the reader card, the OPORD and
METT-TC autofill, the CASEVAC anchor — finds a CONTACTREP's S/A/L/U/T/E/R
and a SITREP's Callsign/Location/Enemy/Friendly/Civ/Status/Remarks **by
those keys**.

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
class GHOSTFR_Templates {
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

1. Add a class under `GHOSTFR_Templates`.
2. Give it `displayName` and `short`.
3. Write its `class Lines`, one class per line.
4. **List every line class name in `lineOrder[]`.**
5. Copy the field keys of an existing card (CONTACTREP, SITREP) rather than
   inventing new ones — the reader and the autofills look fields up by name.

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
- A mission whose config lives in the **database** ships no
  `config_messaging.hpp` at all - the deck is the `<unit>.templates` document,
  registered by `ghostD_pac_fnc_templatesApply`. See
  [config_messaging](config_messaging#when-there-is-no-config_messaginghpp).

Next: [Other Systems](Other-Systems).
