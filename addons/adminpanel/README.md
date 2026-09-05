# Admin Panel

`ghost_adminpanel`

**This addon is licensed GPL-3. The rest of Ghosts of Battle is APL-SA. Read the
licence section at the bottom before moving any file in this folder anywhere
else.**

An in-game admin console: who is on the server, where they are, what state they
are in, and the handful of things an admin has to be able to do about it without
leaving the mission - teleport, heal, spectate, Zeus, kick, ban, run code.

Ported from the admin panel that shipped inside the Task Force Roomba mission
framework, re-laid-out to the TAC//ADMIN design and wired to ghost's own theme
and settings.

## Getting in

Two keys, both under **Ghosts of Battle** in CBA's keybinds:

| Key | Opens |
| --- | --- |
| `Pause/Break` | The console, if you are an admin. Says so if you are not. |
| `Shift + Pause/Break` | The message box, which anybody may use to reach an admin. |

Also `#ghost admin.list`, `#ghost admin.me` and `#ghost admin.reload` - the usual
ghost admin chat surface, for finding out why the console will not open.

## The admin list lives in the MISSION

This is the one thing that had to change in the port. The panel used to
`#include` the mission's admin list at compile time, which an addon cannot do -
an addon is compiled once and then runs on every mission. It is read at runtime
instead, from either of two places.

**The recommended one: `CfgGhostAdmins` in `description.ext`.** Put it beside the
mission's other admin arrays so one edit covers all three:

```cpp
#define ADMINS     "76561198000002705", /* YonV  */     "76561198083000561"  /* Wobba */

enableDebugConsole[]      = {ADMINS};
cba_settings_whitelist[]  = {ADMINS};

class CfgGhostAdmins {
    admins[] = {ADMINS};
};
```

That is one list for the debug console, the CBA settings whitelist and this
panel, which is the point - two lists saying the same thing means one of them is
always out of date.

**The panel's original file still works too.** A mission that still has
`config\config_adminlist.hpp` needs no edit:

```sqf
_admins = [
    "76561198000002705", /* YonV */
    "76561198083000561"  /* Wobba */
];
```

`ghost_adminpanel_fnc_adminList` **runs** that file at mission start and reads
`_admins` back out - `call` writes into the caller's scope, which is exactly what
the old `#include` did. Same path, same variable, same comments.

Third, ghost's own admin flag (`ghost_common_isAdmin`, what `#login` sets) opens
the console as well, and so do the uids in `ghost_admin`'s own
`enableDebugConsole` list. The flag is a CBA setting - **Ghost admins may open
it** - and turning it off makes the mission's list the only way in.

A mission with no list at all is therefore not locked out: the host can still
open the console and grant access with **TOGGLE ADMIN**.

## What is on the screen

**Left rail** - the player list with a filter over it, the four utility toggles
(godmode, infinite ammo, ghost, arsenal), the admin actions (spectate, Zeus,
kick, ban, lock server, role access, heal all), the mission ending picker, and
the message box.

**Centre** - the map, with a tab strip choosing what it puts trackers on:
players, vehicles, AI, or nothing but the mission's own markers. Teleport combos
are on the MAP label's tooltip. Underneath, the code box: a target strip
(SERVER / LOCAL / REMOTE - name), RUN, and a **RETURN** log.

**Right rail** - the live camera feed on the selected man with his grid, height
and heading under it; his info and skills; his vehicle and his medical state.

## What changed from the mission version

Ported code is edited as little as possible so an upstream fix stays a re-copy
rather than a merge. These were not optional:

- **The admin list**, above.
- **`fn_isAdmin` took a unit and then tested `player`** - the local one. Every
  name in the list got the admin's own status, so one admin opening the console
  starred every row. It delegates to ghost's gate now, so there is one answer.
- **`MISSION_ENDBUTTON` and `ADMIN_SERVERHEALALL` shared idc 4941**, which is why
  the whole MISSION block was commented out upstream. END MISSION has a number of
  its own and works, behind a two-stage confirm.
- **Remote exec threw its return value away.** `compileAndExec` spawned the code,
  so nothing could come back; it calls it and sends the result to the console that
  asked. Code that needs to suspend spawns itself.
- **The three exec buttons each fired immediately**, so the only way to change
  your mind about the target was to have already sent it somewhere. They select
  now; RUN sends.
- **Four calls into the Roomba framework** (`YMF_fnc_player_getRank`,
  `player_setRankOverride`, `logToServer`, `toggleRoleGrant`) are guarded. With
  that framework loaded they behave exactly as before; without it the engine's own
  rank, the RPT, and a plain "this mission has no role gating" stand in.
- **The toggle plates were a hardcoded orange**, repainted ten times a second
  straight over whatever scheme the player chose. They read the theme.
- **Layout and skin.** The panel was a floating 0.57-wide box; this is the
  console in the mockup, painted from the tacpad's scheme, opacity and UI size.

Everything else - every action, every remote call, the camera, the markers, the
medical readout - is the original, under its original `admp_fnc_` tag.

## Server whitelisting

If your server runs a `CfgRemoteExec` whitelist rather than allowing everything,
two functions need to be on it:

- `admp_fnc_compileAndExec` - the code box, targeting client or server
- `ghost_adminpanel_fnc_execLog` - the return value coming back

Ghost does not ship a `CfgRemoteExec` of its own; that is the mission's or the
server's call, and it should be.

## Credits and licence

The panel is **JohnnyShootos'** work, edited by **TheTimidShade**, taken from the
mission framework it shipped in - which is licensed under the **GNU General
Public License v3**.

That licence travels with the code. It cannot be relicensed as APL-SA, so this
addon is **its own PBO with its own LICENSE beside it**, distributed alongside
Ghosts of Battle rather than dissolved into it. No file from this folder may be
copied into another ghost addon, and no APL-SA ghost code may be copied in here.

Ghost's additions in this folder - the console layout, the theme and scale, the
filter, the map tabs, the return log, the runtime admin list - are contributed
under the same GPL-3, because that is the only way they can sit in the same PBO.

See [LICENSE](LICENSE) for the full text.

<!-- generated below this line by tools/gen_addon_readmes.py - do not edit -->

## Requires

- `ghost_main`
- `ghost_common`
- `ghost_notify`
- `ghost_tacpad`
- `cba_xeh` _(external)_

## Ships

18 functions.

## CBA settings

| Setting | Type | Name |
|---|---|---|
| `ghost_adminpanel_enabled` | CHECKBOX | Enable admin console |
| `ghost_adminpanel_honourGhostAdmin` | CHECKBOX | Ghost admins may open it |

## Functions

<details><summary>18</summary>

- `ghost_adminpanel_fnc_adminList`
- `ghost_adminpanel_fnc_confirmEnd`
- `ghost_adminpanel_fnc_execClear`
- `ghost_adminpanel_fnc_execLog`
- `ghost_adminpanel_fnc_execRun`
- `ghost_adminpanel_fnc_execTabs`
- `ghost_adminpanel_fnc_execTarget`
- `ghost_adminpanel_fnc_filterList`
- `ghost_adminpanel_fnc_infoRow`
- `ghost_adminpanel_fnc_isAdmin`
- `ghost_adminpanel_fnc_mapCursor`
- `ghost_adminpanel_fnc_mapFilter`
- `ghost_adminpanel_fnc_mapTabs`
- `ghost_adminpanel_fnc_mapTargets`
- `ghost_adminpanel_fnc_open`
- `ghost_adminpanel_fnc_panelAdmin`
- `ghost_adminpanel_fnc_style`
- `ghost_adminpanel_fnc_styleMessage`

</details>
