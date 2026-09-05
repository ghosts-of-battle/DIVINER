# Change notes

Every change to DIVINER, in enough detail to port it to `ghost` by hand.
Newest first. The rules for what goes in an entry are in [CLAUDE.md](CLAUDE.md).

Each entry carries a **Sync** verdict:

| | |
|---|---|
| `yes` | port to `ghost`; rewrite `ghostD_` to `ghost_` and `z\ghostD\addons` to `z\ghost\addons` |
| `no` | DIVINER-only divergence - porting it back would undo the split |
| `careful` | the two repos differ here; the entry names the conflict |

`ghost_missionConfig_*`, `ghost_radio_*` and `GHOST_Nets` are the mission/mod
contract and are spelled the same in both repos. Never rewrite them.

---

## Unreleased

### Skill colours: a `color` on each skill, drawn on the squad panel
**Sync:** `careful` - `addons/pac` + `addons/tacpad_apps`; the Atlas `.skills` document rides the service layer.

Asked 2026-09-05 off the PLATOON STATUS screenshot: "colour them if you can
- medic, cls green, tl and atl yellow, pick a colour for each of the rest;
needs to be a config doc in the storage". The colour is a field on the skill
in the structure - config, editor and database alike - not a table in code.

- `addons/pac/functions/fnc_structFields.sqf` - skills gain
  `["color", "t", "COLOUR", ...]` (`"R,G,B"` in 0-255; the third editor row).
  Read from `CfgGFA_PAC >> skills` by `fnc_loadStructure`, coerced by
  `fnc_adminStructure`, persisted to `<unitId>.skills` by `fnc_structurePersist`.
- **New `addons/pac/functions/fnc_skillColor.sqf`** (PREP'd after
  `PREP(hostRefresh)`): `[id, default]` returns `[r, g, b, a]` in 0-1 from the
  skill's `color`; unknown id, empty or unparsable colour returns the default.
- `addons/tacpad_apps/functions/fnc_appSquad.sqf` - `_skillsOf` now holds
  `[abbrev, id]` pairs; the SKILLS cell draws each code in its own colour via
  `ghostD_pac_fnc_skillColor` (guarded `isNil`), stepping by `ctrlTextWidth`,
  stopping at the STATUS column; on an accent-filled ("out") row the codes stay
  ground.
- **Mission:** `framework.Stratis/config/config_pac.hpp` skills got
  `color` (cls, medic 76,175,80; lead 255,193,7; eng 66,133,244; eod
  229,57,53; jfo 255,152,0; isr 171,71,188; uav 38,198,218; pilot 77,182,172).
- **Database:** `framework.skills` in Atlas re-PUT with the same colours
  added to every item, every other field kept (HTTP 204, read back).
- **Wiki:** `wiki/config_pac.md` `## skills` documents `color`.

**Checked:** `hemtt check`; see the build note at the end of this batch.

### Platoon status: SKILLS wide enough for nine codes, RADIO in its own column, taller rail tiles, no map centring
**Sync:** `yes` - `addons/tacpad_apps/functions/fnc_appSquad.sqf`; rewrite `ghostD_` to `ghost_`.

Four things off one screenshot (2026-09-05):
- "make wider so all these skills show" - `_cols` re-cut: ROLE 0.150,
  SKILLS 0.205, STATUS 0.420, ACE 0.560, GRID 0.710, RADIO 0.815, RANGE
  0.925 (SKILLS from 0.12 to 0.215 of the table; ROLE, two letters, gives it
  up).
- "text seems to be overlapping" - the RADIO value was drawn into column
  **5**, the GRID column, so the channel sat on top of the grid. It is column
  **6** now.
- "make the row taller so the text fits, ok to move ACE down" - the four
  rail tiles (WIA, UNRESPONSIVE, AMMO AVG, KIA) are `_rowH * 2.4` tall (was
  1.9) with the 1.4-size number at `+0.95 rowH`, h `1.3 rowH`; DISPERSION
  and MY ACE REPORT move down with them.
- "does not centre the map, had never planned for it, so remove" - the row
  hit no longer calls `ctrlMapAnimAdd`; it only selects. The foot hint reads
  `TAP A ROW TO SELECT A PLAYER` / `TAP ANOTHER ROW TO CHANGE THE SELECTION`.

**Checked:** `hemtt check`; see the build note at the end of this batch.

### TAC//MSG reader: one label column on the card, the subject instead of the flattened preview, air between lines
**Sync:** `yes` - `addons/tacpad`, `addons/tacpad_apps`; rewrite `ghostD_` to `ghost_`.

- `addons/tacpad/functions/fnc_readerThreadView.sqf` - the card drew a short
  key column (HEADER, SITUATION) and a full title column (1. SITUATION) and
  started the answer at 40% of the card ("do not need both, use only the
  opord column; expand left to the line"). The key column is gone; the title
  sits at `_cx + _pad`, width `0.23 cardW`; the answer starts at `0.25 cardW`
  with width `0.73 cardW - pad`. `_lineTitle` is no longer destructured.
- `addons/tacpad/functions/fnc_readerNetView.sqf` - the line under the tags
  was the whole report flattened with " - " ("again remove this preview").
  It is now the thread's `subject` (falling back to the template title),
  bold, 0.85.
- `addons/tacpad_apps/functions/fnc_panelReader.sqf` - the map-side thread
  view steps `1.35` rows per rendered line (was 1) and `0.5` between
  messages ("hard to read, add space between sections or lines").

**Checked:** `hemtt check`; see the build note at the end of this batch.

### PAC app: skills on one line, order blocks sized to their text, a taller frame for an open order
**Sync:** `yes` - `addons/pac/functions/fnc_app.sqf`; rewrite `ghostD_` to `ghost_`.

- MY RECORD listed skills one per row, a column a screen tall ("line these
  up horizontally"): they are one wrapped line joined with `   ·   `.
- OPORD sized every block at a line per **80** characters; the column holds
  about 170 at this width and scale, so each block was three times taller
  than its text ("bit too much space") and the later sections fell off the
  fixed-height frame ("missing information and rows"). Now a line per **150**
  characters, half the gap, and the frame is `0.88` tall while an order is
  open (`0.58` otherwise) - `_tall` decides at `appFrame`.

**Checked:** `hemtt check`; see the build note at the end of this batch.

### Admin panel: ADMIN chip centred, CLOSE top-right, execute targets fit the code column, COPY for the return
**Sync:** `yes` - `addons/adminpanel`; rewrite `ghostD_` to `ghost_`.

Off the TAC//ADMIN screenshot (2026-09-05):
- `addons/adminpanel/ui/dialog.inc.hpp` - `HEADER_ADMINCHIP` x 0.914 to
  **0.461** (centred in the title bar); new `HEADER_CLOSE` (RscADMPButton,
  `closeDialog 2`) at the chip's old place, 0.914 / 0.012 / 0.078 / 0.028.
- Same file - the three execute targets fit inside the code column's right
  edge (0.417): `REMOTEEXEC_SERVEREXEC(_BACK)` w 0.056 to **0.048**;
  `REMOTEEXEC_LOCALEXEC(_BACK)` x 0.316 to **0.308**, w to **0.048**;
  `REMOTEEXEC_EXECBUTTON(_BACK)` x 0.374 to **0.358**, w 0.090 to **0.058**.
  REMOTE used to run to 0.464, into the RETURN column, which is why RETURN
  sat a row lower. `REMOTEEXEC_RETURN_HEAD` y 0.750 to **0.716** (level with
  EXECUTE), h 0.026; `REMOTEEXEC_RETURN` y 0.776 to **0.750**, h 0.198 to
  **0.184** (level with the code box, top and bottom).
- Same file - new `REMOTEEXEC_COPY` (RscADMPButton) on the RUN/CLEAR row at
  0.425 / 0.942 / 0.062 / 0.032, `onButtonClick` `FUNC(execCopy)`.
- `addons/adminpanel/ui/idcs.inc.hpp` - `IDC_ADMINPANEL_HEADER_CLOSE 26236`,
  `IDC_ADMINPANEL_REMOTEEXEC_COPY 26237`.
- **New `addons/adminpanel/functions/fnc_execCopy.sqf`** (PREP'd after
  `PREP(execClear)`): reads every row of the RETURN listbox
  (`IDC_ADMINPANEL_REMOTEEXEC_RETURN`), `copyToClipboard` joined with `endl`,
  notifies through `ghostD_notify_fnc_notify` (guarded).
- `fnc_style.sqf` only re-texts the chip and scales all controls uniformly,
  so the new positions hold.

**Checked:** `hemtt check`; see the build note at the end of this batch.

### Wiki made DIVINER's own before its first publish; publish script added
**Sync:** `no` - wiki and tools only, and the removals are DIVINER's divergence (`ghost` keeps ALiVE and its forwarder docs).

Asked 2026-09-05: "can you publish the wiki to github". Before pushing 46
pages to a public wiki under DIVINER's name, the pages that still described
the sibling repo or the dropped systems were fixed:

- `wiki/_Sidebar.md` heading `Ghost Wiki` to `DIVINER Wiki`; `wiki/_Footer.md`
  links DIVINER, the 2040 mission repository and DIVINER's issues;
  `wiki/Home.md` "Mod documentation" no longer links a `docs/` folder DIVINER
  does not have (points at Addon Options, the DIVINER and 2040 repositories);
  `wiki/Installation.md` row `Ghost` to `DIVINER` with DIVINER's releases, plus
  a new required row for the framework mission (two-part system).
- ALiVE forwarder wording removed and replaced with what reads the keys in
  DIVINER (the reader card, the OPORD / METT-TC autofill, the CASEVAC anchor):
  `wiki/config_messaging.md` (two passages), `wiki/Messaging-Deck.md` (two),
  `wiki/Cross-File-Contracts.md` (one table row), `wiki/Intel-Packages.md`
  (one word). `wiki/description-ext.md` `CfgCommands` row no longer calls it
  the cTab whitelist.
- **New `tools/wiki/publish_wiki.sh`**: clones `DIVINER.wiki.git`, replaces
  every page with `wiki/*.md` (deletions propagate), commits, pushes; `--dry-run`
  shows the diff. Plain git over HTTPS through the credential manager; `gh` is
  not installed on this box. Explains the one thing it cannot do: create the
  wiki - GitHub only creates `.wiki.git` after the first page is made in the
  web UI (`has_wiki` is true on the repo; the wiki repo did not exist at
  17:40).
- `SYNC.md` "References left pointing at ghost" notes the wiki repoint and
  says not to port the removals back.

**Checked:** every internal wiki link resolves (one false positive in a code
sample); no secrets in `wiki/` (grepped for the Atlas password, user, cluster
and API key). Not yet published - waiting on the wiki's first page.

### Lint: L-S26 braces off two cheap comparisons
**Sync:** `yes` - style only; rewrite `ghostD_` to `ghost_`.

Two `help[L-S26]` hits the user pasted from `hemtt check`, both in lines
written 2026-09-05: `addons/pac/functions/fnc_app.sqf` (`_tall = ... &&
{GVAR(openOpord) isNotEqualTo ""}`) and
`addons/tacpad/functions/fnc_readerNetView.sqf` (`_subject isEqualType "" &&
{_subject isNotEqualTo ""}`). The `{ }` are removed; a comparison is cheaper
than the short circuit. No behaviour change - a comparison binds tighter than
`&&` in SQF, so the meaning is identical.

**Checked:** `hemtt check` clean with every help/warning line shown (1050
sqf, none). **Not re-released**: 0.1.0.1045 already has the identical
behaviour; this ships with the next release.

### Build note - 0.1.0.1045
The five entries above, and the two below (host refresh, slot seeding),
ship in **0.1.0.1045**: `hemtt check` clean (1050 sqf), `hemtt release`
clean with Arma closed, BUILD bumped to 1046. Verified from the staged
artifacts, not the log - the pac PBO header carries `fnc_hostRefresh`,
`fnc_seedFromUnit`, `fnc_skillColor`, `fnc_panelTraining`,
`fnc_promotionPoints`; the adminpanel PBO carries `fnc_execCopy`; signature
`ghostD_0.1.0.1045`, `releases/ghostD-0.1.0.1045.zip` and `ghostD-latest.zip`
at 17:13. `releases/ghostD-0.1.0.1044.zip` remains the mislabeled stale
archive described below and should be deleted. Nothing in this batch is
verified in game yet.

### The host now sees its own publishes - roster, summary and structure refresh on a hosted game
**Sync:** `yes` - `addons/pac`; rewrite `ghostD_` to `ghost_`. Matters for every player-hosted game in `ghost` too.

**The failure, in its own terms.** Reported 2026-09-05: "the admin panel is
not showing my rank change after it's made in PAC, and it is showing in
game." On a player-hosted game the host is server and client in one
namespace, and `publicVariable` never fires the sender's own
`addPublicVariableEventHandler`. So after an edit the server published the
roster and summary, every remote client refreshed, and the host - the one
machine playing - did not: the middle column came back through the direct
`FUNC(adminRecv)` reply, but the roster list (`FUNC(panelFillRoster)`), the
summary block, the structure editor (`FUNC(structSection)`) and the
management window (`FUNC(manageSection)`) stayed as they were. The unit
carried the new rank on panel close (`FUNC(panelReapply)`), so the change
"showed in game" and not on the page.

- **New `addons/pac/functions/fnc_hostRefresh.sqf`** (PREP'd in
  `addons/pac/XEH_PREP.hpp` after `PREP(panelTraining)`): `["roster"]` runs
  `FUNC(panelReapply)`, `FUNC(panelFillRoster)`, `FUNC(manageSection)`;
  `["structure"]` runs `FUNC(takeServer)`, `FUNC(structSection)`,
  `FUNC(panelOpened)`, `FUNC(manageSection)` - the host's copy of the
  handlers `XEH_postInit.sqf` registers for remote clients. Exits at once
  unless `isServer && hasInterface`. `panelReapply` rather than
  `applyOnClient` on purpose: the latter's server round trips would run
  `FUNC(seedFromUnit)` and publish again, and this again.
- `addons/pac/functions/fnc_publish.sqf` - `["roster"] call FUNC(hostRefresh)`
  after `publicVariable QGVAR(opordArchive)`.
- `addons/pac/functions/fnc_boot.sqf` (step 6),
  `addons/pac/functions/fnc_structurePersist.sqf`,
  `addons/pac/functions/fnc_structureImport.sqf` -
  `["structure"] call FUNC(hostRefresh)` after their
  `publicVariable QGVAR(structureSvc)` / `QGVAR(settingsSvc)` pair.

**Behaviour:** on a hosted game the host's own rank and skills now update
the moment an admin edits them, not on panel close; the roster list, the
summary and the management window redraw on every publish. Dedicated servers
and remote clients are unchanged.

**Checked:** `hemtt check` clean. **Shipped in 0.1.0.1045** (verified:
`fnc_hostRefresh` in the pac PBO header). It was NOT in 0.1.0.1044: that
release errored removing `.hemttout\release` (a file in it held by another
process) and re-staged the previous build's PBOs under the 1044 signature
and `releases/ghostD-0.1.0.1044.zip` - a mislabeled 1043; that zip should be
deleted. Not yet verified in game.

### The slot a player picks no longer becomes their PAC role or squad
**Sync:** `yes` - `addons/pac/functions/fnc_seedFromUnit.sqf`; rewrite `ghostD_` to `ghost_`.

Reported 2026-09-05: "the role I select in the role picker should not
become my role in PAC and in the db." `FUNC(seedFromUnit)` - called from
`FUNC(applyOnClient)` on every spawn - copied the Dynamic_Roles slot the
player took into an empty `roleId` (matched on the role's `slotTag`) and the
slot's squad into an empty `groupId`. A player who picked JTAC for one op
had JTAC as their billet on the roster and in the database from then on.

- `addons/pac/functions/fnc_seedFromUnit.sqf` - the `roleId` block (matched
  on `slotTag`) and the `groupId` block are removed; the record's billet and
  squad are now written only by the admin paths (`FUNC(adminSet)`,
  `FUNC(csvImport)`, `FUNC(import)`, `FUNC(seedSample)`, the management
  window). Kept: the rank floor (an empty `rankId` takes the structure rank
  whose `armaRank` matches the unit's) and the one-time skills seed from the
  slot's role (`skillsSeeded`). The signature is unchanged; parameter 3
  (group name) is accepted and unused. Header rewritten.

**Behaviour change:** a new player's roster row shows an empty ROLE and
GROUP until an admin sets them, instead of whatever slot they first took.
The skills seed from the first slot is unchanged - a separate decision if
the unit wants that gone too.

**Wiki:** `wiki/TAC-PAC.md` "Slots and loadouts" opens with the rule: the
record drives the slot, never the other way; a new player shows ROLE and
GROUP empty until an admin sets them.

**Checked:** `hemtt check` clean. **Shipped in 0.1.0.1045**; absent from the
mislabeled 0.1.0.1044 for the reason in the entry above. Not yet verified in
game.

### Play time goes to the database on logon and logoff; no database write before READY
**Sync:** `careful` - `addons/pac`; rides the service layer (`svcSave`), which `ghost` may not have.

Asked 2026-09-05: "time tracking for players - save to db on player logon
and logoff". This is the play-time exception to the SAVE-only rule, made
concrete: a player's session row reaches Mongo the moment they connect and
the moment they leave, not only at mission end.

- `addons/pac/functions/fnc_sessionStart.sqf` - the save after the row is
  appended is now `[true, true] call FUNC(storeSave)`: forced past the
  debounce, and to the database.
- `addons/pac/functions/fnc_sessionEnd.sqf` - likewise
  `if (_found) then {[true, true] call FUNC(storeSave)}`, so a server that
  dies a minute after a player leaves has already put their time down.
- `addons/pac/functions/fnc_storeSave.sqf` - **the database push now also
  requires `ghostD_pac_ready`**: `if (_toService && GVAR(svcUp) &&
  {missionNamespace getVariable [QGVAR(ready), false]})`. Header rewritten to
  name the four callers (SAVE, logon, logoff, mission end).

**Why the READY gate, in the failure's own terms.** Boot step 3 sets
`svcUp` true when the service answers; step 5, up to 20 s later, reads the
store back. Between them the in-memory store is the profile copy, which can
be smaller than the database. The host's own logon always lands in or near
that window. A forced database write there would push the profile copy over
the real store - the same wipe class fixed two entries below. `GVAR(ready)`
is set only after the store is adopted, so before it nothing writes the
database; the session row stays in memory and the next write carries it.

**Behaviour:** one `saveProfileNamespace` plus one async extension push per
connect and per disconnect. Both write the whole store document, so a logon
or logoff never drops anything already in the database. A crash mid-session
still loses the time since that player's logon (the heartbeat updates
lastSeenAt in memory only); a periodic database flush is a separate decision.

**Wiki:** `wiki/TAC-PAC.md` - "Attendance and op windows" now states that a
logon and a logoff each write the store to the database, and that STOP on a
window is a local save; "Where the data lives" now lists the four database
writes (SAVE, logon, logoff, mission end), says the boot never writes the
database back, and drops the old "pushes every save" claim.

**Checked:** `hemtt check` clean; release staged as 0.1.0.1043. Not yet
verified in game.

### Promotion points, with the formula as an editable structure section
**Sync:** `careful` - `addons/pac`; the `.promotion` database document rides
the service layer (`svcStructure` / `svcPushStructure`), which `ghost` may
not have. The record-side and config-side pieces port with the prefix rewrite.

Asked 2026-09-05: "a promotion point system based on attendance, time in
service, time in grade, training, awards - make the formula for points an
editable doc". The formula is a new structure section, **`promotion`**, whose
items are `{name, value}` keyed by meaning: weights `hour`, `op`,
`serviceMonth`, `gradeMonth`, `training`, `award` (points per unit) and
rungs `rank_<rankId>` (points required to hold that rank). Nothing is
hard-coded; a key that is not listed counts as 0.

- **New `addons/pac/functions/fnc_promotionPoints.sqf`** (server; PREP'd in
  `addons/pac/XEH_PREP.hpp` after `PREP(attendanceOf)`): `[uid]` returns
  `[points, breakdown, nextRankId, needed, currentThreshold]`. Hours are
  summed off `GVAR(sessions)` the way `fnc_publish` totals them; ops are
  `FUNC(attendanceOf) # 1`; service and grade months are days since
  `enlistedAt` / `promotedAt` over 30; training and awards are counts on the
  record. `points = round(sum(qty * weight))`. The next rank is the lowest
  `rank_*` rung strictly above the current rank's rung.
- `addons/pac/functions/fnc_structFields.sqf` - `case "promotion"`: one
  labelled field `["value", "n", "VALUE", ...]`.
- `addons/pac/functions/fnc_structOpened.sqf` - `["promotion", "PROMOTION"]`
  added to the section combo (before ADMINS).
- `addons/pac/functions/fnc_structSection.sqf` - hint text for `promotion`;
  ID label reads `KEY` for it.
- `addons/pac/functions/fnc_adminStructure.sqf` - `"promotion"` added to the
  section whitelist (line 50) and the header.
- `addons/pac/functions/fnc_loadStructure.sqf` - `"promotion"` added to the
  config-section list, so `CfgGFA_PAC >> promotion` classes are read
  (`name` + `value` as number).
- `addons/pac/functions/fnc_svcStructure.sqf` - `"promotion"` added to the
  per-section document read list (`<unitId>.promotion`).
- `addons/pac/functions/fnc_svcPushStructure.sqf` - `"promotion"` added to
  the first-boot push list.
- `addons/pac/functions/fnc_structureAdopt.sqf` - `"promotion"` added to the
  "rides along when the document has it" list, so a database without one
  keeps the mission's.
- `addons/pac/functions/fnc_adminGet.sqf` and `fnc_adminSet.sqf` - the
  record COPY sent to the admin page carries a transient `"_promotion"` key
  (`[uid] call FUNC(promotionPoints)`); it is never written to the stored
  record or the store document.
- `addons/pac/functions/fnc_panelFill.sqf` - `PAC_IDC_SERVICE_LINE` is now
  two lines: time in service / grade, then
  `promotion  N pts   next  <Rank>  at M,  K to go   (breakdown)`.
- `addons/pac/functions/fnc_operatorJson.sqf` - new top-level `promotion`
  block: `points`, `current_rank_threshold`, `next_rank`, `next_rank_id`,
  `points_to_next`, `breakdown [{factor, quantity, points_each, points}]`.
- `addons/pac/ui/dialog.inc.hpp` - `SERVICE_LINE` `h` 0.026 to 0.040 and the
  middle column re-laid (see the training entry below).
- **Mission:** `framework.Stratis/config/config_pac.hpp` gained
  `class promotion` with the defaults (hour 1, op 5, serviceMonth 2,
  gradeMonth 1, training 3, award 10; rungs private 0, corporal 40, sergeant
  100, lieutenant 200, captain 320, major 480, colonel 700).
- **Database:** the same defaults were PUT to Atlas as `framework.promotion`
  (HTTP 204, read back 13 items), because `frameworkmongo` carries no
  sections on disk. This is a new config document; the store was not touched.
- **Wiki:** `wiki/config_pac.md` new `## promotion` and `.promotion` in the
  document list; `wiki/TAC-PAC.md` new `## Training and promotion points`.

**Contract:** new structure section `promotion`; new database document
`<unitId>.promotion`; new `promotion` block in the operator file. Points are
advisory - rank is still set by an admin.

**Checked:** `hemtt check`; release staged. Not yet verified in game.

### Training log on the player record
**Sync:** `yes` - `addons/pac`; rewrite `ghostD_` to `ghost_`.

Asked 2026-09-05: "add a training section - simple - date, time and notes".
A new record list, **`training`**, `[[when, by, text], ...]`, the same shape
as `notes`; recorded on the operator file and counted by the promotion
formula.

- `addons/pac/functions/fnc_recordFields.sqf` - `["training", []]` added
  (after `notes`); `FUNC(recordUpgrade)` gives older records the key.
- `addons/pac/functions/fnc_adminSet.sqf` - new fields **`trainingAdd`**
  (value: the text; if it starts with `YYYY-MM-DD` that day is the entry's
  date and is stripped from the text - back-dating a course) and
  **`trainingRemove`** (value: the index into the record's `training` list).
  Log type `"training"`, detail `training: <when> <text>` /
  `training removed: <when> <text>`. Header updated.
- **New `addons/pac/functions/fnc_panelTraining.sqf`** (client; PREP'd in
  `addons/pac/XEH_PREP.hpp` after `PREP(panelNote)`): `["add"]` sends the
  edit box text through `FUNC(panelSet)`; `["remove"]` sends the selected
  row's stored index (its `lbData`).
- `addons/pac/functions/fnc_panelFill.sqf` - clears and fills
  `PAC_IDC_TRAINING_LIST`, newest first, each row's `lbData` = its index into
  the stored list.
- `addons/pac/functions/fnc_operatorJson.sqf` - `personnel_logs.training`
  `[{date, logged_by, notes}]`.
- `addons/pac/ui/idcs.inc.hpp` - `PAC_IDC_TRAINING_TITLE 80`,
  `PAC_IDC_TRAINING_LIST 81`, `PAC_IDC_TRAIN_EDIT 82`, `PAC_IDC_TRAIN_ADD 83`,
  `PAC_IDC_TRAIN_REMOVE 84`.
- `addons/pac/ui/dialog.inc.hpp` - middle column re-laid to fit a TRAINING
  block between AWARDS and NOTES: `SKILLS_LIST` h 0.190 to 0.130 (y 0.454),
  `AWARDS_LIST` h 0.104 to 0.074 (y 0.616), award row y 0.694, new
  `TRAINING_TITLE` 0.732 / `TRAINING_LIST` 0.758 h 0.066 / `TRAIN_EDIT`,
  `TRAIN_ADD`, `TRAIN_REMOVE` 0.828, `NOTES_TITLE` 0.866, `NOTES_LIST` 0.892
  h 0.046; the note row keeps y 0.942 so the column bottom is unchanged.
- **Wiki:** `wiki/TAC-PAC.md` `## Training and promotion points`.

**Contract:** new record key `training`; new `adminSet` fields
`trainingAdd` / `trainingRemove`; new operator-file list
`personnel_logs.training`.

**Checked:** `hemtt check`; release staged. Not yet verified in game.

### The database is written only by SAVE and mission end - the boot never writes it
**Sync:** `careful` - `addons/pac` store contract changes; `ghost` may lack the service layer.

**The failure, in its own terms.** Reported 2026-09-05, reproduced by the user:
"i load the game, open an empty mission, the db is wiped, i open the
frameworkmongo mission and there is no data". The Atlas store document was
found holding one bare record (the host's own, no rank) after sample data and
rank edits had been entered and saved repeatedly. Two compounding faults:

1. **The boot force-saved the store back to Mongo on every start.** Step 6 of
   `fnc_boot.sqf` called `[true] call FUNC(storeSave)`, and with `svcUp` set
   that pushed the in-memory roster over the database document it had just read
   in step 5. Any moment the in-memory roster was smaller than the database
   (an empty profile carried in from another mission, a slow read) the
   database was overwritten with the smaller set. A read-back step re-writing
   its source is the wipe vector.
2. **A non-PAC mission blanked the shared profile store.** `XEH_postInit.sqf`
   registered the `"Ended"` mission-end save, `"PlayerConnected"`,
   `"PlayerDisconnected"` and the heartbeat on every mission. The empty editor
   map never ran `fnc_storeLoad` (the boot's `CfgGFA_PAC` gate exited first),
   so its `GVAR(players)` was `XEH_preInit`'s empty hashmap, and its mission-end
   save wrote 0 players to the profile. The next framework boot then loaded that
   empty profile in step 4 and, through fault 1, could carry it at the database.

**The new contract (user, 2026-09-05: "no write on boot, no write any time
unless a button is pushed; updating play time is the only exception; make sure
play time and actions do NOT get overwritten"):**

- `addons/pac/functions/fnc_storeSave.sqf` - new second parameter
  `_toService` (BOOL, default **false**). It always writes the local profile;
  it pushes to the service (`FUNC(svcSave)`) only when
  `_toService && GVAR(svcUp)`. Header rewritten to state the rule.
- `addons/pac/functions/fnc_boot.sqf` - step 6 is now
  `[true, false] call FUNC(storeSave)`: **profile only, never the database.**
  The step-5 `"empty"` boot log line no longer claims 6/6 creates the store
  document (it is created on the first SAVE or mission end). Header comment for
  6/6 updated.
- `addons/pac/functions/fnc_adminSave.sqf` - the SAVE button is
  `[true, true] call FUNC(storeSave)`: **the one human commit to the database.**
- `addons/pac/XEH_postInit.sqf`, three changes:
  - the `FUNC(bootScreen)` spawn is gated on
    `isClass (missionConfigFile >> "CfgGFA_PAC")`;
  - after `if (!isServer) exitWith {};` a new gate: if the mission has no
    `CfgGFA_PAC`, set `GVAR(ready) = true`, `publicVariable QGVAR(ready)`,
    log, and **exit** - so the boot spawn, `"ExtensionCallback"`, `"Ended"`,
    `"PlayerConnected"`, `"PlayerDisconnected"`, the stale-session sweep and the
    heartbeat are **never registered** on a non-PAC mission;
  - the `"Ended"` handler is `[true, true] call FUNC(storeSave)`: **mission end
    is the play-time commit**, the one automatic database write. It writes the
    whole store (players, sessions, windows, action log), so play time and
    actions accumulated this session land and nothing already in the database is
    dropped.

**Every other `storeSave` caller is now profile-only** (they pass no second
argument): `fnc_adminSet`, `fnc_seedSample` (add and remove), `fnc_csvImport`,
`fnc_import`, `fnc_structureImport`, `fnc_structurePersist` (its store save;
its structure push via `svcSave` is unchanged), `fnc_seedFromUnit`,
`fnc_record`, `fnc_loadoutStore`, `fnc_sessionStart`, `fnc_sessionEnd`,
`fnc_windowSet`, `fnc_adminLogAdd`. A player picking a role in game, a
connect, a spawn, an edit in the panel: none of them reach Mongo. **An admin
presses SAVE to commit edits, seeds and imports.**

**Why this is wipe-proof.** The database is written only when
`GVAR(svcUp)` is true, which step 5 sets only after a successful read (an
error sets it false). So at every database write the in-memory store is the
database's content plus this session's additions - never smaller - and the
whole document is written, so sessions and the action log always ride along.

**Behaviour change to tell admins:** edits no longer trickle to Mongo on their
own thirty-second debounce. Press SAVE. Mission end also commits.

**Port notes:** rewrite `ghostD_` to `ghost_`. If `ghost` has no
`sync = "service"` / `svcSave` layer, only the `CfgGFA_PAC` gate in
`XEH_postInit.sqf` and the boot step-6 change matter there.

**Checked:** `hemtt check` clean (71 configs, 1045 sqf); release staged. Not
yet verified in game - requires a full Arma relaunch to load the new PBO.

### Test as a real Steam id in the editor
**Sync:** `no` - `addons/pac`.

The editor and singleplayer have no Steam id (`getPlayerUID` is ""), so a
tester never matches a real Steam-id record and "the storage did not load"
for their own operator. New CBA setting `ghostD_pac_testUid` ("Test as Steam
id (editor only)", Ghosts of Battle PAC > Service): put your 17-digit id
there and `fnc_uid.sqf` returns it in the editor, so you ARE that operator -
the database's record for you loads and your edits land on it. Empty keeps
the throwaway `SP:<profileName>` id. Ignored in multiplayer, where
`getPlayerUID` is the real id.

**Reminder:** a new build only applies after Arma reloads the mission - the
12:14 rpt was still running a pre-fix PBO (the empty editor map booted in
full, which the CfgGFA_PAC gate now prevents).

**Checked:** `hemtt check` clean; release staged.
### TAC//PAC only boots for a mission that declares it
**Sync:** `careful` - `addons/pac/functions/fnc_boot.sqf`.

Asked 2026-09-05: "the connection to the storage should only happen if the
framework mission is being loaded". `fnc_boot.sqf` now exits at once when the
mission has no `CfgGFA_PAC` - the empty editor map a maker opens first, the
main-menu scene, any non-PAC mission - setting `ghostD_pac_ready` and doing
nothing else: no store load, no publish, no `sync = "service"` service step,
so the `ghostd_pacdb` extension is never called and MongoDB never reached
outside a real TAC//PAC mission. The mod stays loaded and inert; the boot
screen does not show (READY is already set). A mission that declares
`CfgGFA_PAC` - `framework.Stratis` (profile) or `frameworkmongo.Stratis`
(service) - boots exactly as before.

**Checked:** `hemtt check` clean; release staged.
### Editor / SP testing: a stable id when getPlayerUID is empty
**Sync:** `careful` - `addons/pac` (new `fnc_uid`); `adminpanel/fnc_isAdmin.sqf`.

Reported 2026-09-05, with the tester's workflow: "i open arma ... open an
empty map in the editor then load the mission". In the editor preview and
singleplayer `getPlayerUID player` is "", and every TAC//PAC record is keyed
on it - so the tester's own record, rank and skills matched nothing and read
as empty ("storage did not load", "still a pvt"). New `fnc_uid.sqf` returns
`getPlayerUID`, or a stable per-profile fallback `SP:<profileName>` when it is
"" - marked so it is never mistaken for a 17-digit Steam id (CSV import,
admin lists, cross-server merges stay Steam-id only). In a real game it is a
passthrough. Wired into the client identity paths: `fnc_applyOnClient`,
`fnc_panelReapply`, `fnc_app`, `fnc_seedFromUnit`, `fnc_autoSlot`,
`fnc_canTake`, `fnc_loadoutSend`, `fnc_loadoutStore`, `fnc_structMe`. The
tester now gets a real record, seeded from their role, that ranks and skills
apply to. `adminpanel/fnc_isAdmin.sqf`: a local non-multiplayer host with an
empty uid is the mission maker and passes the admin check, so the editor is
not locked out of the pages with everyone-admin off.

**Note on the earlier data loss:** the database `framework` store holds one
player because the reverted "newer local wins" guard had overwritten it; that
is separate from this and not recoverable from the .rpt.

**Checked:** `hemtt check` clean; release staged.
### The store guard discarded the database roster; boot logo squished; DUI required
**Sync:** `no` - `addons/pac`, docs.

Three, 2026-09-05.

- **"the storage did not load".** The "newer local wins" store guard added
  earlier (`fnc_boot.sqf` step 5) backfired: the server profile is shared
  across missions, so a `sync = "off"` run that saved a one-player store with
  a newer timestamp made the guard discard the real 17-player database store
  on the next `sync = "service"` boot (the rpt: "the database store ... is
  OLDER than this server's last save - keeping the profile copy"). Reverted:
  the database store is the source of truth for `sync = "service"` and wins
  over the profile, always. A rank set in game reaches the database through
  the edit's own save, the SAVE button and the forced save at mission end -
  not through a timestamp race.
- **The boot screen logo was squished.** `ui/bootscreen.hpp` sized the logo
  by stretching `w`/`h` in safezone fractions, which is not square on a 16:9
  screen. Now `w`/`h` are equal counts of `pixelW`/`pixelH` (one real pixel
  each) - the main menu's own square-picture idiom.
- **DUI - Squad Radar** added as a required mod in `STEAM.md` and
  `wiki/Installation.md`; ACRE2/TFAR are optional there.

**Checked:** `hemtt check` clean; release staged.
### Support window drew on the display, not a control - blank and erroring
**Sync:** `careful` - `tacpad_apps/fnc_supportRequestDraw.sqf`, `tacpad_apps/dialog.hpp` (`ghost_` in ghost).

From the 2026-09-05 rpt: a flood of `Error Params: Type Display (dialog),
expected Control` from `fnc_drawFill`/`drawText`/`drawFrame`/`drawHit` every
time the support request window drew. `fnc_supportRequestDraw.sqf` passed the
dialog DISPLAY to the tacpad draw helpers, which take a CONTROL parent
(`(ctrlParent _parent) ctrlCreate [..., _parent]`) - so every one of its 24
draw calls threw and drew nothing; the window showed only its map. The
support backdrop gets an idc (8962) and the draws hang on that control. The
squad panel's `[_display, ...] call appFrame` is correct - appFrame takes a
display and returns a body control - and was not touched.

Also, `STEAM.md` and `wiki/Installation.md`: cTab and ALiVE removed from the
optional list (DIVINER dropped ALiVE months ago; cTab is not used), ACRE2 /
TFAR moved from required to optional, Simplex Support Services named for the
fire-support tasking.

**Checked:** `hemtt check` clean; release staged.
### A TAC//PAC boot screen, like ALiVE's init
**Sync:** `no` - `addons/pac`.

Asked 2026-09-05: "add a boot screen like alive has". New `ui/bootscreen.hpp`
(RscTitles `ghostD_pac_bootScreen`, idcs 200-203) and `fnc_bootScreen.sqf`,
spawned on every client from `XEH_postInit.sqf`: a full-plate overlay - the
mark, "INITIALISING THE UNIT", a progress bar and the last five boot steps,
newest brightest - held until `ghostD_pac_ready`, then a READY beat and a
fade. It never flashes on an instant boot: shown only if the unit is still
initialising 0.75 s after the player exists, and a JIP client past READY
shows nothing; a 50 s cap frees the player if boot never comes up. Steps are
live because `fnc_bootLog.sqf` now `publicVariable`s `ghostD_pac_bootLog` and
a new `ghostD_pac_bootStep` fraction per line (small, six lines) - a
dedicated client sees the steps as the server reports them, not only the
whole log at READY. Vanilla `RscText`/`RscPicture`/`RscStructuredText`
forward-declared in `config.cpp` for the titles.

**Checked:** `hemtt check` clean; release staged. Not seen in game yet.
### Wiki: the CSV import and the current admin-page buttons
**Sync:** `no` - wiki only.

Asked 2026-09-05: "add to the wiki". `wiki/TAC-PAC.md`: a new "Importing a
roster from a CSV" section (the file, the columns table, a worked example),
the "Backups, export, import" button table rewritten to the current names
(EXPORT STORE, IMPORT STORE (MERGE), RESTORE STORE, STRUCTURE OUT/IN, IMPORT
CSV, EDIT STRUCTURE / MANAGE) and a note on the SAVE button and reapply-on-
close.
### CSV roster import from the mission
**Sync:** `no` - `addons/pac`, the missions.

Asked 2026-09-05: "a csv import function - csv in the mission can be imported
into the storage". New **IMPORT CSV** on the admin page (DATABASE row) ->
`fnc_panelCsv.sqf` (asks first) -> `fnc_csvImport.sqf` (server, admin-checked,
logged): the server reads `pac_roster.csv` from its own mission copy with
`loadFile` (tried at the mission root and `config\`), parses a header row and
one record per line keyed by `steamId`, and UPSERTS - a row fills the columns
it names and leaves awards, notes and attendance alone; a new id is seeded
(operator id, today's enlistment). Columns matched by name (case/space/
underscore ignored): steamId, name, milsimName, rank (id/name/abbrev, mapped),
group, role (id or name), status, skills (ids, `;`/space/`|`), discordId,
enlisted, promoted, clearance, company, reportsTo, operatorId. Ranks, roles,
statuses and skills the structure lacks are skipped and named back, never
written as orphans; a forced save and publish follow. New idc
`PAC_IDC_CSV_IMPORT` (79); the RESTORE/STRUCTURE row re-fitted to four
buttons. Both framework missions ship a two-row `pac_roster.csv` example.
FAQ updated.

**Checked:** `hemtt check` clean; release staged.
### A SAVE button on the admin page
**Sync:** `no` - `addons/pac`.

Asked 2026-09-05: "maybe a save button for after editing a players info".
Edits already save through `fnc_adminSet` (the disk write debounced 30 s so a
run down the roster is one write); the new **SAVE** button in the PLAYER
column header is the "put it down now" confirmation. `fnc_panelSave.sqf`
(client) -> new `fnc_adminSave.sqf` (server, admin-checked): a forced
`storeSave` to every backend past the debounce, then `publish` so every
client - the edited player included - reapplies rank and skills at once, and
a notify with the count and backend. New idc `PAC_IDC_M_SAVE` (78), painted
in `fnc_panelStyle.sqf`, PREP'd.

**Checked:** `hemtt check` clean; release staged.
### Support window broke the map key; closing the PAC page reapplies your rank
**Sync:** `careful` - `tacpad_apps/fnc_appSupport.sqf` (`ghost_` in ghost);
`no` for the PAC part.

Two reported 2026-09-05.

- **"after i used the support i no longer would open the map".**
  `tacpad_apps/fnc_appSupport.sqf` opened a support window by force-closing
  the tablet's host map display with `(findDisplay IDD_MAP) closeDisplay 2`.
  closeDisplay on the vanilla map desyncs the engine's map-visible toggle, so
  the M key afterward toggled a phantom-open flag and did nothing. Now
  `openMap false` - the sanctioned close - so the toggle stays in sync and M
  reopens the map.

- **"i was still a pvt in game ... closing pac does a reapply".** New
  `pac/fnc_panelReapply.sqf` puts the closing admin's own rank and skills
  back on their unit from the published roster - the local half of
  `applyOnClient` only, no auto-slot or loadout round-trips - wired to the
  admin page's `onUnload` (`ui/dialog.inc.hpp`). An admin who sets their own
  rank now carries it the moment they close the page.

**Checked:** `hemtt check` clean; release staged.
### Wiki: the Atlas IP allowlist page
**Sync:** `no` - wiki only.

Asked 2026-09-05: "add to the wiki how to whitelist ip's in mongo cloud".
New `wiki/Atlas-IP-Allowlist.md`: adding the game server's IP under Atlas
Security > Network Access, finding the address (rented host panel, `curl
ifconfig.me`, testing from a PC too), coping with a changing IP (edit the
entry, or a CIDR range), why "Allow access from anywhere" is the wrong
answer given the connection string rides in a CBA setting, and checking it
worked in the boot log. Linked from `Quick-Start-Database.md` step 3, a new
FAQ question, `_Sidebar.md` and `Home.md`. All internal wiki links verified.
### PAC CBA settings under their own category
**Sync:** `no` - `addons/pac/initSettings.inc.sqf` and doc references.

Asked 2026-09-05: "move all the pac cba settings to a new category Ghosts of
Battle PAC". The two settings the pac addon declares - `ghostD_pac_serviceUrl`
("Database") and `ghostD_pac_serviceKey` ("Service key") - move from
category ["Ghosts of Battle", "TAC//PAC service"] to
["Ghosts of Battle PAC", "Service"]. The in-game path is now Addon Options >
Ghosts of Battle PAC > Service, updated in `fnc_boot.sqf`'s log line and in
`wiki/Quick-Start-Database.md`, `wiki/TAC-PAC.md`, `wiki/config_pac.md` and
`tools/pacdb/README.md`. The setting ids are unchanged, so an existing
`cba_settings.sqf` `force` line still applies. The everyone-admin switch is
an adminpanel setting and stays under Admin Console.

**Checked:** `hemtt check` clean; release staged.
### Everyone-admin testing switch defaults to off
**Sync:** `careful` - `addons/adminpanel/initSettings.inc.sqf`; the setting id is `ghostD_adminpanel_everyoneAdmin` (`ghost_` in ghost).

Asked 2026-09-05: "set the default to off". The CBA setting "Everyone is an
admin (testing)" (Ghosts of Battle > Admin Console) defaulted to on since it
was added on 2026-09-04; it now defaults to **off**. Off, admin is the
TAC//PAC admins list, the mission's admin list and ghost's admin flag, the
way a real server runs. Turn it on only to look at the pages without an
admin list set up. No code path changed - only the default.

**Checked:** `hemtt check` clean; release staged.
### The database store could overwrite a newer local one; the logo replaced everywhere
**Sync:** `careful` for `addons/pac/functions/fnc_boot.sqf` (the guard is
new logic, portable; the rest of the entry is `no` - assets and DIVINER
paths).

**Rank "did not load" - the fix.** Reported 2026-09-05: a rank set in game
was gone next start. Boot step 5 adopted the database's store over the
profile UNCONDITIONALLY, so a save whose push to the database had not
landed - a mission end that tore down before the extension finished its
PUT, or an edit on a run that never pushed - was lost when the older
database copy replaced the newer profile at the next boot. `fnc_boot.sqf`
step 5 now takes the database store only when its `exportedAt` is not older
than this server's `meta.lastSave`; otherwise the profile stands and step 6
pushes it up. Same newer-wins rule the retired bridge path used. A rank set
locally is never overwritten by a stale database copy again. (The
database's own copy still wins when it is genuinely newer - another server's
save.)

**The logo, everywhere (user, 2026-09-05):** `newlogo_3_1024.png` replaces
the old mark. New `tools/` run wrote, from that source, the launcher and
in-game logos - `addons/media/images/logo_256.paa`, `logo_512.paa`,
`logo_1024.paa`, `logo_2048.paa`, the greyscale hover `logo_256_g.paa`,
`addons/main_menu/data/logo_512.paa`, and the repo-root `logo_256.paa`,
`logo_256_g.paa`, `newlogo.png` - each the mark alpha-trimmed and centred on
a transparent square, converted with `hemtt utils paa convert`.
`tools/art/gen_framework_art.py` retargeted from the stray `d:\Git\ghost`
path to DIVINER and the new logo, and re-run: the framework mission's
`framework_loadscreen.paa` and `framework_overview.paa` regenerated with the
new mark (masters in `art/`).

**Checked:** `hemtt check` clean; the loadscreen and the square logos
eyeballed; release staged.
### The JSON reader threw on every null; and why the roster did not come from the database
**Sync:** `no` (`addons/pac`).

From the 2026-09-05 10:24 rpt, the database path worked: `service: config
ADOPTED - 7 rank(s), 9 skill(s), 25 role(s), 15 squad(s), ...`, the deck
registered, the ORBAT applied, the radio plan written. Two things to fix
and one to explain.

- **`fnc_fromJson.sqf` threw on `null`.** `_fnc_literal` was called
  `["null", nil]` and bound the value with `params ["_word", "_result"]` -
  a nil argument reads as an undefined variable, so every `null` in a
  document logged `Undefined variable in expression: _result` (5 in that
  read). The value is now chosen from the word (`true`/`false`/nil), nil
  never passed as a parameter. Paired with the `fnc_toJson.sqf` key fix the
  round trip is clean both ways.

- **Why the roster did not load from the database (not a bug).** The 16
  sample operators were seeded under `framework.Stratis` with `sync = "off"`,
  so they went to the server profile, never the database. The first boot of
  the database mission found `service: no store document yet` and seeded the
  database from the profile as it was then - one player - and from then on
  the database's store `ADOPTED - 1 player (replaces the profile copy)` at
  every boot, which is correct: the database is the source of truth once it
  has a store. To put a built roster into the database, run the database
  mission (or `sync = "service"`) while the roster is in the profile and the
  database store is still empty, or EXPORT STORE and push it with
  `pac_sync.py push-store`. Documented in the FAQ.

**Checked:** `hemtt check` clean; release staged. The malformed `framework`
store document from before the `toJson` fix was deleted from Atlas; the next
save writes a correct one.
### Radio mesh: off by default
**Sync:** `yes` - `addons/radio_mesh/initSettings.inc.sqf` (`ghostD_` -> `ghost_`), `addons/radio_mesh/README.md`.

Asked 2026-09-05: "make sure there is an on/OFF in cba with off being the
default". The CBA server setting `ghostD_radio_mesh_enabled` ("Enable mesh
relaying", Ghosts of Battle > Radio Mesh) existed and defaulted to on; it
now defaults to **off**, and the tooltip says so. Off, `fnc_signal.sqf`
still owns ACRE's custom signal function and returns ACRE's point-to-point
result scaled by the jam level, so jamming works either way. The addon
README also stops claiming the PRC-148 relays by default - the relay list
has been `ACRE_PRC152,ACRE_PRC117F` since 2026-08-28.

**Checked:** `hemtt check` clean; release staged.

### TAC//PAC admin page: enlistment and promotion dates, time in service and grade, the log on the page, the database apart from the tools
**Sync:** `no` - `addons/pac`.

From the screenshot, 2026-09-05:
- **ENLISTED and PROMOTED** rows on the player page (`ui/dialog.inc.hpp`,
  idcs 43-49): each an edit with a SET button (`fnc_panelDate.sqf` ->
  `adminSet "enlistedAt"` / `"promotedAt"`, YYYY-MM-DD checked on both
  sides). Enlisted defaults to the day the unit first saw them, promoted to
  the day the rank last changed; typing an earlier date back-dates. The
  line under them shows **time in service** (from enlisted) and **time in
  grade** (from promoted, else enlisted) as years / months / days and the
  day count (`fnc_panelFill.sqf`, through `stampMinutes`). The header shows
  the operator id. `fnc_adminSet.sqf`: `promotedAt` is now a field, logged
  as `promoted`; `enlistedAt` logged as `enlisted`. Skills, awards and
  notes moved down to fit.
- **The status block** is taller (`h 0.112`) - its saved-at line was cut
  off.
- **RECENT ACTIONS** (idcs 75-76): the empty space under a shrunken
  ORPHANS list is the log, newest first - `fnc_panelLog.sqf` from the rows
  `fnc_logRecv` holds; asked for on open and after every edit
  (`fnc_adminSet` calls `adminLog` for the caller). The ORPHANS title says
  what an orphan is.
- **The op window explained**: START OP / STOP OP, the title and the
  tooltips say what a window does, and the hint block opens with how it
  works and what ATTENDANCE TO CLIPBOARD gives.
- **DATABASE and ADMIN TOOLS apart** (idc 77): EXPORT STORE, IMPORT STORE
  (MERGE), RESTORE STORE, STRUCTURE OUT, STRUCTURE IN under DATABASE; EDIT
  STRUCTURE, MANAGE, SEED SAMPLE DATA, REMOVE SAMPLE under ADMIN TOOLS.
  Rows in that column are 0.030 high to make room.

**Checked:** `hemtt check` clean. Not run in game - the thing to look at is
the middle column fitting: the notes row ends at 0.974.

### First in-game run of the database path: the JSON writer wrote quoted keys and nulls
**Sync:** `no` (`addons/pac`); `careful` for `messaging/fnc_loadTemplates.sqf` (a warning downgraded when `ghostD_pac` is loaded - harmless to port, the class check is by name).

From the 2026-09-05 rpt of the first run against Atlas: the boot adopted
the config (7 ranks, 25 roles, 15 squads, radio plan, 18 templates
registered, ORBAT applied) and then wrote 45 `Undefined variable in
expression: _kv` errors from `fnc_toJson.sqf`, and the store document it
pushed to Atlas was `{ "\"players\"" : null, ... }`.

**Cause:** `fnc_toJson.sqf` sorted a hashmap's keys through `str`, which
wraps a string in quotes, then looked the values up by the quoted key -
nothing found, `_kv` nil, every hashmap written as quoted keys with null
values. Every JSON the mod ever wrote - EXPORT, the .rpt backup, the
service pushes, STRUCTURE OUT - had this; none had been read back in game
before today. **Fix:** the keys are used as they are (`_v get _k`), a
non-string key written as its text. The broken `framework` store document
was deleted from Atlas; the next in-game save writes a correct one.

**Also:** `messaging/fnc_loadTemplates.sqf` logs INFO rather than WARNING
for a missing `GHOSTFR_Templates` when `ghostD_pac` is loaded - on a
database mission the deck arrives with the structure a moment later.

**Not bugs, from the same rpt:** `77 player reference(s) point at structure
ids that no longer exist` came from opening a mission with no `CfgGFA_PAC`
on a profile holding the sample roster - every reference is an orphan
there, as designed. `vehicle_heliTransport does not exist` and the
`has no loadout setup` lines are the mission's logistics config.

**Checked:** `hemtt check` clean; release staged. Watch the next run's
rpt for a clean 6/6 and, in Atlas, a `framework` store document with real
fields.

### pacdb: the extension talks to MongoDB Atlas itself - a hosted server needs nothing else
**Sync:** `no` - `addons/pac`, `tools/pacdb`, docs.

Asked 2026-09-05: "how can a hosted server run that service", "this will
run on a hosted server", "the db is in mongo cloud". The pacdb service is
now optional: `tools/pacdb/extension/Extension.cs` (0.3.0) carries the
MongoDB driver (`MongoDB.Driver` 2.28.0, kept whole under NativeAOT with
`TrimmerRootAssembly` for Driver, Driver.Core, Bson and DnsClient;
`SuppressTrimAnalysisWarnings`; System.Text.Json source-generated for the
one array it writes). A `mongodb+srv://` or `mongodb://` address in the CBA
setting - renamed **Database** in `addons/pac/initSettings.inc.sqf`, the key
now "only for an http:// service" - is spoken to directly: database `ghostd`,
collection `pac`, the same document shapes the service stores (real BSON
fields, `_id` the key, `updatedAt`, the legacy `json` string still read).
An `http://` address keeps the service path. `ping` masks the password.
`fnc_boot.sqf` 3/6 and `fnc_svcConfigure.sqf` / `fnc_svcLoad.sqf` say
"database address". `tools/pacdb/README.md` rewritten around the direct
route with a quick start and the Atlas hardening that makes a broadcast
connection string harmless: a `readWrite`-on-`ghostd` user, Network Access
limited to the game server's IP. `wiki/config_pac.md` `sync`,
`wiki/TAC-PAC.md` "Where the data lives".

**Binaries:** `ghostd_pacdb_x64.dll` 28 MB, `ghostd_pacdb_x64.so` 33 MB
(glibc 2.29), both in the mod root.

**Checked:** `hemtt check` clean. The Windows build was driven through
ctypes straight at the Atlas cluster with the real connection string
(from the environment, never written down): `configure` ok, `ping` names
the masked address, `get framework.ranks` came back in chunks and parsed
to 7 ranks, `list framework.role.` returned 25 keys, a `put` / `get`
round trip on a scratch key worked and the scratch document was deleted
afterwards. The Linux build exports the same four entry points; not run
against Atlas from here.

### pacdb: the service address and key as CBA server settings
**Sync:** `no` - `addons/pac`, `tools/pacdb/extension`, docs.

Asked 2026-09-05: "that needs to be in cba, a lot of hosted servers do not
give the right to create files". New `addons/pac/initSettings.inc.sqf`
(included from `XEH_preInit.sqf`): two EDITBOX settings, global, restart
required - `ghostD_pac_serviceUrl` ("Service URL") and `ghostD_pac_serviceKey`
("Service key"), category "Ghosts of Battle > TAC//PAC service". New
`fnc_svcConfigure.sqf` (server): hands them to the extension with a new
`configure url key` verb (`Extension.cs`; answers `ok`, wins over the
environment and `pacdb.json`; `ping` now names the source); an empty URL
hands nothing over and the extension falls back to `GHOSTD_PACDB_URL` /
`GHOSTD_PACDB_KEY`, then `pacdb.json`. `fnc_boot.sqf` step 3 waits for
`CBA_settings_ready` (10 s guard), calls it and logs which source is in
use; `fnc_svcLoad.sqf`'s warning names the setting. `script_component.hpp`
records the exception to PAC's no-CBA-settings rule. Both extension
binaries rebuilt. Docs: `tools/pacdb/README.md`, `wiki/config_pac.md`,
`wiki/TAC-PAC.md`.

**Know what it means:** a CBA server setting is sent to every client, so
the key is not a secret from the unit's players - it opens the pacdb
service and nothing else. Never the database password; keep the service
reachable from the game server only.

**Checked:** `hemtt check` clean; both binaries rebuilt and the `configure`
verb driven through ctypes. Not run in game - the boot line to watch is
`3/6 service address: the CBA server setting`.

### pacdb: the extension for Windows AND Linux servers, ships in the mod; STRUCTURE IN / OUT and pac_sync.py beside it
**Sync:** `no` - `addons/pac`, `tools/pacdb`, `.hemtt/project.toml`, both missions, docs.

The day's arc, 2026-09-05: the DLL was pulled from the mod over BattlEye, a
bridge over inidbi2's files replaced it, then inidbi2 was ruled out ("no
3rd party mods", and it is Windows-only where the server is Linux), and
the decision came back to the extension ("go back to the dll, we will just
disable battleye unless you have a better idea"). What stands:

- **The extension, lower-cased `ghostd_pacdb`, for both server platforms.**
  `tools/pacdb/extension/Extension.cs`: the name is `ghostd_pacdb` (a Linux
  server looks the file up by the exact name the script gives, and Linux
  mod folders are commonly lower-cased); the config lookup is
  `GHOSTD_PACDB_URL` / `_KEY`, then `pacdb.json` in `AppContext.BaseDirectory`
  or the working directory (the server's root), then - Windows only, guarded
  by `OperatingSystem.IsWindows()` - beside the DLL; `ping` answers with the
  URL it will use, or "NOT CONFIGURED". `ghostd_pacdb.csproj` (renamed from
  `ghostD_pacdb.csproj`): `RuntimeIdentifiers win-x64;linux-x64`,
  `StripSymbols`. New `Dockerfile.linux` + `build-linux.sh` build
  `ghostd_pacdb_x64.so` (NativeAOT cannot cross-compile; Docker or a Linux
  box with the SDK, clang, zlib1g-dev). `.hemtt/project.toml` ships
  `ghostd_pacdb_x64.dll` and `ghostd_pacdb_x64.so` in the mod root;
  `.gitignore` covers both. `fnc_svcLoad.sqf` / `fnc_svcSave.sqf` call
  `"ghostd_pacdb"`; `XEH_postInit.sqf` accepts that name in the callback.
  **BattlEye:** the server process is not policed like a client and no
  client loads the file - run with it on; disable only on a `Blocked
  loading of file` line in the server .rpt.
- **The profile is always the store; the service sits on top.**
  `fnc_boot.sqf` rewritten as six steps: mission config; the profile's
  in-game edits and imports (`structureEdited`, `_settings` applied,
  `_` keys skipped, roles merged); the service (ADOPTED / PUSHED UP / NOT
  ANSWERING / off) then `fnc_structureApply` (narrates `3/6`) and orders
  cached; the store from the profile; the store from the service; saved,
  published, READY. `fnc_storeSave.sqf`: profile, then `svcSave` only when
  `ghostD_pac_svcUp`. `fnc_structurePersist.sqf`: profile and service, plus
  a `"settings"` section (`_settings` in the profile, `<unit>.settings`
  document). `fnc_publish.sqf` backend `profile` / `profile + service (pacdb)`.
  `fnc_loadStructure.sqf` drops the never-used `syncPath` / `apiUrl`.
- **Gone:** the inidbi2 file store (`fnc_fileDb/fileWrite/fileRead`,
  `ghostD_pac_fileStore`, the file branches of `storeLoad`/`storeSave`),
  the bridge (`fnc_bridgeSeed`, `fnc_bridgePoll`, `ghostD_pac_bridgeUp`,
  `service/Bridge.cs`, `IStore.Watch`, the `Bridge` config block). The
  bridge's change-note entries are removed with it.
- **STRUCTURE IN.** New `fnc_structureImport.sqf [caller, text]` (server,
  admin-checked, logged as `structure`): a `{structure, settings}` JSON
  from the clipboard is adopted (`fnc_structureAdopt`), every section
  written to `structureEdited` with `_settings`, pushed to the service when
  it is up (`svcPushStructure`), put into effect, force-saved, published.
  Admin page (`ui/dialog.inc.hpp`): the RESTORE FULL row is three buttons -
  RESTORE FULL, STRUCTURE OUT (`adminText "structure"` now includes
  `settings` and `exportedAt`, the shape IN takes) and STRUCTURE IN
  (`PAC_IDC_STRUCT_IMPORT` 74, `fnc_panelBackup.sqf` mode `structureImport`,
  asks first).
- **Tools.** New `tools/pacdb/pac_sync.py`: `pull` (every document
  assembled into the one JSON, clipboard and/or `--out`), `push-store` (the
  game's EXPORT -> the store document and its `structureEdited` -> config
  documents), `push-structure`. `push_config.py` unchanged. `run-service.cmd`
  back to the two secrets. `README.md` rewritten around the extension, the
  service, the documents and the tools.
- **Heartbeat.** `fnc_sessionTick.sqf` no longer saves (from the bridge
  work, kept): lastSeenAt is updated in memory and written by the next
  event-driven save.

**Missions:** `frameworkmongo.Stratis` `config_pac.hpp` back to
`sync = "service"` with the comment rewritten; `framework.Stratis` comment.

**Docs:** `wiki/TAC-PAC.md` "Where the data lives" and `wiki/config_pac.md`
"Config in the database instead" / `sync` rewritten.

**The Linux build, and glibc.** "most all arma servers are linux ... most
are debian based". The `.so` was built here under WSL: a first build on
Ubuntu 22.04 bound to glibc 2.34, which Debian 11 and Ubuntu 20.04 do not
have, so it was rebuilt on **Ubuntu 20.04** (WSL distro `Ubuntu-20.04`,
Microsoft's apt feed for the SDK, clang 10) and binds to **glibc 2.29** -
Debian 11 and 12, Ubuntu 20.04 onward. `Dockerfile.linux` uses the
`8.0-bullseye-slim` image (2.31) for the same reason; `build-linux.sh` and
`README.md` say so. Exports are unversioned `RVExtension*`.

**Checked:** `hemtt check` clean; `ghostd_pacdb_x64.dll` rebuilt and driven
through ctypes against the running service (version, ping with the URL,
get in chunks, list of 25 role documents); `ghostd_pacdb_x64.so` built,
loaded with ctypes under WSL (version, ping, callback); the service rebuilt
without the bridge and restarted; release staged with both binaries.

### TAC//PAC - the action log, the operator file, and a management window with an ORBAT editor
**Sync:** `no` - all of it is `addons/pac`, which `ghost` does not have.

Asked 2026-09-05 (overnight): "work on the editor and a pac management
window, and make sure there is a date for each action and a simple action
log, and that the below is in pac" - followed by an operator record in JSON
(operator_id, identity, service_status, orbat_assignment, personnel_logs).

**The action log.** New `pac/fnc_logAction.sqf [byUid, byName, type,
targetUid, detail]` (server): one dated, numbered row per admin action -
`[LOG-n, date, byUid, byName, type, targetUid, targetName, detail]` - in
`GVAR(log)` (profile key `gfa_pac_log` = `PAC_KEY_LOG`, the store document's
`log`, the inidbi2 file through it; capped at `PAC_LOG_MAX` 2000), and, when
the action was on a player, on that record under `adminActions`
`[LOG-n, type, date, byUid, byName, notes]`. Called from every door:
`fnc_adminSet.sqf` (every field, with the value in words), `fnc_adminStructure.sqf`
(`structure`), `fnc_adminOrbat.sqf` (`orbat`), `fnc_windowSet.sqf` (`window`
start/stop), `fnc_import.sqf` (`import`), `fnc_seedSample.sqf` (`sample`),
and `fnc_panelKickBan.sqf` through new `fnc_adminLogAdd.sqf` (`kick`, `ban` -
the command runs on the admin's client, the line is relayed, admin-checked).
`fnc_storeLoad/Save/Json/Adopt.sqf` and `fnc_import.sqf` carry the log (merge
appends rows not present; restore replaces). New `fnc_adminLog.sqf
[caller, filter, limit]` sends rows newest first to `fnc_logRecv.sqf`.

**The operator file.** New `pac/fnc_recordFields.sqf` is THE record table:
`name operatorId milsimName discordId enlistedAt rankId promotedAt clearance
statusId company groupId roleId reportsTo skillIds qualifications awards
excused adminActions notes loadouts updatedAt serverId`. `fnc_record.sqf`
seeds from it, giving an operator id (`fnc_operatorSeq.sqf`, `OP-10001`
onward from `meta.operatorSeq`) and the enlistment date (today); new
`fnc_recordUpgrade.sqf` backfills every older record (id, and the
enlistment date from the earliest session) after `storeLoad`, `storeAdopt`,
`import` and `seedSample`. `fnc_adminSet.sqf` gains fields `milsimName
discordId enlistedAt (YYYY-MM-DD, checked) clearance company reportsTo
excuseAdd excuseRemove`; a rank change stamps `promotedAt`; a skill granted
for the first time goes into `qualifications` `[skillId, name, date]`;
`awardAdd` takes `[id, citation]` and awards are `[id, date, by, citation]`
(`fnc_panelFill.sqf` shows the citation). Ranks gain `payGrade`
(`fnc_structFields.sqf`, labelled; `insignia` now unlabelled). New
`fnc_attendanceOf.sqf [uid]` -> `[scheduled, attended, excused, unexcused,
pct]` off closed op windows since enlistment and the sessions filed under
them (`fnc_adminGet.sqf` attaches it as `attendanceSummary` on the copy it
sends). New `fnc_operatorJson.sqf [uid]` builds the exact shape asked for
(`operator_id`, `identity{milsim_name community_handle discord_id
steam_id_64 enlistment_date}`, `service_status{current_rank
rank_abbreviation pay_grade promotion_date time_in_grade_days duty_status
app_clearance_level}`, `orbat_assignment{company platoon squad billet
reports_to_id}`, `personnel_logs{qualifications attendance awards
admin_actions}`) - platoon from the ORBAT, pay grade from the rank,
`logged_by` an admin's operator id. `fnc_adminText.sqf` kinds `operator`
(that JSON) and `orbat`.

**The management window.** New `pac/ui/manage.inc.hpp` (`GVAR(manage)`, idd
69702, idcs `PAC_IDC_MG_*` 130-158 in `ui/idcs.inc.hpp`, included from
`config.cpp`), opened by a new MANAGE button on the admin page
(`ui/dialog.inc.hpp` - EDIT STRUCTURE halved to make room; `PAC_IDC_MANAGE_OPEN`
73; painted in `fnc_panelStyle.sqf`). Sections in a combo, a filter, a
list, an ID row and six field rows, a hint, NEW / SAVE / REMOVE / EXPORT:
`fnc_manageOpen/Opened/Style/Section/Select/Fill/Save/Remove/New/Export.sqf`.
- ACTION LOG: the rows, filtered; a row's detail in the hint; export as text.
- ORBAT - SQUADS AND SLOTS / PLATOON TABS / SHARED RADIO NETS / FACTION:
  **the ORBAT editor** - new `fnc_adminOrbat.sqf [caller, kind, op, key,
  rec]` (server) edits the structure's `orbat` (squad: name, roles checked
  against the structure's roles, condition, POSITION - the SR channel
  order; platoon: id, name, callsign, net, squads; radioNet: id, net,
  squads; faction), rebuilds the live slot table (`ghostD_groups_fnc_orbatApply`,
  nobody thrown out), clears the platoon-tag cache, logs, persists
  (`structurePersist ["orbat"]` -> `<unit>.orbat`), republishes.
- OPERATOR FILES: the roster; the six person-only fields editable (SAVE
  sends only what changed through `adminSet`); the hint is the file
  (rank / pay grade / promoted / status, platoon / squad / billet,
  attendance, qualifications, skills, awards, the last eight actions);
  EXPORT puts the JSON file on the clipboard and in the .rpt.
`XEH_postInit.sqf` refreshes the window on `structureSvc` and `roster`;
`fnc_adminRecv.sqf` fills it.

**Also fixed:** `fnc_attendanceReport.sqf` subtracted two
`stampMinutes` arrays (`[minutes, dow]`) instead of their first elements -
a script error the moment the report was asked for.

**Checked:** `hemtt check` clean. Not run in game.

### Roles, the ORBAT, nets, the radio plan and ranks live in storage; the mongo mission is down to arsenals
**Sync:** `no` for `addons/pac`, `tools/pacdb`, both missions; `careful` for
`groups`, `messaging`, `players`, `tacpad_apps` - every reader below falls
back to the mission config when `ghostD_pac_structure` is absent or empty,
so the same changes port to `ghost` as "roles/ORBAT/nets through one
accessor", and the accessor's PAC branch is dead code there.

Asked 2026-09-05: "get all of the roles and groups into storage, and nets,
and radio, ranks should also all be in storage then clean up the configs".
Roles, the ORBAT, nets and the radio plan are now sections of the TAC//PAC
structure (profile / inidbi2 file / Mongo), the mod reads every one of them
through one function per kind, and `frameworkmongo.Stratis` carries none
of those files any more. `framework.Stratis` stays the full seed.

**Symptom this fixes on the way:** `pac/fnc_structureHash.sqf` assumed every
section was `{id -> record}` and would have thrown `keys` at the ORBAT's
`groups` array the first time it ran in game (the ORBAT section landed
after the last in-game run). It now walks any shape.

**Roles - the whole role is the record.**
- `groups/fnc_roleFields.sqf` (new): the mission contract, `[[field, kind]]`:
  `name description icon nets tiles traits customVariables defaultLoadout
  groupArsenal arsenalWeapons arsenalMagazines arsenalItems arsenalBackpacks`.
- `groups/fnc_roleFromConfig.sqf` (new): one `Dynamic_Roles` class as a
  record by that table. `groups/fnc_role.sqf` (new) `[class] -> record`:
  `ghostD_pac_structure >> roles >> class` when present, else the class from
  config cached in `ghostD_groups_roleCache`. `groups/fnc_roles.sqf` (new):
  all of them. PREP'd in `groups/XEH_PREP.hpp`.
- Converted to `FUNC(role)` / `getOrDefault`: `groups/fnc_fillRoleTree.sqf`
  (name, icon), `fnc_onGroupMenuTvSelectChange.sqf` (name, description,
  defaultLoadout - now guarded with `param` so a role without a loadout does
  not throw), `fnc_updateGroups.sqf` (name, twice), `fnc_roleGate.sqf`
  (name), `fnc_setupPlayer.sqf` (defaultLoadout, the four arsenal arrays -
  COPIED with `+` before `append`, the record is shared - groupArsenal,
  name, traits, customVariables). `messaging/fnc_roleNets.sqf` and
  `tacpad_apps/fnc_roleTiles.sqf` read `nets` / `tiles` off
  `ghostD_groups_fnc_roles` and decide "gated" per call (any role with a
  non-empty list; the old rule was "any role declares the array", empty or
  not) so a structure that arrives later is not stuck behind a cached
  answer; `ghostD_messaging_roleNetsGated` / `ghostD_tacpad_apps_roleTilesGated`
  only log when the answer flips.
- `pac/fnc_structFields.sqf` "roles": the three gates (labelled) plus every
  field above and `arsenalWhitelist defaultSkills slotTag` (unlabelled, ride
  along). `pac/fnc_rolesFromMission.sqf` rewritten: every class becomes a
  full record; a record the structure already holds keeps every field it
  has and only MISSING fields (and an empty `name` / `slotTag`) are filled
  from the class - storage wins, the mission seeds. `pac/fnc_loadStructure.sqf`
  reads a `CfgGFA_PAC >> roles` class only for the fields it actually
  writes (`isNull` check) so a gate-only declaration no longer blanks the
  class's nets and loadout. `pac/fnc_rolesDeclared.sqf` deleted (every role
  is stored now); `pac/fnc_seedFromUnit.sqf` reads traits/customVariables
  off the structure's role record, not the config; `pac/fnc_adminStructure.sqf`
  takes a role's name from `ghostD_groups_fnc_roleFromConfig` when empty,
  persists with the id (`[_section, _id] call FUNC(structurePersist)`).
- **Mongo: one document per role** - `<unit>.role.<class>` =
  `{section: "role", id, role: {...}}`. `pac/fnc_svcStructure.sqf` lists the
  `<unit>.role.` prefix; a `{deleted: true}` document is skipped (the
  extension has no delete verb, so an in-game REMOVE writes a tombstone);
  with no role documents at all the old `<unit>.roles` `{items}` document is
  read. `pac/fnc_svcPushStructure.sqf` pushes one per role;
  `pac/fnc_structurePersist.sqf` `[section, id]` writes one role document
  per edit, and in the profile (`sync = "off"`) `structureEdited.roles`
  keeps ONLY the roles edited in game - `pac/fnc_boot.sqf` merges those over
  the mission's rather than replacing the section.
- The group menu waits: `groups/fnc_initGroupMenu.sqf` exits into
  `ghostD_pac_fnc_whenReady` (60 s, once - `ghostD_groups_waitedForPac`)
  when pac is loaded, not ready, and this machine has no roles yet, with a
  `hintSilent`; a mission with no roles at all still opens after that.

**ORBAT - the rest of `Dynamic_Groups`.** `groups/fnc_orbat.sqf` answers
`[groups, platoons, radioNets, faction]` (two new elements; every caller
used `params` on the first two); the structure's `orbat` gains
`radioNets: [[id, net, squads[]]]` and `faction`. `groups/fnc_initGroupMenu.sqf`
takes the faction from it; `players/fnc_platoonNet.sqf` and
`messaging/fnc_platoonTags.sqf` read the rows from it instead of
`missionConfigFile` (`ghostD_messaging_platoonTagCache` is cleared by
`fnc_takeServer` and the boot). `pac/fnc_loadStructure.sqf` seeds both;
`svcStructure` / `svcPushStructure` / `structureAdopt` / `structurePersist`
carry them in `<unit>.orbat`.

**Nets - `GHOSTFR_Nets` as a section.** Structure `nets` =
`{id -> {id, name (the description), order}}`, seeded in `loadStructure`,
document `<unit>.nets`, editable in the structure editor (NETS section;
ids keep their case and may hold `.`, space, `-`; `order` is a number -
`structFields` kind `"n"`, coerced in `adminStructure`).
`messaging/fnc_netNames.sqf` (new) is THE list: structure nets by `order`,
else `GHOSTFR_Nets`, else the `namedBoxes` setting; `messaging/XEH_postInit.sqf`
and `fnc_railNets.sqf` use it. `messaging/fnc_netsApply.sqf` (new, server)
opens a mailbox for every name that has none - PAC's boot calls it after
adoption, so nets that only exist in the database get boxes.

**Radio - `config_radio.hpp` as a section.** Structure `radio` =
`{key -> value}` for every `ghostFR_radio_*` global, key = the part after
the prefix; `pac/fnc_radioKeys.sqf` (new) is the vocabulary with the "no
plan" default per key (27 keys, `srBlockSize` included).
`pac/fnc_radioFromMission.sqf` (new, server, boot step 1) snapshots the
globals a mission's `loadConfigs.sqf` set into the section when they name
channels; `pac/fnc_radioApply.sqf` (new) writes a plan back into the
globals and re-runs `ghostD_gear_fnc_setupRadios` when a channel list
changed under a programmed preset. Called at pac preInit with
`onlyMissing = true` (every global exists from then on, so a mission with
no plan never hits nil in `gear/fnc_setupRadios.sqf` or
`players/fnc_getRadioChannel.sqf`), by the boot once the structure is
final, and by `fnc_takeServer` on every client. Document `<unit>.radio`
`{section, items}`.

**Ranks.** `config_ranks.hpp` deleted from BOTH missions: the ladder is
`CfgGFA_PAC >> ranks` / `<unit>.ranks`, a man's rank is his record, the
gates are the roles' `minRank` / `requiredSkills` / `uids` (all ten were
already declared). `players/fnc_getRank.sqf` falls back to `"Private"`
when there is no `Dynamic_Ranks >> default_rank`; `Role_Access` and
`Dynamic_Ranks` are still read if a mission has them. Comments in
`initServer.sqf` / `initPlayerLocal.sqf` of both missions say so.

**Boot narration.** 1/7 now says nets and radio plan; 2/7 lists every
document kind read, says roles / nets / radio / squads on ADOPTED, and
adds lines for the radio plan written and mailboxes opened.

**`tools/pacdb/push_config.py`:** sections `roles` (one document per role,
`Dynamic_Roles` merged with `CfgGFA_PAC >> roles`), `nets`
(`config_nets.hpp`), `radio` (`config_radio.hpp` - its literals are JSON,
read by regex), `orbat` with `faction` and `radioNets`; a section whose
file the mission lacks is skipped with a note. Run against
`framework.Stratis`: 25 role documents, orbat, nets (14), radio (26 keys)
written; the legacy `framework.roles` document deleted through the
service. Atlas now holds 38 `framework.*` documents plus the store.

**Missions.**
- `frameworkmongo.Stratis`: deleted `config_roles.hpp`, `config_groups.hpp`,
  `config_nets.hpp`, `config_radio.hpp`, `config_ranks.hpp` and every role
  file under `banshee/ ghost_6/ nomad_2/ talon_3/ wraith_4/`; new
  `config/config_arsenal.hpp` includes `Common_Arsenal` and the five
  `Arsenal_*` shells (the only role config left, as asked: "arsenal
  configs can stay"); `description.ext` includes it and notes where the
  rest went; `loadConfigs.sqf` no longer runs a radio file; `config_pac.hpp`
  comment lists the documents. 40 files remain under `config/`.
- `framework.Stratis`: `config_ranks.hpp` gone and its include replaced by
  a note; header says it is the seed; `config_pac.hpp` roles comment.

**Contract changes.** `ghostD_groups_fnc_orbat` returns four elements.
Role-gated nets/tiles: "gated" now means some role lists at least one
net/tile. `ghostD_pac_fnc_structurePersist` takes `[section, id]`.
`ghostD_pac_fnc_rolesDeclared` removed. New public: `ghostD_groups_fnc_role`,
`_roles`, `_roleFields`, `_roleFromConfig`; `ghostD_messaging_fnc_netNames`,
`_netsApply`; `ghostD_pac_fnc_radioKeys`, `_radioFromMission`, `_radioApply`.

**Checked:** `hemtt check` clean (1016 sqf). Documents verified by GET
through the service (role fields, radio numbers as numbers, orbat counts).
Not run in game - the things to watch: the group menu waiting on READY on
the mongo mission, `radio plan from the structure written` in the boot
log followed by ACRE presets that match the old plan, and `nets from the
structure: N mailbox(es) opened`.

### Fewer mission files: the report deck, the tacpad schemes, ranks and admins live in Mongo
**Sync:** `no` for `pac`/`tools`/missions; `careful` for `tacpad_apps/fnc_missionSchemes.sqf`
(guarded read of `ghostD_pac_structure`).

Asked 2026-09-05: "reduce the number of files in config as much as I can ...
panel UI data to the storage, arsenal configs can stay ... welcome needs to
be per mission, other than that go with your recommendation, then clean up".

- **Report deck** `<unit>.templates` `{section, items:{id:{title, short,
  lines, options}}}` - each entry already in `ghostD_messaging_fnc_registerTemplate`'s
  argument shape. `fnc_loadStructure` converts `GHOSTFR_Templates` field for
  field the way messaging's `fnc_loadTemplates` does; new `fnc_templatesApply`
  registers every entry not yet registered - on the server in boot step 2,
  on clients in `fnc_takeServer`. A mission that still ships the deck wins
  (registered at preInit; duplicates ignored).
- **Schemes** `<unit>.schemes` `{id:{name, ground, ink, accent}}` from
  `GHOSTFR_TacpadSchemes`; `tacpad_apps/fnc_missionSchemes.sqf` reads the
  structure's when present, else the config; `takeServer` clears its cache.
- `structureAdopt` takes `templates`/`schemes` when the document has them;
  `svcStructure` reads, `svcPushStructure` pushes. `push_config.py` gains
  `templates` (from `config_messaging.hpp`) and `schemes` (`config_tacpad.hpp`).
  Pushed: 18 templates, 3 schemes -> Atlas now holds eleven `framework.*`
  documents.
- **frameworkmongo.Stratis cleaned:** `config_messaging.hpp` and
  `config_tacpad.hpp` deleted, their `description.ext` includes retired with
  a note; `config_ranks.hpp` reduced to `default_rank` + empty `Role_Access`;
  `config_admins.hpp` reduced to one fallback id (the debug console / CBA
  whitelist still read it at start). `config_welcome.hpp` stays per mission
  as asked. 66 files remain, and they are the arsenal, role, motorpool,
  cosmetics, nets, radar, sounds, skill and logistics configs.

**Checked:** `hemtt check` clean. Not run in game - the deck registering
after the boot gate is the thing to watch (compose before READY would see
no templates).

### Slot gates in PAC, roles editable, ORBAT stored, skills on the squad panel, one role set per platoon
**Sync:** `no` for `addons/pac`, `tools/pacdb`, the missions; `careful` for
`groups`, `players`, `messaging`, `tacpad_apps`, `adminpanel`, `main` - every
one of those changes is guarded on the pac functions existing (`isNil`)
except the `ARMA_RANKS` macro in `main/script_macros.hpp`, which is plain
and portable.

Asked 2026-09-05 (plan mode, then "will that work?" + four additions):
generic roles (one set per platoon); skills in storage; TL/ATL rank gates
(SGT / CPL); a pilot skill gating pilot slots; skills shown in the squad
panel; platoon/squad ORBAT in persistent storage; roles lockable to Steam
ids; all eight admins in Mongo; console-applied skills temporary.

**Gates - the data.** PAC roles gain `minRank` (a PAC rank id),
`requiredSkills[]` (skill ids) and `uids[]` (Steam ids); skills gain
`abbrev`. New `fnc_structFields [section]` is THE field table
(`[field, kind, label, hint]`): `fnc_loadStructure` builds its section
reader from it, `fnc_adminStructure` coerces and validates by it,
`fnc_structSection` shows its labelled entries. `fnc_rolesFromMission`
defaults the new fields on derived roles and fills a declared role's name
from its class.

**Gates - the door.** New `pac/fnc_canTake [unit, roleClass]` ->
`[ok, why, need]`: locked-to uids, then rank (`ARMA_RANK_INDEX` of the two
ranks' `armaRank`), then required skills, off the player's roster row; a
gate naming a rank/skill the structure lacks warns and does not lock. New
`groups/fnc_roleGate [unit, roleClass]` -> the same triple: admin grants
first, PAC when the role carries any gate (Role_Access is then NOT
consulted - the grant is the whitelist), else Role_Access as before.
`fnc_canTakeRole` is now `(_this call FUNC(roleGate)) # 0`. **Server
re-check:** `fnc_assignPlayer` bounds-checks the path, refuses a role that
is not the one the slot holds, and asks `roleGate` itself (not on respawn)
- a client that remoteExec'd it directly used to bypass the gate.
**Locked slots read as locked:** `fnc_fillRoleTree` draws `NAME  [SGT+]` /
`[PLT]` / `[LOCKED]` at 0.55 alpha, one gate answer per class per redraw;
`fnc_selectPosition` says the reason in words. Shared ladder:
`ARMA_RANKS` / `ARMA_RANK_INDEX(r)` in `main/script_macros.hpp`, used by
`roleGate`, `canTake`, `applyRank`, `adminStructure`.

**Editor.** ROLES section: id keeps its case (class name), fields MIN RANK /
REQUIRED SKILLS / LOCKED TO; **set merges over the existing record** so a
gate edit does not wipe loadout/slotTag; validation of rank and skill ids;
REMOVE puts a mission role back to defaults (`rolesFromMission` re-run).
Persistence writes **declared roles only** (`fnc_rolesDeclared`) so a
renamed mission role is never frozen in the database; boot re-merges after
the profile overlay.

**ORBAT.** Structure section `orbat` = `{groups: [[name, roles[], cond]],
platoons: [[id, name, callsign, net, squads[]]]}`, seeded from
`Dynamic_Groups`, adopted from `<unit>.orbat`, pushed with the rest.
`groups/fnc_orbat` is the one reader (database's when present, else
config) and `fnc_platoons`, `fnc_setupPlayer`, `messaging/fnc_squadNets`,
`players/fnc_getRadioChannel` use it; `groups/fnc_orbatApply` rebuilds
`YMF_dynamicGroups` from it at boot step 2 (keeping anyone seated by name
+ slot) and broadcasts. Not moved: `messaging/fnc_platoonTags`,
`players/fnc_platoonNet` still read the config Platoons (nets are radio
plan; renaming squads in the database needs the mission too - noted). No
editor for ORBAT: edit the document.

**Squad panel.** `tacpad_apps/fnc_appSquad`: SKILLS column between ROLE and
STATUS from the roster (`abbrev`, else the id in capitals), built once per
redraw; columns re-fractioned; ACE geometry by column index.

**Console skills are session-only.** `adminpanel/playerinfo/fn_applySkills`
writes `ghostD_pac_tempEffects` on the unit and calls new
`pac/fnc_applyTemp`; `fnc_applySkills` applies PAC's set then the temp
list (effect switch factored into `_fnc_effect`); cleared at
`EntityRespawned`. Notify says so.

**Missions (both framework.Stratis and frameworkmongo.Stratis):**
`talon_3/config_pilot_lead.hpp` gone, TALON 3-1 uses `pilotTalon`;
`wraith_4-2/` gone, `wraith_4-1/` -> `wraith_4/`, classes `*Wraith41` ->
`*Wraith`, `Arsenal_Wraith41` -> `Arsenal_Wraith`; `config_roles.hpp`,
`config_groups.hpp` (rows 4-1/4-2 both `*Wraith`; arsenal include),
`config_motorpool_common.hpp`, `config_ranks.hpp` (Role_Access
`teamleadWraith` / `atlWraith`, duplicates removed) updated; row order
untouched (SR channels). framework.Stratis `config_pac.hpp`: skills with
`abbrev` + `pilot` (`trait:isPilot`, PLT); roles gates - coC2/teamleadBanshee/
tcNomad/teamleadWraith `sergeant`, xoC2/atlBanshee/driverNomad/copilotTalon/
atlWraith `corporal`, pilotTalon `requiredSkills = pilot`. Records still
naming `pilotTalonLead` / `*Wraith42` show as orphans in the panel.

**Mongo.** `framework.admins` now all eight ids. New `tools/pacdb/push_config.py`
(repo, env-configured) pushes sections from a mission config; run for
skills, roles, orbat.

**Checked:** `hemtt check` clean (1007 sqf). Not run in game.

### pacdb: no connection information in the mod or the repo
**Sync:** `no` - `tools/pacdb` and docs only (the DLL rebuilt).

Asked 2026-09-05: "you have the connection information to our db, I
prefer it not be in code" / "do not add it to the mod, I'll manually add it
to the server". So no CBA setting either (a CBA setting is broadcast to
every client, which is the wrong place for a key).

- Extension `Configure()`: `GHOSTD_PACDB_URL` + `GHOSTD_PACDB_KEY` from the
  environment first; `pacdb.json` beside the DLL only as the fallback (a
  key from the environment still wins over one in the file). Error text
  says so. Rebuilt; proven with the DLL alone in a temp folder and only the
  environment set: `list` and `get framework.admins` answered.
- Service: `run-service.cmd` maps `GHOSTD_MONGO` -> `Mongo__ConnectionString`
  and `GHOSTD_PACDB_KEY` -> `ApiKey` (ASP.NET reads env vars natively);
  refuses to start without `GHOSTD_MONGO`.
- Removed: `tools/pacdb/service/appsettings.Local.json` (and its copy in
  `out/`), `pacdb.json` at the repo root and in `.hemttout/release`. The
  committed `appsettings.json` holds placeholders only.
- This box: the three variables set at User scope so testing continues;
  the service restarted on them.

### TAC//PAC - structure editable in game; admin list in Mongo; documents as real fields
**Sync:** `no` for `pac`/`tools`; `careful` for the one guarded block in
`adminpanel/functions/fnc_isAdmin.sqf`.

Asked 2026-09-05: "in pac some data needs to be editable, data like the
rank structure; admin id now needs to be stored in mongo"; "via the mongo
site I need the top table to be a list of admin steam ids".

- **Editor.** New dialog `ghostD_pac_structure` (idd 69701,
  `ui/structure.inc.hpp`, idcs `PAC_IDC_ST_*` in `idcs.inc.hpp`), opened
  by the roster page's new EDIT STRUCTURE button (`PAC_IDC_STRUCT_OPEN`
  72). Section combo (RANKS, SKILLS, AWARDS, STATUSES, ADMINS), item list,
  ID/NAME plus up to three section fields whose labels swap per section
  (`structSection` holds the field table), NEW / ADD ME / SAVE / REMOVE
  (asks). Functions `structOpen/Opened/Section/Select/Save/Remove/New/Me/Style`.
- **Server door** `fnc_adminStructure [caller, section, "set"|"remove",
  id, record]` - admin re-checked; ids are class names (`[a-z0-9_]`), Steam
  ids for admins; ranks' `armaRank` validated; an admin cannot remove
  themself. Then `fnc_structurePersist [section]`: the section's own
  document to the service when `svcUp`; always into
  `GVAR(structureEdited)` -> profile key `gfa_pac_structure`
  (`PAC_KEY_STRUCTURE`) and the export; hash recomputed; `storeSave`,
  `publish`, `structureSvc` republished (editor and roster combos refresh
  on the PV event). Boot step 2 applies `gfa_pac_structure` over the
  mission config when there is no database - so an edit outlives a
  restart on `sync = "off"` too.
- **Admins.** A structure section `admins` (`{uid: {name, addedBy,
  addedAt}}`); `fnc_loadStructure` reads a `class admins` from a mission
  too. `ghostD_adminpanel_fnc_isAdmin` passes any uid in
  `ghostD_pac_structure >> admins` (after `everyoneAdmin`, before the
  mission list). On the site the document `<unit>.admins` is a plain
  **`ids` array** of Steam ids - `svcStructure` unions `ids` into the map
  (unnamed), `structurePersist`/`svcPushStructure` write both.
  `framework.admins` created with YonV's id (`76561198000002705`); it sorts
  to the top of the collection.
- **Service stores real BSON fields** (`MongoStore.Put` parses the JSON,
  `Get` serialises relaxed extended JSON, `_id`/`updatedAt` stripped;
  documents written before as a `json` string still read). The seven
  documents re-pushed as fields, so the Atlas site edits them as documents.

**Checked:** `hemtt check` clean (1000 sqf); service round trip of a
fields document verified. Not yet run inside Arma.

### TAC//PAC - one Mongo document per config file, so others can edit them
**Sync:** `no` - `addons/pac` + `tools/pacdb`.

Asked 2026-09-05: "can you do a document per config file ... that way
others can edit it; and this [the store] is just their persistent data".

- Documents: `<unit>.settings` / `.ranks` / `.skills` / `.awards` /
  `.statuses` / `.roles` as `{section, items, exportedAt, from}` and one per
  order `<unit>.opord.<id>` as `{section:"opord", id, order}`. The single
  `<unit>.structure` blob is gone (deleted from Atlas along with
  `selftest`). The store `<unit>` stays ONE document - it is runtime
  persistence, not something anyone edits.
- Service: `GET /pac?prefix=` lists keys; `DELETE /pac/{unit}`. Both
  stores (Mongo, file) implement `List`/`Delete`. Extension: `list` verb ->
  callback `list` with the JSON array (`list.error` on failure).
- Mod: `fnc_svcLoad [key, verb]` (verb "get" | "list"); `fnc_svcStructure`
  reads the six section documents, lists `<unit>.opord.` and reads every
  order, assembles the document `structureAdopt` takes (missing section =
  empty; nothing at all = "empty"); `fnc_svcPushStructure` writes the
  mission's config as those documents when the database has none. Boot
  step 2 uses both; the callback handler learns `list` / `list.error`.
- Atlas now holds: `framework.settings`, `.ranks`, `.skills`, `.awards`,
  `.statuses`, `.roles`, `framework.opord.op_ironveil` (pushed from
  `framework.Stratis`'s full config by `push_v2.py`); the store document
  `framework` appears at the first boot.
- Service and extension rebuilt and reinstalled (repo root + release).

**Checked:** `hemtt check` clean; service `/pac?prefix=framework` lists the
documents. Not yet run inside Arma.

### TAC//PAC - the whole config lives in Mongo; the boot narrates itself
**Sync:** `no` - `addons/pac` (+ the mongo mission, wiki, tools).

Asked 2026-09-05: "remove the config files from the mongo mission as needed
and move them to mongo", "if all of the config could be moved", "add a boot
up sequence to the logs or to the console so the process can be seen".

**Structure document.** The service holds a second document per unit,
`<unitId>.structure`: `{structure: {ranks, skills, awards, statuses,
roles, opords}, settings: {...}, exportedAt, from}` - the same shapes
`fnc_loadStructure` compiles. `fnc_structureAdopt [doc]` (server) makes it
THE structure, overrides every setting **except `unitId`, `serverId`,
`sync`** (a database cannot tell a server which server it is or where to
look), re-merges Dynamic_Roles (`fnc_rolesFromMission`, now shared by the
config path and this one) and recomputes the hash. `fnc_svcLoad` /
`fnc_svcSave` take a document key.

**Precedence and seeding.** The database wins when it has a structure
document. A mission that still carries the sections pushes them up only
when the database has none (boot step 2). So: boot once with the full
config, then strip it - or, as done today, push from outside: the
scratch script `push_structure.py` parsed `frameworkmongo.Stratis`'s
`config_pac.hpp` (+ opords) into the loader's shape and PUT
`framework.structure` through the running service (7 ranks, 8 skills, 2
awards, 3 statuses, 0 declared roles, 1 OPORD, 5 settings; read back and
verified). **`frameworkmongo.Stratis/config/config_pac.hpp` is now three
lines - `unitId`, `serverId`, `sync = "service"` - and its `opords/` folder
is gone.** `framework.Stratis` is untouched (`sync = "off"`, full config).

**Clients.** The server publishes `GVAR(structureSvc)` and
`GVAR(settingsSvc)` once after boot (JIP gets them with the mission);
`fnc_takeServer` (from `XEH_postInit` on clients) takes them over what their own mission config
compiled (keeping their three bootstrap settings), now and on the PV event.
A client on the stripped mission therefore has exactly what the server has.

**Boot sequence, visible.** `fnc_boot` rewritten to narrate seven steps
through new `fnc_bootLog [step, text]`: `diag_log` (`[TAC//PAC BOOT 3/7]
...`, live on a dedicated console), `systemChat` when the server has a
screen (hosted / editor), and `GVAR(bootLog)` published. Steps: 1 structure
from mission, 2 structure from service (adopted / pushed / off / not
answering), 3 store from local copies, 4 store from service, 5 orders
cached, 6 saved to every backend, 7 published + READY.

**Checked:** `hemtt check` clean; the structure document round-tripped
through the service from Atlas. Not yet run inside Arma.

### pacdb: MongoDB Atlas proven end to end; extension finds its own folder; DLL ships with releases
**Sync:** `careful` - `.hemtt/project.toml` gains `ghostD_pacdb_x64.dll` in
`[files] include`; `ghost` has no pacdb, so do not port that line.

- 2026-09-05: "I cannot connect to Mongo" - nothing was running or built
  yet. From this machine the Atlas SRV record resolves and all three hosts
  take TLS on 27017. .NET 8 SDK installed (winget); `pacdb-service`
  published and run against the cluster: `/health` -> `ok mongo`,
  `PUT /pac/selftest` -> 204, `GET` returns the document. **The database
  link works.** A `selftest` document is left in `ghostd.pac`.
- Secrets: `tools/pacdb/service/appsettings.Local.json` (git-ignored, loaded
  on top of `appsettings.json` by `Program.cs`) holds the Atlas string;
  `.gitignore` also covers `pacdb.json`, `tools/pacdb/**/bin|obj|out`,
  `service/data/`. The database password was pasted in chat - rotate it.
- `Extension.cs`: `pacdb.json` is looked for beside the DLL first
  (`GetModuleFileNameW` on `ghostD_pacdb_x64.dll`) and only then in
  `AppContext.BaseDirectory`, which for a native library is the game's
  folder, not the mod's.
- `.hemtt/project.toml`: `ghostD_pacdb_x64.dll` included, so a release
  carries the extension.
- **Extension built** (VC++ build tools via winget; NativeAOT publish from
  PowerShell with `C:\Program Files (x86)\Microsoft Visual Studio\Installer`
  on PATH - the ILCompiler targets shell out to `vswhere.exe` and fail with
  "exited with code 123" without it). Two C# fixes on the way: `unsafe` was
  on the whole class and C# forbids `await` in an unsafe context - now
  confined to the four pointer-touching members (`Cb.Ptr` nested class holds
  the function pointer); the `GetModuleFileNameW` extern needed `unsafe`.
  `using System.Runtime.CompilerServices` for `CallConvStdcall`.
- **Proven outside Arma** (python ctypes, DLL + pacdb.json in a temp dir):
  exports `RVExtension`, `RVExtensionArgs`, `RVExtensionRegisterCallback`,
  `RVExtensionVersion`; `ping` -> `ok 0.1.0`; `get selftest` ->
  `get.begin 1`, `get.chunk 0|{...}`, `get.end ok` through the running
  service from Atlas. **Not yet run inside Arma.**
- `hemtt release` 0.1.0.994 staged with the DLL; `pacdb.json` copied into
  `.hemttout/release` by hand (never shipped). Mission `config_pac.hpp`:
  `sync = "service";`. `tools/pacdb/run-service.cmd` starts the service.

### TAC//PAC - MongoDB behind a service, as a third backend
**Sync:** `no` - `addons/pac` + new `tools/pacdb` (not part of the mod build).

Asked 2026-09-05: "how about tying it to a mongo db" / "or RethinkDB" /
"I would prefer an option to do either" - then "mongo it is": the RethinkDB
provider and its package were removed the same day, Mongo is the service's
default, `Store = "file"` stays for testing the pipe, and
`tools/pacdb/docker-compose.yml` + `Dockerfile` stand up Mongo and the
service together.

**Shape.** The game never links a driver. `Arma -> ghostD_pacdb.dll
(NativeAOT C#, tools/pacdb/extension) -> HTTP -> pacdb-service (ASP.NET
minimal API, tools/pacdb/service) -> MongoDB` (or files, for testing). One JSON
document per `unitId` - the panel's EXPORT format, whole - so backups,
diffs, restores and the mod's own import/merge all keep working. The
extension is dumb: `get unit`, chunked `put`, answered asynchronously
through `ExtensionCallback` so no server frame waits on a network.
Protocol and build steps in `tools/pacdb/README.md`.

**Mod side:**
- `fnc_boot` - the server boot in one place, spawned from `XEH_postInit`:
  profile + file (`storeLoad`) -> service (`svcLoad`, waited for up to
  `PAC_SVC_TIMEOUT` = 20 s) -> cache orders -> `storeSave` (creates the
  document the first time) -> `publish` -> `GVAR(ready)`.
- `fnc_svcLoad` - `"ghostD_pacdb" callExtension ["get", [unitId]]`, then
  waits on `GVAR(svcState)`; the `ExtensionCallback` handler in
  `XEH_postInit` assembles `get.begin/get.chunk/get.end` into
  `GVAR(svcChunks)`. Timeout, refusal or error -> `"error"` and the local
  copy stands. `fnc_svcSave` - chunked `put.begin/put.chunk/put.end` on
  every real save (7000-char chunks). Both no-ops unless `sync = "service"`.
- `fnc_storeAdopt [doc]` - used by the file path and the service path: the
  document REPLACES the store (first cut merged and kept local extras -
  which would resurrect a player deleted on another server; a connected
  player's session is re-opened by the heartbeat, his record re-seeded at
  spawn). Wrong shapes refused whole. **Precedence:** with `sync =
  "service"` and an answer, Mongo is the store; local copies are still
  written on every save and only read when the service does not answer or
  has no document yet (which is how a local store migrates in).
- `GVAR(svcUp)`; summary `backend` reads `service (pacdb)` when it is.
- Settings: `sync = "off" | "service"` (the key existed, unused).

**Not compiled here** - the machine has the .NET runtime but no SDK and no
C++ build tools; the two .NET projects are source with build instructions.
Nothing run against a database. The mod side is lint-clean and degrades
to the local copy on any failure.

**Checked:** `hemtt check` clean.

### TAC//PAC - the store as a file (inidbi2), profile as fallback; lost-store guard
**Sync:** `no` - `addons/pac` only.

Asked 2026-09-05: "can we save the db to a file in the Arma file
structure". Script cannot write a file; the door is the inidbi2 extension
(code34, workshop "@INIDBI2 - Official extension", already in the user's
workshop folder), which writes .ini files under `<Arma root>\@inidbi2\db\`.
Windows DLL only; the server is the only caller.

- `fnc_fileDb [name]` - the `OO_INIDBI` object per file, cached; nil without
  the extension. `fnc_fileWrite [db, section, text]` / `fnc_fileRead` -
  text as numbered chunks `n`, `c0..cN`. **Shaped by the wrapper's rules:**
  it puts a STRING between bare quotes and `compile`s the line on read, so
  every quote is doubled going in; its separator is `|`, so pipes go in as
  the JSON escape `|`; each chunk wears `~` guards against .ini
  trimming/comment rules; chunks are 4000 chars under the 10240 return
  buffer. Stale chunks above the new count are deleted.
- `storeSave`: after the profile write, when `GVAR(fileStore)`, the same
  JSON as EXPORT goes to `gfa_pac.ini` section `store`; a **forced** save
  also writes `gfa_pac_backup_YYYYMMDD.ini` (one per day). `meta.players`
  records the count at save.
- `storeLoad`: `GVAR(fileStore) = !isNil "OO_INIDBI"`; if the file reads
  and parses with the right shapes it REPLACES the profile copy (players,
  sessions, windows, opords); wrong shape / bad JSON -> warning, profile
  copy stands; no file yet -> profile copy, info.
- **Lost-store guard:** `meta.players > 0` at last save and no players on
  this load -> `GVAR(readOnly) = true` with a WARNING naming the count. The
  page's status line says READ-ONLY and points at the .rpt. Restore via
  RESTORE FULL (clipboard) from a backup file or the .rpt dump; the guard
  does not clear itself.
- Summary gains `backend`; status line shows `store read-write (file
  (inidbi2))` or `(profile)`.

**Multi-server:** with `@inidbi2\db` junctioned into a Dropbox/Drive
folder this file follows the sync client; still one writer at a time. Per-
server files + merge is the next step, not done.

**Boot gate (asked the same day):** `GVAR(ready)` false in preInit; the
server sets it true and `publicVariable`s `ghostD_pac_ready` after load,
cache and first publish. `applyOnClient` and the client's spawn wait check
it instead of "roster variable exists". New public
`ghostD_pac_fnc_whenReady [code, timeout]` runs code now if ready, else when
the flag comes up - the one line a mission's slotting/boot script needs.
Summary carries `ready`.

**Checked:** `hemtt check` clean. Not run in game; the quote-doubling
round trip through inidbi2 is the thing to prove first (SEED, restart, look
for "file store: read gfa_pac.ini").

### PAC is the source of truth for skills; roles stop applying them
**Sync:** `careful` - `groups/fnc_setupPlayer.sqf` changes (guarded, inert
without pac); the rest is `addons/pac` (`no`).

Asked 2026-09-05: "make the pac the source of truth for skills, remove it
from the roles".

- **What a role still does.** Role `traits[]` and `customVariables[]`
  carry more than skills: tacpad tile access (`weather`, `drones`, ...),
  platoon nets (`BANSHEE`, `WRAITH`), DRA access flags. So the cut is by
  name, not by block: new `ghostD_pac_fnc_managedNames` returns every trait
  and variable name any structure skill can set (Medic/Engineer/
  ExplosiveSpecialist + their ACE variables, plus every `trait:X` / `var:X`
  in the skills' effects). `fnc_setupPlayer` skips those names in both
  arrays and applies everything else as before; PAC's `applySkills` (the
  existing hook at the end of role setup) puts the skills on. A unit that
  adds a skill has, by that, taken its names away from the roles.
- **Migration, once.** `seedFromUnit` reads the slot's `traits[]` /
  `customVariables[]` from `Dynamic_Roles` and grants every structure skill
  whose effects the role satisfied (medic:N <- Medic, eod:N <- ExplosiveSpecialist
  / ace_isEOD, trait:X <- X true ...), then sets `skillsSeeded = true` on
  the record so an admin who later clears a man is not overruled at his
  next spawn. Symptom without it: switch-on day, every player arrives with
  no medic, no leader flag, no METT-TC gate.
- **`skillSource` removed** - there is one source now. Gone from
  `loadStructure` defaults, `applyOnClient` (always applies), the panel hint,
  the framework sample, wiki `config_pac.md` / `TAC-PAC.md`.

**Known second writer, unchanged:** the admin console's PLAYER SKILLS block
(`adminpanel/playerinfo/fn_applySkills`) still sets ACE classes and flags
directly on the unit; PAC overwrites them at the next publish or spawn.
Should be pointed at PAC or removed - not done here.

**Checked:** `hemtt check` clean. Not run in game.

### TAC//PAC admin page: group drives role; status block; window row
**Sync:** `no` - `addons/pac` only. From the 2026-09-05 screenshot.

- **GROUP above ROLE, and the role list is the group's.** GROUP is now a
  combo (`PAC_IDC_GROUP_COMBO` 42) filled from `YMF_dynamicGroups` names
  plus any group a roster row already names; the free-text edit + SET and
  `fnc_panelGroup` are gone (idcs 29/30 removed). New
  `fnc_panelRoleCombo [group, roleId]` fills ROLE with that group's slots
  (`YMF_dynamicGroups` row `roles[]`, each a Dynamic_Roles class = PAC role
  id), once each, plus the record's own role if the group lacks it; no group
  = every role. Symptom before: "Assistant Team Lead" three times, once per
  squad. `panelCombo` handles `groupId` and re-lists roles on a group
  change; `panelFill` selects the group and calls `panelRoleCombo`.
- **Status block:** the structure hash printed `1.49878e+07` - now
  `toFixed 0`, labelled "structure hash"; new `saved <stamp>` line from
  `summary.savedAt`, set in `storeSave` after `saveProfileNamespace` -
  persistence made visible.
- **OP WINDOW row:** name edit + START + STOP on one line; ATTENDANCE TO
  CLIPBOARD full width beneath.
- **Seed:** `seedFromUnit` takes a 4th arg, `groupId group player`, and
  fills an empty `groupId` with the squad's name, so the roster's group and
  the role filter line up on first sight.

**Persistence, answered:** it is the server `profileNamespace` +
`saveProfileNamespace` (debounced 30 s, forced at mission end / window
stop / import); survives restarts on the same writable profile
(`-profiles=` on a dedicated box). Cross-server is phase 2 (sync), not built.

**Checked:** `hemtt check` clean. Not run in game.

### TAC//PAC - order number on the OPORD; OPORDs cached in the profile
**Sync:** `no` - `addons/pac` (+ mission sample, wiki).

Asked 2026-09-04: "add an opord id to the opord, and cache the opord in
profile after load".

- **Order number:** `header.id` (text, e.g. `GHOST-ORD-01`) added to the
  OPORD header in `fnc_loadStructure`. Shown in the app's list (right
  column with the date), in the open order's headline (`GHOST-ORD-01  -
  DATED 2035-07-12`), and in the C2 post's Header.A. The class name stays
  the machine id that `currentOpord`, sessions and METT-TC tags carry.
- **Cache:** new store key `gfa_pac_opords` (`PAC_KEY_OPORDS`) ->
  `GVAR(opordArchive)` {classId -> compiled order + `archivedAt`}. Read in
  `storeLoad`, written in `storeSave`, filled in server `XEH_postInit`
  right after `storeLoad` from every order the mission compiled (mission
  copy wins), saved, and **publicVariable'd in `publish`**. The app's OPORD
  view lists the mission's orders plus every cached one the mission no
  longer carries (dimmed), and opens either. `windowName` resolves
  `opord:<id>` from the archive when the structure no longer has it. Export
  carries `opords`; import merges missing ids (restore replaces).
- Framework sample `op_ironveil.hpp` gets `id = "GHOST-ORD-01"`; wiki
  `config_pac.md` updated (header sample, cache paragraph).

**Checked:** `hemtt check` clean. Not run in game.

### TAC//PAC - every Dynamic_Roles role is a PAC role
**Sync:** `no` - `addons/pac` only (+ mission sample, wiki).

Asked 2026-09-04: "class roles needs to be all roles". Two lists that had
to agree by hand did not. `fnc_loadStructure` now merges every class under
`missionConfigFile >> "Dynamic_Roles"` into `structure.roles` after the
CfgGFA_PAC section is read: id = class name, `name` from the role's `name`,
`slotTag` = class, empty skills/loadout/whitelist. A role the mission
declared in `CfgGFA_PAC >> roles` with the same class name wins (that is
how a maker adds a whitelist or default skills); a declared role with an
empty `slotTag` whose class is a Dynamic_Roles class gets the class as its
slot. The framework mission's sample `class roles {}` is now empty with the
enrichment example in a comment; wiki `config_pac.md` roles section
rewritten. Effects: the roster's ROLE column, `seedFromUnit` and auto-slot
all line up with the group menu without configuration. The structure hash
now includes the derived roles - same on every server running the same
mission, which is the point of it.

**Checked:** `hemtt check` clean. Not run in game.

### OPORD includes: back to one literal line per order
**Sync:** `no` (mission + wiki only).

2026-09-05 .rpt: `Preprocessor failed on file description.ext - error 2
(source config\config_pac.hpp, line 95)` - the line was
`#include PAC_STR(PAC_OPORD_FILE(CURRENT_OPORD))`. **The engine's
preprocessor does not expand macros inside `#include`**; HEMTT's does, so
the mod build never saw it. The chain of attempts, for the record: folder
glob (impossible - no directory read), thirty `__has_include` slots
(rejected: numbering in disguise), macro include off a define (engine
refuses). Final: `currentOpord = "op_ironveil";` as a plain string and
`class opords { #include "opords\op_ironveil.hpp" }` - one literal include
per order, which is the floor. The order cache in the profile (previous
entry) is what makes that bearable: an include can be dropped when the
order is over and the app still lists it. Macros `CURRENT_OPORD`,
`PAC_STR_`, `PAC_STR`, `PAC_OPORD_FILE` removed. Wiki updated.

### TAC//PAC - sample data (SEED SAMPLE / REMOVE SAMPLE)
**Sync:** `no` - `addons/pac` only.

Asked 2026-09-04: "fill the pac with some sample records with made up names".

- `fnc_seedSample [caller, "add"|"remove"]` (server, admin-checked). Sixteen
  fictional players (Marcus Hale, Priya Venkataraman, ...) across GHOST 6,
  BANSHEE, NOMAD, TALON and WRAITH; ranks, roles, skills, awards and
  statuses are **picked by index from whatever the mission's structure
  declares**, so it fits any `CfgGFA_PAC` and never invents an id. Notes
  and awards are stamped "Sample". A closed manual op window `wsample`
  ("Sample op night", eight days ago) with sessions under it so the
  attendance report has a window. Fixed UIDs `9000000000000001..016`
  (outside Steam's range), `serverId = "sample"` on every record - a second
  SEED overwrites, REMOVE deletes exactly those records, their sessions
  (by window id) and the window. Forced save + publish.
- `fnc_panelSample [mode]` - the two buttons on the page's right rail at
  y 0.904 (idcs 70, 71); REMOVE confirms via `BIS_fnc_guiMessage`.
- Wiki `TAC-PAC.md` backup table gains the row.

**Checked:** `hemtt check` clean. Not run in game.

### First in-game pass on TAC//PAC and the suite: seven screenshots' worth of fixes
**Sync:** mixed, per item below. Reported 2026-09-04 with screenshots.

**Reader cards were unreadable** (`yes`). `addons/tacpad/functions/fnc_readerThreadView.sqf`:
the template card gave every line one row, so an OPORD section (paragraphs)
ran over the rows under it. Now each answer is drawn, `ctrlTextHeight` is
measured, the row grows to fit, and the frame is drawn last at the final
height. Same for the per-message body rows. A `grid` field holding a
position (from the map picker) is shown as `mapGridPosition`, not the raw
array - symptom: LOCATION read `[2094.41,5708.61,0.001]`.

**METT-TC subject was the whole mission** (`no`, pac). `fnc_registerTemplates`:
a CALL SIGN line (autoFill ownCallsign) leads and the subject is
`METT-TC {Callsign.A}`. Field keys shift: Mission.A etc. unchanged, new
`Callsign.A`.

**Hover / focus / selection showed the wrong scheme** (`yes`). Those three
colours are config-only; the placeholders were the dark scheme's red accent
(or the light scheme's greys), so a blue-scheme button went red on hover
and the console's player row selected red. Replaced everywhere with a
mid-grey wash that reads on any scheme: `colorBackgroundActive
{0.5,0.5,0.5,0.30}`, `colorFocused {..,0.16}`, `colorSelectBackground[2]
{..,0.35}` in `adminpanel/ui/controls.inc.hpp`, `vehicle/gui.hpp`,
`groups/gui.hpp` (real buttons only; the transparent hit classes untouched);
adminpanel `colorActive` placeholders -> white. Tacpad's own buttons had no
hover at all: `tacpad/gui.hpp` `class GVAR(hit)` gets
`colorBackgroundActive {0.5,0.5,0.5,0.22}` - one line, every tile, rail
button and app control in the suite.

**Console RUN was red** (`yes`): `adminpanel/functions/fnc_style.sqf` paints
`IDC_ADMINPANEL_REMOTEEXEC_EXECBUTTON` with the loud (accent + ground) set
like APPLY and HEAL FULL. The TAC//PAC button is labelled **PAC ROSTER** so
an admin can tell what it opens (`ui/dialog.inc.hpp`).

**PAC roster was blank for a man with a slot** (`no`, pac). New
`fnc_seedFromUnit [unit, armaRank, slot]` (server): fills an EMPTY rankId
from the first structure rank mapping to the unit's Arma rank, and an EMPTY
roleId from the structure role whose `slotTag` is the Dynamic_Roles slot;
then publishes. Sent from `applyOnClient` on spawn with `rank player` and
`YMF_role` (rank is local where setRank ran). Never overwrites an admin's
value. Skills stay empty, per DECIDED.

**PAC app** (`no`): RECORD tab is **MY RECORD**; the OPORD date is
`DATED yyyy-mm-dd` at 0.95 bold. "Could not click back to it" was not
reproducible from the code - the tab hits sit above the OPORD view's BACK
row and do not overlap; to be watched.

**Live tiles** (`careful` - tile list differs): weather tile chip no longer
the clock (there is one top right); it shows DRY / RAIN. MAP TOOLS header
button is **CANCEL** (it stops the running tool; `panelTools.sqf` accepts
both labels).

**Loadout filter script error** (`yes`):
`addons/systems/functions/fnc_filterUnitLoadout.sqf` - "2 elements
provided, 10 expected" at `_baseLoadout#9#2` every role setup without
ACEAX. `CBA_fnc_getLoadout` always returns `[loadout, extended]`; the code
only unwrapped it when the ACEAX flag was set. Now unwrapped by shape
(two elements, first a ten-element loadout), flag or no flag.

**Checked:** `hemtt check` clean. Not yet re-run in game.

### Drone swarm module: the Airframe attribute inherited a Cfg3DEN control from inside CfgVehicles
**Sync:** `yes` if `ghost` ever takes the swarm module (it does not have it today);
the rule applies to every module that uses the class picker.

**Symptom (2026-09-04 .rpt):** hundreds of `No entry
'bin\config.bin/CfgVehicles/ghost_ClassPick_Uav_Single.scope'` / `.side` /
`.model` / `.simulation` ... warnings on game start and at the CBA 3DEN
item-list preload.

**Cause:** `addons/uas/CfgVehicles.hpp` forward-declared
`class ghost_ClassPick_Uav_Single;` *inside* `class CfgVehicles` so that
`class swarmClass: ghost_ClassPick_Uav_Single {...}` could inherit it. That
declaration IS an empty vehicle class of that name, and the engine then
reads it as a vehicle. The picker is a `Cfg3DEN` control; an attribute
names it, it does not inherit it.

**Fix:** declaration removed; `swarmClass` is now `class swarmClass: Edit`
with `control = "ghost_ClassPick_Uav_Single";` and `defaultValue = "''"` -
the idiom `addons/ambience/CfgVehicles.hpp` already uses for
`droneClasses` (`control = "ghost_ClassPick_Uav"`). Comment left at the top
of the file saying why.

**Checked:** `hemtt check` clean; grep confirms no other
`class ghost_ClassPick_*` outside `main/CfgEdenDrone.hpp`. Not yet re-run
in game - the warnings should be gone on the next start.

### METT-TC is a leader's: notice on taking a leader slot, gate on send; everyone-admin switch
**Sync:** `careful` throughout - `messaging` and `tacpad` gain a
`senderMustBe = "leader"` value that `ghost` could take as-is (`yes`); the
`groups` hook line and the PAC function are DIVINER-only (`no`); the
everyone-admin setting is a testing switch (`careful` - port it off, or not
at all).

**Asked (2026-09-04):** "when someone takes a leader slot give them a
notice to fill in their METT-TC and go from there; only leaders can send a
METT-TC" and "for now make everyone an admin".

**The gate.** `addons/messaging/functions/fnc_srvThreadFor.sqf` -
`senderMustBe` gains `case "leader": {(_unit getVariable ["isLeader",
false]) isEqualTo true}` beside issuer/assignee/boxMember. The mission's
own flag, the one a lead role's `customVariables` sets and every tag rule
already reads - NOT `leader group`, which the group system hands to whoever
joined last. The server answers "only the leader may send that".
`addons/tacpad/functions/fnc_composePicker.sqf` filters `_ids` so a
template with `senderMustBe = "leader"` is not offered to a non-leader at
all. PAC's `fnc_registerTemplates` sets it on `mettc`.

**The notice.** `addons/pac/functions/fnc_leaderNotice.sqf [isRespawn]` -
called from **`addons/groups/functions/fnc_setupPlayer.sqf`** by a second
guarded line right after the `applyOnClient` one, with `_isRespawn`. If the
unit now carries `isLeader` and this is not a respawn: a notification
naming the current OPORD, then after the group menu closes (`!dialog`) and
the player is alive, `["", "mettc", false, "", []] call
ghostD_tacpad_fnc_composeOpen` opens the reader on a fresh METT-TC. Nothing
on respawn; nothing for anyone else.

**Everyone admin.** `addons/adminpanel/initSettings.inc.sqf` - new CBA
setting `ghostD_adminpanel_everyoneAdmin` (CHECKBOX, **default true**,
"Ghosts of Battle / Admin Console"). `functions/fnc_isAdmin.sqf` returns
true at the top when it is on, read through a default so a call before
settings init is "no". This is every door: the console, the TAC//PAC page,
and every server-side re-check behind them. **Turn it off before an op.**

**Checked:** `hemtt check` clean. Nothing run in game - the compose-open
timing against the group menu closing is the thing to watch.

### TAC//PAC - own attendance in the app, tile fix, docs, mission sample
**Sync:** `no` for `pac`/wiki; `careful` for the `tacpad_apps` tile line
(only meaningful with `pac`).

- `fnc_publish` totals every player's sessions - `[minutes, joins]`, open
  rows to `lastSeenAt` - and appends them as **roster row index 9**, so a
  client shows "time on" without ever holding the sessions. `fnc_app`
  RECORD view: a TIME ON row (`Nh Mm · K sessions`) above UPDATED; the row
  `params` gained `["_time", [0, 0]]`.
- **`addons/tacpad_apps/functions/fnc_tileData.sqf`** - the PAC tile read
  `summary.window` as a bool; it has been an id string since the attendance
  work. Now `_open = _window isEqualType "" && {_window isNotEqualTo ""}`.
  Symptom before the fix: a string where the tile's `select` wanted a bool.
- Wiki: `TAC-PAC.md` (what it is, panel, skills/ranks, slots/loadouts,
  attendance/windows, backup + how to restore from the .rpt, OPORD/METT-TC)
  and `config_pac.md` (the full `CfgGFA_PAC` reference: settings, opWindows
  shapes, effect strings, roles/slotTag/arsenalWhitelist, opords). Linked
  from `_Sidebar.md` (after Intel-Packages; after config_sounds),
  `Config-Reference.md`, `description-ext.md`, `How-Config-Loads.md`.
- **Mission (`framework.Stratis`)**: new `config/config_pac.hpp` - a
  commented sample `CfgGFA_PAC` (base Arma's seven ranks one to one, 8 skills, 2 awards, 3 statuses,
  3 roles with empty slotTags) - and its `#include` in `description.ext`
  after `config_welcome.hpp`. **OPORDs are one file each** under
  `config/opords/`, included from `class opords`; the first,
  `op_ironveil.hpp` (OPERATION IRON VEIL - made up for the framework task
  force on Stratis, base-game enemies, in the shape of the DPSO Black
  Scorpion order), is set as `currentOpord` so the C2 post, the METT-TC
  pre-fill and the app viewer have something to show. This is what makes PAC
  testable on the framework mission.

**Checked:** `hemtt check` clean, 71 configs / 970 sqf. One build failed first: the python edit that added the TIME ON row wrote a `·` through Windows' default cp1252 and HEMTT refused the file as not UTF-8 - repaired at the byte level; every file touched this session scanned clean after. Nothing run in game.

### TAC//PAC - OPORD to C2 messaging, METT-TC template (deliverable 7)
**Sync:** `no` for `addons/pac`; `careful` for the one `default` branch added
in `tacpad`'s `fnc_composeCard.sqf` (guarded on the pac addon; inert in
`ghost`).

**The server cannot post.** `ghostD_messaging_fnc_srvSubmit` refuses a
sender that is not a live player, and rightly. So the OPORD goes up through
the normal `submit` path from **the first admin to spawn, once per
mission**: `applyOnClient` asks `fnc_opordAsk [unit]` (server) on every
spawn; the server flips `GVAR(opordPosted)` and remoteExecs
`fnc_opordPost` to that admin's machine. `opordPost` builds the payload
from the current OPORD's six sections and sends `["opord", payload,
["B:C2"], "", "", ["OPORD:<id>"]] call ghostD_messaging_fnc_submit` - the
opordId as an audience tag, per the handoff. Nothing to post (no
`currentOpord`, no messaging addon, already posted) is the common case.

**Templates** `fnc_registerTemplates` (every machine, PAC postInit - after
messaging's preInit loaded the mission deck; a mission's own `opord` /
`mettc` wins):
- `opord` - Header (title, date), Situation, Mission and Execution, Admin
  and Logistics, Command and Signal, ROE; subject `OPORD {Header.A}`;
  replyable with `mettc`, `roger`, `freetext`.
- `mettc` - M/E/T/T/T/C text lines plus a LOCATION grid with
  `source = "mapClick"` (the compose card's marker/current-loc/typed
  picker - the "add marker" control). **Pre-fill from the OPORD**: M, E and
  C carry `autoFill = "pac:mission.mission"` / `"pac:situation.enemy"` /
  `"pac:situation.civilTerrain"`.
- `fnc_opordField ["section.field"]` answers those.

**`addons/tacpad/functions/fnc_composeCard.sqf`** - the autoFill switch's
`default` now resolves `"pac:section.field"` through
`ghostD_pac_fnc_opordField` when that function exists, else `""` as before.

**Not done, and why:** the handoff says "SQUAD channel" for METT-TC.
Messaging has no per-template default addressee that I could find
(`broadcast`/`routing` are different things); the sender picks addressees
in the compose UI as for any report. Recorded here so it is not mistaken
for finished.

**Checked:** `hemtt check` clean. Nothing run in game; the field keys the
template generates (`Header.A`, `Mission.A` ...) follow
`registerTemplate`'s line-title rule and were not seen rendered.

### TAC//PAC - backups, export/import, delta tool v0 (deliverables 8, 9)
**Sync:** `no` - `addons/pac` only.

**JSON, because nothing in the mod had it:** `fnc_toJson [value, indent]`
(strings/numbers/bools/arrays/hashmaps; **hashmap keys sorted** so two
exports of the same store diff clean; non-finite numbers -> null) and
`fnc_fromJson [text]` -> `[value, ok, errorPos]` (recursive descent over
`toArray` codes, never throws; objects -> hashmaps, `null` dropped).
Gotcha recorded: SQF escapes a quote by doubling it - `"\""` is a token
error; the writer uses `"\"""` and `""""`.

**Store document** `fnc_storeJson [pretty]`:
`{schemaVersion, unitId, serverId, exportedAt, players, sessions, windows}`
- the backup format and the export format are the same thing on purpose.

**Backups:** `fnc_backupDump [reason]` writes the document into the server
.rpt between `[TAC//PAC] BACKUP BEGIN ...` / `BACKUP END` markers, **in
2000-char slices, one per line** (diag_log truncates) - join the lines
between the markers to restore. Called on mission `Ended` and in
`windowSet` on stop, per the handoff.

**Export / structure dump:** `fnc_adminText` kinds `"export"` (pretty store
JSON) and `"structure"` (structure + hash JSON - the delta tool's v0: diff
two servers' dumps). Both land on the admin's clipboard and .rpt via
`textRecv`.

**Import:** `fnc_import [caller, json, "merge"|"restore"]` - server,
admin-checked. Refuses non-JSON (with the character position), a document
that is not a store, and a `schemaVersion` newer than `PAC_SCHEMA`. Merge:
per player **last writer wins by `updatedAt`** (string compare on the fixed
UTC shape); sessions/windows appended if not already present, never
merged. Restore: replaces players/sessions/windows wholesale; meta kept.
Forced save + publish; answers the admin with a notification.

**Page:** BACKUP row on the right rail - EXPORT, IMPORT (MERGE), RESTORE
FULL (confirms via `BIS_fnc_guiMessage`), STRUCTURE + HASH
(`panelBackup`; idcs 65-69; HINT shrunk to h 0.130). Import/restore read
`copyFromClipboard` on the client and send the text up.

**Checked:** `hemtt check` clean. Nothing run in game; the JSON round trip
is untested against a real store.

### TAC//PAC - auto-slot and kept loadouts (deliverable 5)
**Sync:** `no` for `addons/pac`; `careful` for the one guarded line in
`gear` (inert in `ghost`).

**Auto-slot** `fnc_autoSlot [unit]` - server. A PAC role's `slotTag` is a
`Dynamic_Roles` class name, which is what every slot in `YMF_dynamicGroups`
(`[groupName, roles[], conditions, group, units[]]`) is labelled with.
`slotMatch = "role"`: first free slot anywhere with that role; `"slot"`:
must also be in the group the record's `groupId` names. Asks
`ghostD_groups_fnc_canTakeRole` first (Role_Access still applies), then
calls `ghostD_groups_fnc_assignPlayer` server-side - the same path the
group menu takes. Skipped when `autoSlot = 0`, no roleId, no slotTag, or
the player already has `YMF_oldrole`. Asked for by `applyOnClient` on a
spawn with no role yet.

**Kept loadouts** on the record as `loadouts {roleKey -> [stamp, loadout]}`
(roleKey = PAC roleId, else the `YMF_role` slotted as):
- `fnc_loadoutSave [unit]` (client) - called from
  **`addons/gear/functions/fnc_saveLoadout.sqf`** by one guarded line after
  `SavedLoadout` is set, so the save the player already knows is the one
  that reaches PAC. Off when `savedLoadouts = 0`.
- `fnc_loadoutStore [unit, loadout]` (server) - refuses a sender that is
  not the unit's owner (`remoteExecutedOwner`); **cap by `savedLoadouts`**,
  evicting the oldest stamp; debounced save.
- `fnc_loadoutSend [unit]` (server) -> `fnc_loadoutApply [unit, loadout,
  dropped]` (client, `setUnitLoadout`). **Validated on load, per the
  handoff**: with a non-empty role `arsenalWhitelist[]`, every real class
  (CfgWeapons/Magazines/Vehicles/Glasses) not in it is blanked and the
  player told how many. Asked for by `applyOnClient` on a spawn that
  already has a role - i.e. after the groups hook, so it goes on over the
  role's default loadout.

**Checked:** `hemtt check` clean. Nothing run in game; the whitelist walk
blanks containers to `""` which `setUnitLoadout` may treat differently from
a missing container - to be seen on a screen.

### Vehicle spawner removed - the motorpool is the only vehicle-issuing screen
**Sync:** `careful`. `ghost` still carries `fnc_vehicleSpawner` and the
framework mission's `config_vehicleSpawner.hpp`; port this only if `ghost`
also drops the engineer-course pads. The function was independent of
everything else, so removing it there is the same four deletions.

**Why:** two ways to get a vehicle, with different menus and different
config, were being confused with each other. The motorpool replaced the pad
spawner; the pads' only remaining use (engineer-course wrecks) is not worth
a second system.

**`addons/vehicle`:** deleted `functions/fnc_vehicleSpawner.sqf`; removed
`PREP(vehicleSpawner);` from `XEH_PREP.hpp`; `README.md` function list;
`fnc_motorpool_init.sqf` header no longer describes coexisting with it;
`gui.hpp` comment reworded ("vehicle pool as a screen").

**Mission (`framework.Stratis`):** deleted `config/config_vehicleSpawner.hpp`
and its `#include` in `description.ext`. No `mission.sqm` init line called
the function (checked).

**Wiki:** deleted `config_vehicleSpawner.md`; removed its row from
`Config-Reference.md`, its line from `_Sidebar.md`, `description-ext.md`,
`How-Config-Loads.md`; cut "The engineer-course pads" from
`Motorpool-and-Vehicles.md`; `Home.md` row no longer says "spawner pads".

**Checked:** `hemtt check` clean; `grep -ri vehicleSpawner` over addons,
wiki and the mission returns nothing.

### TAC//PAC - attendance sessions, op windows, report (deliverable 6)
**Sync:** `no` - `addons/pac` only.

**Sessions** (`gfa_pac_sessions`, append-only rows
`[uid, name, joinedAt, lastSeenAt, leftAt, windowId]`):
- `fnc_sessionStart [uid, name]` on `PlayerConnected` (after `record`);
  closes any still-open row for that uid first (a drop the server never saw).
- `fnc_sessionEnd [uid]` on the vanilla `PlayerDisconnected` mission EH.
- `fnc_sessionTick` every `PAC_HEARTBEAT` (60 s) from a plain `spawn` loop in
  `XEH_postInit.sqf`: moves `lastSeenAt` on open rows whose player is still
  on; opens a row for anyone on with none. Crash safety per the handoff.
- Rows still open at the next mission start are closed at their
  `lastSeenAt` (postInit, before anyone can connect).

**Op windows** (`gfa_pac_windows`, rows `[id, name, startedAt, endedAt,
source]`, only `"manual"` ones are ever stored):
- `fnc_windowSet [caller, "start"|"stop", name]` - server, admin-checked
  like `adminSet`; one manual window at a time (START closes the open one at
  the same stamp); STOP is a **forced** save. Ids are `"w" + stamp digits`.
  `GVAR(windowOpen)` is now the open manual id (was a bool) and is restored
  from the store at mission start - a restart mid-op does not end the op.
- `fnc_windowCurrent` - **precedence manual > config > opord**, per the
  handoff: the open manual id; else an `opWindows[]` entry that holds now -
  weekly `{dow, "HH:MM", "HH:MM"}` (dow number 0=Sun..6 or a name) giving
  `cfg:<i>:<date it started>`, or absolute `{"YYYY-MM-DD HH:MM", ...}`
  giving `cfg:<i>`; a window whose end is not after its start runs into the
  next day; else `opord:<currentOpord>`. **Sessions are stamped with this at
  join**, so a forgotten START is not lost - the report groups by the id.
- `fnc_windowName [id]` names any of the three shapes.
- `fnc_stampMinutes [stamp]` -> `[minutes, weekday]` and
  `fnc_minutesStamp [minutes]` -> `"YYYY-MM-DD HH:MM"` - Hinnant's
  days_from_civil / civil_from_days. `dateToNumber` breaks across New Year.

**Report:** `fnc_attendanceReport [windowId]` - per player: total minutes
(open rows count to `lastSeenAt`), joins; sorted by name; `""` = all time.
`fnc_adminText [caller, kind, arg]` (server, admin-checked) builds text and
sends it to the caller only; `fnc_textRecv [title, text]` puts it on the
clipboard, in the .rpt, and notifies. `kind = "report"` with `""` picks the
open window, else the latest, else all time. Export/delta will use the same
path.

**Page:** right rail gains OP WINDOW - name edit + START, STOP, ATTENDANCE
TO CLIPBOARD (`panelWindow`, `panelReport`; idcs 57-59, 63, 64; HINT moved
to y 0.660). Status block shows the current window's name. Summary gains
`window` (resolved id) and `windowName`.

**Checked:** `hemtt check` clean. On the way: a `minutesStamp` precedence
bug (`select (..) + str` parsed as `select ((..) + str)`), an undefined
helper in the first `windowCurrent`, and brace short-circuits. Nothing run
in game; the date maths is untested against a real clock.

### TAC//PAC - the admin page (deliverable 3)
**Sync:** `no` for `addons/pac`; `careful` for the three `adminpanel` touches
(a button that is inert without the pac addon, its idc, one line in the paint
list) - harmless in `ghost`, but pointless there.

**The page.** `addons/pac/ui/dialog.inc.hpp` + `idcs.inc.hpp` (`PAC_IDC_*`,
local to the display, idd `69700`; `idcs.inc.hpp` is included from
`script_component.hpp` so every function sees them). Same screen-as-console
layout as TAC//ADMIN and it inherits the console's `RscADMP*` control classes
(forward-declared in `config.cpp`) so the two screens are one family. Three
columns: **roster** (filter edit, UNASSIGNED toggle, list - offline players
muted not hidden, count), **player** (name/uid/updatedAt/serverId header;
RANK/ROLE/STATUS combos that write on change; GROUP free text + SET; SKILLS
list where a click toggles the row; AWARDS list + combo + ADD/REMOVE; NOTES
list newest-first + edit + ADD NOTE), **actions** (KICK/BAN with the
console's rules - on server, not you, `BIS_fnc_admin == 2`; BAN confirms via
`BIS_fnc_guiMessage` in a spawn; a status block with structure hash / player
counts / READ-ONLY warning; the ORPHANS list from the summary; a hint block
that states the live `skillSource` and what it means).

**Functions (all `panel*`, all PREP'd):** `panelOpen` (console button;
admin check), `panelOpened` (onLoad: re-checks admin or `closeDialog 2`,
fills the four combos from the structure once, sorted by name, "(none)" row
with data `""`), `panelStyle` (paints from `EFUNC(tacpad,theme)` exactly the
way the console's `fnc_style` does; writes the `TAC//PAC` wordmark in SQF
because `//` in a config string is a preprocessor gamble), `panelFillRoster`
(roster + orphans + status; re-selects the open row under
`GVAR(panelFilling)` so the list's own handler does not refetch),
`panelSelect` (asks `adminGet`), `panelFill` (draws the record; combos set
under the filling flag), `panelCombo` / `panelToggleSkill` / `panelGroup` /
`panelAward` / `panelNote` (each one edit -> `panelSet`), `panelSet` (the one
sender: refuses on read-only, else `remoteExec adminSet` to the server),
`panelUnassigned`, `panelKickBan`.

**Plumbing:** `fnc_adminSet` now sends the fresh record back to the caller
(`adminRecv`) after a write, so the page shows what the server holds.
Summary gains `readOnly`. `XEH_postInit.sqf`: the roster and summary PV
handlers also call `panelFillRoster`, which is a no-op unless the page is
open - that is how another admin's edit, or a player joining, shows up live.
`config.cpp` requiredAddons + `ghostD_notify`. New preInit state:
`GVAR(editUid)`, `GVAR(editRecord)`, `GVAR(panelFilling)`,
`GVAR(panelUnassigned)`.

**`addons/adminpanel`:** `ui/dialog.inc.hpp` - LOCK SERVER shrunk from
`w 0.170` to `w 0.082` and `ADMIN_PAC` ("TAC//PAC") added beside it at
`x 0.096 w 0.082 y 0.680`, `onButtonClick` guarded on
`ghostD_pac_fnc_panelOpen` existing; `ui/idcs.inc.hpp` +
`IDC_ADMINPANEL_ADMIN_PAC 27918`; `functions/fnc_style.sqf` - the idc added
to the button paint list after `IDC_ADMINPANEL_ADMIN_SERVERLOCK`.

**Not in this page yet** (later deliverables): op window start/stop (6),
export/import (8), auto-slot and loadouts (5).

**Checked:** `hemtt check` clean, 71 configs / 943 sqf. Two lints on the way:
`reverse` is in-place and returns Nothing (was used inline in a forEach), and
one needless `{}` short-circuit. Nothing run in game - the layout numbers are
untested on a screen.

### TAC//PAC - skills, ranks, and the server-side edit door
**Sync:** `no` (PAC is DIVINER-only); the one-line hook in `groups` is `careful`
- harmless in `ghost` because it is guarded on the function existing, but
`ghost` has no `pac` addon so it would be dead code there.

**Deliverable 4 of `incomingdocs/DESIGN_TAC_PAC.md`, minus the awards/status/
notes UI** (data-only until the admin page exists).

**`addons/pac` - new functions, all in `XEH_PREP.hpp`:**

- `fnc_applyRank [unit, rankId]` - reads the rank's `armaRank` from the
  structure, `setRank`s it, and writes `ghostD_Player_rank` (the variable
  `ghostD_players_fnc_setRank` writes) so nothing reads a stale rank. Must run
  where the unit is local. Refuses an `armaRank` outside Arma's seven; leaves
  an orphaned rankId alone rather than demoting anyone.
- `fnc_applySkills [unit, skillIds]` - a skill's `effects[]` are strings:
  `medic:N` / `engineer:N` / `eod:N` (ACE class + vanilla trait),
  `trait:name` (unit var true, broadcast), `var:name=value` (`true`/`false`/
  numbers become themselves, nothing compiled). **Clears first**: every var it
  set last time (kept in `ghostD_pac_setVars` on the unit) is nil'd and the
  ACE classes zeroed before the new set goes on. No skills = ACE 0 and no
  traits, per the handoff's DECIDED.
- `fnc_applyOnClient []` - the player reads their own row off the published
  `ghostD_pac_roster` (no round trip); rank always, skills only when
  `skillSource` is `"pac"`. Called from three places in `XEH_postInit.sqf`:
  a `waitUntil` on first spawn, `EntityRespawned` mission EH, and
  `addPublicVariableEventHandler` on the roster - the last is how an admin edit
  reaches somebody already in the field.
- `fnc_adminSet [caller, uid, field, value]` - **the only write path.** Server
  only; re-checks `[caller] call ghostD_adminpanel_fnc_isAdmin` (remoteExec is
  not a trust boundary); refuses when the store is read-only; validates ids
  against the structure (unknown rank/role/status/skill/award refused, not
  orphaned). Fields: `rankId roleId groupId statusId skillIds awardAdd
  awardRemove noteAdd`. Awards stored `[id, stamp, by]`, notes
  `[stamp, by, text]`. Stamps `updatedAt` + `serverId`, then `storeSave`
  (debounced) and `publish`.
- `fnc_adminGet [caller, uid]` / `fnc_adminRecv [uid, record]` - the read
  path for the admin page. Server re-checks admin, sends **one** record to the
  caller's machine only; notes and loadouts never reach ordinary clients.
- `fnc_publish` summary gains `orphans` (the `[uid, field, id]` list from
  `storeLoad`) so the admin page can warn.
- `config.cpp` requiredAddons now names `ghostD_adminpanel` (isAdmin) and
  `ghostD_tacpad` (`shared.inc.hpp`, `registerApp`) - both were used, neither
  was declared.

**`addons/groups/functions/fnc_setupPlayer.sqf`** - after the role's
`[player,'BIS'] call EFUNC(players,setRank)`:
`if (!isNil "ghostD_pac_fnc_applyOnClient") then {[] call ghostD_pac_fnc_applyOnClient};`
Role defaults first, PAC on top - otherwise role setup, which runs on
assignment and respawn, overwrites the PAC rank and (in pac mode) the skills.
Symptom without it: admin promotes a player, they respawn as PRIVATE.

**Checked:** `hemtt check` clean, 71 configs / 927 sqf before adminGet/Recv.
First build tripped `INFO_4` on a comma inside `getOrDefault ["name", _uid]`
in a macro argument - pulled into a local. Nothing run in game.

### TAC//PAC - phase 1 foundation and the player-facing surfaces
**Sync:** `no` for now. This is new and DIVINER-only until it has run; nothing
in `ghost` corresponds to it.

**From `incomingdocs/DESIGN_TAC_PAC.md`.** Phase 1 deliverables 1 and 2 done,
and the app and live tile from 3. The admin panel page, skills/ranks/awards
application, auto-slot, attendance, OPORD posting, METT-TC and backups are
still to come.

**New addon `addons/pac`** - 69 addons now.

- `fnc_loadStructure` compiles `CfgGFA_PAC` from the MISSION config into
  hashmaps once: settings with the handoff's defaults, then ranks, skills,
  awards, statuses, roles as flat records keyed by class name, and OPORDs as
  six nested sections plus attachments. Class names are the stable ids. No
  `CfgGFA_PAC` at all is empty sections and a warning, not a throw.
- `fnc_structureHash` folds it to one number for the live tile and the delta
  tool. **Every level's keys are sorted first** - `keys` on a hashmap promises
  no order, and a hash that depended on it would differ between two servers
  running byte-identical files, which is the one check it exists to serve.
  Settings are excluded because `serverId` differs by design.
- `fnc_storeLoad` / `fnc_storeSave` / `fnc_record` / `fnc_stamp` - the four
  `gfa_pac_*` keys in the server's profileNamespace, exactly as the handoff
  names them because they are the backup format too. Type-checked on read.
  Orphaned ids are **flagged and kept**, never dropped. Saves debounced to 30 s
  with a forced write on mission end. Records seeded empty on connect: with
  `skillSource = "pac"` a new player has no skills until an admin assigns them,
  which the handoff marks DECIDED. `stamp` is UTC from `systemTimeUTC`, not
  `date` - a mission set in 1985 would otherwise sort before everything.
- `fnc_publish` sends clients a flat roster and a summary struct, on change
  rather than on a timer. Notes and loadouts stay on the server. Sorted by
  name through a name-first pair, because the rows lead with the UID.
- `fnc_app` - TAC//PAC in the tacpad: RECORD, ROSTER, OPORD under a tab row.
  Read-only by design; `fnc_lookup` turns ids into names and prints `(id?)`
  for one the structure has lost.
- A PAC tile in `tacpad_apps`, reading the summary, guarded on the addon.

**THE NO-CBA RULE, AND HOW IT IS READ.** The handoff says no CBA dependency.
It cannot hold literally - `PREP` is `CBA_fnc_compileFunction` and every PBO
here requires `cba_xeh` - so it is read as its intent: PAC's own behaviour uses
vanilla plumbing. `addMissionEventHandler` for Ended and PlayerConnected,
`profileNamespace`, `createHashMap`, `remoteExec` to come, and no CBA settings
at all - configuration is `CfgGFA_PAC` and nothing else. Two places where the
rule bit: `CBA_fnc_formatNumber` in the timestamp became hand padding, and the
tacpad's `CBA_fnc_execNextFrame` reopen idiom became a `spawn`.

**One guard the handoff does not ask for:** a store whose `schemaVersion` is
newer than the build makes PAC read-only. A build that cannot read the store
properly must not be the one that rewrites it.

**Contract:** `CfgGFA_PAC` in mission config is a **new contract**, per the
handoff §1-2. A new app id `pac`. Four profileNamespace keys on the server.
`ghostD_pac_roster` and `ghostD_pac_summary` broadcast to clients.

**Checked:** `hemtt check` - 71 configs, 923 sqf files, clean at every level.
Not run in game. Three tooling slips caught on the way: `printf` turned `\a` in
the `$PBOPREFIX$` into a bell character, a file was truncated mid-write, and the
`shared.inc.hpp` include was silently not applied the first time - the build
said so, as all-caps variable warnings on `ROW_H` and `PAD`.

### a drone swarm module
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite, and it depends on
nothing ALiVE ever provided.

**Files:** `addons/uas/functions/fnc_moduleDroneSwarm.sqf`,
`fnc_swarmImpact.sqf`, `fnc_swarmCircle.sqf` (**new**), their `PREP`s, the
`ghostD_moduleDroneSwarm` class, `QGVAR(swarmClasses)`, `units[]`, and the
swarm macro block in `script_component.hpp`.

**A SWARM IS AN EVENT, NOT A PRESENCE**, which is why it is a second module
rather than a checkbox on the patrol one. `ghostD_moduleDronePatrol` keeps a
standing watch, replaces losses and stands down when nobody is near. This
launches once, launches everything, and what is gone is gone.
`isTriggerActivated = 1`, so it can wait on a trigger and go on cue.

| Attribute | |
|---|---|
| Airframe | `ghost_ClassPick_Uav_Single` - a picker with side and faction filters |
| Drones | 2 to 12, clamped |
| Action | Impact or Circle |
| **Spawn Min / Max (m)** | 1500 / 2500 - how far out they appear and fly in from |
| Side | the fallback crew's side |
| *(resize)* | the orbit radius; Impact ignores the area |

**THEY ARRIVE, THEY DO NOT APPEAR.** Both actions spawn out at the module's band
and fly in - each drone rolls its own distance inside it, on its own bearing. The
transit is the whole point: it is the window in which the swarm can be heard,
seen and shot at, and at the impact speed 1500 m is about thirty seconds of
somebody deciding what to do. A swarm that materialises on top of its target is
not a swarm, it is damage.

For **circle**, the spawn bearing is the same slice the drone will hold on the
ring, so the flight in spreads them out as well. The LOITER waypoint does the
transit; nothing steers it.

**Spawn Min is floored at 500 m** whatever is typed. Below that there is no
window, and removing the fight is not a difficulty setting.

**Two actions, and they want different airframes.**

- **IMPACT** - every drone spawns 400-800 m out on its own bearing and dives.
  The same steering loop `EFUNC(ambience,kamikazeRun)` flies, written here
  rather than called: that function picks its own target near a player and gates
  the spawn on a module's markers, and a swarm has been told where to go. **A
  drone shot down detonates nothing** - the handler removes itself and that is
  one fewer warhead arriving, which is the whole reason the count matters.
- **CIRCLE** - each drone takes its own slice of the ring and its own altitude
  shelf, gets a LOITER waypoint, and is then **left alone**. An impact drone is
  flown by a loop because it is a weapon with no opinion; a circling one has a
  crew, sensors and usually a gun, and writing its velocity would fight the very
  AI that makes it worth fielding.

**The airframe list is a CBA setting.** *Ghosts of Battle > Drones > Swarm
airframes*, defaulting to the three vanilla UAVs. An Eden attribute is read from
config and cannot know about a CBA setting, so the picker offers every UAV in the
game and the setting is what actually gets fielded - a module naming a class
outside it **refuses when it is placed**, in the RPT and on the Zeus's screen,
rather than at launch when nobody is watching. Empty allows anything.

**It finally uses `CfgEdenDrone.hpp`.** That file has a full drone class picker -
side and faction filters, typed override - written for drone modules that never
came over in the split, and referenced by nothing until now.

**A bug avoided by reading the existing code first.** I had both swarm functions
joining the drone's crew into a group of our own to force its side.
`FUNC(topUp)` documents exactly why that is wrong: *a UAV's autonomy lives in the
crew group `createVehicleCrew` makes, and moving that AI into another group
leaves an aircraft with nobody flying it* - drones fall out of the sky. Both
functions now leave the crew group alone and only seat a fallback UAV AI when an
airframe comes out empty, which is what the side field is actually for.

**Contract:** two new module classes in `uas`'s `units[]`, one new setting.
`ghost_ClassPick_Uav_Single` is now referenced from outside `ghostD_main`.

**Checked:** `hemtt check` - 70 configs, 912 sqf files, clean at every level.
**Not run in game.** Worth watching: whether the picker attribute renders in
Eden from another addon's module, whether the LOITER waypoint holds the radius
for a quadcopter as well as a fixed wing, and whether twelve impact drones at a
0.1 s steering step is a frame time anybody notices.

### the ambience modules are areas you draw
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite. `ghost` has both
modules with the same marker-only fields.

**Files:** `addons/ambience/functions/fnc_areaMarker.sqf` (**new**), its `PREP`,
`fnc_kamikazeModule.sqf` and `fnc_shellingModule.sqf` (six lines each),
`CfgVehicles.hpp` (`canSetArea` on both modules, and the marker field
relabelled).

**Why:** both modules scoped themselves by naming area markers you had drawn
somewhere else - "Area Markers", comma separated, blank meaning anywhere near a
player. Placing the module was therefore two jobs: put the module down, then go
and draw the markers and type their names in. **Resize the module** is one.

**How, and why it is six lines rather than a rewrite.** The area is handed to
`FUNC(pickBuilding)` and `FUNC(kamikazeRun)`, and both hand it to
`EFUNC(common,taorGate)`, which takes marker NAMES because that is what a TAOR
was. So `FUNC(areaMarker)` turns the module's own `objectArea` into a marker and
appends it to the list. Teaching four functions a second way to describe an area
- and leaving two of them able to disagree about whether a position is inside
one - would have been the worse change.

**The marker is local to the server.** Both schedulers run there and so does the
gate they feed, so a global marker would be four network updates and a box on
forty clients' maps to answer a question one machine asks. `hemtt`'s `L-S24`
flagged the global version, which was the prompt to notice that.

**Named markers still work and now ADD to the module's area** rather than being
the only way to say it - the module is the easy answer, a marker somebody drew
by hand is the precise one. A module never resized behaves exactly as before:
anywhere near a player.

**Both modules, not just the kamikaze one.** The shelling module had the
identical field and the identical problem, and leaving one resizable and one not
would be a worse pair than either.

**Checked:** `hemtt check` - 70 configs, 909 sqf files, clean at every level.
Not run in game. Worth watching: that `objectArea`'s `[a, b, angle, isRectangle]`
maps onto marker size the way Eden draws it, particularly for a rotated
rectangle.

### uas ported from ghost: one module, one drone patrol
**Sync:** `careful`. `ghost` keeps this addon with its module and its ALiVE
objective planner, which still works there. Nothing ports back; what matters is
that the two now differ in where a patrol comes from.

**68 addons.** `EGVAR(uas,caches)` and `EGVAR(uas,cacheSide)` exist for the
first time, so `EFUNC(hacking,intelHint)`'s drone-cache source comes alive with
them - the third of its five sources to be reconnected this session.

**Why it needed redesigning rather than porting.** Patrols orbited each ALiVE
commander's own objectives; caches were scattered over each side's TAOR; the
airframe was the commander's faction. Six of thirteen functions asked the
adapter, sixteen call sites. All three of those - objectives, TAORs, commanders
- are gone, so the addon had no answer to WHERE at all.

**New: `ghostD_moduleDronePatrol`, an area module - and ONE MODULE IS ONE
PATROL.** Resize it in Eden or Zeus and the area is the ground flown over.
`canSetArea = 1` and `objectArea`, the same pattern
`EFUNC(modules,moduleHealArea)` already uses. The first module armed starts the
system; one placed an hour in joins the same walk rather than starting a second.

| Attribute | Default | |
|---|---|---|
| Side | `east` | a side friendly to the players is skipped |
| Drones | `1` | how many airframes this patrol keeps up; 0 is placed-and-off |
| Drone Class | empty | empty flies a UAV belonging to the side |
| Artillery On Detect | off | a drone that SEES somebody shells where it saw them |
| Rounds / Scatter / Cooldown | 6 / 100 m / 300 s | that mission, and the gap between two from this patrol |

**Everything about a patrol is on its own module**, which is the shape the whole
rework turns on. ghost had one module for the map and a per-side ceiling shared
across every objective a commander held, with a drip replacement, stand-down
credits and a seeded first fill to ration airframes between them. A number on
the module you placed is a better answer to "how many drones over THIS ground",
and it deleted all of that machinery:

- `GVAR(standDownCredit)` is gone - written by `FUNC(standDown)` and read by
  nobody once the drip went. Ground a section leaves refills as soon as somebody
  is near it again, because a patrol is filled to its own number every tick.
- `GVAR(sideMax)`, `GVAR(baseMax)`, `GVAR(reducedMax)` and the three per-side
  faction settings are gone with it.
- `FUNC(ceilingFor)` **changed meaning**: it was "how many may this side have
  up", it is now "what may this patrol have up given the supply state", and it
  only ever reduces. Four call sites still passed the old single argument and
  would have read zero - `planPatrols` had a dead side-ceiling gate above the
  new loop, `respondTo` gated dispatch on it, the `#ghostuas` report printed it
  and `cacheDown` logged it. All four found and fixed.

**Artillery on detection** hooks `FUNC(spotSweep)`, which already finds the drone
that has actually SEEN somebody - `knowsAbout`, not proximity, so a section that
stayed still and cold is not punished for being overflown. It fires on where the
contact WAS seen, scattered: moving is the counter, the same rule the jammer
sites answer on. Two clocks pace it - the spotter's own cooldown and the
patrol's, because a module flying four airframes over one section is otherwise
four fire missions. The airframe carries its patrol's index, stamped at
creation, which is how the sweep finds the option.

**New: `fnc_zonesFor.sqf`**, standing exactly where
`adapter_alive_fnc_objectivesFor` stood. It returns
`[side, pos, radius, index, class, count, arty]` - the first three are the old
objective entry, so `FUNC(topUp)` reading the orbit centre out of `_x select 1`
never had to change. The index is the identity: stamped on every airframe the
patrol launches, counted back by `FUNC(planPatrols)` and read by
`FUNC(spotSweep)` for the artillery option.

**What each ALiVE call site became:**
- `planPatrols` - forty lines deciding own ground versus enemy ground, then
  gating every objective through `taorGate`, collapse to one line: the zones
  drawn for that side. **A placed zone IS the declaration**, so there is nothing
  to decide and nothing to gate. The commander walk became a distinct-sides walk
  over the zone list.
- `placeCaches` - `findSite` already takes a ring rather than markers, so a
  zone's own centre and radius are the search area. The side's allowance splits
  across its zones, at least one each until it runs out: three caches and four
  zones is three zones with a cache, not four with none.
- `respondTo` - a drone answers noise inside its own zones. Same rule the TAOR
  test enforced, asked of the thing that now knows.
- `topUp` - the stand-off spawn is clamped into the zone instead of into a TAOR,
  and `profileIgnore` is gone because nothing profiles anything.
- `cacheDown` - no ALiVE logistics to request a resupply run. A destroyed cache
  is destroyed; the ceiling returns when the outage window closes rather than
  when a convoy arrives.

**A bug the port would have shipped.** `FUNC(topUp)` still had
`if (GVAR(patrolOver) == 1 && ...)` gating the spawn. `patrolOver` was a module
attribute and the module is deleted, so that variable is never set - **nil == 1
throws**, on every single launch, and the fleet would never have topped up. It
is gone with the TAOR gate it guarded.

**Settings replaced the module's tuning**, all server-side: airframes per side,
ceiling after a cache is lost, outage min/max, caches per side, and a faction
per side for `FUNC(factionUav)` to resolve. Per-side ceiling OVERRIDES are gone
- `GVAR(sideMax)` stays as an empty map that `FUNC(ceilingFor)` falls through,
so a side's ceiling is the shared number for everybody.

**Deleted:** `functions/fnc_moduleController.sqf`, the `ghostD_moduleUAS` class
and its 100 lines of attributes.

**Checked:** `hemtt check` - 70 configs, 908 sqf files, clean at every level.
**Not run in game**, and this is the largest untested surface of the session:
1,400 lines of ported planner logic now reading a source it has never read. What
wants watching first is that a resized module registers the radius Eden shows,
that patrols appear only when a player is inside the zone, and that caches land
inside it rather than in the sea.

### antiship ported from ghost, with the module dropped
**Sync:** `careful`. `ghost` has this addon with its module and its ALiVE
siting, and that still works there. What ports back is nothing; what matters to
ghost is only that the two now differ.

**The mod goes to 67 addons. LOCATE ANTI-SHIP and LOCATE RADAR can appear for
the first time** - both products were already written against
`ghostD_antiship_batteries` and `ghostD_antiship_radars`, and until now those
were read in five places and written in none. Intel Hunt's two coastal sources
come alive with them.

**Files:** `addons/antiship/` - copied from `ghost/addons/antiship`, re-prefixed
`ghost_` to `ghostD_` across 13 files. Then:

- `functions/fnc_moduleController.sqf` **deleted**, with its `PREP`, the
  `ghost_moduleAntiShip` class and 250 lines of module attributes in
  `CfgVehicles.hpp`, and the `CfgPatches` entry.
- `CfgFactionClasses.hpp` **deleted** - it declared the Eden module category and
  the units are `vehicleClass = "Static"`. Five other addons still declare it.
- `functions/fnc_launcherInit.sqf` **new**.
- `initSettings.inc.sqf` **new**.
- `CfgEventHandlers.hpp` - an `Extended_Init_EventHandlers` for the launcher
  beside the radar's.
- `XEH_preInit.sqf` - the two registries declared before anything can be
  created, and the settings included.
- `fnc_tick.sqf` - `_logic` renamed `_launcher`; the name outlived the module.
- `README.md` - rewritten.

**No custom models, which is the good news.** The launcher inherits
`O_SAM_System_04_F`, the radar `O_Radar_System_02_F`, and the decoy is
`B_UAV_01_F` wearing `InvisibleTarget_F.p3d`. So "remake the units" was
recreating definitions, not re-authoring art - none of the baked-in texture-path
trouble that killed the hackphone and soldiertab models in the split.

**WHY THERE IS NO MODULE.** `ghost_moduleAntiShip` did not configure a battery,
it **sited** one: switch a side on and it found coastal ground inside that
side's ALiVE TAOR markers and put a crewed battery on it. There are no TAORs and
no commanders to own them, so the siting had nothing left to read. The honest
replacement is not a smaller module - it is putting the launcher where you want
it. A mission maker knows which headland the battery is on.

Both units bring themselves on line when created, in Eden, in Zeus, or from a
script. The radar already did exactly this - `FUNC(radarInit)` was registration
only and module-free - so the launcher now does the same.

**ONE LAUNCHER IS ONE BATTERY.** The module grouped several under one clock. A
hand-placed launcher carries its own config and its own interval, so three on a
headland are three tubes on three cycles rather than one battery firing three
times as fast. More predictable for somebody placing by eye, and deleting one
launcher removes exactly one tube.

**Radars are read live, not baked.** `FUNC(pickTarget)` is handed the whole
registry each cycle, so a radar sited after the launcher still sees for it -
which is the ordinary case in Zeus, where the launcher goes down first because it
is the thing being hidden.

**Side comes from the crew, then the config.** A crewed static answers `side`
through its gunner; an empty one answers civilian, which would make it hostile
to nobody and invisible to every product. The class's own config side is the
fallback, so an uncrewed launcher placed and forgotten still reads as east.

**Settings replaced eight of the twenty-two attributes** - interval, search
range, target classes, missile speed, cruise altitude, terminal range,
interceptable, debug - all server-side. The other fourteen described where to
site a battery and died with the module.

**Contract:** `ghostD_antiship_batteries` is `[id, posASL, side]` keyed by grid,
`ghostD_antiship_radars` is objects. Both broadcast, both read by
`EFUNC(hacking,productLocateCoastal)`, `productLocateRadar` and `intelHint`.

**Checked:** `hemtt check` - 69 configs, 890 sqf files, clean at every level.
**Not run in game.** The port is mechanical but the module removal is not: what
wants testing is that a launcher placed in Eden registers and fires on its own
clock, that a radar placed afterwards feeds it, and that an uncrewed launcher
takes the config side rather than civilian.

### a missing mod removes its tile, rather than showing a dead one
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite. The PLP half applies to
`ghost` unchanged; the Simplex half needs the Simplex integration first.

**Why:** two things in the suite were front ends for mods that may not be
installed, and both drew anyway - TAC//SUPPORT's tile read NO LINK and the MAP
TOOLS strip drew dimmed with PLP NOT LOADED in its header. That is an
explanation where an absence is the answer. The band is six tiles wide and the
tools strip is three rows of map given up; neither is worth spending on a
permanent apology.

**Files:**
- `addons/init/XEH_preInit.sqf` - `EGVAR(patches,usesSimplex)`, beside the other
  mod checks and in the same shape: `isClass (configFile >> "CfgPatches" >>
  "sss_main")`.
- `addons/tacpad_apps/XEH_postInit.sqf` - the `support` app is registered only
  when Simplex is present.
- `addons/tacpad_apps/functions/fnc_tileData.sqf` - the SUPPORT tile is built
  only then too. With Simplex present but nothing commissioned it still says so
  - that is a state, not an absence.
- `addons/tacpad_apps/XEH_preInit.sqf` - the `tools` panel's existence condition
  gains `!isNil "PLP_fnc_SMT_Main"`. `FUNC(register)` already takes a condition
  checked each time the map opens, which is exactly the lever for this - no new
  machinery.
- `addons/tacpad_apps/functions/fnc_appSettings.sqf` - the MAP TOOLS settings
  section is filtered out with it. Its one row toggles a panel that cannot
  exist, and a settings page whose switch does nothing is worse than one without
  the switch.

**The rule this establishes:** an absent MOD removes the thing; absent EQUIPMENT
or absent DATA shows a state. So DRONES and JAM still read NO SCANNER when the
player is not carrying one - the addon is loaded and the tile is telling him
something true about himself. TAC//SUPPORT with Simplex loaded and nothing
commissioned still draws, reading NONE.

**Detection differs by case, deliberately.** Simplex is a `CfgPatches` check at
preInit, because the app is registered at postInit and a function may not be
compiled yet. PLP is `isNil "PLP_fnc_SMT_Main"` - the same test
`FUNC(panelTools)` already uses to decide which buttons are live, and the
condition is evaluated when the map opens rather than at init, so the function
is certainly there by then. Two tests for two timings rather than one test used
at the wrong moment.

**Contract:** with Simplex absent, the `support` app id does not resolve - a
role's `tiles[]` entry naming it is skipped, as an unknown id already is. With
PLP absent, `QGVAR(show_tools)` is still a registered setting and simply has
nothing to show.

**Checked:** `hemtt check` - 68 configs, 882 sqf files, clean at every level. Not
run in game, and neither mod was loaded to test the present case.

### TAC//SUPPORT gets its own fire mission and CAS windows
**Sync:** `careful` - depends on the Simplex integration below it, which `ghost`
does not have.

**Why:** the board hands off to Simplex's request screen, which works but is a
different mod's visual language dropped into the middle of ours. The preference
is our windows on their backend.

**What that costs, honestly.** Simplex's artillery planner is 29 GUI functions -
sheaf, dispersion, coordination, multi-task plans, relocation. Cloning that is
not a window, it is a project. So the split is: **the mission a man asks for
ninety-five times in a hundred gets our window; the other five open theirs.**

**New: the fire mission window** - `dialog.hpp` (rebuilt, one map control),
`fnc_supportRequest.sqf`, `fnc_supportRequestDraw.sqf`,
`fnc_supportRequestSend.sqf`.

Left column ours, right half a map. Click a point, pick rounds per gun, SEND.

- **Everything on it is asked of Simplex.** `sss_artillery_fnc_canFire` per
  vehicle for range and time of flight, `sss_artillery_fnc_fire` to send it.
  Nothing here simulates anything or decides who may fire. Calls are by name -
  `EFUNC` does not reach across mods.
- **Per gun, and it says so.** An entity is a battery, not a tube: it holds
  `sss_vehicles`, and `canFire` is asked of each because range is per vehicle. A
  battery half in range says `2 OF 4 IN RANGE`, which is worth knowing before the
  press rather than in the impact area. The SEND button prints the total.
- **Out of range is answered before the press.** SEND is dead and says why.
- **It asks again before it fires.** The list is rebuilt in `supportRequestSend`
  - a gun can have died or moved since the target was placed a minute ago.
- **ADVANCED opens Simplex's planner** on the same entity, for the sheaf and
  plans this window deliberately does not have.
- **Time of flight is the longest of the guns that can reach**, because the
  mission is not over until the last shell lands.

**CAS uses the same window.** A strafe run and a loiter station are both "there,
please" - the point IS the request - so the window switches on the service and
shows what differs:

- Simplex dispatches on the entity's own `sss_supportType`, so ours sends
  `[player, entity, ["posASL", ...]]` to `sss_cas_fnc_request` and lets it decide
  whether that is a strafe or a station. The MISSION row says which will arrive.
- **No `canFire` and none needed.** An aircraft flies in from a spawn distance
  and is not refused for range, so the only refusal is the entity's cooldown -
  read live in the draw rather than off the board, which may be a minute old.
  SEND goes dead and counts it down.
- **No time of flight.** That is a shell's number. An aircraft's arrival is
  Simplex's own estimate, announced when it accepts the request rather than
  guessed at here.
- Altitude, aim range, ingress and egress all have defaults over there, and
  ADVANCED is where somebody who wants to set them goes.

**Transport and logistics still open Simplex's screen**, and should: both are
waypoint problems rather than a point on a map, and its complexity earns itself
there.

**Two bugs caught before they shipped:**

1. **The rounds row was laid out from the round count.** The layout used `_x`
   and `_y` as column origins, and `forEach` owns `_x` - so inside the
   `forEach [1,2,4,6,8,12]` that draws the buttons, `_x` was the round count and
   every button was positioned from it. Renamed to `_colX`/`_colY`/`_colW`/
   `_colH` so it cannot recur.
2. **`drawIcon` takes eleven arguments and CBA's `ARR_` macros stop at 8.** The
   map draw handler was written with `ARR_10` and would not preprocess. It is a
   code block in a file rather than a macro argument, so it needs no `ARR_` at
   all.

**Why a dialog and not a panel:** a map control embedded in the map display
bleeds past its frame and feeds its drags to the map underneath. In a dialog it
clips, pans itself, and CLOSE is a `closeDisplay` nothing can sit on top of. The
old TAC//SUPPORT reached the same conclusion and its `dialog.hpp` is where this
one's geometry came from.

**Checked:** `hemtt check` - 68 configs, 882 sqf files, clean at every level.
**Not run in game and not run with Simplex loaded.** The API was read out of the
Simplex source, never exercised. Highest-risk pieces: whether `canFire`'s ETA
return shape is `[bool, number]` as read; whether the map's `MouseButtonDown` and
`Draw` handlers behave inside a dialog laid over the map display; and the
ordering of closing the tacpad map before opening either window.

### TAC//SUPPORT is back, over Simplex Support Services
**Sync:** `careful`. `ghost` still has ALiVE combat support and its own
TAC//SUPPORT screen, so this replaces something that works there. It ports if
and only if ghost is also moving to Simplex.

**Files:** `addons/tacpad_apps/functions/fnc_appSupport.sqf` (**new**, the name
the deleted one had), its `PREP`, its `registerApp`, and a SUPPORT tile in
`fnc_tileData.sqf`.

**Why:** the app was removed with ALiVE - it was that system's front end and had
no other backend. Simplex Support Services (`D:\Git\Simplex-Support-Services`,
GPLv2) is the backend now: artillery, CAS, transport and logistics.

**IT DOES NOT REIMPLEMENT SIMPLEX, and that is the design.** The old
TAC//SUPPORT drew its own tasking screen over ALiVE - a fire mission builder, a
target picker, an asset list and a verdict row, about a thousand lines, all of
it a second implementation of somebody else's system that could and did disagree
with it. Simplex already has a request screen with a map you draw the mission
on. So this is a **board**: every service, every callsign the player is
authorised for, ready or how many seconds until it is - and a press hands off to
`sss_common_fnc_openGUI` for that entity. One implementation of tasking, and it
is not ours.

**What it reads, all of it Simplex's own:**

| | |
|---|---|
| `sss_common_services` | the commissioned services, in Simplex's order - a service it gains is a row we get for nothing |
| `[unit, service] call sss_common_fnc_getEntities` | only what THIS unit is authorised for, asked per draw and never cached |
| `sss_callsign`, `sss_cooldownTimer` | the row and its state |
| `[service, entity, false] call sss_common_fnc_openGUI` | the hand-off |

**Authorisation is Simplex's.** We do not filter and we do not cache: a board
that disagreed with the request screen about what a man may call would be worse
than no board. A service with nothing he may use takes no row at all - he is not
on that net, which is different from "none available".

**No Simplex, no screen.** Guarded on `sss_common_fnc_getEntities` being defined
rather than on a CfgPatches check, because that is the thing actually called.
The app says so and the tile reads NO LINK - the same words it used when ALiVE's
combat support was missing, meaning the same thing.

**Contract:** the `support` app id resolves again, so a role's `tiles[]` entry of
`{"support", "true"}` works as it did. Missions that had it swept out after the
removal can put it back. No new hard dependency: `tacpad_apps` does not require
Simplex and never asks whether it is installed except by calling it.

**Checked:** `hemtt check` - 68 configs, 879 sqf files, clean at every level.
**Not run in game, and not run with Simplex loaded at all** - the API was read
out of the Simplex source, not exercised. The hand-off is the part to watch:
closing the map display before opening Simplex's dialog is the sequence the rest
of the suite uses, but Simplex's own `openGUI` defers a frame and checks for its
`sdf` display first, so the two may need to be ordered the other way round.

### adapter_alive deleted - ALiVE is out of DIVINER
**Sync:** `no`. `ghost` runs ALiVE and keeps its adapter. This is the end of the
split, not a change to port.

**Files:** `addons/adapter_alive/` removed entire - 48 files, 38 functions.
`addons/init/XEH_preInit.sqf` loses the comment explaining where
`EGVAR(patches,usesAlive)` was set, since nothing sets it now and nothing read
it but the adapter itself.

**The mod goes from 67 addons to 66, and 919 sqf files to 878.**

**What it was.** One addon was allowed to know ALiVE existed, and everything
that wanted a fact about the war asked it: profiles and their positions,
commanders and their TAORs, objectives, camps, logistics hubs, radars, air
defence, artillery, installations, combat support, the intelligence model, the
civilian hostility model, and the campaign save. Nine addons called into it.
None do now - they were taken off it one at a time over the entries below this
one, and each replacement is a thing the mission maker or Zeus controls instead
of a thing the simulation happened to contain.

**What is left is prose.** Three comments name ALiVE and none of them calls
anything: two in `main/CfgEdenDrone.hpp` crediting the attribute technique the
drone Eden fields were built from, and one in `respawn/fnc_gearManaged.sqf`
saying which adapter function that answer replaced. They are history, and worth
keeping - somebody reading `gearManaged` in a year should know why it exists.

**Contract:** `ghostD_adapter_alive` is gone as an addon. `ghost_patches_usesAlive`
is never set, so a mission testing it reads nil rather than false - the same
answer it would have had with the adapter loaded and ALiVE absent.

**Checked:** `hemtt check` - 68 configs, 878 sqf files, clean at every level.
**Nothing outside DIVINER was touched at any point in this work.** Verified:
`d:\Git\ghost` and the framework mission have no file modified in the session,
and `MRHMilsimTools` was read only. The one thing written outside the repo is
`d:\Git\_DIVINER_unlicensed_art\`, the quarantined loading-screen art, which was
moved there deliberately and reported at the time.

### hacking: the mission writes the intelligence, and nothing calls ALiVE any more
**Sync:** `careful`. `ghost` keeps ALiVE, so its six locator products still have
a backend and this replaces something that works there. The intel package itself
ports cleanly and is worth having either way.

**NOTHING IN THE MOD REFERENCES THE ADAPTER.** Two mentions remain and both are
prose - a comment in `init/XEH_preInit.sqf` and one in
`respawn/fnc_gearManaged.sqf` saying where that function came from.
`addons/adapter_alive` and its 38 functions can be deleted.

**Why:** six products - LOCATE AA, ARTILLERY, CAMP, LOGISTICS, RADAR and
INSTALLATION - asked the adapter where ALiVE had put something and drew a
shrinking circle round the answer. The intelligence in a mission was therefore
whatever the simulation happened to contain, and a mission maker could not write
a document, hand over a photograph, or decide that breaking into one terminal
tells the players about somewhere else.

**What replaced them:**

- **`fnc_packageEntries.sqf`** (new) - reads a package out of
  `missionConfigFile >> "Ghost_IntelPackages"`. Entries carry `title`, `text` and
  an optional `image`; one with none of the three is skipped with a warning.
  Config order is the order they are handed over in, from the top, so a mission
  maker puts the meat first.
- **`fnc_productPackage.sqf`** (new) - hands over a share, remembers what that
  SIDE has already had off that DEVICE, and files it. Per side rather than per
  player: two men hacking one terminal are one effort. The tally lives on the
  device so it dies with it.
- **`fnc_moduleIntelPackage.sqf`** + **`ghostD_moduleIntelPackage`** (new) -
  Eden and Zeus. Synchronised to something, that object carries the package and
  becomes hackable whatever it is; synchronised to nothing, it builds a
  `Land_DataTerminal_01_F` where it stands. It validates the package name at
  placement, so a typo is reported to the person who made it rather than
  discovered by a player being told the terminal is empty.
- **`EGVAR(tacpad_apps,appIntel)`** + an INTEL tile (new) - TAC//INTEL, folders
  down the left and the open file down the right. Reads the broadcast store, so
  a man who was nowhere near the terminal reads what his section recovered.
  Pictures draw through `RscPictureKeepAspect` rather than
  `EFUNC(tacpad,drawIcon)`, which derives width from height and is square by
  construction - right for a status pip, wrong for a reconnaissance photograph.
- **`QGVAR(cfg_package_share)`** (new setting, SLIDER, default 34%) - how much
  of a package one break-in yields. A percentage of the package's own length, so
  a three-entry package and a thirty-entry one both take about three visits. A
  share that rounds to nothing still hands over one entry.

**Deleted:** `fnc_productLocateAA.sqf`, `fnc_productLocateArty.sqf`,
`fnc_productLocateCamp.sqf`, `fnc_productLocateHub.sqf`,
`fnc_productInstallation.sqf`, `fnc_taorType.sqf`, and their PREPs.

**What survived, and why.** `productLocateCoastal` and `productLocateRadar` read
`EGVAR(antiship,batteries)` and `EGVAR(antiship,radars)` - ghost's own objects,
on the map, not profiles. `productLocateRadar` had ALiVE's radar profiles as a
second source and has lost that half; what is left is the coastal set, which is
the half of the anti-ship split the product exists for. LOCATE JAMMER and TRACE
NETWORK were never the adapter's.

**Also changed:**
- `fnc_intelOptions.sqf` - the menu no longer switches on `FUNC(taorType)`.
  **The device decides, not the ground it stands on** - which is both the only
  question anything can still answer and the better question: what a terminal
  can tell you is a fact about the terminal.
- `fnc_serverPick.sqf` - takes the device as a fifth argument, because the
  package lives on it. `fnc_hackComplete.sqf` passes it at all three call sites.
  The package writes its own result line and `serverPick` skips the generic one.
- `fnc_intelHint.sqf` - six ALiVE pool sources and the TAOR gate gone. Every
  source left is an object somebody deliberately placed, which is a shorter pool
  and an honest one.
- `fnc_ladderCircle.sqf` - no longer reports each circle to ALiVE's intelligence
  model. The circle on the player's map IS the product.
- `XEH_postInit.sqf` - the `hack.taor` debug command, the population hostility
  bump, and **the intel tally's persistence**. Banked deposits, hint tier and
  the hinted list were read from ALiVE's save on its ready event. There is no
  save now: a restarted mission starts the tally at nothing, like every other
  counter in this mod. `QGVAR(popSeen)` still fires and logs, so a mission that
  wants to answer a witnessed hack has somewhere to listen.

**Contract:**
- `Ghost_IntelPackages` in mission config is a **new contract** - documented in
  `wiki/Intel-Packages.md`, linked from the sidebar.
- A new app id, `intel`, so a role's `tiles[]` can carry `{"intel", "true"}`.
- The six product ids no longer resolve. A saved session holding one falls
  through `serverPick`'s default and produces nothing.

**Checked:** `hemtt check` - 69 configs, 919 sqf files, clean at every level.
**Not run in game, and this is a lot of new surface.** What wants looking at:
that a package module attached to nothing builds its terminal and Zeus can still
pick it up; that the share arithmetic walks a package instead of repeating it;
that TAC//INTEL's folder and file lists do not run off the bottom of the panel
with a large package; and whether a `.paa` at a mission-relative path draws in
`RscPictureKeepAspect` at all.

### jamming: sites are placed by hand, and they shoot back
**Sync:** `careful`. `ghost` keeps ALiVE, so the objective-driven spawner still
works there and the module is an addition rather than a replacement. The
artillery reply ports as-is.

**The last hard dependency on `ghostD_adapter_alive` is gone.** `jamming`'s
`requiredAddons` was the only one anywhere. Nothing now requires the adapter to
load; `hacking` is the only addon still calling into it, all through guarded
soft references.

**New: `ghostD_moduleJammerSite`** - one module, one emitter, where you put it.
Eden or Zeus (`scopeCurator = 2`, so Zeus placement comes free).

| Attribute | Default | |
|---|---|---|
| Spectrum | `radio` | `radio`, `data` or `gps`. One per site - the terminal model follows it |
| Radius (m) | `0` | 0 rolls one from the Jamming module's bounds |
| Side | `east` | who owns it, through `EFUNC(common,sideFromText)` |
| Artillery Reply | off | the site shells whoever loiters in its field |
| Reply Delay (s) | `90` | dwell before it fires; resets when the field is empty |
| Reply Rounds | `8` | |
| Reply Scatter (m) | `120` | around the last known position |
| Reply Cooldown (s) | `300` | minimum gap between two missions from this site |

**New: `FUNC(moduleJammerSite)`** builds the site through the existing
`FUNC(spawnJammerSite)`, or `FUNC(spawnGpsUplink)` when the spectrum is `gps` -
GPS is not a bigger mast, it is a ground uplink plus the wandering sphere it
steers, and killing the uplink kills the sphere. It waits on a per-frame handler
for `GVAR(moduleUp)`, because module functions have no ordering between them and
a site built before the Jamming module has read its attributes would roll its
radius from preInit defaults. Ten seconds without an enable and it says so
rather than standing up a mast that denies nothing.

**New: `FUNC(artyReply)`** - the reply loop, one per armed site, ticking every
`JAM_ARTY_TICK` (5s):

- **Detection is presence, not line of sight.** Anybody hostile inside the field
  counts. The fiction is direction-finding kit sitting in the middle of its own
  denial, not a sentry with eyes on - and it makes the rule legible, which a
  visibility check never is.
- **Hostility is `getFriend`, not a side comparison**, so a mission that sets
  west and independent friendly does not have allies shelled.
- **The dwell clock resets the moment the field is empty**, so crossing quickly
  is free and working inside one is not. That is the whole trade the delay buys.
- **It fires at the last known position, scattered** - where the detection was,
  not where the target is now. Moving is the counter. A mission that lands
  exactly on a moving player is not artillery.
- **It targets the man nearest the emitter**, because a site defends itself
  first.
- **It dies with the emitter.** Destroyed or hacked, the handler removes itself.

The mission goes through `EFUNC(common,fireBarrage)` - a virtual battery, no gun
on the map - spread over a third of the delay so the first round is a warning
the rest are coming.

**Removed:** `functions/fnc_spawnObjectiveJammers.sqf` and its PREP. It read a
commander's objective list off the adapter and spread emitters over a share of
it, which is why the mission maker could choose how many and never where, and
why Zeus could not place one at all.

**Changed:**
- `fnc_spawnJammerSite.sqf` - the `EFUNC(adapter_alive,registerSite)` block that
  registered the GPS uplink as an ALiVE objective.
- `fnc_moduleController.sqf` - the `EGVAR(adapter_alive,ready)` gate and its
  event fallback; it calls `FUNC(start)` directly now. `objectiveShare`,
  `maxPerSide` and `siteObjectives` reads gone with their attributes.
- `fnc_start.sqf` - places nothing; it starts the prune and that is all.
- `fnc_spawnGpsUplink.sqf` - **returns `[id, sphereId, uplinkObject]`** where it
  returned two. The module hangs the artillery reply on the emitter and the
  uplink is an emitter like any other.
- `CfgVehicles.hpp` - `ghostD_moduleJamming` loses Objectives With Jammers, Max
  Jammers Per Side and Masts Are ALiVE Objectives. It is the global tuning now -
  radius bounds, burn-through, the GPS domain - and places nothing.
- `config.cpp` - `ghostD_adapter_alive` out of `requiredAddons`, and `units[]`
  now lists **both** modules.

**A bug found in `units[]` on the way.** It read
`units[] = {"ghostD_moduleJamming"}` and I first "fixed" it to
`QGVAR(moduleJamming)` - which expands to `ghostD_jamming_moduleJamming`, a class
that does not exist, and left BOTH modules unlisted. These two carry no component
in their names. Literal strings, with a comment saying why.

**Contract:** a mission using the old ALiVE spawner gets no jammers until it
places Jammer Site modules. That is the point of the change, but it IS a
migration: an existing mission with the Jamming module alone now has jamming
switched on and no emitters. `QGVAR(objectiveShare)`, `QGVAR(maxPerSide)` and
`QGVAR(siteObjectives)` no longer exist.

**Checked:** `hemtt check` - 69 configs, 921 sqf, clean at every level. **Not run
in game**, and this one wants it: the module arming handshake, whether a `gps`
site builds both the uplink and the sphere, and above all whether the artillery
reply is survivable at the shipped 90s/120m/8 rounds. Those numbers are a first
guess at a feel, not a tuned answer.

### TAC//SUPPORT removed, and ambience off the adapter
**Sync:** `careful`. The ambience half is `yes` and improves on ALiVE - the
engine answers "who is hostile to these players" directly. Removing TAC//SUPPORT
is a DIVINER decision: `ghost` keeps ALiVE and keeps a working support screen, so
do not carry the deletion over unless ghost is losing ALiVE too.

**TAC//SUPPORT, removed entire.** It was ALiVE Combat Support's front end and had
no other backend. It comes back later as an integration with Simplex Support
Services when that is present, which is a different system and a different
screen - keeping a dead one in the meantime would only teach players it does
nothing.

Removed: `addons/tacpad_apps/functions/fnc_appSupport.sqf` (the app, ~1000
lines), `addons/tacpad_apps/dialog.hpp` (`QGVAR(supportDlg)`, its own dialog -
the map control needed a real one), the `PREP`, the `registerApp` call, the
`QEGVAR(adapter_alive,supportAck)` handler, the SUPPORT tile and its entry in
the tile order in `fnc_tileData.sqf`, the `QGVAR(supportTag)` setting, the
`class RscText;` forward declaration that only the dialog used, and the
`{"support", "true"}` line from the `fnc_roleTiles.sqf` example.

Kept: `FUNC(ammoState)`, which reads as support-only and is not -
`FUNC(appSquad)` calls it for the squad rail's ammo swatch.

**ambience, off the adapter.** `FUNC(kamikazeModule)` walked
`EFUNC(adapter_alive,commanders)` on its first tick and took the side of the
first commander at war with the players. There are no commanders now, and the
question was never really about them: it is "who is fighting these players",
which `getFriend` answers directly, in three comparisons, with no dependency.
The module's own Side field overrides it either way, as before.

**Contract:** the `support` app id no longer resolves - a role config with
`{"support", "true"}` in its `tiles[]` now names a tile that does not exist.
Harmless (unknown ids are skipped) but worth sweeping from mission configs.
`QGVAR(supportTag)` is gone from Addon Options.

**Where the adapter stands.** Two consumers left, from nine:

| Addon | References | Next |
|---|---|---|
| `hacking` | 51 | Zeus/3DEN intel package, share size a setting, delivered to the TAC//PAD app |
| `jamming` | 6 | a standalone Zeus and 3DEN module - range, spectrum and the rest defined by Zeus or the mission maker, with an artillery reply if the jammer is detected |

`jamming`'s `requiredAddons` is still the only hard dependency on
`ghostD_adapter_alive` anywhere, so it is what keeps the addon in the build.

**Checked:** `hemtt check` - 69 configs, 920 sqf files, clean at every level.
Not run in game. One thing to watch: the SUPPORT tile leaving the band changes
the tile order, so a client with a saved tile layout may want a look.

### hacking: the Intrusion Tablet dialog is gone, the TAC//PAD app is the interface
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite. `ghost` has the same
duplicate screen.

**Files removed:** `addons/hacking/tablet.hpp`, `tablet.inc.hpp`,
`functions/fnc_tabletOpen.sqf`, `fnc_tabletLayout.sqf`, `fnc_tabletRefresh.sqf`,
`fnc_tabletTick.sqf`, `fnc_tabletClosed.sqf`, and
`addons/tacpad_apps/functions/fnc_themeTablet.sqf`. Six fewer sqf files in the
build.

**Files edited:** `addons/hacking/config.cpp` (the `tablet.hpp` include),
`XEH_PREP.hpp` (five PREPs), `script_component.hpp` (the `tablet.inc.hpp`
include and the dialog's IDC block), `XEH_postInit.sqf` (the `hack.tablet` debug
command), `fnc_tabletAction.sqf` / `fnc_tabletSelectDevice.sqf` /
`fnc_tabletSelectIntel.sqf` (the refresh calls into a display that is not there
any more); `addons/tacpad_apps/script_component.hpp` and `XEH_postInit.sqf` and
`XEH_PREP.hpp` (the include, the `tabletOpened` handler, the PREP).

**Why:** there were two interfaces to one system. `EFUNC(tacpad_apps,appHack)`
already draws intrusion inside the tacpad and calls this addon's own functions to
do it - its header says so: *"it used to close the map and hand off to the
suite's own display, which is the one screen in the tacpad that looked like a
different mod."* The dialog it replaced was still in the build, still PREP'd,
still reachable, and `tacpad_apps` still carried its control ids so it could
repaint it. One screen, one place.

**What is NOT gone:** the logic. `scanDevices`, `canHack`, `intelOptions`,
`tabletAdvance`, `tabletAction`, `tabletSelectDevice`, `tabletSelectIntel`,
`tabletInRange` all stay - the app calls every one of them. Their names still say
"tablet" and now mean "the hack session"; renaming them is a separate change and
a wide one.

`TAB_CARDS` (6) and `TAB_INTEL` (9) also stay, moved out of the dialog's IDC
block into `script_component.hpp` proper. They read as control-slot counts and
are not: `FUNC(scanDevices)` truncates its device list to the first and
`FUNC(intelOptions)` its product list to the second, so they are limits on what
a hack may offer.

**AND THE ITEMS ARE GONE TOO.** `QGVAR(terminalItem)` ("Intrusion Tablet") and
`QGVAR(scannerItem)` ("Signal Scanner") are deleted from `CfgWeapons.hpp` and
from `CfgPatches`'s `weapons[]`. They were kit for a gate that does not exist:
nothing in the mod ever asked whether a man carried either. `FUNC(canHack)` reads
the ISR trait through `EFUNC(common,isISR)`, and `FUNC(hasScanner)` reads a unit
variable that **defaults true**. Both classes appeared in exactly one place in
the entire mod - that `weapons[]` line - so they were arsenal furniture implying
a requirement the code had already stopped enforcing.

A loadout or arsenal list naming either class now names nothing. That is the cost
and it is the point: training is the gate, and an item cannot express that.

The three intel classes and the drop item stay - `intelItem`, `intelMap`,
`intelGps` are what a hack *produces* and `FUNC(searchBody)` spawns them;
`dropItem` is a thing you physically place. Those are not devices.

**Contract:** `EGVAR(hacking,tabletOpened)` no longer fires and nothing listens
for it. `FUNC(tabletOpen)` and the four other removed functions were called from
nothing but each other and the debug command.

**Documentation:** `wiki/Custom-Traits.md` is **new** - how to add, remove and
edit the flags that decide what a man may do, both `traits[]` and
`customVariables[]`, since they are the gate now that the items are not. It
covers the syntax (everything is a string, including the booleans), the order
`FUNC(setupPlayer)` applies them in, the trap that only variables *this system*
set are cleared between roles, which flags the mod itself reads, and that the
`isISR` and scanner variable NAMES are Addon Options so a mission can point the
mod at its own naming. Linked from `_Sidebar.md` and from `Roles.md`.

**Checked:** `hemtt check` - 69 configs, 921 sqf files, clean at every level. Not
run in game; the app was already the live path, so what wants confirming is only
that nothing reached the dialog by a route this did not find, and that no shipped
loadout named the two deleted item classes.

### five addons let go of the ALiVE adapter
**Sync:** `careful` - port all of it, but `ghost` keeps ALiVE, so each of these is
a decision about ghost too, not a mechanical rewrite. The `respawn` half is
`yes` on its own terms: `FUNC(gearManaged)` answers the same question better
than the adapter did even where ALiVE is present.

**Why:** stripping ALiVE is the standing Outstanding item in SYNC.md. Nothing
outside `adapter_alive` ever named an ALiVE symbol directly - the count of raw
`ALiVE_*` references outside that addon is zero - so this is 20 adapter
functions behind one seam rather than a scattered rewrite. Five of the nine
consumers are now clear of it.

**Files and what each one lost:**

- `addons/curator/XEH_preInit.sqf` - the `isUav` block calling
  `EFUNC(adapter_alive,profileIgnore)` twice, on the object and on its crew's
  group. It existed because ALiVE profiled what Zeus placed, deleted the
  original and handed back a hull with an empty seat. Nothing does that now, so
  a drone Zeus puts down keeps its AI - which is how this behaved before ALiVE
  was in the mod at all.

- `addons/bft/functions/fnc_draw.sqf` - the whole virtual-friendlies pass, and
  `QGVAR(showVirtual)` with it. It drew a second faded marker set for forces
  ALiVE simulated without spawning. Nothing simulates them now, so every
  friendly on the map is a group the pass above already walked and a marker for
  anything else would be an invention. Leftover `QGVAR(vmarker)` markers are
  swept once, because a client that ran the old build still has them on screen.

- `addons/messaging/functions/fnc_srvForward.sqf` - **deleted**, with its
  `PREP`, its call in `fnc_srvSubmit.sqf`, and three settings:
  `QGVAR(aliveReports)`, `QGVAR(aliveLocality)`, `QGVAR(sitrepMarkerType)`.
  Forwarding a CONTACTREP as an ALiVE spotrep and a SITREP as an ALiVE sitrep
  was the file's entire job. **The report templates are untouched** - they live
  in `templates.inc.sqf` and never knew about any of this. A reportable message
  is still composed, still submitted, still threaded; it just has nowhere
  external to go.

- `addons/groups/functions/fnc_setupPlayer.sqf` +
  `addons/respawn/functions/fnc_gearManaged.sqf` (**new**) - the "is something
  else dressing this man" check moved to the addon that does the dressing. It
  asked `EFUNC(adapter_alive,respawnGearManaged)` whether ALiVE's multispawn was
  restoring gear; it now asks `EFUNC(respawn,gearManaged)`, which answers
  whether the mission actually selected `QGVAR(default)` from
  `CfgRespawnTemplates` - checking `respawnTemplates` and all four per-side
  lists, because a one-sided op commonly sets only `respawnTemplatesWest`. The
  question outlived ALiVE: two systems dressing a respawn strip each other and
  the player arrives naked. Guarded with `isNil` rather than declared in
  `requiredAddons`, matching the curator and ACRE calls three lines below it -
  a build without `respawn` dresses the man in `groups` rather than not at all.

- `addons/common/functions/fnc_taorGate.sqf` - both `taorFor` blocks. One asked
  ALiVE for a side's own TAOR when the caller passed none; the other walked
  every other commander's TAOR to build the foreign ground that bounds a side
  which declared nothing. The caller's markers are the whole answer now. **The
  function itself stays** - `ambience` gates the kamikaze spawn and its building
  picker on explicit markers, which has nothing to do with ALiVE - so this is
  the ALiVE half removed, not the gate. Once the kamikaze module carries its own
  resizable area, those two callers may not need it either.

**Contract:** `EFUNC(respawn,gearManaged)` is new and public. `QGVAR(showVirtual)`
(bft) and the three `messaging` alive settings are gone - a profile carrying them
is harmless, they are simply no longer read. `FUNC(srvForward)` is gone from
`messaging`; nothing outside it called it.

**Still on the adapter**, and each has a decision attached rather than a
deletion:

| Addon | Functions | Where it is going |
|---|---|---|
| `hacking` | 11 | a Zeus-defined intel package; how large a share one hack yields becomes a setting |
| `jamming` | 4 | a Zeus and 3DEN module the mission maker or Zeus places, with settings |
| `tacpad_apps` | 3 | TAC//SUPPORT comes out for now and is remade later |
| `ambience` | 1 | a Zeus and 3DEN module with a resizable area |

`ghostD_adapter_alive` is still in `jamming`'s `requiredAddons` - the only hard
dependency on it anywhere - so the addon cannot be deleted until the jamming
module lands.

**Checked:** `hemtt check` - 69 configs, 927 sqf files, clean at every level.
**Not run in game.** Worth watching: that a respawned player is dressed exactly
once (the `gearManaged` answer is the one thing here that changes behaviour
rather than removing it), and that no leftover BFT virtual markers survive a
mission change.

### groups: the role list selection no longer paints itself the light scheme's red
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite, and `ghost` has the
same six values.

**Files:** `addons/groups/gui.hpp` - `RscGhostTree`, the six `colorSelect` /
`colorMarked` entries and the comment above them.

**Why:** all six were `{0.85, 0.28, 0.20, 1}`, the light scheme's red, hardcoded.
The screen's every other colour comes from `EFUNC(tacpad,theme)` at runtime, so a
player on Olive got a red selection, one on Sand got a red selection, and one on
a custom blue accent got red in the middle of a blue screen. The file's own
comment already admitted this and argued it was one row of one control; with
`custom` accents in the settings it is any colour at all against any other.

**What changed:** the selection carries no hue. `colorSelect` and the two
`colorMarked` text entries are the tree's own ink `{0.90, 0.90, 0.88, 1}`;
`colorSelectBackground` is that ink at `0.14` and the marked backgrounds at
`0.07`. The row lifts, the text stays what it was, nothing contradicts the
accent. `colorBackground` on this tree is a hardcoded dark `{0.07, 0.07, 0.07, 1}`
on every scheme, so an ink lift is the right direction on all six and on a
custom one.

**Why not just make it follow the accent:** Arma has no runtime setter for a
tree's selection colours - that part of the old comment is correct. The one part
of a row a script can still colour is its icon, via `tvSetPictureColor`, and
tinting the selected row's icon would need its base colour back afterwards - ink,
dimmed ink for a taken role, or the accent for your own slot, all decided in
`FUNC(fillRoleTree)`. Reading it back with `tvPictureColor` does not survive
hemtt's SQF parser (`SPE2`), so doing it properly means `fillRoleTree` recording
what it painted rather than `onGroupMenuTvSelectChange` guessing. Left undone
and written into the comment.

**Unresolved, and it matters for judging this.** The values that were there
should have drawn red **text on no fill** - `colorSelectBackground` was already
`{0,0,0,0}` - and the repo's own listboxes agree on that reading of the two
properties (`adminpanel/ui/controls.inc.hpp:106` sets black `colorSelect` text
against a red `colorSelectBackground` fill; `vehicle/gui.hpp:252` does the same
inverted). The screenshot that prompted this shows a **solid red bar**, which is
not what that config should produce. Either the build in the screenshot predates
the current `gui.hpp`, or CT_TREE draws `colorSelect` as a fill where CT_LISTBOX
draws it as text. If it is the latter, this change gives a near-white bar with
near-white text on it and is worse, not better. **Look at it in game before
trusting it.**

**Contract:** none. Colour values only.

**Checked:** `hemtt check` - 69 configs, 927 sqf, clean at every level. Not seen
in game.

### main_menu: the three quick connect buttons are fifteen CBA settings
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite. The defaults are
ghost's own three servers either way, so the ported defaults need no change.

**Files:**
- `addons/main_menu/initSettings.inc.sqf` - **new**. Fifteen settings, all
  client-side, category `["Ghosts of Battle", "Main Menu"]`.
- `addons/main_menu/functions/fnc_cacheServers.sqf` - **new**. Mirrors them into
  `profileNamespace`.
- `addons/main_menu/XEH_mainDisplay.sqf` - **new**. Names, points and hides the
  buttons on display load.
- `addons/main_menu/RscDisplayMain.hpp` - `onButtonClick` gone from all three,
  `idc` added to each, and a width expression fixed.
- `addons/main_menu/script_component.hpp` - `IDC_QUICKCONNECT_LEFT` / `_CENTRE`
  / `_RIGHT`, 657010-657012.
- `addons/main_menu/CfgEventHandlers.hpp` - `RscDisplayMain` display handler.
- `addons/main_menu/XEH_PREP.hpp`, `XEH_preInit.sqf` - the new function, the
  settings include, and the profile seed.
- `addons/main_menu/config.cpp` - `ghostD_common` added to `requiredAddons`.

**Why:** each button carried its whole connection in a config string, and its
name in a text property:

    text = "Ghosts Operations Server";
    onButtonClick = "connectToServer ['104.243.43.232', 2302, 'Ghosts'];";

Moving a server was an edit and a PBO, and a unit running its own servers could
not use the menu at all without forking the mod.

**What changed - the settings.** Five per button, nothing shared between them:
`QGVAR(serverNName)`, `QGVAR(serverNAddress)`, `QGVAR(serverNPort)`,
`QGVAR(serverNPassword)` and `QGVAR(serverNColour)` for N of 1, 2, 3. Three
servers on three different boxes with three different passwords is the ordinary
case rather than something to work around. EDITBOX except the colour, which is
CBA's `COLOR` type so it gets a picker rather than a string to typo. All
client-side - there is no server to enforce them from, which is the entire
situation. Written out one call at a time rather than through a macro: fifteen
plain blocks are longer than a macro and easier to read one of.

The file declares settings and nothing else. The mirroring is wired in
`XEH_preInit.sqf` on a single `CBA_SettingChanged` handler filtered on the
`QGVAR(server)` prefix, rather than the same `onChange` block copied into all
fifteen - a settings file has no business knowing what reads it.

| Slot | Button | Name | Address | Port | Password | Colour |
|---|---|---|---|---|---|---|
| 1 | left | Ghosts Training Server | 104.243.43.232 | 2402 | Gh0sts | #CC4331 |
| 2 | centre | Ghosts Operations Server | 104.243.43.232 | 2302 | Gh0sts | #CC4331 |
| 3 | right | Ghosts Development Server | 104.243.43.232 | 2502 | Gh0sts | #CC4331 |

The colour is the button's background, applied with `ctrlSetBackgroundColor`.
The hover colour is left as Arma's own - a button that has to be told what it
turns into as well as what it is has two settings where one will do.

**Numbered by position, not by server.** 1 is the left button, 2 the centre, 3
the right. A name is a setting now and can say anything, so the side of the
screen is the only stable thing to key on - which is also why the IDCs are
`_LEFT` / `_CENTRE` / `_RIGHT` rather than named after the servers that happen
to ship in those slots. The config class names still say `_main` / `_train` /
`_events`; they record what shipped where, not what a button says now.

**An empty address or a port of 0 hides that button.** That is the "if server is
null, skip" case and it is not an error path - a unit with one server should see
one button, and a build pointed at nothing should see none. Ports are validated
to 1-65535, so a typo removes a button rather than dialling nowhere. An empty
**name** is different: it leaves the config's `text=` alone, because a server
with no name is still a server.

**THE AWKWARD PART, AND WHY IT IS BUILT THIS WAY.**
`Extended_PreInit_EventHandlers` fires when a **mission** starts, not when the
game does. The main menu is drawn before any mission has ever run, so at the
moment these buttons need their values the CBA settings variables **do not
exist**. This is the same constraint SYNC.md records against `main_menu`
generally.

So the settings are where they are edited, and `profileNamespace` is where the
menu reads: `FUNC(cacheServers)` writes `QGVAR(servers)` - three entries of
`[name, address, port, password, colour]`, index 0 left to 2 right - on every
settings change and once at settings init via
`EFUNC(common,runAfterSettingsInit)`.
`XEH_mainDisplay.sqf` reads it back with the shipped three as fallback, so a
fresh install has working buttons before it has ever loaded a mission. **The
cost: a change in Addon Options reaches the main menu on the next launch, not
the current one.** For a server address that is the right way round.

One entry per button rather than parallel lists of names, addresses, ports and
colours: lists that have to stay in step stay in step exactly until somebody adds
a fourth server. The only thing the two sides now share is that index 0 is the
left button.

`XEH_mainDisplay.sqf` is a root script rather than a PREP'd function, matching
`XEH_multiplayerDisplay.sqf` beside it. The config handler body runs inside
`with uiNamespace do`, where a `FUNC()` is a variable lookup in a namespace the
functions are not in; `COMPILE_SCRIPT` compiles by path and asks nothing of any
namespace. Nothing inside it calls out to a `FUNC` for the same reason.

**Two things found on the way:**

1. **The width expression was malformed on all three buttons.**
   `w = "10 * pixelW * pixelGridNoUIScale * 2)"` - a closing bracket with no
   opening one, where the `x` beneath it is built as
   `... * (pixelW * pixelGridNoUIScale * 2)`. Now
   `w = "10 * (pixelW * pixelGridNoUIScale * 2)"`. The same arithmetic either
   way, so a syntax fix rather than a layout change, but it was an unbalanced
   expression sitting in three configs.
2. **The passwords were already in plain text** in the PBO, where anyone could
   read them. They are in the player's profile now, where anyone at that machine
   can. Being editable without a rebuild is the gain; being secret was never on
   offer, and that is written into the settings' own comment.

**Contract:** fifteen new client-side CBA settings. `ghostD_main_menu` now
requires `ghostD_common`, which it did not before -
`EFUNC(common,runAfterSettingsInit)` is the reason, and a missing EFUNC target
resolves to nothing rather than erroring, so the dependency has to be declared
or the failure is silent.

**Checked:** `hemtt check` - 69 configs, 927 sqf files, clean at every diagnostic
level including `help`. **Not run in game.** The profile-mirror design rests on
preInit not having run when `RscDisplayMain` loads; if that assumption is wrong
the buttons still work, they just take their values from a source that was
already correct. What wants watching on a real launch: that the display handler
fires for `RscDisplayMain` at all, that a renamed and recoloured button shows
both, and that an empty address hides its button. `COLOR` is a CBA setting type
this repo had not used before - nothing else in `addons/` declares one - so it is
worth confirming the picker appears rather than the setting failing to
register.

### loading: the addon is gone
**Sync:** `no` for the deletion - DIVINER dropping the loading screen is a
DIVINER decision, and `ghost` keeps its own. **But read the three entries below
this one before deciding that.** They are not cancelled by this: `ghost` still
has the addon, still ships the 23 images that cannot be shipped, and still has
the two null-config bugs. The licence cull in particular is `yes` and stays
`yes` - deleting the addon here removes DIVINER's exposure and does nothing at
all about ghost's.

**Files:** `addons/loading/` removed entire - 12 files plus `ui/loading/`.

**What it took with it:** `ghostD_loading` and its `CfgPatches`; the
`CfgLoadingScreen` background list; the `gui.hpp` background control on
`RscDisplayStart`, `RscDisplayLoadMission` and `RscDisplayNotFreeze`; the three
CBA settings (`QGVAR(enabled)`, `QGVAR(showCredit)`, `QGVAR(pinned)`, all
client-side, so no stored server value is orphaned); and the six background
plates. Arma's own loading screen is what players see now.

**Nothing depended on it.** No other addon named `ghostD_loading` in
`requiredAddons`, and nothing outside it referenced `CfgLoadingScreen`,
`IDC_LOADINGSTART_CUSTOM_BG` or `IDC_LOADINGSTART_LOADINGSTART`. The addon
required `ghostD_common` and was required by nobody.

`EFUNC(common,easterDate)` now has no caller anywhere in the mod. It is left in
`common` as a utility - it is twenty lines of arithmetic with no dependencies -
but it is dead code until something wants it.

**Left behind, deliberately, pending a decision:**
- `tools/art/gen_loading_screens.py` - its `INSTALL` path is a directory that no
  longer exists, so it writes PNG masters and then fails to install. The crop
  and grade logic is not loading-specific and is the only tooling here that
  converts photographs to a house look.
- `art/loading/` - the four PNG masters and `SOURCES.md`, the record of which
  US Army photograph each came from.
- `d:\Git\_DIVINER_unlicensed_art\` - the 23 quarantined images and `ghost.paa`,
  outside the repo. Still the only copy, since none of this was ever committed.

**Checked:** `hemtt check` - 69 configs, 925 sqf files, **no warnings at all**.
The three seasonal-logo File Missing warnings went with the file that named
them.

### loading: settings, one plate per load, and three bits of dead weight
**Sync:** `yes` - straight `ghostD_` to `ghost_` rewrite. Depends on the two
loading entries below it; port those first or the settings list is built from a
config full of images that should not be there.

**Files:**
- `addons/loading/initSettings.inc.sqf` - **new**. Three settings, all
  client-side, category `["Ghosts of Battle", "Loading"]`.
- `addons/loading/XEH_preInit.sqf` - **new**. The addon had none.
- `addons/loading/CfgEventHandlers.hpp` - `Extended_PreInit_EventHandlers` added
  so that preInit runs at all. The comment on the display handler now says why
  one handler on `RscDisplayLoading` covers all three dressed displays.
- `addons/loading/CfgLoadingScreen.hpp` - the `Noise` subclass dropped from
  `LOADING_SCREEN_CLASS`.
- `addons/loading/XEH_loadingDisplay.sqf` - the rest.

**What changed:**

**1. Settings, and the reason they are read the awkward way.** `QGVAR(enabled)`
(CHECKBOX, true) turns the whole dressing off and leaves Arma's loading screen
alone. `QGVAR(showCredit)` (CHECKBOX, true) is the credit line. `QGVAR(pinned)`
(LIST, default `""` = random) forces one plate, which is what a screenshot or a
look at a new crop actually wants. The LIST values are built from
`configClasses` at preInit, so a plate added to `CfgLoadingScreen` appears in
the menu with no second edit - the same rule the class name and the filename
already follow.

Every read is `missionNamespace getVariable [QGVAR(x), <default>]`, not the
GVAR. **The first loading display a player sees is the game booting**, which is
before CBA settings exist; reading the GVAR directly would be nil there, and nil
is not false. All three are client-side: what is on somebody's own loading
screen is theirs.

**2. One plate per load, not one per launch.** The pick was cached in
`uiNamespace` and never cleared, so a player saw one background until they
restarted Arma - which mattered little at two plates and matters at six.
`QGVAR(backgroundAt)` now records `diag_tickTime` at the pick and anything older
than 30 seconds re-rolls.

**A cooldown rather than an unload handler**, deliberately. Clearing the cache
on display unload re-rolls correctly between loads, but it also re-rolls if the
display bounces during one, and a stutter would flick the picture. Thirty
seconds is longer than any such bounce and far shorter than the gap between two
real loads, so it separates them without needing to know which display did what.
A pinned plate skips the cache entirely - a pin that only took effect after a
restart would be useless for its own purpose.

**3. The `Noise` subclass was dead config.** Every background class carried
`class Noise { text="\A3\Ui_f\...\LoadingNoise_ca.paa"; }` and nothing ever read
it: the grain on screen comes from `gui.hpp`'s own `GVAR(lines)` control, which
inherits Arma's `Noise` directly. Three lines per plate that looked
load-bearing and were not.

**4. The credit is positioned against its parent, not the screen.** The label is
a child of the `LoadingStart` group, so its x is measured from that group's left
edge - and it was right-aligned with `safeZoneW`, which is only the same number
while the group happens to span the whole safe zone from zero. It now asks the
group its width with `ctrlPosition`. Not a live bug; a latent one.

**5. Two small ones.** `systemTime select 1` was read twice - the mark switch and
the Easter check - and is now hoisted to `_month`. The label says `Photo:` rather
than `Author:`, which is what the field now holds.

**Contract:** three new CBA settings, all client-side. No function renamed or
added. `ghostD_loading` gains a preInit it did not have; nothing else depends on
it.

**Checked:** `hemtt check` - 927 sqf files, 70 configs, and the same three
seasonal-logo File Missing warnings as before, nothing new. **Not run in game**,
and three things here want a real load to confirm: that the 30-second cooldown
separates loads the way it should, that `ctrlPosition` on the group returns what
the label needs, and that the settings read as their defaults on the boot
display before CBA has initialised.

### loading: four replacement backgrounds, and the tool that makes them
**Sync:** `careful` - the four plates and `tools/art/gen_loading_screens.py`
port as they are, but only on top of the licence cull in the entry below. Do
not carry these into a `ghost` that still has its 23; the point of the set is
that it is the whole set.

**Files:**
- `addons/loading/ui/loading/` - `airdrop.paa`, `flares.paa`, `tank.paa`,
  `mk47.paa`. 2048x1024 DXT1, 9 mipmaps, matching the two survivors.
- `addons/loading/CfgLoadingScreen.hpp` - four `LOADING_SCREEN_CLASS` lines. The
  rotation goes from 2 to 6.
- `tools/art/gen_loading_screens.py` - **new**. Crop, grade, convert, install.
- `art/loading/` - **new**. PNG masters plus `SOURCES.md`, the per-plate source
  and licence record.
- `addons/loading/XEH_loadingDisplay.sqf` - rewritten, no behaviour change.

**Why:** two backgrounds is not a rotation. The user supplied four photographs;
they are 1920x1280 and 1920x1255, in colour, and the set they are joining is
2048x1024 and grey.

**What changed - the tool.** `SOURCES` at the top of the script is the entire
input: source filename, class name, credit. Everything else is mechanical.

- **The class name is the output filename**, because `CfgLoadingScreen` builds
  the texture path out of the class name. Naming them in one place is what stops
  the two drifting apart.
- **The crop is chosen by detail, not by centre.** A 3:2 photograph loses a
  third of its height going to 2:1 and the interesting third is rarely the
  middle, so the 2:1 window with the most edge energy wins, pulled 35% back
  towards centre so it cannot end up hard against an edge. On `tank` that keeps
  the turret and drops the mud; a centre crop took both halves of neither.
- **The grade is measured off the two survivors** - black point 3, white point
  215, mean 92 - and every plate is stretched onto it: 1st and 99th percentile
  to the black and white points, then one gamma solve onto the mean. No search,
  no eyeballing. `airdrop` is the case that sets the gamma clamp at 2.6: a flat
  overcast sky needs 2.49 to come down from mean 125 into family, and the solve
  converges there, so a looser clamp changes nothing for anything else.

Results: `airdrop` mean 96, `flares` 90, `tank` 92, `mk47` 95, against the
survivors' 44 and 116. `hemtt utils paa convert` does the conversion - HEMTT is
already installed and Arma Tools is not needed.

**Contract:** none. `hemtt check` still shows only the three seasonal-logo File
Missing warnings.

**LICENCE - SETTLED.** All four are works of the US federal government and carry
no copyright. Confirmed against their Wikimedia Commons file pages, which report
`LicenseShortName: Public domain` and `AttributionRequired: false` for each, and
name the photographer:

| Plate | `author` = | Source |
|---|---|---|
| `airdrop` | Pfc Eun Jun Choi - U.S. Army | DVIDS 9328915 |
| `flares` | Staff Sgt. Reginald Harvey - U.S. Army | DVIDS 9329611 |
| `tank` | Staff Sgt. Reginald Harvey - U.S. Army | US Army 250920-A-AR378-1199 |
| `mk47` | Sgt. Devon Bistarkey - U.S. Army National Guard | DVIDS 5709166 |

The Ground Forces Festival is a Republic of Korea event, which is why these read
as Korean material at first glance - but the photographers covering it are US
Army, so the images are US public domain. Attribution is not required; the
credits are printed anyway. The one live constraint is that DoD imagery must not
be used so as to imply DoD endorsement. `art/loading/SOURCES.md` carries the
per-plate record.

**A credit cannot contain a comma.** It is a `LOADING_SCREEN_CLASS` argument, so
"Sgt Bloggs, U.S. Army" arrives as two macro arguments and the class does not
build. The credits above use a dash, and the macro's comment now says so.

The two survivors still say "Ghosts of Battle", which should name whoever took
them.

**Checked:** `hemtt check` clean bar the three known warnings; `hemtt utils paa
inspect` confirms DXT1 and 9 maps on the new plates. The addon is 6.3 MB with
six backgrounds, against 22 MB with twenty-six. Not seen in game.

### loading: unlicensed backgrounds removed, seasonal logos wired up, two null-config bugs fixed
**Sync:** `yes` - and not optional. `ghost` ships the same 23 images under the
same filenames, so it carries the same exposure until the same removal is made
there. Straight `ghostD_` to `ghost_` rewrite otherwise.

**Files:**
- `addons/loading/ui/loading/` - 23 `.paa` removed, plus `ghost.paa`. Two kept:
  `maxresdefault.paa` and `S291207115895.paa`. The addon goes from 22 MB to
  1.9 MB; `ghostD_loading.pbo` was 21.2 MB of a 55.8 MB release archive.
- `addons/loading/CfgLoadingScreen.hpp` - 26 `LOADING_SCREEN_CLASS` entries down
  to the 2 that have a file. The macro is unchanged; the header now says what
  may go in the list and that the second argument is a printed credit.
- `addons/loading/XEH_loadingDisplay.sqf` - the seasonal switch finished, two
  null-config bugs fixed. Below.

**Why - the images:** 23 of the 26 loading screens are not ours to ship. The
filenames say where they came from: `maxresdefault.paa` is the filename YouTube
gives a video thumbnail, and the long numeric names are stock-library IDs. Only
`maxresdefault.paa` and `S291207115895.paa` are cleared, per the user. They are
**moved, not deleted** - to `d:\Git\_DIVINER_unlicensed_art\loading`, outside
the repo, because this repo has no commits yet and a delete here has no git
history to come back from. `ghost.paa` went to the `orphan` folder beside it:
512x512 where every background is 2048x1024, and no class in
`CfgLoadingScreen`, so it shipped in the PBO and was never drawn.

**Why - the code:** three things, all inherited with the addon - one that was
never finished, and two that were broken.

1. **The seasonal logo switch never fired.** `switch (_month)` had four branches
   - October, December, Easter, default - and every one of them ran the same
   `_picture ctrlSetText QPATHTOEF(media,images\logo_2048.paa)`. The switch was
   right; the seasonal pictures were simply never drawn. **It stays**, and each
   branch now names the file it wants - `logo_2048_halloween.paa`,
   `logo_2048_christmas.paa`, `logo_2048_easter.paa` in `media\images\` - behind
   a `fileExists` test that falls back to the year-round logo until that file is
   there. Making a season live is dropping a `.paa` in under the right name: no
   code change, no rebuild of this addon. The `fileExists` guard is not
   decoration - `ctrlSetText` on a texture that does not exist draws Arma's
   error texture full-screen. The `easterDate` call moved into its `case`, so it
   is evaluated only in the months that are not October or December.

   This leaves **three `L-C32` File Missing warnings** on `hemtt check`, one per
   undrawn logo. They are accurate and they clear themselves the moment the art
   lands; silence them with a `[sqf.file_missing]` ignore in `.hemtt/lints.toml`
   if the noise is worse than the reminder.
2. **The Easter background resolved to nothing.** `_backgroundCfg =
   CFG_LOADING_SCREEN >> "Backgrounds" >> "bunny"` - there is no `bunny` class in
   `CfgLoadingScreen` and there never was. In the Easter month, half the time,
   that gave a config path that does not exist: `getText (_backgroundCfg >>
   "path")` returned `""`, so the background was blank and the credit line read
   `Author: ` with nothing after it. For a month a year, on a coin flip. Now
   guarded with `isClass`, and the `easterDate` call sits inside the guard, so
   with no bunny art the sum is never done at all.
3. **An empty `Backgrounds` class would have errored.** `selectRandom []` is
   `nil` and `nil >> "path"` is an RPT error on every loading screen - which the
   list shrinking from 26 to 2 turns from hypothetical into one bad edit away.
   It now leaves Arma's own background in place and still draws the logo. Same
   treatment for an empty `author`: no credit line rather than a bare "Author:".

**Contract:** none. Nothing renamed, no setting added, no new dependency.
`EFUNC(common,easterDate)` now has no caller outside that guard - left in
`common` as a utility rather than deleted.

**Ghost notes:** the 23 filenames are listed in
`d:\Git\_DIVINER_unlicensed_art\loading`; delete the same names from
`ghost\addons\loading\ui\loading` and cut the matching `LOADING_SCREEN_CLASS`
lines. The three code fixes apply unchanged.

**Still open:** replacement art. Two backgrounds is a thin rotation, and the
`author` field on both still says "Ghosts of Battle", which should name whoever
actually made them.

**Checked:** `hemtt check` - clean, 926 sqf files, 70 configs. Not run in game;
the empty-`Backgrounds` path and the credit-line suppression are the two worth
watching on a real load.

### medbags: bag contents, fill order and overflow moved to CBA settings
**Sync:** `careful` - port the whole change, but the `GHOST_Apap` line below is
a DIVINER-only drop. In `ghost`, `GHOST_Apap` exists, so put it back in the
three default strings at its original position and count: Boo Boo Bag
`GHOST_Apap:2` last, Medic Bag `GHOST_Apap:4` between `ACE_tourniquet:4` and
`ACE_suture:12`, Trauma Kit `GHOST_apap:6` last (lower-case `a` in the original
- either case works, the class lookup is the game's). Otherwise a straight
`ghostD_` to `ghost_` rewrite.

**Files:**
- `addons/medbags/initSettings.inc.sqf` - **new**. Seven settings, all
  server-enforced (`isGlobal` true), category `["Ghosts of Battle", "MedBags"]`.
- `addons/medbags/functions/fnc_issueContents.sqf` - **new**. Parses a list and
  issues it.
- `addons/medbags/XEH_PREP.hpp` - `PREP(issueContents);`.
- `addons/medbags/XEH_preInit.sqf` - rewritten to the house idiom: `ADDON =
  false;`, `PREP_RECOMPILE_START`/`END` around the PREP include, `#include
  "initSettings.inc.sqf"`, `ADDON = true;`. It previously had no `ADDON` guard
  and no settings include at all.
- `addons/medbags/functions/fnc_doUnpackFirstAid.sqf`,
  `fnc_doUnpackMedicKit.sqf`, `fnc_doUnpackTrauma.sqf`, `fnc_doUnpackFluid.sqf`,
  `fnc_doUnpackDrugKit.sqf` - the success branch's column of `addItem` calls
  replaced by one `[_unit, GVAR(contents<Bag>)] call FUNC(issueContents);`.
  Nothing above the branch changed: same progress bar, same sounds, same
  `ghost_MEDICAL_SUPPLIES_UNPACK_SUCCESS` / `_FAILURE` globals, same
  `_unit removeItem "ghostD_medbags_<Bag>"`.
- `addons/medbags/functions/fnc_doTake.sqf` - the hardcoded `[1, 2, 3], true`
  on the handover `addItem` now reads the same two settings.
- `addons/common/functions/fnc_addItem.sqf` - **header comment only**, no code.
  Argument 3 was documented `[0 = Uniform, 1 = Vest, 2 = Backpack]`; the switch
  it documents is `0` cargo, `1` uniform, `2` vest, `3` backpack. Every caller
  in the repo passes the real codes, so nothing was acting on the wrong doc, but
  it is the doc the new Fill Order setting is written against.

**Why:** changing how many field dressings a Trauma Kit holds meant editing SQF
and shipping a PBO, for a number. Five functions each carried their own column
of `EFUNC(common,addItem)` calls - thirteen of them in the Medic Bag - and each
carried its own `private _order` and `private _overflow` that no code outside
the function ever read. `SYNC.md` had this as an Outstanding item.

**What changed:**

Settings (all `QGVAR`, so `ghostD_medbags_*`):

| Setting | Type | Default |
|---|---|---|
| `QGVAR(contentsFirstAid)` | EDITBOX | `ACE_fieldDressing:6, ACE_quikClot:6, ACE_tourniquet:2, ACE_EarPlugs:1, ACE_salineIV_500:1, ACE_splint:1` |
| `QGVAR(contentsMedicKit)` | EDITBOX | `ACE_fieldDressing:18, ACE_elasticBandage:14, ACE_packingBandage:14, ACE_quikClot:14, ACE_salineIV_500:8, ACE_tourniquet:8, ACE_splint:8, ACE_fieldDressing:6, ACE_tourniquet:4, ACE_EarPlugs:2, ACE_plasmaIV_500:4, ACE_tourniquet:4, ACE_suture:12` |
| `QGVAR(contentsTrauma)` | EDITBOX | `ACE_fieldDressing:28, ACE_elasticBandage:24, ACE_packingBandage:24, ACE_quikClot:24, ACE_salineIV:12, ACE_tourniquet:12, ACE_splint:12, ACE_fieldDressing:24, ACE_tourniquet:10, ACE_EarPlugs:2, ACE_plasmaIV:8, ACE_tourniquet:12, ACE_suture:24, ACE_surgicalKit:1` |
| `QGVAR(contentsFluid)` | EDITBOX | `ACE_salineIV:24, ACE_plasmaIV:12, ACE_bloodIV:8` |
| `QGVAR(contentsDrugKit)` | EDITBOX | `ACE_morphine:16, ACE_adenosine:8, ACE_epinephrine:8` |
| `QGVAR(fillOrder)` | LIST | `"3,2,1"` (index 0 of `["3,2,1", "1,2,3", "2,3,1", "2,1,3"]`) |
| `QGVAR(fillOverflow)` | CHECKBOX | `true` |

The defaults are the old hardcoded lists, item for item, in the original order,
**duplicates included**. Medic Bag names `ACE_fieldDressing` and
`ACE_tourniquet` more than once and Trauma Kit does the same; those repeats are
in the shipped code, they land in different containers as earlier ones fill, and
they were left alone rather than summed. Do not "tidy" them in the port.

`FUNC(issueContents)` takes `[unit, contents string]`, returns how many entries
it issued, and must be called from scheduled code - it keeps the original
`sleep 0.3` between items. It splits on `,`, then `:`, trims both halves,
`parseNumber`s the count, and skips an entry with a warning when it is not
`class:count`, when the count is below 1, or when the class is in neither
`CfgWeapons` nor `CfgMagazines`. That last check is why `GHOST_Apap` came up:
`addItem` never validated a class, `canAddItemToUniform` is false for one that
does not exist, so it fell through to the overflow branch, which built a
`GroundWeaponHolder`, put nothing in it and left it standing in the world.

**Behaviour changes** (three, all deliberate):
1. **The Boo Boo Bag now fills backpack-first.** It was the one bag with
   `_order = [1,2,3]`; the other four and `fnc_doTake` used `[3,2,1]`. One
   global setting cannot be both, and the majority won. Restore the old feel by
   setting Fill Order to "Uniform, vest, backpack" - but note that moves the
   other four bags too.
2. **`GHOST_Apap` is no longer issued** by the Boo Boo Bag, Medic Bag or Trauma
   Kit. It never actually arrived, so no player loses anything he was carrying;
   what stops is the empty ground holder each unpack could leave behind.
3. **Overflow is now switchable.** Off, kit that fits nowhere is not issued at
   all rather than dropped at the man's feet - and a bag taken off a casualty
   in `fnc_doTake` can then be lost, which the old ground fallback guaranteed
   against. Default is on, which is the old behaviour.

**Contract:** one new public-ish function, `ghostD_medbags_fnc_issueContents`.
Nothing renamed, nothing removed. No mission `config\` key is involved - these
are Addon Options, not mission config. No new addon dependency; `medbags`
already required `ghostD_common`.

**Also updated:** `SYNC.md` - the "medbags contents to CBA settings" Outstanding
item is done and gone, and `GHOST_Apap` is written up under Dropped.

**Not updated:** the wiki has no medbags page and no page listing Addon Options,
so there was nothing to amend. A page for the medical bags would be new work.

**Checked:** `hemtt check` - clean, 926 sqf files compiled, 70 configs rapified.
Not tested in game: the fill-order default change and the overflow-off path are
the two worth a look on a live server.

### Change notes rule added
**Sync:** no - repo process, and `ghost` is not the source of truth for it.
**Files:** `CLAUDE.md` (new), `CHANGES.md` (new).
**Why:** DIVINER's fixes go back to `ghost` by hand, and nothing recorded what
had changed since the `c47d7484` copy. SYNC.md covers the split itself but not
the work done after it.
**What changed:** CLAUDE.md now requires a CHANGES.md entry in the same turn as
any change under `addons/`, `include/`, `mod.cpp` or the build wiring, with
files, exact identifiers, symptom, contract changes, sync verdict and how it
was checked.
**Checked:** documentation only, nothing built.

---

<!-- Template - copy, fill, delete this comment's entry when the first real one lands.

### <what changed, in a few words>
**Sync:** yes | no | careful - <reason>
**Files:** `addons/<addon>/functions/fn_<name>.sqf` - <the function or block>;
`addons/<addon>/XEH_preInit.sqf` - <what>.
**Why:** <the symptom that was observed, in its own terms>
**What changed:** <the mechanism, naming every identifier a port must find:
functions, GVAR/QGVAR names, config classes, CBA setting keys, event names>
**Contract:** <renamed or removed public functions, anything a mission's
config\ sees, new dependencies between addons - or "none">
**Ghost notes:** <what the port needs beyond the prefix rewrite - files that
differ, addons ghost has that DIVINER does not>
**Checked:** hemtt check | in-game | not tested

-->
