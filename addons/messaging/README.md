# Messaging

`ghost_messaging`

Threaded reports and tasking, without cTab. The store is on the server and the
clients hold a disposable cache; a task is a thread whose root template moves it
into a state, so there is no second object that can disagree about what is open.

Everything is a mailbox. A player, a group and a shared filing box differ only in
how their membership is worked out, and membership is derived every time rather
than stored — a player who changes squad mid-mission stops getting their old
squad's traffic immediately.

The UI is `ghost_tacpad`'s — TAC//MSG on the map screen. This is the engine
under it, and it is usable from script on its own.

## The chain, and where it stops

Four links, and **every one of them is designed to fail quietly**, which is what
makes a broken send so hard to read from the outside: a refusal is told to the
sender alone, and a delivery to a mailbox nobody is standing in is a legitimate
no-op rather than an error.

| | |
|---|---|
| 1. client `submit` | validates the payload locally, then raises `ghost_messaging_submit` on the server. Refuses with a reason and never leaves the machine if a required field is empty, if there is no addressee, or if messaging is off |
| 2. server `srvSubmit` | checks the sender is a live player, drops a repeated nonce, validates *again*, opens or finds the thread (`srvThreadFor`), files the message |
| 3. server `srvDeliver` | works out the mailboxes — always `P:<sender>`, plus the addressees, plus the command group if a ROUTING line is ticked — files the thread in each, and pushes one `receive` per PLAYER, never one per box they happen to share |
| 4. client `cltReceive` | replaces that thread's row in `ghost_messaging_index` and raises `received`. The reader draws off that index and nothing else |

A shared box has no members — a named box is readable by everyone rather than
subscribed to — so a thread filed only in one is pushed to every player as a
*quiet* row: an index entry with no message body and no notification.

Anything the server refuses comes back on `ghost_messaging_reject`, which is told
to the sender and nobody else. It now also prints to system chat, because the
notification stack is an `RscTitles` layer and every screen it would be about is
a dialog — in front of it.

## Seeing where it stopped

Admin chat commands, gated on the ghost admin flag like the rest of `#ghost`:

| | |
|---|---|
| `#ghost msg.state` | is it enabled, how much is in the store, which mailboxes you can see |
| `#ghost msg.boxes` | every mailbox, its kind, its thread count and how many players are in it *now* |
| `#ghost msg.threads` | every thread: id, priority, status, subject, message count, boxes |
| `#ghost msg.send` | file a free-text message to yourself through the real server path |
| `#ghost msg.mine` | what your own client has in its index — the far end, which a server dump cannot see |

`msg.send` then `msg.mine` isolates it in two presses: a thread that exists on
the server but not in your index is a delivery problem, and one that appears in
both but not on screen is the reader.

## Testing it on your own

A threaded system needs two people to prove and there is rarely a second one on
a dev box, so these file traffic **from somebody else** — through the real
server path, so it arrives unread, raises a notification and lands on the thread
spine exactly as another player's would. Only the call sign is a lie: `srvSubmit`
takes an optional override and, when one is given, does *not* mark the message
read by the sender.

| | |
|---|---|
| `#ghost msg.inbound [text]` | HQ SIGNALS sends you a message — unread, with the alert |
| `#ghost msg.flash` | DOC RILEY files a FLASH CASEVAC on your grid — the accent row, the chip, the card and the alert all come off this one |
| `#ghost msg.reply <threadId> [text]` | ROTARY 1-1 answers a thread, so the spine and the unread count have something in them |
| `#ghost msg.clear` | empties the store and refreshes every index — start the run again |

A full pass on your own, from a cold mission:

1. `#ghost msg.flash` — a FLASH thread arrives. Check the notification, the
   accent row in the list, the unread count on its net tab.
2. Open it. The card should read as the filled 6-line, two columns, not prose.
3. `#ghost msg.threads`, take the id, then `#ghost msg.reply T0001` — the reply
   appears on the spine and the thread comes back unread.
4. Answer it from the reader: a quick reply, then + GRID, then + MARKER, then
   + TEMPLATE for one that needs a card.
5. `#ghost msg.mine` — the index should show one row per thread per mailbox.
6. `#ghost msg.clear` and start again.

The one thing this cannot prove is a second machine: locality, `groupOwner`
routing and JIP index requests all need a real client.

```sqf
// send
["tic", [
    ["Location.A", getPosATL player],
    ["Enemy.A", "Two technicals, north edge of the town"],
    ["Intentions.A", "Holding the compound"]
], ["B:HQ", "G:Alpha 1-1"]] call ghost_messaging_fnc_submit;

// read
["T0001"] call ghost_messaging_fnc_open;

// reply into a thread
["wilco", [], [], "T0001"] call ghost_messaging_fnc_submit;
```

Addressees are mailbox ids: `P:<uid>` for one player, `G:<groupId>` for a group,
`B:<name>` for a shared box. A bare name is taken as a shared box, so `"HQ"` and
`"B:HQ"` reach the same place.

## Templates

All thirteen cTab reports are here, one for one, in `templates.inc.sqf` — the
Ghost smart-card deck plus SITREP and CALL FOR FIRE. Six reply templates were
added, because a threaded system that cannot answer a report is a noticeboard.

Two things in that file are contracts, not presentation:

- **Line titles are field keys.** `registerTemplate` builds each field key from
  its line title, which is what lets the ALiVE forwarder find a CONTACTREP's
  `S`/`A`/`L`/`U`/`T`/`E`/`R` and a SITREP's `Callsign`/`Location`/`Enemy`/
  `Friendly`/`Civ`/`Status`/`Remarks` without counting lines. Rename a line title
  and you have renamed a field. Rename a field's label and nothing breaks.
- **The ROUTING line.** DEFREP carries a tick that also mails the command
  group. The template names that field in its `routing` option rather than the
  code searching for it, so it can be moved.

## Carried over from cTab

- **TIC.** A CONTACT REPORT was never really a message — it was an alarm typed
  into a message form, and it is the one report that reaches people it was not
  addressed to. cTab hardcoded that against the template's uid; here it is a
  template flag, so a mission can put it on another report without touching
  code. It goes out on `ghost_common`'s alert bus, side-filtered, and draws a
  **local** marker on the sending side's map — a global one would be on the
  enemy's map too.
- **ALiVE reports.** CONTACTREP posts as a spotrep and SITREP as a sitrep, each
  with a companion marker. This addon never names an ALiVE symbol: it flattens
  the payload into named fields and hands them to
  `ghost_adapter_alive_fnc_postReport`, which is new. Exactly one addon may know
  ALiVE exists and `tools/check_invariants.py` fails the build over it.

## Record shapes

Every record is a HashMap and every one of them lives on the server only, because
a message has thirteen fields and nobody reads `_msg select 11` correctly at two
in the morning. They are flattened with `toArray` at the network boundary and
rebuilt with `createHashMapFromArray` on the far side, since a HashMap is not
guaranteed to survive a `remoteExec`.

| record | keys |
|---|---|
| message | id seq threadId parentId fromUid fromCallsign templateId payload sentTime gameTime priority transition readBy |
| thread | id kind subject rootTemplateId status issuerUid claimedBy participants boxes anchorPos anchorLabel parentThreadId lastActivity closed messages |
| box | id kind displayName roles uids retention forwardToAlive threads |
| index | threadId boxId subject status priority claimedBy lastActivity unread |

A template is a HashMap too, but it is built from `templates.inc.sqf` in preInit
on every machine and never crosses the wire at all.

## Deliberate deviations from `work/mess.json`

- **The sender is taken from the unit that was handed in**, after checking it is
  a live player, rather than read off the engine with `remoteExecutedOwner`. The
  spec asks for the latter; that needs a raw `remoteExec`, and the rest of the
  mod deliberately travels on CBA's event channel because a mission's
  `CfgRemoteExec` cannot close it. Impersonation from here already requires a
  client running arbitrary code.
- **`gfa_atak` became `ghost_messaging`**, using the standard `GVAR`/`QGVAR`
  macros like every other addon.

## Not built yet

Compose and inbox UI, the field pickers and autofill the schema already
describes (`autoFill` and `source` are stored and unread), `composeMinDevice`,
EW link-state degradation, and FRAGO sub-threads.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `ghost_notify`
- `cba_xeh` _(external)_

## Ships

46 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_messaging_enabled` | CHECKBOX | Enable messaging |
| `ghost_messaging_namedBoxes` | EDITBOX | Shared mailboxes |
| `ghost_messaging_commandGroup` | EDITBOX | Command group |
| `ghost_messaging_idleClose` | SLIDER | Idle close (min) |
| `ghost_messaging_ewLink` | CHECKBOX | EW link state |
| `ghost_messaging_ticBroadcast` | CHECKBOX | TIC alerts the side |
| `ghost_messaging_ticMarker` | CHECKBOX | TIC drops a map marker |
| `ghost_messaging_ticMarkerType` | EDITBOX | TIC marker type |
| `ghost_messaging_ticMarkerColor` | EDITBOX | TIC marker colour |
| `ghost_messaging_aliveReports` | CHECKBOX | Post reports to ALiVE |
| `ghost_messaging_aliveLocality` | LIST | ALiVE report locality |
| `ghost_messaging_sitrepMarkerType` | EDITBOX | SITREP marker type |
| `ghost_messaging_seedTest` | CHECKBOX | Seed test traffic |

## Functions

<details><summary>46</summary>

- `ghost_messaging_fnc_cltIndex`
- `ghost_messaging_fnc_cltMarker`
- `ghost_messaging_fnc_cltReceive`
- `ghost_messaging_fnc_cltThread`
- `ghost_messaging_fnc_fieldKeys`
- `ghost_messaging_fnc_follow`
- `ghost_messaging_fnc_linkState`
- `ghost_messaging_fnc_loadTemplates`
- `ghost_messaging_fnc_netLevel`
- `ghost_messaging_fnc_netStream`
- `ghost_messaging_fnc_notify`
- `ghost_messaging_fnc_open`
- `ghost_messaging_fnc_platoonTags`
- `ghost_messaging_fnc_railNets`
- `ghost_messaging_fnc_registerTemplate`
- `ghost_messaging_fnc_render`
- `ghost_messaging_fnc_request`
- `ghost_messaging_fnc_roleNets`
- `ghost_messaging_fnc_roleTag`
- `ghost_messaging_fnc_seedTest`
- `ghost_messaging_fnc_setNetLevel`
- `ghost_messaging_fnc_squadNets`
- `ghost_messaging_fnc_srvBox`
- `ghost_messaging_fnc_srvBoxesFor`
- `ghost_messaging_fnc_srvClaim`
- `ghost_messaging_fnc_srvDeliver`
- `ghost_messaging_fnc_srvForward`
- `ghost_messaging_fnc_srvIndexFor`
- `ghost_messaging_fnc_srvMarkRead`
- `ghost_messaging_fnc_srvMembers`
- `ghost_messaging_fnc_srvNextId`
- `ghost_messaging_fnc_srvRequestIndex`
- `ghost_messaging_fnc_srvRequestThread`
- `ghost_messaging_fnc_srvSubmit`
- `ghost_messaging_fnc_srvSweep`
- `ghost_messaging_fnc_srvTagged`
- `ghost_messaging_fnc_srvThreadFor`
- `ghost_messaging_fnc_srvTic`
- `ghost_messaging_fnc_subject`
- `ghost_messaging_fnc_submit`
- `ghost_messaging_fnc_tagCallout`
- `ghost_messaging_fnc_tagMatch`
- `ghost_messaging_fnc_tagSet`
- `ghost_messaging_fnc_template`
- `ghost_messaging_fnc_templateIds`
- `ghost_messaging_fnc_validate`

</details>
