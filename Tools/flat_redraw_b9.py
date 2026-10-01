#!/usr/bin/env python3
"""Flat colour batch 9: time, places, media, abstract nouns (100 words). Shares helpers with flat_redraw.py / _b7 / _b8.

Run: python3 Tools/flat_redraw_b9.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

import math

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s, write
from flat_redraw_b7 import P, curtains, heart, note, star, woman
from flat_redraw_b8 import bowl, cloud, pine, steam, stripes


def gear(cx, cy, big, teeth, fill, hole=True):
    o = c(cx, cy, big * 0.8, fill)
    for i in range(teeth):
        a = 2 * math.pi * i / teeth
        ux, uy, vx, vy = math.cos(a), math.sin(a), -math.sin(a), math.cos(a)
        w = big * 0.16
        pts = [(cx + ux * big * 0.7 + vx * w, cy + uy * big * 0.7 + vy * w), (cx + ux * big + vx * w * 0.8, cy + uy * big + vy * w * 0.8),
               (cx + ux * big - vx * w * 0.8, cy + uy * big - vy * w * 0.8), (cx + ux * big * 0.7 - vx * w, cy + uy * big * 0.7 - vy * w)]
        o += p("M" + "L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + "Z", fill)
    return o + (c(cx, cy, big * 0.3, "halo") if hole else "")


def compass(dx, dy):
    """Compass rose: needle tip toward (dx, dy), drawn as two triangles."""
    tip = (170 + 46 * dx, 102 + 46 * dy)
    tail = (170 - 46 * dx, 102 - 46 * dy)
    px, py = -dy * 12, dx * 12
    return (ring(170, 102, 62, "brown", "cream", 5)
            + p(f"M{tip[0]:.0f} {tip[1]:.0f}L{170 + px:.0f} {102 + py:.0f}L{170 - px:.0f} {102 - py:.0f}Z", "orange")
            + p(f"M{tail[0]:.0f} {tail[1]:.0f}L{170 + px:.0f} {102 + py:.0f}L{170 - px:.0f} {102 - py:.0f}Z", "grey") + c(170, 102, 5, "ink")
            + "".join(c(170 + 52 * ux, 102 + 52 * uy, 3, "brown") for ux, uy in ((1, 0), (-1, 0), (0, 1), (0, -1))))


def tv(x, y, w, h, body, screen):
    return r(x, y, w, h, body, 8) + r(x + 8, y + 8, w - 16, h - 16, screen, 3)


def banknote(x, y, w, h, fill):
    return r(x, y, w, h, fill, 6) + ring(x + w / 2, y + h / 2, h * 0.3, "cream", "none", 4) + c(x + 16, y + 16, 5, "cream") + c(x + w - 16, y + h - 16, 5, "cream")


def tower(x, y, w, h, body, cols=2, rows=4, win="cream"):
    o = r(x, y, w, h, body, 3)
    gx, gy = w / (cols + 0.4), (h - 16) / rows
    for i in range(cols):
        for j in range(rows):
            o += r(x + gx * 0.4 + i * gx, y + 10 + j * gy, gx * 0.6, gy * 0.55, win, 2)
    return o


WORDS = {
    "afternoon": lambda: c(236, 66, 26, "orange") + p("M40 176C90 120 160 120 220 150C250 160 280 168 300 176Z", "green") + r(120, 120, 10, 56, "brown", 3) + c(125, 104, 24, "green")
        + e(176, 170, 30, 5, "deepTeal") + ground(40, 300),
    "air": lambda: s("M70 84C120 84 140 54 184 70C214 82 200 112 176 104", "grey", 5) + s("M60 120C130 120 170 100 230 118C270 130 262 156 236 150", "grey", 5)
        + s("M90 150C130 154 150 146 180 156", "grey", 5) + e(240, 70, 14, 7, "green", 30) + e(100, 56, 12, 6, "green", -20) + cloud(250, 100, "cream"),
    "animal": lambda: c(170, 130, 32, "brown") + e(134, 130, 14, 24, "brown", -20) + e(206, 130, 14, 24, "brown", 20) + c(124, 92, 15, "brown") + c(154, 70, 15, "brown")
        + c(186, 70, 15, "brown") + c(216, 92, 15, "brown") + ground(),
    "art": lambda: e(160, 110, 84, 58, "skinShade") + c(192, 128, 11, "halo") + c(110, 96, 10, "orange") + c(140, 76, 10, "teal") + c(176, 72, 10, "green") + c(212, 90, 10, "cream")
        + ln(250, 48, 214, 124, "brown", 6) + ln(214, 124, 206, 140, "teal", 8),
    "article": lambda: r(100, 34, 140, 140, "cream", 4) + r(112, 46, 116, 14, "ink", 2) + r(112, 70, 52, 38, "teal", 3) + ln(174, 76, 226, 76, "grey", 3) + ln(174, 90, 226, 90, "grey", 3)
        + "".join(ln(112, y, 228, y, "grey", 3) for y in (122, 136, 150, 164)),
    "bill": lambda: p("M120 36H220V162L210 154L200 162L190 154L180 162L170 154L160 162L150 154L140 162L130 154L120 162Z", "cream") + ln(134, 54, 206, 54, "ink", 3)
        + "".join(ln(134, y, 170, y, "grey", 3) + ln(186, y, 206, y, "grey", 3) for y in (76, 94, 112)) + r(134, 128, 72, 10, "orange", 3),
    "birthday": lambda: BASE["cake"]() + e(96, 64, 14, 18, "teal") + ln(96, 82, 110, 130, "grey", 3) + e(246, 70, 14, 18, "orange") + ln(246, 88, 234, 130, "grey", 3)
        + star(60, 40, 7, 3, "orange") + c(270, 120, 5, "green") + c(80, 110, 5, "orange"),
    "blog": lambda: r(100, 60, 140, 86, "greyShade", 8) + r(108, 68, 124, 70, "cream", 3) + r(116, 76, 40, 30, "teal", 2) + "".join(ln(164, y, 222, y, "grey", 3) for y in (82, 96, 110))
        + ln(116, 120, 222, 120, "grey", 3) + r(84, 146, 172, 10, "grey", 5) + ln(256, 70, 240, 124, "orange", 5) + ground(),
    "call": lambda: r(136, 36, 68, 124, "ink", 14) + r(144, 52, 52, 84, "teal", 4) + c(170, 100, 14, "cream") + c(170, 148, 7, "green") + s("M214 70C232 80 232 104 214 114", "orange", 4)
        + s("M226 56C254 72 254 112 226 128", "orange", 4),
    "capital": lambda: p("M110 100C110 54 230 54 230 100Z", "teal") + r(106, 96, 128, 10, "cream", 2) + "".join(r(x, 108, 14, 44, "cream", 3) for x in (116, 144, 172, 200, 214))
        + r(100, 152, 140, 10, "grey", 2) + r(90, 162, 160, 12, "greyShade", 2) + ln(170, 56, 170, 32, "brown", 4) + p("M170 32L196 40L170 48Z", "orange"),
    "card": lambda: r(90, 56, 160, 100, "teal", 10) + r(90, 76, 160, 20, "ink") + r(108, 110, 32, 24, "orange", 4) + ln(156, 118, 226, 118, "cream", 3) + ln(156, 132, 200, 132, "cream", 3),
    "cd": lambda: c(170, 102, 64, "grey") + ring(170, 102, 42, "greyShade", "none", 3) + c(170, 102, 15, "halo") + s("M126 74C140 58 160 50 180 52", "cream", 4),
    "cent": lambda: e(170, 150, 50, 12, "skin") + r(120, 130, 100, 20, "skin") + e(170, 130, 50, 12, "skinShade") + e(170, 108, 50, 12, "skin") + r(120, 88, 100, 20, "skin")
        + e(170, 88, 50, 12, "skinShade") + e(170, 66, 50, 12, "skin") + r(120, 46, 100, 20, "skin") + e(170, 46, 50, 12, "skinShade") + ground(80, 260),
    "chart": lambda: ln(80, 40, 80, 164, "ink", 4) + ln(80, 164, 270, 164, "ink", 4) + r(100, 128, 30, 34, "teal", 3) + r(142, 104, 30, 58, "orange", 3) + r(184, 78, 30, 84, "green", 3)
        + r(226, 52, 30, 110, "deepTeal", 3) + s("M100 110L150 88L196 66L248 36", "brown", 4),
    "cinema": lambda: r(80, 36, 180, 88, "ink", 4) + r(88, 44, 164, 72, "teal", 2) + p("M156 64L196 80L156 96Z", "cream") + "".join(r(x, 138, 40, 32, "orange", 8) + r(x + 6, 170, 28, 6, "brown", 2) for x in (86, 134, 182, 230)),
    "city": lambda: tower(60, 80, 50, 96, "teal") + tower(110, 40, 56, 136, "deepTeal", 2, 5) + tower(166, 70, 50, 106, "orange") + tower(216, 96, 56, 80, "skin") + c(268, 52, 16, "orange") + ground(40, 300),
    "clothes": lambda: ln(60, 54, 280, 54, "brown", 5) + ln(120, 54, 120, 66, "grey", 3) + p("M96 66H144L158 92L142 100L136 90V134H104V90L98 100L82 92Z", "teal")
        + ln(190, 54, 190, 66, "grey", 3) + p("M168 66H212L226 150H194L190 100L186 150H154Z", "deepTeal") + ln(250, 54, 250, 66, "grey", 3) + p("M236 66H264L278 140H222Z", "orange"),
    "college": lambda: p("M96 76L170 48L244 76L170 106Z", "ink") + p("M130 92V120C130 136 210 136 210 120V92L170 106Z", "deepTeal") + ln(244, 76, 244, 118, "orange", 3) + c(244, 122, 6, "orange")
        + ln(100, 170, 190, 160, "cream", 14) + ln(190, 160, 196, 158, "skinShade", 14) + ground(),
    "colour": lambda: c(110, 96, 26, "orange") + c(160, 70, 24, "teal") + c(214, 80, 24, "green") + c(240, 128, 22, "skinShade") + c(132, 146, 22, "deepTeal") + c(188, 140, 20, "cream")
        + ln(60, 170, 90, 150, "brown", 5),
    "company": lambda: tower(100, 40, 80, 136, "teal", 3, 5) + tower(180, 96, 60, 80, "deepTeal", 2, 3) + star(140, 28, 8, 3.5, "orange") + ground(70, 270),
    "concert": lambda: p("M120 30L90 150H150Z", "cream") + p("M220 30L190 150H250Z", "cream") + r(60, 150, 220, 20, "brown", 3) + P(170, 0.8, "orange", hair="ink", base=150) + ln(212, 150, 212, 96, "grey", 4)
        + c(212, 90, 6, "ink") + note(90, 70) + "".join(c(x, 170, 9, "ink") for x in (80, 110, 140, 200, 230, 260)),
    "conversation": lambda: e(130, 84, 62, 36, "teal") + p("M96 108L84 138L124 116Z", "teal") + e(212, 120, 62, 36, "orange") + p("M246 144L262 170L220 148Z", "orange")
        + "".join(c(x, 84, 5, "cream") for x in (112, 130, 148)) + "".join(c(x, 120, 5, "cream") for x in (194, 212, 230)),
    "cost": lambda: p("M96 102L148 54H252V150H148Z", "orange") + c(150, 102, 9, "halo") + ln(180, 90, 232, 90, "cream", 4) + ln(180, 110, 220, 110, "cream", 4) + s("M150 102C110 120 90 150 80 170", "brown", 3),
    "country": lambda: c(250, 54, 16, "orange") + p("M40 150C80 100 140 100 190 130C220 108 260 110 300 140V176H40Z", "green") + r(100, 118, 50, 40, "skin", 3) + p("M94 122L125 94L156 122Z", "teal")
        + r(118, 138, 14, 20, "brown", 2) + r(236, 116, 10, 44, "brown", 3) + c(241, 104, 18, "deepTeal") + ground(40, 300),
    "dance": lambda: P(130, 1.0, "teal", hair="brown") + woman(214, 1.0, "orange", "deepTeal") + ln(152, 88, 192, 76, "teal", 6) + note(70, 80) + note(266, 66) + ground(50, 290),
    "dancing": lambda: ln(170, 20, 170, 40, "ink", 3) + c(170, 62, 22, "greyShade") + "".join(ln(170 - 20, y, 170 + 20, y, "cream", 2.5) for y in (54, 62, 70)) + P(120, 0.85, "orange", hair="brown", base=176)
        + woman(220, 0.85, "teal", "orange") + note(262, 100),
    "dawn": lambda: c(170, 124, 42, "orange") + "".join(ln(170 + 54 * dx, 124 + 54 * dy, 170 + 74 * dx, 124 + 74 * dy, "orange", 5) for dx, dy in ((0, -1), (-0.7, -0.7), (0.7, -0.7), (-1, 0), (1, 0)))
        + r(40, 124, 260, 52, "green", 4) + ln(60, 150, 120, 150, "deepTeal", 4) + ln(200, 160, 270, 160, "deepTeal", 4),
    "day": lambda: c(130, 80, 34, "orange") + "".join(ln(130 + 44 * dx, 80 + 44 * dy, 130 + 58 * dx, 80 + 58 * dy, "orange", 5) for dx, dy in ((0, -1), (-1, 0), (1, 0), (0.7, -0.7), (-0.7, -0.7), (0, 1), (0.7, 0.7), (-0.7, 0.7)))
        + cloud(230, 66) + p("M40 176C100 130 200 130 300 176Z", "green") + ln(240, 176, 240, 150, "green", 4) + c(240, 144, 8, "earPink"),
    "dollar": lambda: banknote(80, 62, 180, 100, "green") + s("M180 96C170 88 156 94 160 104C164 114 182 108 180 120C178 130 162 132 158 124M170 86V138", "cream", 4),
    "dvd": lambda: r(84, 40, 100, 134, "deepTeal", 4) + r(94, 50, 80, 70, "orange", 3) + ln(100, 138, 168, 138, "cream", 3) + ln(100, 152, 150, 152, "cream", 3)
        + c(236, 112, 52, "grey") + ring(236, 112, 34, "greyShade", "none", 3) + c(236, 112, 12, "halo"),
    "east": lambda: compass(1, 0) + c(280, 60, 14, "orange"),
    "email": lambda: r(90, 70, 160, 96, "teal", 6) + s("M92 76L170 134L248 76", "cream", 4) + c(246, 62, 16, "skinShade") + s("M236 62H256M246 52V72", "cream", 3),
    "euro": lambda: banknote(80, 62, 180, 100, "teal") + s("M200 90C184 78 160 88 160 112C160 136 184 146 200 134M150 104H192M150 118H190", "cream", 5),
    "evening": lambda: c(170, 120, 46, "orange") + p("M40 176V146C100 126 240 126 300 146V176Z", "deepTeal") + p("M40 176V160C110 146 230 146 300 160V176Z", "teal") + star(70, 50, 8, 3, "orange") + star(260, 40, 6, 2.5, "orange")
        + star(150, 54, 7, 3, "orange") + star(236, 80, 5, 2, "orange"),
    "exam": lambda: r(100, 34, 140, 140, "cream", 4) + "".join(ln(116, y, 190, y, "grey", 3) + c(214, y, 6, "ink") for y in (60, 84, 108)) + s("M120 140L140 156L184 124", "green", 6) + ln(250, 60, 214, 150, "orange", 6),
    "exercise": lambda: ln(100, 102, 240, 102, "greyShade", 8) + r(86, 66, 20, 72, "ink", 4) + r(106, 78, 12, 48, "greyShade", 3) + r(234, 66, 20, 72, "ink", 4) + r(222, 78, 12, 48, "greyShade", 3) + ground(),
    "festival": lambda: s("M50 56C110 100 230 100 290 56", "brown", 3) + "".join(p(f"M{x} {y}L{x + 20} {y + 4}L{x + 8} {y + 28}Z", col) for x, y, col in
                                                                          ((70, 70, "orange"), (100, 82, "teal"), (136, 90, "green"), (170, 92, "skinShade"), (204, 90, "orange"), (238, 82, "teal")))
        + p("M90 176L150 112L210 176Z", "teal") + p("M200 176L250 120L300 176Z", "orange") + star(260, 40, 9, 4, "orange") + ground(50, 300),
    "film": lambda: r(70, 60, 200, 84, "ink", 4) + "".join(r(x, 66, 10, 8, "cream", 2) + r(x, 130, 10, 8, "cream", 2) for x in range(80, 260, 22))
        + r(84, 82, 52, 46, "teal", 2) + r(144, 82, 52, 46, "orange", 2) + r(204, 82, 52, 46, "green", 2),
    "game": lambda: r(88, 84, 164, 70, "greyShade", 30) + r(116, 98, 12, 40, "ink", 2) + r(102, 112, 40, 12, "ink", 2) + c(206, 108, 8, "orange") + c(228, 124, 8, "green") + c(184, 124, 8, "teal")
        + r(150, 100, 14, 8, "ink", 3) + r(172, 100, 14, 8, "ink", 3),
    "geography": lambda: ln(100, 160, 240, 160, "brown", 6) + s("M118 152C90 120 100 60 170 40", "ink", 4) + c(170, 98, 58, "teal") + p("M138 70C150 62 170 70 172 84C160 96 150 90 140 100C128 96 126 82 138 70Z", "green")
        + p("M180 104C196 98 210 110 206 130C196 144 184 138 180 124Z", "green") + ln(170, 156, 170, 164, "brown", 6),
    "gym": lambda: ln(80, 120, 260, 120, "greyShade", 8) + r(70, 88, 20, 64, "ink", 4) + r(90, 98, 12, 44, "greyShade", 3) + r(250, 88, 20, 64, "ink", 4) + r(238, 98, 12, 44, "greyShade", 3)
        + c(170, 150, 24, "ink") + s("M156 134C156 114 184 114 184 134", "ink", 6) + ground(),
    "holiday": lambda: BASE["beach"]() + r(250, 128, 44, 34, "orange", 5) + s("M262 128V118H282V128", "brown", 4) + c(60, 56, 18, "orange"),
    "homework": lambda: r(70, 130, 200, 10, "brown", 3) + r(80, 140, 10, 36, "brown", 2) + r(250, 140, 10, 36, "brown", 2) + r(100, 114, 80, 16, "teal", 3) + r(106, 98, 70, 16, "orange", 3)
        + r(190, 104, 50, 26, "cream", 3) + ln(198, 112, 232, 112, "grey", 3) + ln(198, 122, 224, 122, "grey", 3) + p("M250 126L232 70L246 66L262 122Z", "greyShade") + ground(60, 280),
    "hour": lambda: r(110, 32, 120, 10, "brown", 3) + r(110, 160, 120, 10, "brown", 3) + p("M122 42H218L184 100L218 160H122L156 100Z", "cream") + p("M138 50H202L176 94H164Z", "orange")
        + p("M170 108L172 150H168Z", "orange") + p("M136 160L170 128L204 160Z", "orange"),
    "internet": lambda: r(70, 44, 200, 126, "cream", 6) + r(70, 44, 200, 22, "greyShade", 6) + c(86, 55, 4, "cream") + c(100, 55, 4, "cream") + c(114, 55, 4, "cream") + r(132, 49, 120, 12, "cream", 5)
        + c(120, 116, 36, "teal") + s("M84 116H156M120 80V152", "cream", 3) + s("M104 88C118 106 118 126 104 144", "cream", 3) + "".join(ln(176, y, 250, y, "grey", 3) for y in (92, 108, 124, 140)) + r(176, 148, 40, 10, "orange", 4),
    "interview": lambda: P(96, 1.0, "teal", hair="brown") + woman(244, 1.0, "orange", "deepTeal") + r(130, 126, 80, 8, "brown", 3) + r(140, 134, 8, 42, "brown", 2) + r(192, 134, 8, 42, "brown", 2)
        + r(150, 116, 40, 10, "cream", 2) + ground(50, 290),
    "kidney": lambda: p("M120 70C150 40 230 50 232 100C234 150 190 170 160 160C140 154 150 130 160 120C170 108 150 96 130 106C110 116 100 90 120 70Z", "skinShade")
        + s("M150 114C130 130 120 150 126 170", "earPink", 6) + s("M162 108C150 90 156 60 170 44", "teal", 5),
    "laugh": lambda: c(170, 100, 62, "orange") + s("M130 82C138 72 148 72 154 82", "ink", 4) + s("M186 82C192 72 202 72 210 82", "ink", 4) + p("M126 108C130 150 210 150 214 108Z", "ink") + e(170, 134, 20, 10, "earPink")
        + r(138, 108, 64, 8, "cream", 3) + ln(124, 100, 116, 120, "teal", 4) + ln(216, 100, 224, 120, "teal", 4),
    "lesson": lambda: r(70, 36, 200, 100, "brown", 5) + r(78, 44, 184, 84, "deepTeal", 3) + c(116, 84, 18, "cream") + r(148, 66, 36, 36, "cream", 2) + p("M214 66L236 104H192Z", "cream")
        + ln(74, 150, 266, 150, "brown", 5) + ln(260, 160, 220, 126, "orange", 5),
    "light": lambda: c(170, 90, 40, "orange") + r(150, 124, 40, 22, "grey", 4) + r(154, 146, 32, 14, "greyShade", 4) + r(160, 158, 20, 6, "ink", 3) + s("M154 110L164 86L170 104L176 86L186 110", "ink", 3)
        + "".join(ln(170 + 52 * dx, 90 + 52 * dy, 170 + 66 * dx, 90 + 66 * dy, "orange", 5) for dx, dy in ((0, -1), (-1, 0), (1, 0), (0.7, -0.7), (-0.7, -0.7))),
    "love": lambda: heart(170, 100, 52, "skinShade") + heart(100, 60, 14, "orange") + heart(250, 56, 12, "orange") + heart(250, 140, 10, "skinShade") + heart(90, 144, 10, "earPink"),
    "machine": lambda: r(60, 160, 220, 14, "ink", 4) + c(80, 167, 7, "grey") + c(130, 167, 7, "grey") + c(180, 167, 7, "grey") + c(230, 167, 7, "grey") + r(120, 70, 100, 70, "teal", 8)
        + gear(170, 72, 28, 8, "orange") + r(230, 130, 30, 30, "skin", 3) + r(60, 134, 30, 26, "skin", 3) + ln(220, 100, 262, 80, "greyShade", 6),
    "magazine": lambda: r(110, 36, 120, 140, "orange", 4) + r(120, 46, 100, 20, "ink", 2) + c(170, 108, 30, "cream") + c(170, 108, 14, "teal") + ln(122, 150, 218, 150, "cream", 3) + ln(122, 162, 190, 162, "cream", 3),
    "map": lambda: r(80, 46, 180, 120, "cream", 4) + ln(140, 46, 140, 166, "grey", 3) + ln(200, 46, 200, 166, "grey", 3) + p("M88 130C110 110 130 120 132 100V54H88Z", "green")
        + p("M204 160V130C226 120 240 130 252 120V160Z", "teal") + s("M150 140C160 110 190 120 196 90", "brown", 3) + p("M214 56C226 56 232 66 224 78L214 92L204 78C196 66 202 56 214 56Z", "skinShade") + c(214, 68, 4, "cream"),
    "match": lambda: r(60, 46, 220, 130, "green", 6) + ln(170, 56, 170, 166, "cream", 3) + ring(170, 111, 24, "cream", "none", 3)
        + r(70, 90, 30, 44, "green", 2) + s("M70 90H100V134H70", "cream", 3) + s("M270 90H240V134H270", "cream", 3) + c(190, 130, 11, "cream") + c(190, 130, 4, "ink"),
    "meeting": lambda: e(170, 130, 100, 30, "brown") + "".join(c(x, y, 14, "skin") + e(x, y - 9, 15, 8, hc) + r(x - 18, y + 14, 36, 22, col, 8)
                                                           for x, y, hc, col in ((96, 76, "ink", "teal"), (170, 62, "brown", "orange"), (244, 76, "ink", "green")))
        + r(130, 116, 36, 8, "cream", 2) + r(180, 114, 30, 10, "greyShade", 2) + c(206, 120, 6, "cream"),
    "message": lambda: e(170, 92, 84, 52, "teal") + p("M112 126L96 160L146 134Z", "teal") + "".join(c(x, 92, 7, "cream") for x in (140, 170, 200)),
    "midnight": lambda: ring(150, 104, 56, "brown", "cream", 6) + ln(150, 104, 150, 62, "ink", 5) + ln(150, 104, 150, 70, "ink", 4) + c(150, 104, 5, "ink") + c(256, 60, 24, "cream") + c(266, 54, 20, "halo")
        + star(252, 130, 8, 3, "orange") + star(80, 50, 7, 3, "orange"),
    "minute": lambda: r(158, 40, 24, 12, "greyShade", 3) + ring(170, 108, 54, "greyShade", "cream", 8) + ln(170, 108, 170, 72, "ink", 4) + ln(170, 108, 196, 118, "orange", 4) + c(170, 108, 5, "ink")
        + ln(170, 62, 170, 70, "ink", 3) + ln(170, 146, 170, 154, "ink", 3) + ln(116, 108, 124, 108, "ink", 3) + ln(216, 108, 224, 108, "ink", 3),
    "money": lambda: banknote(76, 90, 150, 76, "green") + banknote(100, 60, 150, 76, "teal") + e(260, 160, 24, 8, "orange") + r(236, 148, 48, 12, "orange") + e(260, 148, 24, 8, "skin") + e(260, 136, 24, 8, "orange"),
    "month": lambda: r(100, 44, 140, 124, "cream", 6) + r(100, 44, 140, 26, "skinShade", 6) + c(130, 44, 5, "ink") + c(210, 44, 5, "ink") + "".join(r(112 + i * 28, 82 + j * 24, 20, 16, "grey" if (i, j) != (3, 1) else "orange", 3) for i in range(4) for j in range(3)),
    "morning": lambda: BASE["coffee"]() + c(262, 52, 20, "orange") + "".join(ln(262 + 28 * dx, 52 + 28 * dy, 262 + 38 * dx, 52 + 38 * dy, "orange", 4) for dx, dy in ((-1, 0), (0, 1), (-0.7, 0.7), (0.7, 0.7))),
    "movie": lambda: r(110, 84, 120, 84, "ink", 4) + r(110, 58, 120, 22, "ink", 3) + p("M116 60L140 60L128 80L116 80Z", "cream") + p("M148 60L172 60L160 80L136 80Z", "cream") + p("M180 60L204 60L192 80L168 80Z", "cream")
        + p("M212 60L228 60L228 80L200 80Z", "cream") + ln(124, 112, 170, 112, "cream", 3) + ln(124, 128, 156, 128, "cream", 3) + p("M178 108L204 124L178 140Z", "orange"),
    "museum": lambda: r(80, 50, 90, 70, "brown", 3) + r(88, 58, 74, 54, "cream", 2) + p("M88 112C100 90 120 100 130 86C140 80 150 96 162 112Z", "green") + c(146, 74, 7, "orange")
        + r(200, 140, 50, 34, "grey", 3) + p("M206 140C200 110 214 98 225 98C236 98 250 110 244 140Z", "teal") + r(216, 88, 18, 12, "teal", 3) + ground(60, 280),
    "music": lambda: "".join(ln(70, y, 270, y, "grey", 3) for y in (60, 78, 96, 114, 132)) + c(120, 138, 14, "ink") + ln(133, 138, 133, 64, "ink", 4) + c(190, 120, 14, "ink") + ln(203, 120, 203, 50, "ink", 4)
        + p("M133 64L203 50V68L133 82Z", "ink") + c(250, 100, 10, "orange"),
    "news": lambda: tv(90, 50, 160, 106, "brown", "teal") + c(170, 86, 14, "skin") + e(170, 78, 15, 8, "ink") + r(150, 100, 40, 24, "orange", 6) + r(98, 132, 144, 12, "orange", 2)
        + ln(110, 138, 200, 138, "cream", 3) + ln(150, 156, 130, 172, "brown", 5) + ln(190, 156, 210, 172, "brown", 5),
    "newspaper": lambda: r(84, 56, 172, 112, "cream", 3) + ln(170, 56, 170, 168, "grey", 3) + r(96, 68, 66, 14, "ink", 2) + r(180, 68, 66, 14, "ink", 2) + r(96, 92, 66, 36, "grey", 2)
        + "".join(ln(96, y, 160, y, "grey", 3) for y in (138, 150, 160)) + "".join(ln(180, y, 244, y, "grey", 3) for y in (96, 108, 120, 132, 144, 156)),
    "night": lambda: c(250, 56, 24, "cream") + c(260, 50, 20, "halo") + star(90, 50, 8, 3, "orange") + star(180, 40, 6, 2.5, "orange") + star(290, 110, 6, 2.5, "orange")
        + r(110, 110, 100, 66, "deepTeal", 3) + p("M100 114L160 70L220 114Z", "ink") + r(124, 126, 24, 24, "orange", 2) + r(168, 126, 24, 24, "orange", 2) + r(154, 150, 14, 26, "ink", 2) + ground(60, 280),
    "north": lambda: compass(0, -1),
    "note": lambda: r(110, 50, 120, 118, "orange", 4) + p("M200 168L230 138V168Z", "skinShade") + "".join(ln(126, y, 214, y, "skinShade", 3) for y in (78, 96, 114, 132)) + c(170, 56, 7, "teal"),
    "page": lambda: p("M170 60C150 50 120 52 96 60V164C120 156 150 154 170 164Z", "cream") + p("M170 60C190 50 220 52 244 60V164C220 156 190 154 170 164Z", "cream")
        + "".join(ln(110, y, 156, y, "grey", 3) + ln(184, y, 230, y, "grey", 3) for y in (82, 98, 114, 130)) + r(206, 56, 10, 52, "orange", 2),
    "paint": lambda: r(120, 96, 100, 72, "grey", 6) + e(170, 96, 50, 10, "greyShade") + p("M124 96C124 112 134 114 134 100ZM150 96V118C150 128 162 128 162 118V96ZM190 96C190 108 198 108 200 96Z", "teal")
        + r(120, 110, 100, 22, "teal") + ln(60, 160, 100, 130, "brown", 5) + r(236, 60, 14, 50, "brown", 3) + r(226, 44, 34, 20, "orange", 3) + ground(),
    "painting": lambda: r(80, 36, 180, 122, "brown", 5) + r(94, 50, 152, 94, "cream", 3) + p("M94 144C120 100 150 110 170 124C190 100 220 100 246 144Z", "green") + c(210, 76, 12, "orange")
        + ln(170, 36, 170, 22, "ink", 3) + ground(60, 280),
    "pair": lambda: p("M104 50H144V128L178 148C190 158 180 176 164 172L116 156C102 150 104 130 104 130Z", "teal") + r(102, 44, 44, 14, "orange", 3)
        + p("M184 50H224V128L258 148C270 158 260 176 244 172L196 156C182 150 184 130 184 130Z", "deepTeal") + r(182, 44, 44, 14, "orange", 3),
    "park": lambda: p("M40 176C90 150 250 150 300 176Z", "green") + r(86, 92, 10, 68, "brown", 3) + c(91, 76, 34, "green") + c(70, 100, 22, "green") + r(176, 130, 90, 8, "brown", 3)
        + r(184, 138, 8, 20, "brown", 2) + r(250, 138, 8, 20, "brown", 2) + r(176, 112, 90, 8, "brown", 3) + ln(284, 160, 284, 80, "ink", 4) + c(284, 74, 7, "orange"),
    "party": lambda: p("M130 164L170 56L210 164Z", "orange") + p("M146 128L194 128L200 146L140 146Z", "teal") + c(170, 50, 8, "cream") + e(88, 70, 16, 21, "teal") + ln(88, 91, 100, 150, "grey", 3)
        + e(256, 76, 16, 21, "green") + ln(256, 97, 244, 150, "grey", 3) + r(70, 130, 8, 4, "orange") + r(268, 130, 8, 4, "teal") + star(110, 36, 7, 3, "orange") + ground(),
    "phone": lambda: r(130, 34, 80, 138, "ink", 14) + r(138, 50, 64, 100, "teal", 4) + "".join(r(144 + i * 20, 60 + j * 20, 14, 14, "cream" if (i + j) % 2 else "orange", 3) for i in range(3) for j in range(3)) + c(170, 160, 5, "grey"),
    "photo": lambda: r(100, 40, 140, 134, "cream", 4) + r(112, 52, 116, 90, "teal", 2) + p("M112 142C130 104 150 112 166 124C180 100 206 100 228 142Z", "green") + c(204, 76, 10, "orange"),
    "photograph": lambda: p("M96 66L196 48L216 150L116 166Z", "cream") + p("M108 74L186 60L202 134L124 148Z", "teal") + p("M124 148L146 110L170 130L184 104L202 134Z", "green")
        + r(190, 70, 56, 50, "cream", 3) + r(196, 76, 44, 38, "orange", 2) + c(236, 154, 10, "cream"),
    "piano": lambda: r(80, 70, 180, 40, "ink", 6) + r(80, 104, 180, 62, "cream", 3) + "".join(ln(x, 104, x, 166, "grey", 3) for x in range(104, 260, 24)) + "".join(r(x, 104, 14, 38, "ink", 2) for x in (96, 120, 168, 192, 216, 240)) + ground(70, 270),
    "picture": lambda: s("M170 28L120 54M170 28L220 54", "ink", 3) + r(100, 54, 140, 112, "brown", 5) + r(112, 66, 116, 88, "cream", 3) + p("M112 154C130 116 150 122 166 136C184 114 206 116 228 154Z", "green") + c(204, 90, 10, "orange") + c(170, 28, 4, "ink"),
    "pool": lambda: r(50, 80, 240, 96, "cream", 8) + r(62, 92, 216, 72, "teal", 4) + "".join(s(f"M{70 + i * 48} 118C{80 + i * 48} 110 {90 + i * 48} 126 {100 + i * 48} 118", "cream", 3) for i in range(4))
        + s("M236 92V64C236 48 256 48 256 64V92", "grey", 4) + s("M222 92V64C222 48 242 48 242 64V92", "grey", 4) + c(120, 142, 12, "orange") + ln(62, 150, 278, 150, "cream", 3),
    "post": lambda: r(158, 124, 24, 52, "brown", 3) + r(124, 56, 92, 74, "skinShade", 10) + e(170, 58, 46, 12, "skinShade") + r(142, 80, 56, 8, "ink", 3) + r(146, 96, 48, 14, "cream", 2) + ground(),
    "pound": lambda: c(170, 102, 62, "orange") + ring(170, 102, 50, "skinShade", "none", 4) + s("M192 80C180 66 156 72 156 96V122M142 122H196M142 104H180", "skinShade", 6),
    "radio": lambda: ln(210, 76, 250, 36, "grey", 3) + r(90, 76, 160, 90, "brown", 10) + c(140, 122, 32, "ink") + c(140, 122, 24, "greyShade") + "".join(ln(124, y, 156, y, "ink", 3) for y in (112, 122, 132))
        + r(188, 92, 48, 16, "cream", 3) + c(202, 138, 10, "orange") + c(228, 138, 10, "cream") + ground(),
    "radar": lambda: c(170, 102, 66, "deepTeal") + ring(170, 102, 44, "green", "none", 3) + ring(170, 102, 22, "green", "none", 3) + ln(104, 102, 236, 102, "green", 3) + ln(170, 36, 170, 168, "green", 3)
        + p("M170 102L216 62L232 80Z", "green") + c(200, 124, 5, "orange") + c(138, 78, 5, "orange"),
    "science": lambda: p("M130 60H160V96L186 150H104L130 96Z", "teal") + r(124, 52, 42, 10, "cream", 3) + p("M118 130L172 130L186 150H104Z", "deepTeal") + c(138, 116, 4, "cream")
        + c(214, 98, 8, "orange") + s("M178 98C178 70 250 70 250 98C250 126 178 126 178 98Z", "deepTeal", 3) + s("M200 66C226 80 226 118 200 132", "deepTeal", 3) + ground(80, 270),
    "shopping": lambda: r(100, 72, 70, 94, "orange", 4) + s("M120 72V58C120 44 150 44 150 58V72", "brown", 4) + r(160, 92, 70, 76, "teal", 4) + s("M180 92V78C180 66 210 66 210 78V92", "brown", 4)
        + r(236, 116, 40, 50, "green", 4) + star(135, 118, 12, 5, "cream") + ground(70, 290),
    "show": lambda: curtains("skinShade", "deepTeal") + star(170, 100, 34, 15, "orange"),
    "song": lambda: c(150, 140, 22, "ink") + ln(172, 140, 172, 50, "ink", 6) + s("M172 50C192 56 208 74 204 100", "ink", 6) + heart(250, 70, 12, "skinShade") + note(86, 90) + s("M210 130C226 134 238 144 240 160", "orange", 4),
    "sound": lambda: r(100, 66, 50, 70, "grey", 6) + p("M150 66L204 36V166L150 136Z", "greyShade") + s("M226 78C246 96 246 106 226 124", "orange", 5) + s("M244 62C276 90 276 114 244 142", "orange", 5),
    "south": lambda: compass(0, 1),
    "sport": lambda: c(110, 124, 36, "orange") + s("M74 124H146M110 88V160", "ink", 3) + c(206, 142, 18, "green") + s("M190 134C200 144 212 144 222 134", "cream", 3) + c(244, 118, 28, "cream") + s("M244 90V146M216 118H272", "ink", 3) + ground(60, 290),
    "story": lambda: p("M170 90C150 80 114 82 90 92V164C114 154 150 154 170 164Z", "cream") + p("M170 90C190 80 226 82 250 92V164C226 154 190 154 170 164Z", "cream")
        + r(142, 44, 56, 46, "skin", 2) + p("M136 48L170 22L204 48Z", "teal") + r(160, 66, 20, 24, "brown", 2) + star(236, 44, 9, 4, "orange") + star(104, 54, 7, 3, "orange"),
    "swimming": lambda: r(50, 110, 240, 66, "teal", 6) + c(150, 100, 15, "skin") + e(150, 90, 16, 8, "ink") + ln(130, 104, 90, 80, "skin", 8) + ln(165, 110, 215, 90, "skin", 8) + ring(150, 100, 6, "ink", "none", 3)
        + "".join(s(f"M{60 + i * 56} 130C{72 + i * 56} 122 {84 + i * 56} 138 {96 + i * 56} 130", "cream", 3) for i in range(4)) + c(240, 92, 4, "cream") + c(254, 78, 3, "cream"),
    "telephone": lambda: r(100, 110, 140, 56, "ink", 12) + r(130, 80, 80, 36, "ink", 10) + ring(170, 142, 18, "cream", "none", 4) + p("M96 90C96 64 126 64 140 74H200C214 64 244 64 244 90C244 100 232 100 226 94H114C108 100 96 100 96 90Z", "orange"),
    "television": lambda: ln(150, 54, 130, 30, "grey", 3) + ln(190, 54, 210, 30, "grey", 3) + r(90, 54, 160, 102, "brown", 10) + r(100, 64, 108, 82, "teal", 6) + c(228, 84, 8, "cream") + c(228, 112, 8, "cream")
        + r(120, 156, 10, 18, "brown", 2) + r(210, 156, 10, 18, "brown", 2) + ground(),
    "tennis": lambda: ln(170, 120, 200, 168, "brown", 10) + ring(150, 86, 44, "ink", "none", 6) + ln(116, 70, 184, 102, "cream", 2.5) + ln(112, 86, 188, 86, "cream", 2.5) + ln(116, 102, 184, 70, "cream", 2.5) + ln(150, 44, 150, 128, "cream", 2.5)
        + c(246, 138, 20, "green") + s("M230 130C240 142 252 142 262 130", "cream", 3) + ground(),
    "theatre": lambda: c(130, 100, 44, "cream") + c(116, 90, 5, "ink") + c(144, 90, 5, "ink") + s("M112 118C124 132 138 132 148 118", "ink", 4) + c(212, 112, 44, "orange") + c(198, 102, 5, "ink") + c(226, 102, 5, "ink")
        + s("M196 138C208 126 222 126 232 138", "ink", 4) + ln(110, 48, 122, 60, "brown", 3),
    "tv": lambda: r(70, 52, 200, 108, "ink", 8) + r(78, 60, 184, 92, "teal", 3) + p("M152 84L192 106L152 128Z", "cream") + r(140, 160, 60, 8, "greyShade", 2) + r(120, 166, 100, 8, "grey", 3) + ground(),
    "university": lambda: p("M60 90L170 40L280 90Z", "deepTeal") + r(66, 90, 208, 10, "cream", 2) + "".join(r(x, 100, 18, 56, "cream", 3) for x in (82, 122, 152, 188, 228, 250))
        + r(56, 156, 228, 10, "grey", 2) + r(46, 166, 248, 12, "greyShade", 2) + ln(170, 40, 170, 24, "brown", 3) + p("M170 24L192 30L170 36Z", "orange"),
    "video": lambda: r(80, 50, 180, 100, "ink", 12) + r(90, 60, 160, 80, "teal", 6) + c(170, 100, 24, "cream") + p("M162 88L186 100L162 112Z", "orange") + ln(96, 160, 244, 160, "grey", 4) + ln(96, 160, 160, 160, "orange", 4),
}


if __name__ == "__main__":
    write(WORDS)
