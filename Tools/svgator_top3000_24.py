#!/usr/bin/env python3
"""Flat colour illustrations, Top-3000 batch 24 (98 nouns + 2 adverbs). Same polygon pipeline as svgator_top3000_1.py.
Run: python3 Tools/svgator_top3000_24.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

import math
import sys

import svgator_top3000_1 as base
from svgator_top3000_1 import BR, CR, DT, GN, GS, GY, HL, IN, OR, PK, R, SB, SK, SS, TL, O, P
from svgator_top3000_3 import star
from svgator_top3000_5 import arc, gear, heart, line
from svgator_top3000_6 import person
from svgator_top3000_7 import burst
from svgator_top3000_8 import JUMBLE, polyline
from svgator_top3000_9 import CURVE, cup, qmark
from svgator_top3000_10 import ZIG, arrow, face, gavel
from svgator_top3000_11 import bubble
from svgator_top3000_12 import GROUND, fig, hand
from svgator_top3000_13 import WATER
from svgator_top3000_14 import doc
from svgator_top3000_15 import cloud
from svgator_top3000_16 import rosette
from svgator_top3000_17 import note
from svgator_top3000_22 import angry
from svgator_top3000_23 import check


def spokes(cx, cy, r1, r2, n, w, c):
    return [line(cx + round(r1 * math.cos(2 * math.pi * i / n)), cy + round(r1 * math.sin(2 * math.pi * i / n)),
                 cx + round(r2 * math.cos(2 * math.pi * i / n)), cy + round(r2 * math.sin(2 * math.pi * i / n)), w, c) for i in range(n)]


def envelope(x, y, c=CR):
    return [R(x, y, 80, 54, c), P([(x, y), (x + 40, y + 30), (x + 80, y)], GS)]


def palm(cx, cy, c=SK):
    """Open hand, fingers up."""
    return [O(cx, cy, 30, 28, c, 12)] + [R(cx - 26 + 14 * i, cy - 50, 10, 40, c) for i in range(4)] + [line(cx + 26, cy, cx + 44, cy - 20, 10, c)]


NOUNS = {
    "burr": spokes(170, 100, 20, 40, 12, 3, BR) + [O(170, 100, 24, 24, BR, 14), R(168, 124, 4, 36, GN)],
    "buster": person(170, 160, 2.0, TL) + [R(154, 28, 32, 12, PK), R(182, 36, 22, 5, PK), GROUND],
    "calabash": [O(170, 122, 36, 34, OR, 14), O(170, 76, 16, 18, OR, 12), R(168, 50, 4, 12, BR), O(184, 54, 10, 4, GN), O(158, 116, 6, 12, HL)],
    "callus": palm(160, 116) + [O(150, 126, 8, 6, SS), O(176, 130, 8, 6, SS), O(152, 72, 4, 4, SS)],
    "canker": [P([(110, 100), (150, 70), (200, 70), (236, 100), (200, 130), (150, 130)], GN), line(110, 100, 236, 100, 2, DT), O(160, 88, 8, 7, BR), O(196, 112, 10, 8, BR), O(176, 116, 5, 5, BR), O(212, 88, 4, 4, BR)],
    "chap": person(170, 160, 2.0, DT) + [R(150, 30, 40, 5, IN), R(158, 20, 24, 12, IN), GROUND] + hand(214, 90),
    "char": [R(120, 120, 100, 24, IN), O(220, 132, 8, 12, BR), O(150, 116, 4, 4, OR), O(180, 114, 3, 3, OR), O(200, 118, 4, 4, PK)] + polyline([(160, 110), (150, 90), (160, 70), (152, 50)], 3, GS) + polyline([(190, 108), (198, 88), (190, 68)], 3, GS),
    "characteristic": [arc(170, 100, r, r + 4, 210, 510, (BR, SS)[r // 8 % 2], 12) for r in (8, 16, 24, 32, 40)],
    "chicane": polyline([(100, 150), (150, 150), (170, 100), (190, 60), (240, 60)], 18, GS) + polyline([(100, 150), (150, 150), (170, 100), (190, 60), (240, 60)], 2, CR) + [R(140, 162, 10, 6, PK), R(196, 44, 10, 6, PK)],
    "clout": [R(108, 90, 30, 20, TL), O(150, 100, 22, 20, SK, 12), R(138, 86, 24, 4, SS)] + burst(204, 96, 18, OR),
    "coming": [R(190, 50, 50, 110, BR), R(196, 56, 38, 104, SB)] + person(150, 160, 1.6, OR) + arrow(108, 70, 168, 70, 4, TL) + [GROUND],
    "commitment": [arc(170, 116, 24, 30, 0, 360, OR, 16), P([(158, 70), (182, 70), (190, 80), (170, 96), (150, 80)], SB), R(166, 86, 8, 4, OR)],
    "complaint": bubble(110, 40, 90, 56, CR, 130) + [R(151, 50, 8, 26, PK), O(155, 84, 4, 4, PK)] + angry(212, 130, OR),
    "complication": polyline(JUMBLE, 4, TL) + [O(120, 70, 6, 6, OR), O(110, 90, 6, 6, PK)],
    "conceit": person(140, 160, 1.8, PK) + [O(212, 96, 28, 42, BR, 12), O(212, 96, 22, 36, SB, 12), R(208, 138, 8, 22, BR), star(140, 34, 8, 3, 5, OR), GROUND],
    "condemnation": gavel(BR) + [O(214, 70, 16, 16, PK), line(204, 60, 224, 80, 4, CR)],
    "confederate": person(140, 160, 1.8, TL) + person(200, 160, 1.8, OR) + [line(152, 112, 188, 112, 8, SK), GROUND],
    "confession": [R(120, 50, 100, 110, BR), R(146, 70, 48, 50, IN)] + [R(152 + 12 * i, 70, 3, 50, SS) for i in range(4)] + [R(146, 92, 48, 3, SS), P([(120, 50), (170, 30), (220, 50)], BR)],
    "confidence": fig((170, 56), (170, 112), [[(148, 84), (158, 104)], [(192, 84), (182, 104)]], [[(154, 158)], [(186, 158)]], OR) + [GROUND, star(216, 50, 8, 3, 5, OR)],
    "confirmation": [O(170, 100, 44, 44, GN, 16)] + polyline([(148, 100), (164, 116), (194, 84)], 8, CR),
    "conformity": [s for r in (100, 160) for i in range(5) for s in person(114 + 28 * i, r, 0.9, GY)] + [GROUND],
    "confrontation": fig((130, 60), (130, 110), [[(162, 80)]], [[(118, 158)], [(142, 158)]], TL) + fig((210, 60), (210, 110), [[(178, 80)]], [[(198, 158)], [(222, 158)]], PK) + burst(170, 54, 10, OR) + [GROUND],
    "convention": [R(110, 40, 120, 22, TL), R(150, 70, 40, 34, BR)] + [O(118 + 21 * i, 124 + 22 * r, 7, 7, (OR, PK, GN, DT, GS)[(i + r) % 5]) for r in range(2) for i in range(6)],
    "conveyance": [R(110, 80, 120, 60, OR)] + [R(118 + 26 * i, 90, 20, 18, SB) for i in range(4)] + [O(136, 142, 10, 10, IN), O(206, 142, 10, 10, IN), GROUND],
    "correspondence": envelope(150, 46, SB) + envelope(116, 90) + arrow(240, 70, 240, 120, 3, TL),
    "covering": [P([(110, 150), (124, 70), (216, 70), (230, 150)], PK)] + [R(126 + 30 * i, 70, 10, 80, SS) for i in range(3)] + [GROUND],
    "craze": [P([(146, 80), (194, 80), (170, 144)], PK), R(166, 60, 8, 20, BR), O(170, 80, 24, 6, OR, 12), arc(170, 100, 40, 43, 200, 340, GS, 8), star(118, 60, 8, 3, 5, OR), star(226, 56, 8, 3, 5, OR), GROUND],
    "creation": hand(140, 140) + [star(190, 80, 26, 11, 5, OR), star(130, 60, 7, 3, 4, PK), star(232, 128, 7, 3, 4, PK)],
    "crimp": polyline(ZIG, 8, OR) + polyline([(x, y + 34) for x, y in ZIG], 8, SS),
    "custom": [R(168, 44, 4, 16, IN), R(156, 60, 28, 10, IN), R(150, 70, 40, 60, PK), R(156, 130, 28, 8, IN), O(170, 100, 10, 14, HL), star(122, 70, 7, 3, 5, OR), star(218, 70, 7, 3, 5, OR)],
    "dado": [R(110, 50, 120, 110, CR), R(110, 110, 120, 50, TL), R(110, 106, 120, 6, BR)] + [R(118 + 38 * i, 118, 30, 34, DT) for i in range(3)],
    "dealer": [R(124 + 22 * i, 54 + 4 * i, 34, 50, CR) for i in range(4)] + [O(141 + 22 * i, 79 + 4 * i, 5, 5, (PK, IN)[i % 2]) for i in range(4)] + hand(170, 136),
    "decision": [line(170, 162, 170, 110, 14, GS), line(170, 110, 120, 60, 12, GS), line(170, 110, 220, 60, 12, GS)] + arrow(140, 128, 116, 104, 3, TL) + arrow(200, 128, 224, 104, 3, PK) + qmark(170, 50, 1.4, OR),
    "decomposition": [R(110, 76, 44, 48, TL), P([(164, 80), (184, 86), (172, 104)], TL), P([(176, 110), (196, 104), (194, 124)], TL), R(204, 84, 12, 12, TL), R(222, 108, 8, 8, TL), R(236, 90, 5, 5, TL)],
    "dedication": rosette(170, 84, PK) + [P([(150, 108), (162, 108), (154, 150), (144, 140)], PK), P([(178, 108), (190, 108), (196, 140), (186, 150)], PK), heart(170, 84, 0.6, PK)],
    "default": [O(170, 104, 40, 30, PK, 14), O(208, 100, 8, 8, SS), R(144, 128, 10, 18, PK), R(186, 128, 10, 18, PK), R(160, 76, 20, 4, IN), O(152, 96, 3, 3, IN)] + polyline([(170, 76), (164, 96), (176, 110), (168, 132)], 3, IN),
    "deflection": [R(220, 40, 12, 120, GS), line(110, 60, 216, 100, 4, TL)] + arrow(216, 100, 124, 150, 4, PK) + [O(216, 100, 7, 7, OR)],
    "deliberation": face(140, 124, 28, SK) + cloud(204, 60, CR) + qmark(204, 50, 1.2, TL) + [O(170, 96, 4, 4, CR), O(180, 86, 5, 5, CR)],
    "demonstration": [s for i, c in enumerate((TL, OR, PK)) for s in person(130 + 40 * i, 160, 1.4, c) + [R(130 + 40 * i - 1, 64, 3, 30, BR), R(116 + 40 * i, 40, 30, 24, CR)]] + [GROUND],
    "denial": palm(164, 116) + [line(110, 60, 122, 72, 3, GS), line(222, 60, 210, 72, 3, GS)],
    "derivative": [R(108, 46, 4, 110, GS), R(108, 152, 130, 4, GS)] + polyline(CURVE, 4, TL) + [line(130, 134, 200, 104, 3, PK), O(170, 118, 5, 5, OR)],
    "designer": [P([(150, 150), (230, 150), (230, 90)], TL), line(122, 140, 192, 70, 12, OR), P([(116, 146), (118, 134), (128, 144)], IN), R(186, 58, 14, 14, PK)],
    "despatch": envelope(150, 74) + [R(104, 80, 36, 4, GS), R(114, 96, 28, 4, GS), R(108, 112, 32, 4, GS)] + arrow(200, 140, 240, 140, 3, TL),
    "detachment": [R(110, 70, 90, 60, CR), R(124, 84, 50, 4, GS), R(124, 96, 40, 4, GS)] + [R(204, 70 + 12 * i, 3, 6, GS) for i in range(5)] + [P([(214, 66), (244, 70), (240, 130), (210, 126)], CR)],
    "determination": [P([(90, 160), (150, 80), (210, 160)], GS)] + fig((200, 62), (200, 112), [[(186, 40)], [(222, 92)]], [[(186, 158)], [(214, 158)]], PK) + [GROUND],
    "devastation": [P([(120, 160), (120, 100), (140, 110), (150, 90), (160, 160)], GS), P([(180, 160), (186, 96), (200, 120), (220, 100), (224, 160)], GS)] + [O(146 + 14 * i, 158, 7, 5, BR) for i in range(4)] + cloud(170, 50, GY),
    "deviation": [R(106 + 16 * i, 100, 10, 4, GS) for i in range(9)] + polyline([(160, 102), (192, 80)], 4, PK) + arrow(192, 80, 226, 50, 4, PK),
    "differential": [R(130, 60, 30, 100, TL), R(180, 110, 30, 50, OR), R(120, 158, 100, 4, GS)] + arrow(226, 134, 226, 62, 3, PK) + arrow(226, 88, 226, 156, 3, PK),
    "director": [R(130, 80, 80, 60, IN), R(130, 64, 80, 14, CR)] + [R(136 + 20 * i, 64, 10, 14, IN) for i in range(4)] + [R(144, 96, 50, 4, GS), R(144, 110, 34, 4, GS)],
    "discernment": [O(170, 100, 54, 26, CR, 16), O(170, 100, 20, 20, TL, 14), O(170, 100, 9, 9, IN), O(176, 94, 3, 3, CR)] + [line(140 + 15 * i, 74, 136 + 16 * i, 62, 3, IN) for i in range(5)],
    "discord": note(140, 120, IN) + note(206, 110, PK) + polyline([(160, 90), (172, 70), (182, 96), (194, 74)], 4, OR) + burst(176, 140, 10, GS),
    "discretion": face(170, 100, 40, SK) + [R(150, 86, 14, 4, IN), R(176, 86, 14, 4, IN), R(164, 102, 12, 46, SS), O(170, 102, 7, 7, SS)],
    "disintegration": [R(110, 70, 50, 60, TL)] + [R(170 + 13 * i, 72 + (i * 23) % 52, 10 - i, 10 - i, TL) for i in range(6)],
    "disorder": [P([(120, 70), (150, 60), (146, 90)], TL), R(180, 60, 30, 20, OR), O(130, 130, 14, 10, PK), P([(200, 110), (230, 120), (210, 150)], GN), R(160, 120, 16, 30, DT), O(226, 70, 8, 8, GS), line(110, 100, 140, 110, 4, BR)],
    "disrespect": [R(150, 56, 40, 16, TL), O(170, 90, 22, 18, SK, 12), R(162, 102, 14, 32, SK), O(169, 134, 7, 4, SK)] + [line(206, 70, 230, 94, 4, PK), line(230, 70, 206, 94, 4, PK)],
    "dissolution": [R(140, 70, 60, 90, CR), R(144, 90, 52, 66, TL), R(160, 126, 20, 20, CR)] + [O(150 + 9 * i, 116 - 8 * (i % 3), 3, 3, CR) for i in range(5)],
    "domain": [P([(110, 140), (130, 70), (210, 60), (230, 130)], GN), R(166, 46, 3, 44, BR), P([(169, 46), (190, 54), (169, 62)], PK)] + [R(110 + 20 * i, 140, 4, 20, BR) for i in range(7)] + [R(110, 146, 124, 3, BR)],
    "dullness": face(170, 100, 40, GY) + [R(146, 120, 48, 4, IN), R(148, 86, 16, 4, IN), R(176, 86, 16, 4, IN), cloud(170, 44, GS)[0]],
    "elaboration": [R(110, 96, 26, 26, GS)] + arrow(144, 109, 176, 109, 3, TL) + [R(190, 90, 44, 44, CR), P([(184, 90), (212, 64), (240, 90)], PK), R(206, 112, 12, 22, BR), R(194, 98, 10, 10, SB), R(222, 98, 10, 10, SB), R(222, 70, 6, 12, BR)],
    "elimination": [O(170, 50, 12, 12, CR), R(132, 72, 76, 10, GS), P([(140, 84), (200, 84), (194, 160), (146, 160)], GS)] + [R(156 + 12 * i, 94, 4, 56, GY) for i in range(3)],
    "emission": [R(110, 110, 120, 50, BR), R(130, 60, 20, 50, GS), R(180, 74, 20, 36, GS), O(140, 46, 16, 10, GY), O(160, 32, 12, 8, GY), O(190, 60, 14, 9, GY), O(210, 46, 10, 7, GY)] + [R(126 + 30 * i, 126, 16, 16, HL) for i in range(3)],
    "ending": [WATER, arc(170, 120, 1, 40, 180, 360, OR, 12)] + [R(110 + 30 * i, 134 + 8 * (i % 2), 18, 3, SB) for i in range(4)],
    "endorsement": doc(120, 50, CR, 3) + polyline([(130, 118), (140, 108), (148, 120), (158, 106), (170, 118)], 3, IN) + [O(210, 128, 22, 22, PK, 14), O(210, 128, 14, 14, SS, 12)],
    "ensemble": [s for i, c in enumerate((TL, OR, PK)) for s in person(130 + 40 * i, 160, 1.4, c)] + note(126, 60, IN) + note(206, 54, IN) + [GROUND],
    "esteem": person(170, 160, 1.6, OR) + [heart(124, 70, 0.6, PK), heart(216, 60, 0.6, PK), heart(230, 112, 0.4, PK), heart(112, 120, 0.4, PK), GROUND],
    "excess": [R(146, 70, 48, 80, CR), R(150, 74, 40, 72, TL), P([(150, 66), (194, 66), (206, 100), (194, 90), (190, 150), (150, 74)], TL), P([(150, 70), (136, 120), (146, 100)], TL), O(170, 156, 54, 6, TL, 12)],
    "extremity": [P([(110, 150), (110, 110), (160, 104), (196, 112), (226, 126), (230, 150)], SK)] + [O(206 + 7 * i, 120 + 2 * i, 4, 4, SS) for i in range(3)] + [R(106, 150, 130, 4, GS)],
    "fabrication": [R(110, 130, 130, 10, GS), O(120, 146, 6, 6, IN), O(170, 146, 6, 6, IN), O(220, 146, 6, 6, IN), R(124, 110, 22, 20, BR), R(170, 110, 22, 20, BR)]
                   + polyline([(220, 40), (220, 70), (196, 86), (196, 100)], 6, OR) + [R(188, 98, 16, 6, IN)],
    "facility": [R(120, 70, 100, 90, CR), R(120, 58, 100, 14, TL)] + [R(130 + 24 * i, 82 + 22 * j, 14, 12, SB) for i in range(4) for j in range(2)] + [R(160, 128, 20, 32, BR)],
    "faintness": [O(170, 90, 26, 26, GS, 14), R(160, 114, 20, 18, GY), R(162, 132, 16, 6, GY)] + [line(170 + round(36 * math.cos(math.radians(a))), 90 - round(36 * math.sin(math.radians(a))),
                  170 + round(44 * math.cos(math.radians(a))), 90 - round(44 * math.sin(math.radians(a))), 2, GY) for a in range(30, 151, 40)],
    "familiarity": person(150, 160, 1.8, TL) + person(190, 160, 1.8, OR) + [line(160, 98, 180, 98, 8, SK), heart(170, 44, 0.5, PK), GROUND],
    "fiber": [s for i, c in enumerate((TL, OR, DT, SS)) for s in polyline([(110, 80 + 12 * i), (140, 70 + 12 * i), (170, 86 + 12 * i), (200, 72 + 12 * i), (230, 84 + 12 * i)], 4, c)],
    "fibre": [R(120, 60, 100, 80, CR)] + [R(124 + 20 * i, 60, 8, 80, TL) for i in range(5)] + [R(120 + 20 * (j % 2) + 40 * i, 66 + 14 * j, 16, 6, OR) for j in range(5) for i in range(3)],
    "fifth": [arc(166, 104, 1, 44, 0, 288, CR, 12), arc(176, 96, 1, 44, 288, 360, OR, 6), O(170, 156, 50, 5, GS, 12), O(166, 104, 3, 3, GS)],
    "filet": [P([(110, 100), (140, 74), (200, 70), (232, 90), (226, 120), (180, 132), (130, 126)], SS)] + [line(140 + 24 * i, 82, 150 + 24 * i, 120, 3, CR) for i in range(4)] + [O(232, 140, 14, 10, HL), R(96, 146, 160, 4, GS)],
    "filler": [P([(140, 50), (200, 50), (176, 84), (164, 84)], GS), R(166, 84, 8, 14, GS), R(140, 100, 60, 60, SB), R(140, 126, 60, 34, OR)] + [O(170, 106 + 8 * i, 2, 2, OR) for i in range(2)],
    "flatness": [R(110, 90, 120, 24, OR), R(158, 94, 24, 16, SB), O(170, 102, 5, 5, GN), R(96, 116, 150, 4, GS)],
    "fluke": [WATER, P([(170, 120), (160, 90), (130, 70), (150, 66), (170, 80), (190, 66), (210, 70), (180, 90)], DT), O(140, 120, 6, 3, CR), O(204, 120, 6, 3, CR)],
    "foliation": [line(110, 150, 230, 60, 5, BR)] + [O(130 + 22 * i, 136 - 16 * i + (12 if i % 2 else -12), 12, 6, (GN, DT)[i % 2]) for i in range(5)],
    "forfeit": [R(150, 40, 4, 120, BR), P([(154, 44), (220, 50), (204, 70), (220, 92), (154, 88)], CR), GROUND],
    "forte": [R(130, 96, 80, 8, GS), R(120, 80, 12, 40, IN), R(208, 80, 12, 40, IN), R(110, 86, 10, 28, IN), R(220, 86, 10, 28, IN), star(170, 60, 10, 4, 5, OR)],
    "fourth": [arc(166, 104, 1, 44, 0, 270, CR, 12), arc(176, 94, 1, 44, 270, 360, OR, 6), O(170, 156, 50, 5, GS, 12), O(166, 104, 3, 3, GS)],
    "freshness": [P([(120, 140), (150, 80), (210, 60), (196, 120)], GN), line(120, 140, 200, 70, 3, DT), O(220, 100, 5, 8, SB), O(230, 128, 4, 6, SB), star(130, 60, 8, 3, 4, SB)],
    "gang": [s for i, c in enumerate((TL, OR, PK, DT, GN)) for s in person(118 + 26 * i, 160 - 6 * (i % 2), 1.3, c)] + [GROUND],
    "gantlet": [R(146, 100, 52, 50, GS)] + [R(146 + 13 * i, 56, 10, 48, GS) for i in range(4)] + [line(198, 110, 220, 86, 10, GS), R(140, 140, 64, 16, GY)] + [R(146, 70 + 16 * i, 49, 2, GY) for i in range(2)],
    "gel": [P([(110, 110), (190, 96), (190, 124)], TL), R(190, 102, 16, 16, GS), O(222, 116, 14, 10, SB), O(214, 104, 8, 6, SB), R(110, 106, 8, 8, GS)],
    "genius": [O(170, 80, 30, 30, OR, 14), R(160, 108, 20, 18, GS), R(162, 126, 16, 6, GS)] + spokes(170, 80, 38, 50, 8, 3, OR) + [R(168, 76, 4, 24, CR)],
    "girdle": [R(110, 90, 120, 20, BR), R(160, 84, 22, 32, OR), R(166, 90, 10, 20, BR), R(176, 98, 16, 4, OR)] + [O(200 + 12 * i, 100, 2, 2, IN) for i in range(3)],
    "gossip": face(130, 110, 26, SK) + face(210, 110, 26, SS) + bubble(150, 40, 40, 26, CR, 156) + [hand(156, 116)[0]] + [O(162 + 8 * i, 54, 2, 2, GS) for i in range(3)],
    "graft": [R(160, 100, 16, 60, BR), line(168, 104, 220, 60, 8, BR), R(162, 96, 16, 10, CR), O(220, 56, 14, 8, GN), O(150, 90, 14, 8, GN), GROUND],
    "grapple": [R(166, 70, 8, 70, GS), arc(170, 140, 18, 24, 0, 180, GS, 8), arc(170, 140, 18, 24, 180, 220, GS, 3), arc(170, 140, 18, 24, 320, 360, GS, 3), O(170, 64, 8, 8, GS)] + polyline([(170, 60), (190, 40), (230, 50)], 3, BR),
    "groove": [O(170, 100, 54, 54, IN, 16)] + [arc(170, 100, r, r + 1, 0, 360, GS, 16) for r in (24, 34, 44)] + [O(170, 100, 14, 14, PK), O(170, 100, 3, 3, IN)],
    "grounds": [P([(110, 150), (140, 110), (180, 104), (220, 150)], BR)] + [O(130 + 16 * i, 140 - 4 * (i % 3), 3, 3, IN) for i in range(6)] + [cup(214, 46, CR), R(200, 70, 26, 4, IN)],
    "gut": [O(170, 92, 46, 40, PK, 14)] + polyline([(140, 92), (190, 84), (196, 104), (148, 108), (152, 120), (190, 120)], 6, SS) + [R(162, 132, 16, 24, PK)],
    "hardness": [P([(140, 70), (200, 70), (220, 92), (170, 150), (120, 92)], TL), P([(140, 70), (160, 92), (170, 70)], CR), P([(170, 70), (180, 92), (200, 70)], CR), R(120, 90, 100, 4, TL), star(222, 56, 8, 3, 4, CR)],
    "heaviness": fig((170, 80), (150, 120), [[(196, 110)]], [[(140, 160)], [(160, 160)]], TL) + [R(190, 96, 40, 34, BR), GROUND],
    "hoodoo": [P([(150, 160), (156, 110), (164, 80), (176, 80), (184, 110), (190, 160)], SS), O(170, 74, 26, 10, BR, 12), P([(90, 160), (250, 160), (250, 164), (90, 164)], SS), O(220, 50, 12, 12, OR)],
    "hoot": [O(170, 110, 34, 40, BR, 14), O(156, 92, 12, 12, CR), O(184, 92, 12, 12, CR), O(156, 92, 5, 5, IN), O(184, 92, 5, 5, IN), P([(164, 104), (176, 104), (170, 116)], OR), P([(140, 76), (148, 58), (156, 76)], BR), P([(184, 76), (192, 58), (200, 76)], BR)]
            + [arc(170, 100, r, r + 3, -30, 30, TL, 6) for r in (50, 60)],
}

ADVERBS = {
    "hereafter": [P([(90, 130), (250, 130), (250, 164), (90, 164)], GN), arc(210, 130, 1, 30, 180, 360, OR, 12)] + arrow(110, 150, 200, 112, 4, TL),
    "personally": person(150, 160, 2.0, TL) + arrow(234, 60, 166, 100, 4, PK) + [GROUND],
}

if __name__ == "__main__":
    assert len(NOUNS) + len(ADVERBS) == 100, (len(NOUNS), len(ADVERBS))
    taken = [w for w in NOUNS if (base.ASSETS / f"word_{w}_plate.imageset").exists()] + [w for w in ADVERBS if (base.ASSETS / f"word_{w}_adverb_plate.imageset").exists()]
    assert not taken, f"would overwrite existing imagesets: {taken}"
    if len(sys.argv) > 2 and sys.argv[1] == "json":
        import json
        base.WORDS = {**NOUNS, **ADVERBS}
        print(json.dumps(base.json_for(sys.argv[2]), separators=(",", ":")))
    else:
        for pos, words in (("noun", NOUNS), ("adverb", ADVERBS)):
            base.POS, base.WORDS = pos, words
            base.main()
