#!/usr/bin/env python3
"""Flat colour A2 batch 1: first 30 drawable Oxford 3000 A2 words in alphabetical order (accident .. blood).

Unlike earlier batches these words have no binding yet, so this script also creates the imageset, the binding
and the Xcode "Validate SVG illustrations" input paths.
Run: python3 Tools/flat_redraw_a2_1.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

import json

from flat_redraw import WORDS as BASE, ASSETS, BINDINGS, FRAME, ROOT, c, e, eye, ground, ln, p, r, ring, s
from flat_redraw_b7 import P, heart, star
from flat_redraw_b10 import arrow

WORDS = {
    "accident": ("noun", ["transport", "events"], "Two cars that have crashed into each other.",
        lambda: r(66, 108, 92, 36, "teal", 8) + r(80, 90, 52, 22, "teal", 6) + r(182, 108, 92, 36, "orange", 8) + r(208, 90, 52, 22, "orange", 6)
        + c(92, 146, 12, "ink") + c(240, 146, 12, "ink") + star(170, 96, 26, 11, "orange") + star(170, 96, 14, 6, "cream") + ground()),
    "accept": ("verb", ["actions"], "An open hand receiving a gift, with a green tick.",
        lambda: r(100, 138, 140, 16, "skin", 8) + r(210, 130, 40, 12, "skin", 6) + r(138, 86, 64, 50, "orange", 4) + r(166, 86, 8, 50, "cream") + r(138, 106, 64, 8, "cream")
        + c(236, 62, 20, "green") + s("M226 62L234 71L248 52", "cream", 5)),
    "active": ("adjective", ["describing"], "A person jumping with arms raised and energy lines.",
        lambda: P(170, top="orange", hair="brown", base=160, arms="") + ln(148, 74, 126, 48, "orange", 6) + ln(192, 74, 214, 48, "orange", 6)
        + ln(130, 168, 120, 178, "grey", 3) + ln(170, 168, 170, 178, "grey", 3) + ln(210, 168, 220, 178, "grey", 3) + star(100, 70, 9, 4, "orange") + star(244, 70, 9, 4, "orange")),
    "adventure": ("noun", ["travel", "events"], "A mountain trail leading to a flag on the summit.",
        lambda: p("M50 170L130 60L196 140L240 88L298 170Z", "teal") + p("M130 60L110 86L130 78L146 90Z", "cream") + ln(130, 60, 130, 34, "brown", 3)
        + p("M130 34H160L148 42L160 50H130Z", "orange") + s("M70 170C110 150 150 160 190 140", "brown", 3) + ground(40, 300)),
    "advertisement": ("noun", ["media", "work"], "A roadside billboard with a bright picture and lines.",
        lambda: r(86, 38, 168, 96, "brown", 6) + r(96, 48, 148, 76, "cream", 3) + c(138, 86, 18, "orange") + ln(170, 74, 228, 74, "teal", 6) + ln(170, 92, 218, 92, "teal", 6)
        + ln(170, 110, 200, 110, "grey", 4) + r(132, 134, 10, 40, "brown", 2) + r(198, 134, 10, 40, "brown", 2) + ground()),
    "airline": ("noun", ["travel", "transport"], "A passenger aeroplane with a teal tail and stripe.",
        lambda: p("M92 104L76 62H104L126 98Z", "teal") + e(170, 106, 84, 18, "cream") + r(96, 108, 150, 6, "teal", 3) + p("M150 100L196 100L176 56H160Z", "grey")
        + p("M150 108L196 108L176 152H156Z", "greyShade") + c(212, 100, 3, "ink") + c(228, 100, 3, "ink") + c(244, 100, 3, "ink") + p("M258 100C274 102 274 112 258 114Z", "ink")
        + e(70, 150, 32, 8, "cream") + e(274, 50, 28, 7, "cream")),
    "alive": ("adjective", ["describing", "nature"], "A small green seedling growing from soil with a heart.",
        lambda: p("M96 170C110 140 230 140 244 170Z", "brown") + ln(170, 150, 170, 90, "green", 7) + e(144, 96, 30, 12, "green", -25) + e(198, 76, 30, 12, "green", 25)
        + heart(170, 50, 12, "skinShade") + ground(60, 280)),
    "alone": ("adjective", ["describing", "feelings"], "One person standing alone in a wide empty space.",
        lambda: P(170, 1.0, top="teal", hair="brown") + e(170, 176, 30, 5, "sandBorder") + ln(66, 180, 274, 180, "brown") + e(62, 56, 28, 8, "cream") + e(284, 70, 22, 6, "cream")),
    "ancient": ("adjective", ["describing", "history"], "Old stone columns, one of them broken, on steps.",
        lambda: r(70, 160, 200, 10, "grey", 2) + r(84, 150, 172, 10, "greyShade", 2) + r(96, 64, 26, 86, "cream") + r(90, 54, 38, 10, "cream", 2) + r(150, 64, 26, 86, "cream")
        + r(144, 54, 38, 10, "cream", 2) + p("M204 150V100L216 92L224 106L238 96V150Z", "cream") + ground(60, 280)),
    "ankle": ("noun", ["body"], "A foot and lower leg with the ankle joint circled.",
        lambda: BASE["foot"]() + ring(145, 124, 24, "orange", "none", 4)),
    "architect": ("noun", ["jobs", "work"], "A person with a house blueprint and a pencil.",
        lambda: P(108, top="teal", hair="brown", arms="") + ln(130, 90, 158, 108, "teal", 6) + r(150, 56, 108, 86, "deepTeal", 4) + p("M170 124V92L204 70L238 92V124Z", "cream")
        + r(196, 100, 16, 24, "deepTeal") + ln(230, 50, 260, 80, "orange", 6) + ground(70, 280)),
    "argue": ("verb", ["communication", "feelings"], "Two people facing each other with angry speech bubbles.",
        lambda: P(100, top="orange", hair="brown", base=176) + P(240, top="teal", hair="ink", base=176) + e(110, 38, 26, 17, "cream") + e(230, 38, 26, 17, "cream")
        + ln(110, 30, 110, 42, "ink", 4) + c(110, 49, 2.5, "ink") + ln(230, 30, 230, 42, "ink", 4) + c(230, 49, 2.5, "ink") + ground(50, 290)),
    "army": ("noun", ["people", "work"], "Three soldiers in green uniforms and helmets standing in a row.",
        lambda: P(110, 0.85, top="green", bottom="deepTeal", hair="green") + P(170, 0.85, top="green", bottom="deepTeal", hair="green") + P(230, 0.85, top="green", bottom="deepTeal", hair="green")
        + ln(60, 180, 280, 180, "brown")),
    "asleep": ("adjective", ["describing", "home"], "A person sleeping in bed at night with a moon and Z letters.",
        lambda: BASE["bed"]() + c(120, 108, 13, "skin") + e(120, 100, 14, 8, "brown") + c(264, 50, 16, "orange") + c(272, 46, 13, "sand")
        + s("M150 70H168L150 88H168", "teal", 3) + s("M184 44H198L184 58H198", "teal", 3)),
    "athlete": ("noun", ["sport", "people"], "A winner standing on a podium with a medal on the chest.",
        lambda: r(112, 152, 116, 26, "brown", 3) + P(170, 0.85, top="orange", bottom="deepTeal", hair="brown", base=152) + ln(160, 76, 170, 96, "teal", 4) + ln(180, 76, 170, 96, "teal", 4)
        + c(170, 102, 7, "orange") + star(96, 70, 9, 4, "orange") + star(244, 70, 9, 4, "orange")),
    "attack": ("verb", ["conflict", "actions"], "Arrows flying toward a castle wall.",
        lambda: r(204, 72, 84, 104, "grey", 4) + r(204, 58, 16, 16, "grey") + r(238, 58, 16, 16, "grey") + r(272, 58, 16, 16, "grey") + r(234, 128, 24, 48, "greyShade", 3)
        + arrow(40, 84, 190, "orange") + arrow(60, 120, 190, "orange") + arrow(40, 156, 190, "orange") + ground(30, 300)),
    "audience": ("noun", ["people", "events"], "Rows of people seen from behind, watching a lit stage.",
        lambda: r(90, 28, 160, 44, "deepTeal", 4) + r(100, 36, 140, 28, "orange", 3) + r(70, 128, 200, 14, "teal", 4) + r(70, 164, 200, 14, "teal", 4)
        + c(100, 112, 14, "skin") + c(140, 112, 14, "brown") + c(180, 112, 14, "ink") + c(220, 112, 14, "skinShade") + c(120, 148, 14, "ink") + c(160, 148, 14, "skin")
        + c(200, 148, 14, "brown") + c(240, 148, 14, "skinShade")),
    "author": ("noun", ["jobs", "books"], "A person beside a large book, holding a pen.",
        lambda: P(108, top="orange", hair="brown", arms="") + ln(130, 90, 168, 110, "orange", 6) + r(170, 54, 94, 112, "teal", 6) + r(170, 54, 14, 112, "deepTeal", 3) + r(196, 76, 56, 28, "cream", 3)
        + ln(204, 88, 244, 88, "ink", 3) + ln(204, 96, 232, 96, "ink", 3) + ln(160, 104, 176, 124, "ink", 4) + ground(60, 290)),
    "award": ("noun", ["sport", "events"], "A golden trophy cup with handles and a star.",
        lambda: p("M132 48H208V90C208 116 190 126 170 126C150 126 132 116 132 90Z", "orange") + s("M132 60C108 60 108 96 138 98", "orange", 7) + s("M208 60C232 60 232 96 202 98", "orange", 7)
        + r(162, 124, 16, 22, "orange") + r(134, 146, 72, 18, "brown", 3) + star(170, 84, 18, 8, "cream") + ground(100, 240)),
    "awful": ("adjective", ["describing", "feelings"], "A sad sick face with a frown and a sweat drop.",
        lambda: c(170, 102, 58, "orange") + eye(150, 90) + eye(190, 90) + ln(138, 74, 160, 80, "ink", 4) + ln(202, 74, 180, 80, "ink", 4) + s("M146 134C156 118 184 118 194 134", "ink", 5)
        + p("M236 62C226 78 224 88 236 90C248 88 246 78 236 62Z", "teal")),
    "baseball": ("noun", ["sport"], "A white baseball with red stitches and a wooden bat.",
        lambda: p("M72 160L226 48L238 64L84 174Z", "brown") + c(212, 126, 44, "cream") + s("M186 96C198 114 198 138 186 156", "skinShade", 3) + s("M238 96C226 114 226 138 238 156", "skinShade", 3)
        + ln(188, 106, 196, 108, "skinShade", 3) + ln(188, 126, 196, 126, "skinShade", 3) + ln(188, 146, 196, 144, "skinShade", 3) + ln(236, 106, 228, 108, "skinShade", 3)
        + ln(236, 126, 228, 126, "skinShade", 3) + ln(236, 146, 228, 144, "skinShade", 3)),
    "basketball": ("noun", ["sport"], "An orange basketball above a hoop with a net.",
        lambda: c(170, 58, 36, "orange") + s("M134 58H206", "ink", 3) + s("M170 22V94", "ink", 3) + s("M145 32C159 48 159 68 145 84", "ink", 3) + s("M195 32C181 48 181 68 195 84", "ink", 3)
        + ring(170, 130, 34, "skinShade", "none", 5) + s("M142 136L158 176M170 138V178M198 136L182 176", "cream", 3)),
    "bean": ("noun", ["food", "plants"], "A green bean pod split open showing round beans.",
        lambda: e(170, 102, 90, 28, "green", -18) + e(170, 102, 76, 18, "teal", -18) + c(128, 118, 12, "cream") + c(160, 104, 12, "cream") + c(192, 90, 12, "cream") + c(224, 76, 12, "cream")
        + ground(80, 260)),
    "beef": ("noun", ["food"], "A raw steak with a white fat edge and a bone.",
        lambda: e(170, 104, 80, 54, "cream") + e(170, 106, 68, 42, "skinShade") + s("M128 96C148 84 158 110 178 98", "cream", 3) + s("M150 124C170 112 192 132 210 118", "cream", 3)
        + c(206, 92, 12, "cream") + c(206, 92, 5, "skinShade")),
    "belt": ("noun", ["clothes"], "A brown leather belt with a metal buckle and holes.",
        lambda: r(50, 86, 240, 28, "brown", 6) + r(136, 76, 52, 48, "orange", 6) + r(150, 90, 24, 20, "brown", 2) + ln(150, 100, 190, 100, "greyShade", 4)
        + c(212, 100, 3, "ink") + c(230, 100, 3, "ink") + c(248, 100, 3, "ink") + c(266, 100, 3, "ink")),
    "bin": ("noun", ["home", "outdoors"], "A grey rubbish bin with a lid and crumpled paper.",
        lambda: p("M124 74H216L206 168H134Z", "grey") + r(114, 60, 112, 14, "greyShade", 4) + r(156, 50, 28, 10, "greyShade", 3) + ln(150, 88, 154, 156, "greyShade", 3)
        + ln(170, 88, 170, 156, "greyShade", 3) + ln(190, 88, 186, 156, "greyShade", 3) + c(244, 160, 12, "cream") + ground()),
    "biology": ("noun", ["school", "science"], "A microscope with a small green leaf.",
        lambda: r(120, 160, 100, 12, "greyShade", 4) + s("M196 70C250 80 250 150 200 156", "greyShade", 12) + ln(154, 56, 186, 124, "teal", 24) + ln(150, 42, 144, 30, "ink", 14)
        + r(132, 128, 70, 8, "grey", 3) + e(86, 146, 22, 10, "green", -25) + ln(86, 154, 108, 166, "green", 4)),
    "birth": ("noun", ["life", "family"], "A chick hatching from a cracked egg.",
        lambda: c(170, 84, 30, "orange") + c(160, 78, 3, "ink") + c(180, 78, 3, "ink") + p("M164 90L176 90L170 100Z", "skin") + p("M110 120L128 104L142 124L160 106L180 124L198 106L214 124L232 108V164H110Z", "cream")
        + p("M110 164H232L220 172H122Z", "sandBorder") + star(90, 56, 9, 4, "orange") + star(256, 56, 9, 4, "orange")),
    "biscuit": ("noun", ["food"], "Two round biscuits with chocolate chips.",
        lambda: c(200, 96, 48, "skinShade") + c(144, 112, 48, "skin") + ring(144, 112, 40, "skinShade", "none", 3) + c(128, 98, 5, "brown") + c(158, 100, 5, "brown")
        + c(146, 128, 5, "brown") + c(126, 124, 4, "brown") + c(176, 124, 4, "brown") + c(216, 80, 5, "brown") + c(194, 104, 5, "brown") + c(222, 112, 4, "brown")),
    "blood": ("noun", ["body", "health"], "A large red-brown blood drop with two small drops.",
        lambda: p("M170 30C150 70 128 90 128 120C128 148 146 164 170 164C194 164 212 148 212 120C212 90 190 70 170 30Z", "skinShade") + e(152, 120, 6, 14, "cream", 20)
        + p("M246 80C238 98 232 104 232 114C232 122 238 128 246 128C254 128 260 122 260 114C260 104 254 98 246 80Z", "skinShade")
        + p("M94 100C88 112 84 118 84 124C84 130 88 134 94 134C100 134 104 130 104 124C104 118 100 112 94 100Z", "skinShade")),
}


def main(words=None):
    words = words or WORDS
    catalog = json.loads(BINDINGS.read_text())
    have = {a["assetName"] for a in catalog["assets"]}
    added = []
    for word, (pos, tags, alt, draw) in words.items():
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
            "style": "flat_color", "contexts": ["dictionary_entry"], "version": 1, "tags": ["a2"] + tags,
            "altText": alt, "isDecorative": False, "notes": None,
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
    main()
