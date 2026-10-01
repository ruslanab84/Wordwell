import re
import tempfile
import unittest
from pathlib import Path

import svg_lint

ROOT = Path(__file__).resolve().parents[2]
ILLUSTRATIONS = ROOT / "Design" / "Illustrations"

HEAD = (
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 340 200">'
    '<rect x="1" y="1" width="338" height="198" rx="12" fill="#EDD9AE" stroke="#BD9F66" stroke-width="2"/>'
    '<rect x="12" y="12" width="316" height="176" rx="5" fill="none" stroke="#BD9F66" stroke-width="1.2"/>'
    '<circle cx="170" cy="100" r="70" fill="#E8C486"/>'
)
ART = '<rect x="100" y="60" width="80" height="80" fill="#2E6F6A"/><circle cx="220" cy="120" r="20" fill="#E5A648"/><line x1="60" y1="170" x2="280" y2="170" stroke="#7A5535" stroke-width="4" stroke-linecap="round"/>'


def svg(art: str = ART, head: str = HEAD, root_attrs: str = "") -> str:
    document = head + art + "</svg>"
    return document.replace("<svg ", f"<svg {root_attrs} ", 1) if root_attrs else document


def rules(text: str, name: str = "sample.svg") -> set[str]:
    with tempfile.TemporaryDirectory() as folder:
        path = Path(folder) / name
        path.write_text(text, encoding="utf-8")
        return {issue.rule for issue in svg_lint.lint_file(path, fix=False)}


class ShippedIllustrations(unittest.TestCase):
    def test_all_pass(self):
        files = sorted(ILLUSTRATIONS.glob("*.svg"))
        self.assertGreaterEqual(len(files), 5)
        for path in files:
            issues = svg_lint.lint_file(path, fix=False)
            self.assertEqual(issues, [], f"{path.name}: {issues}")

    def test_no_text_and_no_metadata(self):
        for path in ILLUSTRATIONS.glob("*.svg"):
            content = path.read_text()
            self.assertNotIn("<text", content, path.name)
            self.assertNotIn("<metadata", content, path.name)

    def test_design_md_palette_table_matches_palette_json(self):
        table = (ROOT / "design.md").read_text()
        rows = dict(re.findall(r"^\|\s*`(\w+)`\s*\|\s*`(#[0-9A-F]{6})`", table, re.M))
        self.assertEqual(rows, svg_lint.PALETTE)


class Rules(unittest.TestCase):
    def test_valid_sample_passes(self):
        self.assertEqual(rules(svg()), set())

    def test_viewbox_and_size_attributes(self):
        self.assertIn("viewbox", rules(svg().replace("0 0 340 200", "0 0 100 100")))
        self.assertIn("root-size", rules(svg(root_attrs='width="680" height="400"')))

    def test_text_is_forbidden(self):
        self.assertIn("element", rules(svg(ART + '<text x="20" y="170">01</text>')))

    def test_gradient_filter_image_metadata_forbidden(self):
        for extra in ('<linearGradient id="g"/>', '<filter id="f"/>', '<image href="a.png"/>', "<metadata>x</metadata>", "<title>t</title>"):
            self.assertIn("element", rules(svg(ART + extra)), extra)

    def test_colour_must_come_from_palette(self):
        self.assertIn("palette", rules(svg(ART.replace("#2E6F6A", "#FF0000"))))
        self.assertIn("palette", rules(svg(ART.replace("#2E6F6A", "red"))))
        self.assertIn("palette", rules(svg(ART.replace("#2E6F6A", "#000"))))

    def test_hex_must_be_uppercase(self):
        self.assertIn("hex-case", rules(svg(ART.replace("#2E6F6A", "#2e6f6a"))))

    def test_missing_fill_would_paint_black(self):
        self.assertIn("implicit-fill", rules(svg(ART + '<rect x="100" y="60" width="20" height="20"/>')))

    def test_opacity_and_style_forbidden(self):
        self.assertIn("opacity", rules(svg(ART.replace('fill="#2E6F6A"', 'fill="#2E6F6A" opacity="0.5"'))))
        self.assertIn("attribute", rules(svg(ART + '<rect x="100" y="60" width="9" height="9" style="fill:#000"/>')))

    def test_stroke_widths(self):
        self.assertIn("stroke-width", rules(svg(ART.replace('stroke-width="4"', 'stroke-width="3.3"'))))
        self.assertIn("tube-cap", rules(svg(ART.replace('stroke-width="4" stroke-linecap="round"', 'stroke-width="12"'))))
        self.assertIn("stroke-width", rules(svg(ART.replace(' stroke-width="4"', ""))))

    def test_frame_card_and_sun_are_required_and_exact(self):
        self.assertIn("card", rules(svg(head=HEAD.replace('rx="12"', 'rx="6"'))))
        self.assertIn("frame", rules(svg(head=HEAD.replace('stroke-width="1.2"', 'stroke-width="3"'))))
        self.assertIn("sun", rules(svg(head=HEAD.replace('r="70"', 'r="40"'))))
        self.assertIn("sun", rules(svg(head=HEAD.replace('fill="#E8C486"', 'fill="#2E6F6A"'))))
        self.assertIn("sun", rules(svg(head=HEAD.replace('cx="170"', 'cx="250"'))))

    def test_artwork_must_stay_inside_the_content_box(self):
        self.assertIn("bounds", rules(svg(ART + '<rect x="10" y="60" width="30" height="30" fill="#5A7F4A"/>')))
        self.assertIn("bounds", rules(svg(ART + '<circle cx="170" cy="184" r="6" fill="#5A7F4A"/>')))
        # stroke width counts: a 20-wide tube centred on the edge sticks out
        self.assertIn("bounds", rules(svg(ART + '<line x1="60" y1="176" x2="200" y2="176" stroke="#7A5535" stroke-width="20" stroke-linecap="round"/>')))

    def test_bounds_follow_transforms_and_paths(self):
        inside = '<g transform="translate(20,10) scale(0.5)"><rect x="100" y="100" width="100" height="100" fill="#5A7F4A"/></g>'
        outside = '<g transform="translate(300,10)"><rect x="0" y="100" width="100" height="40" fill="#5A7F4A"/></g>'
        self.assertNotIn("bounds", rules(svg(ART + inside)))
        self.assertIn("bounds", rules(svg(ART + outside)))
        self.assertIn("bounds", rules(svg(ART + '<path d="M100 100 C 100 300 200 300 200 100" fill="#5A7F4A"/>')))
        self.assertNotIn("bounds", rules(svg(ART + '<path d="M100 100 C 100 150 200 150 200 100Z" fill="#5A7F4A"/>')))

    def test_unsupported_path_commands_and_transforms_are_reported(self):
        self.assertIn("path-command", rules(svg(ART + '<path d="M100 100 A20 20 0 0 1 140 100Z" fill="#5A7F4A"/>')))
        self.assertIn("transform", rules(svg(ART + '<rect x="100" y="60" width="9" height="9" fill="#5A7F4A" transform="skewX(10)"/>')))

    def test_filename_size_and_complexity(self):
        self.assertIn("filename", rules(svg(), name="Elephant 2.svg"))
        self.assertIn("size", rules(svg(ART + "<g>" + "<!-- pad -->" * 400 + "</g>")))
        many = '<rect x="100" y="60" width="4" height="4" fill="#5A7F4A"/>' * 91
        self.assertIn("complexity", rules(svg(many)))

    def test_empty_artwork(self):
        self.assertIn("empty-art", rules(svg(art='<rect x="100" y="60" width="9" height="9" fill="#5A7F4A"/>')))

    def test_invalid_xml(self):
        self.assertIn("xml", rules("<svg><rect></svg>"))


class Fix(unittest.TestCase):
    def test_fix_removes_metadata_sizes_and_normalises(self):
        dirty = svg(ART.replace("#2E6F6A", "#2e6f6a"), root_attrs='width="680" height="400" xmlns:c2pa="http://c2pa.org/manifest"')
        dirty = dirty.replace("</svg>", '<metadata><c2pa:manifest xmlns:c2pa="http://c2pa.org/manifest">AAAA</c2pa:manifest></metadata></svg>')
        dirty = dirty.replace("<rect x=\"100\"", "\n  <rect x=\"100\"")
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "sample.svg"
            path.write_text(dirty, encoding="utf-8")
            before = svg_lint.lint_file(path, fix=False)
            self.assertTrue({"element", "root-size", "hex-case"} <= {i.rule for i in before})
            after = svg_lint.lint_file(path, fix=True)
            self.assertEqual(after, [])
            content = path.read_text()
            self.assertNotIn("metadata", content)
            self.assertNotIn("c2pa", content)
            self.assertNotIn("\n  <", content)
            self.assertIn("#2E6F6A", content)
            self.assertIn('xmlns="http://www.w3.org/2000/svg"', content)

    def test_fix_does_not_hide_real_errors(self):
        bad = svg(ART.replace("#2E6F6A", "#FF0000"))
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "sample.svg"
            path.write_text(bad, encoding="utf-8")
            self.assertIn("palette", {i.rule for i in svg_lint.lint_file(path, fix=True)})

    def test_exit_codes(self):
        with tempfile.TemporaryDirectory() as folder:
            good, bad = Path(folder) / "good.svg", Path(folder) / "bad.svg"
            good.write_text(svg(), encoding="utf-8")
            bad.write_text(svg(ART.replace("#2E6F6A", "#FF0000")), encoding="utf-8")
            self.assertEqual(svg_lint.main([str(good)]), 0)
            self.assertEqual(svg_lint.main([str(bad)]), 1)
            self.assertEqual(svg_lint.main([str(Path(folder) / "missing")]), 2)
            self.assertEqual(svg_lint.main([folder + "/empty-dir-that-does-not-exist"]), 2)


if __name__ == "__main__":
    unittest.main()
