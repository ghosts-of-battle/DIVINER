# Editor and Zeus modules

Everything the mod adds to the Eden editor's module list and to Zeus, in one
place. Two kinds:

- **Modules** are placed in Eden (Systems > Modules) and, for the ones marked
  Zeus, in Zeus's Modules tab under the same name. In Eden they sit in the
  **Ghost** category; four older ones sit under **Ghosts of Battle** and the two
  bundled backpack modules under **BackpackOnChestRedux**. A module's attributes
  are its settings; what a module is synchronised to is what it acts on.
- **Zeus tools** exist only in Zeus and need
  [Zeus Enhanced](https://steamcommunity.com/sharedfiles/filedetails/?id=1779063631)
  loaded; without it they are simply absent. They appear under their ZEN
  category in the Zeus Modules tab and act where you drop them.

Attribute defaults are the values the module starts with. Distances are metres,
times seconds.

---

## Modules in Eden and in Zeus

### Ghost - Ambient Shelling

Ambient war: every few minutes a short artillery stonk lands on a building near
a player inside the named markers. It never targets the players themselves —
the distance band keeps it off their heads — and every impact area is announced
on the alert bus first.

| Attribute | Default | Meaning |
|---|---|---|
| Extra Area Markers | — | Marker names, comma-separated, that define where it may land |
| Interval Min / Max | 240 / 600 | Seconds between stonks, rolled between the two |
| Rounds Min / Max | 2 / 5 | Rounds per stonk |
| Shell Classes | — | Ammunition classes to use; empty picks the default |
| Distance Min / Max | 150 / 450 | The band from the nearest player the target must fall in |

### Ghost - Ambient Kamikaze Drones

Ambient war: every few minutes a one-way drone flies in and dives on a building
near a player inside the named markers. It is a real aircraft on the map —
audible, visible and killable, and shooting it down is the counterplay. It
never dives at the players themselves.

| Attribute | Default | Meaning |
|---|---|---|
| Extra Area Markers | — | Where it may strike |
| Interval Min / Max | 420 / 900 | Seconds between drones |
| Drone Classes | — | Airframes to use; empty picks the default |
| Speed | 40 | Dive speed, m/s |
| Distance Min / Max | 150 / 500 | The band from the nearest player |

### Ghost - APS

Placing this module turns on the active protection system. Without it, the
system is off.

| Attribute | Default | Meaning |
|---|---|---|
| Hard Kill | on | Launcher-and-charge systems that destroy incoming rockets and missiles short of the hull |
| RF Burst | on | The microwave emitter: guided munitions lose guidance, drones drop, every radio nearby is jammed for a moment |
| RF Burst On Helicopters | on | Peer+ helicopters carry the emitter as their DIRCM |
| Tier Overrides | — | `faction:tier` pairs that bend the fit table for a mission |
| Fit Overrides | — | `class:fit` pairs that name a vehicle's fit outright |
| Debug | off | Log fits and intercepts, draw burst radii |

### Ghost - Boarding Point

A muster point that loads players into transport. Synchronise the **object**
players press — a sign, a crate, a flagpole — and it carries an ACE action;
pressing it moves every player within the module's range into cargo.
Synchronise **vehicles** too to say which transport is theirs; with none synced
it uses whatever has free cargo near the module. Players already in a vehicle
are left alone, and anyone who does not fit is told so rather than being
silently left behind.

| Attribute | Default | Meaning |
|---|---|---|
| Pickup Range | 50 | How far from the module a player is still loaded |
| Action Name | Board Transport | The ACE action's text |
| Who Is Loaded | everyone | Everyone in range, or the presser's side only |
| Load The Presser | no | Whether the player who pressed it boards too |

### Ghost - Intel Package

Puts an intel package on a device. Hacking that device hands over a share of
it. How big a share one hack yields is a CBA setting (Ghosts of Battle >
Hacking); the package's own contents are mission config — see
[Intel Packages](Intel-Packages).

| Attribute | Default | Meaning |
|---|---|---|
| Package | — | A class under `Ghost_IntelPackages` in the mission config |
| Terminal Class | `Land_DataTerminal_01_F` | What to build if the module is synchronised to nothing |

### Ghost - Jamming

Placing this module turns on jamming. Without it, the system is off. It places
no jammers — a **Ghost - Jammer Site** does that, one per emitter.

| Attribute | Default | Meaning |
|---|---|---|
| Site Radius Min / Max | 1000 / 3000 | Every site rolls its own reach between the two |
| GPS Denial | on | One uplink per commander steering a wandering 1–2 km GPS sphere |
| Uplink Radius | 400 | The uplink's own GPS field |
| Radio Burn-Through | on | A strong set beats a jammer, and is answered with a QRF |
| Burn-Through Reference | 500 mW | The set power the field is calibrated against |

### Ghost - Jammer Site

One jammer site, where you place it. Needs the Jamming module on the map to
arm.

| Attribute | Default | Meaning |
|---|---|---|
| Spectrum | radio | `radio`, `data` or `gps` — one per site |
| Radius | 0 | 0 rolls one from the Jamming module's bounds |
| Side | east | Who owns the emitter |
| Artillery Reply | off | The site shells whoever loiters in its field |
| Reply Delay | 90 | How long a hostile must stay inside before it fires |
| Reply Rounds / Scatter | 8 / 120 | The size of the mission and how wide it falls |
| Reply Cooldown | 300 | Minimum gap between two missions from this site |

### Ghost - Drone Patrol

One patrol. Resize the module — the area is the ground the drones fly over. A
module never resized is one 800 m orbit. Nobody within 3.2 km, nothing flies.

| Attribute | Default | Meaning |
|---|---|---|
| Side | east | Whose drones. A side friendly to the players is skipped |
| Drones | 1 | How many airframes this patrol keeps up |
| Drone Class | — | Empty flies the side's own |
| Artillery On Detect | off | A drone that sees somebody shells where it saw them |
| Rounds / Scatter / Cooldown | 6 / 100 / 300 | The size of that mission and its gap |

### Ghost - Drone Swarm

A swarm, launched where you place it. Trigger it to launch on cue. Resize the
module to set the orbit radius; Impact ignores the area.

| Attribute | Default | Meaning |
|---|---|---|
| Airframe | — | Which drone; limited by the Swarm Airframes setting |
| Drones | 4 | 2 to 12 |
| Action | impact | `impact` dives on this module; `circle` orbits it |
| Spawn Min / Max | 1500 / 2500 | How far out they appear and fly in from |
| Side | east | The fallback crew's side |

### Timed Repair

Keeps everything synchronised to it serviceable: rearmed, refuelled and
repaired on a timer, and optionally rebuilt if destroyed. A snapshot of each
object is taken at mission start while it is still intact, and that is what a
respawn is rebuilt from — so a respawned object comes back where it was placed,
not where the blast left it. The timer and the rebuild are CBA settings
(Ghosts of Battle > Repair).

---

## Modules in Eden only

These four sit under **Ghosts of Battle** in the module list and do not appear
in Zeus.

| Module | What it does | Attributes |
|---|---|---|
| **Safe Start Disabler** | Turns safe start off for the mission | SP Disable — also disable it in single player |
| **Heal Area** | Heals players inside the module's area | — |
| **AI Spawner** | Spawns a group in waves and sends it along markers, hunting the players when a condition says so. Trigger-activated | Side; Group Config (a `CfgGroups` entry); Move Marker 1 / 2; Waves (-1 unlimited); Hunt Condition; Hunt Trigger (`ghost_huntTrigger`); SAD Trigger (`sadTrigger0`); Hunt Immediately — skip the route and go straight after the players |
| **AI Hunter** | Spawns a group that hunts the players. Trigger-activated | Side; Group Config; Waves; Hunt Trigger |

Bundled with the mod, under **BackpackOnChestRedux**, synchronised to units and
trigger-activated:

| Module | What it does | Attributes |
|---|---|---|
| **Add Chestpack** | Adds a chestpack, with inventory, to every synchronised unit | Chestpack classname (`B_Carryall_cbr`); Chestpack Loadout Array; Chestpack variables; Additional code (`_this` is the chestpack) |
| **Backpack on Chest** | Puts the unit's current backpack on the chest and gives a new backpack | Backpack classname (`B_Parachute`); Delay |

---

## Zeus tools

Only with Zeus Enhanced loaded. Drop one from the Zeus Modules tab; it acts at
the drop position or on the unit under it.

**GOB AI**

| Tool | What it does |
|---|---|
| Enable Unit Simulation | Turns simulation back on for the unit or group under the cursor |
| Set Unit Injury | Sets a unit's ACE injury state |

**GOB Logistics**

| Tool | What it does |
|---|---|
| Staging Zone | Creates a staging zone at the drop position |
| Add Staging | Adds staging to an existing zone |
| Spawn Re-supply Crate | A resupply crate at the drop position |
| Spawn Field Hospital | A field hospital |
| Spawn Medical Crate | A medical crate |
| Spawn Starter Crate | A starter crate |

**GOB Mission**

| Tool | What it does |
|---|---|
| Reset Radio | Resets the player's radio to the comms plan. Only offered when radios are enabled |
| Call Endex | Ends the exercise: the endex sequence for every player |
| Take attendance | Writes every player who attended to the server's `.rpt`. TAC//PAC keeps attendance in the store now — see [TAC-PAC](TAC-PAC) |
| Staging Zones | Lists and manages the staging zones |

**Ghosts of Battle**

| Tool | What it does |
|---|---|
| Add teleport point | Adds a teleport point at the drop position |
| Open teleport menu | Opens the teleport menu |
| Drop Patrol Base Kits | Drops a set of Patrol Base Kit items at the drop position so a player can build a base there. The count is the patrol base setting (default 4) |
| Respawn sides | Respawns every player of the sides you tick |
| Respawn (selected unit) | Respawns the player under the cursor |

---

## Eden attributes

- **Zeus** — on every unit, under its object attributes: tick it and that unit
  has the Zeus interface in the mission (the mod's own curator, no Zeus module
  needed).
- **Ghosts of Battle Attributes** — a category on every object, reserved for
  the mod's own per-object attributes.
- **Class pickers** — the drone modules' class fields open a selection window
  with side and faction filters and a typed override, so a class name is looked
  up rather than remembered. The stored value is still the comma-separated
  string the module reads.

Related: [Intel Packages](Intel-Packages) &middot; [Other Systems](Other-Systems) &middot; [Config Reference](Config-Reference)
