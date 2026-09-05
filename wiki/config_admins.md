# config_admins.hpp

One Steam ID list, three grants: the debug console, the CBA settings whitelist,
and TAC//ADMIN.

**Loads:** `#include`d **first** in [description.ext](description-ext).
**Declares:** `CfgGhostAdmins`, plus the `ADMINS` macro.
**Read by:** `description.ext` macro expansion, and `ghost_adminpanel_fnc_adminList`.

---

## The whole file

```cpp
#define ADMINS \
    "76561198000000000", /* You */ \
    "76561198000000001"  /* Someone else */

/* -------------------- Nothing to edit below here -------------------- */

#define DEBUG_ADMINS ADMINS
#define CBA_ADMINS ADMINS

class CfgGhostAdmins {
    admins[] = {ADMINS};
};
```

And in `description.ext`:

```cpp
enableDebugConsole[] = {DEBUG_ADMINS};
cba_settings_whitelist[] = {CBA_ADMINS};
```

---

## Instructions

**To add an admin:** add their Steam64 ID to the `ADMINS` macro. Nothing else.

- Every line but the last needs a trailing `\` — it is a multi-line macro.
- Every line but the last needs a trailing comma.
- Put the name in a `/* comment */` so the list stays readable.

**Include it first.** The arrays in `description.ext` expand these macros; if
the include comes after them, the file does not parse.

---

## Why one list

This used to be two files saying the same thing — `config_admins.hpp` for the
console and the settings whitelist, `config_adminlist.hpp` for the panel. That
is two lists to keep in step and one of them always out of date. There is one
now, and the panel and the console cannot disagree about who is an admin.

Related: [Other Systems](Other-Systems#admins)
