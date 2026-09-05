# Vendored art and models

## MRHMilsimTools

Everything in this folder except `icons/` comes from **MRHMilsimTools** by Mr H., which is licensed
**ADPL-SA** (Arma Public Licence – Share Alike). That permits redistribution and
modification within Arma 3 with attribution, on the same terms. Ghost is APL-SA,
which is compatible.

Contrast the GPL mods (ALiVE, AXE): ghost may reference their behaviour but never
copy their source — see `docs/DESIGN_INTEL_SYSTEM.md` §0.

| File | Source in MRHMilsimTools | Used for |
|---|---|---|
| `tablet.paa` | `MRHSoldierTab/paa/tablet.paa` | Bezel behind the hacking tablet dialog — **rebranded**, see below |
| `phone.paa` | `MRHFunctions/img/hackphone/hackphone.paa` | Handset behind the signal scanner screen |
| `tablet_icon.paa` | `MRHSoldierTab/models/Tablet/tableticon.paa` | Inventory icon for the Intrusion Tablet |
| `soldiertab.p3d` | `MRHSoldierTab/models/Tablet/soldiertab.p3d` | Model for the Intrusion Tablet item |
| `soldiertabtext.paa` | `MRHSoldierTab/models/Tablet/soldierTabText.paa` | Its texture |
| `hackphone.p3d` | `MRHFunctions/models/hackphone/hackphone.p3d` | Model for the Signal Scanner item |
| `p/hackphonetexture.paa` | `MRHFunctions/models/hackphone/hackPhonetexture.paa` | Its texture |
| `hackphone_icon.paa` | `MRHFunctions/models/hackphone/hackphoneIcon.paa` | Inventory icon for the Signal Scanner |

Everything drawn *inside* the tablet and scanner screens is ghost-original.

`tablet.paa` is **not** the file as vendored: `tools/gen_tablet_bezel.py` paints
out the "MRHTECH" wordmark on the chin and stamps the ghost logo there instead.
The untouched vendored copy lives at `tools/art/tablet_src.paa` — kept outside
`addons/` so a 1.1 MB source image is not packed into the pbo — and the script
always regenerates from it, so it can be rerun and retuned freely.

Note the two bezels are **square images of non-square devices** (`tablet.paa` is a
landscape tablet in a 2048² canvas, `phone.paa` a handset in a 512²). Their
controls must be sized accordingly or the device shears — `fnc_tabletLayout` keeps
its control square, and `fnc_scannerLayout` stretches to `SCN_ASPECT`, which is
the same stretch MRH's own dialog applies to the handset.

## icons/

Line-art glyphs sliced from a stock signals-intelligence icon sheet supplied by
the mod author (`AdobeStock_1965363267`), by `tools/gen_hack_icons.py`. **Confirm
the Adobe Stock licence covers redistribution in a released mod before shipping
these** — everything else in this folder is share-alike, this is not.

They are white on transparent so Arma's `colorText` tints them, which is what
lets a scanner row's glyph take the same state colour as its text for free.

| File | Sheet caption | Used for |
|---|---|---|
| `signal.paa` | Signal Waves | UAV row; Signal Scanner self-action |
| `jam.paa` | Signal Jamming | JAM row |
| `broken.paa` | Broken Signal | JAM row when the field is total |
| `mesh.paa` | Data Flow Tap | MESH row |
| `antenna.paa` | Antenna | NET row |
| `intercept.paa` | Interception Device | Hacking Tablet self-action |
| `listen.paa` | Listening System | *spare* — SIGINT product |
| `comms.paa` | Communication Interception | *spare* — remote unit hack |
| `uplink.paa` | Satellite Dish | *spare* — tower / uplink |
| `wireless.paa` | Wireless Hacking | *spare* — hack in progress |

## Notes for editing

Both p3ds are **MLOD**, so they open and edit in Object Builder — unlike the ODOL
models vendored elsewhere in ghost (e.g. `vests_odin`).

Each references its texture as a **bare lowercase filename with no path**, so the
.paa must sit in this folder and the name must match exactly:

- `soldiertab.p3d` → `soldiertabtext.paa`
- `hackphone.p3d` → `p\hackphonetexture.paa`

Arma texture lookups are case-sensitive even on Windows, so renaming either .paa
silently produces an untextured model. Both were renamed to lowercase on import
for exactly this reason.

MLOD p3ds store texture paths inline as fixed-length ASCIIZ, so a repath must be
byte-for-byte the same length as the original or the file corrupts
(`InvalidFaceVertexCount` on load). The one-letter `p\` folder exists purely to
pad `hackphone.p3d`'s texture path back to its original 50 bytes — do not
"tidy" it away.

Neither needs a `model.cfg`: they are inventory props with no skeleton, not
character-worn gear (which is where a missing model.cfg makes items render
invisible).
