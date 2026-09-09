# config_pac.hpp

**Declares:** `CfgGFA_PAC`.
**Read by:** `ghostD_pac_fnc_loadStructure`, once, on every machine.
**Overview:** [TAC//PAC personnel](TAC-PAC).

The unit's structure - ranks, skills, awards, statuses, roles, OPORDs and the
settings - lives in the mission, not the mod. The mod holds only what changes
at runtime: who has which rank, who was on when. That split is the whole
design: the structure is versioned with the mission and hashed so two servers
can be shown to differ; the player data is in the server's profile and backed
up to the .rpt.

## Config in the database instead

With `sync = "service"` the whole of this file - and the roles, the ORBAT,
the nets, the radio plan, the report deck and the schemes with it - lives
in the service's database, **one document per config file so people can
edit them separately**: `<unitId>.settings`, `.ranks`, `.skills`, `.awards`,
`.statuses`, `.admins`, `.nets`, `.radio`, `.orbat`, `.templates`,
`.schemes`, `.promotion`, `.trainings`, one per role `<unitId>.role.<class>` and one per order
`<unitId>.opord.<id>`. A section document is
`{ "section": "ranks", "items": { id: {...} } }`; a role is
`{ "section": "role", "id": "teamleadBanshee", "role": {...} }` with every
property of [config_roles](config_roles) plus the gates; an order is
`{ "section": "opord", "id": "op_x", "order": {...} }`; the ORBAT is
`{ "section": "orbat", "faction", "groups", "platoons", "radioNets" }`; the
radio plan is `{ "section": "radio", "items": { "srChannels": [...], ... } }`.
A new role or order is a new document - the mod lists the `<unitId>.role.`
and `<unitId>.opord.` prefixes at boot. The mission keeps three values:

```cpp
class CfgGFA_PAC {
    class settings {
        unitId   = "framework";
        serverId = "main";
        sync     = "service";
    };
};
```

The database wins when it has any of those documents; a mission that still
carries the files pushes them all up only when the database has none, so
the way to move a unit in is one boot with the full config (or
`tools/pacdb/push_config.py` from outside), then strip the files. A
document edited on the site is read at the next mission start - or at once
with `pac_sync.py pull` and **STRUCTURE IN** on the admin page. Without the
service (`sync = "off"`) that clipboard road is the whole connection: the
server keeps what was imported in its profile.

## Class names are the ids

A player's record says `rankId = "corporal"`, never `"Corporal"`. Rename the class
and every player who held it becomes an **orphan** - flagged in the admin page,
never dropped - until you put the class back or reassign them. Rename the
`name` and nothing breaks. Class names: short, lowercase, permanent.

## settings

```cpp
class settings {
    unitId        = "ghosts";     // the unit this store belongs to
    serverId      = "main";       // this server; stamped on every edit for merges
    autoSlot      = 1;            // 0 | 1
    slotMatch     = "role";       // "role" | "slot"
    savedLoadouts = 3;            // per player, per role; 0 = off
    currentOpord  = "";           // class name under opords, "" for none
    opWindows[]   = {};           // see Op windows
    sync          = "off";        // "off" | "service" - see Where the data lives
};
```

| Key | What it does |
|---|---|
| `autoSlot` | On first spawn a player whose record has a role is put straight into a slot of that role's `slotTag`, through the same path the group menu takes. Role_Access still applies. |
| `slotMatch` | `role`: the first free slot anywhere with that role. `slot`: only inside the group the record's GROUP field names. |
| `savedLoadouts` | How many loadouts a player may keep, one per role. The gear addon's own "save loadout" is what saves it; the oldest is evicted past the cap. Applied on spawn after the role's default, checked against the role's `arsenalWhitelist`. |
| `currentOpord` | The order that is on. Shown in the PAC app and the live tile; posted to C2 messaging by the first admin to spawn; pre-fills METT-TC. |
| `opWindows[]` | Fallback op windows when no admin pressed START - see below. |
| `sync` | `service`: the server also loads from and saves to MongoDB through the `ghostd_pacdb` extension - `.dll` on a Windows server, `.so` on Linux, both in the mod root, server-side only, the MongoDB driver built in. Where the database is comes from the CBA server setting **Database** (Addon Options > Ghosts of Battle PAC > Service, or the server's `cba_settings.sqf`): a `mongodb+srv://` connection string is Atlas directly - nothing else runs anywhere - and an `http://` address is the optional pacdb service (with **Service key**); else the server's `GHOSTD_PACDB_URL`, else `pacdb.json` in its root. Boot waits up to 20 s for it and falls back to the profile. `off`: the profile only; the database is then an offline tool reached by **STRUCTURE IN / OUT** on the admin page. See [TAC//PAC](TAC-PAC#where-the-data-lives). |

### Op windows

Attendance is reported **per window**. A session is stamped at join with the
window that was on, chosen in this order: a window an admin started from the
panel; else an entry here that holds now; else `currentOpord`. So a forgotten
START button costs nothing.

```cpp
opWindows[] = {
    {6, "19:00", "22:30"},                          // weekly: day, start, end - UTC
    {"Sat", "19:00", "01:00"},                      // day by name; end before start runs past midnight
    {"2026-03-14 18:00", "2026-03-14 23:00"}        // one-off
};
```

Days: `0` = Sunday .. `6` = Saturday, or the first three letters of the name.

## ranks

```cpp
class ranks {
    class corporal { name = "Corporal"; abbrev = "CPL"; insignia = ""; armaRank = "CORPORAL"; };
};
```

`armaRank` **must** be one of `PRIVATE CORPORAL SERGEANT LIEUTENANT CAPTAIN
MAJOR COLONEL` - it is what `setRank`, the scoreboard and `Role_Access` read.
Any number of unit ranks may map to one Arma rank. `insignia` is a texture
path for later use; empty is fine.

## skills

A skill is a name for a set of effects. Assigning it in the panel applies every
effect; removing it removes every one (everything PAC set is cleared before the
new set goes on). `abbrev` is what the squad panel shows beside each man
(empty = the id in capitals). `color` is the colour those letters are drawn
in on the squad panel, `"R,G,B"` in 0-255 (empty = the panel's ink); the
framework's defaults are green for CLS and Medic, yellow for Leader, and one
colour each for the rest, so a leader reads who the medics are at a glance.
It is editable in game under EDIT STRUCTURE > SKILLS, and lives in the
`<unitId>.skills` document. Skills applied from the admin console's own
PLAYER SKILLS block are session-only and end at respawn; only PAC's are kept.

```cpp
class skills {
    class medic { name = "Medic";     abbrev = "MED"; effects[] = {"medic:2"};        color = "76,175,80";  };
    class jfo   { name = "JFO";       abbrev = "JFO"; effects[] = {"trait:isJFO"};    color = "255,152,0";  };
    class pilot { name = "Pilot";     abbrev = "PLT"; effects[] = {"trait:isPilot"};  color = "77,182,172"; };
    class lead  { name = "Leader";    abbrev = "LDR"; effects[] = {"trait:isLeader"}; color = "255,193,7";  };
    class rto   { name = "RTO";       abbrev = "RTO"; effects[] = {"var:acre_radioLevel=2", "trait:isRTO"}; };
};
```

| Effect | Does |
|---|---|
| `medic:N` | ACE medical class `N` (0 none, 1 CLS, 2 medic) and the vanilla Medic trait when `N > 0` |
| `engineer:N` | ACE engineer class `N` (0, 1, 2) and the Engineer trait |
| `eod:N` | ACE explosives on/off and the ExplosiveSpecialist trait |
| `trait:NAME` | unit variable `NAME` set `true`, broadcast - the mod's [custom traits](Custom-Traits) |
| `var:NAME=VALUE` | any unit variable; `true`, `false` and numbers become themselves, anything else stays a string. Nothing is compiled. |

## awards, statuses

```cpp
class awards   { class cib { name = "Combat Infantry Badge"; type = "badge"; image = ""; campaign = ""; }; };
class statuses { class loa { name = "Leave of absence"; }; };
```

Awards are given from the panel and stamped with the date and who gave them.
A status is a label on the roster - what it means is the unit's business.

## trainings

The training catalogue: the courses the unit runs. The player page's TRAINING
dropdown lists them; pick one and press ADD to log it on the record with the
day. The box beside the list is optional - lead with `YYYY-MM-DD` to back-date
the course, and anything after is the note. Every entry is
`{ name, category, description }`; the class name is the course id.

```cpp
class trainings {
    class cls_course { name = "Combat Lifesaver course"; category = "Medical";    description = "ACE CLS: bandages, tourniquets, IVs, triage"; };
    class tl_course  { name = "Team leader course";      category = "Leadership"; description = "Fireteam and squad leading, reports, the tacpad"; };
    class jfo_course { name = "JFO course";              category = "Fires";      description = "Calling fires: 9-line, CAS, artillery"; };
};
```

Editable in game under EDIT STRUCTURE > TRAINING; in the database it is the
`<unitId>.trainings` document. A record's training entries keep the course id,
so renaming a course renames it on every record; removing one leaves the
entries, shown by id. A unit with no catalogue can still type a course into
the box as free text. The promotion formula counts entries, whatever the
course.

## promotion

The promotion-points formula, as data, so a unit changes its weights without
touching code. Every entry is `{ name, value }`; the class name says what the
value means:

| key | value |
|---|---|
| `hour` | points per hour on the server, all sessions |
| `op` | points per op attended (a closed op window with a session under it) |
| `serviceMonth` | points per 30 days since `enlistedAt` |
| `gradeMonth` | points per 30 days since `promotedAt` (`enlistedAt` if never promoted) |
| `training` | points per training entry on the record |
| `award` | points per award on the record |
| `rank_<rank id>` | points required to hold that rank - the rungs of the ladder |

```cpp
class promotion {
    class hour          { name = "Points per hour on the server"; value = 1;  };
    class op            { name = "Points per op attended";        value = 5;  };
    class serviceMonth  { name = "Points per month in service";   value = 2;  };
    class gradeMonth    { name = "Points per month in grade";     value = 1;  };
    class training      { name = "Points per training entry";     value = 3;  };
    class award         { name = "Points per award";              value = 10; };
    class rank_corporal { name = "Corporal";  value = 40;  };
    class rank_sergeant { name = "Sergeant";  value = 100; };
};
```

```
points = round( hours*hour + ops*op + serviceMonths*serviceMonth
              + gradeMonths*gradeMonth + training*training + awards*award )
```

The next rank is the lowest `rank_*` rung above the player's current rank's
rung. A key that is not listed counts as 0. Shown on the player page (second
line of the service block) and in the operator file under `promotion`.
Editable in game under EDIT STRUCTURE > PROMOTION; in the database it is the
`<unitId>.promotion` document. Points are advisory - the rank is still set by
an admin.

## roles

**Every `Dynamic_Roles` role is a PAC role by itself, whole** - same class
name, every property the role file declares (name, description, icon, nets,
tiles, traits, customVariables, defaultLoadout, groupArsenal, the four
arsenal arrays), `slotTag` = the class - so there is nothing to list here
and the roster, auto-slot, the seeded record and the group menu all read
one record. In the database it is one document per role. Declare a role in
this section only to enrich it, with the same class name (only the fields
you write are read; the rest come from the class):

```cpp
class roles {
    class teamleadBanshee {                  // a Dynamic_Roles class name
        name               = "Team Lead";
        defaultSkills[]    = {"lead"};       // skill ids; reserved - a new player's skills are seeded from the role's own traits
        defaultLoadout[]   = {};
        arsenalWhitelist[] = {};             // class names; empty = no restriction
        slotTag            = "";             // empty = this class; set it to point at another slot
    };
};
```

**Gates.** A role may carry `minRank = "sergeant"` (a rank id: the player's
rank must map to the same or a higher Arma rank), `requiredSkills[] =
{"pilot"}` (skill ids the player must hold) and `uids[] = {"7656..."}`
(Steam ids: only these players). A role with any gate is decided by PAC and
the mission's `Role_Access` is not consulted for it; admin role grants still
open everything. Locked slots read `[SGT+]`, `[PLT]`, `[LOCKED]` in the group
menu, and the server refuses a slot the menu would not have offered. Gates
are edited in the in-game editor (ROLES) or on the database site.

`arsenalWhitelist` is enforced when a **kept loadout** is put back on: any
class not listed is left off and the player is told how many. A declared
role whose class name is not in `Dynamic_Roles` is still a role - it just
never auto-slots unless its `slotTag` names a slot.

## opords

**One file per order, one include line each.** An order is
`config\opords\<id>.hpp` holding `class <id> { ... }`, and `config_pac.hpp`
lists it:

```cpp
    currentOpord = "op_ironveil";
...
    class opords {
        #include "opords\op_ironveil.hpp"
        #include "opords\op_hammer.hpp"
    };
```

That line is the floor: the engine's preprocessor cannot read a folder and
does not expand a macro inside `#include`, so a new order is the file, its
include, and `currentOpord`. Once an order is over its include can go - the
server caches every order it has compiled (`gfa_pac_opords`) and the app
lists the cached ones, dimmed, under the mission's own. `header.id` is the
unit's order number (`GHOST-ORD-01`); the class name stays the machine id.

The class name is the id, and the file is named after it; it is what every
session and METT-TC carries. All fields are text unless marked
`[]`, and all are optional. One file:

```cpp
class op_hammer {
    class header    { id = "GHOST-ORD-02"; title = "OP HAMMER"; date = "2026-03-14"; campaign = ""; release = ""; distribution = ""; mapImage = ""; markers[] = {}; };
    class situation {
        overview = ""; enemy = ""; enemyFactions[] = {}; friendly = ""; civilTerrain = "";
        class attachments { class alpha { callsign = "ALPHA"; assets[] = {"2x MRAP"}; }; };
    };
    class mission        { mission = ""; execution = ""; };
    class adminLogistics { admin = ""; logistics = ""; special = ""; armaConsiderations = ""; };
    class commandSignal  { command = ""; signal = ""; };
    class roe            { roeText = ""; clarifications[] = {}; };
};
```

The framework mission ships `opords\op_ironveil.hpp` - a made-up order for the
framework's own task force on Stratis, in the shape of a real one - as the
worked example, and names it in `currentOpord`.

Removing an OPORD's class simply stops listing it; a record or session that
still names its id reads as archived.

**In the database** an order is one document, `<unitId>.opord.<id>`:
`{ "section": "opord", "id": "op_hammer", "order": { "header": {...},
"situation": {...}, "mission": {...}, "adminLogistics": {...},
"commandSignal": {...}, "roe": {...} } }` - the same sections and fields as
the file, `attachments` as a list of `{callsign, assets[]}` under
`situation`. Copy an existing order document on the site, change `_id`,
`id` and the text, and set `currentOpord` in `<unitId>.settings`. Read at
the next mission start. See the [FAQ](FAQ#orders).

## templates, schemes (database only)

With `sync = "service"` two more documents can carry what used to be
`config_messaging.hpp` and `config_tacpad.hpp`: `<unitId>.templates` (the
TAC//MSG report deck, one entry per template in the shape
`ghostD_messaging_fnc_registerTemplate` takes - `title`, `short`, `lines`,
`options`) and `<unitId>.schemes` (`name`, `ground`, `ink`, `accent`). Push
them from a mission that still has the files with
`tools/pacdb/push_config.py --sections templates,schemes`, then delete the
files. A mission that ships the files keeps them: the config registers at
preInit and wins.

## The hash

The whole structure (settings excluded - `serverId` differs on purpose) folds
to one number, shown on the live tile and the admin page. Two servers with
byte-identical files show the same number; a differing number means the
configs have drifted, and STRUCTURE + HASH on the admin page puts the compiled
structure on the clipboard as JSON so the two can be diffed.
