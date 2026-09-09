# DIVINER

The **mission framework** for Ghosts of Battle: the role screen, the tablet
suite, the messaging system, the arsenal and loadout system, the radio
programmer, the motorpool and the systems around them.

Pairs with the **framework mission**
(`framework.Stratis`) - copy that, rename it, and edit `config\`.

> **The mission is configuration. The code is the mod.**
> If you find yourself writing SQF to add a squad, a role or a weapon, stop.
> There is a config for it, and changing it needs no mod rebuild.

**[Documentation is in the wiki](https://github.com/ghosts-of-battle/DIVINER/wiki)**
- installation, the smallest mission that boots, a page per config file, the
cross-file contracts nothing validates for you, and a troubleshooting table.
The source for those pages is [`wiki/`](wiki) in this repo.

---

## Relationship to ghost

DIVINER is the **UI source of truth**. Fixes land here first and are synced back
to `ghost` once they are proven.

It was copied from ghost at `c47d7484` and re-prefixed **`ghost` to `ghostD`**,
so its classes are `ghostD_tacpad`, its functions `ghostD_tacpad_fnc_*` and its
PBOs `z\ghostD\addons\*`.

> **Do not load DIVINER and ghost together.** They are the same addons under
> different prefixes; running both gives you two of everything. DIVINER replaces
> ghost, it does not extend it.

## Building

```
hemtt check      # lints
hemtt build      # debug build into .hemttout/build
hemtt release    # staged release + archive in releases/
```

## Requires

CBA_A3, ACE3, and ACRE2 or TFAR.

## Credits

Ghosts of Battle. Built on the shoulders of CBA, ACE3, ACRE2 and the YMF role
framework.

### Based on & inspired by

Source projects are on GitHub — search the owner/repo path.

| Project | Licence |
|---|---|
| `ArmaForces/Mods` | GPL |
| `AXEmod/AXE` | GPLv3 |
| `Theseus-Aegis/Mods` | GPLv2 |
| `last-resort-gaming/LRG-Fundamentals` | MIT |
| `Theseus-Aegis/TheseusServices` | APL-SA |
| `BourbonWarfare/POTATO` | GPLv2 |

DIVINER itself ships under the Arma Public License Share Alike (APL-SA); see
[LICENSE](LICENSE).
