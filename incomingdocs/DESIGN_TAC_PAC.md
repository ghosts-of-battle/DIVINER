# TAC//PAC — Design Handoff

Unit management app inside the TAC//APP suite (Arma 3). Planning doc for implementation — no code decisions here are final; anything marked **DECIDED** is.

Principle: **KISSS** — keep it simple, supportable, stupid. Supportable = easy backups, no hidden state, one place to configure.

---

## 0. Ground rules (DECIDED)

- Two datasets only: **Structure** and **Player data**. Nothing else persists.
- All configuration lives in `CfgGFA_PAC` (mission/config). **No CBA settings.**
- **No CBA dependency (DECIDED).** Vanilla plumbing only: `remoteExec`, `addMissionEventHandler` (PlayerConnected/HandleDisconnect/Ended), scheduled loops for attendance, `createHashMap`, `profileNamespace`. Do not import CBA macros or functions.
- Structure is files only. No in-game editing of structure.
- Player data references structure by **stable string IDs**, never names. Missing IDs are flagged, never dropped.
- Extension is optional at load. Missing → log warning, run local. Never block a mission on the network.
- No server is "master" in SQF. Sync roles are decided by files on disk, not by mission logic.
- Every exported JSON carries `schemaVersion`, `unitId`, `serverId`, `exportedAt`.

---

## 1. Datasets

### 1.1 Structure (`CfgGFA_PAC`)

| Section | Contents |
|---|---|
| `settings` | see §2 |
| `ranks` | `{id, name, abbrev, insignia, armaRank}` — `armaRank` required, one of PRIVATE..COLONEL. Many custom → one Arma rank allowed |
| `skills` | `{id, name, effects[]}` — effects: ACE medic/engineer/EOD class, custom traits (`isISR`, `isJFO`, Simplex gates), custom `setVariable` pairs |
| `awards` | `{id, name, type (award\|ribbon\|coin), image, campaign}` |
| `statuses` | enum of player status ids + display names (admin-set only) |
| `roles` | `{id, name, defaultSkills[], defaultLoadout, arsenalWhitelist, slotTag}` |
| `opords` | collection, one class per OPORD — see §1.3. History = whatever files are in the collection |
| `admins` | reuse framework admin list (reference, not a copy) |

Structure version = hash of the compiled sections. Shown in live tile; used by delta tool.

### 1.3 OPORD schema (DECIDED — modelled on the DPSO warning order, NOT the Army 5-para/annex format)

Plain strings unless noted. Keep it flat; no annexes, phases, CCIR.

| Section | Fields |
|---|---|
| header | `id`, `title`, `date`, `campaign`, `release`, `distribution`, `mapImage` (optional path), `markers[]` (plain marker names typed by the mission maker — no picker; viewer highlights them on the map if they exist) |
| situation | `overview`, `enemy`, `enemyFactions[]` (faction class ids), `friendly`, `civilTerrain`, `attachments[]` = `{callsign, assets[]}` |
| mission | `mission`, `execution` (optional free text) |
| adminLogistics | `admin`, `logistics`, `special`, `armaConsiderations` |
| commandSignal | `signal`, `command` |
| roe | `roeText`, `clarifications[]` |

Rendered in the PAC app OPORD viewer and posted to C2 at mission start via a fixed OPORD message template (one line per section).

### 1.4 METT-TC template (messaging system, leader → squad)

Registered as a normal message template (same title/lines/fields format as existing templates). Channel: SQUAD. Tag: `opordId` auto-filled from `currentOpord`. Every field has an **Add marker** control: a dropdown of current in-game map markers that inserts the selected marker name into the text (multiple allowed). The sent message carries the referenced marker names so recipients can jump to them on the map.

| Field | Type | Helper text |
|---|---|---|
| Mission | Text + markers | – |
| Enemy | Text + markers | – |
| Terrain and weather | Text + markers | OAKOC: observation & fields of fire, avenues of approach, key terrain, obstacles, cover & concealment |
| Troops and support available | Text + markers | – |
| Time available | Text | – |
| Civil considerations | Text + markers | ASCOPE: areas, structures, capabilities, organizations, people, events |
| ARMA considerations | Text | – |

Pre-fill (default, leader can overwrite): Mission ← OPORD `mission`; Enemy ← `enemy`; Civil ← `civilTerrain`; Troops ← `attachments` flattened to text.

### 1.2 Player data (`profileNamespace`, server)

| Key | Contents |
|---|---|
| `gfa_pac_players` | UID → `{name, rankId, groupId, roleId, skillIds[], awards[{awardId, date, by}], statusId, notes[{date, by, text}], loadouts{roleId → loadout}, updatedAt, serverId}` |
| `gfa_pac_sessions` | append-only `[{uid, join, leave, serverId, mission, opordId}]` |
| `gfa_pac_windows` | `[{id, start, end, opordId, source (manual\|config\|opord)}]` |
| `gfa_pac_meta` | `{schemaVersion, unitId, serverId, lastSave}` |

Records are last-writer-wins by `updatedAt`. Sessions never merge — append only, keyed by writing server.

---

## 2. Settings (`CfgGFA_PAC >> settings`)

```
class settings {
    unitId        = "ghostfa";
    serverId      = "srv1";        // unique per box
    schemaVersion = 1;
    skillSource   = "pac";         // role | pac
    autoSlot      = 1;             // 0 | 1
    slotMatch     = "role";        // role | slot
    savedLoadouts = 3;             // 0 = off, else cap per player
    currentOpord  = "";            // "" = latest by date
    opWindows[]   = {};            // fallback windows {dow, startUTC, endUTC} or {start, end}
    sync          = "off";         // off | local | folder | api   (phase 3)
    syncPath      = "";            // folder mode
    apiUrl        = "";            // api mode (public — key is NOT here)
};
```

Server-only auth (phase 3): `userconfig/gfa_atak/pac_sync.cfg` → `apiKey`, optional `apiUrl` override. Read by the extension only. Never in the mission.

---

## 3. Behaviour

### Mission start
1. Compile structure → hashmaps; compute structure hash.
2. Load player data; seed unknown UIDs on connect.
3. Orphan check: player refs to missing rank/skill/award/opord/role ids → flag in admin panel.
4. Post `currentOpord` to C2 (ROUTINE, all players) via messaging system.
5. If `autoSlot`: place by role (or slot), apply saved or role loadout, apply skills.
6. Start attendance loop.

### Skills
- One catalog. `skillSource = pac`: PAC assignments are the only source — a player with no assignment spawns with **no skills** until an admin assigns them (DECIDED). Admins adjust live, persisted. `role`: role defaults applied, PAC records only.

### Slotting / loadouts
- `slotMatch = role` recommended (tolerant of slot-count changes). `slot` = exact slot per player.
- Saved loadouts: `getUnitLoadout` per role, validated against `arsenalWhitelist` on load, capped.

### Attendance
- Sessions always recorded (connect/disconnect + 60 s heartbeat for crash safety).
- Op windows applied at **report time**, never at record time — a forgotten button is fixed after the fact.
- Window sources, precedence: manual (admin button) > config `opWindows[]` > "mission that ran OPORD X".

### OPORD / METT-TC
- OPORD = structure file. History = files in the collection. Deleted file → id shows "(archived)".
- METT-TC = squad/team leader template in messaging, sent to squad, tagged with `opordId`.
- METT-TC pre-fills from OPORD per §1.4.

### Admin / status
- Admins = framework admin list. Kick/ban via `serverCommand`; requires a logged-in admin context — check early.
- Status set by admins only.

---

## 4. Surfaces

| Surface | Access | Content |
|---|---|---|
| Admin panel → PAC | admins | roster edit, rank/skills/awards/status, notes, kick/ban, op window start/stop, export/import, orphan warnings, **Unassigned** filter (players with no skills/rank/role) |
| PAC app | all | own record, roster, awards, OPORD list + viewer, own attendance |
| Live tile | all | structure hash, current OPORD, players on, op window state |
| Messaging | leaders | METT-TC template |

Clients never write player data. Client → server via `remoteExec` to server-side admin functions that re-check admin status.

---

## Phase 1 — Single server

**Goal:** everything above, no extension, no network.

Deliverables:
1. `CfgGFA_PAC` schema + loader + structure hash.
2. Player data store (load/save/debounced `saveProfileNamespace`).
3. Admin panel PAC page; PAC app; live tile.
4. Skills (both modes), ranks (Arma rank mapping), awards, statuses, notes.
5. Auto-slot + saved loadouts.
6. Attendance sessions + windows + report.
7. OPORD post + viewer; METT-TC template registered with messaging.
8. **Backups:**
   - Auto: `diag_log` full player JSON between marker lines at mission end and op-window stop.
   - Manual: panel Export → `copyToClipboard` on admin client. Import → paste → per-record merge by `updatedAt`; "Restore full" checkbox for wipes.
   - Host: documented startup script that dates and copies `*.vars.Arma3Profile` before launch.
9. Delta tool v0: panel button dumps structure JSON + hash to clipboard/`.rpt`. Comparison is a website (out of scope here).

Exit criteria: two servers can be kept identical by copying files + pasting one export. No dependency beyond TAC//APP.

---

## Phase 2 — Performance / supportability

No new features. Targets:

| Area | Change |
|---|---|
| Saves | debounce `saveProfileNamespace` (e.g. ≥30 s between saves, plus mission end). Dirty flag per record; only dirty records rewritten in the hashmap → serialised once |
| Client sync | clients receive roster **deltas** keyed by `updatedAt`, not the full roster; full pull only on join. Live tile reads a small summary struct |
| Structure | compile once per mission; clients receive structure hash and fetch structure once, cache by hash |
| Attendance | heartbeat writes to memory only; session finalised on disconnect / mission end. Roll sessions older than N days into per-player totals locally (full history stays in exports) |
| profileNamespace size | cap loadouts, roll sessions, measure. Log store size at mission end |
| Admin actions | batch multi-select edits into one save |
| Logging | one `PAC:` log prefix, levels, store size + record count at start/end — this is the support tool |
| Recovery | import tested against phase-1 exports; `schemaVersion` migration path stubbed |

Exit criteria: no frame hitches on save; join cost is one message; store size stable over a month of ops.

---

## Phase 3 — Multi server

**Goal:** optional sync, same in-game behaviour in every mode.

### Sync modes

| Mode | Mechanism | Backup story |
|---|---|---|
| `local` | extension writes `pac_<unitId>_<serverId>_<date>.json` to `syncPath` | the folder |
| `folder` | as `local`, but reads every `pac_<unitId>_*.json` in the folder and merges; host syncs the folder with Drive/Dropbox/rclone/S3/git | the folder + provider versioning |
| `api` | extension HTTP client → sidecar service; sidecar is a file-backed store with an HTTP front, hosted on any box (a "main" server, VPS, AWS) | sidecar's folder |

Rules:
- One writer per file: each server only ever writes its own `serverId` file. No conflict copies.
- Merge = per-record `updatedAt`, last-writer-wins. Sessions never merge; each server's sessions live under its own `serverId`.
- Extension missing or store unreachable → run local, queue, retry on interval. Never block.
- Sidecar is dumb in v1: `GET/PUT /pac/{unitId}/players`, `POST /pac/{unitId}/sessions`, `GET/PUT /pac/{unitId}/structure`. Auth = per-unit API key.

### Structure sync (fill-the-gaps rule) — DECIDED
Structure is compiled config, so it can't be injected at runtime. Instead, structure is loaded **per section** with this precedence:

```
for each section in [settings-overridable, ranks, skills, awards, statuses, roles, opords]:
    if section present in this mission's CfgGFA_PAC (class exists, non-empty)  → use local file  (DO NOT sync)
    else if cached copy in profileNamespace (gfa_pac_structcache)               → use cache
    else if sync store has it                                                    → pull, cache, use
    else                                                                         → empty + warning
```

- A server whose mission contains the section **never** overwrites it from the store.
- A server with the section missing pulls it from the store and caches it, so it works offline next time.
- Whoever holds the full structure exports it to the store (`local`/`folder`/`api` write of `structure_<unitId>_<serverId>.json`, hash included). If several servers publish, highest structure hash timestamp wins — but the intended setup is one publisher.
- Live tile shows per-section origin: `file` / `cache` / `store`. Delta tool includes origin so "why is this different" is answerable.
- `settings` itself is never pulled — `unitId`, `serverId`, `sync` must be in the local file (bootstrap).

### Auth
- `userconfig/gfa_atak/pac_sync.cfg` on the server box: `apiKey`, optional `apiUrl`. Read by extension only; SQF never sees it. Missing file → `api` mode degrades to `local` with a logged warning.

### Extension
- One small extension (arma-rs / Rust recommended), calls: `read_file`, `write_file`, `list_files`, `http_get`, `http_put`, `http_post`, `read_auth`. Async where Arma allows; results via callback.
- No listener. No provider-specific cloud APIs.

Exit criteria: a minion server with only `settings` in its mission boots, pulls structure, runs an op, and its sessions appear in the store. Removing the extension leaves it fully functional on its cache.

---

## Later (not scheduled)
- Sidecar hosted in AWS for communities without a spare box.
- Discord bot reading the sidecar store.
- Web roster / delta tool site reading the same store.

## Open questions
None — all decisions above are final for Phase 1.
