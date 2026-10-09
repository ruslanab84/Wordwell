#!/usr/bin/env python3
"""Flat colour A2 batch 5: 30 A2 nouns in alphabetical order (grass .. ship).

Word list is memory-derived, not from the official Oxford 3000 file (unavailable here).
Run: python3 Tools/flat_redraw_a2_5.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import c, e, ground, ln, p, r, ring, s
from flat_redraw_a2_1 import main

WORDS = {
    "grass": ("noun", ["nature"], "Green grass blades growing on the ground.",
        lambda: p("M60 180L70 120L80 180Z", "green") + p("M96 180L110 104L122 180Z", "green") + p("M220 180L232 110L244 180Z", "green") + p("M256 180L270 128L282 180Z", "green") + r(40, 168, 260, 12, "green", 4)),
    "hammer": ("noun", ["tools"], "A hammer with a wooden handle.",
        lambda: r(164, 78, 12, 100, "brown", 4) + r(128, 52, 84, 34, "grey", 6) + r(116, 58, 16, 22, "greyShade", 4) + ground(80, 260)),
    "lake": ("noun", ["nature", "geography"], "A calm lake between green hills.",
        lambda: p("M30 120C80 60 130 74 170 104C210 74 260 60 310 120Z", "green") + e(170, 140, 116, 36, "teal") + e(170, 140, 74, 18, "deepTeal") + ground(30, 310)),
    "leather": ("noun", ["materials"], "A piece of brown leather with stitched seams.",
        lambda: r(100, 66, 140, 96, "brown", 12) + ln(100, 98, 240, 98, "orange", 3) + ln(128, 66, 128, 162, "orange", 2) + ln(212, 66, 212, 162, "orange", 2) + c(170, 130, 6, "sandBorder")),
    "lock": ("noun", ["home", "objects"], "A closed padlock with a round shackle.",
        lambda: ring(170, 92, 28, "grey", "none", 10) + r(120, 100, 100, 76, "grey", 10) + c(170, 132, 9, "ink") + r(167, 132, 6, 18, "ink", 2)),
    "mirror": ("noun", ["home", "objects"], "A wall mirror in a grey frame.",
        lambda: r(116, 40, 108, 128, "grey", 12) + r(130, 54, 80, 100, "teal", 6) + ln(150, 76, 176, 130, "cream", 4) + ln(180, 64, 196, 90, "cream", 3) + ground(80, 260)),
    "mud": ("noun", ["nature"], "A puddle of brown mud on the ground.",
        lambda: p("M40 166C90 136 250 136 300 166L300 180L40 180Z", "brown") + e(120, 164, 16, 5, "greyShade") + e(220, 172, 12, 4, "greyShade")),
    "net": ("noun", ["sport", "objects"], "A fishing net with a grid pattern.",
        lambda: r(60, 50, 220, 110, "cream", 6) + ln(60, 83, 280, 83, "brown", 2) + ln(60, 116, 280, 116, "brown", 2) + ln(108, 50, 108, 160, "brown", 2) + ln(170, 50, 170, 160, "brown", 2) + ln(232, 50, 232, 160, "brown", 2) + ln(60, 50, 280, 160, "brown", 2)),
    "oven": ("noun", ["home", "kitchen"], "A kitchen oven with a glass door.",
        lambda: r(90, 60, 160, 120, "grey", 12) + r(110, 100, 120, 60, "ink", 6) + c(120, 74, 6, "orange") + c(146, 74, 6, "orange") + r(104, 170, 132, 8, "greyShade", 3)),
    "palace": ("noun", ["buildings", "places"], "A large palace with an orange roof.",
        lambda: r(90, 100, 160, 80, "skin", 4) + p("M80 100L170 48L260 100Z", "orange") + r(150, 138, 40, 42, "brown", 4) + r(104, 116, 20, 24, "teal", 3) + r(216, 116, 20, 24, "teal", 3) + ground(60, 280)),
    "parrot": ("noun", ["animals"], "A green parrot with an orange head on a perch.",
        lambda: e(170, 110, 30, 44, "green") + c(176, 64, 24, "orange") + p("M194 62L214 72L194 80Z", "grey") + p("M150 140L130 176L152 170Z", "teal") + c(182, 60, 5, "ink") + r(90, 170, 160, 8, "brown", 3)),
    "pear": ("noun", ["food", "fruit"], "A green pear with a brown stem.",
        lambda: p("M170 40C150 40 140 60 150 90C130 110 120 150 150 165C170 175 190 175 200 165C230 150 220 110 190 90C200 60 190 40 170 40Z", "green") + ln(170, 40, 176, 20, "brown", 4) + ground(50, 290)),
    "pillow": ("noun", ["home"], "A soft cream pillow on a bed.",
        lambda: r(80, 110, 180, 60, "sandBorder", 24) + r(96, 122, 148, 36, "cream", 18) + ln(120, 140, 220, 140, "sandBorder", 2) + ground(60, 280)),
    "planet": ("noun", ["space", "science"], "An orange planet with a ring.",
        lambda: e(170, 100, 88, 18, "cream", -15) + c(170, 100, 50, "orange") + c(150, 84, 10, "brown") + c(190, 116, 7, "brown")),
    "pocket": ("noun", ["clothes"], "A teal shirt with a small pocket.",
        lambda: r(80, 60, 180, 120, "teal", 16) + r(120, 100, 100, 60, "deepTeal", 8) + c(170, 130, 4, "cream") + ln(120, 100, 220, 100, "cream", 2)),
    "pond": ("noun", ["nature"], "A small pond with lily pads.",
        lambda: e(170, 130, 120, 40, "teal") + e(170, 130, 70, 20, "deepTeal") + e(200, 126, 10, 4, "green") + e(140, 140, 8, 3, "green") + ground(40, 300)),
    "pot": ("noun", ["kitchen"], "A cooking pot with two handles.",
        lambda: r(100, 90, 140, 80, "grey", 14) + r(90, 80, 160, 14, "greyShade", 6) + ln(70, 96, 100, 96, "ink", 6) + ln(240, 96, 270, 96, "ink", 6) + ground(70, 270)),
    "purse": ("noun", ["clothes", "objects"], "An orange purse with a clasp.",
        lambda: r(90, 100, 160, 70, "orange", 16) + ring(170, 96, 30, "brown", "none", 6) + c(170, 136, 6, "brown")),
    "queen": ("noun", ["people", "royalty"], "A queen wearing a golden crown.",
        lambda: p("M110 130L110 80L140 105L170 60L200 105L230 80L230 130Z", "orange") + r(100, 130, 140, 20, "orange", 4) + c(170, 58, 6, "teal") + p("M130 150L120 180L220 180L210 150Z", "teal") + c(170, 118, 10, "skin")),
    "rabbit": ("noun", ["animals"], "A white rabbit with long ears.",
        lambda: e(170, 130, 50, 30, "cream") + c(190, 96, 22, "cream") + e(184, 56, 6, 22, "cream") + e(198, 56, 6, 22, "cream") + c(196, 92, 3, "ink") + ground(60, 280)),
    "rat": ("noun", ["animals"], "A grey rat with a long tail.",
        lambda: e(170, 130, 60, 26, "grey") + c(224, 118, 20, "grey") + c(236, 112, 6, "skinShade") + s("M110 130Q60 150 80 110", "greyShade", 4) + ground(60, 280)),
    "rock": ("noun", ["nature"], "A grey rock with a lighter top.",
        lambda: p("M70 170L100 90L170 60L240 100L270 170Z", "greyShade") + p("M100 90L170 60L240 100L170 120Z", "grey") + ground(50, 290)),
    "roof": ("noun", ["buildings", "home"], "A house with an orange roof.",
        lambda: p("M60 120L170 40L280 120Z", "orange") + r(90, 120, 160, 60, "skin", 4) + r(150, 140, 40, 40, "brown", 4) + ground(50, 290)),
    "ruler": ("noun", ["objects", "school"], "A wooden ruler with centimetre marks.",
        lambda: r(50, 110, 240, 36, "skin", 4) + "".join(ln(x, 110, x, 122, "brown", 2) for x in range(70, 290, 20))),
    "saw": ("noun", ["tools"], "A hand saw with a wooden handle.",
        lambda: p("M60 150L60 110L240 110L270 150Z", "grey") + p("M80 150L92 130L104 150Z", "grey") + p("M120 150L132 130L144 150Z", "grey") + r(230, 96, 40, 30, "brown", 6)),
    "scarf": ("noun", ["clothes"], "A long teal scarf wrapped around a neck.",
        lambda: s("M100 80Q170 120 240 80", "teal", 18) + s("M220 90L226 150", "teal", 14) + s("M232 92L238 150", "teal", 14)),
    "shelf": ("noun", ["home", "furniture"], "A wall shelf holding three books.",
        lambda: r(60, 118, 220, 10, "brown", 3) + r(80, 70, 20, 48, "teal", 2) + r(104, 80, 20, 38, "orange", 2) + r(128, 64, 18, 54, "green", 2) + ground(60, 280)),
    "shell": ("noun", ["nature", "sea"], "A cream seashell with ridges.",
        lambda: p("M90 150Q170 40 250 150Z", "cream") + ln(170, 150, 120, 60, "sandBorder", 3) + ln(170, 150, 170, 50, "sandBorder", 3) + ln(170, 150, 220, 60, "sandBorder", 3)),
    "shield": ("noun", ["objects", "history"], "A teal shield with a white stripe.",
        lambda: p("M120 50L220 50L220 110Q220 160 170 170Q120 160 120 110Z", "teal") + ln(170, 60, 170, 160, "cream", 4) + ln(130, 100, 210, 100, "cream", 4)),
    "ship": ("noun", ["transport", "sea"], "A sailing ship with an orange and cream sail.",
        lambda: p("M70 130L270 130L240 170L100 170Z", "brown") + ln(170, 130, 170, 50, "brown", 5) + p("M176 60L240 120L176 120Z", "cream") + p("M164 66L100 120L164 120Z", "orange") + r(40, 172, 260, 8, "teal", 3)),
}

if __name__ == "__main__":
    main(WORDS)
