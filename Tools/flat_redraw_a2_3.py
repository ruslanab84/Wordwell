#!/usr/bin/env python3
"""Flat colour A2 batch 3: next 30 drawable Oxford 3000 A2 words in alphabetical order (collect .. dream).

Run: python3 Tools/flat_redraw_a2_3.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import WORDS as BASE, c, e, eye, ground, ln, p, r, ring, s
from flat_redraw_b7 import P, heart, star, woman
from flat_redraw_b8 import cloud
from flat_redraw_a2_1 import main

WORDS = {
    "collect": ("verb", ["actions"], "A glass jar filling with coins, with one more coin dropping in.",
        lambda: r(118, 74, 104, 98, "cream", 10) + r(112, 62, 116, 14, "grey", 4) + c(146, 150, 12, "orange") + c(176, 152, 12, "orange") + c(204, 148, 12, "orange") + c(160, 130, 12, "orange")
        + c(192, 126, 12, "orange") + c(170, 36, 13, "orange") + ln(170, 52, 170, 58, "grey", 3) + ground(80, 260)),
    "column": ("noun", ["buildings", "history"], "A stone column with a top, grooves and a base.",
        lambda: r(110, 38, 120, 14, "cream", 3) + r(130, 52, 80, 100, "cream") + ln(150, 56, 150, 150, "grey", 3) + ln(170, 56, 170, 150, "grey", 3) + ln(190, 56, 190, 150, "grey", 3)
        + r(110, 152, 120, 14, "cream", 3) + r(94, 166, 152, 10, "grey", 2)),
    "comedy": ("noun", ["media", "theatre"], "A laughing theatre mask.",
        lambda: c(170, 100, 58, "orange") + s("M138 84Q148 72 160 84", "ink", 4) + s("M180 84Q192 72 202 84", "ink", 4) + p("M136 108H204C204 136 184 148 170 148C156 148 136 136 136 108Z", "ink")
        + r(150, 108, 40, 10, "cream", 2) + star(98, 56, 9, 4, "orange") + star(244, 56, 9, 4, "orange")),
    "compete": ("verb", ["sport", "actions"], "Two runners racing toward a finish tape.",
        lambda: P(90, 0.85, top="orange", hair="brown") + P(160, 0.85, top="teal", hair="ink") + r(246, 70, 6, 106, "brown", 2) + r(290, 70, 6, 106, "brown", 2) + ln(252, 120, 290, 120, "orange", 5)
        + ground(50, 300)),
    "complain": ("verb", ["communication"], "A person with a speech bubble showing a frown.",
        lambda: P(100, top="orange", hair="brown") + e(214, 66, 54, 34, "cream") + p("M170 86L156 112L190 96Z", "cream") + eye(198, 58) + eye(230, 58) + s("M196 82C206 70 222 70 232 82", "ink", 4) + ground(50, 290)),
    "connect": ("verb", ["technology"], "A plug about to join a socket, with a spark between.",
        lambda: s("M30 102H80", "ink", 6) + r(80, 86, 58, 32, "teal", 6) + r(138, 92, 22, 6, "grey", 2) + r(138, 106, 22, 6, "grey", 2) + r(194, 86, 58, 32, "orange", 6) + c(204, 95, 3, "ink") + c(204, 109, 3, "ink")
        + s("M252 102H310", "ink", 6) + star(176, 102, 12, 5, "orange")),
    "continent": ("noun", ["geography"], "A globe with green continents on blue-green sea.",
        lambda: c(170, 102, 66, "teal") + p("M126 72C146 58 172 68 168 90C164 110 138 122 132 100Z", "green") + p("M182 112C202 100 222 114 212 136C202 152 184 144 182 112Z", "green")
        + p("M196 62C208 58 216 66 210 76C204 82 192 72 196 62Z", "green")),
    "cooker": ("noun", ["kitchen", "home"], "A kitchen cooker with an oven door and hob.",
        lambda: r(104, 50, 132, 126, "grey", 6) + r(104, 50, 132, 16, "ink", 4) + e(138, 58, 16, 4, "greyShade") + e(202, 58, 16, 4, "greyShade") + c(130, 80, 5, "ink") + c(170, 80, 5, "ink") + c(210, 80, 5, "ink")
        + r(118, 98, 104, 66, "greyShade", 4) + r(130, 112, 80, 40, "ink", 3) + r(130, 100, 80, 5, "grey", 2)),
    "copy": ("noun", ["school", "work"], "Two sheets of paper, one a copy of the other, with an arrow.",
        lambda: r(96, 46, 88, 110, "grey", 4) + r(150, 66, 88, 110, "cream", 4) + ln(164, 88, 224, 88, "teal", 4) + ln(164, 104, 224, 104, "teal", 4) + ln(164, 120, 206, 120, "teal", 4)
        + ln(110, 70, 160, 70, "greyShade", 4) + ln(110, 86, 140, 86, "greyShade", 4) + ln(262, 100, 280, 100, "green", 8)),
    "corner": ("noun", ["home", "places"], "The corner of a room where two walls meet, marked with a dot.",
        lambda: p("M170 40L262 70V158L170 140Z", "skin") + p("M170 40L78 70V158L170 140Z", "skinShade") + ln(170, 40, 170, 140, "brown", 4) + p("M78 158L170 140L262 158L170 176Z", "brown")
        + c(170, 124, 9, "orange")),
    "count": ("verb", ["school", "numbers"], "Three cards showing one, two and three dots.",
        lambda: r(60, 56, 64, 90, "cream", 6) + c(92, 101, 9, "orange") + r(138, 56, 64, 90, "cream", 6) + c(158, 86, 9, "orange") + c(182, 116, 9, "orange") + r(216, 56, 64, 90, "cream", 6)
        + c(236, 76, 9, "orange") + c(248, 101, 9, "orange") + c(236, 126, 9, "orange") + ground(50, 290)),
    "couple": ("noun", ["people", "family"], "A man and a woman holding hands with a heart above.",
        lambda: P(130, top="teal", hair="ink", arms="") + woman(210, 1.0, "orange", "deepTeal") + ln(152, 90, 168, 112, "teal", 6) + ln(188, 90, 172, 112, "orange", 6) + c(170, 114, 6, "skin")
        + heart(170, 40, 14, "skinShade") + ground(70, 280)),
    "crazy": ("adjective", ["describing", "feelings"], "A wild face with spiral eyes and spiky hair.",
        lambda: p("M116 74L124 40L146 62L158 32L174 60L192 34L200 62L222 44L224 76Z", "brown") + c(170, 108, 52, "orange") + ring(150, 98, 10, "ink", "none", 3) + c(150, 98, 3, "ink")
        + ring(190, 98, 10, "ink", "none", 3) + c(190, 98, 3, "ink") + p("M146 124C156 148 184 148 194 124Z", "ink")),
    "crime": ("noun", ["law"], "A masked robber with a beanie and a bag of loot.",
        lambda: c(150, 110, 46, "skin") + p("M104 88C108 44 192 44 196 88Z", "ink") + r(104, 92, 92, 24, "ink", 8) + e(130, 104, 8, 5, "cream") + e(170, 104, 8, 5, "cream") + s("M136 134C144 140 158 140 166 134", "ink", 3)
        + e(256, 148, 30, 26, "orange") + r(248, 112, 16, 14, "orange", 4) + star(256, 148, 12, 5, "cream") + ground(60, 300)),
    "crowd": ("noun", ["people"], "A crowd of many people standing together.",
        lambda: "".join(r(x - 10, 128, 20, 42, col, 8) + c(x, 114, 11, "skin") for x, col in ((80, "teal"), (125, "orange"), (170, "deepTeal"), (215, "green"), (260, "teal")))
        + "".join(r(x - 10, 80, 20, 40, col, 8) + c(x, 66, 11, "skinShade") for x, col in ((102, "orange"), (148, "green"), (192, "teal"), (238, "orange")))),
    "cry": ("verb", ["feelings"], "A sad face with closed eyes and tears running down.",
        lambda: c(170, 100, 58, "orange") + s("M142 90Q152 100 162 90", "ink", 4) + s("M180 90Q190 100 200 90", "ink", 4) + s("M148 130C158 116 182 116 192 130", "ink", 5)
        + e(150, 116, 5, 12, "teal") + e(190, 124, 5, 12, "teal") + e(150, 148, 5, 10, "teal")),
    "cupboard": ("noun", ["home"], "A wooden cupboard with two doors and handles.",
        lambda: r(102, 38, 136, 128, "brown", 5) + r(110, 46, 58, 112, "skin", 3) + r(172, 46, 58, 112, "skin", 3) + c(158, 104, 4, "brown") + c(182, 104, 4, "brown") + r(112, 166, 14, 10, "brown") + r(214, 166, 14, 10, "brown")),
    "curly": ("adjective", ["describing", "appearance"], "A face framed by curly brown hair.",
        lambda: "".join(c(170 + dx, 100 + dy, 17, "brown") for dx, dy in ((-44, -4), (-38, -34), (-14, -50), (14, -50), (38, -34), (44, -4), (-48, 26), (48, 26))) + c(170, 110, 40, "skin")
        + eye(156, 106) + eye(184, 106) + s("M158 124C164 132 176 132 182 124", "ink", 3)),
    "cycle": ("verb", ["transport", "sport"], "A person riding a bicycle.",
        lambda: BASE["bicycle"]() + ln(144, 80, 186, 54, "orange", 14) + c(198, 42, 12, "skin") + ln(186, 58, 222, 70, "orange", 6) + ln(148, 84, 172, 128, "deepTeal", 9)),
    "danger": ("noun", ["signs"], "A triangular warning sign with an exclamation mark.",
        lambda: p("M170 20L254 166H86Z", "ink") + p("M170 40L238 158H102Z", "orange") + r(163, 78, 14, 46, "ink", 5) + c(170, 142, 7, "ink")),
    "dead": ("adjective", ["describing", "nature"], "A bare tree with no leaves and fallen leaves on the ground.",
        lambda: r(158, 92, 24, 84, "brown", 4) + s("M170 98L132 58", "brown", 9) + s("M170 108L214 66", "brown", 9) + s("M132 58L110 52", "brown", 6) + s("M214 66L236 62", "brown", 6)
        + e(110, 172, 12, 5, "orange") + e(236, 172, 12, 5, "skinShade") + ground(70, 270)),
    "dentist": ("noun", ["jobs", "health"], "A clean white tooth with a toothbrush.",
        lambda: p("M114 62C114 40 146 40 170 52C194 40 226 40 226 62C226 104 210 124 206 152C204 174 190 174 186 152C184 132 178 122 170 122C162 122 156 132 154 152C150 174 136 174 134 152C130 124 114 104 114 62Z", "cream")
        + ln(246, 160, 276, 116, "teal", 12) + ln(270, 124, 282, 110, "orange", 8) + star(90, 60, 10, 4, "orange")),
    "desert": ("noun", ["geography", "nature"], "Sand dunes with a cactus under a hot sun.",
        lambda: c(250, 56, 20, "orange") + p("M30 176C70 120 120 120 160 150C200 120 250 120 310 176Z", "skin") + p("M30 176C90 150 150 160 190 176Z", "skinShade") + r(98, 84, 16, 70, "green", 7)
        + s("M98 112H80V92", "green", 8) + s("M114 126H132V104", "green", 8)),
    "detective": ("noun", ["jobs", "law"], "A magnifying glass over a footprint.",
        lambda: ring(150, 94, 44, "brown", "cream", 9) + e(148, 92, 12, 18, "ink") + c(140, 68, 4, "ink") + c(150, 66, 4, "ink") + c(160, 68, 4, "ink") + ln(184, 128, 238, 168, "brown", 14)),
    "diary": ("noun", ["books", "writing"], "A closed diary with a clasp and a heart.",
        lambda: r(110, 38, 120, 134, "brown", 6) + r(110, 38, 16, 134, "deepTeal", 4) + r(222, 92, 18, 30, "orange", 4) + heart(172, 96, 20, "skinShade") + ln(142, 56, 210, 56, "cream", 3) + p("M200 172V180H208L216 176V172Z", "orange")),
    "digital": ("adjective", ["technology"], "A smartphone showing a pattern of digital bits.",
        lambda: r(126, 26, 88, 148, "ink", 14) + r(134, 42, 72, 112, "teal", 4) + r(144, 54, 14, 18, "cream", 2) + r(166, 54, 14, 18, "cream", 2) + r(188, 54, 8, 18, "cream", 2)
        + r(144, 82, 8, 18, "cream", 2) + r(160, 82, 14, 18, "cream", 2) + r(182, 82, 14, 18, "cream", 2) + r(144, 110, 14, 18, "orange", 2) + r(166, 110, 8, 18, "cream", 2) + c(170, 164, 5, "grey")),
    "document": ("noun", ["work", "writing"], "A sheet of paper with a folded corner, text lines and a clip.",
        lambda: p("M116 34H204L228 58V170H116Z", "cream") + p("M204 34V58H228Z", "grey") + ln(134, 82, 210, 82, "teal", 4) + ln(134, 100, 210, 100, "teal", 4) + ln(134, 118, 210, 118, "teal", 4)
        + ln(134, 136, 184, 136, "teal", 4) + s("M146 30V54", "orange", 5)),
    "download": ("verb", ["technology"], "A green arrow pointing down into a tray.",
        lambda: ln(170, 34, 170, 92, "green", 20) + p("M170 126L132 88H208Z", "green") + r(100, 150, 140, 14, "teal", 4) + r(100, 124, 14, 40, "teal", 3) + r(226, 124, 14, 40, "teal", 3)),
    "drama": ("noun", ["media", "theatre"], "Two theatre masks, one happy and one sad.",
        lambda: c(130, 96, 46, "orange") + s("M106 82Q114 72 124 82", "ink", 3) + s("M138 82Q148 72 156 82", "ink", 3) + s("M110 106C118 128 142 128 150 106", "ink", 4)
        + c(210, 112, 46, "teal") + s("M186 108Q194 98 204 108", "cream", 3) + s("M218 108Q228 98 236 108", "cream", 3) + s("M190 134C198 118 222 118 230 134", "cream", 4)),
    "dream": ("noun", ["sleep"], "A sleeping person with a dream cloud holding a star.",
        lambda: r(64, 140, 100, 36, "teal", 14) + c(100, 126, 22, "skin") + e(100, 114, 22, 10, "brown") + s("M90 128Q98 134 106 128", "ink", 3) + c(142, 112, 5, "cream") + c(158, 96, 8, "cream")
        + cloud(222, 72, "cream") + star(222, 64, 14, 6, "orange")),
}

if __name__ == "__main__":
    main(WORDS)
