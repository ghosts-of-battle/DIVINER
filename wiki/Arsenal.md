# Arsenal

Everything merges into the ACE arsenal when a player takes a slot, narrowest
last:

```
Common_Arsenal                  the mission file, everyone always
  + <unit>.arsenal              the database's common lists, everyone
  + <unit>.arsenal.plt_<PLT>    everyone in that platoon
  + <unit>.arsenal.sqd_<SQD>    everyone in that squad
  + <unit>.arsenal.role_<CLASS> that role only
  + the role's own              arsenalWeapons / Magazines / Items / Backpacks
```

They **add up**. No layer takes anything away.

That merge is `ghostD_groups_fnc_setupPlayer`, which hands the result to
`ace_arsenal_fnc_addVirtualItems`.

> **The narrower names are DERIVED, never stored (2026-09-09).** A role used to
> carry `groupArsenal = "Arsenal_Banshee";` - a class name typed by hand, which
> could name a class that did not exist, and on the reference unit all five of
> them named empty documents. There is no such property now. `plt_`, `sqd_` and
> `role_` are built from the platoon id, the squad name and the role class
> (upper case, anything else an underscore), so **creating one of these
> arsenals is creating the document and nothing else** - nothing to point at,
> nothing to spell wrong. The website computes the same name with the same
> rule.

---

## The array-name contract

> **The array names are a contract, not a style.** `fn_setupPlayer` switches on
> them and recognises exactly four things:
>
> | Array | Contents |
> |---|---|
> | `weapons[]` | Every weapon |
> | `magazines[]` | Every magazine |
> | `backpacks[]` | Every pack |
> | `items*[]` | **Anything whose name starts with `items`** |
>
> So `itemsOptics[]` and `itemsMedical[]` both count as items, and you can split
> them up for readability. **An array called anything else is read by nobody and
> silently does nothing.**

---

## `Common_Arsenal` — gear everyone can draw

`config\arsenal\config_arsenal_common.hpp` is an include list; the content is
one file per gear type.

```cpp
class Common_Arsenal {
    #include "common\weapons.hpp"
    #include "common\magazines.hpp"
    #include "common\backpacks.hpp"
    #include "common\items_uniforms.hpp"
    #include "common\items_headgear.hpp"
    #include "common\items_vests.hpp"
    #include "common\items_optics.hpp"
    #include "common\items_muzzles.hpp"
    #include "common\items_medical.hpp"
    #include "common\items_tools.hpp"
};
```

Each of those defines one array:

```cpp
// common\items_optics.hpp
itemsOptics[] = {
    "optic_Hamr",
    "optic_Arco"
};
```

Group by family and keep them alphabetical inside a group. The files get long —
the reference mission's `magazines.hpp` is over a thousand lines — and a list
you cannot scan is a list with duplicates in it.

---

## The narrower arsenals

Gear only one platoon, one squad or one role may draw. Each is a document, and
its id says who it belongs to:

| Document | Who draws from it | Where it is edited |
| --- | --- | --- |
| `<unit>.arsenal.plt_<PLATOON>` | everyone in that platoon | the platoon page |
| `<unit>.arsenal.sqd_<SQUAD>` | everyone in that squad | the squad page |
| `<unit>.arsenal.role_<CLASS>` | that role only | the role page, ARSENAL |

The id is the platoon id, squad name or role class in upper case with anything
else an underscore - `BANSHEE 1-1` is `sqd_BANSHEE_1_1`, `atlWraith` is
`role_ATLWRAITH`. `ghostD_groups_fnc_setupPlayer` builds those names as it
merges, and `Templates > Common arsenal` on the website lists the common
versions only, because these three are edited where their name comes from.

**A class in a mission file still works for the common arsenal.**
`missionConfigFile >> "Common_Arsenal"` is read first and the database adds to
it, so a mission that ships `config\arsenal\` keeps working and one that ships
none gets everything from `<unit>.arsenal`. There is no per-element class any
more - the old `Arsenal_<Element>` classes are read by nothing, and the
`groupArsenal` property that named them has been removed from the role
contract, from TAC//PAC's role editor and from the website.

---

## Per-role additions

The last layer. Use it for the kit that belongs to one *job* rather than one
element — the medic's blood, the JFO's designator batteries.

```cpp
arsenalWeapons[] = {};
arsenalMagazines[] = {"Laserbatteries"};
arsenalItems[] = {"Laserdesignator", "ACE_Vector", "ACRE_PRC152"};
arsenalBackpacks[] = {"B_UAV_01_backpack_F"};
```

---

## Issued kit is not permitted kit

`defaultLoadout[]` decides what a man **spawns wearing**. The arsenal decides
what he **may draw**. They are separate on purpose: the reference mission issues
one rifle to every role in the task force and still offers every platform in the
common arsenal.

Build a loadout in the Arsenal, export it, and paste it into `defaultLoadout[]`.

Next: [Motorpool and Vehicles](Motorpool-and-Vehicles).
