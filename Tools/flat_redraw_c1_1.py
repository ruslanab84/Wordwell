#!/usr/bin/env python3
"""Flat colour C1 batch 1: 100 C1 nouns, drawn alphabetically (alpaca .. xylophone).

Word list is memory-derived, not from an official C1 list (Oxford 5000 by CEFR unavailable here).
Every entry is unverified: tag 'c1' marks it, the level is not confirmed.
Run: python3 Tools/flat_redraw_c1_1.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

import json

from flat_redraw import ASSETS, BINDINGS, FRAME, ROOT, c, e, ground, ln, p, r, ring, s, wheel

WORDS = {
    "alpaca": ("noun", ["animals"], "A cream alpaca with a long neck and fluffy coat.",
        lambda: e(170, 120, 44, 30, "cream") + r(146, 84, 14, 40, "cream", 6) + e(156, 74, 18, 12, "cream")
        + r(132, 140, 8, 30, "greyShade", 3) + r(200, 140, 8, 30, "greyShade", 3) + ground(110, 230)),
    "antelope": ("noun", ["animals"], "A brown antelope with curved horns.",
        lambda: e(170, 118, 54, 26, "brown") + c(228, 82, 20, "brown") + s("M214 66Q206 40 224 30", "ink", 3)
        + s("M232 64Q242 40 260 40", "ink", 3) + r(134, 136, 8, 40, "brown", 3) + r(196, 136, 8, 40, "brown", 3) + ground(100, 240)),
    "arch": ("noun", ["buildings"], "A stone arch over a doorway.",
        lambda: s("M110 160V96Q170 30 230 96V160", "grey", 22) + r(100, 150, 140, 14, "greyShade", 2) + ground(90, 250)),
    "atoll": ("noun", ["nature", "water"], "A ring of sand around a blue lagoon.",
        lambda: e(170, 118, 96, 42, "sandBorder") + e(170, 118, 64, 26, "teal") + r(90, 110, 40, 8, "green", 3) + c(228, 104, 6, "green")),
    "ballista": ("noun", ["weapons"], "A wooden ballista on a stand, aimed upward.",
        lambda: r(120, 124, 100, 14, "brown", 3) + ln(170, 124, 170, 60, "brown", 8) + ln(124, 88, 216, 88, "ink", 4)
        + r(160, 150, 20, 30, "brown", 2) + ground(90, 250)),
    "barometer": ("noun", ["objects", "science"], "A round barometer with a black needle.",
        lambda: ring(170, 110, 52, "brown", "cream", 8) + ln(170, 110, 196, 92, "ink", 4) + c(170, 110, 5, "ink")
        + r(160, 166, 20, 12, "brown", 2) + ground(110, 230)),
    "bastion": ("noun", ["buildings"], "A stone bastion jutting from a wall.",
        lambda: r(70, 110, 200, 60, "grey", 2) + r(70, 92, 28, 20, "greyShade") + r(140, 92, 28, 20, "greyShade")
        + r(210, 92, 28, 20, "greyShade") + p("M180 110L200 170H180Z", "greyShade") + ground(60, 280)),
    "bayonet": ("noun", ["weapons"], "A steel bayonet with a brown grip.",
        lambda: p("M96 110L210 98L222 110L210 122L96 110Z", "grey") + r(206, 100, 40, 20, "brown", 4) + r(80, 104, 20, 12, "greyShade", 2)),
    "bellows": ("noun", ["tools"], "A leather bellows with a wooden nozzle.",
        lambda: p("M96 100L140 74L200 74L244 100L224 126L140 126Z", "brown") + p("M120 92L220 92L212 104L128 104Z", "orange")
        + r(236, 96, 22, 10, "greyShade", 3) + r(234, 118, 20, 8, "brown", 2)),
    "bison": ("noun", ["animals"], "A brown bison with a shaggy hump.",
        lambda: p("M96 120Q120 80 176 96L232 118L232 146H96Z", "brown") + c(236, 104, 22, "brown") + ln(228, 92, 236, 74, "ink", 4)
        + r(106, 146, 12, 30, "ink", 3) + r(212, 146, 12, 30, "ink", 3) + ground(80, 260)),
    "boiler": ("noun", ["machines"], "A round steel boiler with a pipe and gauge.",
        lambda: e(160, 120, 56, 46, "grey") + r(200, 84, 30, 14, "greyShade", 3) + c(170, 112, 10, "orange")
        + r(120, 160, 80, 12, "greyShade", 3) + ground(90, 250)),
    "boulder": ("noun", ["nature"], "A big grey boulder with moss on one side.",
        lambda: e(170, 130, 64, 40, "grey") + e(186, 120, 30, 16, "greyShade") + e(146, 150, 20, 8, "green") + ground(90, 250)),
    "bugle": ("noun", ["instruments"], "A brass bugle with a long curved tube.",
        lambda: p("M96 118L232 82L240 104L104 140Z", "halo") + e(236, 93, 14, 22, "orange", 16) + r(96, 110, 14, 26, "orange", 3)
        + ln(124, 130, 128, 146, "brown", 4) + c(116, 136, 4, "ink")),
    "canyon": ("noun", ["nature"], "A deep canyon with layered rock walls.",
        lambda: p("M60 60L120 60L140 150L60 150Z", "skinShade") + p("M220 60L280 60V150H200Z", "skinShade")
        + p("M118 72L220 72L200 146L140 146Z", "halo") + ln(150, 110, 190, 110, "brown", 3) + ground(40, 300)),
    "cathedral": ("noun", ["buildings"], "A tall cathedral with twin towers.",
        lambda: r(110, 80, 120, 90, "grey", 2) + r(102, 40, 32, 130, "greyShade", 2) + r(206, 40, 32, 130, "greyShade", 2)
        + p("M102 40L118 24L134 40Z", "teal") + p("M206 40L222 24L238 40Z", "teal") + r(156, 120, 28, 50, "deepTeal", 14)
        + c(170, 100, 18, "halo") + ground(80, 260)),
    "catapult": ("noun", ["weapons"], "A wooden catapult with a loaded arm.",
        lambda: r(110, 124, 120, 14, "brown", 3) + ln(150, 124, 210, 56, "brown", 8) + r(140, 150, 10, 30, "brown", 2)
        + r(206, 150, 10, 30, "brown", 2) + c(210, 52, 12, "grey") + ground(90, 250)),
    "cauldron": ("noun", ["objects"], "A black cauldron over a fire.",
        lambda: e(170, 116, 52, 36, "ink") + r(124, 104, 92, 16, "greyShade", 4) + ln(132, 150, 118, 170, "brown", 5)
        + ln(208, 150, 222, 170, "brown", 5) + p("M150 150L170 170L190 150Z", "orange")),
    "chalice": ("noun", ["objects"], "A gold chalice with a jewelled bowl.",
        lambda: p("M120 60H220L206 104Q170 118 134 104Z", "halo") + r(164, 104, 12, 46, "orange", 2)
        + r(136, 150, 68, 10, "orange", 4) + c(170, 80, 6, "teal")),
    "chameleon": ("noun", ["animals"], "A green chameleon curled around a branch.",
        lambda: s("M96 150Q140 120 170 130Q200 140 214 110", "green", 9) + e(180, 102, 34, 24, "green")
        + c(206, 88, 14, "green") + c(210, 84, 5, "ink") + s("M96 150H250", "brown", 5) + ground(80, 260)),
    "chandelier": ("noun", ["objects", "home"], "A brass chandelier with five candles.",
        lambda: ln(170, 40, 170, 70, "brown", 3) + r(120, 70, 100, 8, "orange", 3) + c(132, 96, 6, "halo")
        + c(170, 100, 6, "halo") + c(208, 96, 6, "halo") + ln(132, 80, 132, 96, "orange", 3) + ln(170, 78, 170, 100, "orange", 3)
        + ln(208, 80, 208, 96, "orange", 3) + p("M120 130H220L210 150H130Z", "orange")),
    "cobra": ("noun", ["animals"], "A coiled cobra raising its hood.",
        lambda: e(170, 150, 74, 16, "green") + s("M120 140Q110 70 160 60Q210 50 200 120", "green", 10)
        + e(164, 66, 22, 20, "teal") + c(158, 62, 3, "ink") + c(176, 62, 3, "ink") + ground(70, 270)),
    "crossbow": ("noun", ["weapons"], "A crossbow with a wooden stock and a taut string.",
        lambda: r(150, 70, 14, 110, "brown", 3) + s("M90 96Q170 64 250 96", "greyShade", 6) + ln(90, 96, 170, 120, "ink", 2)
        + ln(250, 96, 170, 120, "ink", 2) + ground(80, 260)),
    "cupola": ("noun", ["buildings"], "A small round cupola on a roof.",
        lambda: r(110, 120, 120, 40, "cream", 2) + p("M130 120Q170 40 210 120Z", "teal") + c(170, 40, 8, "orange")
        + r(160, 46, 4, 12, "brown") + ground(90, 250)),
    "drawbridge": ("noun", ["buildings"], "A wooden drawbridge lowered across a moat.",
        lambda: r(50, 120, 90, 14, "brown", 2) + p("M140 120L240 90L252 104L152 134Z", "brown") + r(40, 136, 260, 44, "teal", 2)
        + ln(56, 120, 150, 120, "greyShade", 3)),
    "forge": ("noun", ["buildings", "tools"], "A stone forge with glowing coals.",
        lambda: r(100, 120, 140, 50, "grey", 4) + r(130, 80, 30, 40, "greyShade", 3) + r(96, 164, 148, 10, "brown", 2)
        + e(170, 150, 22, 8, "orange") + ground(70, 270)),
    "fortress": ("noun", ["buildings"], "A grey fortress with four towers.",
        lambda: r(100, 110, 140, 70, "grey", 2) + r(86, 80, 26, 100, "greyShade", 2) + r(228, 80, 26, 100, "greyShade", 2)
        + r(150, 124, 40, 56, "deepTeal", 16) + r(96, 68, 14, 12, "grey") + r(232, 68, 14, 12, "grey") + ground(60, 280)),
    "furnace": ("noun", ["machines"], "A black iron furnace with an orange glow.",
        lambda: r(110, 70, 120, 110, "ink", 8) + r(140, 120, 60, 40, "orange", 4) + r(96, 170, 148, 8, "greyShade", 2)
        + r(124, 54, 14, 20, "greyShade", 2) + ground(70, 270)),
    "galleon": ("noun", ["boats"], "A tall galleon with three sails.",
        lambda: p("M80 130H260L240 160H100Z", "brown") + ln(170, 130, 170, 50, "brown", 5) + p("M110 60H230L220 100H120Z", "cream")
        + p("M120 60L170 46L220 60", "cream") + ln(120, 88, 220, 88, "sandBorder", 2) + ground(60, 280)),
    "gargoyle": ("noun", ["buildings"], "A stone gargoyle with wings on a ledge.",
        lambda: r(90, 150, 160, 16, "grey", 2) + e(170, 120, 26, 22, "grey") + c(170, 98, 16, "grey")
        + p("M150 98L134 80L158 92Z", "greyShade") + p("M190 98L206 80L182 92Z", "greyShade") + ground(70, 270)),
    "gauntlet": ("noun", ["clothing", "weapons"], "A steel gauntlet with a brown cuff.",
        lambda: r(136, 90, 68, 70, "grey", 10) + r(130, 150, 80, 22, "brown", 4) + r(146, 60, 14, 32, "grey", 4)
        + r(166, 56, 14, 36, "grey", 4) + r(186, 62, 14, 30, "grey", 4)),
    "gazelle": ("noun", ["animals"], "A slender tan gazelle with thin legs.",
        lambda: e(170, 118, 56, 24, "sandBorder") + c(226, 82, 20, "sandBorder") + s("M234 70Q236 44 224 40", "ink", 3)
        + r(132, 134, 6, 42, "brown", 3) + r(200, 134, 6, 42, "brown", 3) + r(214, 134, 6, 42, "brown", 3) + ground(100, 240)),
    "geyser": ("noun", ["nature"], "A geyser shooting water into the air.",
        lambda: p("M130 160L210 160L200 130L140 130Z", "greyShade") + s("M170 130V60", "teal", 12) + c(170, 52, 8, "teal")
        + c(146, 70, 6, "teal") + c(196, 66, 6, "teal") + ground(80, 260)),
    "globe": ("noun", ["objects"], "A globe on a wooden stand.",
        lambda: c(170, 100, 58, "teal") + e(160, 84, 20, 14, "green") + e(186, 116, 16, 22, "green") + ring(170, 100, 58, "brown", "none", 4)
        + r(160, 156, 20, 14, "brown") + r(136, 168, 68, 8, "brown", 3)),
    "halberd": ("noun", ["weapons"], "A long halberd with an axe blade and spike.",
        lambda: ln(170, 50, 170, 170, "brown", 6) + p("M170 56L212 70L200 96L170 92Z", "grey") + p("M170 56L160 34L166 56Z", "grey")
        + ln(150, 110, 190, 110, "brown", 3) + ground(110, 230)),
    "harpoon": ("noun", ["tools", "weapons"], "A harpoon with a barbed tip and rope.",
        lambda: ln(96, 110, 220, 110, "brown", 6) + p("M220 110L250 110L232 96Z", "grey") + p("M220 110L250 110L232 124Z", "grey")
        + s("M96 110Q80 140 110 160", "orange", 3)),
    "hawk": ("noun", ["animals", "birds"], "A brown hawk with spread wings.",
        lambda: p("M170 96L70 70L110 110L170 118Z", "brown") + p("M170 96L270 70L230 110L170 118Z", "brown")
        + e(170, 118, 30, 40, "cream") + c(170, 74, 20, "brown") + p("M186 74L200 80L186 84Z", "orange") + c(176, 70, 3, "ink")),
    "heron": ("noun", ["animals", "birds"], "A grey heron standing in shallow water.",
        lambda: e(160, 110, 30, 18, "grey") + ln(176, 118, 200, 160, "grey", 5) + ln(144, 118, 130, 160, "grey", 5)
        + s("M186 100Q212 60 240 70", "grey", 6) + p("M236 66L266 72L240 80Z", "orange") + ground(100, 240)),
    "hinge": ("noun", ["objects"], "A brass hinge with two leaves and a pin.",
        lambda: r(90, 96, 70, 12, "orange", 2) + r(160, 96, 70, 12, "orange", 2) + r(154, 84, 12, 36, "greyShade", 3)
        + c(160, 86, 4, "cream")),
    "javelin": ("noun", ["weapons", "sport"], "A javelin with a steel tip and a leather grip.",
        lambda: ln(90, 130, 240, 80, "brown", 5) + p("M240 80L262 70L252 90Z", "grey") + r(120, 116, 20, 14, "ink", 3)),
    "kaleidoscope": ("noun", ["objects"], "A kaleidoscope tube with coloured glass.",
        lambda: r(120, 60, 100, 100, "teal", 10) + c(170, 110, 34, "orange") + c(170, 110, 18, "halo") + c(170, 110, 8, "earPink")
        + r(132, 70, 76, 8, "brown", 2)),
    "kiln": ("noun", ["buildings", "tools"], "A brick kiln with an arched opening.",
        lambda: r(96, 80, 148, 90, "earPink", 6) + p("M140 170V130Q170 102 200 130V170Z", "ink") + e(170, 118, 14, 6, "orange")
        + ln(96, 80, 244, 80, "brown", 4) + ground(70, 270)),
    "lagoon": ("noun", ["nature", "water"], "A calm lagoon beside a sandy shore.",
        lambda: e(170, 120, 80, 36, "teal") + e(170, 118, 56, 22, "deepTeal") + e(120, 146, 18, 6, "sandBorder") + ground(50, 290)),
    "lance": ("noun", ["weapons"], "A long lance with a pennant flag.",
        lambda: ln(90, 150, 230, 60, "brown", 5) + p("M230 60L254 52L244 74Z", "grey") + p("M160 96L202 110L186 124Z", "orange")),
    "lathe": ("noun", ["machines", "tools"], "A wooden lathe holding a turned piece.",
        lambda: r(90, 120, 160, 12, "brown", 3) + r(96, 132, 14, 36, "brown", 3) + r(226, 132, 14, 36, "brown", 3)
        + r(120, 96, 12, 24, "greyShade", 2) + e(170, 98, 22, 12, "orange") + ground(70, 270)),
    "lectern": ("noun", ["objects", "buildings"], "A wooden lectern with an open book.",
        lambda: p("M136 82H204L196 166H144Z", "brown") + p("M124 80L170 72L216 80L170 88Z", "cream")
        + ln(124, 80, 124, 100, "cream", 3) + ln(216, 80, 216, 100, "cream", 3) + ground(100, 240)),
    "lever": ("noun", ["machines"], "A metal lever on a pivot with a round knob.",
        lambda: ln(120, 150, 210, 70, "greyShade", 8) + c(210, 66, 10, "orange") + r(158, 146, 26, 22, "grey", 4) + ground(90, 250)),
    "lynx": ("noun", ["animals"], "A spotted grey lynx with tufted ears.",
        lambda: e(170, 124, 52, 28, "sandBorder") + c(206, 96, 26, "sandBorder") + p("M190 80L194 56L208 74Z", "brown")
        + p("M222 74L230 56L236 80Z", "brown") + e(216, 96, 6, 4, "ink") + ln(150, 150, 150, 170, "brown", 6) + ln(190, 150, 190, 170, "brown", 6)
        + c(144, 116, 4, "brown") + c(170, 112, 4, "brown") + ground(100, 240)),
    "loom": ("noun", ["tools"], "A wooden loom with threads on a frame.",
        lambda: r(100, 60, 14, 120, "brown", 3) + r(226, 60, 14, 120, "brown", 3) + r(100, 60, 140, 10, "brown", 3)
        + ln(124, 80, 124, 170, "orange", 2) + ln(146, 80, 146, 170, "teal", 2) + ln(168, 80, 168, 170, "orange", 2)
        + ln(190, 80, 190, 170, "teal", 2) + ln(212, 80, 212, 170, "orange", 2)),
    "mace": ("noun", ["weapons"], "A steel mace with a spiked head.",
        lambda: ln(170, 170, 170, 110, "brown", 8) + c(170, 96, 26, "grey") + c(154, 84, 4, "greyShade") + c(184, 84, 4, "greyShade")
        + c(170, 70, 4, "greyShade") + c(170, 124, 4, "greyShade")),
    "mallet": ("noun", ["tools"], "A wooden mallet with a round head.",
        lambda: r(164, 84, 12, 88, "brown", 4) + r(120, 60, 100, 36, "orange", 10) + ln(120, 78, 220, 78, "brown", 2) + ground(100, 240)),
    "mongoose": ("noun", ["animals"], "A grey mongoose standing upright.",
        lambda: e(170, 130, 32, 46, "greyShade") + c(170, 84, 22, "grey") + c(160, 80, 4, "ink") + c(180, 80, 4, "ink")
        + p("M168 96L172 104L176 96Z", "earPink") + s("M204 150Q234 150 240 124", "greyShade", 6) + ground(110, 230)),
    "moat": ("noun", ["water", "buildings"], "A wide moat around a castle wall.",
        lambda: r(110, 80, 120, 50, "grey", 2) + r(110, 80, 10, 20, "greyShade") + r(220, 80, 10, 20, "greyShade")
        + r(40, 134, 260, 36, "teal", 2) + s("M60 146Q75 136 90 146Q105 156 120 146Q135 136 150 146Q165 156 180 146Q195 136 210 146Q225 156 240 146", "deepTeal", 3)),
    "mosaic": ("noun", ["art"], "A mosaic of coloured tiles in a grid.",
        lambda: r(90, 56, 160, 100, "cream", 4) + r(102, 68, 24, 24, "orange") + r(134, 68, 24, 24, "teal")
        + r(166, 68, 24, 24, "halo") + r(198, 68, 24, 24, "green") + r(102, 100, 24, 24, "green") + r(134, 100, 24, 24, "orange")
        + r(166, 100, 24, 24, "teal") + r(198, 100, 24, 24, "halo")),
    "musket": ("noun", ["weapons"], "A musket with a brown stock.",
        lambda: r(96, 110, 150, 14, "greyShade", 2) + r(96, 110, 40, 16, "brown", 4) + ln(136, 110, 236, 110, "ink", 3) + r(216, 102, 12, 10, "grey")),
    "narwhal": ("noun", ["animals", "water"], "A grey narwhal with a long spiral tusk.",
        lambda: e(160, 124, 62, 26, "greyShade") + p("M92 124L72 110L76 130Z", "greyShade") + ln(214, 118, 262, 88, "cream", 5)
        + p("M158 100L176 84L186 102Z", "greyShade") + c(200, 116, 3, "ink") + ground(60, 280)),
    "obelisk": ("noun", ["buildings"], "A tall stone obelisk on a base.",
        lambda: p("M158 40L182 40L188 150H152Z", "grey") + p("M158 40L170 20L182 40Z", "orange") + r(136, 150, 68, 14, "greyShade", 2)
        + ground(90, 250)),
    "pagoda": ("noun", ["buildings"], "A tiered pagoda with curved roofs.",
        lambda: r(150, 110, 40, 60, "brown") + p("M120 110H220L200 96H140Z", "orange") + p("M136 84H204L194 70H146Z", "orange")
        + p("M154 58H186L178 46H162Z", "orange") + ln(170, 36, 170, 46, "brown", 3) + ground(100, 240)),
    "parchment": ("noun", ["objects"], "A rolled parchment with a red seal.",
        lambda: r(100, 80, 140, 60, "cream", 8) + c(226, 108, 10, "orange") + ln(118, 96, 200, 96, "sandBorder", 2)
        + ln(118, 110, 190, 110, "sandBorder", 2) + ground(90, 250)),
    "pedestal": ("noun", ["objects", "buildings"], "A stone pedestal holding a vase.",
        lambda: r(130, 150, 80, 14, "greyShade", 2) + r(146, 120, 48, 30, "grey") + p("M136 116H204L196 84H144Z", "cream")
        + e(170, 84, 26, 6, "halo")),
    "periscope": ("noun", ["objects", "machines"], "A periscope with two mirrors on a tube.",
        lambda: r(156, 50, 28, 110, "greyShade", 4) + r(140, 56, 56, 10, "grey", 2) + r(140, 128, 56, 10, "grey", 2)
        + r(176, 58, 14, 8, "brown") + ground(120, 220)),
    "peninsula": ("noun", ["nature", "water"], "A strip of land reaching into the sea.",
        lambda: p("M60 150H160Q190 130 200 100Q220 86 250 96L280 150H60Z", "green") + p("M60 150H280V176H60Z", "teal")
        + e(230, 128, 6, 4, "sandBorder")),
    "pliers": ("noun", ["tools"], "A pair of steel pliers with orange grips.",
        lambda: ln(136, 60, 196, 130, "greyShade", 6) + ln(204, 60, 144, 130, "greyShade", 6) + c(170, 136, 6, "grey")
        + r(176, 146, 22, 34, "orange", 4) + r(120, 146, 22, 34, "orange", 4)),
    "piston": ("noun", ["machines"], "A metal piston inside a cylinder.",
        lambda: r(110, 70, 120, 90, "greyShade", 6) + r(128, 84, 84, 34, "grey", 4) + r(160, 118, 20, 40, "grey", 4)
        + r(120, 158, 100, 10, "brown", 3) + ground(90, 250)),
    "plough": ("noun", ["tools", "farm"], "A wooden plough pulled over soil.",
        lambda: ln(100, 110, 210, 110, "brown", 6) + p("M210 110L244 94L244 130Z", "grey") + ln(120, 110, 150, 150, "brown", 6)
        + r(150, 144, 20, 10, "greyShade") + ground(70, 270)),
    "prism": ("noun", ["objects", "science"], "A glass prism splitting white light.",
        lambda: p("M130 150L170 60L210 150Z", "cream") + ln(72, 110, 128, 110, "cream", 3)
        + ln(206, 100, 262, 80, "orange", 3) + ln(206, 110, 262, 100, "green", 3) + ln(206, 120, 262, 120, "teal", 3)),
    "ravine": ("noun", ["nature"], "A narrow ravine with a stream at the bottom.",
        lambda: p("M60 60H130L160 150H60Z", "skinShade") + p("M210 60H280V150H180Z", "skinShade")
        + p("M130 60L150 110L170 150H180L210 60Z", "halo") + s("M160 150Q170 136 190 150", "teal", 4)),
    "sabre": ("noun", ["weapons"], "A curved sabre with a gold hilt.",
        lambda: s("M96 136Q170 60 246 58", "grey", 6) + r(84, 130, 24, 12, "orange", 4) + c(94, 136, 4, "greyShade")),
    "saxophone": ("noun", ["instruments"], "A gold saxophone with a bent bell.",
        lambda: s("M150 52Q124 60 136 104Q144 150 186 152", "orange", 12) + e(200, 150, 22, 18, "orange")
        + c(154, 74, 4, "ink") + c(154, 96, 4, "ink") + c(160, 118, 4, "ink") + ground(100, 240)),
    "schooner": ("noun", ["boats"], "A two-masted schooner on calm water.",
        lambda: p("M76 130H266L240 160H100Z", "brown") + ln(132, 130, 132, 44, "brown", 4) + ln(212, 130, 212, 60, "brown", 4)
        + p("M136 50L200 50L136 124Z", "cream") + p("M216 66L250 118H216Z", "cream") + ground(60, 280)),
    "scroll": ("noun", ["objects", "art"], "A paper scroll with two wooden rods.",
        lambda: r(110, 88, 120, 64, "cream", 4) + c(110, 120, 12, "brown") + c(230, 120, 12, "brown") + ln(124, 100, 218, 100, "sandBorder", 2)
        + ln(124, 112, 200, 112, "sandBorder", 2) + ground(90, 250)),
    "scythe": ("noun", ["tools", "farm"], "A scythe with a curved blade and a wooden handle.",
        lambda: ln(120, 170, 200, 50, "brown", 6) + p("M200 50Q260 60 246 110L232 102Q240 80 196 62Z", "grey") + ground(90, 250)),
    "sextant": ("noun", ["objects", "science"], "A brass sextant with a curved arc.",
        lambda: p("M120 120Q170 16 220 120Z", "orange") + ln(170, 120, 218, 62, "ink", 3) + c(170, 120, 6, "ink")
        + ln(120, 120, 220, 120, "brown", 4) + ring(170, 120, 40, "brown", "none", 2)),
    "spindle": ("noun", ["tools"], "A wooden spindle with yarn wound on it.",
        lambda: r(164, 60, 12, 110, "brown", 3) + e(170, 110, 30, 16, "orange") + e(170, 130, 30, 14, "teal") + ground(110, 230)),
    "spire": ("noun", ["buildings"], "A stone church spire rising above a roof.",
        lambda: r(130, 110, 80, 60, "grey", 2) + p("M130 110L170 30L210 110Z", "greyShade") + c(170, 28, 5, "orange")
        + r(160, 130, 20, 40, "deepTeal", 8) + ground(100, 240)),
    "squid": ("noun", ["animals", "water"], "A pink squid with long curling tentacles.",
        lambda: e(170, 94, 34, 46, "earPink") + s("M150 130Q140 160 120 170", "earPink", 6) + s("M164 140Q164 168 160 176", "earPink", 6)
        + s("M180 140Q184 168 196 176", "earPink", 6) + s("M198 130Q212 156 226 166", "earPink", 6) + c(158, 90, 4, "ink") + c(182, 90, 4, "ink")),
    "stethoscope": ("noun", ["objects", "science"], "A stethoscope with a chest piece and tubes.",
        lambda: s("M130 60Q120 120 160 124Q200 120 194 60", "greyShade", 4) + ln(130, 60, 130, 50, "greyShade", 4)
        + ln(194, 60, 194, 50, "greyShade", 4) + c(170, 150, 14, "grey") + c(170, 150, 6, "cream") + ground(110, 230)),
    "stirrup": ("noun", ["objects", "animals"], "A metal stirrup on a leather strap.",
        lambda: r(160, 60, 20, 14, "brown", 4) + s("M150 74Q146 120 160 150H180Q194 120 190 74", "greyShade", 6)
        + r(144, 146, 52, 10, "grey", 4)),
    "starfish": ("noun", ["animals", "water"], "An orange starfish with five arms.",
        lambda: p("M170 60L184 98L224 98L192 120L204 160L170 136L136 160L148 120L116 98L156 98Z", "orange")
        + c(170, 108, 5, "halo") + c(118, 56, 5, "teal") + c(222, 56, 5, "teal")),
    "sundial": ("noun", ["objects"], "A stone sundial with a gnomon shadow.",
        lambda: e(170, 130, 60, 16, "grey") + p("M170 130L226 70L232 76L178 128Z", "greyShade") + c(170, 124, 6, "orange")
        + ln(120, 130, 220, 130, "greyShade", 2)),
    "tambourine": ("noun", ["instruments"], "A round tambourine with jingles.",
        lambda: ring(170, 110, 52, "brown", "cream", 8) + c(130, 76, 6, "halo") + c(170, 66, 6, "halo") + c(210, 76, 6, "halo")
        + ln(120, 128, 220, 128, "sandBorder", 3) + ground(100, 240)),
    "astrolabe": ("noun", ["objects", "science"], "A brass astrolabe with a rotating ring.",
        lambda: ring(170, 100, 52, "brown", "cream", 6) + ring(170, 100, 34, "brown", "none", 3) + ln(170, 44, 170, 156, "brown", 3)
        + ln(114, 100, 226, 100, "brown", 3) + p("M170 62L180 100L170 138L160 100Z", "orange") + ring(170, 40, 8, "brown", "none", 3)),
    "hacksaw": ("noun", ["tools"], "A hacksaw with a steel blade and wooden handle.",
        lambda: r(100, 90, 30, 44, "brown", 8) + ln(130, 112, 250, 112, "grey", 6) + ln(130, 94, 200, 64, "greyShade", 4)
        + ln(200, 64, 240, 94, "greyShade", 4) + ln(200, 64, 200, 112, "greyShade", 4)),
    "inkwell": ("noun", ["objects"], "A glass inkwell filled with dark ink.",
        lambda: r(128, 122, 84, 48, "teal", 12) + r(146, 96, 48, 26, "cream", 6) + r(156, 74, 28, 22, "brown", 4)
        + e(170, 126, 28, 6, "deepTeal") + ground(100, 240)),
    "salamander": ("noun", ["animals"], "A teal salamander with orange spots.",
        lambda: e(170, 118, 58, 22, "teal") + c(222, 104, 22, "teal") + c(230, 96, 4, "orange") + c(200, 110, 4, "orange")
        + c(176, 116, 4, "orange") + c(150, 116, 4, "orange") + ln(150, 136, 140, 156, "teal", 4) + ln(190, 136, 196, 156, "teal", 4)
        + ln(96, 118, 116, 118, "teal", 4) + ground(90, 250)),
    "sprocket": ("noun", ["machines"], "A metal sprocket with teeth around a hub.",
        lambda: c(170, 100, 40, "grey") + c(170, 58, 9, "grey") + c(212, 100, 9, "grey") + c(170, 142, 9, "grey")
        + c(128, 100, 9, "grey") + c(195, 75, 9, "grey") + c(145, 125, 9, "grey") + c(170, 100, 14, "cream")),
    "tapestry": ("noun", ["art"], "A woven tapestry with a red border.",
        lambda: r(100, 56, 140, 110, "teal", 2) + r(110, 66, 120, 90, "halo", 2) + c(170, 110, 26, "orange")
        + r(100, 56, 140, 12, "brown", 2) + r(100, 154, 140, 12, "brown", 2) + ground(90, 250)),
    "tarantula": ("noun", ["animals"], "A hairy brown tarantula with eight legs.",
        lambda: e(170, 116, 40, 30, "brown") + c(170, 86, 22, "brown") + c(162, 82, 3, "ink") + c(178, 82, 3, "ink")
        + ln(132, 110, 92, 96, "brown", 4) + ln(132, 124, 90, 130, "brown", 4) + ln(208, 110, 248, 96, "brown", 4)
        + ln(208, 124, 250, 130, "brown", 4) + ground(80, 260)),
    "thermometer": ("noun", ["objects", "science"], "A glass thermometer with red mercury.",
        lambda: r(158, 46, 24, 110, "cream", 12) + r(164, 96, 12, 50, "orange", 6) + c(170, 158, 16, "orange")
        + ln(170, 60, 170, 100, "ink", 2) + ground(120, 220)),
    "tram": ("noun", ["transport"], "A red tram on rails.",
        lambda: r(92, 76, 156, 76, "orange", 12) + r(108, 88, 24, 22, "cream", 3) + r(140, 88, 24, 22, "cream", 3)
        + r(172, 88, 24, 22, "cream", 3) + r(204, 88, 24, 22, "cream", 3) + ln(170, 76, 200, 40, "ink", 3)
        + r(84, 150, 172, 6, "greyShade") + wheel(120, 158, 10) + wheel(220, 158, 10)),
    "trawler": ("noun", ["boats"], "A fishing trawler with a long wire boom.",
        lambda: p("M80 124H250L226 154H102Z", "teal") + r(176, 96, 40, 28, "cream", 3) + ln(196, 96, 196, 56, "brown", 4)
        + ln(196, 60, 138, 124, "greyShade", 2) + ground(60, 280)),
    "trellis": ("noun", ["garden"], "A wooden trellis with a climbing plant.",
        lambda: r(96, 60, 148, 120, "brown", 2) + ln(96, 90, 244, 90, "brown", 3) + ln(96, 120, 244, 120, "brown", 3)
        + ln(130, 60, 130, 180, "brown", 3) + ln(170, 60, 170, 180, "brown", 3) + ln(210, 60, 210, 180, "brown", 3)
        + c(186, 70, 12, "green")),
    "tripod": ("noun", ["objects", "science"], "A metal tripod with three legs.",
        lambda: ln(170, 60, 170, 110, "greyShade", 6) + ln(170, 110, 120, 170, "greyShade", 5) + ln(170, 110, 220, 170, "greyShade", 5)
        + ln(170, 110, 170, 170, "grey", 5) + r(150, 56, 40, 14, "grey", 2) + ground(100, 240)),
    "trombone": ("noun", ["instruments"], "A brass trombone with a long slide.",
        lambda: r(92, 96, 150, 10, "orange", 4) + r(110, 86, 60, 10, "halo", 4) + e(246, 98, 16, 22, "orange")
        + ln(120, 106, 120, 150, "orange", 4) + c(120, 152, 6, "orange") + ground(100, 240)),
    "trowel": ("noun", ["tools", "garden"], "A garden trowel with a wooden handle.",
        lambda: p("M150 120H190L178 166H162Z", "grey") + r(164, 60, 12, 62, "brown", 4) + r(154, 52, 32, 12, "brown", 4) + ground(100, 240)),
    "turbine": ("noun", ["machines", "energy"], "A wind turbine with three white blades.",
        lambda: r(164, 96, 12, 80, "cream", 3) + c(170, 96, 10, "grey") + p("M170 96L176 40L164 40Z", "cream")
        + p("M170 96L222 124L214 132Z", "cream") + p("M170 96L118 124L126 132Z", "cream") + ground(100, 240)),
    "turret": ("noun", ["buildings"], "A stone turret with a pointed cap.",
        lambda: r(136, 80, 68, 90, "grey", 3) + p("M130 80L170 36L210 80Z", "teal") + r(126, 80, 88, 10, "greyShade", 2)
        + r(160, 120, 20, 30, "deepTeal", 8) + ground(100, 240)),
    "watchtower": ("noun", ["buildings"], "A wooden watchtower on tall legs.",
        lambda: r(130, 78, 80, 40, "brown", 3) + p("M120 78H220L170 46Z", "brown") + ln(140, 118, 124, 170, "brown", 6)
        + ln(200, 118, 216, 170, "brown", 6) + ln(170, 118, 170, 170, "brown", 6) + r(158, 92, 24, 14, "cream", 2)),
    "winch": ("noun", ["machines", "tools"], "A metal winch with a rope drum.",
        lambda: r(100, 120, 140, 14, "greyShade", 3) + c(160, 110, 26, "grey") + c(160, 110, 10, "brown")
        + r(224, 96, 16, 34, "greyShade", 3) + ln(160, 136, 160, 170, "brown", 3) + ground(80, 260)),
    "xylophone": ("noun", ["instruments"], "A wooden xylophone with coloured bars.",
        lambda: r(100, 120, 140, 14, "brown", 3) + r(112, 84, 16, 36, "orange", 2) + r(136, 84, 16, 36, "teal", 2)
        + r(160, 84, 16, 36, "halo", 2) + r(184, 84, 16, 36, "green", 2) + r(208, 84, 16, 36, "earPink", 2)
        + ln(100, 134, 100, 170, "brown", 4) + ln(240, 134, 240, 170, "brown", 4)),
    "zeppelin": ("noun", ["transport"], "A silver zeppelin floating in the sky.",
        lambda: e(170, 96, 84, 34, "grey") + r(144, 120, 52, 16, "greyShade", 4) + p("M244 96L270 74L270 118Z", "grey")
        + c(128, 96, 3, "ink")),
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
