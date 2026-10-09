#!/usr/bin/env python3
"""Flat colour A2 batch 6: 30 A2 nouns in alphabetical order after 'ship' (sock .. zoo).

Word list is memory-derived, not from the official Oxford 3000 file (unavailable here).
Run: python3 Tools/flat_redraw_a2_6.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import c, e, ground, ln, p, r, ring, s, wheel
from flat_redraw_a2_1 import main

WORDS = {
    "sock": ("noun", ["clothes"], "A teal sock with a cream stripe.",
        lambda: s("M130 40L130 130Q130 160 170 160L210 160", "teal", 18) + ln(130, 100, 150, 100, "cream", 3) + r(118, 34, 24, 14, "teal", 6)),
    "sofa": ("noun", ["home", "furniture"], "A teal sofa with cushions and short legs.",
        lambda: r(70, 100, 200, 44, "teal", 12) + r(60, 80, 30, 64, "teal", 10) + r(60, 120, 220, 26, "deepTeal", 10) + r(76, 150, 10, 16, "brown") + r(254, 150, 10, 16, "brown") + ground(50, 290)),
    "spider": ("noun", ["animals"], "A black spider with eight thin legs.",
        lambda: c(170, 112, 22, "ink") + c(170, 82, 14, "ink") + ln(150, 100, 100, 80, "ink", 3) + ln(150, 112, 96, 112, "ink", 3) + ln(150, 124, 100, 146, "ink", 3)
        + ln(190, 100, 240, 80, "ink", 3) + ln(190, 112, 244, 112, "ink", 3) + ln(190, 124, 240, 146, "ink", 3) + ln(170, 134, 170, 170, "ink", 3)),
    "spoon": ("noun", ["kitchen", "objects"], "A metal spoon with a round bowl.",
        lambda: r(164, 92, 12, 80, "grey", 6) + c(170, 70, 26, "grey") + c(170, 70, 16, "greyShade")),
    "stair": ("noun", ["buildings", "home"], "Wooden stairs going up to the right.",
        lambda: r(60, 150, 50, 30, "brown", 3) + r(110, 120, 50, 60, "brown", 3) + r(160, 90, 50, 90, "brown", 3) + r(210, 60, 50, 120, "brown", 3)),
    "statue": ("noun", ["art", "places"], "A stone statue on a plinth, one arm raised.",
        lambda: r(140, 150, 60, 22, "greyShade", 4) + r(152, 100, 36, 52, "grey", 6) + c(170, 80, 16, "grey") + s("M152 110L124 140", "grey", 8)),
    "stick": ("noun", ["nature"], "A long brown stick with a small branch.",
        lambda: ln(110, 170, 230, 50, "brown", 8) + ln(206, 84, 232, 74, "brown", 4) + e(110, 172, 12, 4, "greyShade")),
    "stone": ("noun", ["nature", "materials"], "Two smooth grey stones on the ground.",
        lambda: e(170, 140, 60, 30, "greyShade") + e(160, 132, 40, 14, "grey") + e(250, 160, 22, 12, "grey")),
    "storm": ("noun", ["weather"], "A grey storm cloud with a lightning bolt.",
        lambda: c(140, 76, 28, "greyShade") + c(186, 66, 32, "greyShade") + c(228, 84, 22, "greyShade") + r(118, 84, 132, 20, "greyShade", 10)
        + p("M180 110L150 150H172L160 180L200 136H178Z", "orange")),
    "swan": ("noun", ["animals", "nature"], "A white swan on a lake.",
        lambda: e(170, 130, 70, 28, "cream") + s("M200 120Q215 80 200 56", "cream", 12) + c(200, 50, 12, "cream") + p("M206 50L220 56L206 60Z", "orange") + e(170, 164, 140, 10, "teal")),
    "tap": ("noun", ["home", "objects"], "A metal tap with a spout over a sink.",
        lambda: r(150, 60, 40, 40, "grey", 6) + ln(190, 76, 230, 76, "grey", 10) + r(150, 100, 40, 8, "grey", 3) + e(170, 160, 70, 12, "greyShade")),
    "tie": ("noun", ["clothes"], "A teal tie with a knot at the collar.",
        lambda: p("M146 50L194 50L184 90L170 84L156 90Z", "teal") + p("M158 90L182 90L192 166L170 180L148 166Z", "teal") + ln(170, 96, 170, 166, "deepTeal", 2)),
    "tiger": ("noun", ["animals"], "An orange tiger with black stripes.",
        lambda: e(170, 120, 60, 34, "orange") + c(120, 92, 28, "orange") + c(102, 70, 8, "orange") + c(138, 70, 8, "orange")
        + ln(150, 98, 150, 126, "ink", 4) + ln(176, 98, 176, 126, "ink", 4) + ln(200, 100, 200, 122, "ink", 4)
        + c(112, 88, 3, "ink") + c(128, 88, 3, "ink") + c(120, 100, 3, "brown") + r(144, 144, 10, 28, "orange") + r(186, 144, 10, 28, "orange") + ground(60, 280)),
    "tower": ("noun", ["buildings", "places"], "A tall grey tower with battlements and a window.",
        lambda: r(136, 60, 68, 120, "grey", 6) + r(132, 44, 16, 16, "grey", 2) + r(152, 44, 16, 16, "grey", 2) + r(172, 44, 16, 16, "grey", 2) + r(192, 44, 16, 16, "grey", 2)
        + r(160, 100, 20, 26, "ink", 4) + ground(80, 260)),
    "tractor": ("noun", ["transport", "work"], "A green tractor with two large wheels.",
        lambda: r(110, 110, 110, 44, "green", 8) + r(150, 80, 60, 36, "green", 6) + c(138, 160, 20, "ink") + c(138, 160, 8, "grey") + c(230, 164, 14, "ink") + ground(60, 280)),
    "trunk": ("noun", ["nature"], "A brown tree trunk with a leafy green crown.",
        lambda: r(150, 90, 40, 90, "brown", 6) + c(170, 70, 40, "green") + c(136, 96, 24, "green") + c(206, 96, 24, "green") + ground(80, 260)),
    "tunnel": ("noun", ["places", "transport"], "A dark tunnel through a grey hill.",
        lambda: p("M60 180L60 110Q170 30 280 110L280 180Z", "greyShade") + p("M120 180L120 120Q170 80 220 120L220 180Z", "ink") + ground(40, 300)),
    "turtle": ("noun", ["animals"], "A green turtle with a patterned shell.",
        lambda: e(170, 130, 62, 36, "green") + e(170, 130, 40, 22, "deepTeal") + c(246, 132, 14, "green") + r(128, 156, 14, 18, "green") + r(196, 156, 14, 18, "green") + ground(60, 280)),
    "valley": ("noun", ["nature", "geography"], "A green valley with a river and hills.",
        lambda: p("M40 180L120 80L180 150L230 60L300 180Z", "green") + p("M100 180Q170 150 240 180Z", "teal") + p("M120 80L140 110L110 130Z", "cream")),
    "vase": ("noun", ["home", "objects"], "An orange vase on a brown shelf.",
        lambda: p("M130 60L210 60L200 90Q240 120 220 160Q170 180 120 160Q100 120 140 90Z", "orange") + r(132, 50, 76, 12, "brown", 3) + r(116, 160, 108, 8, "brown", 3)),
    "violin": ("noun", ["music", "objects"], "An orange violin with a brown bow.",
        lambda: p("M170 60C200 60 200 90 186 104C210 116 220 150 196 170C180 182 160 182 144 170C120 150 130 116 154 104C140 90 140 60 170 60Z", "orange")
        + r(166, 30, 8, 40, "brown", 2) + ln(170, 62, 170, 172, "brown", 3) + ln(230, 50, 190, 170, "brown", 2)),
    "wallet": ("noun", ["clothes", "objects"], "A brown wallet with an orange clasp.",
        lambda: r(90, 90, 160, 80, "brown", 12) + r(206, 116, 50, 30, "orange", 10) + c(232, 130, 4, "cream")),
    "wave": ("noun", ["sea", "nature"], "Two teal waves rolling across the sea.",
        lambda: s("M40 120Q60 100 80 120Q100 140 120 120Q140 100 160 120Q180 140 200 120Q220 100 240 120Q260 140 280 120", "teal", 10)
        + s("M40 150Q60 130 80 150Q100 170 120 150Q140 130 160 150Q180 170 200 150Q220 130 240 150Q260 170 280 150", "deepTeal", 10) + ground(40, 280)),
    "whale": ("noun", ["animals", "sea"], "A teal whale with a tail over the water.",
        lambda: e(170, 120, 90, 40, "teal") + p("M260 120L300 90L296 130L300 150L260 130Z", "teal") + c(120, 112, 5, "ink") + r(40, 164, 260, 14, "deepTeal", 6)),
    "wheel": ("noun", ["transport", "objects"], "A black wheel with grey spokes.",
        lambda: wheel(170, 110, 50) + ln(170, 60, 170, 160, "grey", 3) + ln(120, 110, 220, 110, "grey", 3) + ground(60, 280)),
    "wing": ("noun", ["animals", "body"], "A cream bird wing with feather lines.",
        lambda: p("M80 130Q120 40 260 60Q220 90 200 140Q150 150 80 130Z", "cream") + ln(120, 110, 200, 84, "sandBorder", 2) + ln(140, 126, 210, 104, "sandBorder", 2)),
    "wolf": ("noun", ["animals"], "A grey wolf with pointed ears.",
        lambda: e(170, 130, 62, 30, "greyShade") + c(232, 104, 26, "grey") + p("M224 80L232 60L240 82Z", "grey") + p("M250 106L278 112L250 118Z", "greyShade") + c(238, 100, 3, "ink")
        + r(130, 150, 12, 30, "greyShade") + r(184, 150, 12, 30, "greyShade") + s("M110 130Q70 120 80 90", "grey", 8) + ground(60, 280)),
    "wood": ("noun", ["materials", "nature"], "Two stacked planks of brown wood.",
        lambda: r(80, 100, 180, 22, "brown", 4) + r(80, 126, 180, 22, "orange", 4) + ln(110, 111, 230, 111, "skinShade", 2) + ln(120, 137, 240, 137, "skinShade", 2)),
    "wool": ("noun", ["materials"], "A ball of cream wool with teal yarn.",
        lambda: c(170, 120, 50, "cream") + s("M130 100Q170 140 210 100", "teal", 3) + s("M124 130Q170 90 216 130", "teal", 3) + s("M140 150Q170 110 200 150", "teal", 3)),
    "zoo": ("noun", ["places", "animals"], "A zoo entrance gate with an orange animal inside.",
        lambda: r(70, 60, 12, 120, "brown", 3) + r(258, 60, 12, 120, "brown", 3) + p("M70 60L170 30L270 60Z", "orange") + e(170, 144, 40, 18, "orange") + c(200, 130, 11, "orange") + ground(50, 290)),
}

if __name__ == "__main__":
    main(WORDS)
