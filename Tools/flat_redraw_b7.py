#!/usr/bin/env python3
"""Flat colour batch 7: people, body, clothes, home (100 words). Shares helpers with flat_redraw.py.

Run: python3 Tools/flat_redraw_b7.py && python3 Tools/svg-lint/svg_lint.py <Words.xcassets> && python3 Tools/validate_svg_assets.py
"""

import math

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s, write, n


def P(cx, k=1.0, top="teal", bottom="deepTeal", hair="ink", style="short", skirt=False, base=176, arms="LR"):
    """Standing figure, feet on `base`, scaled by k. Hands and eyes are dropped when small to stay under the size cap."""
    b, d = base, k >= 0.8
    o = ""
    if style == "long":
        o += r(cx - 21 * k, b - 128 * k, 42 * k, 50 * k, hair, 14 * k)
    if style == "bun":
        o += c(cx, b - 144 * k, 9 * k, hair)
    leg = "skin" if skirt else bottom
    o += r(cx - 15 * k, b - 42 * k, 14 * k, 38 * k, leg, 4 * k) + r(cx + k, b - 42 * k, 14 * k, 38 * k, leg, 4 * k)
    o += r(cx - 19 * k, b - 6 * k, 19 * k, 6 * k, "ink", 2 * k) + r(cx, b - 6 * k, 19 * k, 6 * k, "ink", 2 * k)
    if skirt:
        o += p(f"M{n(cx - 22 * k)} {n(b - 46 * k)}H{n(cx + 22 * k)}L{n(cx + 31 * k)} {n(b - 20 * k)}H{n(cx - 31 * k)}Z", bottom)
    for side, sx in (("L", -1), ("R", 1)):
        if side in arms:
            o += ln(cx + sx * 22 * k, b - 88 * k, cx + sx * 30 * k, b - 52 * k, top, 6)
            if d:
                o += c(cx + sx * 30 * k, b - 48 * k, 5 * k, "skin")
    o += r(cx - 22 * k, b - 96 * k, 44 * k, 58 * k, top, 10 * k) + c(cx, b - 116 * k, 19 * k, "skin")
    if style != "bald":
        o += e(cx, b - 127 * k, 20 * k, 12 * k, hair)
    if d:
        o += eye(cx - 7 * k, b - 111 * k) + eye(cx + 7 * k, b - 111 * k)
    return o


def woman(cx, k=1.0, top="orange", bottom="teal", hair="brown", base=176):
    return P(cx, k, top, bottom, hair, "long", True, base)


def glasses(cx, k=1.0, base=176):
    return ring(cx - 7 * k, base - 111 * k, 6 * k, "ink", "none", 3) + ring(cx + 7 * k, base - 111 * k, 6 * k, "ink", "none", 3)


def heart(cx, cy, z, fill):
    return p(f"M{n(cx)} {n(cy + z)}C{n(cx - 2 * z)} {n(cy - 0.2 * z)} {n(cx - z)} {n(cy - 1.2 * z)} {n(cx)} {n(cy - 0.3 * z)}"
             f"C{n(cx + z)} {n(cy - 1.2 * z)} {n(cx + 2 * z)} {n(cy - 0.2 * z)} {n(cx)} {n(cy + z)}Z", fill)


def star(cx, cy, big, small, fill):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rad = big if i % 2 == 0 else small
        pts.append(f"{n(cx + rad * math.cos(a))} {n(cy + rad * math.sin(a))}")
    return p("M" + "L".join(pts) + "Z", fill)


def bar(x1, y1, x2, y2, body, w=16):
    return ln(x1, y1, x2, y2, body, w)


def curtains(a, b):
    return r(40, 24, 56, 152, a, 4) + r(244, 24, 56, 152, a, 4) + r(40, 24, 260, 14, b) + r(40, 172, 260, 8, "brown")


def note(x, y):
    return c(x, y, 6, "ink") + ln(x + 6, y, x + 6, y - 26, "ink", 3) + ln(x + 6, y - 26, x + 16, y - 20, "ink", 3)


def baby_bundle(x, y):
    return r(x - 14, y, 28, 26, "cream", 10) + c(x, y - 4, 10, "skin") + e(x, y - 11, 10, 5, "ink")


def balloon(x, y):
    return ln(x, y, x + 16, y - 70, "grey", 3) + e(x + 18, y - 90, 16, 20, "teal") + p(f"M{n(x + 14)} {n(y - 68)}L{n(x + 18)} {n(y - 64)}L{n(x + 22)} {n(y - 68)}Z", "teal")


def bricks():
    o = ""
    for i in range(5):
        y = 40 + i * 28
        if i % 2 == 0:
            xs = [(60 + j * 54, 50) for j in range(4)]
        else:
            xs = [(60, 23)] + [(87 + j * 54, 50) for j in range(3)] + [(249, 23)]
        for j, (x, w) in enumerate(xs):
            o += r(x, y, w, 24, "skinShade" if (i + j) % 2 else "skin", 2)
    return o


def tiles():
    return "".join(r(60 + i * 44, 44 + j * 32, 44, 32, "cream" if (i + j) % 2 else "teal") for i in range(5) for j in range(4))


def shelf(y, colors, x0=100):
    o, x = "", x0
    for i, col in enumerate(colors):
        w, h = 12 + (i * 5) % 9, 30 + (i * 7) % 12
        o += r(x, y - h, w, h, col, 2)
        x += w + 2
    return o


def reader_book(cx, b=176):
    return p(f"M{cx - 26} {b - 80}L{cx} {b - 72}L{cx + 26} {b - 80}V{b - 44}L{cx} {b - 36}L{cx - 26} {b - 44}Z", "cream") + ln(cx, b - 72, cx, b - 36, "brown", 3)


WORDS = {
    # --- people
    "family": lambda: P(100) + woman(160) + P(214, 0.62, "green", hair="brown") + woman(248, 0.5, "teal", "orange") + ground(60, 280),
    "actor": lambda: curtains("orange", "deepTeal") + P(170, top="ink", hair="brown", base=172) + p("M164 82L170 86L164 90Z M176 82L170 86L176 90Z", "orange"),
    "actress": lambda: curtains("teal", "deepTeal") + woman(170, 1.0, "orange", "orange", base=172) + star(250, 60, 9, 4, "cream"),
    "adult": lambda: P(130, 1.05) + woman(204, 1.0) + ground(60, 280),
    "artist": lambda: ln(200, 120, 184, 174, "brown", 5) + ln(256, 120, 272, 174, "brown", 5) + ln(228, 120, 228, 174, "brown", 5)
        + r(190, 56, 76, 64, "cream", 3) + c(210, 80, 8, "orange") + c(236, 92, 10, "teal") + e(222, 106, 16, 5, "green")
        + P(120, top="cream", hair="brown") + e(122, 44, 22, 8, "teal") + ln(142, 88, 190, 98, "cream", 6)
        + e(86, 124, 16, 11, "brown") + c(82, 120, 3, "orange") + c(92, 128, 3, "teal") + ground(),
    "baby": lambda: e(170, 174, 90, 8, "teal") + ln(138, 128, 120, 152, "skin", 9) + ln(202, 128, 220, 152, "skin", 9)
        + r(136, 112, 68, 56, "cream", 24) + c(150, 168, 9, "skin") + c(190, 168, 9, "skin") + c(170, 88, 34, "skin")
        + s("M170 56C164 46 178 44 174 54", "ink", 4) + eye(156, 86) + eye(184, 86) + c(148, 98, 5, "earPink") + c(192, 98, 5, "earPink")
        + c(170, 104, 6, "orange"),
    "band": lambda: P(96, 0.8) + P(170, 0.8, "orange", hair="brown") + woman(244, 0.8, "green", "deepTeal")
        + r(150, 136, 40, 26, "orange", 3) + e(170, 136, 20, 5, "cream")
        + e(114, 142, 16, 12, "brown") + ln(124, 136, 150, 108, "brown", 5) + ln(264, 176, 264, 120, "grey", 4) + c(264, 114, 6, "ink") + ground(60, 280),
    "boy": lambda: P(160, 0.95, "green", hair="brown") + c(224, 164, 14, "orange") + s("M210 164H238", "ink", 3) + s("M224 150V178", "ink", 3) + ground(60, 280),
    "girl": lambda: woman(160, 0.95, "orange", "teal") + ln(222, 176, 222, 150, "green", 4) + c(222, 142, 9, "cream") + c(222, 142, 4, "orange") + ground(60, 280),
    "boyfriend": lambda: P(130, hair="brown") + woman(206, 1.0, "orange", "deepTeal") + heart(168, 62, 12, "orange") + ground(60, 280),
    "girlfriend": lambda: woman(130, 1.0, "orange", "teal") + P(206, top="deepTeal", hair="brown") + heart(168, 62, 12, "orange")
        + ln(160, 130, 160, 108, "green", 4) + c(160, 102, 6, "cream") + ground(60, 280),
    "brother": lambda: P(130, 1.0, "teal", hair="brown") + P(200, 0.7, "green") + ground(60, 280),
    "sister": lambda: woman(130, 1.0, "orange", "teal") + woman(200, 0.7, "teal", "orange") + ground(60, 280),
    "cousin": lambda: P(100, 0.7) + woman(170, 0.7, "orange", "deepTeal") + P(240, 0.7, "green", hair="brown") + heart(170, 64, 10, "orange") + ground(60, 280),
    "customer": lambda: r(190, 112, 90, 66, "brown", 3) + r(184, 104, 102, 10, "skinShade", 2) + r(212, 82, 36, 22, "grey", 3) + r(218, 88, 24, 8, "cream")
        + P(120, hair="brown") + r(142, 126, 30, 36, "orange", 3) + s("M148 126C148 110 166 110 166 126", "brown", 4) + ground(),
    "dad": lambda: P(140, 1.05, "green", hair="brown") + P(206, 0.62, "orange", hair="ink") + ln(172, 128, 190, 134, "green", 6) + heart(206, 56, 9, "orange") + ground(60, 280),
    "mum": lambda: woman(150, 1.0, "orange", "teal") + baby_bundle(122, 108) + ground(),
    "father": lambda: P(150, top="deepTeal", hair="brown") + p("M146 84H154L156 106L150 114L144 106Z", "orange") + baby_bundle(184, 106) + ground(),
    "mother": lambda: woman(170, 1.0, "teal", "orange") + baby_bundle(200, 106) + ground(),
    "dancer": lambda: ln(158, 118, 150, 172, "skin", 9) + ln(182, 118, 206, 152, "skin", 9) + c(150, 172, 6, "earPink") + c(208, 152, 6, "earPink")
        + s("M158 72C130 70 124 54 132 40", "skin", 7) + s("M182 72C210 70 216 54 208 40", "skin", 7) + r(156, 64, 28, 44, "cream", 10)
        + e(170, 112, 44, 12, "cream") + e(170, 108, 28, 8, "orange") + c(170, 48, 17, "skin") + c(170, 28, 8, "ink") + e(170, 38, 18, 10, "ink")
        + eye(164, 50) + eye(176, 50),
    "daughter": lambda: woman(130, 1.0, "teal", "orange") + woman(200, 0.65, "orange", "teal") + heart(200, 62, 10, "orange") + ground(60, 280),
    "son": lambda: P(130, hair="brown") + P(200, 0.65, "green") + c(250, 164, 13, "orange") + s("M237 164H263", "ink", 3) + ground(60, 280),
    "driver": lambda: r(84, 72, 172, 96, "teal", 16) + r(100, 82, 140, 50, "cream", 8) + c(170, 112, 18, "skin") + e(170, 102, 19, 11, "ink")
        + eye(163, 112) + eye(177, 112) + ring(170, 142, 22, "ink", "none", 6) + ln(148, 142, 192, 142, "ink", 4) + ln(170, 142, 170, 160, "ink", 4)
        + r(96, 160, 32, 18, "ink", 4) + r(212, 160, 32, 18, "ink", 4) + c(104, 150, 8, "orange") + c(236, 150, 8, "orange") + r(84, 134, 172, 8, "deepTeal"),
    "farmer": lambda: ln(250, 176, 250, 120, "green", 4) + e(250, 112, 7, 14, "orange") + ln(268, 176, 268, 126, "green", 4) + e(268, 118, 7, 14, "orange")
        + P(120, top="teal", bottom="brown", hair="brown") + e(120, 46, 34, 7, "orange") + e(120, 38, 18, 11, "orange")
        + ln(152, 176, 152, 62, "brown", 5) + s("M138 62V84H166V62M152 62V84", "grey", 4) + ground(),
    "friend": lambda: P(130, hair="brown") + woman(210, 1.0, "orange", "deepTeal") + ln(152, 88, 188, 88, "teal", 6) + heart(170, 56, 11, "orange") + ground(60, 280),
    "grandfather": lambda: P(150, top="teal", bottom="brown", hair="grey") + glasses(150) + e(150, 76, 9, 3, "grey")
        + s("M184 176V120C184 106 204 106 204 120", "brown", 5) + ground(),
    "grandmother": lambda: P(150, top="orange", bottom="deepTeal", hair="grey", style="bun", skirt=True) + glasses(150)
        + p("M126 90C140 84 160 84 174 90L170 104H130Z", "teal") + ground(),
    "grandparent": lambda: P(104, top="teal", bottom="brown", hair="grey") + glasses(104) + P(236, top="orange", bottom="deepTeal", hair="grey", style="bun", skirt=True)
        + glasses(236) + P(170, 0.5, "green", hair="brown") + ground(60, 280),
    "husband": lambda: P(130, top="deepTeal", hair="brown") + woman(206, 1.0, "orange", "teal") + ring(168, 70, 12, "orange", "none", 5) + c(168, 56, 5, "cream") + ground(60, 280),
    "wife": lambda: woman(130, 1.0, "cream", "cream") + P(206, top="deepTeal", hair="brown") + ring(168, 70, 12, "orange", "none", 5) + c(168, 56, 5, "cream") + ground(60, 280),
    "man": lambda: P(170, 1.05, hair="brown") + ground(),
    "woman": lambda: woman(170, 1.0, "orange", "teal") + ground(),
    "person": lambda: P(170, 1.05, "grey", "greyShade", "greyShade") + ground(),
    "people": lambda: P(96, 0.9) + woman(170, 0.9, "orange", "deepTeal") + P(244, 0.9, "green", hair="brown") + ground(60, 280),
    "neighbour": lambda: r(50, 106, 84, 64, "skin", 3) + p("M44 110L92 66L140 110Z", "teal") + r(78, 128, 22, 42, "brown", 3) + r(106, 122, 18, 18, "cream")
        + woman(250, 1.0, "orange", "teal") + ln(272, 88, 284, 56, "orange", 6) + c(285, 52, 5, "skin")
        + r(138, 140, 84, 6, "brown", 2) + r(146, 126, 8, 46, "brown", 2) + r(172, 126, 8, 46, "brown", 2) + r(198, 126, 8, 46, "brown", 2) + ground(40, 290),
    "nurse": lambda: woman(170, 1.0, "cream", "teal") + r(154, 32, 32, 14, "cream", 3) + r(168, 35, 4, 8, "teal") + r(166, 37, 8, 4, "teal")
        + s("M160 84C160 110 182 110 182 84", "ink", 3) + c(171, 108, 4, "grey") + r(196, 106, 26, 34, "brown", 3) + r(200, 112, 18, 24, "cream") + ground(),
    "parent": lambda: P(104, hair="brown") + woman(236, 1.0, "orange", "deepTeal") + P(170, 0.55, "green", hair="ink") + ground(60, 280),
    "pilot": lambda: e(270, 52, 24, 6, "cream") + p("M262 52L250 32H262L278 52Z", "cream") + P(170, top="deepTeal", bottom="deepTeal")
        + p("M148 46C148 26 192 26 192 46Z", "ink") + r(146, 44, 50, 6, "deepTeal", 3) + c(170, 38, 4, "orange") + p("M150 90L170 82L190 90L170 96Z", "orange") + ground(),
    "player": lambda: P(140, top="green", bottom="cream", hair="brown") + c(212, 164, 13, "cream") + c(212, 164, 4, "ink") + star(140, 116, 9, 4, "cream") + ground(),
    "police": lambda: p("M170 40C196 50 214 50 226 46V104C226 134 198 156 170 168C142 156 114 134 114 104V46C126 50 144 50 170 40Z", "deepTeal")
        + p("M170 54C190 60 204 60 212 58V104C212 128 192 144 170 156C148 144 128 128 128 104V58C136 60 150 60 170 54Z", "teal") + star(170, 100, 36, 15, "orange"),
    "policeman": lambda: P(170, top="deepTeal", bottom="deepTeal") + p("M148 46C148 28 192 28 192 46Z", "deepTeal") + r(146, 44, 50, 6, "ink", 3) + c(170, 38, 4, "orange")
        + r(148, 128, 44, 6, "ink") + c(184, 102, 5, "orange") + ground(),
    "scientist": lambda: P(170, top="cream", bottom="deepTeal", hair="ink") + glasses(170) + r(204, 84, 12, 26, "cream", 2)
        + p("M204 108H216L234 142H186Z", "teal") + c(208, 130, 3, "cream") + c(216, 122, 2.5, "cream") + ground(),
    "singer": lambda: woman(170, 1.0, "orange", "orange") + ln(226, 176, 226, 104, "grey", 4) + c(226, 98, 7, "ink") + note(106, 80) + note(268, 60) + ground(60, 290),
    "student": lambda: r(122, 88, 14, 46, "brown", 5) + P(150, top="orange", bottom="deepTeal", hair="brown") + r(168, 126, 36, 8, "teal", 2) + r(166, 134, 38, 8, "green", 2) + ground(),
    "teacher": lambda: r(186, 36, 118, 92, "brown", 5) + r(192, 42, 106, 80, "deepTeal", 3) + ln(204, 62, 240, 62, "cream", 3) + ln(204, 78, 266, 78, "cream", 3)
        + ln(204, 94, 232, 94, "cream", 3) + woman(120, 1.0, "teal", "deepTeal") + glasses(120) + ln(150, 128, 196, 70, "brown", 3) + ground(),
    "teenager": lambda: P(170, 0.98, "green", hair="ink") + s("M150 64C150 34 190 34 190 64", "ink", 5) + r(145, 56, 9, 16, "orange", 3) + r(186, 56, 9, 16, "orange", 3)
        + r(200, 112, 12, 22, "ink", 2) + r(202, 116, 8, 14, "teal") + ground(),
    "tourist": lambda: P(140, top="orange", bottom="brown", hair="brown") + e(140, 46, 30, 6, "cream") + e(140, 40, 18, 10, "cream")
        + r(128, 96, 24, 16, "grey", 3) + c(140, 104, 5, "ink") + r(176, 128, 52, 40, "teal", 5) + s("M192 128V118H212V128", "brown", 5) + r(176, 142, 52, 5, "deepTeal") + ground(),
    "uncle": lambda: P(150, top="green", bottom="brown", hair="brown") + e(150, 75, 10, 3.5, "ink") + ln(172, 88, 196, 56, "green", 6) + c(198, 52, 5, "skin") + ground(),
    "aunt": lambda: woman(150, 1.0, "teal", "orange") + c(131, 70, 3, "orange") + c(169, 70, 3, "orange") + r(176, 122, 28, 22, "brown", 4)
        + s("M182 122C182 108 198 108 198 122", "brown", 4) + ground(),
    "visitor": lambda: r(200, 50, 70, 126, "brown", 4) + r(208, 58, 54, 118, "teal", 3) + c(214, 120, 4, "orange") + P(130, top="orange", hair="brown")
        + ln(160, 128, 160, 102, "green", 4) + c(160, 96, 7, "cream") + c(150, 100, 6, "orange") + c(170, 100, 6, "orange") + ground(),
    "waiter": lambda: P(150, top="cream", bottom="ink") + p("M142 84L150 88L142 92Z M158 84L150 88L158 92Z", "ink") + ln(172, 88, 190, 106, "cream", 6)
        + c(190, 106, 5, "skin") + e(208, 106, 34, 5, "greyShade") + r(194, 82, 18, 24, "cream", 3) + r(216, 88, 12, 18, "teal", 3) + ground(),
    "worker": lambda: P(150, top="teal", bottom="brown", hair="ink") + p("M128 50C128 24 172 24 172 50Z", "orange") + r(126, 48, 48, 5, "orange", 2)
        + r(130, 106, 40, 6, "orange") + ln(184, 150, 184, 102, "brown", 5) + r(168, 92, 32, 14, "greyShade", 3) + ground(),
    "writer": lambda: P(150, top="teal", hair="brown", style="long") + r(90, 120, 140, 10, "brown", 3) + r(100, 130, 10, 46, "brown", 2) + r(210, 130, 10, 46, "brown", 2)
        + r(120, 110, 48, 10, "cream", 2) + s("M184 118L206 92", "ink", 4) + r(222, 100, 16, 20, "orange", 3) + ground(60, 280),
    "child": lambda: P(150, 0.7, "orange", hair="brown") + balloon(171, 142) + ground(),
    "group": lambda: P(96, 0.66) + woman(148, 0.66, "orange", "deepTeal") + P(200, 0.66, "green", hair="brown") + woman(252, 0.66, "teal", "orange") + ground(50, 290),
    "team": lambda: P(96, 0.75, "teal", "cream", "brown") + P(150, 0.75, "teal", "cream") + P(204, 0.75, "teal", "cream", "brown") + P(258, 0.75, "teal", "cream")
        + c(177, 170, 8, "orange") + ground(50, 290),
    "reader": lambda: woman(170, 1.0, "teal", "orange") + reader_book(170) + ground(),
    "class": lambda: r(70, 30, 200, 62, "brown", 4) + r(76, 36, 188, 50, "deepTeal", 3) + ln(90, 52, 160, 52, "cream", 3) + ln(90, 68, 130, 68, "cream", 3)
        + "".join(c(x, 122, 13, "skin") + e(x, 114, 14, 7, hc) + r(x - 17, 134, 34, 18, col, 5) + r(x - 28, 148, 56, 7, "brown", 2) + r(x - 22, 155, 6, 22, "brown", 2) + r(x + 16, 155, 6, 22, "brown", 2)
                  for x, hc, col in ((100, "ink", "teal"), (170, "brown", "orange"), (240, "ink", "green"))),
    # --- body
    "back": lambda: r(112, 76, 116, 100, "skin", 36) + c(170, 52, 26, "ink") + c(142, 58, 5, "skin") + c(198, 58, 5, "skin") + e(146, 112, 14, 20, "skinShade", 15)
        + e(194, 112, 14, 20, "skinShade", -15) + ln(170, 82, 170, 148, "skinShade", 4) + r(112, 152, 116, 24, "deepTeal", 6),
    "body": lambda: ln(148, 82, 118, 124, "skin", 9) + ln(192, 82, 222, 124, "skin", 9) + ln(158, 126, 150, 172, "skin", 11) + ln(182, 126, 190, 172, "skin", 11)
        + r(148, 68, 44, 62, "skin", 12) + r(148, 118, 44, 14, "teal", 5) + c(170, 46, 18, "skin") + e(170, 36, 19, 9, "brown") + eye(163, 48) + eye(177, 48),
    "face": lambda: c(106, 104, 12, "skin") + c(234, 104, 12, "skin") + c(170, 100, 64, "skin") + e(170, 52, 62, 24, "brown") + c(148, 98, 9, "cream") + c(192, 98, 9, "cream")
        + eye(148, 98) + eye(192, 98) + c(138, 122, 8, "earPink") + c(202, 122, 8, "earPink") + p("M170 100L162 122H178Z", "skinShade") + s("M148 136C160 150 180 150 192 136", "ink", 4),
    "hair": lambda: r(100, 40, 140, 134, "brown", 56) + c(170, 100, 42, "skin") + e(170, 66, 46, 22, "brown") + eye(156, 100) + eye(184, 100)
        + s("M158 122C166 128 174 128 182 122", "ink", 4) + r(244, 136, 52, 10, "orange", 3) + "".join(ln(x, 146, x, 158, "orange", 3) for x in (250, 262, 274, 286)),
    "leg": lambda: r(134, 30, 58, 44, "teal", 8) + r(140, 70, 46, 70, "skin", 16) + e(163, 96, 22, 8, "skinShade") + r(142, 124, 42, 16, "cream", 3)
        + p("M140 140H186V158L228 164C244 168 242 178 226 178H140Z", "orange") + ground(100, 250),
    "mouth": lambda: p("M104 100C130 134 210 134 236 100Z", "ink") + r(124, 98, 92, 10, "cream", 3)
        + p("M96 100C112 62 150 72 170 82C190 72 228 62 244 100C210 90 130 90 96 100Z", "earPink")
        + p("M96 100C130 150 210 150 244 100C210 124 130 124 96 100Z", "earPink"),
    "nose": lambda: e(170, 104, 100, 70, "skin") + c(112, 84, 16, "cream") + c(228, 84, 16, "cream") + c(116, 84, 8, "ink") + c(224, 84, 8, "ink")
        + s("M88 58C104 44 124 46 134 56", "ink", 4) + s("M206 56C216 46 236 44 252 58", "ink", 4)
        + p("M170 66C186 100 198 122 194 138C184 150 156 150 146 138C142 122 154 100 170 66Z", "skinShade") + c(158, 136, 4, "ink") + c(182, 136, 4, "ink"),
    "tooth": lambda: p("M130 70C130 46 170 54 170 62C170 54 210 46 210 70C210 110 196 156 188 156C180 156 176 118 170 118C164 118 160 156 152 156C144 156 130 110 130 70Z", "cream")
        + ln(150, 66, 150, 86, "sand", 4) + c(160, 60, 3, "sand") + s("M142 112C146 130 148 140 152 148", "sandBorder", 3),
    # --- clothes
    "shirt": lambda: p("M126 46L152 40C158 52 182 52 188 40L214 46L250 92L228 108L212 92V168H126V92L110 108L88 92Z", "teal")
        + p("M152 40L170 64L160 74L146 52Z", "cream") + p("M188 40L170 64L180 74L194 52Z", "cream") + ln(170, 68, 170, 168, "deepTeal", 3)
        + c(170, 90, 3, "cream") + c(170, 116, 3, "cream") + c(170, 142, 3, "cream") + r(184, 100, 18, 18, "deepTeal", 2),
    "t_shirt": lambda: p("M132 46L152 56C160 64 180 64 188 56L208 46L252 84L230 108L212 94V166H128V94L110 108L88 84Z", "green")
        + e(170, 56, 19, 7, "deepTeal") + star(170, 118, 20, 9, "cream"),
    "shoe": lambda: p("M96 148V104C96 92 108 90 116 96C128 108 144 108 150 98L156 92C164 92 170 100 176 104L214 118C240 124 252 136 252 148Z", "teal")
        + r(92, 146, 164, 14, "cream", 7) + ln(150, 104, 164, 118, "cream", 3) + ln(134, 108, 150, 124, "cream", 3) + s("M110 122C130 132 160 136 200 136", "orange", 4) + ground(80, 270),
    "skirt": lambda: p("M138 56H202L250 166H90Z", "orange") + r(136, 50, 68, 14, "deepTeal", 3) + ln(156, 68, 134, 160, "skinShade", 3) + ln(170, 68, 170, 160, "skinShade", 3)
        + ln(184, 68, 206, 160, "skinShade", 3),
    "sweater": lambda: p("M126 50L152 42C158 58 182 58 188 42L214 50L244 126L220 134L206 100V166H134V100L120 134L96 126Z", "teal")
        + r(134, 152, 72, 14, "deepTeal", 3) + r(134, 90, 72, 8, "cream") + r(134, 112, 72, 8, "cream") + e(170, 50, 19, 7, "deepTeal"),
    "trousers": lambda: p("M128 46H212L228 170H184L170 98L156 170H112Z", "brown") + r(128, 46, 84, 12, "ink", 2) + c(170, 52, 4, "orange")
        + ln(144, 100, 136, 162, "skinShade", 3) + ln(196, 100, 204, 162, "skinShade", 3) + s("M134 64C140 74 150 74 156 64", "skinShade", 3),
    "umbrella": lambda: ln(170, 100, 170, 160, "ink", 5) + s("M170 160C170 178 150 178 150 164", "ink", 5)
        + p("M80 100C80 56 260 56 260 100C246 90 232 90 218 100C204 90 190 90 170 100C150 90 136 90 122 100C108 90 94 90 80 100Z", "teal")
        + ln(170, 62, 170, 98, "deepTeal", 3) + ln(170, 62, 122, 96, "deepTeal", 3) + ln(170, 62, 218, 96, "deepTeal", 3) + c(170, 60, 4, "ink")
        + ln(104, 126, 98, 142, "teal", 3) + ln(240, 120, 234, 136, "teal", 3) + ln(212, 142, 206, 158, "teal", 3),
    # --- home
    "bathroom": lambda: r(100, 38, 72, 62, "brown", 5) + r(106, 44, 60, 50, "cream", 3) + ln(114, 56, 124, 50, "sand", 3)
        + r(94, 108, 84, 14, "cream", 5) + r(124, 122, 24, 52, "cream", 3) + ln(136, 98, 136, 108, "grey", 5)
        + ln(206, 56, 284, 56, "brown", 4) + r(216, 56, 56, 66, "orange", 3) + ln(216, 78, 272, 78, "cream", 3) + ground(),
    "bedroom": lambda: BASE["bed"]() + r(130, 38, 80, 30, "brown", 3) + r(136, 44, 68, 18, "teal", 2) + r(264, 124, 40, 46, "brown", 3)
        + p("M272 96H296L292 124H276Z", "orange") + r(282, 124, 4, 6, "brown"),
    "kitchen": lambda: r(60, 34, 200, 44, "brown", 3) + ln(127, 36, 127, 76, "skinShade", 3) + ln(193, 36, 193, 76, "skinShade", 3)
        + c(116, 66, 3, "cream") + c(138, 66, 3, "cream") + c(182, 66, 3, "cream") + c(204, 66, 3, "cream")
        + r(60, 112, 200, 62, "skinShade", 3) + r(54, 104, 212, 10, "cream", 3) + r(130, 114, 70, 60, "grey", 3) + r(138, 128, 54, 30, "ink", 2)
        + r(142, 86, 46, 18, "teal", 3) + r(138, 84, 54, 5, "deepTeal", 2) + s("M156 74C150 64 162 58 156 48", "grey", 3) + s("M176 74C170 64 182 58 176 48", "grey", 3),
    "bath": lambda: p("M70 104H270C270 144 250 164 220 164H120C90 164 70 144 70 104Z", "cream") + r(64, 98, 212, 12, "cream", 5) + c(100, 170, 6, "brown") + c(240, 170, 6, "brown")
        + e(170, 106, 92, 6, "teal") + c(120, 96, 12, "cream") + c(144, 88, 10, "cream") + c(104, 84, 8, "cream") + e(196, 92, 14, 10, "orange") + c(210, 84, 7, "orange")
        + p("M216 84L226 87L216 90Z", "brown") + ln(252, 70, 252, 98, "grey", 6) + ln(252, 70, 226, 70, "grey", 6),
    "shower": lambda: ln(100, 176, 100, 50, "grey", 6) + ln(100, 50, 190, 50, "grey", 6) + p("M176 54H224L240 76H160Z", "greyShade")
        + "".join(ln(x, 90 + (x % 3) * 4, x - 4, 118 + (x % 3) * 8, "teal", 4) for x in (172, 188, 204, 220)) + e(200, 172, 62, 6, "teal") + ground(50, 120),
    "toilet": lambda: r(100, 50, 70, 58, "cream", 8) + c(135, 46, 6, "grey") + p("M96 112H250C250 142 230 160 200 160H150C120 160 96 142 96 112Z", "cream")
        + r(92, 104, 164, 10, "greyShade", 4) + r(150, 156, 60, 20, "cream", 4) + ground(),
    "table": lambda: r(74, 90, 192, 14, "brown", 4) + r(84, 104, 12, 70, "brown", 3) + r(244, 104, 12, 70, "brown", 3) + e(130, 88, 28, 5, "cream")
        + r(196, 66, 20, 24, "teal", 3) + r(160, 68, 20, 22, "teal", 6) + ln(170, 68, 170, 54, "green", 4) + c(170, 50, 6, "orange") + ground(),
    "window": lambda: p("M96 36H126V150L96 166Z", "orange") + p("M244 36H214V150L244 166Z", "orange") + r(116, 36, 108, 128, "brown", 4)
        + r(124, 44, 44, 54, "teal", 2) + r(172, 44, 44, 54, "teal", 2) + r(124, 104, 44, 52, "teal", 2) + r(172, 104, 44, 52, "teal", 2)
        + e(146, 64, 12, 6, "cream") + r(106, 162, 128, 12, "brown", 3),
    "wall": lambda: bricks() + ground(50, 290),
    "floor": lambda: tiles(),
    "room": lambda: r(64, 38, 212, 104, "cream", 2) + r(64, 136, 212, 40, "brown", 2) + r(64, 134, 212, 6, "deepTeal") + r(86, 56, 52, 48, "brown", 3)
        + r(91, 61, 42, 38, "teal", 2) + r(172, 106, 88, 34, "orange", 8) + r(166, 94, 16, 46, "orange", 6) + e(150, 162, 58, 8, "teal"),
    "lamp": lambda: p("M132 54H208L226 108H114Z", "orange") + r(164, 106, 12, 54, "brown", 3) + e(170, 164, 34, 8, "brown") + ground(80, 260),
    "fridge": lambda: r(125, 34, 90, 142, "cream", 10) + ln(125, 84, 215, 84, "greyShade", 3) + r(196, 52, 6, 24, "grey", 3) + r(196, 98, 6, 40, "grey", 3)
        + r(142, 104, 20, 20, "orange", 2) + c(150, 52, 5, "teal") + ground(),
    "blanket": lambda: p("M90 76C120 62 150 90 180 76C210 62 230 80 250 70V168H90Z", "orange") + r(90, 110, 160, 10, "teal") + r(90, 134, 160, 10, "teal")
        + "".join(ln(x, 168, x, 178, "orange", 3) for x in range(100, 250, 16)),
    "basket": lambda: s("M120 98C120 44 220 44 220 98", "brown", 6) + p("M100 98H240L224 168H116Z", "brown") + ln(106, 118, 234, 118, "skinShade", 3)
        + ln(110, 138, 230, 138, "skinShade", 3) + ln(114, 156, 226, 156, "skinShade", 3) + ln(140, 100, 134, 166, "skinShade", 3) + ln(200, 100, 206, 166, "skinShade", 3)
        + c(146, 92, 16, "green") + c(184, 90, 16, "orange") + c(166, 80, 14, "teal") + ground(),
    "apartment": lambda: r(84, 40, 96, 134, "teal", 3) + r(180, 84, 80, 90, "skin", 3)
        + "".join(r(x, y, 20, 18, "cream", 2) for y in (54, 86, 118) for x in (96, 126, 156) if not (y == 118 and x == 126))
        + "".join(r(x, y, 20, 18, "cream", 2) for y in (98, 128) for x in (192, 224))
        + r(120, 146, 26, 28, "brown", 2) + r(78, 34, 108, 8, "deepTeal", 2) + ground(60, 280),
    "flat": lambda: r(70, 84, 60, 90, "skin", 3) + r(130, 84, 60, 90, "teal", 3) + r(190, 84, 60, 90, "orange", 3)
        + p("M64 88L100 56L136 88Z", "brown") + p("M124 88L160 56L196 88Z", "brown") + p("M184 88L220 56L256 88Z", "brown")
        + r(88, 140, 22, 34, "brown", 2) + r(148, 140, 22, 34, "cream", 2) + r(208, 140, 22, 34, "brown", 2)
        + r(84, 104, 26, 22, "cream", 2) + r(144, 104, 26, 22, "cream", 2) + r(204, 104, 26, 22, "cream", 2) + ground(50, 290),
    "home": lambda: BASE["house"]() + heart(170, 70, 9, "cream") + ln(270, 176, 270, 128, "brown", 6) + c(270, 110, 24, "green"),
    "classroom": lambda: r(70, 32, 200, 66, "brown", 4) + r(76, 38, 188, 54, "deepTeal", 3) + ln(90, 56, 170, 56, "cream", 3) + ln(90, 72, 140, 72, "cream", 3)
        + "".join(r(x, 124, 54, 8, "brown", 2) + r(x + 6, 132, 6, 44, "brown", 2) + r(x + 42, 132, 6, 44, "brown", 2) + r(x + 12, 108, 14, 16, "teal", 2)
                  for x in (60, 140, 220)),
    "office": lambda: r(70, 122, 176, 10, "brown", 3) + r(80, 132, 10, 44, "brown", 2) + r(226, 132, 10, 44, "brown", 2) + r(110, 62, 72, 50, "greyShade", 5)
        + r(116, 68, 60, 36, "teal", 2) + r(138, 110, 14, 12, "grey") + r(198, 112, 32, 10, "cream", 2) + r(258, 134, 22, 42, "orange", 3) + e(269, 118, 10, 22, "green") + ground(),
    "hotel": lambda: r(100, 38, 140, 136, "skin", 3) + r(136, 24, 68, 18, "orange", 3) + star(152, 33, 6, 2.6, "cream") + star(170, 33, 6, 2.6, "cream") + star(188, 33, 6, 2.6, "cream")
        + "".join(r(x, y, 24, 18, "teal", 2) for y in (56, 88, 118) for x in (114, 158, 202)) + r(150, 142, 40, 32, "brown", 3) + p("M138 140H202L212 152H128Z", "deepTeal") + ground(),
    "library": lambda: r(90, 30, 160, 146, "brown", 4) + r(98, 38, 144, 130, "deepTeal", 2) + r(98, 80, 144, 5, "brown") + r(98, 122, 144, 5, "brown")
        + shelf(80, ["teal", "orange", "green", "cream", "orange", "teal", "green", "cream", "orange"], 102)
        + shelf(122, ["orange", "cream", "teal", "green", "teal", "orange", "cream", "green", "teal"], 102)
        + shelf(166, ["green", "teal", "cream", "orange", "green", "cream", "teal", "orange", "green"], 102),
    "shop": lambda: r(90, 70, 160, 104, "skin", 3) + r(90, 70, 160, 26, "orange") + "".join(r(x, 70, 16, 26, "cream") for x in range(90, 250, 32))
        + r(130, 42, 80, 20, "deepTeal", 3) + star(170, 52, 7, 3, "orange") + r(104, 106, 80, 52, "teal", 3) + c(124, 142, 8, "orange") + c(150, 142, 8, "green")
        + r(196, 106, 40, 68, "brown", 3) + c(228, 142, 3, "orange") + ground(),
    "pen": lambda: p("M134.5 140.6L125.5 127.4L105 151Z", "ink") + bar(130, 134, 214, 76, "teal") + bar(214, 76, 244, 56, "orange") + ln(160, 114, 190, 94, "deepTeal", 5)
        + s("M96 164C130 168 150 154 176 164", "ink", 3),
    "pencil": lambda: p("M134.5 140.6L125.5 127.4L105 151Z", "skin") + c(107, 150, 3, "ink") + bar(130, 134, 226, 68, "orange") + ln(232, 64, 244, 56, "earPink", 16)
        + ln(228, 66, 236, 61, "grey", 16) + s("M96 164C130 168 150 154 176 164", "ink", 3),
    "paper": lambda: p("M112 44Q112 40 116 40H200L228 68V168Q228 172 224 172H116Q112 172 112 168Z", "cream") + p("M200 40V68H228Z", "greyShade")
        + "".join(ln(128, y, 212, y, "grey", 3) for y in (88, 104, 120, 136, 152)),
    "letter": lambda: r(90, 66, 160, 100, "cream", 6) + s("M92 72L170 130L248 72", "grey", 4) + r(214, 78, 24, 28, "orange", 2) + star(226, 92, 7, 3, "cream")
        + ln(106, 140, 150, 140, "grey", 3) + ln(106, 152, 136, 152, "grey", 3),
}


if __name__ == "__main__":
    write(WORDS)
