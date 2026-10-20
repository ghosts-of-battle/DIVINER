# DESIGN — ACRE2 Mesh + EW Layer

Status: planning / spec. Platform decision locked. No implementation code here by design.

---

## 0. Decision record

- **Platform: ACRE2 on TeamSpeak.** Gameplay fidelity wins over dropping TS. No ACRE standalone-VoIP fork.
- **Mesh + EW ride on diwako's custom-signal hook** (`ACRE2-Custom-Signal-Calculation`), which wraps `acre_api_fnc_setCustomSignalFunc`. Requires ACRE signal model = **Arcade or LOS Multipath** (LOS Multipath is default; LOS Simple bypasses the hook — hard requirement).
- **[[ew-zones]] is ported, not rewritten.** Jamming and detection get better ACRE-native mechanisms; the response/dispatch half carries over unchanged.
- **License:** ACRE2 is GPLv2, diwako's script is included/adaptable. Our layer ships as an addon (not per-mission copy-paste).

---

## 1. What's verified (from source, this is not assumed)

**Detection** — ACRE raises CBA local events on the transmitter's client:

| Event | Payload | Fires on |
|---|---|---|
| `acre_startedSpeaking` | `[unit, onRadio(bool), radioId, speakingType]` | transmitter client, key-up |
| `acre_stoppedSpeaking` | `[unit, onRadio]` | transmitter client, key-down |
| `acre_remoteStartedSpeaking` | `[unit, speakingType, radioId]` | *receiver* clients when a nearby unit is heard |

Plus polling: `acre_api_fnc_isBroadcasting` (unit, bool — keyed on radio) and `acre_api_fnc_isSpeaking` (radio or direct). We use the event, not polling.

**Signal hook** — diwako's `diw_acre_fnc_getCustomSignal` is called per pair with `[frequency, mW, receiverRadioID, transmitterRadioID]`, resolves both antennas, and feeds tx/rx position + power into ACRE's propagation extension. This is the per-pair injection point the mesh needs. Diwako also ships `diw_acre_fnc_createRadioJammer` (frequency-banded, moving-object-capable, stops on jammer death).

Both facts close the two dependencies that were open before this doc.

---

## 2. Architecture — two places, nothing else

The entire 2040 model lives in exactly two execution contexts:

**A. Server graph build (timed, ~2–3s tick — tune).** Expensive work happens here, off the hot path:
- Enumerate mesh nodes (see §3), read position / alive / on / side.
- Build adjacency: node pair connected if within that pair's hop range **and** LOS passes (`terrainIntersect` between hop points).
- Delete edges severed by active jammers (edge midpoint inside a jam radius on the jammed band).
- Compute all-pairs reachability + next-hop (small graph → repeated BFS or Floyd-Warshall is fine).
- Broadcast the reachability/next-hop table to clients.

**B. Client signal lookup (per transmission, per listener — must be O(1)-ish).** Inside diwako's signal func:
1. Resolve `txId` / `rxId` → owner units (cached map, never recompute per call).
2. Look up `reachable[tx][rx]` in the broadcast table.
3. Not reachable → return killed signal (diwako's floor, ~`[0, -992]`).
4. Reachable → take the **last hop** (relay adjacent to rx), substitute its position as the transmitter position into ACRE's `process_signal`; keep freq/mW/rx as-is. ACRE computes real terrain propagation on the final leg only.
5. Attenuate by hop count (each relay adds a small penalty; a 4-hop path sounds worse than direct).
6. Return the **better** of {direct tx→rx, best relay path} so a listener in true direct range isn't penalised and never gets a doubled path.

**Hot-path discipline (this is the thing that bites):** no path search, no `terrainIntersect`, no `nearEntities` in the client func — those all live in the timed server build. Client func = two hash lookups + one array read. Topology therefore updates at tick rate: a relay drone dying collapses the net within one tick. Acceptable and realistic.

---

## 3. Mesh node model

A node = any object flagged mesh-capable. Node attributes: position, alive/on state, hop range (per type), side (mesh is per-faction — a BLUFOR mesh doesn't relay OPFOR).

| Node type | Source | Hop range | Notes |
|---|---|---|---|
| Player/RTO | on foot | short | baseline node |
| Comms vehicle | placed/spawned | medium | mobile relay |
| Relay drone | [[alive-drones]] airframe role | long (altitude helps LOS) | ties to the standalone patrol-UAV layer — a new "comms relay" role |
| Dropped repeater | deployable item | medium, static | emplaced infrastructure; killable |

Killing/jamming any node removes it from the next graph build → net shrinks. This is the core feel: destroy the relay drone, the squad net drops to peer-to-peer.

---

## 4. EW port from [[ew-zones]]

| ew-zones piece | TFAR original | ACRE port |
|---|---|---|
| Detect key-up | `OnSpeak` EH | `acre_startedSpeaking` CBA EH |
| Radio identity | look up active radio | `radioId` from event payload |
| Radio vs direct speech | n/a | `onRadio` bool from payload |
| LPI exempt list | `tf_rf7800str` in list | base radio of `radioId` in list (module var, comma-sep classnames) |
| Jamming (Type 1 zone) | `tf_unable_to_use_radio` flip in radius | diwako `createRadioJammer` — banded, moving-capable |
| Range tweaks | `tf_*DistanceMultiplicator` | `acre_send_power` / `acre_receive_power` |
| Detection → dispatch (Type 2) | OnSpeak → spawn package | `acre_startedSpeaking` → remoteExec spawn (same architecture) |

**Carries over unchanged:** drone response package (2 AP + 1 AT default, variable count + class-list per role), per-transmitter cooldown (doubles as recon/ground de-dup), BLUFOR-only targeting, recon-detection-feeds-dispatch (recon birds as mobile DF hunters), the ATAK suite's built-in EW degradation.

**Locality caveat (same as TFAR):** `acre_startedSpeaking` is local to the transmitter's client, so detection fires for human players keying radios, not AI. Response spawn still goes client→server via remoteExec. Unchanged from ew-zones.

**Jamming ↔ mesh interaction:** jammers don't just lower power — they sever relay edges in the graph build. That makes jamming behave like real EW against a mesh: it cuts hops, collapsing reachability, not just attenuating one link.

**LPI model:** exempting the short-range squad radio while leaving longer-range sets detectable gives a coherent "detectability scales with transmit power" model — same design as ew-zones, now keyed on ACRE `radioId` base class instead of `tf_*` classnames. Translate the exempt list to ACRE radio classes.

---

## 5. Module variables (nothing hardcoded; set per placement)

- Graph tick interval (sec)
- Per-node-type hop range
- Hop-count attenuation per relay
- Mesh side/faction filter
- Jammer: strength (mW), banded frequency ranges, effective radius, falloff radius (diwako's params)
- Detection: BLUFOR-only toggle, per-transmitter cooldown (sec)
- LPI exempt radio classes (comma-sep)
- Response package: count field + class-list field per role (default 2 AP + 1 AT)
- Debug: map markers on mesh nodes + live edges (default off, zero cost when off — mirror the alive-drones debug-marker pattern)

---

## 6. Build phases

1. **Signal hook baseline.** Drop diwako's script in as an addon, confirm Arcade/LOS-Multipath model, verify boost/jam works unmodified. Establishes the injection point works in our modset.
2. **Node registry + server graph build.** Flag nodes, build adjacency with LOS, broadcast reachability. No mesh effect yet — just prove the table is correct (debug markers on edges).
3. **Client signal lookup.** Wire reachability + last-hop substitution + hop attenuation into diwako's func. This is where mesh becomes audible. Test: 3 players, 1 relay, kill relay, net splits.
4. **Jammer → edge severing.** Extend the build step to cut edges through active jam zones on-band. Test: jammer between two players drops the link.
5. **Detection port.** Swap `acre_startedSpeaking` in for `OnSpeak`; wire LPI exempt check on `radioId`; remoteExec the existing dispatch. EW response layer live on ACRE.
6. **Relay-drone role.** Add the "comms relay" airframe to [[alive-drones]] as a mesh node type. Two-layer interplay: patrol UAVs that also carry the net.

Phase 1–3 is the whole mesh. 4–6 are the EW/drone layer on top.

---

## 7. Open items to resolve before/while building

- **Graph tick rate** — start 2–3s, tune against node count and how twitchy the net should feel.
- **Hop attenuation curve** — flat per-hop penalty vs distance-weighted. Start flat.
- **Radio-ID → object resolution** — confirm the cheapest reliable map from `radioId` (e.g. `"ACRE_PRC152_ID_1"`) to owning unit; cache it, refresh on radio init events, not per call.
- **Last-hop substitution edge case** — verify the returned `[Px, maxSignal]` fully replaces ACRE's direct calc (return better-of, don't add). Bench a listener standing in direct range of the true transmitter.
- **Per-pair cost at scale** — profile the client func with a full player count keying simultaneously; the O(1) budget is the design constraint, confirm it holds.
- **Relay-drone hop range vs altitude** — a drone at 500m has huge LOS; may need a range cap so one bird doesn't blanket the map.

---

## 8. One-line summary for handoff

Server builds a timed, LOS-and-jammer-aware relay graph and broadcasts reachability; diwako's per-pair ACRE signal hook does a cheap lookup and, on a reachable path, runs ACRE's real propagation on the last hop only; EW rides the `acre_startedSpeaking` event and severs graph edges through jam zones — the whole MANET model in two functions.
