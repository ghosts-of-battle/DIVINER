# Intel packages

What a hack tells you is something you wrote.

There used to be six products — LOCATE AA, ARTILLERY, CAMP, LOGISTICS, RADAR,
INSTALLATION — and each one asked the simulation where it had put something
and drew a shrinking circle round the answer. That meant the intelligence in your mission
was whatever the simulation happened to contain. You could not write a document,
hand over a photograph, or decide that breaking into *this* terminal tells the
players about *that* dockyard.

Now you can. You write the files, you put them on a device, and a hack hands
over a share of them.

---

## The three pieces

1. **A package** — a class in your mission config. The files themselves.
2. **A Ghost - Intel Package module** — put in Eden or by Zeus, naming a package
   and pointing at a device.
3. **The TAC//INTEL app** — where what a hack recovers ends up. Nothing to set up.

---

## 1. Writing a package

In your mission config, under `Ghost_IntelPackages`:

```cpp
class Ghost_IntelPackages {
    class dockyard {
        name = "PORT SURVEY";               // what the app calls the folder

        class entries {
            class berths {
                title = "BERTHS 4-7";
                text  = "Two coastal freighters alongside. Deck cargo under \
                         tarpaulin on the aft hold of the northern vessel.";
            };
            class manifest {
                title = "CARGO MANIFEST";
                text  = "Nine containers, six declared as agricultural machinery.";
                image = "images\intel\manifest.paa";
            };
            class watch {
                title = "WATCH ROTATION";
                text  = "Two men on the gate, relieved on the hour.";
            };
        };
    };
};
```

| Property | Where | What |
|---|---|---|
| `name` | package | The folder name in the app. Falls back to the class name in capitals |
| `title` | entry | The file name in the list. Shows as UNTITLED if you leave it out |
| `text` | entry | The body |
| `image` | entry | Optional. A `.paa` path, relative to the mission |

**An entry with no title, no text and no image is skipped** with a line in the
RPT. It would otherwise arrive as a blank row and read as a bug.

### Order is the thing to get right

Entries are handed over **from the top**, and a hack yields a *share*. Somebody
who breaks in once and never comes back gets the first entries and nothing else.

So: **put the meat first and the colour last.** The watch rotation above is at
the bottom on purpose.

---

## 2. Putting it on a device

Place a **Ghost - Intel Package** module.

| Attribute | What |
|---|---|
| Package | The class name — `dockyard` in the example above |
| Terminal Class | What to build if you synchronise the module to nothing. Defaults to `Land_DataTerminal_01_F` |

**Synchronise it to something, or it builds its own terminal.** Attached to an
object, that object carries the package and becomes hackable *whatever it is* —
a laptop, a crate, a body. Attached to nothing, a data terminal appears where the
module stands, which is the usual case in Zeus.

**A typo is reported when you place it**, not when a player hacks the terminal
and is told there is nothing on it. If the package is not in your config, the
module says so in the RPT and on the Zeus's screen while you are still standing
next to it.

One package per device. A second module on the same object replaces the first.

---

## 3. What the players do

Anyone with the ISR trait opens **TAC//PAD → INTRUSION**, selects the device, and
picks **DOWNLOAD FILES**. What comes off it appears in **TAC//PAD → INTEL**,
filed under the package's name.

**The files belong to the side, not the man.** Somebody who was nowhere near the
terminal reads what the section brought back, and somebody who hacked it and then
died has not taken the intelligence with him. That is what makes recovering intel
worth doing rather than just seeing it.

### A hack gives a share, not the lot

*Ghosts of Battle → Hacking → Intel package share per hack (%)*, default **34** —
about a third, so three visits empty a terminal.

It is a percentage of the package's own length, so a three-entry package and a
thirty-entry one both take about three visits. Write as much as the story needs
and ignore this number.

- **A share that rounds to nothing still hands over one entry.** A successful
  hack that delivered silence reads as a bug to the man who did it.
- **Never the same entry twice.** Each side keeps its own tally per device, so a
  second hack continues where the first stopped.
- **When it is empty it says so**, and says it differently from "there was never
  anything here" — those are different facts about your mission.
- **100% is one hack, everything**, if that is the shape you want.

The gate on hacking at all is the **ISR trait**, not an item — see
[Custom Traits](Custom-Traits). There is no Intrusion Tablet.

---

## What survived from the old products

Three hunts still draw a circle, because they read objects that are actually on
the map rather than a simulation's profiles:

| Product | Reads |
|---|---|
| LOCATE ANTI-SHIP | `ghostD_antiship_batteries` |
| LOCATE RADAR | `ghostD_antiship_radars` |
| LOCATE JAMMER | the jamming registry — see the Jammer Site module |

They appear in the menu only when there is something of that kind on the map.

---

See also: [Custom Traits](Custom-Traits) for the ISR gate,
[config_tacpad](config_tacpad) for the app tiles.
