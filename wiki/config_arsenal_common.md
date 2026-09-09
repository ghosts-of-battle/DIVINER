# arsenal\config_arsenal_common.hpp

Gear every player can draw regardless of role.

**Loads:** `#include`d by [config_groups](config_groups), outside
`Dynamic_Roles`.
**Declares:** `Common_Arsenal`.
**Read by:** `ghostD_groups_fnc_setupPlayer`.

---

## Shape

The class is only an include list. The content is one file per gear type in
`arsenal\common\`.

```cpp
class Common_Arsenal {
    #include "common\weapons.hpp"
    #include "common\magazines.hpp"
    #include "common\backpacks.hpp"
    #include "common\items_uniforms.hpp"
    #include "common\items_headgear.hpp"
    #include "common\items_vests.hpp"
    #include "common\items_facewear.hpp"
    #include "common\items_nvgs.hpp"
    #include "common\items_optics.hpp"
    #include "common\items_muzzles.hpp"
    #include "common\items_pointers_lights.hpp"
    #include "common\items_bipods.hpp"
    #include "common\items_binoculars.hpp"
    #include "common\items_medical.hpp"
    #include "common\items_tools.hpp"
};
```

Each of those defines **one array**:

```cpp
// common\items_optics.hpp
itemsOptics[] = {
    "optic_Hamr",
    "optic_Arco"
};
```

---

## The array-name contract

> `fn_setupPlayer` switches on the array name and recognises exactly four
> things:
>
> | Array | Contents |
> |---|---|
> | `weapons[]` | Every weapon |
> | `magazines[]` | Every magazine |
> | `backpacks[]` | Every pack |
> | `items*[]` | **Anything whose name starts with `items`** |
>
> So `itemsOptics[]` and `itemsMedical[]` both count as items, and you can split
> them for readability. **An array called anything else is read by nobody and
> silently does nothing.**

---

## Every file in `arsenal\common\`

One array each. The array name is what makes it work — see the contract above.

| File | Array | What goes in it |
|---|---|---|
| `weapons.hpp` | `weapons` | Every rifle, carbine, MG, launcher and sidearm anyone may draw |
| `magazines.hpp` | `magazines` | Every magazine and rocket. The longest file in the tree — group by family |
| `backpacks.hpp` | `backpacks` | Packs. Medic variants usually live in the medical role instead |
| `items_uniforms.hpp` | `itemsUniforms` | Fatigues |
| `items_headgear.hpp` | `itemsHeadgear` | Helmets and covers |
| `items_vests.hpp` | `itemsVests` | Carriers and rigs |
| `items_facewear.hpp` | `itemsFacewear` | Goggles, masks, shemaghs |
| `items_nvgs.hpp` | `itemsNvgs` | Night vision |
| `items_optics.hpp` | `itemsOptics` | Sights and scopes |
| `items_muzzles.hpp` | `itemsMuzzles` | Suppressors and muzzle devices |
| `items_pointers_lights.hpp` | `itemsPointersLights` | Lasers and lights |
| `items_bipods.hpp` | `itemsBipods` | Bipods |
| `items_binoculars.hpp` | `itemsBinoculars` | Binoculars, rangefinders, designators |
| `items_medical.hpp` | `itemsMedical` | Medical consumables everyone may carry |
| `items_tools.hpp` | `itemsTools` | Tools, map tools, and the radio every man is issued |

To add one of your own: create the file, give it a single array named
`weapons`, `magazines`, `backpacks` or `items<Something>`, and `#include` it in
the class above.

---

## Instructions

**Add gear everyone can draw:** add the class to the right array. Nothing else.

**Add a new gear file:** create it in `arsenal\common\`, give it one array named
`weapons`, `magazines`, `backpacks` or `items<Something>`, and `#include` it
here.

**Keep it scannable.** Group by family, alphabetical inside a group. These files
get long — the reference mission's `magazines.hpp` is over a thousand lines —
and a list you cannot scan is a list with duplicates in it.

**Issued is not permitted.** What a man spawns wearing is his role's
`defaultLoadout[]`. This is what he may *draw*. The reference mission issues one
rifle to every role and still offers every platform here.

Related: [Arsenal](Arsenal) &middot; [Element Folder Files](Element-Folder-Files)
