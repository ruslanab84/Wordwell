#!/usr/bin/env python3
"""Flat colour batch 10: verbs as small scenes (100 words, assets word_<verb>_verb_plate). Shares helpers with flat_redraw.py / _b7 / _b8 / _b9.

Run: python3 Tools/flat_redraw_b10.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s, write
from flat_redraw_b7 import P, glasses, heart, note, star, woman
from flat_redraw_b8 import bowl, cloud, plane_top, steam
from flat_redraw_b9 import banknote, compass, gear


def arm(cx, side, tx, ty, col="teal", k=1.0, base=176):
    """Arm from the shoulder of a figure at cx to (tx, ty), with a hand."""
    return ln(cx + side * 22 * k, base - 88 * k, tx, ty, col, 6) + c(tx, ty, 5 * k, "skin")


def bubble(cx, cy, w, h, fill="cream", tail=-1):
    return e(cx, cy, w, h, fill) + p(f"M{cx + tail * w * 0.5:.0f} {cy + h * 0.6:.0f}L{cx + tail * w * 0.8:.0f} {cy + h * 1.5:.0f}L{cx + tail * w * 0.15:.0f} {cy + h * 0.85:.0f}Z", fill)


def runner(cx, top="teal", bottom="deepTeal", hair="ink", base=176):
    b = base
    return (s(f"M{cx} {b - 60}L{cx - 26} {b - 40}L{cx - 50} {b - 30}", bottom, 12) + s(f"M{cx} {b - 60}L{cx + 26} {b - 44}L{cx + 24} {b - 8}", bottom, 12)
            + ln(cx, b - 62, cx + 16, b - 96, top, 30) + s(f"M{cx + 12} {b - 94}L{cx - 10} {b - 78}L{cx - 24} {b - 94}", top, 6)
            + s(f"M{cx + 14} {b - 94}L{cx + 36} {b - 82}L{cx + 48} {b - 98}", top, 6) + c(cx + 22, b - 116, 17, "skin") + e(cx + 20, b - 126, 18, 10, hair) + eye(cx + 28, b - 114)
            + ln(cx - 60, b - 90, cx - 90, b - 90, "grey", 3) + ln(cx - 56, b - 70, cx - 86, b - 70, "grey", 3))


def walker(cx, top="teal", bottom="deepTeal", hair="ink", base=176):
    b = base
    return (ln(cx + 4, b - 44, cx + 22, b - 8, bottom, 13) + ln(cx - 4, b - 44, cx - 22, b - 8, bottom, 13) + c(cx + 26, b - 6, 7, "ink") + c(cx - 26, b - 6, 7, "ink")
            + ln(cx - 20, b - 88, cx - 30, b - 54, top, 6) + ln(cx + 20, b - 88, cx + 30, b - 60, top, 6) + r(cx - 20, b - 96, 40, 56, top, 10) + c(cx, b - 116, 19, "skin")
            + e(cx, b - 127, 20, 12, hair) + eye(cx + 4, b - 111) + eye(cx + 14, b - 111))


def duck(x, y, k=1.0):
    return e(x, y, 22 * k, 14 * k, "orange") + c(x + 16 * k, y - 14 * k, 10 * k, "orange") + p(f"M{x + 24 * k:.0f} {y - 14 * k:.0f}L{x + 36 * k:.0f} {y - 10 * k:.0f}L{x + 24 * k:.0f} {y - 8 * k:.0f}Z", "skinShade") + c(x + 19 * k, y - 16 * k, 2, "ink")


def arrow(x1, y, x2, col="green"):
    d = 1 if x2 > x1 else -1
    return ln(x1, y, x2 - d * 12, y, col, 12) + p(f"M{x2} {y}L{x2 - d * 24} {y - 18}V{y + 18}Z", col)


def circ_arrows():
    return (s("M120 104C120 62 196 50 224 86", "teal", 9) + p("M236 98L206 96L228 70Z", "teal") + s("M220 100C220 142 144 154 116 118", "orange", 9) + p("M104 106L134 108L112 134Z", "orange"))


def table(x1=70, x2=270, y=130):
    return r(x1, y, x2 - x1, 8, "brown", 3) + r(x1 + 10, y + 8, 8, 176 - y - 8, "brown", 2) + r(x2 - 18, y + 8, 8, 176 - y - 8, "brown", 2)


V = {
    "add": lambda: c(90, 106, 16, "green") + c(122, 106, 16, "green") + r(150, 98, 28, 8, "teal", 3) + r(160, 88, 8, 28, "teal", 3) + c(196, 106, 16, "green") + r(222, 94, 22, 6, "deepTeal", 3)
        + r(222, 110, 22, 6, "deepTeal", 3) + c(262, 106, 16, "green") + ground(60, 290),
    "arrive": lambda: plane_top(262, 52, 0.4) + P(130, top="orange", hair="brown") + r(168, 128, 44, 36, "teal", 5) + s("M180 128V118H200V128", "brown", 4) + ln(212, 164, 222, 164, "grey", 3) + ground(),
    "ask": lambda: P(120, hair="brown", arms="L") + arm(120, 1, 150, 56) + e(228, 76, 40, 30, "teal") + p("M200 92L190 118L222 100Z", "teal") + s("M216 68C216 56 240 56 240 68C240 78 228 78 228 88", "cream", 5) + c(228, 98, 3, "cream") + ground(),
    "begin": lambda: P(130, top="green", hair="brown", arms="L") + arm(130, 1, 170, 52, "green") + ln(170, 176, 170, 40, "brown", 4) + p("M170 40L224 52L170 66Z", "green") + r(100, 172, 150, 4, "cream") + ground(60, 280),
    "bring": lambda: P(150, top="orange", hair="brown", arms="") + ln(128, 90, 130, 124, "orange", 6) + ln(172, 90, 170, 124, "orange", 6) + r(122, 110, 56, 36, "skin", 3) + r(142, 110, 16, 36, "skinShade") + arrow(212, 100, 270) + ground(),
    "build": lambda: r(190, 150, 36, 16, "skin", 2) + r(228, 150, 36, 16, "skinShade", 2) + r(208, 134, 36, 16, "skinShade", 2) + r(246, 134, 30, 16, "skin", 2) + P(130, top="orange", bottom="brown", hair="ink", arms="L")
        + arm(130, 1, 168, 100, "orange") + ln(168, 100, 188, 76, "brown", 5) + r(180, 64, 26, 14, "greyShade", 3) + p("M110 50C110 24 150 24 150 50Z", "orange") + ground(),
    "buy": lambda: P(110, top="teal", hair="brown", arms="L") + arm(110, 1, 146, 130) + r(136, 126, 30, 38, "orange", 3) + s("M142 126C142 110 160 110 160 126", "brown", 4)
        + c(232, 104, 22, "orange") + ring(232, 104, 15, "skinShade", "none", 3) + c(262, 140, 14, "orange") + ground(),
    "carry": lambda: P(170, top="orange", hair="brown", arms="") + ln(148, 90, 126, 128, "orange", 6) + ln(192, 90, 214, 128, "orange", 6) + r(106, 126, 38, 38, "teal", 4) + r(196, 126, 38, 38, "green", 4)
        + s("M114 126C114 112 136 112 136 126", "brown", 4) + s("M204 126C204 112 226 112 226 126", "brown", 4) + ground(),
    "change": lambda: circ_arrows() + c(170, 102, 14, "orange") + ring(170, 102, 8, "skinShade", "none", 3),
    "check": lambda: r(100, 40, 120, 134, "brown", 6) + r(108, 52, 104, 114, "cream", 3) + r(140, 34, 40, 20, "grey", 5) + "".join(ln(150, y, 200, y, "grey", 3) + s(f"M120 {y}L126 {y + 6}L136 {y - 8}", "green", 4) for y in (80, 106, 132)),
    "choose": lambda: r(70, 70, 60, 80, "cream", 6) + r(140, 70, 60, 80, "orange", 6) + r(210, 70, 60, 80, "cream", 6) + s("M156 112L168 126L190 96", "cream", 6) + p("M250 150L244 120L262 132L276 128L262 152Z", "skin"),
    "clean": lambda: P(120, top="teal", hair="brown", arms="L") + arm(120, 1, 160, 120) + ln(160, 120, 196, 168, "brown", 5) + e(204, 170, 24, 6, "orange") + r(230, 134, 40, 40, "grey", 5) + e(250, 134, 20, 5, "teal")
        + star(240, 70, 10, 4, "orange") + star(270, 100, 7, 3, "orange") + ground(),
    "climb": lambda: ln(130, 30, 130, 176, "brown", 6) + ln(210, 30, 210, 176, "brown", 6) + "".join(ln(130, y, 210, y, "skinShade", 5) for y in (50, 80, 110, 140)) + P(170, 0.6, top="orange", hair="brown", arms="", base=150)
        + ln(160, 90, 134, 66, "orange", 6) + ln(180, 90, 206, 56, "orange", 6) + ground(100, 240),
    "close": lambda: r(110, 34, 120, 142, "deepTeal", 5) + p("M124 44L190 56V160L124 168Z", "brown") + c(176, 108, 5, "orange") + s("M236 70C262 80 262 130 238 142", "orange", 5) + p("M246 150L236 134L256 132Z", "orange"),
    "come": lambda: P(190, top="orange", hair="brown", arms="L") + arm(190, 1, 232, 70, "orange") + ln(232, 70, 244, 92, "orange", 6) + s("M70 90L100 106L70 122", "teal", 7) + s("M100 90L130 106L100 122", "teal", 7) + ground(),
    "cook": lambda: P(120, top="cream", bottom="deepTeal", hair="ink", arms="L") + arm(120, 1, 164, 118, "cream") + e(120, 44, 22, 10, "cream") + c(106, 36, 11, "cream") + c(134, 36, 11, "cream") + r(176, 110, 70, 50, "grey", 4)
        + r(186, 90, 50, 22, "teal", 4) + steam(200, 84) + steam(224, 84) + ground(),
    "create": lambda: c(130, 92, 36, "orange") + r(116, 126, 28, 16, "grey", 4) + s("M116 90L124 76L130 90L136 76L144 90", "ink", 3) + p("M204 150L226 56L246 62L224 156Z", "brown") + p("M204 150L214 176L224 156Z", "skin") + star(262, 46, 12, 5, "orange") + star(90, 150, 8, 3, "teal"),
    "cut": lambda: ln(110, 54, 220, 130, "grey", 8) + ln(110, 140, 220, 64, "grey", 8) + ring(100, 46, 15, "orange", "none", 6) + ring(100, 148, 15, "orange", "none", 6) + r(226, 90, 56, 26, "cream", 2)
        + ln(226, 103, 252, 103, "greyShade", 3),
    "die": lambda: ground(70, 270) + s("M170 176C170 140 176 110 204 100", "green", 6) + e(206, 108, 16, 7, "earPink", -30) + e(190, 124, 12, 6, "skinShade", 30) + e(164, 150, 14, 6, "green", -35) + c(214, 140, 7, "earPink") + c(238, 164, 7, "skinShade"),
    "draw": lambda: P(100, top="teal", hair="brown", arms="L") + arm(100, 1, 150, 100) + ln(150, 100, 168, 80, "orange", 5) + r(170, 44, 96, 80, "cream", 4) + s("M184 108L204 70L224 108Z", "ink", 3) + r(194, 90, 20, 18, "skin", 1) + ln(176, 150, 176, 176, "brown", 5)
        + ln(260, 150, 260, 176, "brown", 5) + ln(176, 124, 260, 124, "brown", 5) + ground(),
    "dress": lambda: P(130, top="orange", hair="brown") + ln(226, 50, 226, 60, "grey", 3) + ln(180, 56, 280, 56, "brown", 5) + p("M232 66H256L268 150H220Z", "teal") + p("M196 66H216L222 100L206 108L200 100Z", "green"),
    "drink": lambda: P(150, top="teal", hair="brown", arms="L") + ln(172, 88, 164, 72, "teal", 6) + r(156, 62, 16, 24, "cream", 3) + r(156, 72, 16, 14, "orange", 3) + c(168, 90, 5, "skin") + e(150, 70, 6, 3, "ink") + r(210, 140, 50, 8, "brown", 3) + r(222, 148, 8, 28, "brown", 2) + ground(),
    "drive": lambda: BASE["car"]() + c(158, 92, 11, "skin") + e(158, 85, 12, 6, "ink") + ln(60, 100, 86, 100, "grey", 3) + ln(52, 116, 84, 116, "grey", 3) + ln(266, 100, 296, 100, "grey", 3),
    "eat": lambda: P(110, top="orange", hair="brown", arms="L") + ln(132, 88, 144, 70, "orange", 6) + ln(144, 70, 152, 66, "grey", 4) + c(144, 70, 5, "skin") + table(170, 280, 130) + bowl(220, 106, 30, 22, "teal") + c(210, 104, 5, "green") + ground(),
    "end": lambda: ln(120, 176, 120, 36, "brown", 5) + "".join(r(124 + i * 24, 36 + j * 24, 24, 24, "ink" if (i + j) % 2 else "cream") for i in range(5) for j in range(3)) + c(120, 32, 5, "orange") + ground(70, 270),
    "enjoy": lambda: c(250, 56, 20, "orange") + P(150, top="orange", hair="brown", arms="") + ln(128, 90, 108, 56, "orange", 6) + ln(172, 90, 192, 56, "orange", 6) + c(108, 52, 5, "skin") + c(192, 52, 5, "skin") + s("M144 70C150 78 160 78 166 70", "ink", 3)
        + heart(246, 130, 10, "skinShade") + star(80, 120, 8, 3, "orange") + ground(),
    "exercise": lambda: P(170, top="green", bottom="deepTeal", hair="ink", arms="") + ln(148, 90, 118, 58, "green", 6) + ln(192, 90, 222, 58, "green", 6) + c(118, 54, 5, "skin") + c(222, 54, 5, "skin") + ln(80, 176, 100, 176, "ink", 6) + r(240, 156, 30, 20, "ink", 3) + ground(),
    "fall": lambda: ground(60, 290) + p("M232 168C222 170 220 160 232 160L262 164C268 170 258 174 250 172Z", "orange") + r(116, 124, 78, 30, "teal", 12) + c(100, 134, 18, "skin") + e(96, 124, 16, 9, "ink") + ln(190, 134, 232, 110, "deepTeal", 11) + ln(190, 148, 238, 140, "deepTeal", 11)
        + ln(140, 126, 130, 86, "teal", 6) + ln(160, 126, 172, 84, "teal", 6) + star(86, 96, 9, 4, "orange") + star(120, 80, 7, 3, "orange"),
    "fill": lambda: r(180, 36, 56, 64, "teal", 10) + s("M236 52C256 52 256 84 236 84", "teal", 6) + p("M180 50L164 60L180 66Z", "teal") + ln(164, 62, 140, 130, "teal", 5) + p("M96 120H184L176 172H104Z", "cream") + p("M99 138H181L176 172H104Z", "teal") + ground(70, 280),
    "find": lambda: ring(150, 94, 42, "brown", "cream", 8) + star(150, 94, 22, 9, "orange") + ln(182, 126, 232, 172, "brown", 12) + c(250, 60, 4, "orange") + c(80, 140, 4, "orange"),
    "finish": lambda: P(170, top="green", hair="brown", arms="") + ln(148, 90, 124, 62, "green", 6) + ln(192, 90, 216, 62, "green", 6) + ln(80, 112, 150, 112, "orange", 4) + ln(190, 112, 260, 112, "orange", 4) + ln(80, 112, 80, 176, "grey", 5) + ln(260, 112, 260, 176, "grey", 5)
        + star(100, 54, 8, 3, "orange") + star(246, 44, 8, 3, "orange") + ground(60, 280),
    "fly": lambda: cloud(86, 140) + cloud(262, 56) + p("M150 98C134 60 104 52 80 60C104 66 120 86 134 110Z", "deepTeal") + p("M190 98C206 60 236 52 260 60C236 66 220 86 206 110Z", "deepTeal") + e(170, 108, 34, 18, "teal") + c(204, 100, 12, "teal")
        + p("M214 98L232 104L214 108Z", "orange") + eye(206, 98) + p("M136 108L108 124L140 118Z", "teal"),
    "follow": lambda: duck(96, 150, 1.3) + duck(168, 154, 1.0) + duck(222, 156, 0.8) + duck(264, 158, 0.6) + e(170, 174, 120, 6, "teal"),
    "give": lambda: P(100, top="teal", hair="brown", arms="L") + arm(100, 1, 150, 114) + woman(240, 1.0, "orange", "deepTeal") + r(142, 100, 36, 30, "deepTeal", 3) + r(142, 112, 36, 6, "orange") + r(156, 100, 8, 30, "orange") + heart(170, 66, 10, "skinShade") + ground(50, 290),
    "go": lambda: walker(110, "orange", hair="brown") + arrow(176, 100, 270) + ground(60, 290),
    "grow": lambda: "".join(r(x - 20, 150, 40, 26, "orange", 4) for x in (80, 170, 260)) + ln(80, 150, 80, 136, "green", 4) + ln(170, 150, 170, 108, "green", 5) + e(158, 112, 14, 6, "green", -30) + e(182, 106, 14, 6, "green", 30)
        + ln(260, 150, 260, 60, "green", 6) + e(240, 90, 20, 8, "green", -30) + e(280, 80, 20, 8, "green", 30) + e(240, 120, 18, 7, "green", -20) + e(280, 112, 18, 7, "green", 20) + c(260, 56, 9, "orange") + ground(40, 300),
    "hear": lambda: BASE["ear"]() + s("M118 70C102 90 102 114 118 134", "orange", 5) + s("M98 54C70 86 70 118 98 150", "orange", 5),
    "join": lambda: r(98, 70, 76, 76, "teal", 8) + c(174, 108, 14, "teal") + r(180, 70, 76, 76, "orange", 8) + c(180, 108, 14, "halo") + ln(98, 160, 256, 160, "brown", 4) + heart(226, 56, 8, "skinShade"),
    "laugh": lambda: P(170, top="orange", hair="brown") + e(170, 70, 7, 5, "ink") + s("M136 50C128 58 128 66 134 72", "orange", 4) + s("M204 50C212 58 212 66 206 72", "orange", 4) + s("M126 36C116 44 114 56 118 64", "orange", 4) + s("M214 36C224 44 226 56 222 64", "orange", 4) + ground(),
    "learn": lambda: P(110, top="teal", hair="brown", arms="") + ln(132, 90, 150, 108, "teal", 6) + ln(88, 90, 70, 108, "teal", 6) + p("M70 100L110 108L150 100V136L110 144L70 136Z", "cream") + ln(110, 108, 110, 144, "brown", 3) + c(220, 60, 26, "orange") + r(210, 84, 20, 12, "grey", 3) + s("M210 56L216 44L220 56L224 44L230 56", "ink", 3) + ground(),
    "leave": lambda: ln(240, 50, 240, 176, "brown", 5) + p("M200 48L240 40V176L200 170Z", "teal") + P(150, top="orange", hair="brown") + r(96, 130, 40, 34, "teal", 5) + s("M106 130V120H126V130", "brown", 4) + arrow(110, 60, 60, "grey") + ground(),
    "lie": lambda: ground(50, 290) + r(70, 136, 40, 18, "cream", 8) + c(90, 128, 15, "skin") + e(86, 118, 14, 8, "brown") + r(104, 132, 100, 28, "teal", 12) + r(190, 134, 60, 22, "deepTeal", 8) + c(262, 148, 8, "ink") + eye(94, 126)
        + cloud(220, 64) + star(90, 56, 8, 3, "orange"),
    "listen": lambda: P(170, top="teal", hair="ink") + s("M150 64C150 34 190 34 190 64", "ink", 5) + r(144, 56, 10, 18, "orange", 3) + r(186, 56, 10, 18, "orange", 3) + note(80, 80) + note(250, 70) + ground(),
    "live": lambda: BASE["house"]() + P(171, 0.5, top="orange", hair="brown", base=176) + heart(250, 60, 10, "skinShade"),
    "look": lambda: P(170, top="teal", hair="brown") + r(156, 56, 28, 8, "ink", 3) + ring(160, 64, 10, "ink", "grey", 4) + ring(180, 64, 10, "ink", "grey", 4) + ln(90, 100, 140, 100, "orange", 3) + ln(200, 100, 250, 100, "orange", 3) + ground(),
    "lose": lambda: P(150, top="teal", hair="brown") + s("M142 74C150 66 160 66 166 74", "ink", 3) + c(206, 70, 12, "orange") + c(220, 110, 12, "orange") + c(204, 150, 12, "orange") + ring(206, 70, 7, "skinShade", "none", 3) + ln(150, 38, 150, 30, "ink", 3) + ground(),
    "make": lambda: table(60, 280, 128) + p("M130 128V84L170 56L210 84V128Z", "skin") + p("M118 88L170 48L222 88Z", "brown") + c(170, 100, 12, "ink") + r(238, 96, 12, 32, "brown", 3) + r(226, 88, 36, 12, "greyShade", 3) + star(110, 60, 8, 3, "orange") + ground(),
    "match": lambda: c(110, 60, 16, "teal") + r(94, 94, 32, 32, "orange", 3) + p("M110 138L128 168H92Z", "green") + c(230, 60, 16, "teal") + r(214, 94, 32, 32, "orange", 3) + p("M230 138L248 168H212Z", "green") + ln(126, 60, 214, 60, "ink", 3) + ln(126, 110, 214, 110, "ink", 3) + ln(122, 160, 220, 160, "ink", 3),
    "meet": lambda: P(110, top="teal", hair="brown", arms="") + P(230, top="orange", hair="ink", arms="") + ln(132, 90, 168, 112, "teal", 6) + ln(208, 90, 172, 112, "orange", 6) + c(170, 112, 7, "skin") + heart(170, 56, 10, "skinShade") + ground(60, 280),
    "move": lambda: r(60, 66, 130, 84, "orange", 6) + r(190, 90, 60, 60, "teal", 6) + r(200, 98, 32, 24, "cream", 3) + ln(60, 152, 252, 152, "ink", 5) + c(100, 158, 16, "ink") + c(100, 158, 6, "grey") + c(220, 158, 16, "ink") + c(220, 158, 6, "grey")
        + r(76, 80, 36, 30, "skin", 3) + r(118, 90, 52, 22, "skinShade", 3) + ln(262, 100, 300, 100, "grey", 4) + ln(270, 120, 300, 120, "grey", 4),
    "open": lambda: r(110, 34, 120, 142, "deepTeal", 5) + r(120, 44, 100, 132, "orange", 2) + p("M120 44L96 56V164L120 176Z", "brown") + c(104, 108, 4, "orange") + ground(70, 280),
    "order": lambda: P(150, top="cream", bottom="ink", hair="ink", arms="") + p("M142 84L150 88L142 92Z M158 84L150 88L158 92Z", "ink") + ln(128, 90, 130, 118, "cream", 6) + ln(172, 90, 190, 106, "cream", 6) + r(176, 98, 28, 36, "cream", 3) + ln(182, 110, 198, 110, "grey", 3) + ln(182, 120, 194, 120, "grey", 3)
        + ln(204, 92, 192, 118, "orange", 4) + e(250, 150, 24, 8, "grey") + p("M226 150C226 120 274 120 274 150Z", "cream") + ground(),
    "paint": lambda: r(190, 40, 90, 130, "cream", 3) + r(190, 40, 46, 130, "orange", 3) + P(110, top="teal", hair="brown", arms="L") + arm(110, 1, 150, 100) + ln(150, 100, 190, 100, "brown", 5) + r(180, 86, 26, 28, "orange", 4) + ground(),
    "park": lambda: BASE["car"]() + ln(60, 176, 60, 120, "cream", 4) + ln(280, 176, 280, 120, "cream", 4) + r(250, 34, 40, 40, "teal", 6) + r(262, 44, 6, 22, "cream") + ring(272, 52, 7, "cream", "none", 4) + ln(270, 74, 270, 120, "grey", 4),
    "pay": lambda: r(180, 112, 100, 64, "brown", 3) + r(176, 104, 108, 10, "skinShade", 2) + r(204, 78, 52, 28, "greyShade", 4) + r(212, 86, 36, 12, "teal", 2) + P(110, top="teal", hair="brown", arms="L") + arm(110, 1, 156, 108) + r(150, 98, 34, 22, "orange", 3) + ln(150, 106, 184, 106, "ink", 3) + ground(),
    "practise": lambda: P(110, top="teal", hair="brown") + ln(220, 60, 220, 176, "grey", 4) + r(190, 50, 60, 44, "cream", 3) + "".join(ln(198, y, 242, y, "grey", 3) for y in (62, 72, 82)) + c(212, 76, 4, "ink") + c(230, 68, 4, "ink") + e(280, 66, 8, 12, "skin") + ln(260, 150, 280, 150, "ink", 6) + ground(),
    "prepare": lambda: P(110, top="cream", bottom="deepTeal", hair="ink", arms="") + ln(132, 90, 164, 122, "cream", 6) + table(150, 290, 130) + r(176, 118, 70, 12, "brown", 3) + p("M196 118L232 106L236 114L200 122Z", "orange") + ln(240, 100, 262, 106, "grey", 5) + c(262, 106, 3, "ink") + e(120, 44, 20, 9, "cream") + ground(),
    "put": lambda: P(100, top="teal", hair="brown", arms="L") + arm(100, 1, 160, 76) + r(150, 66, 12, 28, "orange", 2) + r(180, 110, 100, 8, "brown", 3) + "".join(r(x, 80, 14, 30, col, 2) for x, col in ((190, "teal"), (206, "green"), (222, "orange"), (238, "deepTeal"))) + ground(),
    "read": lambda: woman(170, 1.0, "teal", "orange") + p("M144 96L170 104L196 96V132L170 140L144 132Z", "cream") + ln(170, 104, 170, 140, "brown", 3) + glasses(170) + c(250, 120, 24, "orange") + r(244, 144, 12, 32, "brown", 3) + ground(),
    "relax": lambda: c(250, 50, 20, "orange") + ln(90, 176, 130, 120, "brown", 6) + ln(190, 176, 210, 130, "brown", 6) + p("M80 120H220L200 140H100Z", "orange") + r(104, 106, 110, 18, "teal", 8) + c(88, 98, 16, "skin") + e(84, 88, 15, 8, "brown") + r(160, 100, 56, 14, "deepTeal", 5) + r(236, 130, 20, 32, "cream", 3) + ln(246, 130, 256, 112, "orange", 4) + ground(50, 290),
    "repeat": lambda: circ_arrows() + p("M158 88L190 102L158 116Z", "green"),
    "ride": lambda: BASE["bicycle"]() + c(176, 44, 13, "skin") + e(176, 36, 14, 7, "ink") + ln(170, 84, 178, 56, "orange", 14) + ln(180, 62, 212, 80, "orange", 6) + ln(170, 92, 150, 114, "deepTeal", 9) + ln(150, 114, 166, 126, "deepTeal", 9),
    "run": lambda: runner(180, "orange", hair="brown") + ground(60, 290),
    "say": lambda: P(110, top="teal", hair="brown") + e(230, 70, 54, 36, "cream") + p("M196 90L182 116L216 100Z", "cream") + ln(204, 58, 256, 58, "grey", 3) + ln(204, 72, 244, 72, "grey", 3) + ln(204, 86, 232, 86, "grey", 3) + ground(),
    "see": lambda: BASE["eye"]() + star(238, 56, 10, 4, "orange") + star(100, 52, 8, 3, "orange") + ln(250, 130, 276, 144, "orange", 4),
    "sell": lambda: p("M60 40H280L270 66H70Z", "orange") + "".join(r(x, 40, 20, 26, "cream") for x in range(70, 270, 40)) + r(90, 120, 160, 10, "brown", 3) + r(100, 130, 8, 46, "brown", 2) + r(232, 130, 8, 46, "brown", 2) + P(170, 0.8, top="teal", hair="brown", base=130) + c(112, 108, 10, "green") + c(136, 108, 10, "orange") + c(206, 108, 10, "green")
        + c(230, 108, 10, "orange") + ground(),
    "send": lambda: p("M80 120L260 50L200 150L170 126L150 150L140 122Z", "cream") + p("M260 50L170 126L200 150Z", "grey") + s("M60 150C90 150 100 130 120 134", "orange", 4) + r(92, 52, 46, 32, "orange", 3) + s("M92 54L115 72L138 54", "cream", 3),
    "share": lambda: P(110, 0.85, top="teal", hair="brown", arms="") + P(230, 0.85, top="orange", hair="ink", arms="") + ln(130, 104, 160, 120, "teal", 6) + ln(210, 104, 180, 120, "orange", 6) + e(163, 124, 14, 12, "skin") + e(177, 124, 14, 12, "skinShade") + heart(170, 66, 9, "skinShade") + ground(50, 290),
    "shop": lambda: P(220, top="orange", hair="brown", arms="") + ln(198, 90, 170, 108, "orange", 6) + p("M70 92H170L158 144H84Z", "grey") + ln(56, 80, 70, 92, "greyShade", 5) + ln(86, 96, 90, 140, "greyShade", 3) + ln(110, 96, 112, 142, "greyShade", 3) + ln(134, 96, 134, 142, "greyShade", 3)
        + c(94, 160, 8, "ink") + c(150, 160, 8, "ink") + r(100, 72, 20, 22, "teal", 3) + c(142, 80, 12, "green") + ground(),
    "show": lambda: r(150, 44, 130, 90, "brown", 5) + r(158, 52, 114, 74, "cream", 3) + r(170, 100, 20, 20, "teal") + r(198, 80, 20, 40, "orange") + r(226, 64, 20, 56, "green") + P(96, top="teal", hair="brown", arms="L") + arm(96, 1, 144, 80) + ln(144, 80, 170, 70, "brown", 4) + ground(),
    "sing": lambda: P(110, 0.8, top="orange", hair="brown") + woman(170, 0.8, "teal", "orange") + P(230, 0.8, top="green", hair="ink") + e(110, 82, 4, 3, "ink") + e(170, 82, 4, 3, "ink") + e(230, 82, 4, 3, "ink") + note(70, 90) + note(266, 84) + ground(50, 290),
    "sit": lambda: r(190, 118, 70, 10, "brown", 3) + r(250, 60, 10, 66, "brown", 3) + r(196, 128, 8, 48, "brown", 2) + r(246, 128, 8, 48, "brown", 2) + r(210, 70, 38, 56, "teal", 10) + c(228, 54, 17, "skin") + e(228, 45, 18, 10, "brown") + eye(234, 54)
        + r(180, 118, 62, 16, "deepTeal", 6) + r(166, 124, 16, 50, "deepTeal", 5) + r(160, 168, 24, 8, "ink", 3) + ground(),
    "sleep": lambda: BASE["bed"]() + c(116, 108, 14, "skin") + e(112, 100, 14, 8, "brown") + r(100, 112, 150, 30, "teal", 8) + s("M190 62H210L190 82H212", "ink", 4) + s("M222 40H238L222 56H240", "ink", 4),
    "speak": lambda: r(196, 96, 56, 80, "brown", 4) + r(190, 90, 68, 10, "skinShade", 2) + ln(224, 90, 224, 70, "grey", 4) + c(224, 64, 6, "ink") + P(130, top="teal", hair="brown", arms="") + ln(152, 90, 186, 100, "teal", 6) + ln(108, 90, 90, 112, "teal", 6) + "".join(c(x, 172, 9, "ink") for x in (70, 100)) + s("M156 36C162 28 168 28 174 36", "orange", 3) + ground(),
    "spend": lambda: r(110, 100, 100, 64, "brown", 8) + p("M110 106H210V122H110Z", "skinShade") + r(186, 120, 24, 20, "orange", 4) + c(150, 70, 12, "orange") + c(190, 52, 12, "orange") + c(226, 76, 12, "orange") + ring(150, 70, 7, "skinShade", "none", 3) + ring(190, 52, 7, "skinShade", "none", 3) + ring(226, 76, 7, "skinShade", "none", 3) + ground(),
    "stand": lambda: P(170, top="teal", hair="brown") + e(170, 175, 44, 5, "brown") + ln(120, 176, 220, 176, "grey", 3),
    "start": lambda: c(170, 102, 58, "green") + ring(170, 102, 58, "deepTeal", "none", 5) + p("M152 70L206 102L152 134Z", "cream"),
    "stay": lambda: BASE["bed"]() + r(236, 138, 44, 32, "orange", 5) + s("M248 138V128H268V138", "brown", 4) + c(120, 56, 12, "orange") + ln(120, 68, 120, 84, "orange", 4) + ln(120, 78, 130, 78, "orange", 3),
    "stop": lambda: ln(170, 150, 170, 176, "grey", 6) + p("M140 36H200L240 72V120L200 156H140L100 120V72Z", "skinShade") + r(130, 88, 80, 16, "cream", 3),
    "study": lambda: r(70, 134, 200, 8, "brown", 3) + r(80, 142, 8, 34, "brown", 2) + r(252, 142, 8, 34, "brown", 2) + P(150, top="teal", hair="brown", style="long") + r(104, 112, 62, 22, "cream", 3) + r(100, 120, 40, 14, "orange", 3) + r(196, 110, 36, 8, "teal", 3) + r(190, 100, 36, 12, "green", 3)
        + p("M246 78H270L264 100H252Z", "orange") + ln(258, 100, 258, 134, "grey", 4) + ground(),
    "swim": lambda: r(50, 112, 240, 64, "teal", 6) + c(150, 100, 15, "skin") + e(150, 90, 17, 10, "teal") + ring(156, 100, 6, "ink", "none", 3) + ln(128, 104, 88, 82, "skin", 8) + ln(168, 108, 224, 88, "skin", 8) + ln(56, 140, 284, 140, "cream", 3)
        + "".join(s(f"M{60 + i * 56} 156C{72 + i * 56} 148 {84 + i * 56} 164 {96 + i * 56} 156", "cream", 3) for i in range(4)),
    "take": lambda: r(190, 98, 12, 78, "brown", 3) + c(196, 76, 42, "green") + c(166, 96, 26, "green") + c(228, 100, 26, "green") + c(212, 70, 7, "skinShade") + c(180, 84, 7, "skinShade") + P(110, top="orange", hair="brown", arms="L") + arm(110, 1, 150, 60, "orange") + ln(150, 60, 204, 66, "orange", 6) + ground(),
    "talk": lambda: P(100, top="teal", hair="brown") + woman(240, 1.0, "orange", "deepTeal") + e(120, 40, 26, 14, "cream") + e(220, 52, 26, 14, "cream") + c(112, 40, 3, "grey") + c(122, 40, 3, "grey") + c(130, 40, 3, "grey") + c(212, 52, 3, "grey") + c(222, 52, 3, "grey") + c(230, 52, 3, "grey") + ground(50, 290),
    "teach": lambda: r(150, 40, 130, 84, "brown", 5) + r(158, 48, 114, 68, "deepTeal", 3) + c(184, 82, 14, "cream") + r(206, 68, 26, 26, "cream", 2) + p("M252 70L266 98H238Z", "cream") + woman(100, 1.0, "teal", "deepTeal") + ln(124, 90, 160, 70, "brown", 3) + glasses(100) + ground(),
    "tell": lambda: P(100, top="teal", hair="brown") + P(230, 0.55, top="orange", hair="ink") + e(150, 50, 40, 26, "cream") + p("M130 70L120 92L148 72Z", "cream") + star(150, 50, 14, 6, "orange") + heart(250, 90, 8, "skinShade") + ground(60, 290),
    "thank": lambda: P(150, top="orange", hair="brown", arms="") + ln(132, 90, 150, 110, "orange", 6) + ln(168, 90, 150, 110, "orange", 6) + c(150, 112, 6, "skin") + s("M142 70C150 78 160 78 166 70", "ink", 3) + heart(224, 70, 20, "skinShade") + ln(240, 176, 240, 130, "green", 4) + c(240, 124, 8, "cream") + c(230, 130, 7, "orange") + c(250, 130, 7, "orange") + ground(),
    "think": lambda: P(130, top="teal", hair="brown", arms="L") + ln(152, 88, 142, 100, "teal", 6) + c(135, 74, 5, "skin") + c(176, 52, 5, "cream") + c(192, 40, 7, "cream") + e(236, 56, 44, 28, "cream") + c(214, 52, 4, "grey") + c(236, 52, 4, "grey") + c(258, 52, 4, "grey") + ground(),
    "try": lambda: c(170, 100, 62, "cream") + ring(170, 100, 62, "ink", "none", 4) + c(170, 100, 44, "teal") + c(170, 100, 26, "cream") + c(170, 100, 10, "skinShade") + ln(240, 40, 184, 92, "brown", 5) + p("M180 98L190 82L196 90Z", "grey"),
    "turn": lambda: s("M110 170V100C110 60 190 50 220 90", "teal", 16) + p("M244 92L204 94L226 58Z", "teal") + ln(86, 176, 134, 176, "grey", 5),
    "wait": lambda: P(110, top="teal", hair="brown", arms="L") + arm(110, 1, 126, 86) + ring(234, 94, 42, "brown", "cream", 6) + ln(234, 94, 234, 66, "ink", 4) + ln(234, 94, 252, 104, "ink", 4) + c(234, 94, 4, "ink") + c(190, 160, 4, "grey") + c(206, 160, 4, "grey") + c(222, 160, 4, "grey") + ground(),
    "wake": lambda: c(170, 108, 48, "orange") + c(170, 108, 36, "cream") + ln(170, 108, 170, 84, "ink", 4) + ln(170, 108, 188, 116, "ink", 4) + c(134, 66, 16, "greyShade") + c(206, 66, 16, "greyShade") + ln(150, 150, 140, 170, "ink", 5) + ln(190, 150, 200, 170, "ink", 5)
        + s("M106 80L90 70M104 108L84 108M232 80L248 70M236 108L256 108", "orange", 4),
    "walk": lambda: walker(160, "teal", hair="brown") + r(90, 178, 160, 4, "brown") + c(240, 70, 18, "orange") + ground(60, 280),
    "wash": lambda: ln(170, 36, 170, 52, "grey", 6) + p("M140 52H200V64H184V76H156V64H140Z", "grey") + ln(170, 82, 168, 112, "teal", 5) + bowl(170, 128, 70, 28, "cream") + e(150, 112, 22, 12, "skin") + e(190, 112, 22, 12, "skin")
        + c(120, 92, 11, "cream") + c(222, 88, 9, "cream") + c(104, 116, 7, "cream") + c(238, 110, 7, "cream") + c(150, 96, 6, "cream") + ground(80, 260),
    "watch": lambda: P(100, top="teal", hair="brown") + r(150, 56, 120, 82, "brown", 8) + r(158, 64, 104, 66, "teal", 4) + p("M192 80L222 98L192 116Z", "cream") + r(190, 138, 20, 20, "brown", 2) + r(172, 156, 56, 8, "brown", 3) + ground(),
    "wear": lambda: P(170, top="orange", hair="brown") + e(170, 46, 30, 6, "teal") + p("M154 46C154 24 186 24 186 46Z", "teal") + r(148, 80, 44, 12, "teal", 5) + r(184, 86, 12, 30, "teal", 4) + ground(),
    "welcome": lambda: r(100, 34, 140, 142, "deepTeal", 5) + r(110, 44, 120, 132, "orange", 2) + P(170, top="teal", hair="brown", arms="L") + arm(170, 1, 214, 62) + r(130, 172, 80, 6, "brown", 3) + heart(120, 60, 9, "skinShade") + ground(80, 260),
    "win": lambda: P(170, 0.78, top="green", hair="brown", arms="") + ln(153, 107, 146, 46, "green", 6) + ln(187, 107, 194, 46, "green", 6) + c(146, 42, 5, "skin") + c(194, 42, 5, "skin")
        + p("M152 20H188V36C188 48 182 52 170 52C158 52 152 48 152 36Z", "orange") + ln(170, 52, 170, 62, "orange", 5) + star(96, 70, 9, 4, "orange") + star(246, 60, 9, 4, "orange") + star(80, 130, 7, 3, "orange") + ground(),
    "work": lambda: r(70, 134, 200, 8, "brown", 3) + r(80, 142, 8, 34, "brown", 2) + r(252, 142, 8, 34, "brown", 2) + P(130, top="teal", hair="ink") + r(150, 112, 60, 22, "greyShade", 4) + r(156, 86, 48, 28, "teal", 3) + r(224, 120, 16, 14, "orange", 3) + ground(),
    "write": lambda: r(90, 56, 160, 110, "cream", 4) + "".join(ln(104, y, 190, y, "grey", 3) for y in (80, 100, 120)) + ln(104, 140, 150, 140, "ink", 3) + e(220, 140, 30, 14, "skin", -20) + ln(214, 142, 170, 118, "orange", 7) + p("M170 118L160 112L164 124Z", "ink"),
    "design": lambda: r(70, 44, 200, 126, "teal", 6) + ring(150, 104, 30, "cream", "none", 3) + r(190, 60, 60, 40, "cream", 2) + ln(80, 156, 180, 156, "cream", 3) + ln(200, 116, 250, 116, "cream", 3) + ln(200, 130, 240, 130, "cream", 3)
        + p("M246 150L262 100L274 106L256 156Z", "orange") + p("M246 150L252 168L256 156Z", "skin"),
}

WORDS = {f"{k}_verb": v for k, v in V.items()}

if __name__ == "__main__":
    write(WORDS)
