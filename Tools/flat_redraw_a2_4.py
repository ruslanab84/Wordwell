#!/usr/bin/env python3
"""Flat colour A2 batch 4: next 30 drawable Oxford 3000 A2 words in alphabetical order (drop .. golf).

Run: python3 Tools/flat_redraw_a2_4.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s
from flat_redraw_b7 import P, heart, star
from flat_redraw_b8 import cloud, pine
from flat_redraw_a2_1 import main

WORDS = {
    "drop": ("noun", ["nature"], "A falling water drop with ripples below.",
        lambda: p("M170 24C150 62 132 80 132 106C132 128 148 142 170 142C192 142 208 128 208 106C208 80 190 62 170 24Z", "teal") + e(156, 108, 6, 14, "cream", 20) + e(170, 160, 58, 11, "sandBorder") + e(170, 160, 34, 6, "teal")),
    "drug": ("noun", ["health"], "A medicine bottle with a cross and a capsule.",
        lambda: r(100, 72, 74, 98, "orange", 8) + r(106, 54, 62, 20, "cream", 4) + r(108, 100, 58, 44, "cream", 3) + r(133, 106, 8, 32, "teal") + r(121, 118, 32, 8, "teal")
        + e(222, 150, 32, 14, "teal", -30) + e(240, 140, 20, 14, "cream", -30) + ground(80, 270)),
    "dry": ("adjective", ["describing", "weather"], "Cracked dry ground under a hot sun.",
        lambda: c(250, 56, 22, "orange") + p("M30 100H310V176H30Z", "skin") + s("M60 110L90 140L80 170", "brown", 3) + s("M90 140L130 146L150 176", "brown", 3) + s("M180 104L200 138L240 144", "brown", 3)
        + s("M240 144L260 176", "brown", 3) + s("M200 138L196 176", "brown", 3)),
    "earth": ("noun", ["space", "geography"], "The planet Earth with the Moon and stars.",
        lambda: c(150, 106, 56, "teal") + p("M112 86C130 72 156 84 150 104C144 122 120 130 116 110Z", "green") + p("M164 120C182 112 198 124 190 142C180 154 166 146 164 120Z", "green")
        + c(240, 62, 16, "cream") + star(76, 56, 8, 3, "orange") + star(260, 140, 8, 3, "orange") + star(90, 150, 6, 2.5, "orange")),
    "electricity": ("noun", ["science"], "A bright lightning bolt with sparks.",
        lambda: p("M192 24L128 110H168L148 178L218 84H178Z", "orange") + star(100, 64, 9, 4, "orange") + star(244, 130, 9, 4, "orange") + star(92, 140, 7, 3, "orange")),
    "empty": ("adjective", ["describing"], "An open empty box with nothing inside.",
        lambda: p("M96 92L116 66H224L244 92Z", "skinShade") + r(96, 92, 148, 76, "skin", 4) + e(170, 92, 74, 12, "brown") + ground(70, 270)),
    "employee": ("noun", ["jobs", "work"], "A worker at a desk with a name badge.",
        lambda: r(96, 140, 148, 12, "brown", 3) + r(108, 152, 10, 26, "brown", 2) + r(222, 152, 10, 26, "brown", 2) + P(150, 0.75, top="teal", hair="brown", base=140) + r(154, 78, 12, 16, "cream", 2)
        + r(180, 124, 50, 16, "grey", 3) + ground(70, 270)),
    "engine": ("noun", ["transport", "machines"], "A metal engine with pistons and a pipe.",
        lambda: r(96, 84, 148, 70, "grey", 8) + r(112, 52, 26, 36, "greyShade", 4) + r(148, 52, 26, 36, "greyShade", 4) + r(184, 52, 26, 36, "greyShade", 4) + s("M244 100C270 100 270 150 244 150", "greyShade", 8)
        + ring(138, 120, 16, "ink", "none", 5) + c(138, 120, 4, "ink") + r(96, 154, 148, 14, "ink", 4)),
    "engineer": ("noun", ["jobs", "work"], "A worker in an orange hard hat beside a large gear.",
        lambda: P(120, top="teal", hair="orange") + e(120, 49, 26, 5, "orange") + ring(220, 106, 30, "grey", "none", 12) + c(220, 106, 8, "greyShade") + ln(220, 60, 220, 70, "grey", 10) + ln(220, 142, 220, 152, "grey", 10)
        + ln(174, 106, 184, 106, "grey", 10) + ln(256, 106, 266, 106, "grey", 10) + ground(60, 280)),
    "enormous": ("adjective", ["describing"], "A tiny person standing next to a gigantic tree.",
        lambda: pine(226, 178, 150) + P(96, 0.4, top="orange", hair="brown") + ground(50, 290)),
    "error": ("noun", ["technology"], "A computer window with a red-brown cross showing an error.",
        lambda: r(90, 44, 160, 112, "cream", 8) + r(90, 44, 160, 22, "teal", 8) + r(90, 56, 160, 10, "teal") + c(170, 112, 28, "skinShade") + ln(158, 100, 182, 124, "cream", 7) + ln(182, 100, 158, 124, "cream", 7)),
    "essay": ("noun", ["school", "writing"], "Lined paper with writing and a pencil.",
        lambda: r(110, 34, 120, 140, "cream", 4) + ln(130, 34, 130, 174, "skinShade", 2) + ln(142, 66, 214, 66, "teal", 3) + ln(142, 86, 214, 86, "teal", 3) + ln(142, 106, 214, 106, "teal", 3)
        + ln(142, 126, 190, 126, "teal", 3) + ln(220, 150, 262, 108, "orange", 10) + p("M214 156L220 150L226 156L212 162Z", "skin")),
    "factory": ("noun", ["buildings", "work"], "A factory with chimneys, windows and smoke.",
        lambda: r(70, 104, 200, 72, "grey", 3) + p("M70 104L100 78V104Z", "greyShade") + p("M100 104L130 78V104Z", "greyShade") + p("M130 104L160 78V104Z", "greyShade") + r(204, 52, 22, 52, "brown", 2) + r(238, 68, 18, 36, "brown", 2)
        + cloud(226, 56, "cream") + r(84, 124, 24, 18, "cream", 2) + r(122, 124, 24, 18, "cream", 2) + r(160, 124, 24, 18, "cream", 2) + r(206, 130, 30, 46, "ink", 2) + ground(50, 290)),
    "fan": ("noun", ["home", "machines"], "An electric fan with three blades on a stand.",
        lambda: ring(170, 84, 54, "grey", "cream", 6) + p("M170 84L160 42C170 34 182 40 182 52Z", "teal") + p("M170 84L212 98C214 110 204 118 194 112Z", "teal") + p("M170 84L134 112C124 106 126 94 136 90Z", "teal")
        + c(170, 84, 8, "greyShade") + r(163, 138, 14, 28, "grey", 3) + r(134, 164, 72, 10, "greyShade", 4)),
    "farming": ("noun", ["jobs", "outdoors"], "A green tractor on a field.",
        lambda: r(150, 76, 70, 44, "green", 4) + r(108, 98, 80, 30, "green", 5) + r(160, 84, 40, 28, "cream", 3) + c(206, 136, 32, "ink") + c(206, 136, 14, "grey") + c(124, 148, 18, "ink") + c(124, 148, 7, "grey")
        + ln(110, 98, 110, 80, "ink", 5) + ln(40, 176, 300, 176, "brown") + ln(60, 168, 90, 168, "green", 5) + ln(240, 168, 290, 168, "green", 5)),
    "fashion": ("noun", ["clothes"], "A stylish dress with a belt and sparkles.",
        lambda: BASE["dress"]() + star(86, 62, 9, 4, "orange") + star(256, 70, 10, 4, "orange") + star(250, 140, 7, 3, "orange")),
    "fear": ("noun", ["feelings"], "A frightened face with wide eyes and open mouth.",
        lambda: p("M116 74L124 42L144 62L158 34L172 60L190 36L198 62L218 46L224 78Z", "ink") + c(170, 108, 52, "skin") + ring(152, 98, 11, "ink", "cream", 3) + c(152, 98, 4, "ink") + ring(188, 98, 11, "ink", "cream", 3)
        + c(188, 98, 4, "ink") + e(170, 134, 9, 12, "ink") + e(232, 90, 5, 9, "teal") + e(108, 100, 5, 9, "teal")),
    "field": ("noun", ["nature", "farm"], "A green field with rows of crops under the sun.",
        lambda: c(250, 56, 20, "orange") + p("M30 96H310V178H30Z", "green") + ln(80, 178, 120, 98, "deepTeal", 4) + ln(130, 178, 150, 98, "deepTeal", 4) + ln(180, 178, 180, 98, "deepTeal", 4)
        + ln(230, 178, 210, 98, "deepTeal", 4) + ln(280, 178, 240, 98, "deepTeal", 4)),
    "fight": ("verb", ["conflict", "sport"], "Two boxing gloves hitting each other with a burst.",
        lambda: e(112, 102, 40, 32, "skinShade") + r(60, 92, 26, 22, "cream", 4) + e(228, 102, 40, 32, "teal") + r(254, 92, 26, 22, "cream", 4) + star(170, 102, 22, 9, "orange") + star(170, 102, 11, 5, "cream")),
    "finger": ("noun", ["body"], "A hand with one finger pointing up.",
        lambda: r(150, 30, 30, 100, "skin", 15) + r(118, 100, 96, 66, "skin", 22) + e(120, 120, 16, 24, "skin", -30) + ln(166, 112, 166, 130, "skinShade", 3) + ln(138, 124, 194, 124, "skinShade", 3) + r(124, 156, 84, 20, "teal", 3)),
    "fishing": ("noun", ["sport", "outdoors"], "A fishing rod with a line and a fish in the water.",
        lambda: r(40, 128, 260, 50, "teal", 6) + ln(66, 118, 200, 36, "brown", 5) + ln(200, 36, 200, 138, "grey", 2) + e(200, 150, 28, 14, "orange") + p("M226 150L246 138V162Z", "orange") + eye(188, 148)
        + s("M60 142C80 134 100 150 120 142", "cream", 3) + s("M240 166C260 158 280 172 290 166", "cream", 3)),
    "flu": ("noun", ["health"], "A sick face with a red nose and a thermometer.",
        lambda: c(170, 104, 52, "skin") + s("M144 92Q152 98 160 92", "ink", 3) + s("M180 92Q188 98 196 92", "ink", 3) + c(170, 114, 8, "skinShade") + ln(176, 132, 216, 148, "greyShade", 6) + c(220, 150, 5, "orange")
        + e(140, 72, 12, 6, "teal", 20) + r(100, 150, 140, 26, "teal", 12)),
    "fork": ("noun", ["kitchen"], "A silver fork with four tines.",
        lambda: r(146, 30, 8, 50, "grey", 3) + r(160, 30, 8, 50, "grey", 3) + r(174, 30, 8, 50, "grey", 3) + r(188, 30, 8, 50, "grey", 3) + p("M146 76H196C196 100 182 106 176 110V170C176 176 160 176 160 170V110C154 106 146 100 146 76Z", "grey")
        + ground(110, 230)),
    "furniture": ("noun", ["home"], "A sofa with a lamp and a small table.",
        lambda: r(70, 84, 140, 40, "teal", 12) + r(60, 106, 160, 44, "teal", 12) + r(76, 112, 128, 26, "deepTeal", 8) + r(70, 150, 10, 16, "brown") + r(200, 150, 10, 16, "brown") + ln(256, 60, 256, 164, "brown", 5)
        + p("M236 60L276 60L268 36H244Z", "orange") + r(236, 164, 40, 8, "brown", 3) + ground(50, 290)),
    "gallery": ("noun", ["art", "places"], "Two framed pictures on a wall and a bench.",
        lambda: r(68, 46, 100, 78, "brown", 4) + r(78, 56, 80, 58, "teal", 2) + c(138, 78, 8, "orange") + p("M78 114L106 84L128 104L148 90L158 114Z", "green") + r(196, 52, 72, 92, "brown", 4)
        + r(206, 62, 52, 72, "skin", 2) + c(232, 92, 12, "skinShade") + r(100, 150, 140, 12, "brown", 3) + r(112, 162, 10, 14, "brown") + r(218, 162, 10, 14, "brown") + ground(60, 280)),
    "gas": ("noun", ["home", "science"], "A gas cylinder with a valve and a flame.",
        lambda: r(130, 78, 80, 94, "teal", 28) + r(156, 62, 28, 18, "greyShade", 4) + r(144, 112, 52, 22, "cream", 3) + p("M170 22C182 34 186 40 180 48C176 54 164 54 160 46C158 40 166 36 170 22Z", "orange") + ground(100, 240)),
    "gate": ("noun", ["outdoors", "home"], "A wooden garden gate between two posts.",
        lambda: r(76, 52, 18, 124, "brown", 3) + r(246, 52, 18, 124, "brown", 3) + r(112, 76, 10, 90, "skin", 2) + r(136, 76, 10, 90, "skin", 2) + r(160, 76, 10, 90, "skin", 2) + r(184, 76, 10, 90, "skin", 2) + r(208, 76, 10, 90, "skin", 2)
        + r(100, 90, 130, 8, "brown", 2) + r(100, 140, 130, 8, "brown", 2) + c(224, 120, 4, "ink") + ground(50, 290)),
    "goal": ("noun", ["sport"], "A football goal with a net and a ball.",
        lambda: r(66, 50, 208, 8, "cream", 3) + r(66, 50, 8, 112, "cream", 3) + r(266, 50, 8, 112, "cream", 3) + ln(104, 58, 104, 156, "grey", 2) + ln(140, 58, 140, 156, "grey", 2) + ln(176, 58, 176, 156, "grey", 2)
        + ln(212, 58, 212, 156, "grey", 2) + ln(74, 88, 266, 88, "grey", 2) + ln(74, 122, 266, 122, "grey", 2) + c(170, 168, 12, "cream") + ground(50, 290)),
    "gold": ("noun", ["money", "materials"], "A stack of shiny gold bars with sparkles.",
        lambda: p("M96 164L112 132H170L186 164Z", "orange") + p("M160 164L176 132H234L250 164Z", "orange") + p("M128 132L144 100H202L218 132Z", "orange") + ln(118, 148, 168, 148, "cream", 3) + ln(186, 148, 238, 148, "cream", 3)
        + ln(148, 116, 198, 116, "cream", 3) + star(82, 84, 10, 4, "orange") + star(256, 100, 10, 4, "orange") + ground(70, 280)),
    "golf": ("noun", ["sport"], "A golf ball near a flag on a green.",
        lambda: p("M40 176C90 130 250 130 300 176Z", "green") + ln(222, 60, 222, 146, "brown", 4) + p("M222 60H258L246 72L258 84H222Z", "orange") + c(120, 150, 11, "cream") + e(222, 148, 14, 4, "ink") + ln(70, 90, 110, 140, "grey", 5)),
}

if __name__ == "__main__":
    main(WORDS)
