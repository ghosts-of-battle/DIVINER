# Common tasks

Recipes. Each one lists every file that has to change.

---

## Add a squad

1. Add a row to `group_setup[]` in `config_groups.hpp`.
2. Add it to a `Platoons` tab's `squads[]`, if you use tabs.
3. Give it a channel in `ghost_radio_srSquadChannel` — or accept its row index.
4. Add it to `ghost_radio_tfarNets` if you run TFAR (it has no fallback).
5. If it needs its own role classes, add a folder, write the files, and include
   them in `config_roles.hpp`.

Its TAC//MSG squad net appears on its own — squad nets are implicit.

---

## Add a platoon

1. Add its squads to `group_setup[]`.
2. Add a `Platoons` class with `name`, `callsign`, `net`, `squads[]`.
3. Declare its net in `GHOST_Nets` (`config_nets.hpp`).
4. Add an MR channel with **the same name** in `ghost_radio_mrChannels`.
5. Add that net to the `nets[]` of whichever roles should read it — usually
   every element's two leaders.
6. Optionally give it an SR bank in `ghost_radio_srGroups`.

Ten tabs maximum, five to a row.

---

## Add a role to an existing squad

1. Write `config\<element>\config_<role>.hpp`.
2. Include it in `config_roles.hpp`.
3. Add its class name to that squad's role list in `group_setup[]` — once per
   slot it should occupy.
4. Gate it in `Role_Access` if it needs a rank.
5. Give it `groupArsenal = "Arsenal_<Element>";` to match its folder.

---

## Add a weapon everyone can draw

Add the class to `weapons[]` in `arsenal\common\weapons.hpp`. Nothing else.

## Add a weapon only one element can draw

Add it to that element's `config_arsenal.hpp` `weapons[]`. Confirm every role in
that folder carries the matching `groupArsenal`.

---

## Change what a role spawns with

Edit that role's `defaultLoadout[]`. It is a standard `setUnitLoadout` array —
build it in the Arsenal in the editor, export, paste.

**After changing a weapon, check three things:**

- the magazine loaded in the weapon entry
- the spare magazines in the uniform, vest and backpack
- the muzzle and optic

`setUnitLoadout` **silently drops** anything the weapon does not accept, so a
rifle swap that leaves 6.5 magazines in the vest is a man with nothing to shoot,
and nothing in the log says so.

---

## Issue one rifle across the whole task force

Change the first entry of every role's `defaultLoadout[]`, and the magazines and
muzzle with it. That is every role file in every element folder.

The arsenal is unaffected — everything stays drawable. Issued kit is not
permitted kit.

---

## Merge two identical elements onto one set of role classes

When two elements have byte-identical role files, they do not need two copies.

1. Keep one set. Rename the classes to something neutral for both.
2. Point both elements' `group_setup` rows at the kept classes.
3. Collapse the `Role_Access` entries to match.
4. Delete the other set and its includes from `config_roles.hpp`.

The cost: they now share a rank gate and a description. Give one of them
something of its own later and it needs its own set back — a copy of the files
and a change of names in the rows.

---

## Rename a platoon

1. `Platoons >> callsign` and `>> net`.
2. Every squad name in `group_setup[]`, and in that tab's `squads[]`.
3. Any `RadioNets` entry naming those squads.
4. `ghost_radio_srSquadChannel` and `ghost_radio_tfarNets`.
5. `ghost_radio_mrChannels` — the arm net's name.
6. `GHOST_Nets` — the arm net's declaration.
7. Every role's `nets[]` that listed the old arm net.
8. `MotorPool_<OldCallsign>` → `MotorPool_<NewCallsign>`, if it has a pool.

Role class names and folder names are internal and need not change — but if you
leave them, they name a callsign that no longer exists, which is a trap for the
next person. Rename them in the same pass.

---

## Add an admin

Edit the `ADMINS` macro at the top of `config_admins.hpp`. Nothing below it.

One list grants the debug console, the CBA settings whitelist and TAC//ADMIN.
