#!/usr/bin/env python3
"""svg_lint: checks Wordwell word illustrations against design.md, section 4.

    python3 svg_lint.py Design/Illustrations          lint files or folders
    python3 svg_lint.py Design/Illustrations --fix    clean what can be fixed mechanically
    python3 svg_lint.py Design/Illustrations --json   machine-readable report

Exit code 1 when an error remains. Standard library only.
"""
from __future__ import annotations

import argparse
import json
import math
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, asdict
from pathlib import Path

SVG_NS = "http://www.w3.org/2000/svg"
PALETTE: dict[str, str] = json.loads((Path(__file__).with_name("palette.json")).read_text())
HEX_TO_TOKEN = {v: k for k, v in PALETTE.items()}

VIEWBOX = "0 0 340 200"
CARD = {"x": "1", "y": "1", "width": "338", "height": "198", "rx": "12", "fill": "sand", "stroke": "sandBorder", "stroke-width": "2"}
FRAME = {"x": "12", "y": "12", "width": "316", "height": "176", "rx": "5", "fill": "none", "stroke": "sandBorder", "stroke-width": "1.2"}
SUN_RADIUS = (66.0, 74.0)
SUN_CX, SUN_CY = (160.0, 190.0), (94.0, 106.0)
INNER = (12.0, 12.0, 328.0, 188.0)
CONTENT = (18.0, 18.0, 322.0, 182.0)
MAX_BYTES = 4096
MAX_SHAPES = 90
THIN_STROKES = {2.0, 2.5, 3.0, 4.0}
TUBE_MIN = 5.0
# Repo assets are named word_<lemma>_plate.svg (Xcode asset name); the bare lemma slug is also accepted.
FILENAME = re.compile(r"^(word_[a-z][a-z0-9_]*_plate|[a-z][a-z0-9-]*)\.svg$")

ALLOWED_TAGS = {"svg", "g", "rect", "circle", "ellipse", "line", "path", "polygon", "polyline"}
CLOSED = {"rect", "circle", "ellipse", "path", "polygon", "polyline"}
GEOMETRY = {"x", "y", "width", "height", "rx", "ry", "cx", "cy", "r", "x1", "y1", "x2", "y2", "d", "points", "transform"}
PAINT = {"fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin"}
ROOT_ATTRS = {"viewBox"}
DROPPABLE_TAGS = {"metadata", "title", "desc"}


@dataclass
class Issue:
    file: str
    rule: str
    where: str
    message: str


def local(tag: str) -> str:
    return tag.rsplit("}", 1)[-1] if "}" in tag else tag


def num(value: str | None, default: float = 0.0) -> float:
    try:
        return float(value) if value is not None else default
    except ValueError:
        return default


# ------------------------------------------------------------------ geometry

Matrix = tuple[float, float, float, float, float, float]
IDENTITY: Matrix = (1, 0, 0, 1, 0, 0)


def mul(m: Matrix, n: Matrix) -> Matrix:
    a, b, c, d, e, f = m
    p, q, r, s, t, u = n
    return (a * p + c * q, b * p + d * q, a * r + c * s, b * r + d * s, a * t + c * u + e, b * t + d * u + f)


def parse_transform(text: str | None) -> Matrix | None:
    """translate / scale / rotate only. None means unsupported."""
    matrix = IDENTITY
    if not text:
        return matrix
    for name, raw in re.findall(r"(\w+)\s*\(([^)]*)\)", text):
        args = [float(x) for x in re.findall(r"-?\d*\.?\d+(?:[eE][-+]?\d+)?", raw)]
        if name == "translate" and args:
            step: Matrix = (1, 0, 0, 1, args[0], args[1] if len(args) > 1 else 0)
        elif name == "scale" and args:
            step = (args[0], 0, 0, args[1] if len(args) > 1 else args[0], 0, 0)
        elif name == "rotate" and args:
            rad = math.radians(args[0])
            cos, sin = math.cos(rad), math.sin(rad)
            step = (cos, sin, -sin, cos, 0, 0)
            if len(args) == 3:
                step = mul(mul((1, 0, 0, 1, args[1], args[2]), step), (1, 0, 0, 1, -args[1], -args[2]))
        else:
            return None
        matrix = mul(matrix, step)
    return matrix


def apply(m: Matrix, x: float, y: float) -> tuple[float, float]:
    return m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]


def path_points(d: str) -> list[tuple[float, float]] | None:
    """Sampled points of an M/L/H/V/C/Q/Z path. None when it uses S/T/A."""
    tokens = re.findall(r"[MmLlHhVvCcSsQqTtAaZz]|-?\d*\.?\d+(?:[eE][-+]?\d+)?", d)
    pts: list[tuple[float, float]] = []
    i, cx, cy, sx, sy, cmd = 0, 0.0, 0.0, 0.0, 0.0, ""

    def read(n: int) -> list[float]:
        nonlocal i
        vals = [float(t) for t in tokens[i:i + n]]
        i += n
        return vals

    while i < len(tokens):
        if re.match(r"[A-Za-z]", tokens[i]):
            cmd = tokens[i]
            i += 1
            if cmd in "Zz":
                cx, cy = sx, sy
                continue
        if cmd in "SsTtAa" or not cmd:
            return None
        rel = cmd.islower()
        c = cmd.upper()
        ox, oy = (cx, cy) if rel else (0.0, 0.0)
        if c == "M" or c == "L":
            x, y = read(2)
            cx, cy = ox + x, oy + y
            if c == "M":
                sx, sy = cx, cy
                cmd = "l" if rel else "L"
            pts.append((cx, cy))
        elif c == "H":
            (x,) = read(1)
            cx = ox + x
            pts.append((cx, cy))
        elif c == "V":
            (y,) = read(1)
            cy = oy + y
            pts.append((cx, cy))
        elif c == "C":
            x1, y1, x2, y2, x, y = read(6)
            p0, p1, p2, p3 = (cx, cy), (ox + x1, oy + y1), (ox + x2, oy + y2), (ox + x, oy + y)
            for k in range(1, 25):
                t = k / 24
                u = 1 - t
                pts.append((u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0],
                            u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1]))
            cx, cy = p3
        elif c == "Q":
            x1, y1, x, y = read(4)
            p0, p1, p2 = (cx, cy), (ox + x1, oy + y1), (ox + x, oy + y)
            for k in range(1, 25):
                t = k / 24
                u = 1 - t
                pts.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0], u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
            cx, cy = p2
    return pts


def local_points(el: ET.Element, tag: str) -> list[tuple[float, float]] | None:
    g = el.get
    if tag == "rect":
        x, y, w, h = num(g("x")), num(g("y")), num(g("width")), num(g("height"))
        return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
    if tag == "circle":
        x, y, r = num(g("cx")), num(g("cy")), num(g("r"))
        return [(x - r, y - r), (x + r, y + r), (x - r, y + r), (x + r, y - r)]
    if tag == "ellipse":
        x, y, rx, ry = num(g("cx")), num(g("cy")), num(g("rx")), num(g("ry"))
        return [(x - rx, y - ry), (x + rx, y + ry), (x - rx, y + ry), (x + rx, y - ry)]
    if tag == "line":
        return [(num(g("x1")), num(g("y1"))), (num(g("x2")), num(g("y2")))]
    if tag in ("polygon", "polyline"):
        values = [float(v) for v in re.findall(r"-?\d*\.?\d+", g("points") or "")]
        return list(zip(values[0::2], values[1::2]))
    if tag == "path":
        return path_points(g("d") or "")
    return []


# ------------------------------------------------------------------ paint

def paint_token(value: str | None) -> str | None:
    """Palette token for a paint value, 'none', or None when it is not a palette colour."""
    if value is None:
        return None
    if value == "none":
        return "none"
    return HEX_TO_TOKEN.get(value)


# ------------------------------------------------------------------ lint

def lint_tree(root: ET.Element, name: str, size: int) -> list[Issue]:
    issues: list[Issue] = []

    def add(rule: str, where: str, message: str) -> None:
        issues.append(Issue(name, rule, where, message))

    if not FILENAME.match(Path(name).name):
        add("filename", "file", "use a lowercase lemma slug: letters, digits and hyphens, e.g. 'ice-cream.svg'")
    if size > MAX_BYTES:
        add("size", "file", f"{size} bytes, limit {MAX_BYTES}. Run --fix to strip metadata and whitespace")

    if local(root.tag) != "svg":
        add("root", "<root>", "root element must be <svg>")
        return issues
    if root.get("viewBox") != VIEWBOX:
        add("viewbox", "<svg>", f'viewBox must be exactly "{VIEWBOX}", found "{root.get("viewBox")}"')
    for attr in ("width", "height"):
        if attr in root.attrib:
            add("root-size", "<svg>", f"remove {attr}: the app scales the artwork, fixed sizes break layout")
    for attr in root.attrib:
        if attr not in ROOT_ATTRS | {"width", "height"}:
            add("attribute", "<svg>", f"attribute '{attr}' is not allowed on the root")

    shapes: list[tuple[str, ET.Element, dict, Matrix | None]] = []
    counter = 0

    def walk(el: ET.Element, inherited: dict, matrix: Matrix | None, top: bool) -> None:
        nonlocal counter
        for child in el:
            tag = local(child.tag)
            counter += 1
            where = f"#{counter} <{tag}>"
            if "}" in child.tag and not child.tag.startswith("{" + SVG_NS):
                add("foreign-namespace", where, "elements from other namespaces are not allowed")
                continue
            if tag not in ALLOWED_TAGS:
                hint = " (run --fix)" if tag in DROPPABLE_TAGS else ""
                add("element", where, f"<{tag}> is not allowed{hint}. Allowed: {', '.join(sorted(ALLOWED_TAGS - {'svg'}))}")
                continue

            for attr in child.attrib:
                if attr in ("opacity", "fill-opacity", "stroke-opacity"):
                    add("opacity", where, f"{attr} is not allowed: use a palette colour, not transparency")
                elif attr not in GEOMETRY | PAINT:
                    add("attribute", where, f"attribute '{attr}' is not allowed")

            paint = dict(inherited)
            for attr in PAINT:
                if attr in child.attrib:
                    paint[attr] = child.attrib[attr]
            for attr in ("fill", "stroke"):
                if attr in child.attrib:
                    value = child.attrib[attr]
                    if paint_token(value) is None:
                        if value.upper() in HEX_TO_TOKEN:
                            add("hex-case", where, f"{attr}=\"{value}\": write hex in uppercase (run --fix)")
                        else:
                            add("palette", where, f"{attr}=\"{value}\" is not in the palette (palette.json)")

            own = parse_transform(child.get("transform"))
            if own is None:
                add("transform", where, "only translate, scale and rotate are supported")
                cumulative = None
            else:
                cumulative = mul(matrix, own) if matrix is not None else None

            if tag == "g":
                walk(child, paint, cumulative, False)
                continue

            shapes.append((where, child, paint, cumulative))

    walk(root, {}, IDENTITY, True)
    top_shapes = [c for c in root if local(c.tag) in ALLOWED_TAGS and local(c.tag) != "g"]

    # --- structure: card, inner frame, sun
    def matches(el: ET.Element, spec: dict) -> bool:
        for key, want in spec.items():
            have = el.get(key)
            if key in ("fill", "stroke"):
                if paint_token(have) != ("none" if want == "none" else want):
                    return False
            elif have is None or abs(num(have) - num(want)) > 1e-9:
                return False
        return True

    children = [c for c in root if "}" not in c.tag or c.tag.startswith("{" + SVG_NS)]
    children = [c for c in children if local(c.tag) not in DROPPABLE_TAGS]
    if len(children) < 3:
        add("structure", "<svg>", "expected card, inner frame and sun before the artwork")
    else:
        if local(children[0].tag) != "rect" or not matches(children[0], CARD):
            add("card", "#1", "first element must be the card rect: x=1 y=1 width=338 height=198 rx=12, fill sand, stroke sandBorder 2")
        if local(children[1].tag) != "rect" or not matches(children[1], FRAME):
            add("frame", "#2", "second element must be the inner frame: x=12 y=12 width=316 height=176 rx=5, fill none, stroke sandBorder 1.2")
        sun = children[2]
        if local(sun.tag) != "circle" or paint_token(sun.get("fill")) != "halo":
            add("sun", "#3", "third element must be the sun: a circle filled with halo")
        else:
            r, cx, cy = num(sun.get("r")), num(sun.get("cx")), num(sun.get("cy"))
            if not SUN_RADIUS[0] <= r <= SUN_RADIUS[1]:
                add("sun", "#3", f"sun radius {r:g} must be between {SUN_RADIUS[0]:g} and {SUN_RADIUS[1]:g}")
            if not (SUN_CX[0] <= cx <= SUN_CX[1] and SUN_CY[0] <= cy <= SUN_CY[1]):
                add("sun", "#3", f"sun centre ({cx:g}, {cy:g}) must be near the middle: x {SUN_CX[0]:g}–{SUN_CX[1]:g}, y {SUN_CY[0]:g}–{SUN_CY[1]:g}")
            if cx - r < INNER[0] or cx + r > INNER[2] or cy - r < INNER[1] or cy + r > INNER[3]:
                add("sun", "#3", "sun must stay inside the inner frame")

    artwork = shapes[3:] if len(shapes) >= 3 else []
    if len(shapes) >= 3 and len(artwork) < 3:
        add("empty-art", "<svg>", "the artwork needs at least 3 shapes after the sun")
    if len(shapes) > MAX_SHAPES:
        add("complexity", "<svg>", f"{len(shapes)} shapes, limit {MAX_SHAPES}. Simplify: one hero object, few details")

    # --- per-shape rules: colours, strokes, bounds
    for index, (where, el, paint, matrix) in enumerate(shapes):
        tag = local(el.tag)
        is_frame = index < 3
        fill, stroke = paint.get("fill"), paint.get("stroke")

        if tag in CLOSED and fill is None:
            add("implicit-fill", where, "no fill set: SVG would paint it black. Use a palette colour or fill=\"none\"")
        if tag == "line" and stroke in (None, "none"):
            add("implicit-stroke", where, "a line without stroke is invisible")

        width = 0.0
        if stroke not in (None, "none"):
            raw = paint.get("stroke-width")
            if raw is None:
                add("stroke-width", where, "stroke-width must be set explicitly")
            else:
                width = num(raw)
                if not is_frame:
                    if width < TUBE_MIN and width not in THIN_STROKES:
                        add("stroke-width", where, f"stroke-width {raw}: detail lines use {sorted(THIN_STROKES)}")
                    if width >= TUBE_MIN and paint.get("stroke-linecap") != "round":
                        add("tube-cap", where, f"strokes of {TUBE_MIN:g}+ act as shapes and need stroke-linecap=\"round\"")

        if is_frame or index == 2:
            continue
        if matrix is None:
            continue
        points = local_points(el, tag)
        if points is None:
            add("path-command", where, "path uses S, T or A commands; use M L H V C Q Z so bounds can be checked")
            continue
        if not points:
            continue
        moved = [apply(matrix, x, y) for x, y in points]
        scale = math.sqrt(abs(matrix[0] * matrix[3] - matrix[1] * matrix[2]))
        pad = width * scale / 2
        left = min(p[0] for p in moved) - pad
        top = min(p[1] for p in moved) - pad
        right = max(p[0] for p in moved) + pad
        bottom = max(p[1] for p in moved) + pad
        if left < CONTENT[0] or top < CONTENT[1] or right > CONTENT[2] or bottom > CONTENT[3]:
            add("bounds", where, f"extends to x {left:.1f}–{right:.1f}, y {top:.1f}–{bottom:.1f}; keep artwork inside x {CONTENT[0]:g}–{CONTENT[2]:g}, y {CONTENT[1]:g}–{CONTENT[3]:g}")

    return issues


# ------------------------------------------------------------------ fix

def fix_tree(root: ET.Element) -> None:
    for parent in list(root.iter()):
        for child in list(parent):
            if local(child.tag) in DROPPABLE_TAGS:
                parent.remove(child)
    for attr in ("width", "height"):
        root.attrib.pop(attr, None)
    for el in root.iter():
        for attr in ("fill", "stroke"):
            value = el.get(attr)
            if value and value.startswith("#") and value.upper() in HEX_TO_TOKEN:
                el.set(attr, value.upper())
        if el.text and not el.text.strip():
            el.text = None
        if el.tail and not el.tail.strip():
            el.tail = None


def serialise(root: ET.Element) -> str:
    ET.register_namespace("", SVG_NS)
    text = ET.tostring(root, encoding="unicode")
    return text.replace(" />", "/>") + "\n"


# ------------------------------------------------------------------ cli

def collect(paths: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        p = Path(raw)
        files += sorted(p.rglob("*.svg")) if p.is_dir() else [p]
    return files


def lint_file(path: Path, fix: bool) -> list[Issue]:
    try:
        root = ET.fromstring(path.read_text(encoding="utf-8"))
    except ET.ParseError as error:
        return [Issue(str(path), "xml", "file", f"not valid XML: {error}")]
    if fix:
        fix_tree(root)
        path.write_text(serialise(root), encoding="utf-8")
    return lint_tree(root, str(path), path.stat().st_size)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Lint Wordwell illustrations against design.md")
    parser.add_argument("paths", nargs="+", help="SVG files or folders")
    parser.add_argument("--fix", action="store_true", help="strip metadata/title/desc and size attributes, uppercase hex, minify")
    parser.add_argument("--json", action="store_true", help="print a JSON report")
    args = parser.parse_args(argv)

    missing = [p for p in args.paths if not Path(p).exists()]
    if missing:
        print(f"Not found: {', '.join(missing)}", file=sys.stderr)
        return 2
    files = collect(args.paths)
    if not files:
        print("No SVG files found.", file=sys.stderr)
        return 2

    all_issues: list[Issue] = []
    for path in files:
        all_issues += lint_file(path, args.fix)

    if args.json:
        print(json.dumps({"files": len(files), "errors": [asdict(i) for i in all_issues]}, indent=2, ensure_ascii=False))
    else:
        for issue in all_issues:
            print(f"{issue.file}: error [{issue.rule}] {issue.where}: {issue.message}")
        verb = "fixed and checked" if args.fix else "checked"
        print(f"{verb} {len(files)} file(s): {len(all_issues)} error(s)")
    return 1 if all_issues else 0


if __name__ == "__main__":
    sys.exit(main())
