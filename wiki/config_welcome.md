# config_welcome.hpp

The welcome modal, shown to every player once the mission display is up.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `GHOST_Welcome`.
**Read by:** `initPlayerLocal.sqf` → `ghost_common_fnc_modal`.

---

## Shape

```cpp
class GHOST_Welcome {
    title = "GHOSTS OF BATTLE";
    subtitle = "TASK FORCE ROOMBA - HORIZON ISLANDS, 2040";
    lines[] = {
        // {text, size, {r,g,b}, align}     align: 0 left, 1 centre, 2 right
        {"SITUATION - RED ZONE", 1.15, {1,0.33,0.33}, 0},
        {"China has invaded eastern Tanoa...", 0.9, {1,1,1}, 0},

        {"GETTING STARTED", 1.15, {1,1,1}, 0},
        {"Select a role from the group menu.", 0.9, {1,1,1}, 0}
    };
};
```

| | |
|---|---|
| `title` / `subtitle` | The two halves of the title bar |
| `lines[]` | One entry per line |

Each line is `{text, size, {r,g,b}, align}`:

| Element | What |
|---|---|
| text | Structured text — **`<br/>` works inside it** |
| size | Relative. `1.15` for a heading, `0.9` for body |
| `{r,g,b}` | 0–1 floats |
| align | `0` left, `1` centre, `2` right |

---

## Instructions

**Write it as headings and paragraphs.** A coloured heading line at `1.15`,
then a white paragraph at `0.9`. That is the whole vocabulary.

**Colour by meaning** — red for the threat, green for friendly ground, blue for
the reason you are there. Then stop; four colours is a ransom note.

**Say what to do at the end.** The last block should tell a new player how to
take a slot, because that is the question they have while the box is open.

**To turn it off:** delete the whole class. Nothing is shown.

Related: [Other Systems](Other-Systems#the-welcome-screen)
