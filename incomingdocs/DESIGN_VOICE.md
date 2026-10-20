# Voice (game VoIP) - design

Voice runs on Arma 3's own VON. RF decides who hears whom; VON carries the audio.
Related: [DESIGN_RF.md](DESIGN_RF.md), [DESIGN_EW.md](DESIGN_EW.md), [DESIGN_TABLET_APPS.md](DESIGN_TABLET_APPS.md).
Canvas: TAC//APP Voice (artifact TkPxnzSsb5PBfguWuEbRQc).
Status: design, for code. Date 2026-10-20.

## Decision

- **Base voice is VON.** Nothing to install, nothing to host, no DLL.
- **One voice adapter interface:** `join(unit, net)`, `leave(unit, net)`, `quality(unit, net, q)`, `talking(unit, net)`.
  - VON is the first adapter.
  - TFAR standalone can be a second adapter for groups that want real ear split.
  - Enfusion VoN is the Arma 4 adapter.
- **What carries over unchanged:** the RF mod, the UI and the rules.
- **Not used:** LiveKit (it was only for an external voice app).
- **Spec:** `SPEC_TACNET.json` D14 (replaces D1 / D1b), D16 (numpad), `voice_adapter`.

## VON vs TFAR standalone

| | VON + our layer | TFAR standalone + override |
|---|---|---|
| Install / hosting | none | mod with a DLL, plus a voice relay server |
| Nets | 10 custom channels + Group | effectively unlimited |
| Calls at once | about 8 | no practical limit |
| Ear split per net | beeps only (panned) | yes, voice too |
| Volume per net | no, per speaker | yes |
| Link quality | volume fade + static overlay | real degradation |
| Direct voice 3D | yes, fixed range | yes, 3 ranges |
| Carries to Arma 4 | the concept does | no |
| Risk | low | medium |

## Channels

| ID | VON channel | Our use | State |
|---|---|---|---|
| 0 | Global | admin broadcast | talk: admins only |
| 1 | Side | not used | disabled |
| 2 | Command | not used (C2 replaces it) | disabled |
| 3 | Group | TEAM net (one per Arma group) | on, mesh sets volume |
| 4 | Vehicle | crew intercom | on, no mesh, works inside the vehicle only |
| 5 | Direct | local voice, 3D | on, untouched, cannot be jammed |
| 6 | Custom 1 | C2 | membership from fill and keys, mesh sets volume |
| 7 | Custom 2 | A2G | as C2 |
| 8-15 | Custom 3-10 | CALL 1-8 | made on dial, removed on hang-up, mesh sets volume |

- **Side** reaches every player on your side, anywhere, with no range, so it would bypass the mesh, jamming and keys. That's why it is off.
- **Commands used:**
  - `radioChannelCreate`, `radioChannelAdd` and `radioChannelRemove`: make channels and set who is in them.
  - `setCurrentChannel`: which channel you talk on.
  - `enableChannel`: block talking on a channel.
  - `getPlayerChannel`: who is talking, and on which channel.
  - `setPlayerVoNVolume`: per-listener volume for each speaker.
  - Server: `disableChannels`, plus the VON codec settings.

## Numpad

| Numpad | Does |
|---|---|
| 1 2 3 4 | device keys F1 F2 F3 F4 |
| 0 / . | device arrows: active net left / right (walking view), cursor (apps) |
| 5 | open / close tablet |
| 6 | open / close RADIO app on your phone or side device (proposed) |
| 7 / 8 | previous / next tab in the small-device apps (proposed) |
| 9 | TROOPS IN CONTACT |

**F-keys on the walking view:**
- **F1:** accept a call.
- **F2:** ear for the active net; during a call, quick add.
- **F3:** mute the active net.
- **F4:** decline or hang up.

## Mesh drives VON

- **Every tick (1 s)** the RF mod works out each listener's quality to each speaker on each net (widest path, see the RF doc).
- **The listener's client sets that speaker's volume** (`setPlayerVoNVolume`): 1 = full, falling = quieter with static, 0 = muted.
- **Membership changes only for keys, fills and calls.** A flickering link changes volume; it never kicks anyone out of a channel.
- **Islands:** a squad cut off from C2 still hears each other on C2, and loses everyone beyond the gap.
- **Group channel:** team nets can't have people removed, so they are muted by volume instead.
- **Grace time:** 3 s before muting a speaker whose route drops (proposed).

## Nets on the devices

- **Only nets you are on are shown.**
  - VEH appears inside a vehicle.
  - CALL appears when a call is live or ringing.
  - A loaded or captured key shows its net while the key is held.
- **A net you're on but can't reach shows a red outline.** It is not hidden.
- **Ear tag per net** (L / B / R). VON can't pan voice, so the ear pans the net's beeps and static, not the voice.
- **Talking box:** name, net and ear.

Phone walking view, incoming call, in a call:

![phone walk](images/voice_phone_walk.png)
![phone ring](images/voice_phone_ring.png)
![phone call](images/voice_phone_call.png)

Side device walking and ringing:

![side walk](images/voice_side_walk.png) ![side ring](images/voice_side_ring.png)

## Calls

- **A call is one custom channel,** any size up to 8 people. Max 8 calls at once.
- **Dial:** CALL needs reach on DATA. The other person gets a ring, with F1 accept and F4 decline.
- **Add people:**
  - + ADD on a contact while a call is live;
  - group buttons: + MY TEAM, + SQUAD LEADERS, + RTOs, + MEDICS, + HQ;
  - search by name or callsign;
  - the recent contacts list;
  - ADD TO CALL from a member on the map or the squad list;
  - F2 quick add on the walking view.

  Added people ring until they accept. Group adds skip people out of reach and stop at 8.
- **Leave / end:** anyone can hang up. The call ends when one person is left, and its channel is freed.
- **Priority:** a FLASH call can bump the oldest ROUTINE call when all slots are full. The bumped call gets a warning tone first.
- **RTO console** can pull people into a call without a ring. They can still leave.

### Callback

- **Offered when a call fails:** no route, busy, or no answer in 20 s. Press CALL BACK.
- **The server holds the request.** When both people can reach each other on DATA and a call slot is free, both phones ring.
- **Limits:** a request expires after 15 min. One per pair, and up to 3 pending per player.
- **Waiting:** a request waits while either person is in a call, and is held (not dropped) while either is on EMCON 3.
- **Both people see the pending callback**, on the notification line and in CALLS.

### Voice messages

- VON audio can't be recorded from script, so there are no recorded voice notes on VON.
- **Instead:** the callback above. Typed notes are possible later.
- Real voice notes need our own DLL (phase 2, TFAR / own-DLL path only).

## Sounds

Our own sound files, played locally. TFAR's sounds stay under its own licence and are not used.

| Radio | When |
|---|---|
| TX chirp | you start talking on a radio net |
| Roger beep | you stop |
| Squelch open / tail | someone you can hear starts / stops |
| Static | under their voice, louder as quality drops |
| Cut tone | the speaker's route drops mid-transmission |
| Net switch click | you change active net |
| Blocked tone | you try to talk with no route, on EMCON 3, or jammed |

| Call | When |
|---|---|
| Dial tone, ringback | you start a call |
| Ring | incoming call or callback |
| Busy | no free slot, or the other person is busy |
| Connect / hang-up | call opens / ends or someone leaves |
| Join chime | someone is added |
| Priority warning | your ROUTINE call is about to be bumped |

- **Pitch per net:** C2 low, TEAM mid, A2G high, CALL two-tone, so you know the net before the voice starts.
- **Ear:** beeps and static play from the net's ear.
- **Settings:** radio beeps on/off, call beeps on/off, one beep volume, pitch per net, static by quality.
- **Triggers:**
  - Your own transmissions: our push-to-talk handler.
  - Other speakers: a per-frame check of `getPlayerChannel`. As far as I know there is no VON event for this.
  - Mesh: radio sounds only play for speakers you can hear by mesh volume.

## Tablet RADIO app

**NETS:** your nets, VON channel, link, ear (L/B/R), beep volume, state, who is talking; sounds and keys panels.

![tablet nets](images/voice_tablet_nets.png)

**CALLS:** VON channel slots (server-wide), contacts with + ADD / CALL / CALL BACK, group adds, search, the live call with recent contacts, and pending callbacks.

![tablet calls](images/voice_tablet_calls.png)

**MANAGE:** leaders, RTO and admin only.
- **Nets:** VON channel, members, key, PACE alternate, state.
- **Temp nets:** each takes a custom slot and auto-closes.
- **Patches** through a gateway (no slot).
- **Members:** route, hops, listen-only; ADD / REMOVE / REKEY / FORCE PACE / ORDER EMCON.
- **Signal plan:** load, reset, admin export to the mission config.

![tablet manage](images/voice_tablet_manage.png)

| Action | TL | SL | RTO | Admin |
|---|---|---|---|---|
| own nets, members | ✓ | ✓ | ✓ | ✓ |
| add / remove (own team) | ✓ | ✓ | ✓ | ✓ |
| temp net, patch | | ✓ | ✓ | ✓ |
| rekey, PACE, EMCON | | ✓ | ✓ | ✓ |
| C2 / A2G, calls, bump | | | ✓ | ✓ |
| signal plan | | | | ✓ |

## Phone and side RADIO app

- **Opens full screen** on the carried device (numpad 6, proposed). The mouse works too.
- **Cursor:** numpad 0 / . move it; F1-F4 are soft keys, shown along the bottom; 7 / 8 switch tabs (proposed).
- **Layout:** the phone uses wide tables. The side device stacks each row onto two lines, with the soft keys in a 2 x 2 grid.

| Tab | F1 | F2 | F3 | F4 |
|---|---|---|---|---|
| NETS | MUTE | EAR | SET ACTIVE | BACK |
| CALLS | ADD | CALL | GROUP + | HANG UP |
| MANAGE | ADD | REMOVE | REKEY | BACK |

![phone app nets](images/voice_phone_app_nets.png)
![phone app calls](images/voice_phone_app_calls.png)
![phone app manage](images/voice_phone_app_manage.png)

![side app nets](images/voice_side_app_nets.png) ![side app calls](images/voice_side_app_calls.png) ![side app manage](images/voice_side_app_manage.png)

**Adding a caller on the phone or side device:**
1. Open RADIO. It opens on CALLS while a call is live.
2. Move to the person with 0 / .
3. Press F1 ADD.

- **Group add:** F3 GROUP +, move to the group, F1.
- **Quick add from the walking view:** F2 during a call opens a recent / team list on the notification line. Move with 0 / . and press F1 to add; F4 closes it.

## Tests to run first

1. `setPlayerVoNVolume`: per listener, per speaker, across all channels.
2. `enableChannel` with voice off: you can still hear the channel (needed for listen-only).
3. `getPlayerChannel`: updates fast enough for speaking indicators and sounds.
4. Add / remove delay on custom channels across clients.
5. Whether script can limit the Vehicle channel to crew (otherwise passengers are muted by volume).

## Open

- **Mesh:**
  - Do handhelds relay by default?
  - Are the hop limits right (4 / 6 / 8)?
  - Should AI radios relay for players? Proposed: no.
  - Is a 3 s grace time right?
- **Keys:** confirm numpad 6 (radio app), 7 / 8 (tabs), and F2 quick add.
- **MANAGE on small devices:** leaders only, as on the tablet?
- **Group add:** ring everyone, or join them directly?
- **Callback:** ring both people at once, or B first?
