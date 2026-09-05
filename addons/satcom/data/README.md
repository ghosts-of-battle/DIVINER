# SatCom

Ported from **[AZM SatCom](https://github.com/alezm00/Satcom)** by Alezm, released
under **The Unlicense** — public domain, so it can be copied, modified and
redistributed without restriction. Nothing here is under a share-alike or
copyleft term.

| File | Source | Used for |
|---|---|---|
| `satcom_icon.paa` | `@AZM_SatCom/addons/azm_satcom/data/satcom_icon.paa` | Item picture and the interaction icons |

That icon is the only asset. Both models are vanilla:

- item — `\a3\Props_F_Enoch\Military\Equipment\BatteryPack_01_Closed_F.p3d`
- deployed mast — `\A3\Props_F_Enoch\Military\Camps\SatelliteAntenna_01_F.p3d`

## What changed in the port

- Re-prefixed to ghost's naming: `ghost_satcom_item`, `ghost_satcom_deployed`,
  `ghost_satcom_antenna`.
- **ACRE2 is a soft dependency.** The original hard-required `acre_main`; ghost's
  version does not, because `patrol_base` uses the deployed mast as its base
  beacon and an ACRE-less server would otherwise lose both. Every ACRE call is
  guarded by `ghost_satcom_fnc_hasAcre`, and the Connect / Disconnect actions are
  hidden rather than shown-and-broken when it is absent.
- Pack Up refuses on a mast that is anchoring a patrol base — see
  `ghost_satcom_fnc_canPickUp`.
- Pack Up now disconnects a connected radio before deleting the mast. The
  original only did this on its own pick-up path, and deleting a connected
  antenna leaves ACRE holding a dead reference.
- Deploy re-checks the carried item, and the delayed pick-up re-checks the mast
  still exists, so neither can be raced.
