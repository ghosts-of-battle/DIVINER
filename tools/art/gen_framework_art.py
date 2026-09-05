# -*- coding: utf-8 -*-
"""Loadscreen and overview art for the framework mission.

    python tools/art/gen_framework_art.py            # PNG masters into art/
    python tools/art/gen_framework_art.py --paa      # ...and convert + install

THE LOOK IS THE SUITE'S OWN, and deliberately so: flat ground, exact hairline
rules, RobotoCondensed, one accent, zero rounded anything. It is the same
vocabulary gui.hpp states for the in-game screens, so the loading screen is not
a different mod's poster in front of the mission it loads.

TWO PICTURES, NOT ONE SCALED TWICE. The loadscreen is read full width for a few
seconds - it can carry a kicker, a rule and a tagline. The overview is a thumbnail
in a mission browser, where anything under about 40px of cap height is mush, so
it drops to the logo and one word.

The ghost logo is the source mark; it is alpha-trimmed here rather than by hand,
so replacing newlogo.png needs no measuring.
"""
import io
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
MISSION = (r"c:\Users\jwise\Documents\Arma 3 - Other Profiles\YonV"
           r"\missions\2040\framework.Stratis\data")

# The source mark - the unit's new logo (user, 2026-09-05). Alpha-trimmed
# below, so a new file needs no measuring.
LOGO = r"D:\Dropbox\Docs\adobe\ghostsB\newlogo_3_1024.png"
OUT = os.path.join(ROOT, "art")

# The suite's tokens, straight off gui.hpp.
GROUND = (13, 13, 13)
INK = (230, 230, 225)
MUTE = (147, 147, 143)
LINE = (89, 89, 87)
ACCENT = (217, 71, 51)

F_BOLD = r"C:\Windows\Fonts\RobotoCondensed-Bold.ttf"
F_REG = r"C:\Windows\Fonts\RobotoCondensed-Regular.ttf"

WORD = "FRAMEWORK"
TAG = "HERDING CATS SINCE 2034"
KICK = "MISSION FRAMEWORK"


def font(path, size):
    return ImageFont.truetype(path, size)


def tracked(draw, xy, text, fnt, fill, track):
    """PIL has no letter-spacing and the design lives on it."""
    x, y = xy
    for ch in text:
        draw.text((x, y), ch, font=fnt, fill=fill)
        x += draw.textlength(ch, font=fnt) + track
    return x - track - xy[0]


def tracked_w(draw, text, fnt, track):
    return sum(draw.textlength(c, font=fnt) for c in text) + track * (len(text) - 1)


def scanlines(img, every=3, strength=10):
    """The faintest suggestion of a panel, not a CRT filter."""
    d = ImageDraw.Draw(img, "RGBA")
    for y in range(0, img.height, every):
        d.line((0, y, img.width, y), fill=(0, 0, 0, strength))
    return img


def logo(height):
    im = Image.open(LOGO).convert("RGBA")
    im = im.crop(im.getchannel("A").getbbox())
    w = int(im.width * height / im.height)
    return im.resize((w, height), Image.LANCZOS)


def glow(mark, blur=18, alpha=70):
    """A cold halo so the mark sits ON the ground rather than in a hole."""
    a = mark.getchannel("A").filter(ImageFilter.GaussianBlur(blur))
    g = Image.new("RGBA", mark.size, INK + (0,))
    g.putalpha(a.point(lambda v: int(v * alpha / 255)))
    return g


# ============================================================ loadscreen ====
def loadscreen():
    W, H = 1024, 512
    img = Image.new("RGB", (W, H), GROUND)
    d = ImageDraw.Draw(img)

    scanlines(img)

    # The mark, left, with air around it.
    mark = logo(300)
    mx, my = 62, (H - mark.height) // 2
    # No halo behind the mark (user, 2026-09-05: "still see a border around
    # the logo") - the mark sits straight on the ground.
    img.paste(mark, (mx, my), mark)

    # The rule that separates mark from word - the suite's hairline, full bleed
    # vertically so it reads as a division of the plate and not a little tick.
    rx = mx + mark.width + 58
    d.rectangle([rx, 74, rx + 1, H - 74], fill=LINE)

    tx = rx + 46

    f_kick = font(F_BOLD, 17)
    f_tag = font(F_REG, 23)

    # THE WORD IS SIZED TO THE COLUMN, not guessed. At 108 it ran to the plate's
    # right edge with no margin at all; this fits it to what is actually left
    # after the mark and the rule, with the same 62 margin the mark gets.
    right = W - 62
    size = 108
    while size > 60:
        f_word = font(F_BOLD, size)
        word_w = tracked_w(d, WORD, f_word, -1.5)
        if tx + word_w <= right:
            break
        size -= 2

    # The block is centred against the mark rather than hung off its top, so the
    # two halves of the plate balance.
    block = 24 + 34 + size + 30 + 34
    top = (H - block) // 2

    tracked(d, (tx, top), KICK, f_kick, MUTE, 5.0)

    wy = top + 40
    tracked(d, (tx, wy), WORD, f_word, INK, -1.5)

    # ONE ACCENT, and it is this. A short bar under the word, the weight of the
    # header rule the screens use.
    ry = wy + size + 22
    d.rectangle([tx, ry, tx + 86, ry + 4], fill=ACCENT)

    # The tagline, tracked to sit under the word without competing with it.
    tracked(d, (tx, ry + 26), TAG, f_tag, MUTE, 2.6)

    # NO CORNER STAMP. The mark already says GHOSTS OF BATTLE, in a circle,
    # twice the size - a second one in the corner is the same word again.

    return img


# =============================================================== steam ======
def steam():
    """The Workshop preview - square, because Steam crops to square in grids."""
    S = 1024
    img = Image.new("RGB", (S, S), GROUND)
    d = ImageDraw.Draw(img)
    scanlines(img)

    mark = logo(430)
    mx, my = (S - mark.width) // 2, 150
    img.paste(mark, (mx, my), mark)

    f_kick = font(F_BOLD, 26)
    kw = tracked_w(d, KICK, f_kick, 8.0)
    tracked(d, ((S - kw) // 2, my + mark.height + 40), KICK, f_kick, MUTE, 8.0)

    right = S - 80
    size = 150
    while size > 90:
        f_word = font(F_BOLD, size)
        if 80 + tracked_w(d, WORD, f_word, -2.0) <= right:
            break
        size -= 2
    ww = tracked_w(d, WORD, f_word, -2.0)
    wy = my + mark.height + 84
    tracked(d, ((S - ww) // 2, wy), WORD, f_word, INK, -2.0)

    d.rectangle([(S - 110) // 2, wy + size + 20, (S + 110) // 2, wy + size + 24], fill=ACCENT)

    f_tag = font(F_REG, 27)
    tw = tracked_w(d, TAG, f_tag, 3.0)
    tracked(d, ((S - tw) // 2, wy + size + 46), TAG, f_tag, MUTE, 3.0)
    return img


# ============================================================== overview ====
def overview():
    """A thumbnail. Bigger mark, one word, no small type at all."""
    W, H = 1024, 512
    img = Image.new("RGB", (W, H), GROUND)
    d = ImageDraw.Draw(img)
    scanlines(img)

    mark = logo(340)
    f_word = font(F_BOLD, 132)
    track = -2.0
    word_w = tracked_w(d, WORD, f_word, track)

    gap = 54
    total = mark.width + gap + word_w
    x = int((W - total) // 2)
    my = (H - mark.height) // 2

    img.paste(mark, (x, my), mark)

    wx = int(x + mark.width + gap)
    wy = (H - 132) // 2 - 12
    tracked(d, (wx, wy), WORD, f_word, INK, track)

    # The accent, as a full-height rule between mark and word - the one place
    # this plate spends it.
    ax = int(x + mark.width + gap // 2)
    d.rectangle([ax - 2, my + 26, ax + 1, my + mark.height - 26], fill=ACCENT)

    f_tag = font(F_BOLD, 19)
    tw = tracked_w(d, TAG, f_tag, 5.0)
    tracked(d, (int((W - tw) // 2), wy + 158), TAG, f_tag, MUTE, 5.0)

    return img


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

    jobs = [("framework_loadscreen", loadscreen()), ("framework_overview", overview()), ("steam_preview", steam())]

    for name, img in jobs:
        p = os.path.join(OUT, name + ".png")
        img.save(p)
        print("wrote art/%s.png  %dx%d" % (name, img.width, img.height))

    if "--paa" not in sys.argv:
        print("\n(--paa to convert and install into the mission)")
        return

    if not os.path.isdir(MISSION):
        print("\nmission data folder not found: %s" % MISSION)
        return

    for name, _ in jobs:
        png = os.path.join(OUT, name + ".png")
        paa = os.path.join(MISSION, name + ".paa")
        if to_paa(png, paa):
            print("installed %s  (%d KB)" % (paa, os.path.getsize(paa) // 1024))


if __name__ == "__main__":
    main()
