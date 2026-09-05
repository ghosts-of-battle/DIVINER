# config_sounds.hpp

Mission `CfgSounds`.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `CfgSounds`.
**Read by:** the engine.

---

## The whole file

```cpp
class CfgSounds {
    sounds[] = {};
};
```

It ships **empty on purpose**. It is here so that adding a sound is an edit to
one file rather than a new file and a new include.

---

## Instructions

**Add a sound:**

```cpp
class CfgSounds {
    sounds[] = {};

    class alarm {
        name = "alarm";
        sound[] = {"data\sounds\alarm.ogg", 1, 1};   // path, volume, pitch
        titles[] = {};
    };
};
```

Then play it with `playSound "alarm"` or `say3D`.

- The file must be **`.ogg`** or `.wss`, and must exist at that path inside the
  mission.
- `sounds[] = {}` at the top stays — the engine expects the array even when the
  classes below it are what matter.
- Keep clips short and mono. A stereo file positioned in 3D does not behave.

Related: [Other Systems](Other-Systems#sounds)
