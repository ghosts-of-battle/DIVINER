# Loading screen sources

The plates in `addons/loading/ui/loading` and where they came from.
`tools/art/gen_loading_screens.py` builds the `.paa` from the originals in
`art/`; the PNG masters here are its output, not hand-edited.

The `author` value is printed on the loading screen itself - see
`CfgLoadingScreen.hpp` - so it is the credit, not a note. It is a macro
argument, so it cannot contain a comma.

| Plate | Photographer | Licence | Source |
|---|---|---|---|
| `airdrop` | Pfc Eun Jun Choi, U.S. Army | Public domain | [DVIDS 9328915](https://www.dvidshub.net/image/9328915/gyeryong-ground-forces-festival-2025) |
| `flares` | Staff Sgt. Reginald Harvey, U.S. Army | Public domain | [DVIDS 9329611](https://www.dvidshub.net/image/9329611/gyeryong-ground-forces-festival-2025) |
| `tank` | Staff Sgt. Reginald Harvey, U.S. Army | Public domain | US Army release 250920-A-AR378-1199 |
| `mk47` | Sgt. Devon Bistarkey, U.S. Army National Guard | Public domain | [DVIDS 5709166](https://www.dvidshub.net/download/image/5709166) |
| `maxresdefault` | - | cleared by the user | - |
| `S291207115895` | - | cleared by the user | - |

All four are **works of the US federal government and carry no copyright**,
confirmed against their Wikimedia Commons file pages: every one reports
`LicenseShortName: Public domain` and `AttributionRequired: false`. The Ground
Forces Festival is a Republic of Korea event; the photographers covering it are
US Army, which is why the images are US public domain rather than Korean.

Attribution is therefore **not required**. The credits are printed anyway,
because naming the person who took the photograph costs a line of config.

The one live constraint: **US DoD imagery may not be used in a way that implies
DoD endorsement.** A loading screen behind our own mark is decoration, not a
claim of sponsorship, but a plate must not be captioned or framed as approval.

The last two rows say "Ghosts of Battle" in the config because that is what they
have always said. Whoever actually took them should be named instead.
