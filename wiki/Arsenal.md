# Arsenal

Three sources merge into the ACE arsenal when a player takes a slot, in this
order:

```
Common_Arsenal            everyone, always
  + Arsenal_<Element>     his element's own, via the role's groupArsenal
  + the role's own        arsenalWeapons / Magazines / Items / Backpacks
```

That merge is `ghostD_groups_fnc_setupPlayer`, which hands the result to
`ace_arsenal_fnc_addVirtualItems`.

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

## Per-element arsenals

One file per element folder, for gear only that element may draw.

```cpp
// config\banshee\config_arsenal.hpp
class Arsenal_Banshee {
    weapons[] = {};
    magazines[] = {};
    backpacks[] = {};
    items[] = {};
};
```

Two things to get right:

**1. Every role in the folder points at it.**

```cpp
groupArsenal = "Arsenal_Banshee";
```

Omit the property and that role sees only the common arsenal.

**2. It must be a top-level class.** It is looked up as
`missionConfigFile >> "Arsenal_Banshee"`, so include it beside the common
arsenal at the **foot of `config_groups.hpp`** — *outside* `Dynamic_Roles`:

```cpp
#include "config_roles.hpp"
#include "arsenal\config_arsenal_common.hpp"

#include "ghost_6\config_arsenal.hpp"
#include "banshee\config_arsenal.hpp"
#include "nomad_2\config_arsenal.hpp"
```

Nest it inside `Dynamic_Roles` by mistake and the lookup finds nothing, with no
error — the role just gets the common arsenal.

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
