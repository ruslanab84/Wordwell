#!/usr/bin/env python3
"""Flat colour batch 11: adjectives, adverbs and prepositions as small scenes (~100 words). Shares helpers with flat_redraw.py and _b7.._b10.

Run: python3 Tools/flat_redraw_b11.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s, write
from flat_redraw_b7 import P, WORDS as W7, glasses, heart, star, woman
from flat_redraw_b8 import bowl, cloud, steam
from flat_redraw_b9 import tower
from flat_redraw_b10 import arrow, runner, walker


def varrow(x, y1, y2, col="green"):
    d = 1 if y2 > y1 else -1
    return ln(x, y1, x, y2 - d * 12, col, 12) + p(f"M{x} {y2}L{x - 18} {y2 - d * 24}H{x + 18}Z", col)


def tee(cx, cy, k, col):
    pts = [(-18, -34), (-42, -20), (-32, -2), (-20, -10), (-20, 34), (20, 34), (20, -10), (32, -2), (42, -20), (18, -34), (0, -26)]
    return p("M" + "L".join(f"{cx + x * k:.1f} {cy + y * k:.1f}" for x, y in pts) + "Z", col)


def face(fill="orange", cx=170, cy=102, rad=60):
    return c(cx, cy, rad, fill) + eye(cx - 20, cy - 12) + eye(cx + 20, cy - 12)


def mark_check(col="green", cx=170, cy=102):
    return c(cx, cy, 60, col) + ring(cx, cy, 48, "cream", "none", 3) + s(f"M{cx - 28} {cy + 2}L{cx - 8} {cy + 24}L{cx + 30} {cy - 24}", "cream", 12)


def mark_cross(col="skinShade", cx=170, cy=102):
    return c(cx, cy, 60, col) + ln(cx - 24, cy - 24, cx + 24, cy + 24, "cream", 12) + ln(cx - 24, cy + 24, cx + 24, cy - 24, "cream", 12)


def thumb(col="skin"):
    return r(110, 98, 110, 66, col, 18) + r(150, 48, 34, 62, col, 14) + ln(130, 118, 200, 118, "skinShade", 3) + ln(130, 134, 200, 134, "skinShade", 3) + r(86, 100, 30, 62, "teal", 4)


def opp():
    return arrow(130, 76, 250, "teal") + arrow(210, 128, 90, "orange")


def scale_box(x, y, w, h, col="teal"):
    return r(x, y, w, h, col, 6)


def house_cut():
    return r(80, 40, 180, 136, "skin", 3) + p("M70 44L170 20L270 44Z", "brown") + r(80, 104, 180, 6, "brown") + r(188, 56, 40, 36, "cream", 2) + r(110, 124, 40, 36, "cream", 2)


A = {
    "afraid": lambda: P(170, top="teal", hair="brown", arms="") + ln(148, 90, 140, 64, "teal", 6) + ln(192, 90, 200, 64, "teal", 6) + c(140, 60, 5, "skin") + c(200, 60, 5, "skin") + c(162, 65, 5, "cream") + c(178, 65, 5, "cream") + c(162, 65, 2.5, "ink") + c(178, 65, 2.5, "ink")
        + e(170, 76, 4, 5, "ink") + c(206, 48, 3, "cream") + c(134, 42, 3, "cream") + ground(),
    "angry": lambda: P(170, top="orange", hair="brown") + ln(155, 54, 168, 60, "ink", 4) + ln(185, 54, 172, 60, "ink", 4) + s("M160 76C166 70 174 70 180 76", "ink", 3) + c(134, 40, 8, "cream") + c(206, 40, 10, "cream") + c(120, 54, 6, "cream") + c(220, 56, 6, "cream") + ground(),
    "beautiful": lambda: BASE["flower"]() + star(100, 56, 9, 4, "orange") + star(246, 50, 7, 3, "orange") + star(250, 130, 8, 3, "orange"),
    "best": lambda: p("M130 100L110 168L140 156L156 176L170 120Z", "teal") + p("M210 100L230 168L200 156L184 176L170 120Z", "deepTeal") + c(170, 82, 48, "orange") + ring(170, 82, 36, "skinShade", "none", 4) + star(170, 82, 24, 10, "skinShade"),
    "better": lambda: r(100, 120, 40, 50, "grey", 3) + r(150, 90, 40, 80, "teal", 3) + r(200, 56, 40, 114, "green", 3) + varrow(262, 150, 60, "green") + ground(80, 240),
    "big": lambda: P(70, 0.4, top="orange", hair="brown") + r(110, 34, 160, 142, "teal", 8) + r(130, 54, 120, 50, "deepTeal", 4) + ground(),
    "small": lambda: P(110, 1.0, top="teal", hair="brown") + r(190, 150, 30, 26, "orange", 4) + c(262, 168, 8, "grey") + ground(),
    "large": lambda: tee(110, 100, 1.5, "teal") + tee(254, 130, 0.6, "orange") + ground(),
    "little": lambda: c(170, 128, 28, "orange") + c(170, 96, 20, "orange") + p("M186 94L202 100L186 106Z", "skinShade") + eye(176, 92) + ln(160, 152, 158, 168, "skinShade", 4) + ln(180, 152, 182, 168, "skinShade", 4) + ground(),
    "bored": lambda: P(150, top="teal", hair="brown", arms="L") + ln(172, 88, 160, 76, "teal", 6) + c(158, 74, 5, "skin") + ln(158, 62, 168, 62, "ink", 3) + ln(172, 62, 180, 62, "ink", 3) + ln(160, 74, 172, 74, "ink", 3)
        + ring(250, 80, 28, "brown", "cream", 5) + ln(250, 80, 250, 62, "ink", 3) + ln(250, 80, 262, 84, "ink", 3) + ground(),
    "boring": lambda: r(80, 46, 180, 110, "ink", 8) + r(90, 56, 160, 90, "grey", 4) + "".join(ln(100, y, 240, y, "greyShade", 3) for y in (76, 96, 116)) + s("M100 136H240", "ink", 3) + s("M268 60H284L268 80H286", "ink", 4) + ln(130, 156, 120, 174, "ink", 5) + ln(210, 156, 220, 174, "ink", 5),
    "busy": lambda: r(70, 134, 200, 8, "brown", 3) + r(80, 142, 8, 34, "brown", 2) + r(252, 142, 8, 34, "brown", 2) + P(130, top="teal", hair="ink") + r(160, 116, 46, 18, "greyShade", 3) + r(214, 112, 26, 22, "ink", 4) + s("M250 100C262 96 266 108 258 112", "orange", 3)
        + "".join(r(x, y, 22, 16, "cream", 2) for x, y in ((190, 40), (230, 56), (96, 40), (60, 70))) + ground(),
    "cheap": lambda: p("M96 100L148 54H244V146H148Z", "orange") + c(150, 100, 9, "halo") + c(210, 100, 14, "skinShade") + ring(210, 100, 8, "orange", "none", 3) + varrow(266, 54, 130, "green") + ground(70, 280),
    "expensive": lambda: p("M96 100L148 54H244V146H148Z", "orange") + c(150, 100, 9, "halo") + p("M184 86H224L234 98L204 130L174 98Z", "teal") + varrow(266, 130, 54, "skinShade") + c(110, 160, 12, "orange") + c(134, 160, 12, "orange") + ground(70, 280),
    "clean": lambda: e(170, 120, 78, 32, "grey") + e(170, 116, 66, 26, "cream") + star(120, 60, 12, 5, "orange") + star(214, 50, 14, 6, "orange") + star(262, 96, 9, 4, "orange") + c(70, 100, 12, "cream") + c(88, 78, 8, "cream"),
    "dirty": lambda: e(170, 120, 78, 32, "grey") + e(170, 116, 66, 26, "cream") + e(150, 112, 14, 8, "brown") + e(196, 120, 10, 6, "brown") + c(174, 106, 5, "brown") + c(240, 70, 4, "ink") + c(100, 70, 4, "ink") + s("M240 70C250 62 256 70 262 62", "grey", 3),
    "complete": lambda: c(170, 102, 66, "cream") + ring(170, 102, 58, "green", "none", 12) + s("M142 104L164 128L204 76", "green", 12) + star(262, 56, 9, 4, "orange") + star(78, 150, 7, 3, "orange"),
    "cool": lambda: c(170, 100, 60, "skin") + e(170, 50, 62, 22, "brown") + r(120, 80, 100, 22, "ink", 8) + s("M150 128C162 138 180 138 192 128", "ink", 4) + star(262, 50, 9, 4, "orange") + star(78, 60, 7, 3, "orange"),
    "correct": lambda: mark_check(),
    "true": lambda: mark_check(),
    "right": lambda: mark_check(),
    "false": lambda: mark_cross(),
    "wrong": lambda: mark_cross(),
    "dangerous": lambda: p("M170 30L266 170H74Z", "ink") + p("M170 52L246 160H94Z", "orange") + r(164, 90, 12, 40, "ink", 4) + c(170, 146, 7, "ink"),
    "dark": lambda: c(170, 102, 70, "ink") + c(206, 84, 24, "cream") + c(216, 78, 21, "ink") + star(120, 70, 8, 3, "cream") + star(140, 130, 6, 2.5, "cream") + star(200, 140, 7, 3, "cream"),
    "delicious": lambda: p("M110 56H230L170 168Z", "orange") + p("M104 50H236L230 66H110Z", "skin") + c(150, 82, 11, "skinShade") + c(190, 80, 11, "skinShade") + c(170, 112, 11, "skinShade") + c(170, 70, 7, "green") + heart(252, 60, 10, "skinShade") + star(86, 70, 8, 3, "orange"),
    "different": lambda: c(90, 102, 28, "teal") + c(150, 102, 28, "teal") + r(192, 74, 56, 56, "orange", 6) + c(270, 102, 28, "teal") + ground(60, 300),
    "same": lambda: r(80, 62, 70, 70, "teal", 6) + r(190, 62, 70, 70, "teal", 6) + r(158, 84, 24, 6, "ink", 3) + r(158, 104, 24, 6, "ink", 3),
    "difficult": lambda: p("M40 176L300 70V176Z", "green") + c(170, 100, 30, "grey") + ln(150, 120, 190, 100, "greyShade", 3) + P(130, 0.5, top="orange", hair="brown", arms="", base=140) + ln(170, 130, 160, 120, "orange", 5) + ground(40, 300),
    "easy": lambda: r(90, 150, 60, 26, "grey", 3) + mark_check("green", 210, 90) + ground(70, 290),
    "early": lambda: c(110, 130, 40, "orange") + r(40, 130, 220, 50, "green", 4) + ring(220, 90, 44, "orange", "cream", 8) + ln(220, 90, 220, 62, "ink", 4) + ln(220, 90, 238, 98, "ink", 4) + c(220, 90, 4, "ink"),
    "late": lambda: runner(130, "orange", hair="brown") + ring(244, 76, 40, "brown", "cream", 6) + ln(244, 76, 244, 50, "ink", 4) + ln(244, 76, 224, 90, "ink", 4) + c(244, 76, 4, "ink") + ground(60, 290),
    "excited": lambda: P(170, top="orange", hair="brown", arms="") + ln(148, 90, 120, 56, "orange", 6) + ln(192, 90, 220, 56, "orange", 6) + c(120, 52, 5, "skin") + c(220, 52, 5, "skin") + e(170, 72, 8, 6, "ink") + star(90, 50, 9, 4, "orange") + star(250, 46, 9, 4, "orange") + heart(262, 120, 9, "skinShade") + ground(),
    "exciting": lambda: s("M40 170C60 60 100 40 130 120C150 170 180 170 200 100C220 50 250 50 290 150", "brown", 8) + r(110, 100, 30, 18, "teal", 5) + c(116, 122, 6, "ink") + c(134, 122, 6, "ink") + ln(60, 176, 280, 176, "brown", 4) + star(246, 40, 9, 4, "orange"),
    "famous": lambda: star(170, 96, 70, 30, "orange") + P(170, 0.8, top="teal", hair="brown", base=176) + c(70, 60, 8, "cream") + c(270, 80, 8, "cream") + c(80, 130, 6, "cream") + ground(),
    "fat": lambda: ln(152, 140, 148, 174, "deepTeal", 14) + ln(188, 140, 192, 174, "deepTeal", 14) + e(170, 108, 52, 48, "teal") + c(170, 56, 22, "skin") + e(170, 44, 23, 12, "brown") + eye(162, 58) + eye(178, 58) + ln(124, 92, 106, 128, "teal", 8) + ln(216, 92, 234, 128, "teal", 8) + ground(),
    "favourite": lambda: heart(170, 100, 58, "skinShade") + star(90, 56, 10, 4, "orange") + star(256, 50, 10, 4, "orange") + star(250, 140, 8, 3, "orange"),
    "few": lambda: c(120, 100, 22, "green") + c(170, 100, 22, "green") + c(220, 100, 22, "green") + ground(70, 270),
    "full": lambda: p("M118 46H222L212 172H128Z", "cream") + p("M126 58H214L208 164H132Z", "teal") + e(170, 58, 44, 7, "teal") + c(236, 78, 6, "teal") + c(104, 72, 4, "teal") + ln(142, 76, 146, 140, "cream", 3) + ground(90, 250),
    "friendly": lambda: P(110, top="teal", hair="brown", arms="L") + ln(132, 88, 148, 56, "teal", 6) + c(150, 52, 5, "skin") + woman(230, 1.0, "orange", "deepTeal") + heart(170, 50, 10, "skinShade") + ground(50, 290),
    "funny": lambda: c(170, 108, 56, "skin") + c(120, 66, 26, "orange") + c(220, 66, 26, "orange") + c(170, 108, 11, "skinShade") + eye(148, 90) + eye(192, 90) + s("M136 126C150 156 190 156 204 126", "ink", 4) + c(170, 52, 3, "orange"),
    "good": lambda: thumb(),
    "great": lambda: thumb() + star(90, 50, 10, 4, "orange") + star(250, 50, 10, 4, "orange") + star(262, 130, 8, 3, "orange"),
    "wonderful": lambda: s("M60 160C60 70 280 70 280 160", "skinShade", 12) + s("M80 160C80 88 260 88 260 160", "orange", 12) + s("M100 160C100 106 240 106 240 160", "green", 12) + s("M120 160C120 124 220 124 220 160", "teal", 12) + cloud(70, 160) + cloud(270, 160),
    "happy": lambda: face() + s("M136 116C148 140 192 140 204 116", "ink", 5) + c(128, 112, 7, "earPink") + c(212, 112, 7, "earPink"),
    "sad": lambda: face("teal") + s("M144 134C156 118 184 118 196 134", "cream", 5) + ln(130, 94, 160, 88, "cream", 3) + p("M200 108C194 120 194 126 200 130C206 126 206 120 200 108Z", "cream"),
    "healthy": lambda: BASE["apple"]() + heart(254, 64, 14, "skinShade") + star(84, 60, 8, 3, "orange"),
    "sick": lambda: P(120, top="teal", hair="brown") + s("M110 76C120 70 130 70 138 76", "ink", 3) + r(210, 36, 20, 110, "cream", 10) + c(220, 154, 18, "skinShade") + r(216, 70, 8, 80, "skinShade") + ln(236, 60, 246, 60, "ink", 3) + ln(236, 90, 246, 90, "ink", 3) + ln(236, 120, 246, 120, "ink", 3) + ground(),
    "high": lambda: tower(110, 30, 70, 146, "teal", 2, 6) + varrow(250, 150, 40, "green") + ground(80, 280),
    "long": lambda: ln(60, 100, 280, 100, "teal", 12) + p("M44 100L72 82V118Z", "teal") + p("M296 100L268 82V118Z", "teal") + "".join(ln(x, 124, x, 140, "ink", 3) for x in range(70, 280, 30)) + ln(60, 140, 280, 140, "ink", 3),
    "short": lambda: ln(130, 110, 210, 110, "orange", 12) + p("M118 110L138 98V122Z", "orange") + p("M222 110L202 98V122Z", "orange") + ln(130, 134, 210, 134, "ink", 3) + ln(130, 126, 130, 142, "ink", 3) + ln(210, 126, 210, 142, "ink", 3),
    "tall": lambda: ln(100, 176, 100, 134, "orange", 7) + ln(122, 176, 122, 134, "orange", 7) + ln(168, 176, 168, 134, "orange", 7) + ln(190, 176, 190, 134, "orange", 7) + e(146, 128, 54, 24, "orange") + ln(176, 118, 206, 44, "orange", 18)
        + e(216, 40, 20, 12, "orange", -20) + c(210, 30, 4, "skinShade") + c(214, 28, 3, "skinShade") + c(130, 124, 6, "skinShade") + c(158, 134, 6, "skinShade") + c(190, 82, 5, "skinShade") + ground(70, 240),
    "hungry": lambda: P(110, top="teal", hair="brown") + s("M96 120C100 112 106 116 110 112", "orange", 3) + s("M118 128C124 120 130 124 134 120", "orange", 3) + e(230, 130, 40, 14, "grey") + e(230, 126, 34, 10, "cream") + ln(176, 100, 176, 140, "grey", 4) + ground(),
    "thirsty": lambda: c(250, 56, 24, "orange") + P(110, top="orange", hair="brown") + p("M192 100H232L228 160H196Z", "cream") + s("M104 76C112 72 120 72 126 76", "ink", 3) + c(160, 64, 4, "teal") + ground(),
    "tired": lambda: P(150, top="teal", hair="brown") + ln(140, 62, 150, 62, "ink", 3) + ln(156, 62, 166, 62, "ink", 3) + e(150, 74, 5, 6, "ink") + s("M200 70H220L200 92H222", "ink", 4) + s("M232 44H248L232 62H250", "ink", 4) + ground(),
    "interested": lambda: P(170, top="teal", hair="brown") + star(163, 65, 6, 2.5, "orange") + star(177, 65, 6, 2.5, "orange") + e(170, 76, 4, 3, "ink") + heart(240, 70, 10, "skinShade") + star(100, 70, 8, 3, "orange") + ground(),
    "married": lambda: P(130, top="deepTeal", hair="brown") + woman(210, 1.0, "cream", "cream") + ring(170, 128, 9, "orange", "none", 4) + ring(184, 128, 9, "orange", "none", 4) + heart(170, 56, 11, "skinShade") + ground(60, 280),
    "modern": lambda: r(70, 70, 120, 80, "greyShade", 6) + r(78, 78, 104, 64, "teal", 3) + r(60, 150, 140, 8, "grey", 4) + r(214, 80, 44, 78, "ink", 10) + r(220, 90, 32, 54, "orange", 3) + c(236, 150, 3, "grey"),
    "new": lambda: W7["shoe"]() + star(262, 56, 14, 6, "orange") + star(86, 70, 10, 4, "orange") + star(270, 130, 8, 3, "orange"),
    "old": lambda: W7["grandfather"](),
    "young": lambda: W7["child"](),
    "next": lambda: s("M100 60L160 102L100 144", "teal", 18) + s("M170 60L230 102L170 144", "orange", 18) + c(262, 60, 5, "grey") + c(262, 102, 5, "grey") + c(262, 144, 5, "grey"),
    "left": lambda: arrow(250, 102, 70, "teal") + c(260, 60, 6, "orange"),
    "online": lambda: r(90, 70, 160, 90, "greyShade", 6) + r(98, 78, 144, 74, "teal", 3) + r(70, 160, 200, 8, "grey", 4) + s("M130 52C150 36 190 36 210 52", "orange", 5) + s("M146 64C158 54 182 54 194 64", "orange", 5) + c(170, 100, 12, "cream"),
    "open": lambda: p("M96 100L170 70L244 100L170 130Z", "skin") + p("M96 100L170 130V176L96 146Z", "skinShade") + p("M244 100L170 130V176L244 146Z", "skin") + p("M96 100L78 66L150 52L170 70Z", "skin") + p("M244 100L262 66L190 52L170 70Z", "skinShade") + star(170, 98, 14, 6, "orange"),
    "opposite": lambda: opp(),
    "pretty": lambda: e(130, 80, 44, 32, "orange", -25) + e(210, 80, 44, 32, "teal", 25) + e(136, 128, 32, 24, "teal", 25) + e(204, 128, 32, 24, "orange", -25) + r(164, 62, 12, 90, "ink", 6) + ln(168, 62, 150, 36, "ink", 3) + ln(172, 62, 190, 36, "ink", 3) + c(130, 80, 8, "cream") + c(210, 80, 8, "cream"),
    "quick": lambda: p("M190 30L110 112H160L140 172L230 86H180Z", "orange") + ln(70, 70, 100, 70, "grey", 4) + ln(60, 100, 96, 100, "grey", 4) + ln(70, 130, 100, 130, "grey", 4),
    "fast": lambda: runner(180, "teal", hair="brown") + ground(60, 290),
    "slow": lambda: e(170, 164, 76, 12, "green") + c(190, 118, 44, "brown") + ring(190, 118, 30, "skinShade", "none", 5) + ring(190, 118, 14, "skinShade", "none", 5) + ln(112, 150, 112, 120, "green", 14) + c(112, 114, 12, "green") + ln(106, 104, 100, 84, "green", 4) + ln(120, 104, 124, 82, "green", 4)
        + c(100, 80, 4, "ink") + c(124, 78, 4, "ink") + ground(70, 280),
    "quiet": lambda: P(170, top="teal", hair="brown", arms="L") + ln(192, 88, 174, 72, "teal", 6) + r(170, 66, 6, 14, "skin", 3) + c(172, 78, 5, "skin") + s("M210 60C220 70 220 90 210 100", "orange", 4) + s("M222 50C238 66 238 94 222 110", "orange", 4) + ground(),
    "ready": lambda: P(150, top="green", hair="brown", arms="L") + ln(172, 88, 192, 66, "green", 6) + r(190, 52, 10, 20, "skin", 4) + c(196, 74, 6, "skin") + r(224, 60, 40, 56, "cream", 4) + s("M232 72L238 78L248 66", "green", 4) + s("M232 92L238 98L248 86", "green", 4) + ground(),
    "special": lambda: r(130, 140, 80, 36, "brown", 4) + star(170, 90, 44, 19, "orange") + star(100, 56, 9, 4, "orange") + star(246, 50, 9, 4, "orange") + star(250, 120, 7, 3, "orange"),
    "strong": lambda: ln(106, 162, 140, 92, "skin", 26) + e(164, 98, 34, 26, "skin", -20) + c(142, 70, 20, "skin") + ln(124, 74, 134, 82, "skinShade", 3) + c(250, 60, 8, "orange") + star(246, 130, 8, 3, "orange"),
    "useful": lambda: r(100, 90, 140, 80, "orange", 8) + s("M144 90V70C144 54 196 54 196 70V90", "brown", 6) + r(100, 120, 140, 8, "skinShade") + ln(250, 50, 276, 76, "grey", 8) + ring(246, 46, 12, "greyShade", "none", 6) + ground(),
    "warm": lambda: BASE["fire"]() + steam(250, 110) + steam(86, 110),
    "cold": lambda: "".join(ln(170 + 62 * dx, 100 + 62 * dy, 170 - 62 * dx, 100 - 62 * dy, "cream", 6) for dx, dy in ((1, 0), (0, 1), (0.7, 0.7), (0.7, -0.7))) + c(170, 100, 12, "cream") + ln(250, 40, 250, 150, "cream", 10) + c(250, 156, 14, "teal") + ground(),
    "welcome": lambda: r(90, 140, 160, 30, "brown", 6) + ln(110, 156, 230, 156, "skinShade", 4) + heart(170, 100, 30, "skinShade") + ln(110, 140, 110, 110, "green", 4) + c(110, 104, 9, "orange") + ln(230, 140, 230, 110, "green", 4) + c(230, 104, 9, "earPink") + e(170, 150, 20, 5, "cream"),
    # prepositions and adverbs
    "above": lambda: r(110, 130, 120, 46, "teal", 6) + c(170, 80, 20, "orange") + varrow(250, 130, 50, "green") + ground(90, 250),
    "below": lambda: r(110, 60, 120, 46, "teal", 6) + c(170, 140, 20, "orange") + varrow(250, 60, 150, "green") + ground(90, 250),
    "across": lambda: r(40, 100, 260, 34, "teal", 4) + r(40, 90, 50, 70, "green", 4) + r(250, 90, 50, 70, "green", 4) + arrow(70, 70, 270, "orange"),
    "around": lambda: c(170, 102, 26, "green") + s("M170 36C230 36 262 80 252 120", "orange", 9) + p("M262 132L236 120L264 98Z", "orange") + s("M170 168C110 168 78 124 88 84", "teal", 9) + p("M78 72L104 84L76 106Z", "teal"),
    "away": lambda: p("M120 176H220L190 90H150Z", "greyShade") + P(170, 0.3, top="orange", hair="brown", base=110) + arrow(250, 60, 296, "grey") + ground(80, 260),
    "behind": lambda: c(206, 128, 30, "orange") + r(110, 80, 90, 96, "teal", 6) + ground(80, 260),
    "between": lambda: r(70, 80, 60, 96, "teal", 5) + r(210, 80, 60, 96, "deepTeal", 5) + c(170, 150, 22, "orange") + ground(60, 280),
    "down": lambda: varrow(170, 40, 170, "teal") + c(246, 70, 14, "orange") + ground(),
    "up": lambda: varrow(170, 170, 40, "green") + e(246, 70, 16, 20, "teal") + ln(246, 90, 240, 130, "grey", 3) + ground(),
    "downstairs": lambda: house_cut() + P(130, 0.5, top="orange", hair="brown", base=170) + varrow(220, 60, 150, "green"),
    "upstairs": lambda: house_cut() + P(200, 0.42, top="orange", hair="brown", base=104) + varrow(120, 150, 60, "green"),
    "in": lambda: r(100, 90, 140, 86, "skin", 4) + p("M90 90L110 60H230L250 90Z", "skinShade") + c(170, 40, 18, "orange") + varrow(170, 56, 100, "green"),
    "out": lambda: r(70, 90, 120, 86, "skin", 4) + p("M60 90L80 60H180L200 90Z", "skinShade") + c(250, 72, 18, "orange") + arrow(200, 120, 280, "green") + ground(60, 300),
    "on": lambda: r(90, 110, 160, 10, "brown", 3) + r(100, 120, 10, 56, "brown", 2) + r(230, 120, 10, 56, "brown", 2) + c(170, 90, 20, "orange") + ground(),
    "off": lambda: r(60, 90, 120, 10, "brown", 3) + r(70, 100, 10, 76, "brown", 2) + c(210, 90, 20, "orange") + c(226, 160, 20, "orange") + varrow(250, 100, 150, "green") + ground(50, 300),
    "over": lambda: r(150, 90, 40, 86, "skinShade", 3) + s("M70 140C80 50 260 50 270 140", "teal", 8) + p("M282 148L256 140L276 120Z", "teal") + ground(),
    "under": lambda: r(90, 70, 160, 10, "brown", 3) + r(100, 80, 10, 96, "brown", 2) + r(230, 80, 10, 96, "brown", 2) + c(170, 150, 20, "orange") + ground(),
    "through": lambda: ring(170, 100, 50, "brown", "none", 10) + arrow(60, 100, 290, "orange"),
    "near": lambda: r(70, 90, 70, 86, "skin", 3) + p("M62 94L105 56L148 94Z", "teal") + r(180, 110, 12, 66, "brown", 3) + c(186, 90, 30, "green") + ln(146, 150, 176, 150, "ink", 3) + ground(50, 290),
    "together": lambda: P(110, top="teal", hair="brown", arms="") + P(170, top="orange", hair="ink", arms="") + woman(230, 1.0, "green", "deepTeal") + ln(132, 90, 148, 110, "teal", 6) + ln(192, 90, 208, 110, "orange", 6) + heart(170, 36, 10, "skinShade") + ground(60, 290),
}

_SAME = {"opposite_adjective": "opposite", "opposite_adverb": "opposite", "near_adjective": "near", "near_adverb": "near", "fast_adjective": "fast", "fast_adverb": "fast",
         "quickly_adverb": "fast", "cold": "cold", "correct_adjective": "correct", "complete_adjective": "complete", "true_adjective": "true", "false_adjective": "false",
         "wrong_adjective": "wrong", "right_adjective": "right", "open_adjective": "open", "welcome_adjective": "welcome", "new_adjective": "new"}
_ADJ = ("afraid angry beautiful best better big bored boring busy cheap clean cool dangerous dark delicious different difficult dirty early easy excited exciting expensive famous fat favourite few "
        "friendly full funny good great happy healthy high hungry interested large late little long married modern next old pretty quick quiet ready sad short sick slow small special strong tall thirsty tired "
        "useful warm wonderful young left online").split()
_ADV = "above across around away behind below between down downstairs in off on out over through together under up upstairs".split()

WORDS = {}
for k in _ADJ:
    WORDS[f"{k}_adjective"] = A[k]
for k in _ADV:
    WORDS[f"{k}_adverb"] = A[k]
for dst, src in _SAME.items():
    if dst == "cold":
        WORDS["cold"] = A["cold"]
    elif dst.endswith("_adjective") or dst.endswith("_adverb"):
        WORDS[dst] = A[src]
WORDS["opposite"] = A["opposite"]
WORDS["right_adjective"] = A["right"]

if __name__ == "__main__":
    write(WORDS)
