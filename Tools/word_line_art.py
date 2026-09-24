#!/usr/bin/env python3
"""Keep dictionary SVGs in the same simple line style as phrasal verb cards."""

import xml.etree.ElementTree as ET
from pathlib import Path


SVG = "{http://www.w3.org/2000/svg}"
ET.register_namespace("", "http://www.w3.org/2000/svg")
COLOR_WORDS = {"black", "blue", "brown", "green", "grey", "orange", "pink", "purple", "red", "white", "yellow"}


def is_color_swatch(name: str) -> bool:
    word = name.removeprefix("word_").removesuffix("_plate")
    return word in COLOR_WORDS - {"orange"} or word == "orange_adjective"


def line_art_svg(source: str, *, preserve_color: bool = False) -> str:
    root = ET.fromstring(source)
    if root.tag != SVG + "svg":
        raise ValueError("Expected an SVG root")

    # Old assets have a parchment frame and printed specimen label outside the drawing.
    if len(root) >= 3 and root[0].tag == SVG + "rect" and root[1].tag == SVG + "rect":
        root.remove(root[0])
        root.remove(root[0])
    for child in list(root):
        if child.tag == SVG + "text":
            root.remove(child)

    root.attrib.update({
        "width": "342", "height": "196", "viewBox": "0 0 342 196",
        "fill": "none", "stroke": "#3A362E", "stroke-width": "2.8",
        "stroke-linecap": "round", "stroke-linejoin": "round",
    })
    for element in root.iter():
        if element is root:
            continue
        color = element.get("fill")
        is_text = element.tag == SVG + "text"
        element.set("fill", "#3A362E" if is_text else color if preserve_color and element.tag == SVG + "circle" and color not in (None, "none") else "none")
        if is_text:
            element.set("stroke", "none")
        else:
            element.attrib.pop("stroke", None)
        element.attrib.pop("stroke-width", None)
        element.attrib.pop("stroke-linecap", None)
        element.attrib.pop("stroke-linejoin", None)
    return ET.tostring(root, encoding="unicode") + "\n"


def main() -> None:
    assets = Path(__file__).resolve().parents[1] / "Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets"
    count = 0
    for path in assets.glob("word_*_plate.imageset/*.svg"):
        source = path.read_text()
        if "No. " not in source:
            continue
        path.write_text(line_art_svg(source, preserve_color=is_color_swatch(path.stem)))
        count += 1
    print(f"Converted {count} dictionary illustrations")


if __name__ == "__main__":
    main()
