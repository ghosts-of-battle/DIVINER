# Custom traits

What a man is allowed to do is a fact about the man, not about his pockets.
There is no Intrusion Tablet item and no Signal Scanner item; whether somebody
can break into a tower is decided by a flag on the unit, set from their role.

There are **two** mechanisms and they are not interchangeable.

| | `traits[]` | `customVariables[]` |
|---|---|---|
| Sets | an engine unit trait, via `setUnitTrait` | a unit variable, via `setVariable` |
| Read with | `getUnitTrait "name"` | `getVariable "name"` |
| Known to | the engine, and anything reading engine traits | whatever agrees on the name |
| Use it for | `Medic`, `Engineer`, `ExplosiveSpecialist`, `UAVHacker` | everything else, including all of ours |

Almost everything you will add is a `customVariables[]` entry. `traits[]` exists
for the handful the engine itself defines.

Both live in a role class in `config\roles\`. See [Roles](Roles) for the rest of
the class.

---

## The syntax

**Every element is a string, including the numbers and the booleans.**

```cpp
class ISR_Operator {
    name = "ISR Operator";

    traits[] = {
        {"UAVHacker", "true", "false"}
    };

    customVariables[] = {
        {"isISR", "true", "true"},
        {"ace_medical_medicClass", 1, "true"}
    };
};
```

### `traits[] = { {name, value, custom} }`

- **name** — the trait. Engine traits are `Medic`, `Engineer`,
  `ExplosiveSpecialist`, `UAVHacker`, `audibleCoef`, `camouflageCoef`.
- **value** — `"true"` or `"false"` are compiled to booleans. Anything else is
  passed through as written, which is how `audibleCoef` takes a number.
- **custom** — `"true"` makes it a *custom* trait, one the engine stores but does
  not itself act on. `"false"` for the engine's own. Optional; defaults to
  `"false"`.

### `customVariables[] = { {name, value, global} }`

- **name** — the variable. Any string.
- **value** — `"true"` and `"false"` compile to booleans. A bare number stays a
  number. Any other string stays that string.
- **global** — `"true"` broadcasts it to every machine, `"false"` keeps it local.
  **Not optional.** Ours want `"true"`: the server and other clients test these.

---

## Adding one

1. Decide which mechanism. If nothing in the engine reads it, it is a
   `customVariables[]` entry.
2. Add the row to every role that should have it.
3. Have something read it: `_unit getVariable ["myFlag", false]`.

That is the whole procedure. There is no registry to update and no list of legal
names — a custom variable exists because somebody set it and somebody reads it.

## Removing one

**Delete the row from every role that carries it.** Do not set it to `"false"`
in one role and leave it out of another: a man who takes the second role after
the first keeps whatever the first gave him unless the flag is cleared, and the
clearing rule below only covers variables this system set.

## Editing one

Change the value in the role class. It applies the next time that role is taken
— which includes every respawn, because role setup runs again on respawn.

---

## What happens when a role is applied

In order, in `ghostD_groups_fnc_setupPlayer`:

1. **Every boolean engine trait is cleared.** `getAllUnitTraits` is walked and
   anything currently `true` is set `false`. Numeric traits — `audibleCoef` and
   `camouflageCoef` — are left alone, because a coefficient has no "off".
2. `traits[]` is applied.
3. **Custom variables from the previous role are set to `nil`.** The names are
   remembered in `YMF_myCustomVariables`, which is rewritten each time.
4. `customVariables[]` is applied, and the names recorded for step 3 next time.
5. `YMF_role` is set to the role id.

### The trap in step 3

**Only variables this system set are cleared.** A variable you set from a
trigger, an init field or a script is invisible to `YMF_myCustomVariables`, so it
survives a role change — and if a role also sets it, the role wins until the next
role change, at which point it is nil'd rather than restored to what your script
wanted. Set it from the role, or set it from your own code after role setup, not
both.

---

## The flags this mod reads

| Variable | Read by | Default when absent |
|---|---|---|
| `isISR` | `ghostD_common_fnc_isISR` — the intrusion app and Intel Hunt processing | `false` — no ISR, no hacking |
| `isLeader` | rank gates, nets, the roster | `false` |
| `isJFO` | TAC//SUPPORT audience tag | `false` |
| the scanner flag | `ghostD_hacking_fnc_hasScanner` | **`true`** — everybody sweeps unless denied |

### Two of those names are settings, not constants

`isISR` and the scanner flag are read through **Addon Options**, so a mission
that already marks its operators some other way can point the mod at its own
naming instead of renaming everything:

- *Ghosts of Battle → Common → ISR unit variable* (default `isISR`)
- *Ghosts of Battle → Hacking → Scanner variable* (default the scanner flag)

Change the setting and the mod reads your name. The role config has to agree —
these settings rename what the mod *looks for*, not what the role *sets*.

### The scanner flag defaults true, and that is deliberate

Carrying a scanner was once the gate, and then a flag defaulting to `false`,
which is the same requirement in different clothes. Everybody sweeps now. Setting
the variable `false` on a unit denies them the scanner, which is the only thing a
mission is likely to want.

---

## Setting a flag outside a role

For a unit placed in Eden, in its init field:

```sqf
this setVariable ["isISR", true, true];
```

The third argument is the broadcast and it is not optional — the server tests
this. Note the [trap above](#the-trap-in-step-3): if that unit later takes a role
through the role screen, this is not restored after the role's own variables are
cleared.

---

## Checking what a unit has

In the debug console, on the unit's own machine:

```sqf
// engine traits, all of them, with their values
getAllUnitTraits player

// one custom variable
player getVariable ["isISR", false]

// every variable this system set on the current role
YMF_myCustomVariables
```

`YMF_myCustomVariables` is the honest answer to "what did this role give me" —
anything set elsewhere will not be in it.

---

See also: [Roles](Roles) for the full role class, [Rank Gates](Rank-Gates) for
what `isLeader` drives, [config_roles](config_roles) for the file layout.
