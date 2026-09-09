# config_nets.hpp

> **In storage since 2026-09-05.** The list is the `<unitId>.nets` document
> (`{section, items: {id: {id, name, order}}}` - `name` is the description,
> `order` the place on the rail) when TAC//PAC holds it, editable in the structure
> editor's NETS section. `ghostD_messaging_fnc_netNames` reads it, then this file,
> then the setting, and the server opens a mailbox per name from the same list.

Every named TAC//MSG mailbox in the mission, declared in one place.

**Loads:** `#include`d in [description.ext](description-ext).
**Declares:** `GHOST_Nets`.
**Read by:** `ghostD_messaging_fnc_roleNets`, `fnc_railNets`, and the server's
mailbox store at startup.

With this class present the addon's own "Shared mailboxes" **setting is
ignored**, so the nets live with the mission rather than in a profile somebody
has to remember to set.

---

## Shape

```cpp
class GHOST_Nets {
    nets[] = {
        // {name, description}
        {"C2", "Command and control - the detachment net"},
        {"C2.reports", "Filed reports: contact, situation, patrol"},

        {"FIRES", "Fire support coordination"},
        {"FIRES.cas", "Close air support requests"},
        {"FIRES.arty", "Artillery and mortar fire missions"},
        {"FIRES.trans", "Transport and lift requests"},

        {"MEDICAL", "Medical coordination"},
        {"MEDICAL.mist", "MIST reports"},
        {"MEDICAL.medevac", "Nine-line medevac requests"},

        {"ENGINEER", "Demolition, breaching, obstacle and repair work"},

        // The arms - one per platoon, named for it
        {"BANSHEE", "1st Platoon: Banshee 1-1 to 1-4"},
        {"NOMAD", "2nd Platoon: Nomad 2-1 to 2-4"}
    };
};
```

---

## Three rules

### 1. A dot is nesting, and nothing more

`FIRES.cas` is its own net, not a folder inside `FIRES`. A player can be on one
and not the other.

### 2. Do not declare squad nets here

They exist because the squads exist, and are named **exactly** as `group_setup`
names them — `"BANSHEE 1-1"`, not `"BANSHEE"`. A man reads his own because he is
*in* it.

Declaring them here makes every squad's traffic a named net the role gate then
has to exclude one by one. Leaving them out **is** the privacy rule.

### 3. Access is decided per role, not here

Each role's `nets[]` is its access list.

- A net absent from a role's list is not his.
- A role with no list gets none.
- If **no** role in the mission declares `nets[]`, the gate does not exist and
  every net reads as it always did.

---

## Instructions

**Add a net:** one `{name, description}` row, then add it to the `nets[]` of
every role that should read it. A declared net nobody lists is a mailbox nobody
opens.

**Add a platoon's arm net:** declare it here, add a matching MR channel of the
**same name** in [config_radio](config_radio), and set it as the platoon's `net`
in [config_groups](config_groups).

**Names must agree with the radio.** Nothing enforces it — see
[Cross-File Contracts](Cross-File-Contracts).

Related: [Nets](Nets) &middot; [config_radio](config_radio)
