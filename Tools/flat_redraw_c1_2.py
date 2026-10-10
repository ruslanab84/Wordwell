#!/usr/bin/env python3
"""Flat colour C1 batch 2: 100 C1 nouns, drawn alphabetically (abbey .. zither).

Word list is memory-derived, not from an official C1 list (Oxford 5000 by CEFR unavailable here).
Every entry is unverified: tag 'c1' marks it, the level is not confirmed.
Run: python3 Tools/flat_redraw_c1_2.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

import json

from flat_redraw import ASSETS, BINDINGS, FRAME, ROOT, c, e, ground, ln, p, r, ring, s

WORDS = {
    "abbey": ("noun", ["buildings"], "A stone abbey with a tall arched window.",
        lambda: r(96, 98, 148, 72, "grey", 2) + p("M150 98L170 54L190 98Z", "greyShade") + r(160, 40, 20, 20, "grey", 2)
        + r(162, 124, 16, 46, "deepTeal", 8) + r(124, 110, 14, 22, "cream", 6) + r(202, 110, 14, 22, "cream", 6) + ground(70, 270)),
    "albatross": ("noun", ["animals", "birds"], "A white albatross with long spread wings.",
        lambda: p("M170 104L60 76L100 118L170 118Z", "cream") + p("M170 104L280 76L240 118L170 118Z", "cream")
        + e(170, 124, 32, 22, "cream") + c(196, 100, 18, "cream") + p("M210 100L234 106L210 112Z", "orange") + c(202, 96, 3, "ink") + ground(90, 250)),
    "amphora": ("noun", ["objects"], "A clay amphora with two handles.",
        lambda: e(170, 116, 32, 46, "earPink") + s("M138 84Q118 100 128 124", "brown", 4) + s("M202 84Q222 100 212 124", "brown", 4)
        + r(150, 60, 40, 14, "brown", 3) + ground(100, 240)),
    "ampoule": ("noun", ["objects", "science"], "A small glass ampoule with liquid inside.",
        lambda: r(152, 56, 36, 10, "grey", 3) + p("M158 66H182L196 140Q198 152 186 154H154Q142 152 144 140Z", "cream")
        + p("M150 128H190L186 146Q184 152 170 152Q156 152 154 146Z", "teal")),
    "anteater": ("noun", ["animals"], "A long-snouted anteater with a bushy tail.",
        lambda: e(160, 120, 48, 26, "greyShade") + c(212, 110, 14, "greyShade") + ln(224, 110, 254, 118, "greyShade", 6)
        + s("M230 100Q262 96 264 130", "brown", 8) + r(124, 136, 8, 34, "greyShade", 3) + r(180, 136, 8, 34, "greyShade", 3) + ground(100, 250)),
    "aqueduct": ("noun", ["buildings", "water"], "A stone aqueduct carrying water on arches.",
        lambda: p("M60 100H280V118H60Z", "grey") + p("M80 118Q100 146 120 118Z", "greyShade") + p("M140 118Q160 146 180 118Z", "greyShade")
        + p("M200 118Q220 146 240 118Z", "greyShade") + r(58, 96, 224, 6, "greyShade", 2) + ground(50, 290)),
    "armadillo": ("noun", ["animals"], "A grey armadillo with banded armour.",
        lambda: e(168, 124, 48, 30, "greyShade") + ln(130, 110, 206, 110, "grey", 3) + ln(128, 124, 208, 124, "grey", 3)
        + c(216, 110, 18, "grey") + c(226, 104, 3, "ink") + r(136, 146, 8, 24, "greyShade", 3) + r(186, 146, 8, 24, "greyShade", 3) + ground(100, 240)),
    "bassoon": ("noun", ["instruments"], "A long wooden bassoon with a bent bell.",
        lambda: r(118, 60, 16, 110, "brown", 6) + r(134, 140, 30, 22, "orange", 8) + r(134, 64, 16, 8, "orange", 2)
        + c(126, 84, 3, "ink") + c(126, 110, 3, "ink") + ground(100, 240)),
    "beaker": ("noun", ["objects", "science"], "A glass beaker with blue liquid.",
        lambda: p("M120 60H220L206 160Q204 172 190 172H150Q136 172 134 160Z", "cream")
        + p("M128 120H212L206 160Q204 172 190 172H150Q136 172 134 160Z", "teal") + ground(90, 250)),
    "bobbin": ("noun", ["objects"], "A wooden bobbin with thread wound on it.",
        lambda: r(150, 70, 40, 16, "brown", 3) + r(164, 86, 12, 50, "brown", 3) + r(134, 136, 72, 22, "orange", 6)
        + r(150, 158, 40, 12, "brown", 3)),
    "bobcat": ("noun", ["animals"], "A spotted bobcat with tufted ears.",
        lambda: e(170, 124, 46, 26, "sandBorder") + c(212, 108, 22, "sandBorder") + p("M198 92L200 66L214 86Z", "brown")
        + p("M222 86L232 66L236 92Z", "brown") + c(204, 108, 3, "ink") + c(220, 108, 3, "ink") + c(150, 118, 4, "brown")
        + c(176, 122, 4, "brown") + r(140, 140, 8, 30, "brown", 3) + r(186, 140, 8, 30, "brown", 3) + ground(100, 250)),
    "buckle": ("noun", ["objects", "clothing"], "A metal buckle with a tongue.",
        lambda: ring(170, 112, 36, "grey", "none", 8) + r(156, 104, 28, 12, "orange", 3) + ln(170, 76, 170, 60, "grey", 4)),
    "cairn": ("noun", ["nature", "objects"], "A stacked pile of stones marking a path.",
        lambda: e(170, 160, 50, 14, "grey") + e(170, 134, 40, 14, "greyShade") + e(170, 110, 30, 12, "grey")
        + e(170, 88, 20, 10, "greyShade") + ground(90, 250)),
    "dingo": ("noun", ["animals"], "A sandy dingo with pointed ears.",
        lambda: e(170, 124, 50, 26, "sandBorder") + c(218, 104, 20, "sandBorder") + p("M204 86L208 60L220 84Z", "sandBorder")
        + p("M226 84L234 60L238 88Z", "sandBorder") + c(224, 100, 3, "ink") + r(140, 140, 8, 28, "sandBorder", 3)
        + r(184, 140, 8, 28, "sandBorder", 3) + ground(100, 250)),
    "capybara": ("noun", ["animals"], "A large brown capybara with a blunt snout.",
        lambda: e(170, 124, 60, 36, "brown") + c(236, 104, 24, "brown") + c(230, 96, 3, "ink")
        + r(132, 140, 10, 30, "brown", 3) + r(196, 140, 10, 30, "brown", 3) + ground(100, 250)),
    "cassowary": ("noun", ["animals", "birds"], "A cassowary with a blue head and a helmet.",
        lambda: e(160, 124, 46, 30, "greyShade") + ln(200, 110, 212, 70, "ink", 8) + c(214, 64, 12, "teal")
        + p("M224 62L240 66L224 72Z", "orange") + r(140, 146, 8, 26, "orange", 3) + r(176, 146, 8, 26, "orange", 3) + ground(100, 240)),
    "chinchilla": ("noun", ["animals"], "A grey chinchilla with round ears.",
        lambda: e(170, 122, 44, 34, "grey") + c(214, 96, 22, "grey") + p("M200 80L204 56L216 78Z", "greyShade")
        + p("M224 78L232 60L236 84Z", "greyShade") + c(222, 94, 3, "ink") + r(138, 146, 10, 22, "greyShade", 3)
        + r(186, 146, 10, 22, "greyShade", 3) + ground(100, 240)),
    "citadel": ("noun", ["buildings"], "A hilltop citadel with a tall keep.",
        lambda: r(110, 92, 120, 78, "grey", 2) + p("M104 92L170 52L236 92Z", "greyShade") + r(156, 130, 28, 40, "deepTeal", 10)
        + r(126, 70, 16, 22, "grey", 2) + r(198, 70, 16, 22, "grey", 2) + ground(70, 270)),
    "clasp": ("noun", ["objects", "clothing"], "A gold clasp with a round stone.",
        lambda: c(170, 110, 40, "orange") + c(170, 110, 20, "halo") + ln(170, 70, 170, 150, "brown", 4)),
    "cogwheel": ("noun", ["machines"], "A grey cogwheel with teeth.",
        lambda: c(170, 100, 44, "grey") + c(170, 100, 22, "greyShade") + r(160, 50, 20, 20, "grey", 3)
        + r(160, 130, 20, 20, "grey", 3) + r(120, 90, 20, 20, "grey", 3) + r(200, 90, 20, 20, "grey", 3) + c(170, 100, 8, "cream")),
    "condor": ("noun", ["animals", "birds"], "A dark condor with spread wings.",
        lambda: p("M170 96L60 84L110 116L170 116Z", "ink") + p("M170 96L280 84L230 116L170 116Z", "ink")
        + e(170, 120, 30, 22, "ink") + c(194, 104, 16, "ink") + p("M208 102L226 108L208 112Z", "orange") + ground(100, 240)),
    "cormorant": ("noun", ["animals", "birds"], "A dark cormorant with a long neck.",
        lambda: e(160, 126, 44, 22, "deepTeal") + s("M196 118Q226 96 210 62", "deepTeal", 8) + c(206, 58, 10, "deepTeal")
        + p("M214 58L232 62L214 66Z", "orange") + ground(100, 240)),
    "cornet": ("noun", ["instruments"], "A brass cornet with three valves.",
        lambda: r(104, 104, 110, 12, "orange", 4) + e(224, 110, 22, 18, "orange") + r(136, 116, 10, 22, "orange", 3)
        + c(118, 116, 8, "halo") + ln(150, 96, 150, 104, "greyShade", 3) + ln(170, 96, 170, 104, "greyShade", 3)),
    "coyote": ("noun", ["animals"], "A grey-brown coyote with pointed ears.",
        lambda: e(170, 124, 46, 26, "sandBorder") + c(214, 102, 22, "sandBorder") + p("M202 84L206 58L218 80Z", "brown")
        + p("M226 80L234 58L238 86Z", "brown") + p("M236 100L262 116L238 112Z", "grey") + c(222, 100, 3, "ink")
        + r(138, 140, 10, 28, "brown", 3) + r(186, 140, 10, 28, "brown", 3) + ground(100, 250)),
    "crucible": ("noun", ["objects", "science"], "A grey crucible glowing with heat.",
        lambda: p("M130 96H210L196 160Q194 170 184 170H156Q146 170 144 160Z", "grey") + r(124, 88, 92, 12, "greyShade", 3)
        + e(170, 118, 28, 6, "orange") + ground(100, 240)),
    "dulcimer": ("noun", ["instruments"], "A wooden dulcimer with strings across it.",
        lambda: p("M96 112L220 80L244 136L120 168Z", "brown") + p("M120 128L210 104L220 128L130 152Z", "orange")
        + ln(140, 116, 200, 100, "cream", 2) + ln(140, 132, 200, 116, "cream", 2)),
    "decanter": ("noun", ["objects"], "A glass decanter of red wine.",
        lambda: p("M140 98H200L212 140Q214 170 170 170Q126 170 128 140Z", "teal") + r(158, 68, 24, 34, "teal", 6)
        + r(152, 58, 36, 12, "brown", 4) + r(136, 122, 68, 8, "cream", 2)),
    "delta": ("noun", ["nature", "water"], "A river delta fanning out into the sea.",
        lambda: p("M170 60L96 150H244Z", "teal") + ln(170, 40, 170, 110, "deepTeal", 4)
        + ln(170, 110, 120, 150, "deepTeal", 3) + ln(170, 110, 220, 150, "deepTeal", 3) + ground(60, 280)),
    "dowel": ("noun", ["objects", "tools"], "A round wooden dowel peg.",
        lambda: r(120, 112, 100, 14, "brown", 7) + r(120, 112, 14, 14, "halo", 7)
        + ln(144, 119, 200, 119, "sandBorder", 2) + ln(152, 124, 194, 124, "sandBorder", 2)),
    "dungeon": ("noun", ["buildings"], "A stone dungeon with barred windows.",
        lambda: r(96, 86, 148, 94, "grey", 4) + r(120, 100, 28, 40, "ink", 12) + r(170, 100, 28, 40, "ink", 12)
        + ln(134, 100, 134, 140, "cream", 2) + ln(184, 100, 184, 140, "cream", 2) + ground(80, 260)),
    "elk": ("noun", ["animals"], "A brown elk with large antlers.",
        lambda: e(170, 124, 52, 28, "brown") + c(218, 96, 20, "brown") + ln(212, 76, 206, 40, "ink", 4)
        + ln(206, 40, 240, 30, "ink", 4) + ln(200, 46, 186, 28, "ink", 4) + r(138, 140, 8, 30, "brown", 3)
        + r(186, 140, 8, 30, "brown", 3) + ground(100, 250)),
    "ember": ("noun", ["nature"], "A glowing orange ember with a hot core.",
        lambda: c(170, 130, 30, "orange") + c(170, 130, 16, "halo") + p("M170 60L186 96L160 96Z", "orange")
        + p("M120 120L132 96L140 124Z", "orange") + ground(110, 230)),
    "estuary": ("noun", ["nature", "water"], "A wide estuary where a river meets the sea.",
        lambda: p("M140 30H170Q176 80 200 110Q226 150 280 170V180H60V170Q120 160 140 120Q150 80 140 30Z", "teal")
        + p("M110 150Q150 140 190 150Q230 160 260 176", "deepTeal") + s("M80 120Q110 110 130 124", "sandBorder", 3)),
    "ewer": ("noun", ["objects"], "A brass ewer with a wide spout.",
        lambda: p("M130 84H210L200 160H140Z", "orange") + s("M210 96Q246 110 220 140", "orange", 6)
        + p("M140 84L150 64H190L200 84Z", "halo") + ground(100, 240)),
    "ferret": ("noun", ["animals"], "A cream ferret with a long body.",
        lambda: e(170, 124, 58, 18, "cream") + c(232, 112, 16, "cream") + c(240, 108, 3, "ink")
        + p("M230 98L238 84L244 102Z", "earPink") + s("M120 124Q96 130 84 146", "greyShade", 6)
        + r(146, 138, 8, 24, "skinShade", 3) + r(180, 138, 8, 24, "skinShade", 3) + ground(70, 270)),
    "figurine": ("noun", ["objects", "art"], "A small ceramic figurine.",
        lambda: c(170, 70, 12, "halo") + p("M154 84H186L192 130H148Z", "halo") + r(146, 130, 48, 14, "brown", 3)),
    "flagon": ("noun", ["objects"], "A brown flagon with a hinged lid.",
        lambda: p("M136 80H200L208 164H128Z", "brown") + r(132, 68, 72, 14, "greyShade", 4)
        + s("M204 96Q236 104 220 140", "brown", 6) + ground(100, 240)),
    "gatehouse": ("noun", ["buildings"], "A grey gatehouse with a wide arch.",
        lambda: r(112, 84, 116, 76, "grey", 2) + r(146, 110, 48, 50, "ink", 12) + r(106, 70, 28, 24, "greyShade", 2)
        + r(206, 70, 28, 24, "greyShade", 2) + ground(70, 270)),
    "gibbon": ("noun", ["animals"], "A brown gibbon with long arms.",
        lambda: c(170, 72, 22, "brown") + e(170, 116, 28, 34, "brown") + s("M142 110Q110 130 100 156", "brown", 8)
        + s("M198 110Q230 130 240 156", "brown", 8) + c(162, 68, 3, "ink") + c(178, 68, 3, "ink") + ground(100, 240)),
    "gong": ("noun", ["instruments"], "A round bronze gong on a frame.",
        lambda: c(170, 108, 46, "orange") + c(170, 108, 22, "halo") + ln(170, 40, 170, 64, "brown", 3)
        + ln(130, 40, 210, 40, "brown", 4)),
    "gorge": ("noun", ["nature"], "A steep gorge with a river at the bottom.",
        lambda: p("M60 60H120L140 150H60Z", "skinShade") + p("M280 60H220L200 150H280Z", "skinShade")
        + p("M120 60L140 150L200 150L220 60Z", "halo") + s("M150 150Q170 136 190 150", "teal", 4)),
    "harmonica": ("noun", ["instruments"], "A small harmonica with metal reeds.",
        lambda: r(104, 108, 132, 36, "greyShade", 6) + r(114, 116, 116, 20, "cream", 3)
        + ln(132, 116, 132, 136, "ink", 2) + ln(170, 116, 170, 136, "ink", 2) + ln(208, 116, 208, 136, "ink", 2)),
    "hyena": ("noun", ["animals"], "A spotted hyena with a sloping back.",
        lambda: e(170, 124, 52, 28, "sandBorder") + c(218, 104, 22, "sandBorder") + p("M200 86L206 62L216 84Z", "brown")
        + c(226, 100, 3, "ink") + r(140, 140, 8, 30, "brown", 3) + r(180, 140, 8, 30, "brown", 3)
        + r(124, 108, 8, 40, "brown", 3) + ground(100, 250)),
    "kestrel": ("noun", ["animals", "birds"], "A small kestrel with spread wings.",
        lambda: p("M170 110L100 90L130 120Z", "brown") + p("M170 110L240 90L210 120Z", "brown")
        + e(170, 120, 24, 28, "sandBorder") + c(170, 94, 16, "sandBorder") + p("M182 92L196 98L182 102Z", "orange")
        + c(164, 90, 3, "ink") + ground(110, 230)),
    "lattice": ("noun", ["objects", "architecture"], "A wooden lattice screen.",
        lambda: r(100, 60, 140, 110, "cream", 2) + ln(100, 94, 240, 94, "brown", 3) + ln(100, 128, 240, 128, "brown", 3)
        + ln(134, 60, 134, 170, "brown", 3) + ln(170, 60, 170, 170, "brown", 3) + ln(206, 60, 206, 170, "brown", 3)),
    "lemur": ("noun", ["animals"], "A grey lemur with a striped tail.",
        lambda: e(170, 124, 36, 26, "greyShade") + c(200, 96, 18, "greyShade") + c(194, 94, 3, "ink") + c(206, 94, 3, "ink")
        + s("M136 130Q90 110 100 74", "ink", 6) + ground(100, 240)),
    "lute": ("noun", ["instruments"], "A round-backed lute with a long neck.",
        lambda: e(170, 134, 42, 34, "orange") + c(170, 110, 20, "orange") + c(170, 128, 10, "brown")
        + r(164, 64, 12, 58, "brown", 3) + r(156, 54, 28, 14, "brown", 3)),
    "magpie": ("noun", ["animals", "birds"], "A black and white magpie with a long tail.",
        lambda: e(160, 120, 40, 26, "ink") + c(200, 98, 18, "ink") + p("M210 92L240 98L212 104Z", "orange")
        + p("M120 116L80 104L110 130Z", "ink") + c(204, 94, 3, "cream") + ground(100, 240)),
    "mandolin": ("noun", ["instruments"], "A round-bodied mandolin with a short neck.",
        lambda: c(170, 126, 40, "orange") + c(170, 126, 14, "ink") + r(164, 60, 12, 66, "brown", 3)
        + r(150, 52, 40, 12, "brown", 3)),
    "manatee": ("noun", ["animals", "water"], "A grey manatee with a paddle tail.",
        lambda: e(170, 124, 60, 30, "grey") + c(232, 118, 14, "grey") + p("M130 118L104 130L120 138Z", "greyShade")
        + c(230, 110, 3, "ink") + ground(90, 250)),
    "mantelpiece": ("noun", ["architecture", "home"], "A wooden mantelpiece with a small clock.",
        lambda: r(90, 96, 160, 14, "brown", 3) + r(106, 110, 12, 62, "brown", 3) + r(222, 110, 12, 62, "brown", 3)
        + r(126, 64, 28, 32, "halo", 3) + c(140, 80, 6, "orange")),
    "marmot": ("noun", ["animals"], "A brown marmot sitting upright.",
        lambda: e(170, 124, 46, 30, "brown") + c(214, 108, 20, "brown") + c(222, 102, 3, "ink")
        + r(140, 144, 12, 26, "greyShade", 3) + r(180, 144, 12, 26, "greyShade", 3) + ground(100, 250)),
    "meerkat": ("noun", ["animals"], "A meerkat standing upright on its hind legs.",
        lambda: e(170, 128, 24, 40, "sandBorder") + c(170, 84, 18, "sandBorder") + c(164, 82, 3, "ink")
        + c(176, 82, 3, "ink") + ground(120, 220)),
    "mill": ("noun", ["buildings"], "A windmill with four sails.",
        lambda: p("M140 150L160 70H180L200 150Z", "cream") + p("M170 70L150 40L190 40Z", "teal")
        + ln(170, 70, 100, 40, "brown", 4) + ln(170, 70, 240, 40, "brown", 4) + ln(170, 70, 170, 24, "brown", 4)
        + r(166, 62, 8, 8, "orange", 2) + ground(100, 240)),
    "mink": ("noun", ["animals"], "A dark brown mink with a sleek coat.",
        lambda: e(170, 126, 50, 20, "greyShade") + c(218, 112, 16, "greyShade") + c(224, 108, 3, "ink")
        + s("M120 124Q96 126 84 140", "greyShade", 6) + r(142, 138, 8, 22, "greyShade", 3)
        + r(184, 138, 8, 22, "greyShade", 3) + ground(90, 250)),
    "minaret": ("noun", ["buildings"], "A slender minaret with a pointed top.",
        lambda: r(146, 80, 48, 92, "cream", 2) + p("M146 80L170 30L194 80Z", "teal") + r(154, 110, 32, 20, "deepTeal", 6)
        + ln(170, 30, 170, 20, "orange", 3) + r(132, 164, 76, 8, "greyShade", 2)),
    "mortar": ("noun", ["objects", "kitchen"], "A stone mortar with a wooden pestle.",
        lambda: p("M120 110H220L204 162Q200 170 190 170H150Q140 170 136 162Z", "grey") + ln(190, 86, 160, 130, "brown", 6)
        + r(112, 104, 116, 8, "greyShade", 3)),
    "newt": ("noun", ["animals"], "A spotted newt with a long tail.",
        lambda: e(170, 126, 46, 22, "skin") + c(214, 110, 18, "skin") + c(220, 106, 3, "ink")
        + s("M120 122Q96 116 80 124", "skinShade", 4) + r(146, 144, 8, 20, "skinShade", 3)
        + r(182, 144, 8, 20, "skinShade", 3) + ground(90, 250)),
    "observatory": ("noun", ["buildings", "science"], "A stone observatory with a domed roof.",
        lambda: r(106, 112, 128, 58, "grey", 2) + p("M116 112Q170 42 224 112Z", "teal") + ln(170, 58, 230, 32, "orange", 4)
        + r(158, 130, 24, 40, "deepTeal", 10) + ground(80, 260)),
    "ocarina": ("noun", ["instruments"], "A clay ocarina with finger holes.",
        lambda: e(170, 124, 50, 34, "brown") + c(150, 118, 5, "cream") + c(170, 112, 5, "cream") + c(190, 118, 5, "cream")
        + r(196, 100, 20, 12, "orange", 3)),
    "ocelot": ("noun", ["animals"], "A spotted ocelot with a sleek coat.",
        lambda: e(170, 124, 50, 26, "orange") + c(218, 104, 20, "orange") + p("M204 86L208 62L220 84Z", "orange")
        + p("M226 84L234 62L236 88Z", "orange") + c(146, 118, 4, "ink") + c(170, 126, 4, "ink") + c(194, 118, 4, "ink")
        + c(214, 104, 3, "ink") + r(140, 140, 8, 28, "orange", 3) + r(186, 140, 8, 28, "orange", 3) + ground(100, 250)),
    "oboe": ("noun", ["instruments"], "A slender wooden oboe with a flared bell.",
        lambda: r(116, 98, 110, 10, "brown", 4) + c(116, 103, 8, "brown") + r(112, 88, 22, 8, "halo", 2)
        + c(230, 102, 10, "orange")),
    "opossum": ("noun", ["animals"], "A grey opossum with a long tail.",
        lambda: e(170, 122, 46, 28, "grey") + c(214, 108, 20, "grey") + c(222, 104, 3, "ink")
        + s("M130 136Q100 150 84 128", "earPink", 6) + r(144, 140, 8, 24, "greyShade", 3)
        + r(184, 140, 8, 24, "greyShade", 3) + ground(100, 250)),
    "orca": ("noun", ["animals", "water"], "A black and white orca with a tall fin.",
        lambda: e(170, 116, 64, 34, "ink") + p("M160 90L178 56L192 94Z", "ink") + e(200, 134, 28, 12, "cream")
        + c(206, 104, 3, "cream") + ground(60, 280)),
    "osprey": ("noun", ["animals", "birds"], "A brown and white osprey hunting fish.",
        lambda: e(170, 120, 30, 36, "cream") + c(170, 84, 18, "brown") + p("M170 100L100 80L120 120Z", "brown")
        + p("M170 100L240 80L220 120Z", "brown") + p("M186 84L200 88L186 92Z", "orange") + c(164, 80, 3, "ink") + ground(100, 240)),
    "padlock": ("noun", ["objects"], "A brass padlock with a steel shackle.",
        lambda: r(128, 108, 84, 58, "orange", 6) + s("M140 108Q140 60 170 60Q200 60 200 108", "greyShade", 8)
        + c(170, 134, 8, "ink")),
    "pangolin": ("noun", ["animals"], "A pangolin covered in overlapping scales.",
        lambda: e(170, 122, 50, 32, "greyShade") + p("M128 118Q170 96 214 118Q210 148 170 150Q132 150 128 118Z", "brown")
        + c(230, 106, 16, "greyShade") + s("M120 126Q90 130 80 152", "brown", 6) + ground(90, 250)),
    "panther": ("noun", ["animals"], "A black panther with a long tail.",
        lambda: e(170, 122, 50, 26, "ink") + c(218, 100, 20, "ink") + p("M204 82L210 60L220 80Z", "ink")
        + p("M226 80L234 62L238 86Z", "ink") + c(226, 96, 3, "cream") + s("M120 120Q92 110 82 130", "ink", 6)
        + r(142, 140, 8, 28, "ink", 3) + r(184, 140, 8, 28, "ink", 3) + ground(70, 270)),
    "pavilion": ("noun", ["buildings"], "A garden pavilion with a pointed roof.",
        lambda: r(120, 110, 100, 60, "cream", 2) + p("M106 110L170 64L234 110Z", "teal") + r(150, 132, 40, 38, "brown", 4)
        + ground(90, 250)),
    "pestle": ("noun", ["objects", "kitchen"], "A wooden pestle beside a stone mortar.",
        lambda: p("M116 110H224L210 150Q206 160 196 160H144Q134 160 130 150Z", "grey") + ln(200, 66, 164, 120, "brown", 8)
        + c(200, 66, 8, "brown")),
    "pheasant": ("noun", ["animals", "birds"], "A colourful pheasant with a long tail.",
        lambda: e(170, 124, 44, 26, "orange") + c(206, 100, 16, "teal") + p("M220 102L256 90L236 116Z", "brown")
        + p("M186 104L210 100L196 118Z", "deepTeal") + c(210, 96, 3, "ink") + r(146, 144, 6, 22, "brown", 2) + ground(100, 240)),
    "pitcher": ("noun", ["objects", "kitchen"], "A teal pitcher with a handle.",
        lambda: p("M132 96H200L192 166H140Z", "teal") + s("M200 108Q230 116 214 142", "teal", 6)
        + r(130, 84, 74, 12, "deepTeal", 3) + ground(100, 240)),
    "platypus": ("noun", ["animals", "water"], "A brown platypus with a duck-like bill.",
        lambda: e(170, 124, 48, 28, "brown") + p("M218 116Q252 118 254 136Q240 146 218 136Z", "orange")
        + c(214, 102, 20, "brown") + c(222, 98, 3, "ink") + s("M130 130Q104 150 118 160", "brown", 6) + ground(100, 250)),
    "plateau": ("noun", ["nature"], "A flat-topped plateau with steep sides.",
        lambda: p("M60 150H96L120 80H240L264 150H300V176H60Z", "sandBorder") + r(120, 80, 120, 8, "brown", 2)
        + e(150, 84, 10, 4, "green") + e(200, 84, 8, 4, "green")),
    "plinth": ("noun", ["architecture"], "A stone plinth holding a bust.",
        lambda: r(120, 140, 100, 22, "grey", 2) + r(132, 110, 76, 30, "greyShade", 2) + c(170, 92, 22, "cream")),
    "quail": ("noun", ["animals", "birds"], "A small brown quail.",
        lambda: e(170, 124, 46, 26, "sandBorder") + c(212, 104, 18, "sandBorder") + p("M204 92L212 74L220 94Z", "brown")
        + c(218, 100, 3, "ink") + r(142, 140, 6, 22, "brown", 2) + r(180, 140, 6, 22, "brown", 2) + ground(100, 240)),
    "rampart": ("noun", ["buildings"], "A stone rampart along the top of a wall.",
        lambda: r(80, 110, 180, 54, "grey", 2) + r(80, 96, 24, 16, "greyShade", 2) + r(124, 96, 24, 16, "greyShade", 2)
        + r(168, 96, 24, 16, "greyShade", 2) + r(212, 96, 24, 16, "greyShade", 2) + ground(60, 280)),
    "reindeer": ("noun", ["animals"], "A reindeer with branching antlers.",
        lambda: e(170, 124, 46, 26, "brown") + c(214, 100, 18, "brown") + ln(204, 84, 196, 52, "ink", 3)
        + ln(196, 52, 176, 44, "ink", 3) + ln(196, 52, 212, 40, "ink", 3) + ln(212, 84, 226, 50, "ink", 3)
        + r(142, 140, 8, 26, "brown", 3) + r(184, 140, 8, 26, "brown", 3) + ground(100, 250)),
    "scabbard": ("noun", ["objects", "weapons"], "A brown leather scabbard for a blade.",
        lambda: p("M124 66H146L214 166Q218 176 206 176H196Q186 176 182 168Z", "brown")
        + r(118, 58, 30, 12, "sandBorder", 3) + ln(160, 100, 190, 120, "sandBorder", 2) + ln(150, 130, 180, 146, "sandBorder", 2)),
    "scaffold": ("noun", ["buildings"], "A wooden scaffold beside a building.",
        lambda: r(90, 80, 8, 100, "brown", 2) + r(230, 80, 8, 100, "brown", 2) + r(90, 96, 148, 6, "brown", 2)
        + r(90, 130, 148, 6, "brown", 2) + ln(96, 180, 160, 96, "brown", 3) + ln(234, 180, 170, 96, "brown", 3) + ground(70, 270)),
    "shard": ("noun", ["nature"], "A sharp glass shard catching the light.",
        lambda: p("M170 40L200 110L180 170L150 150Z", "cream") + p("M170 40L200 110L170 110Z", "teal")
        + ln(150, 150, 180, 170, "greyShade", 2)),
    "sieve": ("noun", ["objects", "kitchen"], "A round metal sieve with small holes.",
        lambda: ring(170, 110, 46, "brown", "cream", 8) + c(146, 96, 5, "greyShade") + c(170, 110, 5, "greyShade")
        + c(194, 124, 5, "greyShade") + ln(170, 156, 220, 176, "brown", 6)),
    "sitar": ("noun", ["instruments"], "An Indian sitar with a long neck and gourd.",
        lambda: c(132, 130, 30, "orange") + c(132, 130, 10, "ink") + r(160, 94, 102, 10, "brown", 4) + c(262, 99, 6, "brown")),
    "sloth": ("noun", ["animals"], "A sloth hanging from a branch.",
        lambda: ln(70, 48, 270, 48, "brown", 6) + e(170, 100, 34, 40, "grey") + c(170, 62, 22, "grey")
        + c(162, 58, 3, "ink") + c(178, 58, 3, "ink") + s("M140 110Q120 84 130 60", "greyShade", 8)),
    "spigot": ("noun", ["objects"], "A brass spigot on a barrel.",
        lambda: r(126, 96, 88, 18, "greyShade", 6) + r(150, 114, 20, 40, "grey", 4) + c(170, 160, 8, "orange")
        + c(170, 80, 6, "grey")),
    "spur": ("noun", ["objects", "tools"], "A steel spur with a spiked rowel.",
        lambda: ring(170, 110, 36, "greyShade", "none", 6) + c(170, 110, 8, "orange")
        + ln(136, 110, 204, 110, "greyShade", 3) + ln(170, 74, 170, 146, "greyShade", 3)),
    "stalactite": ("noun", ["nature"], "Stalactites hanging from a cave ceiling.",
        lambda: p("M70 60H270V80H70Z", "skinShade") + p("M120 80L140 150L160 80Z", "halo")
        + p("M190 80L206 130L222 80Z", "halo")),
    "stingray": ("noun", ["animals", "water"], "A flat grey stingray with a thin tail.",
        lambda: p("M170 96Q250 80 260 120Q230 150 170 140Q110 150 80 120Q90 80 170 96Z", "greyShade")
        + s("M236 120Q270 120 290 110", "ink", 4) + c(160, 118, 3, "ink") + c(180, 118, 3, "ink")),
    "tankard": ("noun", ["objects", "kitchen"], "A pewter tankard with a handle.",
        lambda: p("M124 90H206V166Q206 174 198 174H132Q124 174 124 166Z", "sandBorder")
        + s("M206 102Q234 108 226 140", "greyShade", 6) + r(124, 82, 82, 10, "brown", 3)),
    "tapir": ("noun", ["animals"], "A tapir with a short trunk.",
        lambda: e(160, 124, 52, 28, "greyShade") + c(218, 100, 22, "greyShade") + ln(232, 104, 262, 118, "ink", 8)
        + c(214, 94, 3, "cream") + r(120, 140, 10, 28, "ink", 3) + ground(100, 250)),
    "timpani": ("noun", ["instruments"], "A copper timpani kettledrum.",
        lambda: p("M116 104Q170 120 224 104L220 150Q170 166 120 150Z", "brown") + e(170, 104, 54, 14, "cream")
        + ln(150, 70, 192, 96, "brown", 3) + ground(100, 240)),
    "toucan": ("noun", ["animals", "birds"], "A black toucan with a big orange beak.",
        lambda: e(160, 126, 40, 30, "ink") + c(196, 100, 20, "ink") + p("M212 96Q250 98 260 112Q236 118 212 110Z", "orange")
        + c(200, 94, 3, "cream") + p("M140 130L120 156L160 142Z", "ink") + ground(100, 240)),
    "trident": ("noun", ["weapons"], "A three-pronged trident.",
        lambda: ln(170, 60, 170, 170, "greyShade", 6) + ln(140, 60, 140, 100, "greyShade", 5)
        + ln(200, 60, 200, 100, "greyShade", 5) + p("M130 100Q170 124 210 100L200 110Q170 128 140 110Z", "greyShade")),
    "ukulele": ("noun", ["instruments"], "A small wooden ukulele.",
        lambda: e(170, 134, 40, 30, "orange") + e(170, 108, 28, 22, "orange") + c(170, 130, 12, "ink")
        + r(164, 56, 12, 60, "brown", 3) + r(156, 52, 28, 10, "brown", 3)),
    "valve": ("noun", ["machines"], "A brass valve with a round handle.",
        lambda: r(120, 108, 100, 14, "grey", 6) + c(170, 80, 18, "greyShade") + ln(170, 98, 170, 108, "grey", 8)
        + c(120, 115, 8, "orange") + ground(110, 230)),
    "vault": ("noun", ["architecture"], "A stone vault with a dark doorway.",
        lambda: p("M80 170V110Q170 40 260 110V170Z", "grey") + p("M150 170V130Q170 112 190 130V170Z", "ink") + ground(60, 280)),
    "viaduct": ("noun", ["buildings"], "A stone viaduct carrying a road over a valley.",
        lambda: r(60, 104, 220, 10, "grey", 2) + p("M80 114Q100 146 120 114Z", "greyShade") + p("M140 114Q160 146 180 114Z", "greyShade")
        + p("M200 114Q220 146 240 114Z", "greyShade") + ground(50, 290)),
    "wedge": ("noun", ["tools"], "A wooden wedge for splitting logs.",
        lambda: p("M110 150L230 120L230 162Z", "brown") + r(110, 150, 120, 10, "greyShade", 2)
        + ln(140, 140, 200, 126, "sandBorder", 2) + ln(156, 158, 214, 144, "greyShade", 2)),
    "wombat": ("noun", ["animals"], "A round grey wombat.",
        lambda: e(170, 124, 50, 32, "greyShade") + c(218, 104, 22, "greyShade") + c(224, 98, 3, "ink")
        + r(140, 146, 10, 22, "greyShade", 3) + r(184, 146, 10, 22, "greyShade", 3) + ground(100, 250)),
    "zither": ("noun", ["instruments"], "A flat zither with strings across the body.",
        lambda: p("M96 110L244 96L244 130L96 144Z", "brown") + ln(110, 116, 234, 104, "orange", 2)
        + ln(110, 128, 234, 116, "orange", 2)),
}


def main(words=None):
    words = words or WORDS
    catalog = json.loads(BINDINGS.read_text())
    have = {a["assetName"] for a in catalog["assets"]}
    added = []
    for word, (pos, tags, alt, draw) in sorted(words.items()):
        name = f"word_{word}_plate"
        folder = ASSETS / f"{name}.imageset"
        folder.mkdir(exist_ok=True)
        (folder / f"{name}.svg").write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 340 200">{FRAME}{draw()}</svg>\n')
        (folder / "Contents.json").write_text(json.dumps({
            "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
            "info": {"author": "xcode", "version": 1},
            "properties": {"preserves-vector-representation": True},
        }, separators=(",", ":")) + "\n")
        if name in have:
            continue
        catalog["assets"].append({
            "id": f"illustration.{word}.{pos}.plate", "word": word, "lemma": word, "partOfSpeech": pos, "senseId": None,
            "assetName": name, "assetPath": f"Resources/IllustrationsSVG/Words.xcassets/{name}.imageset/{name}.svg",
            "style": "flat_color", "contexts": ["dictionary_entry"], "version": 1, "tags": ["c1"] + tags,
            "altText": alt, "isDecorative": False, "notes": "C1 memory-derived, unverified",
        })
        added.append(name)
    BINDINGS.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n")
    project = ROOT / "Wordwell.xcodeproj/project.pbxproj"
    text = project.read_text()
    start = text.index("\t\t\tinputPaths = (", text.index("/* Validate SVG illustrations */ = {"))
    end = text.index("\t\t\t);", start)
    base = "$(SRCROOT)/Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets"
    inputs = "".join(f'\t\t\t\t"{base}/{n}.imageset/{f}",\n' for n in sorted(added) for f in ("Contents.json", f"{n}.svg"))
    if inputs:
        project.write_text(text[:end] + inputs + text[end:])
    print(f"Drew {len(words)} illustrations, added {len(added)} bindings")


if __name__ == "__main__":
    main(WORDS)
