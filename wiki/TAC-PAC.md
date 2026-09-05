# TAC//PAC - personnel

> New here? [Quick start: the database](Quick-Start-Database) sets up MongoDB
> Atlas and the mission in twenty minutes; the [FAQ](FAQ) answers "how do I
> add an op order" and the rest.

Ranks, roles, skills, awards, notes, attendance and orders for a unit, kept
across missions on the server, edited from the admin console, read in the
tacpad. Phase 1 of `incomingdocs/DESIGN_TAC_PAC.md`.

**Structure** (what the unit has: the rank ladder, the skills, the roles, the
OPORDs) is mission config - [config_pac](config_pac). **Player data** (who has
what) is the server's profile. The two never mix: a mission update cannot
touch a record, and a record cannot invent a rank.

## Where it shows up

| Surface | Who | What |
|---|---|---|
| Admin console -> **TAC//PAC** button (ADMIN ACTIONS column) | admins | the panel: roster, one player's record, edits, kick/ban, op windows, attendance, backups |
| Tacpad -> **PAC** app | everyone | own record (rank, role, skills, awards, time on), the roster, the OPORD list and viewer |
| Tacpad **PAC** live tile | everyone | op window state, players on record, current OPORD, structure hash |
| C2 messaging | everyone / leaders | the current OPORD, posted once per mission by the first admin to spawn; METT-TC replies (leaders only) pre-filled from it |

## The admin panel

Three columns. **Roster** on the left: filter by name, UNASSIGNED shows only
players with no rank, role or skills, offline players are muted not hidden.
Click a row and the server sends that player's full record - notes and
loadouts never reach ordinary clients.

**Player** in the middle. RANK, GROUP, ROLE and STATUS are combos that
write on change. **ENLISTED** and **PROMOTED** are dates with SET: enlisted
defaults to the day the unit first saw them, promoted to the day the rank
last changed, and either can be typed over to back-date; the line under
them shows **time in service** and **time in grade**. SKILLS is a list where
a click ticks or unticks; AWARDS has the player's awards with ADD from a
combo and REMOVE; NOTES is newest-first with ADD NOTE. Every edit goes to
the server, which **checks the sender against the admin list before
writing** - the panel's own check is a courtesy, the server's is the real
one - stamps it with the time and the server, logs it, and publishes. A
player in the field gets a rank or skill change at once; on spawn everyone
gets theirs.

**Actions** on the right. KICK / BAN with the console's rules. A status block
with the structure hash, counts, the current window, the store backend and
when it was last saved, and a READ-ONLY warning if the store was written by
a newer PAC. ORPHANS lists every id a record still holds that the structure
no longer has. **RECENT ACTIONS** is the dated log, newest first - the whole
of it is under MANAGE. Then OP WINDOW, and two groups of buttons:
**DATABASE** (EXPORT STORE, IMPORT STORE, RESTORE STORE, STRUCTURE OUT,
STRUCTURE IN - the store and the structure as clipboard JSON) and **ADMIN
TOOLS** (EDIT STRUCTURE, MANAGE, the sample data).

## Editing the structure in game

EDIT STRUCTURE on the roster page opens the editor: ranks, skills, awards,
statuses and the admin list, one section at a time - pick an item, change
its fields, SAVE; NEW for another; REMOVE asks first, because every record
holding that id reads as orphaned until reassigned. The server checks the
admin list before every write, keeps the change in the unit's database (or
the profile without one, where it outlives a restart), and sends the new
structure to every client at once.

**Roles** are a section too - the *whole* role, and in the database one
document per role, `<unitId>.role.<class>`. The editor shows the gates (MIN
RANK, REQUIRED SKILLS, LOCKED TO - see [config_pac](config_pac#roles));
everything else the role is - name, description, icon, nets, tiles, traits,
variables, default loadout, arsenal arrays - rides along untouched and is
edited on the site. The group menu, the slot setup and the net and tile
gates all read the stored role. **Nets** are a section (NETS: the
description and the rail order). The **ORBAT** (`<unitId>.orbat`: faction,
squads and their slots, platoon tabs, shared radio nets) and the **radio
plan** (`<unitId>.radio`, every `ghost_radio_*` value by name) are documents
applied at boot and on every client. The ORBAT is edited in the
[management window](#the-management-window-log-orbat-operator-files); the
radio plan on the site. The tacpad's SQUAD panel shows each man's skills
from the roster.

**Admins** are a section too: on the database's site the document
`<unitId>.admins` is a plain `ids` array of Steam ids, edited there or in
game (ADD ME puts your own in). Anyone in it may open the console and the
PAC pages, beside the mission's own list.

## The management window: log, ORBAT, operator files

MANAGE on the roster page opens it: one screen, a section picked from a
combo, a filter, a list, and the open item's fields on the right.

**Action log.** Every action an admin takes is written down, dated and
signed - `LOG-n  date  who  type  whom  what`: rank, role, group, status,
skills, awards, notes, the operator fields, structure and ORBAT edits, op
windows started and stopped, imports, sample seeds, kicks and bans. The log
is part of the store (backed up and exported with it, merged on import),
capped at 2000 rows, and every action done *to* a player is also on that
player's record under admin actions - so the log reads as a ledger and the
record as a file. LOG TO CLIPBOARD exports it as text.

**ORBAT editor** - four sections. SQUADS AND SLOTS: a squad is a name, its
slots (role classes in slot order, checked against the roles the structure
has), a condition and a POSITION - the row order is the SR radio channel
order, so moving a squad moves its channel. PLATOON TABS: id, name, callsign,
net and the squads under it. SHARED RADIO NETS: nets that cross a platoon
boundary. FACTION: the name over the role screen. Every save rebuilds the
live slot table at once (nobody seated is thrown out), goes to the
`<unitId>.orbat` document (or the profile), and reaches every client.
ORBAT TO CLIPBOARD exports the document.

**Operator files.** Every record is an operator file, and this is where the
parts only a person can know are typed: MILSIM NAME, DISCORD ID, ENLISTED
(YYYY-MM-DD - attendance is counted from it), CLEARANCE, COMPANY and
REPORTS TO. The rest is read off what the unit already does: the operator
id (`OP-10001` onward, given once), rank with its pay grade (a rank field),
promotion date (stamped when the rank changes) and time in grade, status,
platoon (from the ORBAT), squad and billet, qualifications (every skill
ever granted, with the day), attendance (operations held since enlistment,
attended, excused, unexcused, percentage), awards with citations, and the
admin actions logged against them. OPERATOR FILE TO CLIPBOARD writes it as
JSON in this shape:

```json
{ "operator_id": "OP-10001",
  "identity": { "milsim_name", "community_handle", "discord_id", "steam_id_64", "enlistment_date" },
  "service_status": { "current_rank", "rank_abbreviation", "pay_grade", "promotion_date", "time_in_grade_days", "duty_status", "app_clearance_level" },
  "orbat_assignment": { "company", "platoon", "squad", "billet", "reports_to_id" },
  "personnel_logs": { "qualifications": [...], "attendance": {...}, "awards": [...], "admin_actions": [...] } }
```

## Skills, ranks, and who applies them

A **rank** maps to one of Arma's seven and is set on the unit, always. A
**skill** is a named set of effects (ACE classes, traits, variables - see
[config_pac](config_pac#skills)). **PAC is the source of truth for skills.** The roles no longer set any trait
or variable a PAC skill can set (tile access, nets and DRA flags stay with the
role); what is ticked on the panel is what the player carries. A new player's
skills are seeded once from their role, so switching PAC on loses nobody
anything; after that only the panel changes them. The groups addon applies the
role's defaults first and PAC's answer goes on top, so a promotion survives a
respawn.

## Slots and loadouts

**The record drives the slot, never the other way.** A player's ROLE and
GROUP on the roster are their billet and squad, set on the PAC page (or by a
CSV import) and nowhere else. The slot they pick in the role picker is what
they are doing this op; it does not fill an empty ROLE or GROUP on the
record, so a new player shows both empty until an admin sets them. The one
thing a first slot still seeds is skills, once (see above).

With `autoSlot = 1`, a player whose record has a role is put into a free slot
of that role's `slotTag` on first spawn - the same path the group menu takes,
Role_Access included. `slotMatch = slot` also requires the group the record's
GROUP field names.

The gear addon's "save loadout" also keeps the loadout on the PAC record,
one per role, up to `savedLoadouts`. On a spawn with a role it goes on over
the role's default, minus anything not on the role's `arsenalWhitelist`.

## Attendance and op windows

Every connect opens a session, every disconnect closes it, and a 60 s
heartbeat keeps "last seen" honest for the server that dies without one.
Sessions are append-only and never merged. **A logon and a logoff each write
the store to the database at once** - a player's time is down the moment
they leave, whatever happens to the server afterwards. The heartbeat updates
"last seen" in memory only, so a crash mid-session loses the time since that
player's logon.

A session is stamped at join with the **op window** that was on: one an admin
started from the panel (name + START; STOP forces a local save and a backup
dump - the window reaches the database with the next SAVE, logon, logoff or
mission end), else a `settings.opWindows[]` entry that holds now, else the
current OPORD. Windows are applied at report time, so a forgotten START is
fixed after the fact.

**ATTENDANCE TO CLIPBOARD** gives the open window's report - or the latest
window's, or all time - as text on the clipboard and in the .rpt: per player,
hours and minutes, joins. The PAC app shows each player their own total.

## Training and promotion points

**Training** is a dated log on the record: the courses a player has held. On
the player page, type the course into the TRAINING box and press ADD; the
server stamps it with the time and your name. Lead with the day it was held -
`2026-08-14 CLS course, passed` - to back-date it. REMOVE takes out the
selected entry. Every add and remove is logged, and the entries appear in the
operator file under `personnel_logs.training`.

**Promotion points** are computed by the server from a formula the unit keeps
as data: the `promotion` section of the structure (EDIT STRUCTURE >
PROMOTION in game, or the `<unitId>.promotion` document in the database).
The weights are points per hour on the server, per op attended, per month in
service, per month in grade, per training entry and per award; the rungs are
one per rank (`rank_sergeant = 100` means 100 points to hold Sergeant). The
player page shows the total, the breakdown and the next rung on the second
line of the service block; the operator file carries it under `promotion`.
Points are advisory - an admin still sets the rank. The keys and the formula
are in [config_pac](config_pac) under `promotion`.

## Backups, export, import

If the store comes up empty when the last save held players, it goes
**read-only** and says so on the status line: restore from a backup file or
the .rpt before anyone is seeded fresh over the loss.

The store goes into the server .rpt at **mission end** and at **op window
stop**, as JSON between `[TAC//PAC] BACKUP BEGIN` and `BACKUP END` lines,
sliced 2000 characters per line. To restore from the log: copy every line
between the markers, strip the `[TAC//PAC] ` prefix from each, join them into
one string, put it on the clipboard, and press RESTORE FULL.

The player column has a **SAVE** button - edits save on their own (the disk
write debounced so a run down the roster is one write), and SAVE forces the
write to profile and database now and reapplies to every client, with a
confirmation. Closing the page also reapplies your own rank and skills.

The right column, DATABASE and ADMIN TOOLS:

| Button | Does |
|---|---|
| EXPORT STORE | the store as readable JSON on your clipboard and in your .rpt |
| IMPORT STORE (MERGE) | merges the JSON on your clipboard: per player the newer `updatedAt` wins; sessions and windows are appended if new |
| RESTORE STORE | replaces every record, session and window with the clipboard's; asks first |
| STRUCTURE OUT | the whole structure and its hash as JSON - STRUCTURE IN on another server takes it, and it diffs two servers |
| STRUCTURE IN | replaces the structure with the JSON on your clipboard - from `pac_sync.py pull` or another server's STRUCTURE OUT; asks first |
| IMPORT CSV | a roster CSV shipped in the mission into the store - see below |
| EDIT STRUCTURE / MANAGE | the structure editor, and the log / ORBAT / operator window |
| SEED SAMPLE DATA / REMOVE SAMPLE | sixteen made-up players drawn from the mission's own ranks, roles, skills and awards, with notes and a closed op window - so the panel and reports can be seen working before the unit has entered anybody. Reversible to the record. |

A document from a newer PAC is refused. A document that does not parse is
refused with the character it failed at.

## Importing a roster from a CSV

A unit that keeps its people in a spreadsheet imports them without typing
each one. Save the sheet as **`pac_roster.csv`** in the mission - its root
or `config\` - and press **IMPORT CSV** on the admin page. The server reads
the file from its own mission copy, so it works on a dedicated server, and
writes one record per row.

**It updates, it does not replace.** A row for a Steam id already on the
roster fills the columns the CSV names and leaves the rest - awards, notes,
attendance - alone. A new id is added, with an operator id and today's
enlistment unless the CSV gives them. Ranks, roles, statuses and skills the
structure does not have are skipped and named back in the result, never
written as orphans.

**The file.** A header row, then a row per person. Column order is free;
columns are matched by name, with case, spaces and underscores ignored;
unknown columns are ignored and missing ones left alone.

| Column | What |
|---|---|
| `steamId` | **required** - the 17-digit id, the record's key |
| `name` | the display name |
| `milsimName` | the unit's name for them - "Cpl J. Miller" |
| `rank` | a rank: its id (`sergeant`), name (`Sergeant`) or abbrev (`SGT`) |
| `group` | the squad id - `BANSHEE 1-1` |
| `role` | a role: its class id (`atlBanshee`) or its name |
| `status` | a status: its id or name |
| `skills` | skill ids, separated by a space, `;` or `|` |
| `discordId`, `enlisted`, `promoted`, `clearance`, `company`, `reportsTo`, `operatorId` | written as given; the dates are `YYYY-MM-DD` |

```
steamId,name,milsimName,rank,group,role,status,skills,enlisted
76561198000002705,YonV,Maj J. Wise,sergeant,GHOST 6,coC2,Active,lead isr,2025-01-06
76561198083000561,Wobba,Cpl A. Bauer,corporal,BANSHEE 1-1,atlBanshee,Active,cls,2025-03-15
```

`framework.Stratis` ships this example. See also the [FAQ](FAQ).

## The OPORD and METT-TC

`settings.currentOpord` names the order that is on. The PAC app lists every
OPORD and opens one section by section. The first admin to spawn posts it to
the C2 mailbox as an `opord` message tagged `OPORD:<id>`, and a leader replies
with **METT-TC**: Mission, Enemy, Terrain and weather, Troops and support,
Time, Civil considerations, and a LOCATION picked from the map. Mission,
Enemy and Civil are pre-filled from the OPORD.

**Only a leader may send a METT-TC.** A leader is whoever holds a slot whose
role sets `isLeader` (the team-lead roles in `config_roles.hpp` do). The
template is not offered to anyone else and the server refuses it from anyone
else. **Taking a leader slot** brings a notice that the METT-TC is owed
against the current OPORD, and once the group menu closes the tacpad opens on
a fresh one. A respawn into the same slot brings nothing.

Both templates are built in; a mission that defines its own `opord` or
`mettc` in `GHOSTFR_Templates` wins.

## Where the data lives

**The server's profile is always the store** - `profileNamespace` keys
`gfa_pac_players`, `gfa_pac_sessions`, `gfa_pac_windows`, `gfa_pac_meta`,
`gfa_pac_opords`, `gfa_pac_log` and `gfa_pac_structure` (every section
edited or imported in game). It is written when something changed - a
connect, a disconnect, an admin's edit, a window, an import, the mission
ending - never on a timer, and dumped into the `.rpt` at mission end and
window stop as a backup. Windows or Linux server alike. That is the local
copy; what reaches the database is narrower, below.

**MongoDB sits on top of it.** With `sync = "service"` the server also
reads its config and store from MongoDB Atlas through the `ghostd_pacdb`
extension - `ghostd_pacdb_x64.dll` on a Windows server, `ghostd_pacdb_x64.so`
on Linux, both in the mod root, the MongoDB driver built in, called by the
server and never by a client. **The store is written to the database on
exactly four occasions: the SAVE button on the admin page, a player's
logon, a player's logoff, and mission end.** The boot reads the store and
never writes it back; an edit on the player page, a role picked in game, a
seed or an import change the server's copy and wait for one of those four.
So press SAVE when you are done editing - and nothing that runs on its own
can ever shrink the database, because every one of those writes sends the
whole store the server read from it, plus what happened since. Structure
edits (EDIT STRUCTURE) are written to their own documents as you save them.
Nothing else runs anywhere: a rented game server does this by itself. Where the database is: the CBA server setting **Database**
(Addon Options > Ghosts of Battle PAC > Service, set by a logged-in
admin, or the server's `cba_settings.sqf`), the `mongodb+srv://` connection
string from Atlas; else `GHOSTD_PACDB_URL` in the server machine's
environment; else `pacdb.json` in the server's root. A server setting is
sent to every client, so give Atlas a user for this database alone and
allow only the game server's IP - `tools/pacdb/README.md` walks through it.
An `http://` address in the setting is the optional pacdb service instead.
A database that is down costs a delay at boot, not the roster. BattlEye does not police the dedicated server process the way
it polices clients: run with it on, and only if the server `.rpt` says
`Blocked loading of file` is there anything to change.

**The clipboard is the other road**, with or without the service:

| | |
|---|---|
| database -> game | `pac_sync.py pull` puts one `{structure, settings}` JSON on the clipboard; **STRUCTURE IN** on the admin page adopts it, puts it into effect, keeps it in the profile (and the service) and sends it to every client. |
| game -> database | **EXPORT** (the store) -> `pac_sync.py push-store`; **STRUCTURE OUT** -> `pac_sync.py push-structure`. |
| server -> server | **STRUCTURE OUT** on one, **STRUCTURE IN** on the other; **EXPORT** and **IMPORT (MERGE)** / **RESTORE FULL** for the store. |

**The boot narrates itself.** Six steps, each a line `[TAC//PAC BOOT n/6]
...` in the server `.rpt` (live on a dedicated console) and on screen in a
hosted game: structure from the mission; what was edited or imported in
game laid over it from the profile; config from the service (adopted, or
the mission's pushed up when the database has none, or not answering) and
the structure into effect; the store from the profile; the store from the
service when it has one; saved to the profile (never back to the database),
published, READY. With the service the
mission needs only `unitId`, `serverId` and `sync` - see
[config_pac](config_pac#config-in-the-database-instead).

## What a mission still needs on disk

With everything in the database, a mission carries: `config_pac.hpp` (three
lines), `config_arsenal.hpp` with `Common_Arsenal` and one `Arsenal_*`
shell per element (the arsenals stay on disk - a role's `groupArsenal`
names one of them), motorpool, cosmetics and pylons (modset-bound),
`config_radar.hpp`, `config_sounds.hpp` (engine), `config_skill.hpp`,
`config_logistics.sqf`, `loadConfigs.sqf`, and `config_welcome.hpp` - the
welcome text is per mission on purpose. Roles, the ORBAT, the nets, the
radio plan, ranks, admins, the report deck, the schemes and the orders are
documents. `frameworkmongo.Stratis` is exactly that list - 40 files, all of
them arsenal, motorpool or modset - and `framework.Stratis` is the same
mission with every seed file still in it.

## What is where

| | |
|---|---|
| Structure | `CfgGFA_PAC` in the mission (the seed), or the unit's `<unitId>.*` documents - [config_pac](config_pac) |
| Player data | server `profileNamespace` keys `gfa_pac_players`, `gfa_pac_sessions`, `gfa_pac_windows`, `gfa_pac_meta`, `gfa_pac_opords`, `gfa_pac_log`, `gfa_pac_structure`; the service's `<unitId>` document with `sync = "service"`; the `.rpt` backup dump; EXPORT on the admin page |
| Boot gate | `ghostD_pac_ready` (publicVariable) - `[{ ... }] call ghostD_pac_fnc_whenReady` runs code once the store is loaded |
| Code | `addons/pac`; the extension, the service and the tools in `tools/pacdb` |
| Design | `incomingdocs/DESIGN_TAC_PAC.md` |
