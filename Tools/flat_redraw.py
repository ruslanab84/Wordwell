#!/usr/bin/env python3
"""Flat colour word illustrations (340x200 card, design.md §4). Writes only the listed word_<lemma>_plate.svg files.

Run: python3 Tools/flat_redraw.py && python3 Tools/svg-lint/svg_lint.py <Words.xcassets> && python3 Tools/validate_svg_assets.py
Migrating a word also sets its binding style to "flat_color" (done here).
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets"
BINDINGS = ROOT / "Packages/WordwellKit/Sources/WordwellData/Resources/IllustrationsSVG/illustration_bindings.json"
PALETTE = json.loads((ROOT / "Tools/svg-lint/palette.json").read_text())

FRAME = ('<rect x="1" y="1" width="338" height="198" rx="12" fill="#EDD9AE" stroke="#BD9F66" stroke-width="2"/>'
         '<rect x="12" y="12" width="316" height="176" rx="5" fill="none" stroke="#BD9F66" stroke-width="1.2"/>'
         '<circle cx="170" cy="102" r="70" fill="#E8C486"/>')


def col(name):
    return PALETTE[name]


def n(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def r(x, y, w, h, c, rx=0):
    return f'<rect x="{n(x)}" y="{n(y)}" width="{n(w)}" height="{n(h)}"' + (f' rx="{n(rx)}"' if rx else "") + f' fill="{col(c)}"/>'


def c(cx, cy, rad, fill):
    return f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(rad)}" fill="{col(fill)}"/>'


def e(cx, cy, rx, ry, fill, rot=0):
    t = f' transform="rotate({rot} {n(cx)} {n(cy)})"' if rot else ""
    return f'<ellipse cx="{n(cx)}" cy="{n(cy)}" rx="{n(rx)}" ry="{n(ry)}" fill="{col(fill)}"{t}/>'


def p(d, fill):
    return f'<path d="{d}" fill="{col(fill)}"/>'


def s(d, stroke, w=4):
    """Stroked open path (limb, handle, detail)."""
    return f'<path d="{d}" fill="none" stroke="{col(stroke)}" stroke-width="{w}" stroke-linecap="round"/>'


def ln(x1, y1, x2, y2, stroke, w=4):
    return f'<line x1="{n(x1)}" y1="{n(y1)}" x2="{n(x2)}" y2="{n(y2)}" stroke="{col(stroke)}" stroke-width="{w}" stroke-linecap="round"/>'


def ring(cx, cy, rad, stroke, fill="none", w=4):
    f = col(fill) if fill != "none" else "none"
    return f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(rad)}" fill="{f}" stroke="{col(stroke)}" stroke-width="{w}" stroke-linecap="round"/>'


def ground(x1=70, x2=270):
    return ln(x1, 180, x2, 180, "brown")


def eye(x, y):
    return c(x, y, 2.5, "ink")


def wheel(cx, cy, rad=17):
    return c(cx, cy, rad, "ink") + c(cx, cy, rad * 0.45, "grey")


WORDS = {
    "apple": lambda: c(154, 112, 36, "green") + c(186, 112, 36, "green") + r(154, 80, 32, 30, "green")
        + ln(170, 76, 174, 52, "brown", 5) + e(192, 58, 16, 7, "teal", -25) + e(146, 100, 6, 12, "cream", 20) + ground(110, 230),
    "bag": lambda: s("M146 76C146 40 194 40 194 76", "brown", 5) + r(120, 72, 100, 98, "orange", 6)
        + r(120, 104, 100, 12, "cream") + ground(),
    "ball": lambda: c(170, 102, 56, "orange") + s("M114 102H226", "ink", 3) + s("M170 46V158", "ink", 3)
        + s("M132 62C152 84 152 120 132 142", "ink", 3) + s("M208 62C188 84 188 120 208 142", "ink", 3),
    "banana": lambda: p("M104 70C96 138 170 176 242 130C246 124 238 120 232 124C176 152 130 130 128 70Z", "orange")
        + ln(104, 66, 110, 56, "brown", 6) + ln(238, 126, 246, 130, "brown", 6),
    "bed": lambda: r(84, 82, 14, 88, "brown", 3) + r(242, 120, 12, 50, "brown", 3) + r(90, 118, 158, 28, "teal", 4)
        + r(138, 108, 110, 38, "deepTeal", 4) + r(98, 102, 46, 20, "cream", 8) + ground(),
    "bicycle": lambda: ring(108, 128, 36, "ink") + ring(232, 128, 36, "ink")
        + s("M108 128L148 86H196L232 128", "teal", 5) + s("M148 86L168 128H108", "teal", 5) + s("M168 128L196 86", "teal", 5)
        + s("M208 86L220 68H236", "ink", 5) + r(136, 76, 26, 8, "ink", 3) + c(108, 128, 5, "grey") + c(232, 128, 5, "grey") + c(168, 128, 6, "orange"),
    "bird": lambda: s("M76 150H264", "brown", 5) + ln(160, 130, 160, 150, "orange") + ln(184, 130, 184, 150, "orange")
        + p("M210 96L262 74L250 112Z", "deepTeal") + e(174, 104, 50, 34, "teal") + e(164, 116, 30, 18, "orange")
        + e(184, 96, 26, 13, "deepTeal", -15) + c(130, 78, 22, "teal") + p("M112 72L86 82L112 88Z", "ink") + eye(124, 74),
    "boat": lambda: p("M84 122H256L230 154H110Z", "brown") + ln(168, 44, 168, 122, "brown", 5) + p("M162 52V114H112Z", "cream")
        + p("M176 64L226 114H176Z", "orange") + r(84, 122, 172, 8, "deepTeal", 2) + ground(),
    "book": lambda: r(118, 58, 104, 112, "teal", 6) + r(118, 58, 16, 112, "deepTeal", 4) + r(148, 82, 58, 34, "cream", 3)
        + ln(156, 94, 198, 94, "ink", 3) + ln(156, 104, 186, 104, "ink", 3) + ground(),
    "boot": lambda: p("M130 48H182V108L228 120C244 124 246 152 230 152H130Z", "brown") + r(126, 146, 120, 14, "ink", 4)
        + r(130, 48, 52, 12, "cream", 2) + ground(),
    "bottle": lambda: r(146, 86, 48, 84, "teal", 10) + r(158, 52, 24, 40, "teal", 4) + r(156, 42, 28, 12, "orange", 3)
        + r(146, 114, 48, 32, "cream") + ln(158, 130, 182, 130, "ink", 3) + ground(),
    "box": lambda: r(112, 86, 116, 74, "skin", 3) + r(106, 72, 128, 20, "skinShade", 3) + r(160, 72, 20, 88, "cream") + ground(),
    "bread": lambda: r(96, 90, 148, 66, "skin", 30) + ln(132, 98, 144, 122, "skinShade") + ln(166, 98, 178, 122, "skinShade")
        + ln(200, 98, 212, 122, "skinShade") + ground(),
    "bus": lambda: r(80, 66, 180, 84, "teal", 12) + r(80, 120, 180, 10, "orange") + r(94, 80, 34, 28, "cream", 3)
        + r(136, 80, 34, 28, "cream", 3) + r(178, 80, 34, 28, "cream", 3) + r(220, 80, 28, 40, "cream", 3)
        + wheel(124, 152) + wheel(216, 152) + ground(),
    "cake": lambda: e(170, 158, 76, 12, "grey") + r(110, 106, 120, 50, "skin", 6) + r(106, 92, 128, 22, "cream", 10)
        + r(166, 62, 8, 32, "teal", 2) + e(170, 54, 6, 10, "orange") + c(132, 104, 5, "orange") + c(208, 104, 5, "orange") + c(170, 108, 5, "orange"),
    "camera": lambda: r(98, 78, 144, 82, "grey", 10) + r(128, 64, 52, 18, "greyShade", 4) + c(170, 120, 30, "ink")
        + c(170, 120, 19, "greyShade") + c(162, 112, 5, "cream") + r(208, 88, 18, 10, "orange", 2) + ground(),
    "car": lambda: p("M84 130V112L118 104L138 76H202L226 104L256 112V130Z", "teal") + p("M146 84H170V104H132Z", "cream")
        + p("M178 84H198L214 104H178Z", "cream") + r(84, 124, 172, 10, "deepTeal", 3) + wheel(122, 136) + wheel(218, 136) + ground(),
    "carrot": lambda: p("M92 150L210 88C224 82 238 100 228 114Z", "orange") + e(222, 76, 6, 18, "green", 35)
        + e(236, 88, 6, 18, "green", 75) + e(212, 72, 6, 16, "green", -5) + ln(150, 124, 164, 130, "skinShade", 3)
        + ln(176, 112, 188, 118, "skinShade", 3),
    "cat": lambda: s("M206 158C252 158 256 118 240 106", "greyShade", 9) + e(170, 130, 40, 34, "grey") + c(170, 80, 30, "grey")
        + p("M144 62L148 38L166 54Z", "greyShade") + p("M196 62L192 38L174 54Z", "greyShade")
        + eye(158, 78) + eye(182, 78) + p("M166 88H174L170 93Z", "earPink") + ground(100, 240),
    "chair": lambda: r(128, 46, 12, 76, "brown", 3) + r(128, 108, 88, 14, "brown", 3) + r(124, 100, 94, 14, "teal", 5)
        + r(130, 120, 10, 50, "brown", 3) + r(200, 120, 10, 50, "brown", 3) + r(146, 54, 50, 8, "brown", 2) + ground(),
    "cheese": lambda: p("M94 142H246V108L94 78Z", "orange") + c(132, 122, 7, "skinShade") + c(186, 128, 9, "skinShade")
        + c(216, 116, 5, "skinShade") + ground(),
    "chicken": lambda: ln(164, 136, 164, 168, "orange") + ln(188, 136, 188, 168, "orange") + p("M208 96L258 66L250 118Z", "greyShade")
        + e(176, 108, 46, 36, "cream") + e(186, 104, 24, 14, "greyShade", -15) + c(128, 78, 21, "cream")
        + p("M118 60L124 48L132 58L138 48L142 62Z", "orange") + p("M108 76L88 82L108 90Z", "orange") + eye(122, 74) + ground(),
    "clock": lambda: ring(170, 102, 58, "brown", "cream", 6) + ln(170, 102, 170, 64, "ink") + ln(170, 102, 198, 116, "ink")
        + c(170, 102, 5, "ink") + c(170, 58, 3, "ink") + c(170, 146, 3, "ink") + c(126, 102, 3, "ink") + c(214, 102, 3, "ink"),
    "coat": lambda: p("M128 54L152 48L170 64L188 48L212 54L238 92L218 108L212 92V166H128V92L122 108L102 92Z", "teal")
        + p("M152 48L170 64L188 48L170 92Z", "deepTeal") + ln(170, 92, 170, 166, "deepTeal", 3)
        + c(158, 112, 4, "orange") + c(158, 134, 4, "orange") + c(158, 156, 4, "orange"),
    "coffee": lambda: e(170, 158, 78, 11, "greyShade") + p("M116 90H224V118C224 146 200 160 170 160C140 160 116 146 116 118Z", "cream")
        + s("M224 102C256 100 256 140 220 140", "cream", 8) + e(170, 90, 54, 9, "brown")
        + s("M150 70C142 58 158 52 150 40", "grey", 3) + s("M176 70C168 58 184 52 176 40", "grey", 3),
    "computer": lambda: r(100, 58, 140, 98, "greyShade", 8) + r(110, 68, 120, 74, "teal", 3) + ln(124, 84, 168, 84, "cream", 3)
        + ln(124, 96, 150, 96, "cream", 3) + r(160, 154, 20, 14, "grey") + r(136, 166, 68, 10, "grey", 3),
    "cow": lambda: r(112, 82, 122, 58, "cream", 24) + e(150, 104, 14, 10, "ink") + e(204, 120, 16, 10, "ink")
        + r(122, 134, 12, 38, "cream", 3) + r(150, 134, 12, 38, "cream", 3) + r(196, 134, 12, 38, "cream", 3) + r(216, 134, 12, 38, "cream", 3)
        + r(122, 166, 12, 6, "ink") + r(150, 166, 12, 6, "ink") + r(196, 166, 12, 6, "ink") + r(216, 166, 12, 6, "ink")
        + s("M234 96C250 104 250 130 244 146", "ink", 4) + r(72, 76, 48, 48, "cream", 14) + r(72, 104, 34, 22, "earPink", 8)
        + p("M88 76L84 60L98 72Z", "orange") + p("M112 76L118 60L122 76Z", "orange") + e(122, 84, 10, 5, "greyShade", 20) + eye(92, 92) + ground(),
    "cup": lambda: r(124, 76, 92, 84, "teal", 12) + s("M216 96C254 94 254 140 214 140", "teal", 9) + e(170, 78, 46, 7, "deepTeal")
        + r(124, 112, 92, 14, "cream") + ground(100, 240),
    "desk": lambda: r(84, 94, 172, 14, "brown", 3) + r(92, 108, 12, 62, "brown", 3) + r(192, 108, 56, 54, "skinShade", 3)
        + c(220, 124, 4, "orange") + c(220, 146, 4, "orange") + r(116, 82, 40, 12, "teal", 2) + r(122, 74, 30, 8, "orange", 2) + ground(),
    "dictionary": lambda: r(110, 50, 120, 120, "brown", 6) + r(110, 50, 16, 120, "deepTeal", 4) + r(140, 76, 66, 36, "cream", 3)
        + ln(150, 90, 196, 90, "ink", 3) + ln(150, 100, 182, 100, "ink", 3) + r(126, 164, 100, 8, "cream") + ground(),
    "doctor": lambda: r(134, 92, 72, 80, "cream", 12) + c(170, 66, 20, "skin") + e(170, 56, 21, 11, "ink")
        + s("M154 94C154 132 186 132 186 94", "ink", 4) + r(166, 122, 8, 20, "teal") + r(160, 128, 20, 8, "teal")
        + r(150, 92, 12, 14, "skin") + ground(),
    "dog": lambda: s("M216 106C240 94 246 82 240 70", "skin", 9) + r(116, 94, 102, 48, "skin", 20) + c(104, 86, 26, "skin")
        + e(124, 80, 9, 18, "skinShade", 15) + e(86, 94, 13, 10, "skinShade") + c(76, 92, 4, "ink") + eye(100, 82)
        + r(124, 136, 12, 36, "skin", 4) + r(198, 136, 12, 36, "skin", 4) + ground(),
    "door": lambda: r(116, 42, 108, 132, "brown", 4) + r(126, 52, 88, 122, "teal", 2) + r(138, 66, 28, 46, "deepTeal", 2)
        + r(174, 66, 28, 46, "deepTeal", 2) + c(200, 124, 6, "orange") + ground(),
    "egg": lambda: e(170, 138, 82, 14, "grey") + e(170, 118, 66, 36, "cream") + c(170, 112, 24, "orange") + e(162, 104, 6, 4, "cream"),
    "fish": lambda: p("M208 100L256 68V132Z", "deepTeal") + e(158, 100, 56, 34, "teal") + e(158, 114, 40, 18, "cream")
        + p("M140 68L170 60L176 76Z", "deepTeal") + c(122, 92, 7, "cream") + eye(120, 92) + s("M190 86C196 96 196 106 190 116", "deepTeal", 3),
    "flower": lambda: ln(170, 92, 170, 172, "green", 6) + e(146, 138, 22, 8, "green", -30) + e(194, 126, 22, 8, "green", 30)
        + e(170, 54, 14, 22, "cream") + e(170, 118, 14, 22, "cream") + e(138, 86, 22, 14, "cream") + e(202, 86, 22, 14, "cream")
        + e(148, 64, 14, 22, "cream", -45) + e(192, 64, 14, 22, "cream", 45) + e(148, 108, 14, 22, "cream", 45) + e(192, 108, 14, 22, "cream", -45)
        + c(170, 86, 16, "orange") + ground(110, 230),
    "football": lambda: c(170, 102, 54, "cream") + p("M170 80L190 95L182 119H158L150 95Z", "ink")
        + s("M170 80V50M190 95L216 86M182 119L198 142M158 119L142 142M150 95L124 86", "ink", 3),
    "house": lambda: r(198, 46, 18, 36, "deepTeal") + r(112, 88, 116, 82, "skin", 3) + p("M98 92L170 38L242 92Z", "teal")
        + r(158, 122, 26, 48, "brown", 3) + r(124, 104, 24, 24, "cream", 2) + r(194, 104, 24, 24, "cream", 2) + ground(),
    "key": lambda: ring(122, 100, 26, "greyShade", "none", 10) + ln(148, 100, 244, 100, "greyShade", 10)
        + r(212, 104, 10, 22, "greyShade", 2) + r(230, 104, 10, 14, "greyShade", 2),
    "ear": lambda: e(170, 100, 38, 54, "skin") + e(174, 104, 22, 36, "skinShade") + s("M166 80C184 80 186 108 168 120", "earPink", 5)
        + c(168, 148, 14, "skin"),
    "eye": lambda: p("M92 102C128 60 212 60 248 102C212 144 128 144 92 102Z", "cream") + c(170, 102, 28, "teal") + c(170, 102, 13, "ink")
        + c(179, 93, 5, "cream") + s("M98 66C140 34 200 34 242 66", "ink", 6),
    "hand": lambda: r(138, 50, 14, 62, "skin", 7) + r(154, 40, 14, 72, "skin", 7) + r(170, 46, 14, 66, "skin", 7)
        + r(186, 58, 14, 54, "skin", 7) + r(138, 96, 62, 56, "skin", 16) + ln(142, 134, 112, 104, "skin", 14)
        + r(144, 150, 50, 22, "teal", 3),
    "foot": lambda: r(122, 40, 46, 92, "skin", 10) + r(118, 70, 54, 28, "teal", 3)
        + p("M122 116H168V138L232 150C250 154 248 172 230 172H138C118 172 122 146 122 146Z", "skin")
        + c(232, 160, 5, "skinShade") + c(216, 156, 4, "skinShade") + ground(),
    "hat": lambda: p("M122 126C122 66 218 66 218 126Z", "teal") + r(122, 110, 96, 10, "orange") + e(170, 128, 82, 14, "deepTeal") + ground(),
    "jacket": lambda: p("M128 54L152 48L170 64L188 48L212 54L238 100L218 112L212 96V166H128V96L122 112L102 100Z", "green")
        + p("M152 48L170 64L188 48L170 82Z", "deepTeal") + ln(170, 82, 170, 166, "cream", 3)
        + r(134, 120, 22, 4, "deepTeal") + r(184, 120, 22, 4, "deepTeal"),
    "jeans": lambda: p("M126 50H214L222 170H184L170 98L156 170H118Z", "teal") + r(126, 50, 88, 14, "deepTeal", 2)
        + ln(140, 76, 152, 76, "orange", 3) + ln(200, 76, 188, 76, "orange", 3) + c(170, 72, 4, "orange"),
    "dress": lambda: p("M152 44H188L196 86L238 168H102L144 86Z", "teal") + r(142, 84, 56, 8, "orange", 2)
        + r(102, 160, 136, 8, "deepTeal", 2) + s("M152 44L150 30M188 44L190 30", "deepTeal", 5),
    "glass": lambda: p("M130 58H210L202 168H138Z", "cream") + p("M135 100H205L202 168H138Z", "teal") + r(134, 54, 76, 8, "cream", 3)
        + ln(146, 70, 150, 130, "cream", 3) + ground(100, 240),
    "guitar": lambda: c(170, 140, 36, "skin") + c(170, 100, 28, "skin") + c(170, 124, 11, "ink") + r(164, 26, 12, 80, "brown", 3)
        + r(158, 20, 24, 18, "brown", 3) + r(152, 154, 36, 6, "brown", 2) + ln(168, 40, 168, 152, "cream", 2),
    "horse": lambda: s("M224 100C248 106 250 138 240 156", "ink", 9) + r(112, 90, 112, 50, "brown", 22)
        + p("M124 96L98 52L126 44L152 92Z", "brown") + p("M98 52L70 74L80 92L114 72Z", "brown") + s("M124 48L150 94", "ink", 7)
        + p("M104 48L112 32L120 46Z", "brown") + eye(100, 64) + r(122, 134, 12, 38, "brown", 3) + r(146, 134, 12, 38, "brown", 3)
        + r(198, 134, 12, 38, "brown", 3) + r(214, 134, 12, 38, "brown", 3) + r(122, 166, 12, 6, "ink") + r(146, 166, 12, 6, "ink")
        + r(198, 166, 12, 6, "ink") + r(214, 166, 12, 6, "ink") + ground(),
    "ice_cream": lambda: p("M138 104H202L170 172Z", "skin") + ln(152, 112, 176, 150, "skinShade", 3) + ln(186, 112, 164, 150, "skinShade", 3)
        + c(170, 96, 32, "earPink") + c(170, 66, 26, "cream") + c(170, 40, 7, "orange"),
    "juice": lambda: p("M134 66H206L198 164H142Z", "orange") + r(130, 62, 80, 8, "cream", 3) + s("M186 62L202 34H224", "teal", 6)
        + ln(150, 84, 153, 130, "cream", 3) + ground(100, 240),
    "fire": lambda: p("M170 38C178 70 214 86 206 128C202 152 184 164 170 164C152 164 134 152 132 128C130 100 156 92 170 38Z", "orange")
        + p("M170 100C178 118 192 126 188 142C186 154 178 158 170 158C160 158 152 152 152 142C152 124 164 120 170 100Z", "cream")
        + ln(120, 174, 220, 158, "brown", 10) + ln(120, 158, 220, 174, "brown", 10),
    "garden": lambda: c(118, 78, 34, "green") + r(112, 106, 12, 72, "brown", 3) + r(158, 120, 100, 8, "brown", 2)
        + r(162, 104, 10, 70, "brown", 3) + r(186, 104, 10, 70, "brown", 3) + r(210, 104, 10, 70, "brown", 3) + r(234, 104, 10, 70, "brown", 3)
        + ln(150, 172, 150, 146, "green", 4) + c(150, 140, 9, "orange") + ln(176, 172, 176, 150, "green", 4) + ground(),
    "farm": lambda: r(226, 66, 30, 106, "grey", 4) + e(241, 66, 15, 8, "greyShade") + r(98, 92, 120, 78, "brown", 3)
        + p("M88 96L158 50L228 96Z", "deepTeal") + r(138, 116, 40, 54, "cream", 2) + ln(138, 116, 178, 170, "brown", 3)
        + ln(178, 116, 138, 170, "brown", 3) + ground(),
    "beach": lambda: r(50, 146, 240, 12, "teal", 6) + r(80, 162, 180, 8, "deepTeal", 4) + ln(170, 70, 170, 160, "brown", 5)
        + p("M104 96C104 50 236 50 236 96Z", "orange") + p("M150 62C146 72 146 86 148 96H170V58Z", "cream") + p("M190 58V96H212C214 82 210 70 204 62Z", "cream"),
    "hospital": lambda: r(100, 58, 140, 14, "deepTeal", 3) + r(104, 70, 132, 102, "cream", 3) + r(160, 82, 20, 44, "teal") + r(148, 94, 44, 20, "teal")
        + r(156, 136, 28, 36, "teal", 3) + r(114, 140, 24, 22, "sandBorder", 2) + r(202, 140, 24, 22, "sandBorder", 2) + ground(),
    "airport": lambda: p("M96 100L82 64H106L124 96Z", "teal") + e(170, 104, 82, 17, "cream") + p("M150 104L196 104L176 152H156Z", "greyShade")
        + p("M150 100L194 100L178 60H162Z", "grey") + c(116, 102, 3, "ink") + c(132, 102, 3, "ink") + c(148, 102, 3, "ink")
        + p("M240 96C254 98 254 110 240 112Z", "ink") + ground(60, 280),
    "bike": lambda: WORDS["bicycle"](),
}


def write(words) -> None:
    catalog = json.loads(BINDINGS.read_text())
    by_asset = {}
    for a in catalog["assets"]:
        by_asset.setdefault(a["assetName"], []).append(a)
    for word, draw in words.items():
        name = f"word_{word}_plate"
        (ASSETS / f"{name}.imageset" / f"{name}.svg").write_text(
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 340 200">{FRAME}{draw()}</svg>\n')
        for a in by_asset[name]:  # a few assets are bound to several lemmas/senses
            a["style"] = "flat_color"
    BINDINGS.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n")
    print(f"Redrew {len(words)} illustrations")


def main() -> None:
    write(WORDS)


if __name__ == "__main__":
    main()
