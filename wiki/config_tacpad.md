# config_tacpad.hpp

Your unit's own TAC//PAD colour presets, shown in the tacpad SETTINGS app under
COLOUR SCHEME as a second row headed MISSION PRESETS, drawn exactly like the six
the mod ships.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `GHOST_TacpadSchemes`.
**Read by:** the tacpad SETTINGS app.

---

## Shape

```cpp
class GHOST_TacpadSchemes {

    // Day ground. The blue reads as cold light rather than the shipped red.
    class TFR_Day {
        name = "TFR BLUE";
        ground = "#EEF1F4";
        ink = "#12243A";
        accent = "#3D8BD8";
    };

    class TFR_Night {
        name = "TFR NIGHT";
        ground = "#0B1016";
        ink = "#CFE3F2";
        accent = "#4FA3E3";
    };
};
```

| Property | What |
|---|---|
| `name` | What the card says. Uppercased on screen — **about twelve characters fit** |
| `ground` | Panel background |
| `ink` | Text and dividers |
| `accent` | Selection, alerts and FLASH traffic |

---

## Rules

**Three tokens and nothing else.** Divider weight, tints and pressed states are
all derived from those three, which is why there is no fourth field.

**Format:** hex with or without the hash. The older `"r,g,b"` 0–1 form still
reads.

**A missing token skips the entry** with a warning in the RPT, rather than
drawing a black card.

**Three cards per row.** Six is two rows and still fits. Past that the row
starts eating the swatch strips underneath it — keep the list to what your unit
actually switches between.

---

## Instructions

**Add a scheme:** one class with the three tokens and a short `name`.

**Pair day and night.** A scheme that works at noon is unusable at 0200; ship
both and let people switch.

**Check contrast** between `ink` and `ground` before shipping — this is a panel
read in a firefight, not a portfolio piece.

## Why it is here and not in the mod

The alternative was every player reassembling the same three colours by hand off
the swatch strips at the bottom of that screen, which is not a preset — it is a
colouring exercise twenty people get slightly differently.

Related: [Other Systems](Other-Systems#tacpad-colour-schemes)
