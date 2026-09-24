#!/usr/bin/env python3
"""Add curated A2-C1 dictionary illustrations in the line art style."""

import json
import re

from generate_a1_plates import ASSETS, BINDINGS, PROJECT, pictured
from word_line_art import line_art_svg


def drawing(content):
    return f'<g fill="none" stroke="#3A362E" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{content}</g>'


# Only words whose pictured meaning matches the app dictionary's first sense.
PLATES = {
    "a2": {
        "gift": (pictured("gift"), "A wrapped present with a ribbon."),
        "knife": (pictured("knife"), "A knife with a sharp blade and handle."),
        "lamp": (pictured("lamp"), "A table lamp giving light."),
        "moon": (pictured("moon"), "The Moon in the night sky."),
        "forest": (pictured("tree+tree+tree"), "A group of trees in a forest."),
        "ocean": (pictured("sea"), "The open ocean with waves."),
        "pilot": (pictured("person+plane"), "A pilot beside an aeroplane."),
        "bridge": (drawing('<path d="M29 141h284v18H29Z" fill="#9B7050"/><path d="M57 141V93c26-43 61-43 87 0v48m54 0V93c26-43 61-43 87 0v48" fill="#C99B58"/><path d="M42 122h258M33 161h275"/><path d="M28 164c29-10 47-10 75 0s47 10 75 0 47-10 75 0 47 10 61 0" stroke="#8FAEAA" stroke-width="6"/>'), "An arched bridge crossing water."),
        "frog": (drawing('<ellipse cx="171" cy="115" rx="65" ry="38" fill="#6E8571"/><circle cx="135" cy="75" r="19" fill="#6E8571"/><circle cx="207" cy="75" r="19" fill="#6E8571"/><circle cx="135" cy="74" r="9" fill="#F7F2E6"/><circle cx="207" cy="74" r="9" fill="#F7F2E6"/><circle cx="137" cy="74" r="4" fill="#3A362E"/><circle cx="205" cy="74" r="4" fill="#3A362E"/><path d="M135 128c18 12 54 12 72 0m-95 2-36 22m153-22 36 22"/>'), "A green frog with long hind legs."),
        "fridge": (drawing('<rect x="111" y="24" width="120" height="136" rx="5" fill="#A8B9AD"/><path d="M111 85h120M127 42v27m0 30v35M127 160v6m88-6v6" stroke-width="5"/><rect x="139" y="40" width="30" height="17" rx="3" fill="#F7F2E6"/>'), "A two-door refrigerator."),
    },
    "b1": {
        "coin": (pictured("coin"), "A round metal coin."),
        "flag": (pictured("flag"), "A flag flying from its pole."),
        "leaf": (pictured("leaf"), "A green leaf with visible veins."),
        "bee": (drawing('<ellipse cx="171" cy="107" rx="54" ry="37" fill="#D7B662"/><path d="M151 75v65m29-65v65" stroke="#584B3F" stroke-width="13"/><ellipse cx="137" cy="62" rx="27" ry="19" transform="rotate(-24 137 62)" fill="#F7F2E6"/><ellipse cx="205" cy="62" rx="27" ry="19" transform="rotate(24 205 62)" fill="#F7F2E6"/><circle cx="120" cy="103" r="5" fill="#3A362E"/><path d="m223 105 24 9-24 9m-100-44-16-16m23 14-1-23"/>'), "A bee with striped body and wings."),
        "bell": (drawing('<path d="M124 128V79c0-26 18-44 47-44s47 18 47 44v49l19 13H105Z" fill="#D7B662"/><circle cx="171" cy="147" r="14" fill="#B98A56"/><path d="M122 128h98M171 35V21m-49 54c4-14 11-23 22-28"/>'), "A metal bell with a clapper."),
        "diamond": (drawing('<path d="m171 28 72 53-72 82-72-82Z" fill="#A8B9AD"/><path d="M99 81h144m-100 0 28 82 28-82m-56 0 28-53 28 53" stroke="#F7F2E6" stroke-width="4"/>'), "A cut diamond gemstone."),
        "drum": (drawing('<ellipse cx="171" cy="66" rx="76" ry="24" fill="#F7F2E6"/><path d="M95 66v72c0 14 33 24 76 24s76-10 76-24V66" fill="#B97762"/><ellipse cx="171" cy="66" rx="76" ry="24" fill="#F7F2E6"/><path d="M95 66v72m152-72v72m-132-47 38 58m74-58-38 58m-47-59 48 59M123 31l48 35m52-35-52 35"/>'), "A round percussion drum with two sticks."),
        "rope": (drawing('<path d="M82 48c22-22 60-19 75 4 15 24-3 48-32 50-32 2-45-17-31-32 11-11 29-9 39-1m29-10c27-29 74-14 76 24 2 30-24 44-52 36-20-6-23-28-5-38 12-7 27-4 37 6m-69 40c-17 18-44 20-73 14m162-21c12 9 24 17 35 22" stroke="#9B7050" stroke-width="14"/><path d="m270 132 19 14m-18-12 13 17" stroke="#D7B662" stroke-width="3"/>'), "A thick rope arranged in loose loops."),
        "robot": (drawing('<rect x="116" y="33" width="110" height="88" rx="10" fill="#A8B9AD"/><rect x="129" y="121" width="84" height="37" rx="4" fill="#6E8571"/><circle cx="145" cy="75" r="10" fill="#F7F2E6"/><circle cx="197" cy="75" r="10" fill="#F7F2E6"/><path d="M148 103h46m-23-70V18m-45 117-29 18m119-18 29 18m-91 5v10m34-10v10" stroke-width="5"/><circle cx="171" cy="17" r="6" fill="#B97762"/>'), "A small mechanical robot."),
        "tent": (drawing('<path d="M63 151 171 35l108 116Z" fill="#6E8571"/><path d="M171 35v116m-26 0 26-58 26 58" fill="#C99B58"/><path d="m56 153 115-124 115 124M31 157h280"/><path d="m63 151-25 10m241-10 25 10" stroke-width="3"/>'), "A canvas camping tent with an entrance."),
    },
    # https://www.oxfordlearnersdictionaries.com/external/pdf/wordlists/oxford-3000-5000/The_Oxford_5000_by_CEFR_level.pdf
    "b2": {
        "ambulance": (drawing('<path d="M58 87h159v54H58Z" fill="#F7F2E6"/><path d="M217 102h48l25 39h-73Z" fill="#F7F2E6"/><path d="M66 88V65h145v22M48 141h255"/><rect x="107" y="92" width="48" height="42" fill="#A8B9AD"/><path d="M128 99v27m-13-13h27" stroke="#B97762" stroke-width="9"/><path d="M228 112h30l14 21h-44Z" fill="#A8B9AD"/><circle cx="98" cy="145" r="16" fill="#584B3F"/><circle cx="251" cy="145" r="16" fill="#584B3F"/>'), "An ambulance with a medical cross."),
        "basket": (drawing('<path d="M87 78h168l-17 79H104Z" fill="#B98A56"/><path d="M104 78c0-40 21-59 67-59s67 19 67 59M111 97h120m-115 22h110m-103 21h96m-103-62 14 79m28-79 4 79m28-79-4 79m27-79-14 79" stroke="#9B7050" stroke-width="4"/><path d="M87 78h168" stroke-width="6"/>'), "A woven basket with a curved handle."),
        "blanket": (drawing('<path d="M72 121V74c0-12 12-21 26-21h146c14 0 26 9 26 21v47Z" fill="#F7F2E6"/><path d="M73 103c42-20 77 10 111-10s61-20 86 2v56H73Z" fill="#6E8571"/><path d="M86 123h170m-168 15h164M70 151h203" stroke="#ECD9AF" stroke-width="4"/><path d="M82 62V44m178 18V44" stroke="#9B7050" stroke-width="6"/>'), "A warm blanket spread over a bed."),
        "brick": (drawing('<rect x="97" y="44" width="148" height="102" rx="2" fill="#B97762"/><path d="M97 94h148M145 44v50m50 0v52" stroke="#ECD9AF" stroke-width="6"/><path d="M78 148h185"/>'), "Red clay bricks laid in a staggered pattern."),
        "candle": (drawing('<rect x="139" y="63" width="64" height="97" rx="3" fill="#F7F2E6"/><path d="M171 63V49"/><path d="M171 17c-18 15-19 35 0 38 19-3 18-23 0-38Z" fill="#D7B662"/><path d="M171 31c-7 8-7 16 0 20" stroke="#B97762" stroke-width="4"/><path d="M139 84c18 9 43 9 64 0m-86 76h108"/>'), "A lit wax candle with a flame."),
        "cave": (drawing('<path d="M38 153c5-77 48-119 133-119s128 42 133 119Z" fill="#8C877C"/><path d="M107 153c3-46 25-70 64-70s61 24 64 70Z" fill="#584B3F"/><path d="M38 153h266m-128-70 7 28 7-20m-53-8-8 26-9-21"/><path d="M130 153c13-16 26-20 41-19s28 7 41 19" stroke="#C99B58" stroke-width="4"/>'), "A dark opening inside a rocky cave."),
        "cliff": (drawing('<path d="M29 149h138l14-126 40 27-5 57 31-10 13 52h55Z" fill="#9B7050"/><path d="m180 23 11 49-7 42m37-64 20 27-25 30m44-10-27 23" stroke="#785D3E" stroke-width="4"/><path d="M29 160c27-13 48-13 74 0s50 13 77 0 53-13 79 0 44 13 56 0" stroke="#8FAEAA" stroke-width="6"/>'), "A steep rock cliff above the sea."),
        "ladder": (drawing('<path d="M105 161 128 24m109 137L214 24M119 54h101m-106 27h110m-115 27h120m-125 27h130" stroke="#9B7050" stroke-width="9"/><path d="M72 163h198"/>'), "A wooden ladder with evenly spaced rungs."),
        "rocket": (drawing('<g transform="translate(171 91) scale(.78) translate(-171 -91)"><path d="M171 17c-28 27-41 69-34 110h68c7-41-6-83-34-110Z" fill="#F7F2E6"/><circle cx="171" cy="67" r="16" fill="#A8B9AD"/><path d="M137 106 108 137l29 7m68-38 29 31-29 7M157 127l-12 30h52l-12-30" fill="#B97762"/><path d="M154 158c0 16 8 25 17 31 9-6 17-15 17-31Z" fill="#D7B662"/><path d="M137 127h68"/></g>'), "A rocket with fins and a flame beneath it."),
        "worm": (drawing('<path d="M73 126c27-53 60-59 78-38 14 16-4 39 18 46 25 8 27-40 60-39 25 1 29 28 15 42" stroke="#B97762" stroke-width="21"/><circle cx="236" cy="111" r="4" fill="#3A362E"/><path d="m87 82-16-19m35 8-4-21m160 56 15-11" stroke="#6E8571" stroke-width="4"/><path d="M42 158h255"/>'), "A long soft-bodied worm curling across soil."),
    },
    "c1": {
        "anchor": (drawing('<path d="M171 58v93m-23-70h46M91 113c0 38 32 50 80 50s80-12 80-50m-160 0 22 16m-22-16 6 27m154-27-22 16m22-16-6 27" stroke="#584B3F" stroke-width="9"/><circle cx="171" cy="35" r="16" fill="#A8B9AD"/><path d="M171 51v20"/>'), "A ship's anchor with two curved arms."),
        "crystal": (drawing('<path d="m171 22 58 42-11 76-47 28-47-28-11-76Z" fill="#A8B9AD"/><path d="m171 22-22 46 22 100 22-100Zm-58 42 36 4-25 72m105-76-36 4 25 72m-94 0 47 28 47-28" stroke="#F7F2E6" stroke-width="4"/>'), "A faceted mineral crystal."),
        "dam": (drawing('<path d="M52 66h238l-30 93H82Z" fill="#8C877C"/><path d="M64 78h212M56 161c29-14 48-14 77 0s48 14 77 0 48-14 77 0" stroke="#8FAEAA" stroke-width="6"/><path d="M100 89h27v40h-27Zm58 0h27v40h-27Zm58 0h27v40h-27Z" fill="#584B3F"/><path d="M48 65h246"/>'), "A large dam holding back water."),
        "dawn": (drawing('<path d="M39 143h264"/><path d="M113 143a58 58 0 0 1 116 0Z" fill="#D7B662"/><path d="M171 34v26m-63-2 19 19m108-19-19 19M76 104h24m142 0h24" stroke="#C99B58" stroke-width="5"/><path d="M36 159c35-10 61-10 96 0s58 10 93 0 55-10 81 0" stroke="#8FAEAA" stroke-width="5"/>'), "The sun rising at dawn over the horizon."),
        "gear": (drawing('<g transform="translate(171 91) scale(.72) translate(-171 -91)"><path d="M151 27h40l5 16 19 8 16-8 28 28-8 16 8 19 16 5v40l-16 5-8 19 8 16-28 28-16-8-19 8-5 16h-40l-5-16-19-8-16 8-28-28 8-16-8-19-16-5v-40l16-5 8-19-8-16 28-28 16 8 19-8Z" fill="#8C877C" transform="translate(0 -30) scale(1 .88)"/><circle cx="171" cy="88" r="41" fill="#ECD9AF"/><circle cx="171" cy="88" r="12" fill="#F7F2E6"/></g>'), "A toothed mechanical gear wheel."),
        "kidney": (drawing('<path d="M139 27c-32-11-59 17-59 54 0 39 23 69 51 69 17 0 25-15 25-29 0-13-12-24-11-35 1-13 13-24 15-37 2-11-5-19-21-22Z" fill="#B97762"/><path d="M203 27c32-11 59 17 59 54 0 39-23 69-51 69-17 0-25-15-25-29 0-13 12-24 11-35-1-13-13-24-15-37-2-11 5-19 21-22Z" fill="#B97762"/><path d="M158 111c13 11 24 11 36 0m-36-24h36" stroke="#785D3E" stroke-width="4"/>'), "A pair of bean-shaped kidneys."),
        "nest": (drawing('<path d="M83 104c7 37 36 56 88 56s81-19 88-56Z" fill="#9B7050"/><path d="M83 104c58 22 118 22 176 0m-153 16c44 18 86 18 130 0m-116 17c33 12 69 12 102 0" stroke="#D7B662" stroke-width="5"/><ellipse cx="148" cy="94" rx="19" ry="25" fill="#F7F2E6"/><ellipse cx="192" cy="94" rx="19" ry="25" fill="#A8B9AD"/>'), "A bird's nest containing two eggs."),
        "radar": (drawing('<circle cx="171" cy="91" r="68" fill="#6E8571"/><circle cx="171" cy="91" r="45"/><circle cx="171" cy="91" r="21"/><path d="M171 23v136M103 91h136M171 91l46-47" stroke="#F7F2E6" stroke-width="3"/><path d="M171 91a62 62 0 0 1 42-47l-42 47Z" fill="#A8B9AD"/><circle cx="207" cy="70" r="5" fill="#D7B662"/>'), "A circular radar screen showing a detected object."),
        "sword": (drawing('<path d="m171 19 17 103-17 13-17-13Z" fill="#A8B9AD"/><path d="M171 25v102M128 128h86m-43 1v31" stroke="#584B3F" stroke-width="7"/><circle cx="171" cy="160" r="8" fill="#D7B662"/><path d="m130 128 9-13m73 13-9-13"/>'), "A long sword with a metal blade and hilt."),
        "warehouse": (drawing('<path d="M56 75 171 27l115 48v83H56Z" fill="#C99B58"/><path d="M47 75 171 21l124 54M56 158h230"/><path d="M121 100h100v58H121Z" fill="#584B3F"/><path d="M133 116h76m-76 15h76m-76 15h76" stroke="#A8B9AD" stroke-width="3"/><rect x="75" y="110" width="32" height="32" fill="#B98A56"/><rect x="235" y="110" width="32" height="32" fill="#B98A56"/>'), "A large warehouse with stacked storage crates."),
    },
}


def main():
    catalog = json.loads(BINDINGS.read_text())
    existing = {(item["lemma"], item["partOfSpeech"], item["style"])
                for item in catalog["assets"] if "dictionary_entry" in item["contexts"]}
    additions = []
    for level, words in PLATES.items():
        for word, (scene, alt) in words.items():
            if (word, "noun", "monochrome_line_art") in existing:
                continue
            name = f"word_{word}_plate"
            folder = ASSETS / f"{name}.imageset"
            if folder.exists():
                raise ValueError(f"Asset name collision: {folder}")
            folder.mkdir()
            svg = line_art_svg(f'<svg xmlns="http://www.w3.org/2000/svg">{scene}</svg>')
            (folder / f"{name}.svg").write_text(svg)
            (folder / "Contents.json").write_text(json.dumps({
                "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
                "info": {"author": "xcode", "version": 1},
                "properties": {"preserves-vector-representation": True},
            }, separators=(",", ":")) + "\n")
            catalog["assets"].append({
                "id": f"illustration.{word}.noun.plate",
                "word": word, "lemma": word, "partOfSpeech": "noun", "senseId": None,
                "assetName": name,
                "assetPath": f"Resources/IllustrationsSVG/Words.xcassets/{name}.imageset/{name}.svg",
                "style": "monochrome_line_art", "contexts": ["dictionary_entry"], "version": 1,
                "tags": [level, "visual"], "altText": alt, "isDecorative": False, "notes": None,
            })
            additions.append(name)

    BINDINGS.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n")
    project = PROJECT.read_text()
    start = project.index("\t\t\tinputPaths = (", project.index("/* Validate SVG illustrations */ = {"))
    end = project.index("\t\t\t);", start)
    inputs = "".join(
        f'\t\t\t\t"$(SRCROOT)/Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets/{name}.imageset/{filename}",\n'
        for name in sorted(additions) for filename in ("Contents.json", f"{name}.svg")
    )
    if inputs:
        PROJECT.write_text(project[:end] + inputs + project[end:])
    print(f"Added {len(additions)} CEFR dictionary illustrations")


if __name__ == "__main__":
    main()
