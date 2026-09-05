# Nets

> **In storage since 2026-09-05.** The same list is a TAC//PAC document,
> `<unitId>.nets`, when the unit keeps its config in the database - see
> [config_nets](config_nets). The roles' `nets[]` moved with the roles.

`config\config_nets.hpp` declares every named TAC//MSG mailbox in the mission,
in one place.

```cpp
class GHOST_Nets {
    nets[] = {
        // Command
        {"C2", "Command and control - the detachment net"},
        {"C2.reports", "Filed reports: contact, situation, patrol"},

        // Fires
        {"FIRES", "Fire support coordination"},
        {"FIRES.cas", "Close air support requests"},
        {"FIRES.arty", "Artillery and mortar fire missions"},

        // The arms - one per platoon, named for it
        {"BANSHEE", "1st Platoon: Banshee 1-1 to 1-4"},
        {"NOMAD", "2nd Platoon: Nomad 2-1 to 2-4"}
    };
};
```

With this class present the addon's own "Shared mailboxes" setting is ignored,
so the nets live with the mission that uses them rather than in a profile
somebody has to remember to set.

---

## Three rules

### 1. A dot is nesting, and nothing more

`FIRES.cas` is its own net, not a folder inside `FIRES`. A player can be on one
and not the other.

### 2. Squad nets are not declared here

They exist because the squads exist, and are named **exactly** as `group_setup`
names them — `"BANSHEE 1-1"`, not `"BANSHEE"`.

A man reads his own because he is *in* it, not because a config granted it.

> Since a platoon net is now its callsign, the difference between the platoon
> net and a squad net is one space and a number. `BANSHEE` and `BANSHEE 1-1` are
> two different nets, matched whole and never by prefix.

### 3. Access is decided per role, not here

Each role's `nets[]` array is its access list, because access follows the job
somebody signed up for.

- A net **absent** from a role's list is not his.
- A role with **no** list gets none.
- If **no** role in the mission declares `nets[]` at all, the gate does not exist
  and every net reads as it always did — so adding this to a mission that never
  asked for role gating does not silently take every net away.

That third rule is also the privacy mechanism. Leaving squad nets out of every
role's `nets[]` *is* what keeps squad traffic in the squad.

---

## A workable shape

The reference mission's rule, which is a reasonable default:

| | Reads |
|---|---|
| **An element's two leaders** (the gated slots) | All four arm nets, plus command and the working fires and medevac nets |
| **Everyone else** | His own platoon's arm net, and the trade net he owns |

Specialists reach other platoons through the trade net they already have:

| Role | Crosses a platoon boundary via |
|---|---|
| JFO | `FIRES`, `FIRES.cas`, `FIRES.arty`, `FIRES.trans` |
| Medic | `MEDICAL`, `MEDICAL.mist`, `MEDICAL.medevac` |
| Demo, support | `ENGINEER` |
| ISR, recon, vehicle crew | Nothing — his platoon and his squad only |

That last row is deliberate, and worth deciding on for yourself: a rifleman on
two nets is a rifleman who hears his team and his platoon, and nothing else.

---

## What a player actually sees

The rail in TAC//MSG shows, in order:

1. The declared named nets **that his role allows**
2. **His own squad's net** — never gated, never listed in a role's `nets[]`
3. `ALL`

That is `ghost_messaging_fnc_railNets`, and the tacpad panel tab strip and the
compose target list ask the same function the same question.

Example, for the reference mission:

| Player | Rail |
|---|---|
| GHOST 6 · CO | C2, C2.reports, FIRES, FIRES.cas, FIRES.arty, FIRES.trans, MEDICAL, MEDICAL.medevac, ENGINEER, BANSHEE, NOMAD, TALON, WRAITH, **GHOST 6**, ALL |
| GHOST 6 · Security | C2, **GHOST 6**, ALL |
| BANSHEE 1-1 · Recon | BANSHEE, **BANSHEE 1-1**, ALL |
| WRAITH 4-2 · Support | ENGINEER, WRAITH, **WRAITH 4-2**, ALL |

He never sees another squad's net.

---

## The name has to agree with the radio

A platoon's `net` value is used twice: TAC//MSG opens a mailbox of that name,
and the ACRE MR plan carries a channel of that name. One word for one net across
mail and radio — but **nothing enforces it**. See
[Cross-File Contracts](Cross-File-Contracts).

---

## Tags — waking people, not moving traffic

A tag **wakes whoever it names. The traffic stays on the net it was sent on.**
Tagging is not a second addressing system; it is how you make sure the right
person looks at a message that is already on a net he can read.

A tagged man gets a **loud notification** whatever the message's own urgency was,
and the tag that reached him is on the notification.

### What a tag may be

Tried in this order:

| Kind | Example | Reaches |
|---|---|---|
| A job | `MEDICS` | Every man doing that job, anywhere in the task force |
| A squad | `BANSHEE 1-1` | Everybody in that group |
| A platoon | `NOMAD` | Every squad the mission files under that platoon |
| A man | a callsign or a UID | Him |

Case and spaces are noise — `nomad`, `NOMAD` and ` Nomad ` are the same tag, and
`BANSHEE 1-1` is reachable as `BANSHEE1-1`.

### The six job tags

Each resolves off the first of these that answers: **the mission's own flag**,
then **an engine trait**, then **the role class name**.

| Tag | Mission flag | Engine trait | Role name contains |
|---|---|---|---|
| `LEADERS` | `isLeader` | — | `teamlead` |
| `MEDICS` | `ace_medical_medicClass > 0` | `medic` | `medical` |
| `DEMO` | `ace_isEOD` | `explosiveSpecialist` | `demo` |
| `ISR` | `isISR` | — | `isr` |
| `PILOTS` | `isPilot` | — | `pilot`, `copilot` |
| `JFO` | `isJFO` | — | `jfo`, `jtac` |

`HQ` still answers as `LEADERS` and `AVIATION` as `PILOTS`, so traffic sent
before the chips were renamed still resolves.

> **A job tag reaches everyone the flag is set on.** If your leaders carry
> `isISR = true` and `isJFO = true` — as the reference mission's do, because
> they task drones and fires — then `ISR` and `JFO` reach every leader as well
> as the specialists. That is a decision in your role configs, not in the tag
> system: clear the flag on roles that should not answer the call.

### The chips

The composer offers a pre-built set: **his own squad**, **the platoons whose arm
net he is on**, then **the six jobs**. The free-text box above the row still
takes anything — a callsign, a job, a man, a UID.

Related: [Roles](Roles) &middot; [Messaging Deck](Messaging-Deck)

Next: [Comms Plan](Comms-Plan).
