# Cross-file contracts

These pairs must agree, and **nothing in the engine or the mod validates them**.
Every one fails quietly — a man on the wrong channel, a role nobody can take, a
net that reaches no one.

If you read one page on this wiki before shipping a mission, read this one.

---

## The list

| This | must match | or |
|---|---|---|
| `group_setup` row order | `ghost_radio_srSquadChannel`, and the generated radio faces | Teams spawn on the wrong channel |
| `Platoons >> net`, `RadioNets >> net` | names in `ghost_radio_mrChannels` | The man lands on the detachment default |
| `nets[]` in a role file | a net declared in `GHOST_Nets` | The role reads a mailbox that does not exist |
| Role classes in `group_setup` | classes included by `config_roles.hpp` | Empty slot, no card beside it |
| `Role_Access` class names | role class names | The gate gates nothing |
| `groupArsenal` value | a top-level `Arsenal_<X>` class | The role gets only the common arsenal |
| First word of a group id | `MotorPool_<Callsign>` | The element gets the common pool (usually fine) |
| A messaging line's `name` | the ALiVE forwarder's field keys | Reports forward with missing fields |

---

## The four worth explaining

### The SR channel is a row index

A squad's position in `group_setup` **is** its short-range channel, unless
`ghost_radio_srSquadChannel` names it explicitly:

```
channel = row index × ghost_radio_srBlockSize + 1
```

Insert a squad at the top of the roster and every team below it moves one
channel. List every squad in `ghost_radio_srSquadChannel` and the fallback never
fires.

Either way, changing a channel means re-running `tools/gen_radio_faces.py` and
`tools/gen_prc148_faces.py` — the card painted on the radio model is generated
from that file, and it does not update itself.

### MR net names are matched as exact strings

`ghost_players_fnc_platoonNet` returns the `net` value from `RadioNets` or
`Platoons`; `fn_getRadioChannel` looks for a channel of that name in
`ghost_radio_mrChannels`. A typo is not an error — the man lands on
`ghost_radio_mrDefault` and nobody notices until two people cannot hear each
other.

### Squad nets are implicit

They are named exactly as `group_setup` names them and appear in **no** role's
`nets[]`. That is not an oversight — it is the privacy rule. A man reads his own
squad because he is in it.

**Do not "fix" this by declaring them in `GHOST_Nets`.** Doing so makes every
squad's traffic a named net that the role gate then has to exclude one by one.

### A rank gate that names nothing gates nothing

```cpp
class Role_Access {
    class teamleadBanshee { minRank = "Sergeant"; };   // works
    class teamleadBanshe  { minRank = "Sergeant"; };   // typo - gates nothing
};
```

Both read identically in the file. The second one leaves the slot open to
everybody, silently.

The matching trap: **do not set a gate no player can pass.** If nobody in
`Dynamic_Ranks` holds Lieutenant, a `minRank = "Lieutenant"` slot is a slot
nobody can take.

---

## Checking your own mission

None of this is validated at load, so check it yourself. A short Python script
against your `config\` folder can confirm, in one pass:

- every role class in `group_setup` is included by `config_roles.hpp`
- every `Role_Access` class name matches a role class
- every net in a role's `nets[]` is declared in `GHOST_Nets`
- every `Platoons` and `RadioNets` `net` has an `ghost_radio_mrChannels` entry
- every squad has an `ghost_radio_srSquadChannel` row
- every role carries a `groupArsenal` naming a class that exists

The reference mission is checked this way after every roster change, and it
catches something roughly half the time.

---

## The RPT is the other half

The framework **warns rather than fails** on most misconfiguration, so the
mission still boots and the mistake is visible only in the log. Search for
`[ghost]`.

See [Troubleshooting](Troubleshooting).
