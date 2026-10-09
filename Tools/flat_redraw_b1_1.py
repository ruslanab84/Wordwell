#!/usr/bin/env python3
"""Flat colour B1 batch 1: 30 B1 nouns in alphabetical order (balloon .. jug).

Word list is memory-derived, not from the official Oxford 3000 file (unavailable here).
Run: python3 Tools/flat_redraw_b1_1.py   (then svg_lint on the new files, validate_svg_assets.py, swift test)
"""

import json

from flat_redraw import ASSETS, BINDINGS, FRAME, ROOT, c, e, ground, ln, p, r, ring, s

WORDS = {
    "balloon": ("noun", ["fun"], "An orange balloon with a string.",
        lambda: e(170, 80, 40, 48, "orange") + s("M170 128Q160 150 170 176", "brown", 2) + c(170, 128, 3, "brown")),
    "bat": ("noun", ["animals"], "A dark bat with spread wings.",
        lambda: p("M170 90Q120 50 60 70Q90 100 100 120Q130 110 170 120Q210 110 240 120Q250 100 280 70Q220 50 170 90Z", "ink") + e(170, 110, 16, 20, "ink") + p("M158 96L154 74L168 90Z", "ink") + p("M182 96L186 74L172 90Z", "ink")),
    "bench": ("noun", ["outdoors", "furniture"], "A wooden park bench with a backrest.",
        lambda: r(80, 120, 180, 12, "brown", 4) + r(80, 100, 180, 12, "brown", 4) + r(92, 132, 10, 44, "brown", 2) + r(238, 132, 10, 44, "brown", 2) + ground(60, 280)),
    "blender": ("noun", ["kitchen"], "A kitchen blender with a glass jug.",
        lambda: p("M120 100L220 100L210 60L130 60Z", "cream") + r(124, 48, 92, 12, "greyShade", 4) + r(104, 160, 132, 14, "grey", 6) + r(120, 100, 100, 60, "teal", 12) + c(170, 130, 4, "ink")),
    "cage": ("noun", ["animals", "objects"], "A metal cage with a small bird inside.",
        lambda: "".join(ln(x, 60, x, 180, "grey", 4) for x in range(110, 250, 20)) + r(90, 56, 160, 8, "grey", 4) + r(90, 172, 160, 8, "grey", 4) + c(170, 110, 12, "orange")),
    "camel": ("noun", ["animals"], "A tan camel with a hump.",
        lambda: e(170, 126, 64, 28, "orange") + c(150, 96, 20, "orange") + c(236, 100, 16, "orange") + s("M220 118Q230 110 232 92", "orange", 12)
        + r(120, 146, 12, 34, "brown") + r(146, 146, 12, 34, "brown") + r(196, 146, 12, 34, "brown") + r(222, 146, 12, 34, "brown")),
    "chain": ("noun", ["objects", "metal"], "A row of grey metal chain links.",
        lambda: ring(110, 110, 18, "grey", "none", 6) + ring(140, 110, 18, "grey", "none", 6) + ring(170, 110, 18, "grey", "none", 6) + ring(200, 110, 18, "grey", "none", 6) + ring(230, 110, 18, "grey", "none", 6)),
    "chimney": ("noun", ["home", "buildings"], "A house with a brown chimney and smoke.",
        lambda: p("M70 110L170 50L270 110Z", "orange") + r(90, 110, 160, 70, "skin", 4) + r(210, 60, 24, 50, "brown", 3) + c(222, 44, 8, "greyShade") + c(236, 30, 6, "greyShade") + ground(50, 290)),
    "cookie": ("noun", ["food"], "A round chocolate chip cookie.",
        lambda: c(170, 110, 58, "skinShade") + c(170, 110, 50, "skin") + c(150, 96, 6, "brown") + c(190, 118, 6, "brown") + c(176, 94, 5, "brown") + c(156, 126, 5, "brown") + c(200, 98, 4, "brown")),
    "crab": ("noun", ["animals", "sea"], "An orange crab with large claws.",
        lambda: e(170, 130, 62, 30, "orange") + c(104, 100, 18, "orange") + c(236, 100, 18, "orange") + ln(130, 146, 100, 170, "orange", 5) + ln(146, 150, 126, 176, "orange", 5)
        + ln(210, 150, 234, 176, "orange", 5) + ln(194, 146, 220, 170, "orange", 5) + ln(160, 110, 160, 96, "ink", 3) + ln(180, 110, 180, 96, "ink", 3)),
    "crown": ("noun", ["royalty", "objects"], "A gold crown with three points and a red jewel.",
        lambda: p("M100 140L100 70L135 100L170 50L205 100L240 70L240 140Z", "orange") + r(100, 130, 140, 18, "orange", 4) + c(170, 58, 6, "teal") + c(120, 80, 5, "teal") + c(220, 80, 5, "teal")),
    "donkey": ("noun", ["animals"], "A grey donkey with long ears.",
        lambda: e(170, 118, 60, 28, "greyShade") + c(232, 84, 20, "greyShade") + p("M226 66L222 40L234 64Z", "greyShade") + p("M240 66L246 40L250 66Z", "greyShade")
        + r(130, 140, 12, 36, "greyShade") + r(186, 140, 12, 36, "greyShade") + s("M108 110Q90 130 96 150", "greyShade", 4) + ground(60, 280)),
    "envelope": ("noun", ["post", "objects"], "A cream envelope with a stamp.",
        lambda: r(80, 80, 180, 100, "cream", 6) + ln(80, 80, 170, 130, "sandBorder", 3) + ln(260, 80, 170, 130, "sandBorder", 3) + r(230, 96, 22, 22, "orange", 3)),
    "feather": ("noun", ["nature", "animals"], "A teal feather with a dark spine.",
        lambda: p("M170 30Q220 80 210 130Q190 170 170 180Q150 170 130 130Q120 80 170 30Z", "teal") + ln(170, 40, 170, 176, "deepTeal", 3) + ln(170, 80, 195, 100, "deepTeal", 2) + ln(170, 110, 150, 130, "deepTeal", 2)),
    "fence": ("noun", ["outdoors"], "A wooden fence with vertical pickets.",
        lambda: r(60, 110, 220, 8, "brown", 3) + r(60, 140, 220, 8, "brown", 3)
        + "".join(r(x, 90, 14, 90, "brown", 2) for x in range(70, 250, 36)) + ground(40, 300)),
    "fox": ("noun", ["animals"], "An orange fox with a white-tipped tail.",
        lambda: e(170, 124, 56, 26, "orange") + c(232, 104, 22, "orange") + p("M222 88L226 62L240 86Z", "orange") + p("M240 86L252 64L252 90Z", "orange")
        + p("M114 124Q80 110 70 140Q100 150 116 134Z", "orange") + r(140, 142, 10, 34, "brown") + r(190, 142, 10, 34, "brown") + c(248, 108, 4, "ink") + ground(60, 280)),
    "frame": ("noun", ["home", "art"], "A brown picture frame with a green landscape.",
        lambda: r(90, 50, 160, 120, "brown", 6) + r(104, 64, 132, 92, "cream", 4) + p("M104 150L150 100L180 124L210 96L236 150Z", "green") + c(204, 84, 8, "orange")),
    "garage": ("noun", ["buildings", "home"], "A grey garage with a closed door.",
        lambda: p("M70 120L170 50L270 120Z", "grey") + r(90, 120, 160, 60, "grey", 4) + r(120, 130, 100, 50, "brown", 2)
        + ln(120, 140, 220, 140, "greyShade", 2) + ln(120, 156, 220, 156, "greyShade", 2) + ground(50, 290)),
    "ghost": ("noun", ["fiction"], "A white ghost with dark eyes and a wavy hem.",
        lambda: p("M110 170L110 100Q110 50 170 50Q230 50 230 100L230 170L214 156L198 170L182 156L170 170L154 156L138 170L122 156Z", "cream")
        + c(146, 100, 6, "ink") + c(194, 100, 6, "ink")),
    "goat": ("noun", ["animals"], "A cream goat with small horns and a beard.",
        lambda: e(170, 126, 60, 28, "cream") + c(230, 96, 20, "cream") + ln(224, 80, 218, 58, "brown", 3) + ln(238, 80, 246, 58, "brown", 3)
        + p("M236 112L232 130L240 116Z", "brown") + r(128, 140, 10, 38, "brown") + r(190, 140, 10, 38, "brown") + r(218, 140, 10, 38, "brown") + ground(60, 280)),
    "goose": ("noun", ["animals"], "A white goose with a long neck and orange beak.",
        lambda: e(160, 130, 60, 30, "cream") + s("M210 120Q230 80 220 50", "cream", 12) + c(222, 44, 12, "cream") + p("M232 44L250 50L232 54Z", "orange")
        + ln(150, 156, 150, 176, "orange", 4) + ln(170, 156, 170, 176, "orange", 4)),
    "hammock": ("noun", ["outdoors", "leisure"], "An orange hammock tied between two posts.",
        lambda: r(40, 80, 10, 100, "brown", 3) + r(290, 80, 10, 100, "brown", 3) + p("M70 110Q170 160 270 110L270 120Q170 170 70 120Z", "orange") + ln(50, 90, 70, 110, "brown", 2) + ln(290, 90, 270, 110, "brown", 2)),
    "hen": ("noun", ["animals"], "A white hen with a red comb.",
        lambda: e(160, 130, 50, 34, "cream") + c(206, 96, 18, "cream") + c(206, 76, 8, "orange") + p("M222 96L236 100L222 104Z", "orange")
        + p("M114 120Q90 100 104 84Q120 106 126 124Z", "cream") + ln(150, 156, 150, 176, "orange", 4) + ln(170, 156, 170, 176, "orange", 4)),
    "hill": ("noun", ["nature", "geography"], "A green hill with a tree on the slope.",
        lambda: p("M30 180Q170 40 310 180Z", "green") + p("M120 180Q200 90 280 180Z", "deepTeal") + c(90, 130, 12, "green") + r(88, 140, 4, 20, "brown")),
    "honey": ("noun", ["food"], "A jar of golden honey with a lid.",
        lambda: p("M120 100L220 100L212 170Q170 180 128 170Z", "orange") + r(120, 80, 100, 24, "brown", 4) + ln(130, 118, 210, 118, "sandBorder", 3) + c(160, 140, 8, "skinShade") + c(190, 150, 6, "skinShade")),
    "hook": ("noun", ["objects"], "A grey metal hook with a rounded end.",
        lambda: r(164, 30, 12, 14, "grey", 2) + ln(150, 26, 190, 26, "grey", 4) + c(170, 36, 5, "orange") + s("M170 40Q200 40 200 70Q200 100 170 120Q140 140 150 160Q160 176 176 170", "grey", 6)),
    "horn": ("noun", ["music", "animals"], "A curved orange horn with brown rings.",
        lambda: p("M70 150Q140 150 260 60L272 90Q170 150 70 150Z", "orange") + ln(120, 140, 200, 110, "brown", 2) + ln(160, 126, 240, 84, "brown", 2)),
    "iceberg": ("noun", ["nature", "sea"], "A white iceberg floating on blue water.",
        lambda: p("M70 170L130 90L170 120L210 60L270 170Z", "cream") + p("M170 120L210 60L240 140Z", "teal") + r(30, 166, 280, 12, "teal", 4)),
    "jar": ("noun", ["kitchen", "objects"], "A glass jar with a brown lid.",
        lambda: p("M120 100L220 100L220 150Q220 170 200 170L140 170Q120 170 120 150Z", "teal") + r(130, 80, 80, 22, "brown", 4) + ln(130, 120, 210, 120, "cream", 3) + ground(70, 270)),
    "jug": ("noun", ["kitchen"], "A teal jug with a handle and a spout.",
        lambda: p("M120 80L220 80L230 150Q230 170 210 170L130 170Q110 170 110 150Z", "teal") + s("M220 100Q250 110 230 140", "teal", 6) + e(170, 80, 50, 8, "deepTeal") + ground(70, 270)),
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
            "style": "flat_color", "contexts": ["dictionary_entry"], "version": 1, "tags": ["b1"] + tags,
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
