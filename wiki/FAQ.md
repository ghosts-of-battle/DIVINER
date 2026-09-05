# FAQ

Short answers, each with where to go. Pages: [TAC//PAC](TAC-PAC),
[config_pac](config_pac), [Quick start: the database](Quick-Start-Database).

---

## Orders

**How do I add an op order?**

Three ways; the order shows in the PAC app's OPORD tab either way, and the
first admin to spawn posts the current one to C2.

1. *In the mission.* Copy `config\opords\op_ironveil.hpp` from the
   framework mission to `config\opords\op_yourop.hpp`, rename the class
   inside to `op_yourop`, fill the sections, and in `config_pac.hpp` add its
   include under `class opords` and name it in `currentOpord`:
   ```cpp
   currentOpord = "op_yourop";
   ...
   class opords {
       #include "opords\op_ironveil.hpp"
       #include "opords\op_yourop.hpp"
   };
   ```
   The fields are listed in [config_pac](config_pac#opords). Every field is
   one string; leave a field empty rather than deleting it.
2. *In the database.* On the Atlas site, in `ghostd > pac`, copy the
   `framework.opord.op_ironveil` document, set `_id` to
   `framework.opord.op_yourop` and `id` to `op_yourop`, and edit the
   `order` object - the same sections as the file. Then in
   `framework.settings` set `items.currentOpord` to `op_yourop`. It is read
   at the next mission start.
3. *From a file into the database.* Put the file in a mission as in 1 and
   run `tools/pacdb/push_config.py <mission>\config --sections settings,opords`
   from a PC with the pacdb service running.

An order that is over can lose its include or document: the server caches
every order it has compiled, and the app lists cached ones, dimmed, under
the current ones.

**How do I switch which order is current?**
`settings.currentOpord` - in `config_pac.hpp`, or `items.currentOpord` in
the `<unitId>.settings` document.

**Why can't a player send a METT-TC?**
Only a leader can: whoever holds a slot whose role sets `isLeader`. Taking
such a slot brings the notice and opens the compose page.

## Squads, roles, the ORBAT

**How do I add a squad, rename one, or change its slots?**
Admin page > **MANAGE** > ORBAT - SQUADS AND SLOTS. NAME, SLOTS (one role
class per slot, in slot order), CONDITION, POSITION. The row order is the
SR radio channel order, so POSITION is a real change. Saving rebuilds the
live slot table at once; nobody seated is thrown out. Or edit the
`<unitId>.orbat` document.

**How do I add a role?**
Copy an existing role document (`<unitId>.role.teamleadBanshee`) to a new
`_id` and `id`, change `name`, `nets`, `tiles`, `defaultLoadout`, the
arsenal arrays and the gates, then put the class in a squad's SLOTS. The
role's `groupArsenal` must name an `Arsenal_*` class the mission carries -
the arsenals stay on disk. Without a database: a file under the element
folder, included in `config_roles.hpp` ([Roles](Roles)).

**How do I lock a slot to a rank, a skill, or a person?**
Admin page > **EDIT STRUCTURE** > ROLES: MIN RANK (a rank id), REQUIRED
SKILLS (skill ids), LOCKED TO (Steam ids). The group menu shows `[SGT+]`,
`[PLT]`, `[LOCKED]` and the server refuses a slot the menu would not offer.
Admin role grants still open everything.

**How do I add a platoon tab, or a radio net that crosses platoons?**
MANAGE > ORBAT - PLATOON TABS / SHARED RADIO NETS. A tab's NET must be a
named net and an MR channel of the same name.

## People

**How do I promote someone?**
Admin page, pick them on the roster, RANK combo. It goes on them at once
if they are in the field, and on every spawn. PROMOTED is stamped with the
day; type an earlier date and SET to back-date it - time in grade counts
from it.

**How do I set when someone joined?**
ENLISTED on the player page: it defaults to the day the unit first saw
them; type the real date and SET. Time in service and the attendance
percentage count from it.

**How do I give someone a skill?**
Admin page > SKILLS, click to tick. What is ticked is what they carry; PAC
is the source of truth. Skills given from the admin console's player
window are session-only.

**How do I add an admin?**
EDIT STRUCTURE > ADMINS > ADD ME, or type a Steam id. Or add the id to the
`ids` list of the `<unitId>.admins` document. And before a real op turn off
the CBA setting **Everyone is an admin (testing)** under Admin Console.

**How do I see a person's whole file, or hand it to them?**
MANAGE > OPERATOR FILES: identity, service, assignment, qualifications,
attendance, awards, every action logged against them. OPERATOR FILE TO
CLIPBOARD writes it as JSON.

**Someone shows as an orphan. What happened?**
Their record names a rank, role, skill or status id the structure no
longer has - it was renamed or removed. Pick them on the roster and set
the field again.

## Attendance and the log

**How do I count attendance for an op?**
Admin page > OP WINDOW: START OP as the op begins, STOP OP when it ends.
Everyone on the server in between is counted. ATTENDANCE TO CLIPBOARD
lists who was on and for how long; the operator file shows scheduled,
attended, excused and unexcused.

**How do I see who changed what?**
RECENT ACTIONS on the admin page; the whole log under MANAGE > ACTION LOG,
with a filter and LOG TO CLIPBOARD. Every line is dated and signed, and
every action done to a player is on their file too.

## Nets, radio

**How do I add a net?**
EDIT STRUCTURE > NETS (the net's name, its description, its place on the
rail), or the `<unitId>.nets` document. Then list it in the `nets` of the
roles that may read it. Squad nets are never listed - they exist because
the squads do.

**How do I change the radio plan?**
The `<unitId>.radio` document: every key is a `ghostFR_radio_*` value from
[config_radio](config_radio) - `srChannels`, `mrChannels`, `srSquadChannel`
and the rest. The names in `mrChannels` must match the platoon tabs' nets.
Read at the next mission start.

## The database and servers

**Where is everything stored?**
[TAC//PAC - Where the data lives](TAC-PAC#where-the-data-lives). Short
form: the server's profile always; MongoDB on top of it with
`sync = "service"`.

**How do I import a roster from a spreadsheet?**
Save it as `pac_roster.csv` in the mission (its root or `config\`), with a
header row and a `steamId` column. Then admin page > **IMPORT CSV** (in the
DATABASE row) reads it on the server and writes one record per row, keyed by
Steam id - a row updates the record it names and leaves the rest (awards,
notes, attendance) alone; a new id is added. Recognised columns: `steamId`,
`name`, `milsimName`, `rank` (id, name or abbrev), `group`, `role`, `status`,
`skills` (ids, space/`;`/`|` separated), `discordId`, `enlisted`, `promoted`,
`clearance`, `company`, `reportsTo`, `operatorId`. Unknown ranks/roles/skills
are skipped and named in the result. `framework.Stratis` ships a two-row
example.

**I built a roster with the database off - how do I get it into the database?**
The database becomes the source of truth the moment it has a store, and it
replaces the profile at every boot. So seed it while it is still empty: with
the roster in the server profile and no store document yet in the database,
start the mission with `sync = "service"` - the first boot pushes the profile
roster up. If the database already has a store, EXPORT STORE on the admin
page and `tools/pacdb/pac_sync.py push-store` it, or IMPORT (MERGE) the other
server's export. A roster seeded with `sync = "off"` never reaches the
database on its own.

**How do I move the unit to a new server?**
Point both servers at the same database and they share everything. Without
one: STRUCTURE OUT on the old server, STRUCTURE IN on the new; EXPORT STORE
and RESTORE STORE for the roster.

**Can I run without a database?**
Yes - `sync = "off"`. The roster lives in the server's profile and the
config in the mission files; the clipboard buttons move data by hand.

**How do I let my server reach the Atlas database?**
Add the server's public IP to the cluster's Network Access list - Atlas
refuses every other address, which is what makes the connection string safe
in a CBA setting. Step by step, with how to find the IP and what to do when
it changes: [Atlas IP allowlist](Atlas-IP-Allowlist).

**Does BattlEye block the extension?**
The dedicated server process is not policed the way clients are, and no
client ever loads the file. Run with BattlEye on; only a `Blocked loading
of file` line naming `ghostd_pacdb` in the server `.rpt` would mean
anything, and the answer then is whitelisting.

**The group menu says it is waiting for the unit's roles.**
The server has not reached READY yet - the database is slow or not
answering. It waits a minute at most, then opens with whatever it has.
Read the boot lines in the `.rpt`.

**How do I get rid of the sample data?**
Admin page > ADMIN TOOLS > REMOVE SAMPLE. It takes out exactly what SEED
SAMPLE DATA put in.
