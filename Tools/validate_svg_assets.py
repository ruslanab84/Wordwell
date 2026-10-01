#!/usr/bin/env python3
"""Validate bundled word bindings and the small SVG subset used by Wordwell."""

import json
import hashlib
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from word_line_art import is_color_swatch


ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "Docs/04_SVG_ASSET_SPEC.json"
CATALOG = ROOT / "Packages/WordwellKit/Sources/WordwellData/Resources/IllustrationsSVG/illustration_bindings.json"
ASSETS = ROOT / "Packages/WordwellKit/Sources/WordwellDesign"
PHRASAL_CATALOG = ROOT / "Tools/PhrasalVerbs/phrasal_verbs.json"
PHRASAL_ASSETS = ASSETS / "Resources/IllustrationsSVG/PhrasalVerbs.xcassets"
PHAVE_LIST = ROOT / "Tools/PhrasalVerbs/phave_150.txt"
SVG_NS = "{http://www.w3.org/2000/svg}"
ALLOWED_TAGS = {"svg", "g", "path", "circle", "rect", "line", "ellipse", "polyline", "polygon", "text"}
ALLOWED_ATTRIBUTES = {
    "xmlns", "width", "height", "viewBox", "x", "y", "x1", "x2", "y1", "y2", "cx", "cy", "r", "rx", "ry",
    "d", "points", "fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin", "font-family",
    "font-style", "font-size", "text-anchor", "transform",
}


def check(condition, message):
    if not condition:
        raise ValueError(message)


def validate_svg(path, style):
    source = path.read_text()
    check("<!" not in source and "url(" not in source and "&" not in source, f"unsafe SVG content: {path}")
    root = ET.fromstring(source)
    check(root.tag == SVG_NS + "svg", f"SVG root or namespace missing: {path}")
    check(root.get("viewBox") is not None, f"viewBox missing: {path}")
    if style == "flat_color":
        check(root.get("viewBox") == "0 0 340 200", f"flat colour illustration size must be 340x200: {path}")
    elif path.stem.endswith("_plate"):
        check(root.get("viewBox") == "0 0 342 196", f"dictionary illustration size must be 342x196: {path}")
    if style == "flat_color":
        return  # palette, bounds and structure are enforced by Tools/svg-lint/svg_lint.py
    for element in root.iter():
        tag = element.tag.removeprefix(SVG_NS)
        check(element.tag.startswith(SVG_NS) and tag in ALLOWED_TAGS, f"unsupported SVG element {tag}: {path}")
        check(set(element.attrib) <= ALLOWED_ATTRIBUTES, f"unsupported SVG attribute: {path}")
        if style in {"monochrome_line_art", "color_swatch"}:
            swatch = style == "color_swatch" and tag == "circle" and element.get("fill") not in (None, "none")
            letter = tag == "text" and element.get("fill") == "#3A362E"
            check(element.get("fill", "none") == "none" or swatch or letter, f"line art must be unfilled: {path}")
            strokes = {"#3A362E", "currentColor"} | ({"none"} if letter else set())
            check(element.get("stroke", "#3A362E") in strokes, f"line art stroke color: {path}")
            if element.get("stroke-width"):
                check(1.4 <= float(element.get("stroke-width")) <= 2.8, f"line art stroke width: {path}")
            if element.get("stroke-linecap"):
                check(element.get("stroke-linecap") == "round", f"line art cap: {path}")
            if element.get("stroke-linejoin"):
                check(element.get("stroke-linejoin") == "round", f"line art join: {path}")
    if path.stem.endswith("_plate"):
        check(all(child.tag != SVG_NS + "text" for child in root), f"dictionary SVG has a printed caption: {path}")
    if style == "color_swatch":
        check(is_color_swatch(path.stem), f"unexpected color swatch: {path}")
        check(any(element.tag == SVG_NS + "circle" and element.get("fill") not in (None, "none") for element in root.iter()), f"empty color swatch: {path}")


def validate():
    schema = json.loads(SCHEMA.read_text())
    catalog = json.loads(CATALOG.read_text())
    binding_schema = schema["$defs"]["illustrationBinding"]
    properties = binding_schema["properties"]
    check(set(catalog) == {"schemaVersion", "assets"}, "catalog has unknown top-level fields")
    check(catalog["schemaVersion"] == schema["properties"]["schemaVersion"]["const"], "schema version mismatch")
    ids, lookup_keys = set(), set()
    for binding in catalog["assets"]:
        check(set(binding_schema["required"]) <= set(binding) <= set(properties), f"binding fields: {binding}")
        check(binding["id"] not in ids and binding["id"], f"duplicate/empty binding ID: {binding['id']}")
        ids.add(binding["id"])
        check(binding["word"].strip() and binding["lemma"].strip(), f"empty word/lemma: {binding['id']}")
        check(binding.get("partOfSpeech") in properties["partOfSpeech"]["enum"], f"part of speech: {binding['id']}")
        check(binding.get("senseId") is None or binding["senseId"].strip(), f"empty sense ID: {binding['id']}")
        check(binding["style"] in properties["style"]["enum"], f"style: {binding['id']}")
        check(isinstance(binding["version"], int) and binding["version"] >= 1, f"version: {binding['id']}")
        contexts = binding["contexts"]
        check(contexts and len(contexts) == len(set(contexts)), f"empty/duplicate contexts: {binding['id']}")
        allowed = {"dictionary_entry"} if binding["style"] == "color_swatch" else {"dictionary_entry", "header", "library", "review", "speaking"}
        check(set(contexts) <= allowed, f"style/context mismatch: {binding['id']}")
        check(binding["tags"] and len(binding["tags"]) == len(set(binding["tags"])) and all(binding["tags"]), f"tags: {binding['id']}")
        check(isinstance(binding["isDecorative"], bool), f"isDecorative: {binding['id']}")
        check(binding["isDecorative"] or bool((binding.get("altText") or "").strip()), f"alt text missing: {binding['id']}")
        name, asset_path = binding["assetName"], binding["assetPath"]
        check(re.fullmatch(properties["assetName"]["pattern"], name) is not None, f"asset name: {binding['id']}")
        check(re.fullmatch(properties["assetPath"]["pattern"], asset_path) is not None, f"asset path: {binding['id']}")
        check(asset_path.endswith(f"/{name}.imageset/{name}.svg"), f"asset name/path mismatch: {binding['id']}")
        check(name.endswith(("_plate", "_line")), f"asset name mismatch: {binding['id']}")
        path = ASSETS / asset_path
        check(path.is_file(), f"SVG missing: {path}")
        image_set = json.loads((path.parent / "Contents.json").read_text())
        check(image_set["images"][0]["filename"] == path.name and image_set["properties"]["preserves-vector-representation"] is True,
              f"vector image set invalid: {path.parent}")
        validate_svg(path, binding["style"])
        for context in contexts:
            key = (binding["lemma"].casefold(), binding.get("partOfSpeech"), binding.get("senseId"), context)
            check(key not in lookup_keys, f"duplicate word/context binding: {binding['id']}")
            lookup_keys.add(key)
    check(catalog["assets"], "catalog is empty")
    print(f"Validated {len(catalog['assets'])} SVG bindings")


def validate_phrasal_gallery():
    entries = json.loads(PHRASAL_CATALOG.read_text())
    check(isinstance(entries, list) and len(entries) == 300, "phrasal gallery must have 300 entries")
    fields = {"id", "phrase", "meaning", "example", "level", "imageAsset", "imageAlt"}
    ids, phrases, names, hashes = set(), set(), set(), set()
    for entry in entries:
        check(set(entry) == fields, f"phrasal entry fields: {entry.get('id')}")
        check(all(isinstance(value, str) and value.strip() for value in entry.values()), f"empty phrasal field: {entry.get('id')}")
        check(entry["level"] in {"A1–A2", "B1–B2", "C1"}, f"phrasal level: {entry['id']}")
        check(entry["id"] == re.sub(r"[^a-z0-9]+", "-", entry["phrase"].lower()).strip("-"), f"unstable ID: {entry['id']}")
        check(entry["imageAsset"] == "pv_" + entry["id"].replace("-", "_") + "_line", f"image/ID mismatch: {entry['id']}")
        check(entry["id"] not in ids and entry["phrase"].casefold() not in phrases, f"duplicate expression: {entry['phrase']}")
        check(entry["imageAsset"] not in names, f"reused phrasal image: {entry['imageAsset']}")
        check(len(entry["imageAlt"].split()) >= 5 and entry["imageAlt"].casefold() != entry["phrase"].casefold(),
              f"image description too short: {entry['id']}")
        ids.add(entry["id"])
        phrases.add(entry["phrase"].casefold())
        names.add(entry["imageAsset"])
        folder = PHRASAL_ASSETS / (entry["imageAsset"] + ".imageset")
        path = folder / (entry["imageAsset"] + ".svg")
        check(path.is_file(), f"phrasal SVG missing: {path}")
        metadata = json.loads((folder / "Contents.json").read_text())
        check(metadata["images"][0]["filename"] == path.name and metadata["properties"]["preserves-vector-representation"] is True,
              f"phrasal vector image set invalid: {folder}")
        validate_svg(path, "monochrome_line_art")
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        check(digest not in hashes, f"duplicate phrasal drawing: {path}")
        hashes.add(digest)
    check({path.stem for path in PHRASAL_ASSETS.glob("*/*.svg")} == names, "orphan or missing phrasal SVG")
    phave = {line.strip() for line in PHAVE_LIST.read_text().splitlines() if line.strip()}
    check(len(phave) == 150 and phave <= phrases, "PHaVE core expressions are missing")
    print(f"Validated {len(entries)} phrasal verbs and distinct SVG scenes")


if __name__ == "__main__":
    try:
        validate()
        if "--phrasal" in sys.argv:
            validate_phrasal_gallery()
    except (ValueError, KeyError, OSError, ET.ParseError, TypeError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
