# RF mod - design

Mod: `gfa_rf`. Deps: CBA only. Rules: [SPEC_TACNET.json](SPEC_TACNET.json) `rf`.
EW on top of it: [DESIGN_EW.md](DESIGN_EW.md). UI: RF app on the tablet, [DESIGN_TABLET_APPS.md](DESIGN_TABLET_APPS.md).
Status: design, for code. Date 2026-10-19.

## What it is

The base of the comms ecosystem. It answers one question every tick: who can reach whom, on which net, and how well. Voice, data, BFT, drones, calls and EW all read the answer. It has no screen of its own: the tablet's RF app is its UI.

- **Nets, not frequencies.** A net is a group with a key. Players never see frequencies.
- **Mesh.** Any capable radio can relay. Traffic takes the best path.
- **One answer for everything.** Voice quality, data delivery, BFT freshness and drone control all come from the same link quality, so they can never disagree.

## Where it runs

| Side | Does |
|---|---|
| Server | registry, link budget, mesh, raw intercepts, client slices |
| Client | reads its own slice only; no computation |

- Tick: players 1 s, static nodes 5 s.
- A slice is pushed to a client only when it changes (`publicVariableClient`), never every tick.

## Objects

| Object | Holds |
|---|---|
| **Node** | id, object (unit / vehicle / prop), side, profile, nets with keys, state (on, tx, relay, activeNet, monitorNet, emcon 0-3), battery, owner mod |
| **Profile** | bands, TX power, RX sensitivity, antenna gain, pattern (omni / sector + angle), hop limit, relay capable, spread gain, data rate, battery Wh, idle and TX watts, ES capable, DF class, anti-spoof GPS |
| **Net** | id, name, band, key, spread gain, PACE (P/A/C/E net ids), state (cut, held, patchedTo), source (signal plan) |
| **Link** | a, b, net, SNR, quality 0-1, hops, last hop |
| **Emitter** | node, band, power, pattern, azimuth, intent (comms / data / video / jam / spoof / decoy / radar / de), exposure |
| **Track** | side, emitter, band, dBm, bearing ± error, fix ± error, named (key held), class, time, cuts |

## Link budget

```
rx      = tx + gainTx + gainRx - pathloss(d, band) - terrain - clutter - body
noise   = floor(band) + sum(jammers in band, each minus spread gain unless the key is held)
snr     = rx - noise
quality = clamp((snr - 6) / 20, 0, 1)
```

**Path loss**: log-distance per band.

| Band | Exponent | Ref at 1 m | Noise floor |
|---|---|---|---|
| VHF | 2.6 | 32 dB | −110 dBm |
| UHF | 2.9 | 40 dB | −105 dBm |
| SAT | 2.0 | 45 dB | −115 dBm |
| VIDEO | 3.2 | 48 dB | −95 dBm |

**Obstacles:**
- Terrain: 3 samples along the path (`terrainIntersectASL`); each blocked sample costs 12 dB.
- Clutter: `lineIntersectsSurfaces`, counted. Wall 18 dB, tree 5 dB.
- Body: prone 3 dB, in a vehicle 6 dB.

**Without the key:**
- Detection: rx minus spread gain.
- Jamming noise: jammer minus spread gain.

**Tuning targets:** 5 W VHF ~5 km open and ~1 km in town; 0.5 W handheld ~1.5 km open.

## Mesh

- Built per net, every tick.
- **Vertices:** nodes on the net that are on and either relay-capable or an endpoint.
- **Prefilter:** skip pairs beyond the band's maximum range at maximum power.
- **Edges:** link budget per pair, cached for the tick.
- **Search:** widest path, maximising the weakest link (from `radio_mesh`).
- **Hop limit:** the smallest profile hop limit along the path.
- **Gateway:** a node on two nets with relay on joins the two graphs.
- **Relay cost:** a relaying node drains battery at TX watts while it carries traffic.
- **AI nodes:** only if the profile or node is flagged.

## What quality does

| Domain | Quality → effect |
|---|---|
| Voice | TFAR per-unit distance multipliers from quality; static as it falls; cut below threshold |
| Data | delivery and delay; messages queue below threshold, send when the link returns |
| BFT | update rate falls with quality; stale marker when no path |
| Drones | control and feed need the VIDEO link; below 0.2 control is lost and the drone RTBs |
| Calls | connect only with reach on DATA; drop when the link drops |
| GPS | own position good / degraded / denied from the GPS band |

## Nets (default plan)

| Net | Who | Band |
|---|---|---|
| TEAM 1-5 | that team (Arma group) | VHF |
| C2 | everyone, all-call, by signal plan | VHF |
| A2G | everyone, air to ground | UHF |
| DATA | everyone, data only | UHF data |
| CALL x | 2+ nodes, temporary, created on dial | UHF data |

Fill: rifleman and leader get TEAM, C2, A2G. PACE and gateways are added when nets grow.

## Radio profiles

| Profile | Bands | TX | RX sens | Gain | Hops | Spread | Battery | Range (flat, clear) |
|---|---|---|---|---|---|---|---|---|
| Handheld (MPU5) | VHF/UHF | 5 W | −112 dBm | 2 dBi | 4 | 20 dB | 38 Wh | ~3 km |
| Manpack | VHF/UHF | 20 W | −115 dBm | 3 dBi | 6 | 20 dB | 90 Wh | ~8 km |
| Vehicle set | VHF/UHF/SAT | 50 W | −118 dBm | 6 dBi mast | 8 | 25 dB | vehicle | ~15 km |
| Ground relay | VHF/UHF | 20 W | −118 dBm | 6 dBi | 8 | 25 dB | 200 Wh | ~10 km |
| Drone link | VIDEO | 1 W | −95 dBm | 3 dBi | 0 | 10 dB | drone | ~4 km |
| Legacy / commercial | VHF | 5 W | −110 dBm | 2 dBi | 0 | 0 dB | 30 Wh | ~3 km |
| SAT terminal | SAT | 10 W | −120 dBm | 12 dBi | 0 | 10 dB | 60 Wh | sky view |

**Faction tiers**, set in the faction builder:
- **A peer:** same sets as players.
- **B regular** (default when unset): legacy sets plus some manpacks, 10 dB spread.
- **C irregular:** commercial radios and phones only, no spread.

## Who gets a node

- **Players:** from the radio or device they carry (GPS slot device, radio item).
- **Vehicles:** every vehicle with a set gets a vehicle node; the crew uses it.
- **AI:** leaders and vehicles, with the profile set by the faction tier.
- **Placed:** ground relays, jammers (EW), decoys (EW), static HQ nodes from the mission.

## What players do with RF

- **Everyone with a set:**
  - Pick the active net (numpad), monitor a second net, use the 2nd PTT.
  - Call another node, leave a voice note.
  - Set power, relay on/off, and antenna (omni / sector + heading).
  - See their own link quality, hops, battery and exposure.
- **RTO, leaders, crews:**
  - Carry a manpack as a relay, or place, pick up and re-battery a ground relay.
  - Raise a vehicle mast.
  - Run a gateway between nets.
  - Load the fill, order EMCON, rekey nets, switch the group to its PACE alternate.
- **Physical:** destroy enemy relays and antennas; capture and INSPECT enemy sets (EW).

## What the AI does with RF

- Same physics as players: terrain, range and jamming all apply.
- **Comms gate (EW):** AI groups share sightings, call support and get orders only over links. Isolated groups fight alone. See the EW doc.
- **AI drones:** drop their waypoints when the link is lost, then hold or RTB.

## Public API

| Call | Scope |
|---|---|
| `rf_register` / `rf_unregister` | node in / out |
| `rf_setState` | on, tx, relay, activeNet, monitorNet, keys, emcon |
| `rf_link`, `rf_reach` | client slice |
| `rf_tracks`, `rf_emitters` | per side |
| `rf_noise` | pos, band → dBm |
| `rf_budget` | server: full budget for a pair |
| `rf_netSet`, `rf_rekey` | server / admin |
| `rf_emcon` | server |
| `rf_gpsState` | client slice |
| EW calls (`rf_jam`, `rf_spoof`, `rf_decoy`, `rf_threats`) | provided when `gfa_ew` is loaded, through RF's noise-source and listener hook |

**Events:** `rf_linkChanged`, `rf_netCut`, `rf_rekeyed`, `rf_emconChanged`, `rf_exposureHigh`. With EW: `rf_trackNew`, `rf_trackLost`, `rf_jamOn`, `rf_spoofDetected`, `rf_dfOnYou`.

**Settings:**
- Tick rates.
- Band table.
- Terrain and clutter dB.
- AI nodes counted.
- Max nodes per net.
- PACE auto time.
- Debug overlay.

## UI

The RF app on the tablet (and vehicle tablet):

- **Without EW:** OVERVIEW, NETS, MESH.
- **With EW:** also ES, EA, EP.
- **Phone and side devices:** RF state appears in the status icons (NET, MESH, JAM, GPS) and the net row (green / red outline per net).

![overview](images/app_rf.png)
![nets](images/app_rfnets.png)
![mesh](images/app_rfmesh.png)

## Open

1. Antenna height and radio horizon: masts, aircraft and drones at altitude. The link budget ignores height today, and it matters most.
2. Power: battery drain, swap, vehicle charging.
3. Performance: node and pair limits, spreading work over frames, caching terrain samples.
4. Sync: slice contents and size, JIP, headless client.
5. Mission maker: Eden signal-plan module (nets, keys, PACE), placing relays, Zeus controls.
6. Weather: rain fade on SAT and VIDEO, foliage by season.
7. The quality threshold is 6 dB in the spec, but the tablet mockups show 3 dB. One of them needs to change.
