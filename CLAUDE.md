# DIVINER

The mission framework mod for Ghosts of Battle. HEMTT project, prefix `ghostD`,
PBOs at `z\ghostD\addons\*`. See [README.md](README.md) for what it is and
[SYNC.md](SYNC.md) for how it came off `ghost`.

## Scope

**Work only in this repo.** DIVINER is the UI source of truth - fixes land here
first, and are ported back to `ghost` later, by hand. Never edit a `ghost`
checkout as part of a DIVINER task, and never assume a change has been synced.

## Change notes are mandatory

Every change to `addons/`, `include/`, `mod.cpp`, `.hemtt/` or the build wiring
gets an entry in [CHANGES.md](CHANGES.md), written **in the same turn as the
change**, before reporting the work done. This is not a courtesy changelog: it
is the porting instruction sheet for `ghost`, and it is the only record of what
diverged. If it is not in CHANGES.md, it does not get synced.

Write the entry so someone with a `ghost` checkout, this file, and no memory of
the conversation can replay the change. That means:

- **Every file touched**, by full repo path, with the function or block inside
  it. `addons/tacpad/functions/fn_openApp.sqf` - not "the tacpad".
- **Exact identifiers.** Function names, `GVAR`/`QGVAR` names, config classes,
  CBA setting keys, event names, string literals. Spell them out; a later port
  is a search-and-replace against these names.
- **The why, in the failure's own terms** - what was observed to be wrong, not
  just what the fix does. A port that does not know the symptom cannot be
  verified.
- **Behaviour and contract changes** called out separately from refactors:
  anything a mission's `config\` sees, any renamed or removed public function,
  any new dependency between addons.
- **A sync verdict on every entry** - `yes`, `no` or `careful`, with a reason.
  See below.
- **How it was checked.** `hemtt check`, in-game, or not at all - say which.

Group related file edits into one entry with one heading. Do not split a single
fix across three entries, and do not merge two unrelated fixes into one.

### The sync verdict

`ghost` is the same code under the `ghost` prefix, minus DIVINER's removals.
Mark each entry:

- **`yes`** - a real fix or feature; port it. Note the mechanical rewrites the
  port needs: `ghostD_` to `ghost_`, `z\ghostD\addons` to `z\ghost\addons`.
- **`no`** - DIVINER-only divergence. The re-prefix itself, cTab removal, ALiVE
  stripping, anything in SYNC.md's Dropped list. Say which, so nobody ports it
  back and undoes the split.
- **`careful`** - touches code that differs between the two, or depends on an
  addon `ghost` has and DIVINER does not (or the reverse). Name the conflict.

**Mission-side globals stay `ghost_`.** `ghost_missionConfig_*`, `ghost_radio_*`
and `GHOST_Nets` are the mission/mod contract and are identical in both repos -
never rewrite those to `ghostD_`, in code or in a sync note.

### Also update, when the change touches them

- [SYNC.md](SYNC.md) - if the change resolves or adds an Outstanding item,
  drops something, or changes a reference still pointing at `ghost`.
- [wiki/](wiki) - if a config key, contract or troubleshooting symptom changed.
  The wiki is the published documentation, not internal notes.

## Building

`hemtt check` lints. `hemtt build` is the debug build. `hemtt release` stages an
archive into `releases/` and bumps `BUILD` in `addons/main/script_version.hpp`
via the post_release hook - so the build number in a CHANGES.md heading is the
build the change ships in, not the one in the file while you are editing.
