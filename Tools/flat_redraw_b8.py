#!/usr/bin/env python3
"""Flat colour batch 8: food, transport, nature, objects (100 words). Shares helpers with flat_redraw.py / flat_redraw_b7.py.

Run: python3 Tools/flat_redraw_b8.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s, wheel, write
from flat_redraw_b7 import heart, star


def stripes(x, y, w, h, a, b, step=20):
    return r(x, y, w, h, a) + "".join(r(x + i, y, step / 2, h, b) for i in range(0, int(w), step))


def bowl(cx, y, w, depth, fill):
    return p(f"M{cx - w} {y}H{cx + w}C{cx + w} {y + depth} {cx + w * 0.6} {y + depth * 1.15} {cx} {y + depth * 1.15}C{cx - w * 0.6} {y + depth * 1.15} {cx - w} {y + depth} {cx - w} {y}Z", fill)


def steam(x, y):
    return s(f"M{x} {y}C{x - 8} {y - 10} {x + 8} {y - 16} {x} {y - 26}", "grey", 3)


def cloud(cx, cy, fill="cream"):
    return c(cx - 22, cy, 18, fill) + c(cx + 4, cy - 10, 24, fill) + c(cx + 30, cy, 18, fill) + r(cx - 40, cy, 88, 18, fill, 9)


def pine(cx, base, h, fill="green", snow=False):
    o = r(cx - 5, base - 14, 10, 14, "brown") + p(f"M{cx} {base - h}L{cx + h * 0.42} {base - 12}H{cx - h * 0.42}Z", fill)
    if snow:
        o += p(f"M{cx} {base - h}L{cx + h * 0.2} {base - h * 0.62}Q{cx} {base - h * 0.55} {cx - h * 0.2} {base - h * 0.62}Z", "cream")
    return o


def plane_top(cx, cy, sc=1.0):
    a = lambda v: v * sc
    return (p(f"M{cx} {cy - a(6)}L{cx - a(80)} {cy + a(22)}V{cy + a(34)}L{cx} {cy + a(14)}L{cx + a(80)} {cy + a(34)}V{cy + a(22)}Z", "teal")
            + e(cx, cy + a(2), a(12), a(64), "cream") + p(f"M{cx} {cy + a(50)}L{cx - a(28)} {cy + a(66)}H{cx + a(28)}Z", "teal") + c(cx, cy - a(40), a(6), "teal"))


WORDS = {
    # --- food and drink
    "beer": lambda: s("M204 90C242 90 242 144 204 144", "greyShade", 8) + r(128, 74, 76, 92, "orange", 8) + e(166, 74, 40, 12, "cream") + c(140, 68, 12, "cream")
        + c(166, 60, 14, "cream") + c(192, 68, 12, "cream") + c(150, 112, 3, "cream") + c(172, 128, 3, "cream") + c(186, 104, 3, "cream") + ground(100, 240),
    "breakfast": lambda: e(170, 132, 86, 28, "teal") + e(170, 128, 74, 22, "cream") + e(150, 124, 24, 13, "sand") + c(150, 124, 8, "orange")
        + r(186, 112, 34, 26, "skin", 6) + s("M120 138C130 146 142 146 152 138", "earPink", 5) + r(236, 80, 26, 24, "cream", 5) + s("M262 88C278 88 278 102 262 102", "cream", 5),
    "butter": lambda: p("M112 108L132 88H248L228 108Z", "cream") + r(112, 108, 116, 46, "orange", 4) + p("M228 108L248 88V132L228 154Z", "skin") + ln(60, 164, 120, 150, "grey", 5) + ground(),
    "cafe": lambda: stripes(70, 36, 200, 26, "teal", "cream", 24) + ln(80, 62, 80, 176, "brown", 5) + ln(260, 62, 260, 176, "brown", 5)
        + e(170, 128, 60, 8, "brown") + ln(170, 134, 170, 176, "brown", 6) + r(142, 102, 26, 24, "cream", 5) + r(172, 102, 26, 24, "cream", 5)
        + s("M198 108C212 108 212 122 198 122", "cream", 4) + steam(155, 98) + ground(),
    "chocolate": lambda: r(108, 40, 124, 126, "brown", 6) + "".join(r(114 + i * 38, 46 + j * 30, 34, 26, "skinShade", 3) for i in range(3) for j in range(3))
        + r(108, 120, 124, 46, "orange", 4) + r(108, 120, 124, 8, "cream"),
    "cream": lambda: bowl(170, 140, 60, 26, "teal") + e(170, 134, 54, 18, "cream") + e(170, 110, 40, 16, "cream") + e(170, 88, 26, 14, "cream")
        + c(170, 68, 8, "orange") + ln(170, 62, 176, 52, "green", 3) + ground(),
    "dinner": lambda: ln(70, 50, 70, 160, "grey", 5) + ln(60, 50, 60, 76, "grey", 3) + ln(80, 50, 80, 76, "grey", 3) + ln(270, 50, 270, 160, "grey", 5)
        + p("M262 50C282 70 282 96 270 108V50Z", "grey") + e(170, 112, 76, 52, "greyShade") + e(170, 108, 68, 46, "cream") + e(158, 106, 32, 20, "brown")
        + c(200, 98, 6, "green") + c(212, 110, 6, "green") + c(198, 122, 6, "green"),
    "dish": lambda: e(170, 150, 96, 18, "grey") + p("M100 148C100 74 240 74 240 148Z", "cream") + c(170, 78, 8, "greyShade") + ln(120, 112, 134, 96, "sand", 4) + ground(),
    "drink": lambda: r(104, 76, 46, 96, "orange", 8) + r(104, 108, 46, 24, "cream") + p("M186 96H240L232 170H194Z", "teal") + r(182, 88, 62, 10, "cream", 3)
        + ln(214, 88, 222, 56, "orange", 5) + ground(),
    "food": lambda: r(88, 118, 104, 42, "skin", 18) + ln(120, 124, 128, 148, "skinShade", 3) + ln(148, 124, 156, 148, "skinShade", 3) + c(222, 138, 22, "green")
        + ln(222, 116, 226, 102, "brown", 4) + r(254, 96, 34, 64, "cream", 8) + r(260, 84, 22, 14, "teal", 3) + ground(70, 300),
    "fruit": lambda: bowl(170, 118, 76, 34, "brown") + c(130, 104, 20, "green") + c(172, 96, 22, "orange") + c(212, 104, 20, "deepTeal") + c(150, 86, 14, "orange")
        + c(194, 84, 14, "green") + ln(130, 84, 134, 74, "brown", 3) + ground(),
    "ice": lambda: e(170, 164, 90, 8, "teal") + r(106, 100, 56, 56, "cream", 8) + r(106, 146, 56, 10, "grey", 5) + r(172, 110, 56, 56, "cream", 8) + r(172, 156, 56, 10, "grey", 5)
        + r(138, 56, 54, 54, "cream", 8) + r(138, 100, 54, 10, "grey", 5) + ln(116, 112, 116, 130, "sand", 4) + ln(182, 122, 182, 140, "sand", 4) + ln(148, 68, 148, 84, "sand", 4),
    "lunch": lambda: s("M150 76C150 52 194 52 194 76", "ink", 5) + r(110, 76, 120, 88, "teal", 10) + r(104, 70, 132, 18, "deepTeal", 5) + r(160, 80, 20, 12, "orange", 3)
        + r(110, 128, 120, 6, "deepTeal") + c(262, 146, 20, "green") + ln(262, 126, 266, 112, "brown", 4) + ground(),
    "meal": lambda: r(70, 134, 200, 16, "brown", 6) + e(150, 120, 62, 20, "cream") + e(140, 118, 24, 11, "brown") + c(172, 114, 6, "green") + c(184, 120, 6, "green")
        + r(222, 84, 28, 50, "cream", 6) + r(222, 104, 28, 30, "teal", 3) + ln(80, 116, 80, 134, "grey", 4),
    "meat": lambda: p("M104 110C104 70 170 62 220 80C250 92 250 140 210 152C160 168 104 150 104 110Z", "brown") + s("M112 110C112 78 170 70 214 86", "cream", 6)
        + c(160, 114, 14, "cream") + c(160, 114, 6, "greyShade") + ln(190, 100, 214, 112, "skinShade", 3) + ln(186, 130, 214, 134, "skinShade", 3) + ground(),
    "menu": lambda: r(106, 30, 128, 148, "brown", 6) + r(114, 38, 112, 132, "cream", 3) + ln(134, 58, 206, 58, "ink", 3)
        + "".join(ln(130, y, 156, y, "grey", 3) + ln(180, y, 210, y, "grey", 3) for y in (82, 104, 126, 148)),
    "milk": lambda: p("M130 84L170 54L210 84Z", "cream") + r(130, 84, 80, 88, "cream", 3) + r(130, 112, 80, 34, "teal") + c(170, 129, 10, "cream") + ln(170, 54, 170, 84, "grey", 3) + ground(),
    "onion": lambda: p("M158 74C160 50 170 46 170 30C170 46 180 50 182 74Z", "green") + c(170, 118, 50, "skin") + s("M170 70C140 90 140 150 170 166", "skinShade", 3)
        + s("M170 70C200 90 200 150 170 166", "skinShade", 3) + ln(170, 166, 170, 176, "cream", 3),
    "orange": lambda: c(170, 110, 54, "orange") + e(196, 58, 20, 8, "green", -20) + ln(170, 58, 172, 50, "brown", 4) + c(150, 100, 3, "skinShade") + c(190, 124, 3, "skinShade")
        + c(166, 134, 3, "skinShade") + c(194, 92, 3, "skinShade") + ground(100, 240),
    "pepper": lambda: p("M120 100C120 70 220 70 220 100C230 140 210 168 170 168C130 168 110 140 120 100Z", "green") + r(164, 56, 12, 22, "brown", 4)
        + s("M150 90C140 120 146 150 156 162", "deepTeal", 3) + s("M190 90C200 120 194 150 184 162", "deepTeal", 3) + e(150, 100, 6, 14, "cream", 10) + ground(100, 240),
    "potato": lambda: e(170, 112, 68, 46, "skinShade", -10) + c(146, 104, 4, "brown") + c(180, 94, 4, "brown") + c(196, 126, 4, "brown") + c(160, 132, 4, "brown")
        + e(150, 92, 10, 5, "skin", -20) + ground(100, 240),
    "restaurant": lambda: ln(170, 26, 170, 54, "ink", 3) + p("M144 74L156 54H184L196 74Z", "orange") + e(110, 126, 38, 8, "cream") + ln(110, 134, 110, 172, "brown", 6)
        + e(230, 126, 38, 8, "cream") + ln(230, 134, 230, 172, "brown", 6) + c(110, 118, 8, "orange") + c(230, 118, 8, "teal") + r(76, 150, 10, 26, "brown", 3)
        + r(264, 150, 10, 26, "brown", 3) + ground(),
    "rice": lambda: ln(214, 40, 160, 96, "brown", 4) + ln(232, 48, 178, 102, "brown", 4) + bowl(170, 110, 60, 46, "teal") + p("M116 112C120 70 220 70 224 112Z", "cream")
        + ln(150, 92, 156, 98, "grey", 3) + ln(176, 86, 182, 92, "grey", 3) + ln(196, 100, 202, 106, "grey", 3) + ground(),
    "salad": lambda: bowl(170, 108, 74, 54, "cream") + e(130, 98, 28, 12, "green", -15) + e(170, 90, 30, 14, "green") + e(210, 98, 28, 12, "green", 15) + c(150, 84, 11, "orange")
        + c(196, 82, 10, "skinShade") + e(172, 74, 16, 8, "green", 20) + r(100, 106, 140, 6, "greyShade", 3) + ground(),
    "salt": lambda: p("M142 90H198L204 160Q204 170 194 170H146Q136 170 136 160Z", "cream") + p("M146 90V70C146 52 194 52 194 70V90Z", "grey") + c(158, 72, 2.5, "ink")
        + c(170, 66, 2.5, "ink") + c(182, 72, 2.5, "ink") + c(110, 168, 3, "cream") + c(228, 170, 3, "cream") + c(236, 164, 3, "cream") + ground(80, 260),
    "sandwich": lambda: r(100, 140, 140, 22, "skin", 10) + e(110, 130, 28, 10, "green") + e(170, 130, 40, 11, "green") + e(230, 130, 28, 10, "green") + r(110, 112, 120, 16, "skinShade", 4)
        + p("M100 112C100 62 240 62 240 112Z", "skin") + c(140, 88, 3, "cream") + c(170, 80, 3, "cream") + c(200, 88, 3, "cream") + ground(),
    "soup": lambda: bowl(170, 110, 62, 46, "teal") + e(170, 110, 62, 10, "orange") + c(150, 110, 5, "green") + c(184, 108, 5, "cream") + steam(150, 86) + steam(186, 86)
        + ln(240, 56, 204, 104, "grey", 5) + e(246, 50, 12, 8, "grey", -45) + ground(),
    "sugar": lambda: r(134, 94, 44, 40, "cream", 5) + r(158, 54, 44, 40, "cream", 5) + bowl(170, 126, 66, 34, "teal") + r(104, 124, 132, 8, "deepTeal", 3) + c(150, 114, 8, "cream") + ground(),
    "supermarket": lambda: ln(66, 68, 92, 80, "greyShade", 5) + p("M92 80H252L230 140H114Z", "grey") + "".join(ln(x, 82, x + 4, 138, "greyShade", 3) for x in (130, 160, 190, 220))
        + ln(106, 108, 242, 108, "greyShade", 3) + ln(114, 146, 230, 146, "greyShade", 5) + c(128, 164, 9, "ink") + c(216, 164, 9, "ink") + r(134, 56, 24, 28, "orange", 3)
        + r(170, 50, 22, 34, "teal", 4) + c(214, 70, 14, "green") + ground(60, 280),
    "tea": lambda: e(170, 148, 86, 10, "greyShade") + p("M126 90H214V118C214 142 196 150 170 150C144 150 126 142 126 118Z", "cream") + s("M214 100C242 98 242 130 212 128", "cream", 7)
        + e(170, 90, 44, 7, "brown") + ln(170, 90, 148, 60, "grey", 3) + r(140, 52, 14, 14, "orange", 2) + steam(184, 76),
    "tomato": lambda: c(170, 112, 54, "skinShade") + star(170, 68, 22, 8, "green") + e(150, 92, 8, 14, "earPink", 25) + ground(100, 240),
    "vegetable": lambda: r(118, 120, 14, 50, "cream", 4) + c(100, 108, 18, "green") + c(126, 96, 22, "green") + c(152, 108, 18, "green") + p("M184 84H236L214 172Z", "orange")
        + e(204, 70, 6, 16, "green", -15) + e(218, 68, 6, 16, "green", 15) + ln(200, 104, 214, 108, "skinShade", 3) + ln(204, 128, 216, 132, "skinShade", 3) + ground(),
    "water": lambda: p("M130 54H210L202 168H138Z", "cream") + p("M134 92H206L202 168H138Z", "teal") + ln(146, 66, 150, 120, "cream", 3) + p("M262 60C250 84 244 96 262 106C280 96 274 84 262 60Z", "teal") + ground(100, 240),
    "wine": lambda: r(236, 90, 28, 82, "green", 8) + r(244, 56, 12, 40, "green", 4) + r(242, 50, 16, 10, "brown", 3) + p("M120 50H180C184 100 170 120 150 124C130 120 116 100 120 50Z", "cream")
        + p("M122 82H178C178 106 168 118 150 122C132 118 122 106 122 82Z", "skinShade") + r(146, 122, 8, 40, "cream") + e(150, 164, 30, 6, "cream") + ground(60, 280),
    "market": lambda: stripes(70, 38, 200, 28, "orange", "cream", 24) + ln(80, 66, 80, 176, "brown", 5) + ln(260, 66, 260, 176, "brown", 5) + r(86, 118, 168, 12, "brown", 3)
        + r(96, 130, 10, 46, "brown", 2) + r(234, 130, 10, 46, "brown", 2) + c(118, 108, 11, "green") + c(142, 108, 11, "orange") + c(166, 108, 11, "green") + c(190, 108, 11, "skinShade")
        + c(214, 108, 11, "orange") + ground(),
    "cooking": lambda: p("M130 164C120 140 140 128 150 100C156 128 180 124 170 164Z", "orange") + p("M190 164C184 148 198 140 204 124C210 142 226 144 218 164Z", "orange")
        + r(110, 70, 120, 56, "teal", 6) + r(104, 66, 132, 8, "deepTeal", 3) + c(170, 60, 5, "ink") + ln(244, 100, 266, 74, "brown", 5) + e(272, 66, 12, 8, "brown", -50) + ln(100, 170, 240, 170, "ink", 6),
    "knife": lambda: r(76, 106, 66, 26, "brown", 8) + p("M138 106H206C232 106 252 118 262 132H138Z", "grey") + ln(142, 132, 262, 132, "greyShade", 3) + c(96, 119, 3, "cream") + c(122, 119, 3, "cream") + ground(60, 280),
    # --- transport
    "ambulance": lambda: r(80, 76, 180, 80, "cream", 10) + r(80, 130, 180, 8, "teal") + r(206, 86, 44, 28, "teal", 4) + r(150, 94, 12, 34, "teal") + r(139, 105, 34, 12, "teal")
        + c(144, 68, 6, "orange") + wheel(118, 158) + wheel(222, 158) + ground(),
    "bridge": lambda: r(40, 142, 260, 36, "teal", 4) + r(100, 52, 12, 92, "brown", 3) + r(228, 52, 12, 92, "brown", 3) + r(40, 112, 260, 12, "grey", 3)
        + s("M40 112C70 80 96 58 106 56", "ink", 4) + s("M106 56C140 104 200 104 234 56", "ink", 4) + s("M234 56C244 58 270 80 300 112", "ink", 4)
        + "".join(ln(x, y, x, 112, "ink", 3) for x, y in ((140, 88), (170, 94), (200, 88))),
    "flight": lambda: cloud(86, 140) + cloud(262, 70) + plane_top(170, 76, 0.9) + c(170, 152, 4, "cream") + c(170, 164, 4, "cream") + c(170, 175, 4, "cream"),
    "journey": lambda: p("M40 130L110 60L170 120L220 80L300 150V176H40Z", "green") + s("M170 168C110 154 230 138 170 118C130 104 190 90 170 78", "greyShade", 16) + c(250, 50, 18, "orange"),
    "passport": lambda: r(120, 40, 100, 134, "teal", 8) + ring(170, 96, 26, "orange", "none", 4) + s("M170 70V122M144 96H196", "orange", 3) + s("M152 78C164 90 164 102 152 114", "orange", 3)
        + s("M188 78C176 90 176 102 188 114", "orange", 3) + r(144, 140, 52, 6, "orange", 3) + r(152, 152, 36, 6, "orange", 3),
    "plane": lambda: plane_top(170, 96, 1.2),
    "road": lambda: p("M136 40H204L284 176H56Z", "greyShade") + "".join(r(166, y, 8, 14 + (y - 52) // 8, "cream") for y in (56, 84, 116, 152)) + ln(138, 44, 62, 176, "cream", 3) + ln(202, 44, 278, 176, "cream", 3),
    "rocket": lambda: p("M144 110L112 148L144 138Z", "orange") + p("M196 110L228 148L196 138Z", "orange") + p("M170 30C206 56 208 100 198 140H142C132 100 134 56 170 30Z", "cream")
        + p("M170 30C186 42 194 56 196 70H144C146 56 154 42 170 30Z", "orange") + c(170, 94, 15, "teal") + p("M154 140L170 176L186 140Z", "orange"),
    "station": lambda: p("M70 90L170 40L270 90Z", "brown") + r(84, 90, 172, 70, "skin", 3) + ring(170, 70, 16, "brown", "cream", 5) + ln(170, 70, 170, 60, "ink", 3) + ln(170, 70, 178, 74, "ink", 3)
        + r(100, 110, 36, 50, "deepTeal", 3) + r(204, 110, 36, 50, "deepTeal", 3) + r(152, 112, 36, 48, "brown", 3) + r(40, 160, 260, 10, "grey", 2) + ln(40, 176, 300, 176, "ink", 4),
    "street": lambda: r(60, 70, 60, 106, "skin", 3) + r(120, 46, 56, 130, "teal", 3) + r(176, 84, 66, 92, "orange", 3) + "".join(r(x, y, 14, 16, "cream", 2) for y in (82, 112, 142) for x in (68, 98))
        + "".join(r(x, y, 14, 16, "cream", 2) for y in (58, 90, 122) for x in (130, 154)) + r(190, 100, 16, 20, "cream", 2) + r(214, 100, 16, 20, "cream", 2)
        + ln(262, 176, 262, 70, "ink", 5) + c(262, 64, 8, "orange") + ground(40, 300),
    "taxi": lambda: r(150, 56, 40, 14, "cream", 3) + r(160, 60, 20, 6, "ink") + p("M84 130V112L118 104L138 76H202L226 104L256 112V130Z", "orange") + p("M146 84H170V104H132Z", "cream")
        + p("M178 84H198L214 104H178Z", "cream") + "".join(r(94 + i * 14, 118, 7, 7, "ink") for i in range(0, 11, 2)) + r(84, 124, 172, 10, "deepTeal", 3) + wheel(122, 136) + wheel(218, 136) + ground(),
    "ticket": lambda: r(90, 66, 160, 80, "orange", 8) + c(90, 106, 12, "halo") + c(250, 106, 12, "halo") + "".join(c(196, y, 3, "cream") for y in (76, 90, 104, 118, 132))
        + star(138, 106, 22, 10, "cream") + ln(212, 90, 236, 90, "skinShade", 3) + ln(212, 106, 232, 106, "skinShade", 3) + ln(212, 122, 228, 122, "skinShade", 3),
    "traffic": lambda: r(144, 30, 52, 116, "ink", 10) + c(170, 58, 13, "skinShade") + c(170, 88, 13, "orange") + c(170, 118, 13, "green") + r(164, 146, 12, 30, "grey") + ground(),
    "train": lambda: r(60, 78, 130, 64, "teal", 10) + r(194, 78, 76, 64, "deepTeal", 10) + "".join(r(x, 90, 24, 22, "cream", 3) for x in (72, 104, 136, 206, 238)) + r(60, 122, 210, 8, "orange")
        + c(96, 152, 12, "ink") + c(148, 152, 12, "ink") + c(220, 152, 12, "ink") + c(252, 152, 12, "ink") + r(176, 50, 22, 28, "ink", 4) + ln(40, 168, 300, 168, "ink", 4) + ground(40, 300),
    "travel": lambda: r(110, 80, 120, 86, "orange", 10) + s("M148 80V66H192V80", "brown", 5) + ln(140, 80, 140, 166, "brown", 5) + ln(200, 80, 200, 166, "brown", 5)
        + c(166, 130, 8, "teal") + c(182, 118, 6, "green") + plane_top(262, 56, 0.4) + ground(),
    "trip": lambda: r(112, 46, 116, 16, "orange", 8) + r(120, 60, 100, 112, "green", 26) + r(138, 114, 64, 44, "deepTeal", 8) + ln(144, 60, 144, 108, "brown", 5) + ln(196, 60, 196, 108, "brown", 5)
        + c(170, 136, 8, "orange") + ground(),
    "tent": lambda: p("M70 172L170 52L270 172Z", "orange") + p("M146 172L170 110L194 172Z", "deepTeal") + ln(170, 52, 170, 110, "skinShade", 3) + ln(70, 172, 270, 172, "brown", 5) + ln(170, 52, 170, 36, "brown", 4)
        + p("M170 36L196 44L170 52Z", "teal"),
    "anchor": lambda: ring(170, 46, 12, "deepTeal", "none", 6) + ln(170, 58, 170, 150, "deepTeal", 8) + ln(140, 82, 200, 82, "deepTeal", 7)
        + s("M100 112C108 160 160 172 170 150C180 172 232 160 240 112", "deepTeal", 8) + p("M92 118L108 100L116 124Z", "deepTeal") + p("M248 118L232 100L224 124Z", "deepTeal"),
    # --- nature
    "autumn": lambda: r(160, 100, 20, 76, "brown", 4) + c(170, 78, 46, "orange") + c(136, 100, 28, "skinShade") + c(204, 100, 28, "orange") + e(98, 60, 9, 5, "orange", 30)
        + e(250, 76, 9, 5, "skinShade", -30) + e(80, 120, 9, 5, "orange", -20) + e(120, 170, 12, 5, "skinShade", 10) + e(220, 172, 12, 5, "orange", -10) + ground(),
    "bee": lambda: e(150, 68, 20, 30, "cream", -25) + e(194, 68, 20, 30, "cream", 25) + e(180, 106, 46, 31, "orange") + r(166, 78, 10, 56, "ink") + r(188, 78, 10, 56, "ink")
        + c(124, 104, 20, "ink") + eye(116, 100) + s("M116 86C112 70 104 66 98 66", "ink", 3) + s("M130 84C132 68 140 62 146 62", "ink", 3) + p("M226 106L246 112L226 118Z", "ink"),
    "branch": lambda: s("M70 150C130 130 200 110 270 70", "brown", 10) + s("M140 128C150 100 160 90 170 80", "brown", 6) + s("M200 108C212 130 226 140 240 142", "brown", 6)
        + e(168, 74, 18, 9, "green", -50) + e(186, 92, 18, 9, "green", 30) + e(242, 134, 18, 9, "green", 20) + e(106, 128, 16, 8, "green", -30) + e(250, 64, 16, 8, "green", -30) + e(222, 92, 16, 8, "green", 40),
    "cave": lambda: p("M60 176C60 100 100 50 170 50C240 50 280 100 280 176Z", "grey") + p("M130 176C130 130 150 108 170 108C190 108 210 130 210 176Z", "ink")
        + p("M144 122L150 140L156 114Z", "greyShade") + p("M178 112L184 136L190 112Z", "greyShade") + ln(60, 176, 280, 176, "brown", 5) + c(262, 70, 6, "orange"),
    "cliff": lambda: p("M40 40H190L206 100L184 176H40Z", "skinShade") + r(40, 34, 160, 14, "green", 5) + ln(70, 80, 130, 86, "brown", 3) + ln(90, 120, 160, 126, "brown", 3)
        + p("M184 176L206 100L300 100V176Z", "teal") + s("M214 128C226 120 238 136 250 128C262 120 274 136 288 128", "cream", 3) + c(262, 56, 16, "orange"),
    "forest": lambda: pine(90, 172, 100, "deepTeal") + pine(150, 176, 130, "green") + pine(206, 172, 110, "deepTeal") + pine(256, 176, 90, "green") + ground(60, 290),
    "frog": lambda: e(124, 152, 28, 14, "green") + e(216, 152, 28, 14, "green") + e(170, 124, 58, 42, "green") + e(170, 140, 36, 22, "cream") + e(170, 98, 44, 30, "green")
        + c(144, 70, 14, "green") + c(196, 70, 14, "green") + c(144, 70, 8, "cream") + c(196, 70, 8, "cream") + eye(144, 70) + eye(196, 70) + s("M148 104C162 116 178 116 192 104", "ink", 4),
    "island": lambda: r(40, 130, 260, 46, "teal", 4) + e(170, 138, 90, 24, "skin") + s("M176 130C170 100 180 80 170 56", "brown", 8) + e(144, 58, 28, 8, "green", -30) + e(196, 58, 28, 8, "green", 30)
        + e(150, 72, 24, 7, "green", 25) + e(192, 74, 24, 7, "green", -25) + c(166, 70, 5, "brown") + c(178, 70, 5, "brown") + c(250, 50, 16, "orange"),
    "leaf": lambda: p("M120 150C100 90 160 40 240 44C244 110 200 160 120 150Z", "green") + s("M120 150C160 120 200 90 232 52", "deepTeal", 4) + s("M162 114L170 82M190 96L214 96M148 130L128 112", "deepTeal", 3)
        + ln(120, 150, 100, 170, "brown", 5),
    "lion": lambda: c(170, 102, 66, "brown") + c(170, 106, 44, "orange") + c(126, 62, 14, "brown") + c(214, 62, 14, "brown") + c(126, 62, 7, "earPink") + c(214, 62, 7, "earPink")
        + eye(154, 96) + eye(186, 96) + e(170, 124, 18, 12, "cream") + p("M162 110H178L170 120Z", "ink") + s("M170 120V128M158 132C164 138 176 138 182 132", "ink", 3),
    "moon": lambda: c(170, 100, 58, "cream") + c(196, 90, 52, "halo") + star(250, 56, 10, 4, "orange") + star(96, 140, 8, 3, "orange") + star(264, 134, 6, 2.5, "orange"),
    "mountain": lambda: p("M40 176L120 60L200 176Z", "grey") + p("M130 176L220 48L300 176Z", "greyShade") + p("M120 60L140 88L120 80L104 90Z", "cream") + p("M220 48L242 80L220 72L202 84Z", "cream")
        + r(40, 160, 260, 16, "green", 4) + c(268, 54, 14, "orange"),
    "mouse": lambda: s("M232 140C264 150 270 120 262 104", "earPink", 5) + e(170, 134, 60, 34, "grey") + c(116, 120, 22, "grey") + c(138, 98, 16, "grey") + c(138, 98, 9, "earPink")
        + eye(110, 114) + c(96, 124, 4, "ink") + ln(94, 118, 76, 112, "ink", 3) + ln(94, 126, 76, 130, "ink", 3) + ground(),
    "nest": lambda: ln(60, 150, 280, 150, "brown", 6) + e(170, 124, 80, 34, "brown") + e(148, 112, 16, 20, "cream") + e(172, 108, 16, 20, "cream") + e(196, 112, 16, 20, "cream")
        + c(148, 108, 3, "teal") + c(176, 104, 3, "teal") + c(198, 110, 3, "teal") + e(170, 134, 80, 24, "skinShade") + s("M100 134C130 150 210 150 240 134", "brown", 4) + s("M110 120C120 110 126 112 134 120", "brown", 3),
    "ocean": lambda: c(250, 52, 18, "orange") + p("M40 90C70 70 100 110 130 90C160 70 190 110 220 90C250 70 280 110 300 90V176H40Z", "teal")
        + p("M40 130C70 112 100 148 130 130C160 112 190 148 220 130C250 112 280 148 300 130V176H40Z", "deepTeal") + s("M60 100C76 92 90 100 106 94", "cream", 3) + s("M200 100C216 92 230 100 246 94", "cream", 3),
    "pig": lambda: s("M232 112C254 104 254 126 238 124", "earPink", 5) + e(170, 120, 62, 42, "earPink") + c(112, 112, 28, "earPink") + p("M104 88L112 66L128 88Z", "earPink") + e(98, 118, 16, 12, "skin")
        + c(94, 118, 2.5, "ink") + c(104, 118, 2.5, "ink") + eye(116, 104) + r(130, 150, 14, 24, "earPink", 4) + r(206, 150, 14, 24, "earPink", 4) + ground(),
    "rain": lambda: cloud(170, 78, "grey") + "".join(ln(x, y, x - 8, y + 22, "teal", 4) for x, y in ((120, 120), (150, 130), (180, 118), (210, 132), (240, 120), (136, 148), (196, 150), (226, 148))),
    "river": lambda: r(60, 34, 220, 142, "green", 8) + s("M130 40C210 72 120 110 170 142C186 154 176 160 186 164", "teal", 32) + c(100, 70, 16, "deepTeal") + c(240, 130, 16, "deepTeal")
        + c(236, 70, 8, "grey") + c(96, 140, 8, "grey") + ln(120, 160, 130, 150, "cream", 3),
    "sea": lambda: c(250, 56, 18, "orange") + r(40, 104, 260, 72, "teal", 4) + s("M64 124C80 116 96 124 112 116", "cream", 3) + s("M200 140C216 132 232 140 248 132", "cream", 3) + s("M70 154C86 146 102 154 118 146", "cream", 3)
        + p("M156 50V104H112Z", "cream") + p("M164 62L204 104H164Z", "orange") + p("M104 106H214L196 124H122Z", "brown") + s("M60 60C70 52 80 56 84 62", "ink", 3) + s("M240 90C248 84 258 88 262 94", "ink", 3),
    "sheep": lambda: ln(138, 150, 138, 172, "ink", 6) + ln(154, 150, 154, 172, "ink", 6) + ln(196, 150, 196, 172, "ink", 6) + ln(212, 150, 212, 172, "ink", 6)
        + c(140, 112, 26, "cream") + c(170, 100, 30, "cream") + c(204, 112, 26, "cream") + c(170, 128, 30, "cream") + e(104, 112, 16, 20, "ink") + e(124, 96, 8, 5, "ink", 30) + eye(100, 106) + ground(),
    "snake": lambda: s("M80 150C80 100 150 150 170 112C190 74 250 110 240 76", "green", 18) + e(240, 70, 16, 12, "green") + eye(244, 66) + s("M250 72L266 70L272 62M266 70L272 78", "earPink", 3)
        + c(110, 128, 4, "orange") + c(150, 128, 4, "orange") + c(186, 106, 4, "orange") + c(222, 94, 4, "orange") + ground(60, 280),
    "snow": lambda: e(170, 174, 110, 8, "cream") + c(170, 138, 34, "cream") + c(170, 92, 24, "cream") + r(154, 52, 32, 8, "ink", 2) + r(160, 34, 20, 20, "ink", 3) + p("M170 92L196 98L170 102Z", "orange")
        + eye(162, 86) + eye(178, 86) + c(170, 124, 3, "ink") + c(170, 138, 3, "ink") + c(170, 152, 3, "ink") + ln(138, 120, 112, 100, "brown", 4) + ln(202, 120, 228, 100, "brown", 4)
        + c(80, 60, 4, "cream") + c(262, 80, 4, "cream") + c(250, 140, 4, "cream"),
    "spring": lambda: c(256, 56, 16, "orange") + "".join(ln(x, 176, x, y, "green", 4) + c(x, y - 8, 10, col) + c(x, y - 8, 4, "orange") for x, y, col in ((110, 120, "earPink"), (150, 100, "cream"), (190, 124, "orange"), (230, 108, "earPink")))
        + e(130, 150, 20, 7, "green", -30) + e(210, 152, 20, 7, "green", 30) + ground(60, 280),
    "star": lambda: star(170, 102, 66, 28, "orange") + star(84, 56, 10, 4, "cream") + star(262, 140, 8, 3, "cream") + star(262, 50, 7, 3, "cream"),
    "summer": lambda: BASE["beach"]() + c(262, 54, 20, "orange"),
    "sun": lambda: c(170, 102, 36, "orange") + "".join(ln(170 + 48 * dx, 102 + 48 * dy, 170 + 66 * dx, 102 + 66 * dy, "orange", 5) for dx, dy in
                                                       ((1, 0), (-1, 0), (0, 1), (0, -1), (0.7, 0.7), (-0.7, 0.7), (0.7, -0.7), (-0.7, -0.7))),
    "tree": lambda: r(158, 100, 24, 76, "brown", 4) + c(170, 70, 44, "green") + c(138, 96, 30, "green") + c(202, 96, 30, "green") + c(160, 62, 5, "orange") + c(190, 84, 5, "orange") + ground(),
    "winter": lambda: e(170, 174, 120, 8, "cream") + pine(120, 172, 120, "green", True) + pine(214, 172, 90, "deepTeal", True) + "".join(c(x, y, 3.5, "cream") for x, y in ((70, 50), (160, 40), (260, 70), (80, 120), (270, 130))),
    "worm": lambda: e(170, 172, 110, 8, "brown") + s("M80 150C100 120 130 170 160 140C190 110 210 150 250 120", "earPink", 16) + c(252, 118, 12, "earPink") + eye(256, 114)
        + ln(106, 138, 106, 150, "skinShade", 3) + ln(150, 146, 150, 156, "skinShade", 3) + ln(196, 132, 196, 142, "skinShade", 3),
    "weather": lambda: c(130, 78, 32, "orange") + "".join(ln(130 + 42 * dx, 78 + 42 * dy, 130 + 54 * dx, 78 + 54 * dy, "orange", 5) for dx, dy in ((0, -1), (-1, 0), (0.7, -0.7), (-0.7, -0.7), (-0.7, 0.7)))
        + cloud(190, 112, "cream") + "".join(ln(x, 144, x - 6, 164, "teal", 4) for x in (160, 190, 220)),
    "plant": lambda: p("M130 126H210L198 172H142Z", "orange") + r(124, 118, 92, 12, "skinShade", 4) + ln(170, 118, 170, 70, "green", 5) + e(140, 98, 26, 10, "green", -30) + e(200, 90, 26, 10, "green", 30)
        + e(146, 70, 22, 9, "green", -50) + e(196, 62, 22, 9, "green", 50) + e(170, 50, 10, 18, "green") + ground(),
    # --- objects
    "bell": lambda: p("M120 130C120 70 150 56 170 56C190 56 220 70 220 130Z", "orange") + r(110, 128, 120, 12, "orange", 5) + c(170, 152, 10, "brown") + c(170, 50, 5, "brown") + e(148, 96, 6, 16, "cream", 15),
    "candle": lambda: r(150, 80, 40, 90, "cream", 4) + p("M170 34C184 56 188 62 170 74C152 62 156 56 170 34Z", "orange") + ln(170, 74, 170, 82, "ink", 3) + p("M150 100C150 112 160 116 160 104Z", "cream")
        + e(170, 172, 44, 6, "brown") + ground(100, 240),
    "coin": lambda: c(210, 120, 40, "skinShade") + c(150, 100, 56, "orange") + ring(150, 100, 44, "skinShade", "none", 4) + star(150, 100, 24, 10, "skinShade") + ground(80, 280),
    "diamond": lambda: p("M120 70H220L246 96H94Z", "teal") + p("M94 96H246L170 168Z", "deepTeal") + ln(120, 70, 138, 96, "cream", 3) + ln(220, 70, 202, 96, "cream", 3) + ln(138, 96, 170, 168, "cream", 3)
        + ln(202, 96, 170, 168, "cream", 3) + ln(170, 70, 170, 96, "cream", 3) + star(262, 58, 12, 4, "cream"),
    "drum": lambda: ln(120, 40, 200, 100, "brown", 5) + ln(220, 40, 140, 100, "brown", 5) + r(120, 96, 100, 66, "orange", 6) + e(170, 96, 50, 14, "cream") + e(170, 162, 50, 8, "orange")
        + s("M126 100L146 158L166 100L186 158L206 100", "brown", 3) + ground(),
    "flag": lambda: ln(110, 176, 110, 40, "brown", 5) + p("M114 44C150 30 190 58 250 44V112C190 126 150 98 114 112Z", "teal") + star(182, 80, 18, 8, "cream") + c(110, 36, 5, "orange") + ground(70, 200),
    "gift": lambda: r(120, 100, 100, 70, "teal", 3) + r(114, 86, 112, 18, "deepTeal", 3) + r(164, 86, 12, 84, "orange") + e(150, 76, 18, 11, "orange", -20) + e(190, 76, 18, 11, "orange", 20) + c(170, 80, 6, "orange") + ground(),
    "ladder": lambda: ln(130, 40, 130, 176, "brown", 6) + ln(210, 40, 210, 176, "brown", 6) + "".join(ln(130, y, 210, y, "skinShade", 5) for y in (62, 90, 118, 146)) + ground(100, 240),
    "rope": lambda: ring(170, 110, 52, "skin", "none", 8) + ring(170, 110, 34, "skin", "none", 8) + ring(170, 110, 16, "skin", "none", 8) + s("M222 110C240 140 250 150 280 150", "skin", 8) + ln(280, 150, 290, 156, "skinShade", 5),
    "sword": lambda: p("M170 24L184 42V128H156V42Z", "grey") + ln(170, 40, 170, 124, "greyShade", 3) + r(128, 126, 84, 10, "brown", 4) + r(164, 136, 12, 30, "brown", 3) + c(170, 172, 6, "orange"),
    "crystal": lambda: p("M120 170L106 106L128 70L150 106L146 170Z", "deepTeal") + p("M150 170L146 70L176 34L206 70L202 170Z", "teal") + p("M202 170L198 106L226 80L246 112L238 170Z", "deepTeal")
        + ln(176, 34, 176, 170, "cream", 3) + ln(128, 70, 128, 160, "teal", 3) + ln(226, 80, 222, 160, "teal", 3) + ground(80, 270),
    "bank": lambda: p("M80 84L170 38L260 84Z", "deepTeal") + r(86, 86, 168, 10, "cream", 2) + "".join(r(x, 98, 16, 56, "cream", 3) for x in (100, 138, 176, 214))
        + r(80, 154, 180, 10, "grey", 2) + r(70, 164, 200, 12, "greyShade", 2) + c(170, 66, 10, "orange"),
    "brick": lambda: r(100, 128, 140, 40, "skinShade", 4) + r(84, 88, 100, 40, "skin", 4) + r(190, 88, 90, 40, "skinShade", 4) + r(120, 48, 120, 40, "skin", 4)
        + "".join(r(x, y, 14, 8, "brown", 2) for x, y in ((112, 144), (140, 144), (214, 144))) + ground(60, 290),
    "robot": lambda: ln(170, 38, 170, 52, "ink", 4) + c(170, 34, 6, "orange") + r(130, 52, 80, 54, "grey", 10) + c(152, 78, 9, "teal") + c(188, 78, 9, "teal") + r(152, 94, 36, 5, "ink", 2)
        + r(122, 112, 96, 52, "greyShade", 8) + ln(122, 126, 94, 150, "grey", 8) + ln(218, 126, 246, 150, "grey", 8) + r(142, 164, 18, 12, "ink", 3) + r(180, 164, 18, 12, "ink", 3) + c(170, 138, 8, "orange"),
}


if __name__ == "__main__":
    write(WORDS)
