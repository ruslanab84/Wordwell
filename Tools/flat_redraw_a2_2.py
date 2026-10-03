#!/usr/bin/env python3
"""Flat colour A2 batch 2: next 30 drawable Oxford 3000 A2 words in alphabetical order (blow .. coast).

Run: python3 Tools/flat_redraw_a2_2.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

from flat_redraw import c, e, eye, ground, ln, p, r, ring, s
from flat_redraw_b7 import P, heart, star
from flat_redraw_b8 import bowl, cloud, pine, steam
from flat_redraw_a2_1 import main

WORDS = {
    "blow": ("verb", ["actions"], "A face blowing air toward a candle, with smoke rising.",
        lambda: c(106, 100, 40, "skin") + e(100, 88, 4, 3, "ink") + c(142, 108, 7, "ink") + s("M160 96C190 88 200 100 214 94", "grey", 4) + s("M160 112C190 118 200 108 214 114", "grey", 4)
        + r(236, 108, 18, 64, "cream", 3) + p("M245 80C252 92 252 100 245 104C238 100 238 92 245 80Z", "orange") + ground(60, 290)),
    "board": ("noun", ["school"], "A classroom board with chalk writing and a ledge.",
        lambda: r(66, 36, 208, 114, "brown", 6) + r(78, 48, 184, 90, "deepTeal", 3) + s("M96 76H180", "cream", 4) + s("M96 96H220", "cream", 4) + s("M96 116H160", "cream", 4)
        + r(120, 150, 100, 8, "brown", 2) + r(146, 144, 24, 6, "cream", 2)),
    "boil": ("verb", ["cooking"], "A pot of bubbling water with steam on a flame.",
        lambda: r(106, 90, 128, 62, "grey", 8) + r(88, 98, 20, 8, "greyShade", 3) + r(232, 98, 20, 8, "greyShade", 3) + e(170, 92, 62, 8, "teal") + c(150, 90, 6, "cream") + c(176, 88, 7, "cream")
        + c(196, 92, 5, "cream") + steam(140, 64) + steam(176, 64) + steam(208, 64) + p("M134 176C140 160 150 160 154 150C160 160 166 168 170 160C178 166 192 170 202 176Z", "orange")),
    "bone": ("noun", ["body"], "A white bone with rounded ends.",
        lambda: r(96, 90, 148, 24, "cream", 8) + c(100, 88, 15, "cream") + c(100, 116, 15, "cream") + c(240, 88, 15, "cream") + c(240, 116, 15, "cream") + ln(120, 108, 220, 108, "grey", 3)),
    "borrow": ("verb", ["actions"], "One person handing a book to another to borrow it.",
        lambda: P(96, top="orange", hair="brown", arms="") + P(244, top="teal", hair="ink", arms="") + ln(118, 90, 154, 106, "orange", 6) + ln(222, 90, 186, 106, "teal", 6)
        + r(150, 94, 40, 28, "deepTeal", 3) + r(156, 100, 28, 6, "cream", 2) + ground(50, 290)),
    "boss": ("noun", ["jobs", "work"], "A person in a suit and tie leading two smaller people.",
        lambda: P(170, 0.9, top="deepTeal", hair="ink") + p("M158 92H182L170 104Z", "cream") + p("M170 104L165 114L170 134L175 114Z", "orange") + P(86, 0.6, top="teal", hair="brown") + P(254, 0.6, top="orange", hair="brown")
        + star(170, 32, 12, 5, "orange") + ground(50, 290)),
    "bottom": ("noun", ["position"], "A stack of three boxes with the lowest one highlighted and an arrow.",
        lambda: r(110, 134, 120, 40, "orange", 4) + r(124, 94, 92, 40, "teal", 4) + r(138, 54, 64, 40, "grey", 4) + ln(272, 60, 272, 124, "green", 10) + p("M272 160L254 132H290Z", "green")),
    "bowl": ("noun", ["kitchen", "food"], "A bowl of hot soup with steam.",
        lambda: bowl(170, 92, 70, 52, "teal") + e(170, 92, 70, 9, "orange") + steam(146, 74) + steam(176, 74) + steam(204, 74) + r(120, 160, 100, 10, "deepTeal", 4) + ground(80, 260)),
    "brain": ("noun", ["body"], "A pink brain with folds and a stem.",
        lambda: c(142, 100, 36, "earPink") + c(198, 100, 36, "earPink") + c(170, 78, 36, "earPink") + e(170, 118, 52, 28, "earPink") + r(160, 138, 20, 28, "skinShade", 6)
        + s("M170 54V104", "skinShade", 3) + s("M126 92C140 84 150 96 158 88", "skinShade", 3) + s("M182 88C192 96 202 84 216 92", "skinShade", 3) + s("M132 120C146 112 156 124 164 116", "skinShade", 3)),
    "bright": ("adjective", ["describing"], "A glowing light bulb with rays.",
        lambda: c(170, 86, 40, "orange") + e(160, 76, 8, 12, "cream", 20) + r(154, 122, 32, 24, "grey", 4) + ln(158, 134, 182, 134, "greyShade", 3) + r(160, 146, 20, 8, "greyShade", 3)
        + ln(170, 24, 170, 36, "orange", 5) + ln(112, 44, 122, 54, "orange", 5) + ln(228, 44, 218, 54, "orange", 5) + ln(98, 88, 110, 88, "orange", 5) + ln(242, 88, 230, 88, "orange", 5)),
    "broken": ("adjective", ["describing"], "A cup broken into two pieces with small shards.",
        lambda: p("M104 88H158L150 118L160 138L148 162H124C110 162 104 152 104 148Z", "teal") + p("M182 88H236V148C236 156 228 162 218 162H174L184 138L174 118Z", "teal")
        + p("M168 150L178 146L176 158Z", "teal") + p("M162 164L170 158L172 168Z", "teal") + ln(104, 96, 158, 96, "deepTeal", 4) + ln(182, 96, 236, 96, "deepTeal", 4) + ground()),
    "brush": ("noun", ["art", "tools"], "A paintbrush with orange paint and a paint stroke.",
        lambda: ln(96, 156, 192, 74, "brown", 12) + ln(192, 74, 212, 58, "grey", 16) + e(228, 48, 15, 9, "orange", -40) + s("M90 172C130 150 190 178 250 152", "teal", 10)),
    "burn": ("verb", ["actions"], "A burning match with a flame and smoke.",
        lambda: ln(112, 168, 200, 92, "brown", 8) + c(208, 84, 9, "skinShade") + p("M224 26C238 46 246 56 240 70C236 78 214 78 210 66C208 56 220 48 224 26Z", "orange") + e(224, 62, 6, 9, "cream")
        + s("M244 52C256 40 240 32 252 22", "grey", 3)),
    "businessman": ("noun", ["jobs", "work"], "A man in a suit with a tie and a briefcase.",
        lambda: P(150, top="deepTeal", hair="ink") + p("M138 80H162L150 94Z", "cream") + p("M150 94L145 104L150 124L155 104Z", "orange") + ln(172, 86, 200, 126, "deepTeal", 6)
        + r(190, 130, 54, 40, "brown", 5) + s("M206 130V122H228V130", "brown", 4) + ground(70, 280)),
    "button": ("noun", ["clothes"], "A round teal button with four holes and orange thread.",
        lambda: c(170, 100, 56, "teal") + ring(170, 100, 40, "deepTeal", "none", 4) + c(154, 86, 5, "cream") + c(186, 86, 5, "cream") + c(154, 114, 5, "cream") + c(186, 114, 5, "cream")
        + ln(154, 86, 186, 114, "orange", 3) + ln(186, 86, 154, 114, "orange", 3)),
    "camp": ("verb", ["travel", "outdoors"], "An orange tent beside a pine tree.",
        lambda: pine(82, 172, 84) + p("M110 172L184 66L258 172Z", "orange") + p("M184 106L160 172H208Z", "deepTeal") + ln(184, 66, 184, 46, "brown", 3) + ground(50, 290)),
    "carpet": ("noun", ["home"], "A patterned rug with fringe on a floor.",
        lambda: r(70, 90, 200, 70, "teal", 6) + r(82, 100, 176, 50, "deepTeal", 3) + p("M170 106L196 125L170 144L144 125Z", "orange") + c(110, 125, 8, "cream") + c(230, 125, 8, "cream")
        + ln(70, 98, 60, 98, "orange", 3) + ln(70, 112, 60, 112, "orange", 3) + ln(70, 138, 60, 138, "orange", 3) + ln(270, 98, 280, 98, "orange", 3) + ln(270, 112, 280, 112, "orange", 3)
        + ln(270, 138, 280, 138, "orange", 3) + ground(50, 290)),
    "cartoon": ("noun", ["media"], "A television showing a smiling cartoon character.",
        lambda: r(92, 46, 156, 104, "greyShade", 10) + r(104, 58, 132, 80, "orange", 4) + c(150, 82, 11, "cream") + c(190, 82, 11, "cream") + c(170, 108, 28, "cream")
        + eye(160, 104) + eye(180, 104) + s("M160 118C166 124 174 124 180 118", "ink", 3) + r(146, 150, 48, 10, "grey", 3) + r(124, 160, 92, 8, "grey", 3)),
    "cash": ("noun", ["money"], "Banknotes and a coin.",
        lambda: r(120, 58, 140, 70, "deepTeal", 6) + r(84, 92, 140, 70, "green", 6) + star(154, 127, 18, 8, "cream") + ln(100, 106, 120, 106, "cream", 4) + ln(188, 148, 208, 148, "cream", 4)
        + c(256, 152, 18, "orange") + ring(256, 152, 11, "skinShade", "none", 3)),
    "castle": ("noun", ["buildings", "history"], "A grey castle with two towers, a gate and a flag.",
        lambda: r(112, 96, 116, 80, "grey", 3) + r(86, 72, 38, 104, "greyShade", 3) + r(216, 72, 38, 104, "greyShade", 3) + p("M80 74L105 42L130 74Z", "teal") + p("M210 74L235 42L260 74Z", "teal")
        + r(154, 128, 32, 48, "brown", 14) + ln(235, 42, 235, 24, "brown", 3) + p("M235 24H256L246 31L256 38H235Z", "orange") + r(98, 92, 14, 18, "ink", 2) + r(228, 92, 14, 18, "ink", 2) + ground(60, 280)),
    "catch": ("verb", ["sport", "actions"], "A brown glove catching a ball.",
        lambda: e(170, 132, 58, 38, "brown") + r(116, 66, 22, 70, "brown", 10) + r(142, 54, 22, 80, "brown", 10) + r(168, 54, 22, 80, "brown", 10) + r(194, 64, 22, 72, "brown", 10)
        + ln(116, 140, 94, 112, "brown", 16) + c(170, 126, 20, "cream") + s("M158 114C164 122 164 130 158 138", "skinShade", 3) + s("M182 114C176 122 176 130 182 138", "skinShade", 3)),
    "celebrate": ("verb", ["events", "actions"], "A person with a party hat, balloons and confetti.",
        lambda: P(170, top="teal", hair="brown", base=172, arms="") + ln(148, 84, 128, 56, "teal", 6) + ln(192, 84, 212, 56, "teal", 6) + p("M158 40L170 18L182 40Z", "orange")
        + e(110, 40, 14, 18, "orange") + ln(110, 58, 124, 54, "grey", 2) + e(232, 40, 14, 18, "skinShade") + ln(232, 58, 218, 54, "grey", 2)
        + c(90, 110, 4, "orange") + c(250, 110, 4, "teal") + c(100, 150, 4, "skinShade") + c(244, 150, 4, "orange") + ground(70, 270)),
    "chef": ("noun", ["jobs", "food"], "A cook in a tall white hat beside a steaming pot.",
        lambda: P(130, 0.9, top="cream", bottom="deepTeal", hair="brown") + e(130, 56, 22, 14, "cream") + r(110, 58, 40, 12, "cream", 3) + r(200, 138, 56, 34, "grey", 5) + e(228, 138, 28, 5, "teal")
        + steam(214, 126) + steam(240, 126) + ground(60, 290)),
    "chemistry": ("noun", ["school", "science"], "A glass flask with green liquid and bubbles.",
        lambda: p("M150 44H190V92L224 152C228 162 222 168 212 168H128C118 168 112 162 116 152L150 92Z", "cream") + p("M134 122H206L224 152C228 162 222 168 212 168H128C118 168 112 162 116 152Z", "green")
        + r(144, 36, 52, 10, "grey", 3) + c(160, 142, 5, "cream") + c(182, 134, 4, "cream") + c(172, 154, 6, "cream") + c(166, 70, 4, "grey")),
    "chip": ("noun", ["food"], "Golden chips in a teal paper carton.",
        lambda: r(116, 48, 14, 70, "orange", 3) + r(136, 38, 14, 80, "orange", 3) + r(156, 50, 14, 68, "orange", 3) + r(176, 42, 14, 76, "orange", 3) + r(196, 52, 14, 66, "orange", 3)
        + p("M104 96H236L222 170H118Z", "teal") + r(120, 128, 100, 10, "cream")),
    "church": ("noun", ["buildings"], "A church with a tower, steeple and cross.",
        lambda: r(100, 104, 140, 72, "cream", 3) + p("M92 108L170 74L248 108Z", "brown") + r(150, 52, 40, 40, "cream", 2) + p("M146 54L170 30L194 54Z", "teal") + ln(170, 20, 170, 32, "orange", 4)
        + ln(163, 25, 177, 25, "orange", 4) + r(158, 136, 24, 40, "brown", 12) + c(124, 134, 8, "teal") + c(216, 134, 8, "teal") + ground(60, 280)),
    "circle": ("noun", ["shapes"], "A round teal circle with its centre and radius.",
        lambda: c(170, 102, 62, "teal") + ln(170, 102, 232, 102, "cream", 4) + c(170, 102, 5, "cream")),
    "cloud": ("noun", ["weather", "nature"], "Two fluffy clouds, one grey and one white.",
        lambda: cloud(206, 84, "greyShade") + cloud(142, 124, "cream")),
    "coach": ("noun", ["sport", "jobs"], "A sports coach with a clipboard and a whistle.",
        lambda: P(122, top="orange", bottom="deepTeal", hair="ink", arms="") + ln(144, 90, 176, 108, "orange", 6) + r(172, 76, 62, 76, "brown", 4) + r(180, 86, 46, 58, "cream", 2)
        + ln(188, 100, 218, 100, "ink", 3) + ln(188, 112, 218, 112, "ink", 3) + ln(188, 124, 206, 124, "ink", 3) + c(122, 94, 6, "grey") + c(240, 166, 14, "orange") + ground(60, 290)),
    "coast": ("noun", ["nature", "travel"], "A grassy cliff beside the sea.",
        lambda: r(40, 112, 260, 64, "teal", 6) + s("M190 130H230", "cream", 3) + s("M240 150H280", "cream", 3) + s("M200 160H240", "cream", 3) + p("M40 108C84 96 130 108 160 140C174 156 172 176 160 176H40Z", "skin")
        + p("M40 108C84 96 130 108 150 126L40 130Z", "green")),
}

if __name__ == "__main__":
    main(WORDS)
