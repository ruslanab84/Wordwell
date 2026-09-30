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


def person(cx, top, s=1.0, hair="short", dress=False, legs=True):
    """Front-facing pictogram: head, shoulders/dress, legs. `top` is the head's top edge."""
    hr, cy = 15 * s, top + 15 * s
    tt, bot, hw = top + 33 * s, top + 88 * s, 28 * s
    out = [f'<circle cx="{f(cx)}" cy="{f(cy)}" r="{f(hr)}"/>']
    if dress:
        out.append(f'<path d="M{f(cx-9*s)} {f(tt)}L{f(cx+9*s)} {f(tt)}L{f(cx+30*s)} {f(bot)}L{f(cx-30*s)} {f(bot)}Z"/>')
        if legs:
            out.append(f'<path d="M{f(cx-8*s)} {f(bot)}v{f(24*s)}M{f(cx+8*s)} {f(bot)}v{f(24*s)}"/>')
    else:
        out.append(
            f'<path d="M{f(cx-hw)} {f(bot)}V{f(tt+20*s)}C{f(cx-hw)} {f(tt+8*s)} {f(cx-18*s)} {f(tt)} {f(cx-8*s)} {f(tt)}'
            f'H{f(cx+8*s)}C{f(cx+18*s)} {f(tt)} {f(cx+hw)} {f(tt+8*s)} {f(cx+hw)} {f(tt+20*s)}V{f(bot)}Z"/>')
        if legs:
            out.append(f'<path d="M{f(cx-10*s)} {f(bot)}v{f(24*s)}M{f(cx+10*s)} {f(bot)}v{f(24*s)}"/>')
    if hair == "short":
        out.append(f'<path d="M{f(cx-hr)} {f(cy-2*s)}C{f(cx-hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-2*s)}"/>')
    elif hair == "long":
        out.append(f'<path d="M{f(cx-hr)} {f(cy)}C{f(cx-hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy)}'
                   f'M{f(cx-hr)} {f(cy)}v{f(24*s)}M{f(cx+hr)} {f(cy)}v{f(24*s)}"/>')
    elif hair == "bun":
        out.append(f'<path d="M{f(cx-hr)} {f(cy-2*s)}C{f(cx-hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-hr*1.5)} {f(cx+hr)} {f(cy-2*s)}"/>'
                   f'<circle cx="{f(cx)}" cy="{f(cy-hr-6*s)}" r="{f(7*s)}"/>')
    elif hair == "beret":
        out.append(f'<ellipse cx="{f(cx)}" cy="{f(cy-hr*0.9)}" rx="{f(hr*1.25)}" ry="{f(hr*0.5)}"/>'
                   f'<path d="M{f(cx)} {f(cy-hr*1.4)}v{f(-4*s)}"/>')
    return "".join(out)


def glasses(cx, top, s):
    cy = top + 16 * s
    return (f'<circle cx="{f(cx-6*s)}" cy="{f(cy)}" r="{f(4.5*s)}"/><circle cx="{f(cx+6*s)}" cy="{f(cy)}" r="{f(4.5*s)}"/>'
            f'<path d="M{f(cx-1.5*s)} {f(cy)}h{f(3*s)}"/>')


GUITAR = ('<path d="M96 84c-12 0-20 8-20 18 0 8 4 12 4 18 0 4-8 10-8 20 0 16 12 26 24 26s24-10 24-26c0-10-8-16-8-20 0-6 4-10 4-18 0-10-8-18-20-18Z"/>'
          '<circle cx="96" cy="142" r="8"/><path d="M91 84V36h10v48M89 36h14V22H89ZM86 150h20"/>')

def cap(cx, top, s):
    hr, cy = 15 * s, top + 15 * s
    return (f'<path d="M{f(cx-hr-s)} {f(cy-3*s)}C{f(cx-hr)} {f(cy-hr*1.8)} {f(cx+hr)} {f(cy-hr*1.8)} {f(cx+hr+s)} {f(cy-3*s)}Z"/>'
            f'<path d="M{f(cx-hr-3*s)} {f(cy-3*s)}h{f(2*hr+6*s)}"/>')


def ball(cx, cy, r):
    import math
    pts = [(cx + .38 * r * math.cos(math.radians(-90 + 72 * k)), cy + .38 * r * math.sin(math.radians(-90 + 72 * k))) for k in range(5)]
    outs = [(cx + .8 * r * math.cos(math.radians(-90 + 72 * k)), cy + .8 * r * math.sin(math.radians(-90 + 72 * k))) for k in range(5)]
    poly = "M" + "L".join(f"{f(x)} {f(y)}" for x, y in pts) + "Z"
    spokes = "".join(f"M{f(a)} {f(b)}L{f(c)} {f(d)}" for (a, b), (c, d) in zip(pts, outs))
    return f'<circle cx="{f(cx)}" cy="{f(cy)}" r="{f(r)}"/><path d="{poly}{spokes}"/>'


def cube(cx, cy, r):
    k = 0.87 * r
    return (f'<path d="M{f(cx)} {f(cy-r)}L{f(cx+k)} {f(cy-r/2)}V{f(cy+r/2)}L{f(cx)} {f(cy+r)}L{f(cx-k)} {f(cy+r/2)}V{f(cy-r/2)}Z'
            f'M{f(cx-k)} {f(cy-r/2)}L{f(cx)} {f(cy)}L{f(cx+k)} {f(cy-r/2)}M{f(cx)} {f(cy)}V{f(cy+r)}"/>')


def storefront(sign):
    return ('<path d="M76 62h190l10 30H66Z"/><path d="M104 62l-6 30M142 62l-2 30M180 62l2 30M218 62l4 30M244 62l8 30"/>'
            '<path d="M84 92v84M258 92v84M60 176h222"/><rect x="100" y="112" width="86" height="64"/><rect x="204" y="112" width="40" height="64"/>'
            '<circle cx="234" cy="146" r="3"/><path d="M143 112v64M100 144h86"/>' + sign)


def tennis_racket():
    import math
    rows = "".join(f'<path d="M{f(150-42*math.sqrt(1-(14*k/54)**2))} {f(80+14*k)}H{f(150+42*math.sqrt(1-(14*k/54)**2))}"/>' for k in range(-3, 4))
    cols = "".join(f'<path d="M{f(150+14*j)} {f(80-54*math.sqrt(1-(14*j/42)**2))}V{f(80+54*math.sqrt(1-(14*j/42)**2))}"/>' for j in range(-2, 3))
    return ('<g transform="translate(120 96) rotate(-32) translate(-150 -80)"><ellipse cx="150" cy="80" rx="42" ry="54"/>' + rows + cols +
            '<path d="M138 132l12 12 12-12M144 144v34h12v-34"/></g>')


def flake():
    import math
    out = []
    for a in (0, 60, 120):
        dx, dy = math.cos(math.radians(a)), math.sin(math.radians(a))
        out.append(f'M{f(171-58*dx)} {f(98-58*dy)}L{f(171+58*dx)} {f(98+58*dy)}')
        for sgn in (1, -1):
            bx, by = 171 + 36 * dx * sgn, 98 + 36 * dy * sgn
            for side in (-1, 1):
                ax = math.radians(a + (45 if side == 1 else -45)) if sgn == 1 else math.radians(a + 180 + (45 if side == 1 else -45))
                out.append(f'M{f(bx)} {f(by)}L{f(bx+16*math.cos(ax))} {f(by+16*math.sin(ax))}')
    return f'<path d="{"".join(out)}"/>'


BOOK = ('<path d="M96 70c22-8 50-8 75 6 25-14 53-14 75-6v80c-22-8-50-8-75 6-25-14-53-14-75-6Z"/><path d="M171 76v80"/>'
        '<path d="M110 90c16-4 34-4 48 4M110 108c16-4 34-4 48 4M184 94c14-8 32-8 48-4M184 112c14-8 32-8 48-4"/>')

def fig(head, S, H, arms, legs):
    """Line-only stick figure. Joints are absolute points; arms/legs are [(elbow|knee), (hand|foot)] pairs."""
    d = f"M{f(S[0])} {f(S[1])}L{f(H[0])} {f(H[1])}"
    for (a, b) in arms + legs:
        origin = S if (a, b) in arms else H
        d += f"M{f(origin[0])} {f(origin[1])}L{f(a[0])} {f(a[1])}L{f(b[0])} {f(b[1])}"
    return f'<circle cx="{f(head[0])}" cy="{f(head[1])}" r="12"/><path d="{d}"/>'


def house(x, y, w, h):
    return (f'<path d="M{f(x)} {f(y+h*.42)}h{f(w)}v{f(h*.58)}h{f(-w)}Z"/><path d="M{f(x-5)} {f(y+h*.42)}L{f(x+w/2)} {f(y)}L{f(x+w+5)} {f(y+h*.42)}"/>'
            f'<rect x="{f(x+w*.4)}" y="{f(y+h*.7)}" width="{f(w*.2)}" height="{f(h*.3)}"/>')


def bldg(x, y, w, h, cols, rows):
    g = w / (cols * 2 + 1)
    out = f'<rect x="{f(x)}" y="{f(y)}" width="{f(w)}" height="{f(h)}"/>'
    for r in range(rows):
        for c in range(cols):
            out += f'<rect x="{f(x+g*(1+2*c))}" y="{f(y+g*(1+2*r))}" width="{f(g)}" height="{f(g)}"/>'
    return out


def car(cx, cy, sc):
    body = ('<path d="M66 132v-14c0-10 8-18 20-20l24-32c4-4 8-6 14-6h84c6 0 10 2 14 6l24 32c12 2 20 10 20 20v14Z"/>'
            '<path d="M122 98l14-22h34v22ZM178 98V76h32l16 22"/><circle cx="106" cy="140" r="16"/><circle cx="246" cy="140" r="16"/>')
    return f'<g transform="translate({f(cx)} {f(cy)}) scale({f(sc)}) translate(-176 -110)">{body}</g>'


def sparkle(cx, cy, r):
    return (f'<path d="M{f(cx)} {f(cy-r)}Q{f(cx)} {f(cy)} {f(cx+r)} {f(cy)}Q{f(cx)} {f(cy)} {f(cx)} {f(cy+r)}'
            f'Q{f(cx)} {f(cy)} {f(cx-r)} {f(cy)}Q{f(cx)} {f(cy)} {f(cx)} {f(cy-r)}Z"/>')


def hardhat(cx, top, s):
    hr, cy = 15 * s, top + 15 * s
    return (f'<path d="M{f(cx-hr-2*s)} {f(cy-2*s)}C{f(cx-hr)} {f(cy-hr*1.9)} {f(cx+hr)} {f(cy-hr*1.9)} {f(cx+hr+2*s)} {f(cy-2*s)}Z"/>'
            f'<path d="M{f(cx-hr-6*s)} {f(cy-2*s)}h{f(2*hr+12*s)}M{f(cx)} {f(cy-hr*1.4)}v{f(-2*s)}"/>')


def hand_pointing():
    return ('<path d="M116 176v-50c0-10 8-16 16-16h60c10 0 16 6 16 16v50Z"/><rect x="146" y="40" width="22" height="76" rx="11"/>'
            '<path d="M168 112V98c0-8 14-8 14 0v14M182 112v-8c0-8 14-8 14 0v8M116 132c-16-6-26 4-16 14l16 10"/>')


def _old_hand_pointing():
    return ('<path d="M100 98h80v58c0 8-6 14-14 14h-52c-8 0-14-6-14-14Z"/><path d="M180 108h70c10 0 10 20 0 20h-70"/>'
            '<path d="M112 98c0-16 8-24 22-24 6 0 10 4 8 10M124 136h56M124 152h56M88 98v72"/>')


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

W["dinner"] = ('<circle cx="171" cy="100" r="54"/><circle cx="171" cy="100" r="36"/>'
               '<path d="M92 44v32q0 10 10 10t10-10V44M102 86v88M104 44v30M92 44v30"/>'
               '<path d="M252 44c14 8 16 50 0 72v58"/>')

W["dish"] = ('<path d="M96 122c0-42 30-62 75-62s75 20 75 62Z"/><circle cx="171" cy="52" r="8"/>'
             '<path d="M78 126h186c0 12-34 24-93 24s-93-12-93-24Z"/><path d="M130 88c6-14 18-22 30-24"/>')

W["dollar"] = ('<rect x="70" y="52" width="202" height="96" rx="8"/><circle cx="171" cy="100" r="28"/>'
               '<path d="M181 90c-6-7-24-6-24 5 0 13 28 6 28 20 0 10-20 11-27 3M171 80v6M171 118v6"/>'
               '<circle cx="94" cy="76" r="4"/><circle cx="248" cy="124" r="4"/>')

W["dress"] = ('<path d="M150 42l6 40-10 22-34 68h118l-34-68-10-22 6-40"/><path d="M156 82q15 12 30 0M146 104h50"/>')

W["driver"] = ('<circle cx="171" cy="50" r="20"/><path d="M168 30c-16 0-26 10-24 20M174 30c16 0 26 10 24 20"/>'
               '<path d="M124 112c0-24 18-38 47-38s47 14 47 38"/>'
               '<circle cx="171" cy="152" r="38"/><circle cx="171" cy="152" r="8"/><path d="M133 152h30M179 152h30M171 160v30"/>')

W["evening"] = ('<path d="M50 138h242"/><path d="M116 138a55 55 0 0 1 110 0"/>'
                '<path d="M171 60v-16M120 78l-11-11M222 78l11-11M84 106l-14-4M258 106l14-4"/>'
                '<path d="M268 44a16 16 0 1 0 14 22 14 14 0 0 1-14-22Z"/><path d="M84 158h174M120 174h100"/>')

W["exam"] = ('<rect x="106" y="24" width="130" height="152" rx="6"/><path d="M126 50h60"/>'
             '<rect x="126" y="70" width="16" height="16"/><path d="M129 78l4 4 7-9M156 78h60"/>'
             '<rect x="126" y="100" width="16" height="16"/><path d="M129 108l4 4 7-9M156 108h60"/>'
             '<rect x="126" y="130" width="16" height="16"/><path d="M156 138h60"/>')

W["exercise"] = ('<path d="M76 40h190M92 26v28M108 30v20M234 30v20M250 26v28"/>'
                 + person(171, 60, 1.0) + '<path d="M143 100L112 44M199 100l31-56"/>')

W["face"] = ('<circle cx="171" cy="98" r="58"/><path d="M113 98h-8c-6 0-6 16 0 16h8M229 98h8c6 0 6 16 0 16h-8"/>'
             '<circle cx="150" cy="88" r="4"/><circle cx="192" cy="88" r="4"/>'
             '<path d="M138 74q12-8 24 0M180 74q12-8 24 0M171 92l-6 20h12M148 130q23 20 46 0"/>')

W["farm"] = ('<path d="M84 176V98l46-38 46 38v78Z"/><path d="M78 102l52-44 52 44"/>'
             '<rect x="112" y="122" width="36" height="54"/><path d="M112 122l36 54M148 122l-36 54"/>'
             '<path d="M196 176V82c0-16 12-24 26-24s26 8 26 24v94Z"/><path d="M196 104h52M196 132h52"/><path d="M52 176h240"/>')

W["farmer"] = (person(112, 46, 1.25, hair=None) +
               '<ellipse cx="112" cy="59" rx="34" ry="6"/><path d="M92 58c0-22 40-22 40 0"/>'
               '<path d="M236 176V62M220 40v22q16 12 32 0V40M236 40v22"/><path d="M147 110l70-6"/>')

W["father"] = (person(112, 26, 1.4) + person(220, 86, 0.9) + '<path d="M148 118l48 16"/>')

W["festival"] = ('<path d="M50 50Q171 110 292 50"/>'
                 + "".join(f'<path d="M{x-11} {y-1}h22L{x} {y+26}Z"/>' for x, y in
                           [(74, 61), (111, 73), (147, 80), (183, 80), (219, 75), (256, 65)]) +
                 '<path d="M160 172V134l30-8v38"/><circle cx="152" cy="172" r="8"/><circle cx="182" cy="164" r="8"/>'
                 '<path d="M84 130c-14-4-22-22-14-34 8-10 26-10 34 0 8 12 0 30-14 34l4 12"/>')

W["film"] = ('<rect x="46" y="54" width="250" height="88" rx="4"/>'
             + "".join(f'<rect x="{x}" y="60" width="10" height="10" rx="2"/><rect x="{x}" y="126" width="10" height="10" rx="2"/>'
                       for x in range(60, 290, 26)) +
             '<rect x="62" y="80" width="62" height="36"/><rect x="140" y="80" width="62" height="36"/><rect x="218" y="80" width="62" height="36"/>')

W["floor"] = ('<path d="M70 66h202l32 108H38Z"/><path d="M120 66l-16 108M171 66v108M222 66l16 108"/>'
              '<path d="M61 96h220M52 130h238"/>')

W["foot"] = ('<path d="M150 92c-14-14-8-40 10-46 18-6 36 6 36 26 0 14-8 18-8 36 0 26 4 42-16 50-18 6-32-6-32-26 0-16 0-30 10-40Z"/>'
             '<circle cx="130" cy="54" r="7"/><circle cx="148" cy="38" r="6"/><circle cx="168" cy="30" r="5"/><circle cx="186" cy="30" r="5"/>'
             '<circle cx="204" cy="40" r="4"/>')

W["friend"] = (person(118, 40, 1.3) + person(224, 40, 1.3, hair="bun", dress=True) + '<path d="M146 108h32M192 108h-10"/>')

W["fruit"] = ('<path d="M92 122h158c0 34-32 52-79 52s-79-18-79-52Z"/><path d="M84 122h174"/>'
              '<path d="M126 118c-16-8-20-34-4-40 8-2 12 2 16 2s8-4 16-2c16 6 12 32-4 40Z"/><path d="M138 80c0-8 4-12 10-14"/>'
              '<circle cx="190" cy="92" r="24"/><path d="M190 68c0-8 6-12 12-12"/>'
              '<path d="M214 120c6-32 28-46 52-44-6 28-26 46-52 44Z"/>')

W["game"] = ('<path d="M96 76c-20 0-32 30-32 60 0 14 8 22 20 16l24-22h118l24 22c12 6 20-2 20-16 0-30-12-60-32-60Z"/>'
             '<path d="M118 92v30M103 107h30"/><circle cx="230" cy="96" r="7"/><circle cx="250" cy="112" r="7"/>'
             '<path d="M166 100h10M166 112h10"/>')

W["garden"] = ('<path d="M92 92h68l-6 62c0 8-4 12-12 12h-32c-8 0-12-4-12-12Z"/><path d="M160 112l50-38M92 106c-30-4-30 40 2 40"/>'
               '<path d="M210 74l12 6-6 14-14-6Z"/><path d="M234 150c12 2 22 6 30 14M246 132c10 0 20 6 24 14M236 168c14 0 24 4 32 10"/>'
               '<path d="M290 176v-58"/><circle cx="290" cy="106" r="7"/><circle cx="290" cy="90" r="7"/><circle cx="276" cy="98" r="7"/><circle cx="304" cy="98" r="7"/>'
               '<path d="M60 176h250"/>')

W["geography"] = ('<circle cx="171" cy="86" r="56"/><ellipse cx="171" cy="86" rx="24" ry="56"/><path d="M116 66h110M116 106h110"/>'
                  '<path d="M171 142v18M138 172h66M126 150c8 20 82 20 90 0"/>')

W["girl"] = (person(171, 22, 1.5, hair="long", dress=True) + '<path d="M144 60l-8 18M198 60l8 18"/>')

W["girlfriend"] = (person(112, 40, 1.25, hair="long", dress=True) + person(232, 40, 1.25) +
                   '<path d="M172 60c-12-12-30-4-22 10 5 8 22 20 22 20s17-12 22-20c8-14-10-22-22-10Z"/>')

W["grandfather"] = (person(122, 30, 1.4) + glasses(122, 30, 1.4) +
                    '<path d="M100 66c0 14 44 14 44 0"/><path d="M220 176V112c0-16 24-16 24 0"/>')

W["grandmother"] = (person(122, 30, 1.4, hair="bun", dress=True) + glasses(122, 30, 1.4) +
                    '<path d="M220 176V112c0-16 24-16 24 0"/>')

W["grandparent"] = (person(100, 40, 1.1) + glasses(100, 40, 1.1) + person(220, 40, 1.1, hair="bun", dress=True) + glasses(220, 40, 1.1) +
                    '<path d="M132 108h56"/>')

W["group"] = (person(84, 60, 0.95) + person(171, 34, 1.25, hair="long", dress=True) + person(258, 60, 0.95) +
              '<path d="M118 100l24 4M224 104l16-4"/>')

W["guitar"] = '<g transform="translate(171 98) rotate(38) scale(1.05) translate(-100 -99)">' + GUITAR + '</g>'

W["gym"] = ('<rect x="46" y="70" width="14" height="60" rx="4"/><rect x="64" y="58" width="14" height="84" rx="4"/>'
            '<path d="M60 100h4M78 100h92"/><rect x="170" y="58" width="14" height="84" rx="4"/><rect x="188" y="70" width="14" height="60" rx="4"/>'
            '<circle cx="256" cy="130" r="32"/><path d="M234 106c-8-38 44-38 36 0M222 130h68"/>')

W["hair"] = ('<circle cx="171" cy="100" r="34"/>'
             '<path d="M133 100c-12-56 18-76 38-76s50 20 38 76c8 20 8 52-8 74-2-32-12-44-30-48-18 4-28 16-30 48-16-22-16-54-8-74Z"/>'
             '<path d="M146 88c20-2 36-12 42-26 6 14 14 22 22 26"/>')

W["hat"] = ('<path d="M100 112c0-40 20-64 71-64s71 24 71 64"/>'
            '<path d="M60 120c0-10 50-16 111-16s111 6 111 16-50 18-111 18-111-8-111-18Z"/><path d="M102 108c20 8 118 8 138 0"/>')

W["head"] = ('<path d="M150 30c-30 6-46 32-40 62 2 12 8 22 6 34-1 8 4 12 12 12h8v22h46v-24c10-2 18-8 18-20l10-2c4 0 4-4 2-6l-12-16c0-12 2-18 0-26-6-26-24-42-50-36Z"/>'
            '<path d="M136 84a10 13 0 1 0 0 .1"/><circle cx="184" cy="76" r="3"/>')

W["doctor"] = (person(112, 26, 1.4) + '<path d="M112 80v58M92 80l20 28 20-28"/>'
               '<path d="M92 84c-6 30 8 42 20 42s26-12 20-42"/>'
               '<circle cx="246" cy="98" r="44"/><path d="M246 76v44M224 98h44"/>')

W["elephant"] = ('<path d="M128 74c6-18 34-28 70-28h42c28 0 44 18 44 46v78h-30v-32h-20v32h-30v-32h-46v32h-30V74Z"/>'
                 '<circle cx="152" cy="92" r="26"/><circle cx="148" cy="80" r="3"/>'
                 '<path d="M128 90c-24-2-40 12-44 34-2 14 2 26-4 38-4 8 6 12 12 4 8-12 6-28 8-38 4-12 16-14 28-12"/>'
                 '<path d="M106 112c-6 10-16 14-24 12M284 92c10 8 8 24 2 36"/>')

W["husband"] = (person(112, 36, 1.3) + person(230, 36, 1.3, hair="bun", dress=True) +
                '<circle cx="171" cy="130" r="10"/><path d="M165 112l6-9 6 9Z"/><path d="M148 108l14 14M194 108l-14 14"/>')

W["ice"] = cube(171, 98, 62) + '<path d="M142 58l10-6M136 74l6-4"/>'

W["ice_cream"] = ('<path d="M138 112l33 68 33-68Z"/><path d="M148 132l22-16M158 154l32-30M168 172l28-26"/>'
                  '<path d="M134 104c-10-32 14-52 37-52s47 20 37 52c-8 8-12 6-18-2-6 8-12 8-19 0-7 8-13 8-19 2-6 8-12 10-18 0Z"/>'
                  '<path d="M148 60c0-20 10-30 23-30s23 10 23 30"/><circle cx="171" cy="22" r="6"/>')

W["internet"] = ('<rect x="70" y="34" width="202" height="128" rx="8"/><path d="M70 60h202M86 47h4M100 47h4M114 47h4"/>'
                 '<circle cx="171" cy="112" r="38"/><ellipse cx="171" cy="112" rx="16" ry="38"/><path d="M133 112h76M141 94h60M141 130h60"/>')

W["interview"] = (person(78, 40, 1.3) + person(264, 40, 1.3, hair="long", dress=True) +
                  '<circle cx="171" cy="86" r="10"/><path d="M171 96v24M158 120h26"/><path d="M110 96l50-8"/>')

W["island"] = ('<path d="M92 142c22-32 58-38 79-38s57 6 79 38Z"/><path d="M168 104c-4-26 4-44 16-56"/>'
               '<path d="M184 48c-14-14-34-10-44 6M184 48c14-12 34-8 44 8M184 48c-6-18 4-30 18-32M184 48c-4-10-16-16-32-10"/>'
               '<path d="M44 152c14 8 28 8 42 0s28-8 42 0 28 8 42 0 28-8 42 0 28 8 42 0M68 172c14 6 28 6 42 0s28-6 42 0 28 6 42 0 28-6 42 0"/>')

W["jeans"] = ('<path d="M118 30h106l8 14-8 130h-46l-6-84-6 84h-46l-8-130Z" transform="translate(0 0)"/>'
              '<path d="M118 44h106M126 62c12 0 20 6 24 18M216 62c-12 0-20 6-24 18M171 44v40"/><circle cx="171" cy="52" r="3"/>')

W["journey"] = ('<rect x="96" y="78" width="150" height="90" rx="10"/><path d="M148 78V58h46v20M96 112h150M158 112v12h26v-12"/>'
                '<path d="M120 78v90M222 78v90"/><circle cx="196" cy="140" r="8"/>')

W["juice"] = ('<path d="M128 70h94l-10 106h-74Z"/><path d="M132 100h86"/><path d="M190 70l22-46h28"/>'
              '<circle cx="128" cy="70" r="22"/><path d="M128 48v44M106 70h44M112 54l32 32M144 54l-32 32"/>')

W["kitchen"] = ('<rect x="92" y="104" width="158" height="72" rx="4"/><rect x="106" y="122" width="130" height="46" rx="3"/>'
                '<circle cx="118" cy="113" r="3"/><circle cx="171" cy="113" r="3"/><circle cx="224" cy="113" r="3"/>'
                '<path d="M130 104V72h82v32M122 72h98M158 60h26v12M130 86h-18M212 86h18"/>'
                '<path d="M148 52c-6-8 6-12 0-22M172 52c-6-8 6-12 0-22M196 52c-6-8 6-12 0-22"/>')

W["land"] = ('<path d="M34 138c40-56 92-56 132 0 34-36 84-36 142 6"/><path d="M34 176h274"/>'
             '<path d="M240 100v-30"/><circle cx="240" cy="56" r="16"/><path d="M60 158h44M150 164h60"/>'
             '<circle cx="270" cy="48" r="16"/>')

W["laugh"] = ('<circle cx="171" cy="98" r="60"/><path d="M138 80q10-12 20 0M184 80q10-12 20 0"/>'
              '<path d="M134 108h74c0 26-16 40-37 40s-37-14-37-40Z"/><path d="M152 138c8-8 30-8 38 0"/><path d="M128 96l-8 4M214 96l8 4"/>')

W["leg"] = ('<path d="M150 24h42v124h14c14 0 22 6 22 16H150Z"/><path d="M150 74q21 12 42 0M150 148h42"/>')

W["lesson"] = ('<rect x="64" y="30" width="214" height="112" rx="4"/><path d="M50 150h242M100 172h30"/>'
               '<path d="M92 108l30-52 30 52ZM196 84a20 20 0 1 0 0 .1M230 60l24 44"/><path d="M86 60h20M86 76h12"/>')

W["library"] = ('<rect x="62" y="30" width="218" height="146" rx="4"/><path d="M62 78h218M62 126h218"/>'
                '<rect x="76" y="44" width="14" height="34"/><rect x="92" y="38" width="12" height="40"/><rect x="106" y="48" width="18" height="30"/>'
                '<rect x="150" y="42" width="14" height="36"/><rect x="166" y="46" width="12" height="32"/><rect x="200" y="40" width="16" height="38"/><rect x="220" y="46" width="14" height="32"/>'
                '<rect x="78" y="92" width="16" height="34"/><rect x="96" y="88" width="12" height="38"/><rect x="132" y="94" width="18" height="32"/><rect x="204" y="90" width="14" height="36"/><rect x="222" y="94" width="18" height="32"/>'
                '<rect x="80" y="140" width="18" height="36"/><rect x="100" y="146" width="12" height="30"/><rect x="170" y="142" width="16" height="34"/><rect x="190" y="138" width="14" height="38"/>')

W["light"] = ('<path d="M171 30c-26 0-44 18-44 42 0 16 8 24 16 34 4 6 6 10 6 18h44c0-8 2-12 6-18 8-10 16-18 16-34 0-24-18-42-44-42Z"/>'
              '<path d="M149 124h44M152 138h38M160 152h22M160 124V92l11 10 11-10v32"/>'
              '<path d="M171 16V6M116 34l-8-8M226 34l8-8M96 74H84M258 74h12"/>')

W["line"] = ('<path d="M76 56H266"/><path d="M76 98c16-18 32-18 48 0s32 18 48 0 32-18 48 0 32 18 46 0"/>'
             '<path d="M76 146l24-22 24 22 24-22 24 22 24-22 24 22 24-22 22 22"/>')

W["lion"] = ('<path d="M235.0 100.0A13 13 0 0 1 230.1 124.5A13 13 0 0 1 216.3 145.3A13 13 0 0 1 195.5 159.1A13 13 0 0 1 171.0 164.0A13 13 0 0 1 146.5 159.1A13 13 0 0 1 125.7 145.3A13 13 0 0 1 111.9 124.5A13 13 0 0 1 107.0 100.0A13 13 0 0 1 111.9 75.5A13 13 0 0 1 125.7 54.7A13 13 0 0 1 146.5 40.9A13 13 0 0 1 171.0 36.0A13 13 0 0 1 195.5 40.9A13 13 0 0 1 216.3 54.7A13 13 0 0 1 230.1 75.5A13 13 0 0 1 235.0 100.0Z"/><circle cx="171" cy="102" r="40"/><circle cx="140" cy="70" r="10"/><circle cx="202" cy="70" r="10"/><circle cx="156" cy="96" r="4"/><circle cx="186" cy="96" r="4"/><path d="M162 110h18l-9 9ZM171 119v8M158 130q13 8 26 0"/>')

W["list"] = ('<rect x="106" y="24" width="130" height="152" rx="6"/>'
             '<circle cx="128" cy="66" r="4"/><path d="M144 66h70"/><circle cx="128" cy="96" r="4"/><path d="M144 96h70"/>'
             '<circle cx="128" cy="126" r="4"/><path d="M144 126h70"/><circle cx="128" cy="156" r="4"/><path d="M144 156h44"/>')

W["love"] = ('<path d="M171 156c-52-36-66-66-54-88 10-16 34-14 54 8 20-22 44-24 54-8 12 22-2 52-54 88Z"/>'
             '<path d="M262 82c-14-9-18-18-14-24 3-5 10-4 14 2 4-6 11-7 14-2 4 6 0 15-14 24ZM86 60c-10-7-13-14-10-18 2-4 7-3 10 1 3-4 8-5 10-1 3 4 0 11-10 18Z"/>')

W["lunch"] = ('<rect x="90" y="72" width="162" height="98" rx="12"/><path d="M90 108h162M146 72V54h50v18"/><rect x="156" y="100" width="30" height="16" rx="4"/>'
              '<path d="M112 136h40M112 152h26"/><circle cx="212" cy="140" r="14"/>')

W["magazine"] = ('<rect x="104" y="24" width="134" height="152" rx="4"/><rect x="118" y="38" width="106" height="24"/>'
                 '<rect x="118" y="74" width="106" height="52"/><path d="M118 118l30-30 20 20 16-14 40 30M134 140h74M134 156h50"/><circle cx="200" cy="90" r="5"/>')

W["man"] = (person(171, 22, 1.5) + '<path d="M150 74l21 14 21-14M171 88l-5 12 5 24 5-24Z"/>')

W["market"] = ('<path d="M74 60h194l10 34H64Z"/><path d="M106 60l-8 34M142 60l-4 34M180 60l2 34M218 60l6 34M250 60l12 34"/>'
               '<path d="M86 94v82M256 94v82"/><rect x="72" y="138" width="198" height="38"/>'
               '<circle cx="112" cy="126" r="12"/><circle cx="140" cy="126" r="12"/><circle cx="196" cy="126" r="12"/><circle cx="224" cy="126" r="12"/>'
               '<path d="M160 116c-10 0-10 22 22 22 14 0 14-22 0-22Z" transform="translate(-10 0)"/>')

W["match"] = ('<rect x="46" y="34" width="250" height="132" rx="4"/><path d="M171 34v132"/><circle cx="171" cy="100" r="26"/>'
              '<path d="M46 72h34v56H46M296 72h-34v56h34"/>' + ball(171, 100, 8))

W["meal"] = ('<circle cx="171" cy="100" r="66"/><circle cx="171" cy="100" r="50"/>'
             '<path d="M128 92c-6-18 12-30 30-26 18 4 22 18 14 30-8 12-40 22-44-4Z"/>'
             '<circle cx="196" cy="96" r="7"/><circle cx="210" cy="112" r="7"/><circle cx="192" cy="120" r="7"/>'
             '<path d="M150 124c8-6 20-6 28 0"/>')

W["meat"] = ('<path d="M100 100c-4-30 26-48 66-48 46 0 84 20 84 56 0 34-38 52-80 52-42 0-66-26-70-60Z"/>'
             '<path d="M126 92h102v22h-38v36h-26v-36h-38Z"/><path d="M118 70c34-16 88-10 112 8"/>')

W["meeting"] = (person(96, 44, 0.95, legs=False) + person(171, 44, 0.95, hair="long", legs=False) + person(246, 44, 0.95, legs=False) +
                '<rect x="60" y="130" width="222" height="16" rx="3"/><path d="M84 146v30M258 146v30"/><path d="M130 130l14-10h24l6 10M220 130l-12-8h-14"/>')

W["menu"] = ('<rect x="100" y="24" width="142" height="152" rx="6"/><path d="M132 50h78M120 80h56M200 80h22M120 102h44M188 102h34M120 124h64M204 124h18M120 146h40M190 146h32"/>'
             '<circle cx="171" cy="52" r="0"/>')

W["message"] = ('<path d="M84 40h174c9 0 16 7 16 16v60c0 9-7 16-16 16h-96l-34 30v-30H84c-9 0-16-7-16-16V56c0-9 7-16 16-16Z"/>'
                '<circle cx="132" cy="86" r="6"/><circle cx="171" cy="86" r="6"/><circle cx="210" cy="86" r="6"/>'
                '<circle cx="268" cy="38" r="16"/><path d="M268 30v16"/>')

W["milk"] = ('<path d="M96 66h64v110H96Z"/><path d="M96 66l16-28h32l16 28M112 38V24h32v14"/><circle cx="128" cy="112" r="14"/><path d="M128 102v20M118 112h20"/>'
             '<path d="M196 100h58l-8 76h-42Z"/><path d="M199 126h52"/>')

W["mother"] = (person(112, 26, 1.4, hair="bun", dress=True) + person(220, 86, 0.9) + '<path d="M150 120l50 18"/>')

W["movie"] = ('<path d="M112 100l10 76h98l10-76Z"/><path d="M144 100l6 76M171 100v76M198 100l-6 76"/>'
              '<circle cx="128" cy="88" r="13"/><circle cx="152" cy="76" r="14"/><circle cx="182" cy="74" r="14"/><circle cx="208" cy="82" r="13"/><circle cx="224" cy="94" r="10"/>')

W["nose"] = '<path d="M171 26 132 122c-6 14 4 24 20 24h38c16 0 26-10 20-24Z"/><path d="M146 132c6 6 14 6 20 0M176 132c6 6 14 6 20 0"/>'

W["note"] = ('<path d="M112 34h118v90l-34 40H112Z"/><path d="M196 164v-40h34"/><path d="M130 62h82M130 84h82M130 106h50"/>'
             '<circle cx="171" cy="34" r="6"/>')

W["nurse"] = (person(112, 40, 1.3, dress=True, hair="long") + '<path d="M96 60h32v-10H96ZM112 46v10M107 51h10"/>'
              '<circle cx="246" cy="98" r="44"/><path d="M246 76v44M224 98h44"/>')

W["office"] = ('<rect x="106" y="34" width="112" height="72" rx="4"/><path d="M162 106v16M136 122h52M58 138h226M74 138v38M268 138v38"/>'
               '<path d="M84 138h36v38H84Z" transform="translate(0 0)"/><path d="M124 154h104M250 110h18v28h-18Z"/><path d="M268 120c8 0 8 12 0 12"/>')

W["onion"] = ('<path d="M171 40c6 14 18 22 26 34 22 26 20 74-26 82-46-8-48-56-26-82 8-12 20-20 26-34Z"/>'
              '<path d="M171 46c-20 36-22 80 0 110M171 46c20 36 22 80 0 110"/><path d="M171 40V26M160 160l-4 12M171 160v14M182 160l4 12"/>')

W["page"] = ('<path d="M104 24h106l34 34v118H104Z"/><path d="M210 24v34h34"/><rect x="122" y="76" width="104" height="24"/><path d="M122 122h104M122 140h104M122 158h60"/>')

W["paint"] = ('<path d="M88 116c-8-44 34-76 82-72 54 4 84 34 72 72-8 26-32 8-46 24-12 14-8 32-38 28-42-6-64-16-70-52Z"/>'
              '<circle cx="128" cy="82" r="9"/><circle cx="162" cy="66" r="9"/><circle cx="200" cy="74" r="9"/><circle cx="222" cy="102" r="9"/>'
              '<circle cx="160" cy="138" r="9"/><path d="M250 150l30-58M246 152l-8 12 10 4Z"/>')

W["painting"] = ('<rect x="76" y="30" width="190" height="120" rx="4"/><rect x="90" y="44" width="162" height="92"/>'
                 '<path d="M90 120l40-38 30 26 24-20 68 40"/><circle cx="216" cy="70" r="12"/><path d="M110 150l-16 26M232 150l16 26M171 150v26"/>')

W["paper"] = ('<path d="M108 34h100l32 32v112H108Z"/><path d="M208 34v32h32M126 34V22h100l32 32v112h-18"/>')

W["parent"] = (person(84, 40, 1.2) + person(258, 40, 1.2, hair="bun", dress=True) + person(171, 90, 0.8) +
               '<path d="M112 100l32 22M230 100l-32 22"/>')

W["park"] = ('<path d="M92 100c-22-4-28-28-10-40 2-22 30-32 46-16 14-14 42-6 44 16 22 4 22 34 0 40Z"/>'
             '<path d="M128 100v74M128 132l-18-16M128 120l16-14"/><path d="M200 138h84M204 118h76M210 138v34M274 138v34M204 118v20M280 118v20"/><path d="M50 176h250"/>')

W["party"] = ('<path d="M171 44l42 120H129Z"/><path d="M148 110h46M140 136h62"/><circle cx="171" cy="36" r="9"/>'
              '<path d="M84 60l8 8M100 84l10 2M76 110l10-4M256 60l-8 8M244 90l10 4M262 120l-10-4"/><circle cx="96" cy="140" r="4"/><circle cx="252" cy="146" r="4"/>')

W["pen"] = ('<g transform="translate(171 98) rotate(38) translate(-171 -98)"><path d="M150 28h42v100l-21 32-21-32Z"/><path d="M150 56h42M196 38v40h8V38Z"/>'
            '<path d="M171 148v12M164 160h14"/></g>')

W["pencil"] = ('<g transform="translate(171 98) rotate(38) translate(-171 -98)"><path d="M152 26h38v18h-38Z"/><path d="M152 44h38v82h-38ZM171 44v82"/>'
               '<path d="M152 126l19 34 19-34"/><path d="M163 144h16"/></g><path d="M262 150c10-6 18 2 10 10M282 160c10-4 14 6 6 10"/>')

W["people"] = (person(58, 60, 0.8, legs=False) + person(115, 60, 0.8, hair="long", dress=True, legs=False) + person(171, 60, 0.8, legs=False) +
               person(227, 60, 0.8, hair="bun", dress=True, legs=False) + person(284, 60, 0.8, legs=False))

W["person"] = ('<circle cx="171" cy="98" r="70"/><circle cx="171" cy="78" r="22"/><path d="M128 160c0-26 18-38 43-38s43 12 43 38"/>')

W["phone"] = ('<rect x="120" y="22" width="102" height="152" rx="16"/><rect x="130" y="38" width="82" height="112" rx="4"/><path d="M160 30h22M171 162h.1"/>'
              '<rect x="140" y="50" width="20" height="20" rx="5"/><rect x="180" y="50" width="20" height="20" rx="5"/><rect x="140" y="88" width="20" height="20" rx="5"/>'
              '<rect x="180" y="88" width="20" height="20" rx="5"/><rect x="140" y="126" width="60" height="14" rx="5"/>')

W["photo"] = ('<rect x="100" y="24" width="142" height="152" rx="3"/><rect x="112" y="36" width="118" height="100"/>'
              '<path d="M112 120l32-30 24 22 20-18 42 26"/><circle cx="200" cy="62" r="10"/>')

W["photograph"] = ('<g transform="rotate(-8 171 98)"><rect x="90" y="40" width="130" height="102"/><path d="M90 118l34-30 26 22 22-18 48 30"/><circle cx="188" cy="66" r="9"/></g>'
                   '<g transform="rotate(8 200 100)"><rect x="150" y="60" width="110" height="88" transform="translate(0 6)"/></g>')

W["picture"] = ('<rect x="72" y="36" width="198" height="130" rx="4"/><rect x="88" y="52" width="166" height="98"/>'
                '<path d="M88 132l42-40 30 26 24-20 70 34"/><circle cx="216" cy="82" r="12"/><path d="M171 36V22l-14-6M171 22l14-6"/>')

W["piano"] = ('<rect x="64" y="50" width="214" height="104" rx="6"/>' +
              "".join(f'<path d="M{64+214/8*k} 98V154"/>' for k in range(1, 8)) +
              "".join(f'<rect x="{64+214/8*k-8}" y="50" width="16" height="56"/>' for k in (1, 2, 4, 5, 6)) +
              '<path d="M64 168h214"/>')

W["plant"] = ('<path d="M132 132h78l-10 44h-58Z"/><path d="M124 132h94"/><path d="M171 132V70"/>'
              '<path d="M171 96c-30 0-46-20-44-44 26 0 44 14 44 44Z"/><path d="M171 78c28-4 44-22 42-44-24 2-42 16-42 44Z"/>')

W["player"] = (person(112, 40, 1.3) + ball(250, 156, 20) + '<path d="M144 120l60 28"/>')

W["police"] = ('<g transform="translate(0 6)"><path d="M66 132v-14c0-10 8-18 20-20l24-32c4-4 8-6 14-6h84c6 0 10 2 14 6l24 32c12 2 20 10 20 20v14Z"/>'
               '<path d="M122 98l14-22h34v22ZM178 98V76h32l16 22M66 118h220"/><rect x="146" y="52" width="50" height="10" rx="3"/>'
               '<circle cx="106" cy="140" r="16"/><circle cx="246" cy="140" r="16"/></g>')

W["policeman"] = (person(171, 22, 1.5) + cap(171, 22, 1.5) + '<path d="M196 84l6-4 6 4-2 8h-8Z"/>')

W["pool"] = ('<rect x="56" y="102" width="230" height="70" rx="4"/><path d="M56 128c19-12 38-12 57 0s38 12 57 0 38-12 57 0 38 12 57 0"/>'
             '<path d="M232 102V54c0-10 8-14 18-14M256 102V54c0-10 8-14 18-14M232 62h24M232 82h24"/>')

W["post"] = ('<path d="M112 112V72c0-24 20-38 59-38s59 14 59 38v40Z"/><path d="M142 78h58M112 96h118"/><path d="M171 112v64M140 176h62"/>'
             '<path d="M230 62h24v-22"/>')

W["reader"] = (person(100, 40, 1.3) + '<g transform="translate(152 56) scale(0.6)">' + BOOK + '</g>')

W["restaurant"] = storefront('<circle cx="171" cy="36" r="14"/><circle cx="171" cy="36" r="8"/><path d="M142 22v28M136 22v10q0 6 6 6t6-6V22M200 22c8 4 8 24 0 28v0M200 22v28"/>')

W["rice"] = ('<path d="M100 114h142c0 34-24 56-71 56s-71-22-71-56Z"/><path d="M106 114c4-30 30-48 65-48s61 18 65 48"/>'
             '<path d="M138 92l7 4M168 82l7 4M198 94l7 4M154 106l7 3"/><path d="M234 36l-42 68M250 44l-44 68"/>')

W["scientist"] = (person(112, 40, 1.3) + '<path d="M94 76l18 26 18-26"/>'
                  '<path d="M252 88v34l-26 48h72l-26-48V88ZM246 88h32M232 150h58"/><circle cx="264" cy="60" r="6"/><circle cx="278" cy="42" r="4"/>')

W["sea"] = ('<path d="M128 90a43 43 0 0 1 86 0"/><path d="M171 30v-10M130 46l-8-8M212 46l8-8"/>'
            '<path d="M40 106c14-14 28-14 42 0s28 14 42 0 28-14 42 0 28 14 42 0 28-14 42 0 28 14 42 0"/>'
            '<path d="M40 136c14-14 28-14 42 0s28 14 42 0 28-14 42 0 28 14 42 0 28-14 42 0 28 14 42 0"/>'
            '<path d="M40 166c14-14 28-14 42 0s28 14 42 0 28-14 42 0 28 14 42 0 28-14 42 0 28 14 42 0"/>')

W["sheep"] = ('<path d="M112 92c-14-2-18-22-4-28 2-14 20-20 30-10 8-12 28-12 36-2 12-8 32-2 34 12 14 0 22 18 12 28 8 10 0 26-14 26h-92c-14 0-20-16-2-26Z"/>'
              '<path d="M120 118v40M138 118v40M226 118v40M208 118v40"/>'
              '<ellipse cx="92" cy="106" rx="20" ry="18"/><path d="M76 92l-12-10M108 92l12-10"/><circle cx="88" cy="102" r="3"/><path d="M84 116h12"/>')

W["shop"] = storefront('<rect x="108" y="30" width="60" height="20" rx="3"/><path d="M118 40h40"/><path d="M204 56l4 6M232 56l-4 6"/>')

W["shopping"] = ('<path d="M92 80h84l6 92H86Z"/><path d="M116 80c0-30 44-30 44 0"/>'
                 '<path d="M188 60h74l6 112H182Z"/><path d="M206 60c0-32 40-32 40 0"/><path d="M200 112h56"/>')

W["show"] = ('<path d="M66 28h210v16H66Z"/><path d="M72 44c30 0 50 20 50 66s-10 50-18 66H72Z"/><path d="M270 44c-30 0-50 20-50 66s10 50 18 66h32Z"/>'
             '<path d="M66 176h210"/><path d="M171 92l7 14 15 2-11 10 3 15-14-7-14 7 3-15-11-10 15-2Z"/>')

W["singer"] = (person(100, 40, 1.3, hair="long", dress=True) +
               '<circle cx="176" cy="86" r="10"/><path d="M176 96v56M160 152h32M132 96l32-8"/>'
               '<path d="M244 128V68l26-6v56"/><circle cx="234" cy="128" r="10"/><circle cx="260" cy="120" r="10"/>')

W["sister"] = (person(112, 26, 1.4, hair="long", dress=True) + person(216, 66, 1.05, hair="bun", dress=True) + '<path d="M148 124h36"/>')

W["skirt"] = ('<path d="M128 36h86v16h-86Z"/><path d="M128 52l-40 118h166L214 52"/><path d="M152 52l-14 118M171 52v118M190 52l14 118"/>')

W["snake"] = ('<path d="M66 138C116 152 140 108 102 92 62 76 88 34 148 38c46 4 78 22 100 6"/>'
              '<path d="M68 152c56 14 90-42 50-56-24-10-16-32 30-30 44 4 84 22 108-2"/><path d="M66 138l2 14"/>'
              '<path d="M256 34c14-6 32 4 30 18-2 12-20 16-34 8"/><path d="M286 46l14-6M286 54l14 4"/><circle cx="270" cy="44" r="3"/>')

W["snow"] = flake()

W["son"] = (person(112, 26, 1.4) + person(216, 66, 1.05) + '<path d="M148 124h36"/>')

W["song"] = ('<path d="M112 140V50l120-24v92"/><path d="M112 78l120-24"/><circle cx="96" cy="140" r="16"/><circle cx="216" cy="118" r="16"/>')

W["sound"] = ('<path d="M96 76h32l44-34v112l-44-34H96Z"/><path d="M200 76c10 14 10 30 0 44M224 60c20 24 20 52 0 76M248 44c30 34 30 76 0 108"/>')

W["soup"] = ('<path d="M96 106h150c0 34-30 56-75 56s-75-22-75-56Z"/><path d="M88 106h166M120 174h102"/>'
             '<path d="M136 92c-6-8 6-14 0-24M164 92c-6-8 6-14 0-24M192 92c-6-8 6-14 0-24"/>'
             '<circle cx="132" cy="128" r="6"/><circle cx="172" cy="136" r="6"/><circle cx="206" cy="124" r="6"/>')

W["sport"] = ('<path d="M112 44h118v46c0 28-22 42-59 42s-59-14-59-42Z"/><path d="M112 58H88c0 30 12 40 28 44M230 58h24c0 30-12 40-28 44"/>'
              '<path d="M171 132v22M138 154h66v18h-66Z"/><path d="M171 60l7 14 15 2-11 10 3 15-14-7-14 7 3-15-11-10 15-2Z"/>')

W["spring"] = ('<path d="M52 176h238"/><path d="M171 176V110"/><path d="M148 60c0 34 8 50 23 50s23-16 23-50l-11 12-12-18-12 18Z"/>'
               '<path d="M171 150c-24 0-40-16-42-36 24 0 42 12 42 36Z"/><path d="M171 158c22 0 38-14 40-32-22 0-40 10-40 32Z"/>'
               '<path d="M92 176v-30M92 146c-6-8 0-16 6-14 4-8 14-2 10 6 8 2 6 12-2 12Z"/>')

W["station"] = ('<path d="M112 60c0-16 12-28 28-28h62c16 0 28 12 28 28v92H112Z"/><rect x="126" y="56" width="90" height="44" rx="4"/><path d="M171 56v44"/>'
                '<circle cx="136" cy="128" r="8"/><circle cx="206" cy="128" r="8"/><path d="M112 152h118M96 176l14-24M246 176l-14-24M84 176h174"/>')

W["street"] = ('<path d="M128 70L96 176h150L214 70Z"/><path d="M171 80v14M171 108v18M171 140v22"/>'
               '<rect x="26" y="40" width="80" height="136"/><path d="M40 60h20v18H40ZM70 60h20v18H70ZM40 96h20v18H40ZM70 96h20v18H70ZM40 132h20v18H40Z"/>'
               '<rect x="236" y="56" width="80" height="120"/><path d="M250 76h20v18h-20ZM280 76h20v18h-20ZM250 112h20v18h-20ZM280 112h20v18h-20Z"/>')

W["student"] = (person(112, 40, 1.3) + '<path d="M148 104l40 10"/>'
                '<rect x="200" y="152" width="80" height="16"/><rect x="206" y="132" width="70" height="18"/><rect x="198" y="110" width="84" height="20"/>')

W["study"] = ('<g transform="translate(-14 14)">' + BOOK + '</g><circle cx="272" cy="50" r="16"/><path d="M266 68h12M268 74h8M272 34v-8M258 40l-6-4M286 40l6-4"/>')

W["sugar"] = cube(140, 128, 36) + cube(206, 128, 36) + cube(173, 86, 36)

W["summer"] = ('<circle cx="171" cy="98" r="42"/><path d="M171 36V18M171 178v-18M109 98H91M251 98h-18M127 54l-12-12M215 142l12 12M127 142l-12 12M215 54l12-12"/>'
               '<path d="M140 90h26v16h-26ZM176 90h26v16h-26ZM166 96h10"/><path d="M158 122q13 12 26 0"/>')

W["swimming"] = ('<circle cx="150" cy="86" r="16"/><path d="M134 82c4-12 28-12 32 0"/><path d="M166 94c16-20 40-30 62-22"/><circle cx="234" cy="70" r="6"/>'
                 '<path d="M50 112c14-12 28-12 42 0s28 12 42 0 28-12 42 0 28 12 42 0 28-12 42 0 28 12 42 0"/>'
                 '<path d="M50 144c14-12 28-12 42 0s28 12 42 0 28-12 42 0 28 12 42 0 28-12 42 0 28 12 42 0"/>')

W["teacher"] = (person(84, 40, 1.3) + glasses(84, 40, 1.3) + '<path d="M118 100l70-40"/>'
                '<rect x="176" y="36" width="112" height="84" rx="4"/><path d="M190 64h50M190 84h74M190 100h34"/><path d="M170 130h124"/>')

W["team"] = (person(64, 46, 0.95) + person(128, 46, 0.95) + person(192, 46, 0.95) +
             '<path d="M56 78h16M120 78h16M184 78h16"/>' + ball(280, 150, 20) + '<path d="M232 120l28 20"/>')

W["teenager"] = (person(171, 26, 1.4) +
                 '<path d="M146 56c0-30 50-30 50 0"/><circle cx="145" cy="60" r="7"/><circle cx="197" cy="60" r="7"/>'
                 '<rect x="212" y="88" width="24" height="42" rx="5"/>')

W["telephone"] = ('<path d="M96 88c0-18 20-22 40-16h70c20-6 40-2 40 16 0 8-6 12-14 12h-16l-6-12h-78l-6 12h-16c-8 0-14-4-14-12Z"/>'
                  '<path d="M96 176H246l-18-62H114Z"/><circle cx="171" cy="146" r="18"/><circle cx="171" cy="146" r="4"/>'
                  '<circle cx="171" cy="132" r="2"/><circle cx="158" cy="142" r="2"/><circle cx="184" cy="142" r="2"/><path d="M128 100l-6 14M214 100l6 14"/>')

W["tennis"] = tennis_racket() + '<circle cx="256" cy="140" r="18"/><path d="M242 128c8 8 8 24 0 32M270 126c-8 8-8 24 0 32"/>'

W["test"] = ('<rect x="100" y="24" width="142" height="152" rx="6"/><path d="M120 56h60M120 78h40"/>'
             '<circle cx="204" cy="80" r="20"/><path d="M196 92l8-22 8 22M198 86h12"/>'
             '<path d="M120 114h100M120 134h100M120 154h60"/>')

W["town"] = (bldg(56, 84, 52, 92, 2, 3) + bldg(114, 52, 60, 124, 2, 4) + bldg(180, 100, 44, 76, 1, 2) + bldg(230, 74, 56, 102, 2, 3) +
             '<path d="M144 52V34M136 34h16M40 176h262"/>')

W["traffic"] = ('<rect x="58" y="34" width="34" height="86" rx="8"/><circle cx="75" cy="52" r="8"/><circle cx="75" cy="77" r="8"/><circle cx="75" cy="102" r="8"/><path d="M75 120v56M58 176h34"/>'
                + car(184, 140, 0.55) + car(268, 118, 0.42) + '<path d="M110 176h210"/>')

W["train"] = ('<rect x="40" y="60" width="132" height="76" rx="14"/><rect x="176" y="60" width="126" height="76" rx="14"/><path d="M172 98h4"/>'
              '<rect x="56" y="74" width="30" height="26" rx="3"/><rect x="96" y="74" width="30" height="26" rx="3"/><rect x="136" y="74" width="26" height="26" rx="3"/>'
              '<rect x="190" y="74" width="30" height="26" rx="3"/><rect x="230" y="74" width="30" height="26" rx="3"/><rect x="270" y="74" width="20" height="26" rx="3"/>'
              '<circle cx="80" cy="146" r="10"/><circle cx="140" cy="146" r="10"/><circle cx="210" cy="146" r="10"/><circle cx="270" cy="146" r="10"/><path d="M28 162h286"/>')

W["travel"] = ('<path d="M52 108L292 34 206 158 172 118Z"/><path d="M292 34L172 118M172 118l-8 42 30-32"/>'
               '<path d="M52 150c30-30 60-10 90-40"/>')

W["trip"] = ('<path d="M171 176V34"/><path d="M171 44h80l16 14-16 14h-80Z"/><path d="M171 92h-76l-16 14 16 14h76Z"/>'
             '<path d="M120 176h100M52 176h238"/><circle cx="250" cy="152" r="10"/><path d="M250 162v14"/>')

W["vacation"] = ('<path d="M96 96C106 54 190 54 200 96Z"/><path d="M148 68v104M148 68V54"/>'
                 '<path d="M56 176c20-10 40-10 60 0s40 10 60 0 40-10 60 0 40 10 60 0"/>'
                 '<circle cx="262" cy="52" r="18"/><path d="M262 22v-8M236 42l-6-6M288 42l6-6M262 82v8"/>'
                 '<path d="M206 150l30-24 26 24Z" transform="translate(0 0)"/>')

W["tree"] = ('<path d="M100 104a30 30 0 0 1 2-58 42 42 0 0 1 76-12 34 34 0 0 1 62 30 28 28 0 0 1-14 40Z"/>'
             '<path d="M150 104v72h42v-72M171 104V78M171 92l-14-12M171 86l14-10M150 176h-14M192 176h14"/>')

W["trousers"] = ('<rect x="118" y="32" width="106" height="16"/><path d="M118 48l-4 126h50l7-80 7 80h50l-4-126"/><path d="M140 48v22M202 48v22"/>')

W["t_shirt"] = ('<path d="M122 36c14 10 62 10 76 0l50 22-18 38-20-8v88H110V88l-20 8-18-38Z" transform="translate(-6 0)"/><path d="M144 34c8 22 44 22 52 0"/>')

W["tv"] = ('<rect x="64" y="46" width="214" height="116" rx="8"/><rect x="80" y="62" width="150" height="84" rx="4"/>'
           '<circle cx="254" cy="84" r="8"/><circle cx="254" cy="112" r="8"/><path d="M130 46l41-26 41 26M90 162v10M252 162v10"/>')

W["uncle"] = (person(112, 26, 1.4) + '<path d="M96 60q8-8 16 0 8-8 16 0"/><rect x="180" y="118" width="56" height="44"/><path d="M180 134h56M208 118v44M208 118c-14-16-30-8-18 0M208 118c14-16 30-8 18 0"/>')

W["university"] = ('<path d="M52 82L171 30l119 52Z"/><path d="M52 176h238M64 164h214M76 152h190"/>'
                   '<path d="M84 90v62M128 90v62M172 90v62M214 90v62M258 90v62" transform="translate(-13 0)"/><path d="M130 24l41-16 41 16-41 16Z" transform="translate(0 -4)"/>')

W["vegetable"] = ('<path d="M92 62c16-6 32 0 34 14l-16 94c-2 8-10 8-12 0L84 76c0-8 2-12 8-14Z" transform="translate(4 0)"/>'
                  '<path d="M104 60c-10-22-24-28-36-24M104 60c2-24 14-34 28-34M104 60c12-18 28-20 36-12M96 92h14M98 118h14"/>'
                  '<circle cx="230" cy="112" r="50"/><path d="M230 62l-14 14 14-4 14 4-14-14v-14M212 68l-12-4M248 68l12-4"/>')

W["video"] = ('<rect x="62" y="36" width="218" height="124" rx="12"/><path d="M148 70v56l50-28Z"/><path d="M84 146h174"/><circle cx="130" cy="146" r="6"/>')

W["village"] = (house(52, 78, 78, 98) + house(140, 96, 62, 80) + house(214, 84, 76, 92) + '<path d="M40 176h262M120 176c10-20 10-30 0-40"/>')

W["waiter"] = (person(110, 44, 1.3) + '<path d="M96 66l7 5 7-5-7-5ZM110 71v0"/><path d="M140 96l34-34"/><path d="M160 60h100"/><path d="M190 60c0-24 40-24 40 0"/><circle cx="210" cy="30" r="0"/>')

W["walk"] = ('<path d="M52 176h238"/>' + fig((178, 54), (172, 72), (166, 122), [[(150, 92), (140, 116)], [(194, 90), (204, 110)]], [[(190, 140), (206, 174)], [(150, 146), (126, 160)]]) +
             '<path d="M232 92h40M262 84l10 8-10 8"/>')

W["water"] = ('<path d="M171 24c30 40 48 62 48 86 0 28-22 48-48 48s-48-20-48-48c0-24 18-46 48-86Z"/><path d="M146 112c0 14 6 24 16 28"/>'
              '<path d="M104 176c14-8 28-8 42 0s28 8 42 0 28-8 42 0"/>')

W["weather"] = ('<path d="M76 138a30 30 0 0 1 4-60 40 40 0 0 1 74-8 32 32 0 0 1 34 68Z"/><path d="M96 158l-6 14M126 158l-6 14M156 158l-6 14"/>'
                '<circle cx="246" cy="62" r="24"/><path d="M246 22v10M246 92v10M206 62h10M276 62h10M218 34l7 7M267 83l7 7M274 34l-7 7"/>')

W["wife"] = (person(112, 36, 1.3, hair="long", dress=True) + person(230, 36, 1.3) +
             '<circle cx="171" cy="130" r="10"/><path d="M165 112l6-9 6 9Z"/><path d="M148 108l14 14M194 108l-14 14"/>')

W["window"] = ('<rect x="106" y="34" width="130" height="122" rx="3"/><rect x="118" y="46" width="106" height="98"/><path d="M171 46v98M118 95h106"/>'
               '<path d="M98 156h146v10H98Z"/><path d="M84 30c20 10 20 60 10 90M258 30c-20 10-20 60-10 90"/>')

W["wine"] = ('<path d="M112 34h64c0 44-8 66-32 68-24-2-32-24-32-68Z"/><path d="M114 60h60M144 102v50M116 154h56"/>'
             '<path d="M238 176V90c0-14 6-20 6-34V36h18v20c0 14 6 20 6 34v86Z"/><rect x="236" y="112" width="34" height="34"/><path d="M240 36h26"/>')

W["winter"] = ('<circle cx="171" cy="140" r="38"/><circle cx="171" cy="90" r="27"/><circle cx="171" cy="54" r="19"/>'
               '<path d="M156 40h30M160 40V22h22v18M167 52h.1M175 52h.1M171 56l14 4-14 2"/><path d="M171 84h.1M171 100h.1M171 124h.1M171 142h.1"/>'
               '<path d="M144 92l-34-22M198 92l34-22"/><path d="M60 60l14 14M60 74l14-14M270 110l12 12M270 122l12-12"/>')

W["woman"] = (person(171, 22, 1.5, hair="bun", dress=True) + '<path d="M208 104h34v28h-34Z"/><path d="M216 104c0-16 18-16 18 0"/>')

W["work"] = ('<rect x="96" y="44" width="130" height="82" rx="6"/><path d="M76 132h170l-12 16H88Z"/><path d="M122 60h60M122 76h78M122 92h40"/>'
             '<path d="M262 100h34v40c0 10-8 16-17 16-10 0-17-6-17-16Z"/><path d="M296 110h8c6 0 6 20 0 20h-8"/>')

W["worker"] = (person(112, 44, 1.3, hair=None) + hardhat(112, 44, 1.3) +
               '<path d="M242 168l24-96"/><path d="M244 62l50 10-4 16-50-10Z" transform="rotate(-8 268 76)"/>')

W["world"] = ('<circle cx="171" cy="98" r="72"/><ellipse cx="171" cy="98" rx="30" ry="72"/><path d="M99 98h144"/>'
              '<path d="M126 60c8-6 18-4 24 4 4 8-6 12-4 20-10 4-24-6-20-24ZM190 96c14-4 26 4 24 18-6 14-12 16-20 30-8-12-12-30-4-48Z"/>')

W["writer"] = (person(100, 40, 1.3) + '<g transform="translate(172 92) rotate(30) translate(-171 -98) scale(0.9)">' + '<path d="M150 28h42v100l-21 32-21-32Z"/><path d="M150 56h42M196 38v40h8V38Z"/>' + '</g>'
               '<rect x="208" y="60" width="80" height="106" rx="4"/><path d="M222 88h52M222 108h52M222 128h30"/>')

W["writing"] = ('<rect x="60" y="34" width="150" height="132" rx="4"/><path d="M80 66c12-10 20 10 32 0s20 10 32 0 20 10 32 0M80 96c12-10 20 10 32 0s20 10 32 0M80 126c12-10 20 10 32 0"/>'
                '<g transform="translate(234 96) rotate(38) translate(-171 -98)"><path d="M150 28h42v100l-21 32-21-32Z"/><path d="M150 56h42M196 38v40h8V38Z"/></g>')

W["afternoon"] = ('<circle cx="112" cy="84" r="34"/><path d="M112 32v10M112 126v10M60 84h10M154 84h10M76 48l7 7M148 120l-7-7M76 120l7-7M148 48l-7 7"/>'
                  '<circle cx="246" cy="110" r="46"/><path d="M246 110V78M246 110h26M246 70v6M246 150v6M206 110h6M280 110h6"/>')

W["aunt"] = (person(112, 26, 1.4, hair="long", dress=True) + '<rect x="180" y="118" width="56" height="44"/><path d="M180 134h56M208 118v44M208 118c-14-16-30-8-18 0M208 118c14-16 30-8 18 0"/>')

W["break"] = ('<path d="M76 90h100v40c0 22-14 36-38 36h-24c-24 0-38-14-38-36Z"/><path d="M176 102h14c14 0 14 26 0 26h-14"/>'
              '<path d="M108 76c-6-8 6-14 0-24M136 76c-6-8 6-14 0-24"/><circle cx="248" cy="98" r="42"/><path d="M236 80v36M260 80v36"/>')

W["child"] = (person(150, 56, 1.0) + '<ellipse cx="230" cy="52" rx="22" ry="28"/><path d="M230 80l-6 8h12l-6-8ZM230 88c0 30-20 40-44 50"/>')

W["help"] = ('<circle cx="171" cy="98" r="70"/><circle cx="171" cy="98" r="30"/>'
             '<path d="M171 28v40M171 128v40M101 98h40M201 98h40M122 49l22 22M198 125l22 22M122 147l22-22M198 71l22-22"/>')

W["midnight"] = ('<path d="M92 30a44 44 0 1 0 40 62 38 38 0 0 1-40-62Z"/>'
                 + sparkle(172, 44, 12) + sparkle(210, 30, 8) + sparkle(64, 120, 8) +
                 '<circle cx="246" cy="112" r="46"/><path d="M246 112V78M246 112v0"/><path d="M246 70v6M246 150v6M204 112h6M282 112h6"/>')

W["mum"] = (person(126, 26, 1.4, hair="bun", dress=True) + '<circle cx="204" cy="100" r="14"/><path d="M182 118c0-10 10-18 22-18s22 8 22 18v22h-44Z"/><path d="M158 100l24 14"/>')

W["pepper"] = ('<circle cx="171" cy="28" r="10"/><path d="M148 44h46l10 108c0 10-6 16-16 16h-34c-10 0-16-6-16-16Z"/><path d="M146 84h50M146 120h50"/>'
               '<circle cx="86" cy="166" r="4"/><circle cx="106" cy="172" r="4"/><circle cx="240" cy="168" r="4"/><circle cx="262" cy="160" r="4"/>')

W["play"] = ('<circle cx="120" cy="100" r="50"/><path d="M120 50c-24 20-24 80 0 100M76 76c30 10 74 10 88 0M76 124c30-10 74-10 88 0"/>'
             '<rect x="204" y="128" width="44" height="44"/><rect x="230" y="84" width="44" height="44"/><path d="M252 100v12M242 106h20"/>')

W["point"] = ('<path d="M171 28c-28 0-46 20-46 44 0 30 46 82 46 82s46-52 46-82c0-24-18-44-46-44Z"/><circle cx="171" cy="72" r="16"/><ellipse cx="171" cy="168" rx="46" ry="10"/>')

W["pound"] = ('<circle cx="171" cy="98" r="62"/><circle cx="171" cy="98" r="48"/>'
              '<path d="M192 74c-4-10-14-14-24-12-14 4-16 16-14 30l4 26c2 12-4 18-14 22h58M148 104h34"/>')

W["return"] = ('<path d="M100 156V96c0-28 20-48 46-48s46 20 46 48v34"/><path d="M166 108l26 30 26-30"/>')

W["visit"] = (house(170, 56, 110, 120) + person(96, 54, 1.2) + '<path d="M130 84l16-14M134 96l20-6"/>')

W["arrive_verb"] = (house(190, 60, 100, 116) + '<path d="M40 176h250"/>' +
                    fig((80, 62), (76, 80), (74, 128), [[(58, 104), (54, 128)], [(96, 104), (118, 116)]], [[(62, 154), (56, 176)], [(88, 154), (94, 176)]]) +
                    '<rect x="112" y="112" width="24" height="18" rx="2"/>')

W["ask_verb"] = (person(90, 70, 1.1) + person(252, 70, 1.1) +
                 '<path d="M56 24h96c8 0 12 4 12 12v22c0 8-4 12-12 12h-56l-16 14V70h-24c-8 0-12-4-12-12V36c0-8 4-12 12-12Z" transform="translate(6 0)"/>'
                 '<path d="M96 36c0-10 18-10 18 0 0 8-9 8-9 16M105 60v.1"/>')

W["bring_verb"] = ('<path d="M40 176h262"/>' + fig((90, 62), (86, 80), (84, 128), [[(112, 96), (140, 96)], [(104, 108), (136, 112)]], [[(72, 154), (66, 176)], [(98, 154), (104, 176)]]) +
                   '<rect x="140" y="88" width="56" height="44"/><path d="M140 104h56M168 88v44"/><path d="M246 110h-40M218 100l-14 10 14 10"/>')

W["build_verb"] = ('<path d="M40 176h262"/><rect x="60" y="150" width="120" height="26"/><rect x="60" y="124" width="90" height="26"/><rect x="60" y="98" width="60" height="26"/>'
                   '<path d="M90 150v26M120 124v26M150 150v26M90 98v26"/>'
                   '<g transform="translate(248 84) rotate(40)"><rect x="-22" y="-10" width="44" height="20" rx="3"/><path d="M0 10v70"/></g>')

W["buy_verb"] = ('<path d="M76 74h94l6 94H70Z"/><path d="M100 74c0-30 46-30 46 0"/>'
                 '<circle cx="246" cy="74" r="34"/><path d="M256 64c-4-6-18-6-18 4 0 10 20 5 20 15 0 8-16 9-20 3M246 54v6M246 88v6"/><path d="M204 96l-22 22M182 106v12h12"/>')

W["carry_verb"] = ('<path d="M40 176h262"/>' + fig((100, 56), (96, 74), (94, 124), [[(126, 94), (156, 88)], [(122, 108), (154, 106)]], [[(80, 150), (72, 176)], [(108, 150), (116, 176)]]) +
                   '<rect x="154" y="72" width="70" height="56"/><path d="M154 92h70M189 72v20"/><path d="M250 100h30M270 92l10 8-10 8"/>')

W["check_verb"] = ('<rect x="96" y="34" width="150" height="140" rx="8"/><rect x="141" y="24" width="60" height="20" rx="6"/>'
                   '<path d="M126 106l26 26 52-56"/><path d="M126 152h90"/>')

W["clean_verb"] = ('<path d="M96 96h96l-10 74h-76Z"/><path d="M106 96c0-36 76-36 76 0"/><circle cx="130" cy="62" r="10"/><circle cx="162" cy="44" r="7"/><circle cx="196" cy="56" r="12"/>'
                   '<circle cx="230" cy="88" r="6"/><rect x="234" y="126" width="48" height="30" rx="8"/><path d="M246 138h.1M262 146h.1M270 134h.1"/>' + sparkle(288, 80, 10))

W["climb_verb"] = ('<path d="M46 176L160 42l58 70 30-32 48 96Z"/><path d="M160 42V22l24 8-24 8"/>'
                   '<g transform="translate(124 100) scale(0.5)">' + fig((16, -8), (10, 14), (0, 60), [[(-16, 30), (-26, 20)], [(30, 34), (44, 28)]], [[(20, 84), (8, 110)], [(-16, 84), (-30, 108)]]) + '</g>')

W["close_verb"] = ('<rect x="106" y="30" width="130" height="146"/><path d="M106 30l50 14v122l-50 10Z"/><circle cx="144" cy="108" r="3"/>'
                   '<path d="M280 98c-30 0-60-10-90-20M204 70l-14 8 12 14"/>')

W["come_verb"] = ('<path d="M40 176h262"/>' + fig((236, 54), (230, 72), (226, 122), [[(210, 92), (196, 78)], [(250, 94), (262, 112)]], [[(206, 148), (196, 176)], [(240, 148), (248, 176)]]) +
                  '<path d="M170 100h-84M100 90l-14 10 14 10"/><circle cx="66" cy="100" r="8"/>')

W["cook_verb"] = ('<path d="M90 112h110c0 20-16 32-55 32s-55-12-55-32Z"/><path d="M200 116h78v10h-78Z"/><path d="M76 112h136"/>'
                  '<circle cx="146" cy="108" r="0"/><path d="M116 96c-6-8 6-14 0-24M146 96c-6-8 6-14 0-24M176 96c-6-8 6-14 0-24"/>'
                  '<path d="M112 176c-8-10 0-16 4-26 4 6 12 10 6 26ZM146 176c-8-10 0-16 4-26 4 6 12 10 6 26ZM180 176c-8-10 0-16 4-26 4 6 12 10 6 26Z"/>')

W["cut_verb"] = ('<path d="M138 138L204 30M204 138L138 30"/><circle cx="130" cy="152" r="18"/><circle cx="212" cy="152" r="18"/><circle cx="171" cy="84" r="3"/>'
                 '<path d="M60 176h14M88 176h14M116 176h14M144 176h14M172 176h14M200 176h14M228 176h14M256 176h14"/>')

W["draw_verb"] = ('<rect x="66" y="34" width="152" height="128" rx="4"/><path d="M96 118V92l32-26 32 26v26Z"/><path d="M116 118V102h24v16"/>'
                  '<g transform="translate(250 100) rotate(40) translate(-171 -98)"><path d="M152 26h38v18h-38Z"/><path d="M152 44h38v82h-38ZM171 44v82"/><path d="M152 126l19 34 19-34"/></g>')

W["dress_verb"] = (person(96, 40, 1.3) +
                   '<path d="M262 48v-8c10 0 12-12 2-14-10-2-14 8-8 12M262 48L224 70h76Z"/>'
                   '<path d="M234 76c8 12 26 12 34 0l30 14-12 24-16-6v54h-58v-54l-16 6-12-24Z" transform="translate(-2 0)"/>')

W["drink_verb"] = (person(96, 40, 1.3) + '<path d="M150 96l30-22"/><path d="M168 46l40 6-8 48h-24Z" transform="rotate(-12 190 74)"/><path d="M176 62h34"/>')

W["drive_verb"] = car(190, 108, 1.0) + '<path d="M44 92h44M30 108h58M44 124h44M40 176h262"/>'

W["eat_verb"] = (person(100, 40, 1.3) + '<path d="M148 100l40-28M196 64l8-14M204 50l6 14M198 50l8 10"/><circle cx="212" cy="70" r="14"/>')

W["exercise_verb"] = ('<path d="M52 176h238"/>' + fig((171, 42), (171, 60), (171, 112), [[(140, 62), (118, 42)], [(202, 62), (224, 42)]], [[(140, 146), (124, 176)], [(202, 146), (218, 176)]]))

W["fall_verb"] = ('<path d="M50 176h242"/>' + fig((200, 108), (182, 118), (132, 140), [[(204, 144), (216, 164)], [(168, 146), (178, 166)]], [[(104, 122), (84, 104)], [(126, 164), (98, 172)]]) +
                  '<path d="M236 92l6-8M246 104l10-2M232 76l2-10"/><circle cx="252" cy="160" r="0"/>')

W["fill_verb"] = ('<g transform="rotate(-38 120 90)"><path d="M92 40h56l-6 70c0 8-4 12-12 12h-20c-8 0-12-4-12-12Z"/><path d="M148 58h14c10 0 10 30 0 30h-12"/></g>'
                  '<path d="M138 90c18 8 40 30 46 66"/><path d="M196 90h62l-8 86h-46Z"/><path d="M200 132h54"/>')

W["find_verb"] = ('<circle cx="140" cy="84" r="52"/><path d="M178 124l70 56"/><circle cx="118" cy="84" r="12"/><path d="M130 84h48M164 84v14M176 84v10"/>' + sparkle(240, 56, 12))

W["follow_verb"] = (person(96, 60, 1.0) + person(224, 40, 1.3) + '<path d="M132 130h50M170 120l14 10-14 10"/>')

W["give_verb"] = ('<path d="M60 136h74c10 0 22-6 30-14l30-26c8-8 20 0 12 10l-22 28c-14 22-36 34-62 34H60Z"/>'
                  '<rect x="186" y="42" width="66" height="50"/><path d="M186 60h66M219 42v50M219 42c-14-14-30-6-18 0M219 42c14-14 30-6 18 0"/><path d="M270 76v34M258 98l12 12 12-12"/>')

W["leave_verb"] = (house(52, 60, 100, 116) + '<path d="M40 176h262"/>' +
                   fig((210, 62), (216, 80), (218, 128), [[(198, 104), (190, 126)], [(234, 102), (244, 82)]], [[(200, 154), (192, 176)], [(230, 154), (240, 176)]]) +
                   '<path d="M262 118h30M282 110l10 8-10 8"/>')

W["listen_verb"] = ('<path d="M196 30c-32 0-54 22-50 58 2 18 12 26 22 34 8 8 6 24 24 24 20 0 24-22 12-32-8-8-4-20 6-28 28-28 8-56-14-56Z"/>'
                    '<path d="M186 54c-18 2-26 18-22 34M120 84a34 34 0 0 0 0 42M96 68a58 58 0 0 0 0 74M72 54a82 82 0 0 0 0 100"/>')

W["make_verb"] = ('<rect x="60" y="140" width="220" height="26" rx="3"/><path d="M170 140V116"/>'
                  '<g transform="translate(216 66) rotate(40)"><rect x="-24" y="-12" width="48" height="24" rx="3"/><path d="M0 12v76"/></g>'
                  '<path d="M96 120l-14-8M108 110l-4-14M76 132l-14-2"/>')

W["meet_verb"] = (person(84, 40, 1.3) + person(258, 40, 1.3) + '<path d="M112 92l40 12M230 92l-40 12"/><rect x="152" y="98" width="38" height="14" rx="6"/>')

W["move_verb"] = ('<path d="M52 100V86h14M110 86h14v14M124 128v14h-14M66 142H52v-14"/><rect x="218" y="86" width="72" height="56"/><path d="M218 114h72M254 86v28"/>'
                  '<path d="M138 114h64M186 100l16 14-16 14"/>')

W["order_verb"] = ('<path d="M98 132c0-40 20-62 73-62s73 22 73 62Z"/><path d="M82 132h178v16H82Z"/><path d="M171 70V54M158 54h26"/><path d="M120 108c4-14 14-22 26-24"/>')

W["paint_verb"] = ('<g transform="translate(210 90) rotate(38) translate(-171 -98)"><path d="M160 24c-8 18 0 32 11 38 11-6 19-20 11-38"/><rect x="157" y="62" width="28" height="18"/><path d="M162 80l4 78h10l4-78"/></g>'
                   '<path d="M50 150c20-18 40 18 60 0s40-18 60 0"/><path d="M50 166c20-18 40 18 60 0"/>')

W["park_verb"] = (car(226, 130, 0.75) + '<rect x="72" y="30" width="72" height="80" rx="6"/><path d="M96 92V50h20c16 0 16 26 0 26H96"/><path d="M108 110v66M84 176h48"/>')

W["pay_verb"] = ('<g transform="rotate(-14 110 100)"><rect x="52" y="70" width="112" height="72" rx="8"/><path d="M52 90h112"/><rect x="66" y="108" width="24" height="16" rx="3"/></g>'
                 '<rect x="214" y="54" width="70" height="112" rx="8"/><rect x="226" y="68" width="46" height="26"/><path d="M228 112h.1M244 112h.1M260 112h.1M228 128h.1M244 128h.1M260 128h.1M228 144h.1M244 144h.1M260 144h.1"/>'
                 '<path d="M178 90c8 8 8 24 0 32M192 82c12 12 12 36 0 48"/>')

W["put_verb"] = ('<path d="M60 150h222M84 150v26M258 150v26"/><rect x="130" y="102" width="82" height="48"/><path d="M130 118h82M171 102v16"/>'
                 '<path d="M171 30v40M156 56l15 14 15-14"/>')

W["read_verb"] = (person(171, 16, 1.0, legs=False) + '<g transform="translate(171 143) scale(0.8) translate(-171 -113)">' + BOOK + '</g>')

W["relax_verb"] = ('<path d="M66 50v126M276 50v126"/><path d="M66 74c56 84 154 84 210 0"/><path d="M66 74l24 20M276 74l-24 20"/>'
                   '<circle cx="112" cy="112" r="11"/><path d="M124 118c26 22 72 22 100 0"/><path d="M40 176h262"/>'
                   '<circle cx="250" cy="34" r="16"/><path d="M250 8v6M232 18l4 4M268 18l-4 4"/>')

W["ride_verb"] = ('<circle cx="98" cy="140" r="32"/><circle cx="244" cy="140" r="32"/><path d="M98 140l52-50h62l32 50M150 90l24 50h-76M212 90l-6-22h24"/>'
                  + fig((166, 30), (160, 48), (144, 86), [[(190, 62), (216, 66)], [(184, 66), (214, 68)]], [[(172, 112), (166, 134)], [(150, 116), (148, 140)]]))

W["run_verb"] = ('<path d="M50 176h240"/>' + fig((196, 44), (186, 62), (166, 112), [[(160, 86), (140, 76)], [(210, 84), (234, 96)]], [[(190, 134), (222, 138)], [(150, 138), (120, 160)]]) +
                 '<path d="M74 80h44M60 100h50M80 120h34"/>')

W["say_verb"] = (person(88, 50, 1.2) + '<path d="M144 34h124c8 0 12 4 12 12v44c0 8-4 12-12 12h-90l-24 16V102h-10c-8 0-12-4-12-12V46c0-8 4-12 12-12Z" transform="translate(-4 -2)"/>'
                 '<path d="M172 52c-6 4-6 12 0 16M170 60h8M212 52c-6 4-6 12 0 16M210 60h8"/>')

W["see_verb"] = ('<path d="M52 98C96 44 246 44 290 98 246 152 96 152 52 98Z"/><circle cx="171" cy="98" r="34"/><circle cx="171" cy="98" r="14"/><path d="M186 84l6-6"/>')

W["share_verb"] = ('<circle cx="120" cy="100" r="56"/><path d="M120 44v56l40 40M120 100L64 100" />'
                   '<path d="M186 76L250 44a56 56 0 0 1 12 66Z" transform="translate(22 8)"/><path d="M204 150l40 10M232 152l12 8-12 8"/>')

W["shop_verb"] = ('<path d="M108 74h126l-10 96H118Z"/><path d="M136 74c0-38 70-38 70 0"/><path d="M136 100c0 24 70 24 70 0"/>' + sparkle(266, 60, 12) + sparkle(84, 56, 8))

W["show_verb"] = (person(84, 44, 1.3) + '<path d="M112 100l40-22"/><rect x="150" y="34" width="120" height="96" rx="4"/><path d="M162 108l32-30 22 20 20-16 24 22"/><circle cx="238" cy="62" r="10"/><path d="M210 130l-16 46M210 130l16 46"/>')

W["sing_verb"] = ('<circle cx="120" cy="98" r="52"/><path d="M92 76q10-10 20 0M128 76q10-10 20 0"/><ellipse cx="120" cy="120" rx="14" ry="18"/><path d="M96 130v0"/>'
                  '<path d="M214 130V68l30-8v56"/><circle cx="204" cy="130" r="10"/><circle cx="234" cy="122" r="10"/><path d="M268 96c8 8 8 20 0 28M282 84c14 14 14 38 0 52"/>')

W["sit_verb"] = ('<path d="M40 176h262"/><path d="M186 100h60v-46M186 100v76M246 100v76"/>' +
                 fig((156, 44), (152, 62), (166, 104), [[(178, 82), (196, 92)], [(172, 88), (188, 98)]], [[(200, 108), (204, 150)], [(196, 110), (198, 150)]]))

W["sleep_verb"] = ('<rect x="50" y="130" width="202" height="20"/><path d="M58 150v26M244 150v26M50 130V90"/><path d="M62 130V108c0-8 10-14 30-14h20v36"/>'
                   '<circle cx="86" cy="108" r="14"/><path d="M112 130c10-24 40-28 74-16 24 8 46 16 66 16"/>'
                   '<path d="M232 62h20l-20 22h20M262 40h14l-14 16h14"/>')

W["speak_verb"] = ('<path d="M120 30c-30 6-46 32-40 62 2 12 8 22 6 34-1 8 4 12 12 12h8v22h46v-24c10-2 18-8 18-20l10-2c4 0 4-4 2-6l-12-16c0-12 2-18 0-26-6-26-24-42-50-36Z" transform="translate(-20 0)"/>'
                  '<path d="M196 90c8 6 8 18 0 24M214 78c14 12 14 36 0 48M232 66c20 18 20 54 0 72"/>')

W["stand_verb"] = ('<path d="M52 176h238"/>' + fig((171, 34), (171, 52), (171, 104), [[(150, 80), (148, 108)], [(192, 80), (194, 108)]], [[(163, 140), (162, 176)], [(179, 140), (180, 176)]]) +
                   '<path d="M236 122V84M224 96l12-12 12 12"/>')


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
