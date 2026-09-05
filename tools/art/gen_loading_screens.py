# -*- coding: utf-8 -*-
"""Loading screen backgrounds for ghostD_loading.

    python tools/art/gen_loading_screens.py          # PNG masters into art/loading
    python tools/art/gen_loading_screens.py --paa    # ...convert and install the .paa

WHY THIS EXISTS. The backgrounds are photographs from outside, and they have to
arrive as 2048x1024 .paa that look like they belong to the same set. Doing that
by hand is four crops, four grades and four conversions per batch, done slightly
differently each time. SOURCES is the whole input: a file, a class name, and a
credit.

THE CLASS NAME IS THE FILENAME. CfgLoadingScreen builds the texture path out of
the class name, so what is named here is what goes in the config, and the two
cannot drift apart.

THE GRADE IS MEASURED, NOT EYEBALLED. The two screens that survived the licence
cull are grey, dark and contrasty; TARGET below is that look as numbers - black
point, white point and mean - and every image is stretched onto it. A flat
overcast sky and a sunlit desert come out belonging to the same set, which is
the only reason a mixed set of found photographs reads as deliberate.

THE CROP IS CHOSEN BY DETAIL. A 3:2 photograph loses a third of its height on
the way to 2:1 and the interesting third is rarely the middle, so the window
with the most edge energy wins, pulled gently back towards centre so it does not
end up hard against the top or bottom edge.
"""
import os
import subprocess
import sys

from PIL import Image, ImageFilter, ImageStat

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
ART = os.path.join(ROOT, "art")
OUT = os.path.join(ART, "loading")
INSTALL = os.path.join(ROOT, "addons", "loading", "ui", "loading")

W, H = 2048, 1024

# black point, white point, mean - taken off the two screens that survived the
# licence cull. Deep blacks, highlights held back off white, mid-dark overall.
TARGET_BLACK = 3
TARGET_WHITE = 215
TARGET_MEAN = 92

# source file (in art/), class name = output filename, credit printed on screen.
# NO COMMAS in a credit - CfgLoadingScreen takes it as a macro argument.
SOURCES = [
    ("Ground_Forces_Festival_2025_-_0074.jpg", "airdrop", "Pfc Eun Jun Choi - U.S. Army"),
    ("Ground_Forces_Festival_2025_-_0090.jpg", "flares", "Staff Sgt. Reginald Harvey - U.S. Army"),
    ("Gyeryong_Ground_Forces_Festival_2025_-_19_of_25.jpg", "tank", "Staff Sgt. Reginald Harvey - U.S. Army"),
    ("U.S._Army_Special_Operations_Command_Soldier_Fires_Mk_47_Striker_during_"
     "Joint_Forces_live-fire_range_in_Amman,_Jordan,_Aug_28,_2019.jpg", "mk47",
     "Sgt. Devon Bistarkey - U.S. Army National Guard"),
]


def percentile(img, p):
    hist = img.histogram()
    want = img.width * img.height * p / 100.0
    run = 0
    for value, count in enumerate(hist):
        run += count
        if run >= want:
            return value
    return 255


def crop_2to1(im):
    """The 2:1 window holding the most detail, biased back towards centre."""
    want_h = int(round(im.width / 2.0))
    if want_h >= im.height:                      # already wider than 2:1
        want_w = im.height * 2
        x = (im.width - want_w) // 2
        return im.crop((x, 0, x + want_w, im.height))

    # one edge-energy number per row, off a small greyscale copy
    small = im.convert("L").resize((256, max(1, im.height * 256 // im.width)))
    edges = small.filter(ImageFilter.FIND_EDGES)
    rows = [sum(edges.crop((0, y, edges.width, y + 1)).getdata()) for y in range(edges.height)]

    scale = edges.height / float(im.height)
    win = max(1, int(round(want_h * scale)))
    best, best_score = 0, None
    for top in range(0, edges.height - win + 1):
        centre = top + win / 2.0
        pull = 1.0 - 0.35 * abs(centre - edges.height / 2.0) / (edges.height / 2.0)
        score = sum(rows[top:top + win]) * pull
        if best_score is None or score > best_score:
            best, best_score = top, score

    y = min(im.height - want_h, int(round(best / scale)))
    return im.crop((0, y, im.width, y + want_h))


def grade(im):
    """Grey, then stretched onto the target black/white points and mean."""
    g = im.convert("L")

    lo, hi = percentile(g, 1), percentile(g, 99)
    if hi <= lo:
        lo, hi = 0, 255
    span = float(hi - lo)
    stretch = [
        min(255, max(0, int(round(TARGET_BLACK + (i - lo) * (TARGET_WHITE - TARGET_BLACK) / span))))
        for i in range(256)
    ]
    g = g.point(stretch)

    # gamma onto the target mean - one solve, not a search
    mean = max(1.0, min(254.0, ImageStat.Stat(g).mean[0]))
    import math
    gamma = math.log(TARGET_MEAN / 255.0) / math.log(mean / 255.0)
    # 2.6 is where the solve converges for a flat overcast sky, which is the
    # hardest case here - the airdrop plate needs 2.49 to come down into family
    # and anything looser than this clamp changes nothing for the others.
    gamma = max(0.55, min(2.6, gamma))
    g = g.point([min(255, int(round(255.0 * ((i / 255.0) ** gamma)))) for i in range(256)])

    return g.convert("RGB")


def to_paa(png, paa):
    if os.path.exists(paa):
        os.remove(paa)
    r = subprocess.run(["hemtt", "utils", "paa", "convert", png, paa],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print("   paa FAILED: %s" % (r.stderr or r.stdout).strip()[:200])
        return False
    return True


def main():
    if not os.path.isdir(OUT):
        os.makedirs(OUT)

    made = []
    for src, name, credit in SOURCES:
        path = os.path.join(ART, src)
        if not os.path.isfile(path):
            print("missing source: %s" % src)
            continue

        im = Image.open(path).convert("RGB")
        out = grade(crop_2to1(im).resize((W, H), Image.LANCZOS))

        png = os.path.join(OUT, name + ".png")
        out.save(png)
        st = ImageStat.Stat(out.convert("L"))
        print("%-10s %sx%s -> %dx%d  mean %.0f  std %.0f  (%s)"
              % (name, im.width, im.height, W, H, st.mean[0], st.stddev[0], credit))
        made.append((name, png))

    if "--paa" not in sys.argv:
        print("\n(--paa to convert and install into addons/loading/ui/loading)")
        return

    for name, png in made:
        paa = os.path.join(INSTALL, name + ".paa")
        if to_paa(png, paa):
            print("installed %s.paa  (%d KB)" % (name, os.path.getsize(paa) // 1024))

    print("\nCfgLoadingScreen.hpp lines:")
    for src, name, credit in SOURCES:
        print("        LOADING_SCREEN_CLASS(%s,%s);" % (name, credit))


if __name__ == "__main__":
    main()
