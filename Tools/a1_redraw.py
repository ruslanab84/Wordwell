#!/usr/bin/env python3
"""Hand-drawn replacements for weak A1 dictionary SVGs (342x196, ink line art, design.md §4).

Each entry is stroke-only markup; the wrapper below adds the shared root attributes.
Run: python3 Tools/a1_redraw.py   (then python3 Tools/validate_svg_assets.py)
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets"

HEAD = ('<svg xmlns="http://www.w3.org/2000/svg" width="342" height="196" viewBox="0 0 342 196" fill="none" '
        'stroke="#3A362E" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round">\n  <g fill="none">\n    ')
TAIL = "\n  </g>\n</svg>\n"


def f(n: float) -> str:
    return f"{n:.1f}".rstrip("0").rstrip(".")


def person(cx, top, s=1.0, hair="short", dress=False):
    """Front-facing pictogram: head, shoulders/dress, legs. `top` is the head's top edge."""
    hr, cy = 15 * s, top + 15 * s
    tt, bot, hw = top + 33 * s, top + 88 * s, 28 * s
    out = [f'<circle cx="{f(cx)}" cy="{f(cy)}" r="{f(hr)}"/>']
    if dress:
        out.append(f'<path d="M{f(cx-9*s)} {f(tt)}L{f(cx+9*s)} {f(tt)}L{f(cx+30*s)} {f(bot)}L{f(cx-30*s)} {f(bot)}Z"/>')
        out.append(f'<path d="M{f(cx-8*s)} {f(bot)}v{f(24*s)}M{f(cx+8*s)} {f(bot)}v{f(24*s)}"/>')
    else:
        out.append(
            f'<path d="M{f(cx-hw)} {f(bot)}V{f(tt+20*s)}C{f(cx-hw)} {f(tt+8*s)} {f(cx-18*s)} {f(tt)} {f(cx-8*s)} {f(tt)}'
            f'H{f(cx+8*s)}C{f(cx+18*s)} {f(tt)} {f(cx+hw)} {f(tt+8*s)} {f(cx+hw)} {f(tt+20*s)}V{f(bot)}Z"/>')
        out.append(f'<path d="M{f(cx-10*s)} {f(bot)}v{f(24*s)}M{f(cx+10*s)} {f(bot)}v{f(24*s)}"/>')
    if hair == "short":
        out.append(f'<path d="M{f(cx-hr)} {f(cy-2*s)}C{f(cx-hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-2*s)}"/>')
    elif hair == "long":
        out.append(f'<path d="M{f(cx-hr)} {f(cy)}C{f(cx-hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy)}'
                   f'M{f(cx-hr)} {f(cy)}v{f(24*s)}M{f(cx+hr)} {f(cy)}v{f(24*s)}"/>')
    elif hair == "beret":
        out.append(f'<ellipse cx="{f(cx)}" cy="{f(cy-hr*0.9)}" rx="{f(hr*1.25)}" ry="{f(hr*0.5)}"/>'
                   f'<path d="M{f(cx)} {f(cy-hr*1.4)}v{f(-4*s)}"/>')
    return "".join(out)


W = {}

W["actor"] = (person(120, 34, 1.3) +
              '<g transform="rotate(-10 200 88)"><rect x="200" y="66" width="84" height="20" rx="3"/>'
              '<path d="M218 66l-8 20M238 66l-8 20M258 66l-8 20M278 66l-8 20"/></g>'
              '<rect x="200" y="90" width="84" height="62" rx="4"/><path d="M216 110h52M216 128h34"/>')

W["actress"] = (person(120, 34, 1.3, hair="long", dress=True) +
                '<g transform="rotate(-10 200 88)"><rect x="200" y="66" width="84" height="20" rx="3"/>'
                '<path d="M218 66l-8 20M238 66l-8 20M258 66l-8 20M278 66l-8 20"/></g>'
                '<rect x="200" y="90" width="84" height="62" rx="4"/><path d="M216 110h52M216 128h34"/>')

W["artist"] = (person(96, 34, 1.3, hair="beret") +
               '<path d="M130 100l50-22"/><path d="M180 78l6-3"/>'
               '<rect x="196" y="36" width="88" height="68" rx="3"/>'
               '<path d="M206 92l24-26 16 16 12-12 20 22M240 104l-22 66M240 104l22 66M240 104V118M212 130h56"/>'
               '<circle cx="262" cy="54" r="6"/>')

W["baby"] = ('<circle cx="171" cy="70" r="36"/><path d="M171 34c-9-9 5-19 12-9"/>'
             '<circle cx="134" cy="74" r="6"/><circle cx="208" cy="74" r="6"/>'
             '<path d="M154 68q6 6 12 0M176 68q6 6 12 0M162 88q9 9 18 0"/>'
             '<path d="M139 104c-20 8-32 26-32 50v22h128v-22c0-24-12-42-32-50"/><path d="M107 150h128"/>')

W["back"] = ('<circle cx="171" cy="38" r="18"/><path d="M164 56v10h14V56"/>'
             '<path d="M112 176v-72c0-20 14-32 34-36l18-2h14l18 2c20 4 34 16 34 36v72"/>'
             '<path d="M171 72v98M163 90h16M163 108h16M163 126h16M163 144h16M163 162h16"/>'
             '<path d="M140 92c-8 14-6 30 6 40M202 92c8 14 6 30-6 40"/>')

W["band"] = ('<path d="M96 84c-12 0-20 8-20 18 0 8 4 12 4 18 0 4-8 10-8 20 0 16 12 26 24 26s24-10 24-26c0-10-8-16-8-20 0-6 4-10 4-18 0-10-8-18-20-18Z"/>'
             '<circle cx="96" cy="142" r="8"/><path d="M91 84V36h10v48M89 36h14V22H89ZM86 150h20"/>'
             '<ellipse cx="240" cy="112" rx="46" ry="12"/><path d="M194 112v40c0 7 20 14 46 14s46-7 46-14v-40"/>'
             '<path d="M214 123v40M240 125v41M266 123v40M200 66l40 34M282 66l-42 34"/>')

W["bill"] = ('<path d="M118 26h106v144l-13-9-13 9-14-9-13 9-14-9-13 9-13-9-13 9Z"/>'
             '<path d="M138 54h66M138 74h66M138 94h40M138 122h66M138 140h24M184 140h20"/>')

W["body"] = ('<circle cx="171" cy="38" r="16"/>'
             '<path d="M155 60h32c9 0 14 6 14 14v44h-8v54h-18v-44h-8v44h-18v-54h-8V74c0-8 5-14 14-14Z"/>'
             '<path d="M141 118l-8 34M201 118l8 34"/>')

W["boy"] = person(171, 22, 1.5)

W["boyfriend"] = (person(112, 40, 1.25) +
                  person(232, 40, 1.25, hair="long", dress=True) +
                  '<path d="M172 60c-12-12-30-4-22 10 5 8 22 20 22 20s17-12 22-20c8-14-10-22-22-10Z"/>')

W["brother"] = (person(112, 26, 1.5) + person(226, 64, 1.1) +
                '<path d="M150 150h38"/>')

W["breakfast"] = ('<circle cx="120" cy="100" r="58"/><circle cx="120" cy="100" r="42"/>'
                  '<path d="M96 88c-6 16 10 34 30 30 22-4 30-24 16-38-10-10-22-2-32-2-8 0-10 6-14 10Z"/>'
                  '<circle cx="126" cy="100" r="11"/>'
                  '<path d="M214 84h58v46c0 14-10 24-24 24h-10c-14 0-24-10-24-24Z"/><path d="M272 96h12c8 0 8 24 0 24h-12"/>'
                  '<path d="M228 74c-6-8 6-14 0-22M246 74c-6-8 6-14 0-22"/><path d="M204 168h80"/>')

W["butter"] = ('<path d="M92 100l26-22h96l-26 22Z"/><path d="M92 100h96v50H92Z"/><path d="M188 100l26-22v50l-26 22"/>'
               '<path d="M92 118h96"/><path d="M226 128l12-10h32l-12 10ZM226 128h32v26h-32ZM258 128l12-10v26l-12 10"/>')

W["call"] = ('<path d="M96 52c-12 8-14 24-6 44 14 30 38 52 66 62 18 6 32-2 36-14l-8-20-22-8-12 14c-14-8-26-20-34-36l14-12-8-22-18-8Z"/>'
             '<path d="M196 56a36 36 0 0 1 32 32M196 30a62 62 0 0 1 58 58"/>')

W["card"] = ('<rect x="80" y="44" width="182" height="112" rx="12"/><rect x="80" y="70" width="182" height="24"/>'
             '<rect x="100" y="112" width="32" height="24" rx="4"/><path d="M152 124h64M152 138h36"/>')

W["cent"] = ('<circle cx="171" cy="98" r="62"/><circle cx="171" cy="98" r="48"/>'
             '<path d="M196 80a26 26 0 1 0 0 36M171 60v76"/>')

W["chart"] = ('<path d="M82 30v138h206"/>'
              '<rect x="102" y="118" width="30" height="50"/><rect x="148" y="92" width="30" height="76"/>'
              '<rect x="194" y="68" width="30" height="100"/><rect x="240" y="40" width="30" height="128"/>'
              '<path d="M100 96l46-24 44-8 48-30M240 34h14v14"/>')

W["chocolate"] = ('<g transform="rotate(-8 171 98)"><rect x="92" y="46" width="158" height="112" rx="8"/>'
                  '<path d="M131 46v112M171 46v112M211 46v112M92 84h158M92 121h158"/></g>')

W["class"] = ('<rect x="70" y="26" width="202" height="88" rx="4"/><path d="M92 54h56M92 74h84M92 94h44"/>'
              '<path d="M216 90l14-24 14 24"/><path d="M60 118h222"/>'
              + person(112, 128, 0.45) + person(171, 128, 0.45) + person(230, 128, 0.45))

W["conversation"] = ('<path d="M66 30h140c8 0 14 6 14 14v50c0 8-6 14-14 14h-84l-26 22v-22H66c-8 0-14-6-14-14V44c0-8 6-14 14-14Z"/>'
                     '<path d="M76 56h100M76 76h64"/>'
                     '<path d="M136 112v6c0 8 6 14 14 14h72l26 22v-22h10c8 0 14-6 14-14V70c0-8-6-14-14-14h-34"/>'
                     '<circle cx="190" cy="98" r="3"/><circle cx="212" cy="98" r="3"/><circle cx="234" cy="98" r="3"/>')

W["cooking"] = ('<path d="M100 96h122v52c0 10-8 18-18 18H118c-10 0-18-8-18-18Z"/><path d="M92 96h138M100 112H84M222 112h16"/>'
                '<path d="M150 88h22v8h-22Z"/><path d="M130 76c-6-8 6-14 0-24M162 76c-6-8 6-14 0-24M194 76c-6-8 6-14 0-24"/>'
                '<path d="M274 56l-34 92"/><ellipse cx="277" cy="48" rx="8" ry="12" transform="rotate(20 277 48)"/>')

W["cousin"] = (person(82, 22, 0.55) + person(260, 22, 0.55, hair="long", dress=True) +
               '<path d="M110 58h122M82 70v20M260 70v20"/>'
               + person(82, 92, 0.8) + person(260, 92, 0.8, hair="long", dress=True) +
               '<path d="M118 138h106M118 138l8-6M118 138l8 6M224 138l-8-6M224 138l-8 6"/>')

W["cream"] = ('<path d="M124 70c-10 6-14 18-14 30v50c0 12 8 20 20 20h50c12 0 20-8 20-20v-50c0-12-4-24-14-30"/>'
              '<path d="M124 70c0-8 10-12 32-12s32 4 32 12c0 6-10 10-32 10s-32-4-32-10ZM124 70l-16-8M200 92h22c14 0 14 40 0 40h-22"/>'
              '<path d="M156 108c-8 12-8 22 4 22s12-10 4-22l-4-8Z"/><path d="M120 176h72"/>')

W["customer"] = (person(112, 34, 1.3) +
                 '<path d="M148 100l56-8"/>'
                 '<path d="M204 92h74l8 76H196Z"/><path d="M222 92v-10c0-16 34-16 34 0v10"/>'
                 '<path d="M226 112c0 12 26 12 26 0"/>')

W["bread"] = ('<path d="M92 88c-6-30 20-50 79-50s85 20 79 50c-4 10-12 12-12 12v66H104v-66s-8-2-12-12Z"/>'
              '<path d="M138 62c-6 14 4 26 14 24M180 58c-6 14 4 26 14 24M214 66c-4 10 2 18 10 16"/>')

W["cheese"] = ('<path d="M96 150H250V96Z"/><path d="M96 150l24-18 154-54v54l-24 18M250 96l24-18"/>'
               '<circle cx="204" cy="132" r="7"/><circle cx="230" cy="112" r="5"/><circle cx="160" cy="141" r="4"/>')

W["chair"] = ('<rect x="120" y="30" width="102" height="68" rx="6"/><path d="M154 30v68M188 30v68"/>'
              '<rect x="108" y="98" width="126" height="16" rx="5"/><path d="M122 114v58M220 114v58M122 146h98"/>')

W["cow"] = ('<path d="M132 68h118c10 0 18 8 18 18v24c0 10-8 18-18 18H132c-10 0-18-8-18-18V86c0-10 8-18 18-18Z"/>'
            '<path d="M114 80l-28-2c-12 0-20 8-20 20v14c0 6 4 10 10 10h34"/><circle cx="78" cy="104" r="2"/>'
            '<path d="M86 78l-6-16M104 76l2-14M66 92l-10-4"/>'
            '<path d="M132 128v40h12v-40M154 128v40h12v-40M236 128v40h12v-40M256 128v40h12v-40"/>'
            '<path d="M268 84c14 4 18 22 12 42M276 126l-8 8"/>'
            '<path d="M168 82c12-4 22 6 16 16-8 8-22 0-16-16ZM214 96c10 0 16 8 10 16-8 6-20 0-10-16Z"/>'
            '<ellipse cx="200" cy="134" rx="10" ry="5"/>')


def main() -> None:
    for word, markup in W.items():
        name = f"word_{word}_plate"
        path = ASSETS / f"{name}.imageset" / f"{name}.svg"
        if not path.exists():
            raise SystemExit(f"missing asset: {path}")
        path.write_text(HEAD + markup + TAIL)
    print(f"Redrew {len(W)} A1 illustrations")


if __name__ == "__main__":
    main()
