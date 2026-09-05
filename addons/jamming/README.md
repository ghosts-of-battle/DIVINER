# Jamming

`ghost_jamming`

The jamming model: zones with a full-strength core and a falloff, one shared
calculator (`jamFactor`) that every consumer agrees with - radio degradation,
the device's jam readout, the scanner needle.

## Three domains, not one

A zone denies **radio**, **data**, **GPS**, or some combination, and every
consumer asks about the one it cares about rather than about "jamming":

| domain | what goes | who reads it |
|---|---|---|
| `radio` | the voice net - TFAR and ACRE degradation | `jammerLoop` |
| `data` | TAC//MSG traffic, and every group but your own off the map | `messaging_fnc_linkState`, `bft_fnc_draw` |
| `gps` | the GPS item, and with it the map self-icon | `gpsApply` |

`any` is not a domain a zone can carry - it is the question the meter and the EW
scanner ask, meaning "is the spectrum dirty at all". A zone with no domains set
carries radio and data, which is what one emitter denied before the split, so an
untouched mission behaves exactly as it did.

`JAM_DENIED_BAND` is 0.75 and it is one number: it is where the handset says
DENIED, where the meter turns red, where the GPS comes off, and where keying up
counts as burning through rather than talking in a noisy place.

## A site is three props

The **terminal** says what the site denies and IS the emitter - it holds the
zone, LOCATE JAMMER plots it, the hacking tower pool picks it up by classname,
and hacking or destroying it kills the denial permanently. An **omnidirectional
antenna** and a **satellite dish** stand beside it, rolled from three colours
each. They carry nothing; they are there so a site reads as a site from three
hundred metres out. Every site is registered with its commander through the
adapter, so ALiVE garrisons the thing it owns.

    RuggedTerminal_01_communications_hub_F   GPS     one on the map, ever
    RuggedTerminal_01_F                      data    the bigger objectives
    RuggedTerminal_01_communications_F       radio   the rest

## GPS is space-based

There is no mast over the ground it denies. One uplink on the whole map steers a
**1 km or 2 km sphere that wanders**, turning at the world edge, re-rolling its
heading every so often - weather rather than terrain. It is the one field a
player cannot walk out of and wait out, so the only answer is the uplink, which
is a findable, garrisoned, hackable objective like any other site. Kill it and
GPS comes back for good.

## Burning through

A set powerful enough to punch a hole in a radio field does so - and
`ghost_reaction` answers the transmission with the full reply and a QRF on the
transmitter, no detection roll. It is not something that might be noticed: it is
radiating hard, from inside ground somebody is spending an emitter to keep quiet.
Off by default until the module's **Radio Burn-Through** is ticked.

    #ghostjam    list live zones

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `ghost_notify`
- `cba_xeh` _(external)_

Carries `skipWhenMissingDependencies` - the PBO is skipped rather than breaking the load order when something above is absent.

## Ships

1 unit class, 17 functions.

## Eden modules

### Ghost - Jamming

`ghost_moduleJamming`, category ghost_modules

Placing this module turns on jamming. Without it, the system is off.<br>Site Radius Min / Max (m) - every site rolls its own reach between the two Objectives With Jammers (%) - Share of a commander's objectives that get an emitter Max Jammers Per Side - Hard ceiling per commander whatever the share works out to GPS Denial - one uplink per commander steering a wandering 1-2 km GPS sphere Uplink Radius (m) - the uplink's own GPS field Masts Are ALiVE Objectives - off by default; the uplink always is Radio Burn-Through - a strong set beats a jammer, and is answered with a QRF Burn-Through Reference (mW) - the set power the field is calibrated against

<details><summary>6 attributes</summary>

- `burnRef`
- `gpsUplinkRadius`
- `largeRadius`
- `maxPerSide`
- `objectiveShare`
- `smallRadius`

</details>

## Functions

<details><summary>17</summary>

- `ghost_jamming_fnc_getZones`
- `ghost_jamming_fnc_gpsApply`
- `ghost_jamming_fnc_gpsDrift`
- `ghost_jamming_fnc_jamFactor`
- `ghost_jamming_fnc_jamHud`
- `ghost_jamming_fnc_jammerLoop`
- `ghost_jamming_fnc_moduleController`
- `ghost_jamming_fnc_productLocateJammer`
- `ghost_jamming_fnc_pruneJammers`
- `ghost_jamming_fnc_publishZones`
- `ghost_jamming_fnc_spawnGpsUplink`
- `ghost_jamming_fnc_spawnJammerSite`
- `ghost_jamming_fnc_spawnObjectiveJammers`
- `ghost_jamming_fnc_spawnTempZone`
- `ghost_jamming_fnc_spawnZoneAt`
- `ghost_jamming_fnc_start`
- `ghost_jamming_fnc_zoneModel`

</details>
