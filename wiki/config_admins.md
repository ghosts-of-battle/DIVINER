# config_admins.hpp

> **Two lists, two jobs (2026-09-09).** `#define ADMINS` here feeds
> `enableDebugConsole[]` and `cba_settings_whitelist[]` and **nothing else** -
> the engine and CBA read those arrays out of description.ext before any script
> runs. **Who may open TAC//PAC and TAC//ADMIN is `<unit>.admins`**, edited on
> the PAC admin page or the website. The old `CfgGhostAdmins` class is read by
> nothing and has been removed from the missions.

And in `description.ext`:

```cpp
enableDebugConsole[] = {ADMINS};
cba_settings_whitelist[] = {ADMINS};
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
