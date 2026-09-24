#!/usr/bin/env python3
"""Build pictured Oxford 3000 A1 dictionary SVGs from small, original scenes."""

import json
import re
from word_line_art import line_art_svg
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets"
BINDINGS = ROOT / "Packages/WordwellKit/Sources/WordwellData/Resources/IllustrationsSVG/illustration_bindings.json"
PROJECT = ROOT / "Wordwell.xcodeproj/project.pbxproj"

# Each source scene uses the 342 x 196 dictionary coordinates. The SVG output
# converts these colored source motifs to outlines; compositions reuse them.
MOTIFS = {
    "person": '<circle cx="171" cy="49" r="22" fill="#D9AD87"/><path d="M146 43c2-19 13-27 29-26 17 1 25 12 24 28-14-7-34-9-53-2Z" fill="#584B3F"/><path d="M124 145v-34c0-23 17-40 40-40h14c23 0 40 17 40 40v34Z" fill="#6E8571"/><path d="M145 145v15m52-15v15" fill="none" stroke-width="5"/>',
    "woman": '<circle cx="171" cy="51" r="21" fill="#D9AD87"/><path d="M146 48c-5-37 12-43 25-43 23 0 31 18 25 47l13 28h-75Z" fill="#584B3F"/><path d="M146 78h50l37 77H109Z" fill="#B97762"/><path d="M126 116l-17 21m107-21 17 21" fill="none" stroke-width="5"/>',
    "baby": '<circle cx="171" cy="59" r="28" fill="#D9AD87"/><path d="M160 30c6-12 17-13 22-3" fill="none"/><path d="M119 114c0-25 20-40 52-40s52 15 52 40l-17 38h-70Z" fill="#A8B9AD"/><path d="M143 127h56" fill="none"/><circle cx="161" cy="59" r="2" fill="#3A362E"/><circle cx="181" cy="59" r="2" fill="#3A362E"/><path d="M163 72c5 5 11 5 16 0" fill="none"/>',
    "face": '<circle cx="171" cy="85" r="59" fill="#D9AD87"/><path d="M113 69c-4-34 17-54 57-54 42 0 63 20 59 54-26-18-89-18-116 0Z" fill="#584B3F"/><circle cx="150" cy="82" r="4" fill="#3A362E"/><circle cx="192" cy="82" r="4" fill="#3A362E"/><path d="M170 85l-6 20h12m-23 13c12 11 25 11 37 0" fill="none"/>',
    "hand": '<path d="M125 153V96c0-10 13-13 17-3V51c0-13 17-13 17 0v31-43c0-13 17-13 17 0v43-35c0-13 17-13 17 0v39-24c0-13 17-13 17 0v53c0 19-16 38-39 38Z" fill="#D9AD87"/>',
    "arm": '<path d="M73 122c20 0 34-13 50-30l26-29c10-10 22 1 15 12l-21 30c28 4 42-2 60-22 9-11 24 0 16 13-25 42-64 58-105 49l-41-8Z" fill="#D9AD87"/><path d="M73 122v17" fill="none"/>',
    "leg": '<path d="M127 28h83l-10 71-11 50h-41l-9-51Z" fill="#6E8571"/><path d="M147 149h46v11h-77c-2-9 12-12 31-11Z" fill="#9B7050"/><path d="M169 44v96" fill="none"/>',
    "foot": '<path d="M139 48h49v59c12 18 24 29 53 32 15 2 19 18 6 21H99c-14-2-17-16-7-22 15-9 34-16 47-31Z" fill="#D9AD87"/><path d="M89 147h158" fill="none"/>',
    "eye": '<path d="M68 91c50-57 156-57 206 0-50 57-156 57-206 0Z" fill="#F7F2E6"/><circle cx="171" cy="91" r="35" fill="#6E8571"/><circle cx="171" cy="91" r="18" fill="#3A362E"/><circle cx="181" cy="80" r="7" fill="#F7F2E6"/>',
    "ear": '<path d="M166 25c-44 0-67 27-63 68 3 27 22 38 35 48 10 8 10 22 29 22 22 0 24-24 12-34-10-9-6-24 6-35 36-36 12-69-19-69Z" fill="#D9AD87"/><path d="M160 45c-26 3-39 22-33 44m0 0c10-16 30-18 37-4 10 18-15 28-15 45" fill="none"/>',
    "nose": '<path d="M170 26 124 119c-6 13 6 23 22 23h49c16 0 28-10 22-23Z" fill="#D9AD87"/><path d="M139 131c7 8 18 9 28 2m8 0c10 7 21 6 28-2" fill="none"/>',
    "mouth": '<path d="M73 94c31-28 62-29 98-7 36-22 67-21 98 7-30 40-64 54-98 54S103 134 73 94Z" fill="#B97762"/><path d="M89 105c55 13 109 13 164 0" fill="none"/><path d="M112 116c36 7 82 7 118 0" fill="none" stroke="#F7F2E6" stroke-width="8"/>',
    "tooth": '<path d="M102 40c-19 18-9 55 2 79 10 23 15 41 28 41 14 0 12-29 39-45 27 16 25 45 39 45 13 0 18-18 28-41 11-24 21-61 2-79-20-19-41-2-69 2-28-4-49-21-69-2Z" fill="#F7F2E6"/><path d="M114 54c15-11 33-1 48 1" fill="none"/>',
    "tree": '<path d="M152 107h38v52h-38Z" fill="#9B7050"/><path d="M105 111c-31-10-27-47 0-56 1-30 34-41 52-24 22-22 55-9 58 19 33-3 50 35 24 57-18 16-111 18-134 4Z" fill="#6E8571"/><path d="M171 154V77m0 53-32-29m32 13 28-30" fill="none"/>',
    "mountain": '<path d="M53 151 127 39l51 73 32-46 79 85Z" fill="#8FA69C"/><path d="m97 84 30-45 30 45-17-8-13 10-14-10Zm94 8 19-26 21 30-17-9-11 9Z" fill="#F7F2E6"/><path d="M45 151h247" fill="none"/>',
    "river": '<path d="M109 26c59 19 104 31 78 54-21 18-85 12-78 31 7 16 75 15 123 43H89c-29-27-36-47 6-61 21-7 52-12 42-22-10-9-40-19-55-45Z" fill="#8FAEAA"/><path d="M90 154h155" fill="none"/>',
    "sun": '<circle cx="171" cy="89" r="43" fill="#D7B662"/><path d="M171 18v19m0 104v19M100 89H81m180 0h-19M121 39l-13-13m126 126-13-13m13-100 13-13M108 152l13-13" fill="none" stroke="#C99B58" stroke-width="5"/>',
    "moon": '<path d="M199 22c-41 10-60 55-40 88 13 22 40 34 66 27-15 17-33 22-51 22-40 0-69-31-69-69 0-40 32-71 71-71 8 0 16 1 23 3Z" fill="#D7B662"/><circle cx="241" cy="43" r="5" fill="#F7F2E6"/><circle cx="257" cy="91" r="4" fill="#F7F2E6"/>',
    "cloud": '<path d="M83 111c-20-2-28-20-16-35 8-10 20-13 33-9 2-28 26-47 54-42 18 3 30 16 35 31 21-14 51-4 53 20 21 1 36 17 32 35-3 16-17 26-35 26H100c-9 0-14-8-17-26Z" fill="#F7F2E6"/>',
    "rain": '<path d="M90 92c-24-9-11-41 13-36 9-29 55-39 72-10 30-17 66 6 60 34 24 3 29 34 5 42H102c-17 0-23-14-12-30Z" fill="#A8B9AD"/><path d="m108 132-8 22m47-22-8 22m47-22-8 22m47-22-8 22" fill="none" stroke="#6E8571" stroke-width="5"/>',
    "snow": '<path d="M90 92c-24-9-11-41 13-36 9-29 55-39 72-10 30-17 66 6 60 34 24 3 29 34 5 42H102c-17 0-23-14-12-30Z" fill="#F7F2E6"/><path d="M116 141h16m-8-8v16m50-8h16m-8-8v16m48-8h16m-8-8v16" fill="none" stroke="#8FAEAA" stroke-width="3"/>',
    "sea": '<path d="M34 103c25 0 25 13 50 13s25-13 50-13 25 13 50 13 25-13 50-13 25 13 74 13v46H34Z" fill="#8FAEAA"/><path d="M42 133c25 0 25 10 50 10s25-10 50-10 25 10 50 10 25-10 50-10 25 10 58 10" fill="none" stroke="#F7F2E6" stroke-width="3"/><circle cx="170" cy="59" r="31" fill="#D7B662"/>',
    "island": '<path d="M35 134c57-17 216-17 272 0v25H35Z" fill="#8FAEAA"/><path d="M102 133c17-21 37-29 69-29s52 8 69 29Z" fill="#C99B58"/><path d="M168 104V39" fill="none" stroke="#9B7050" stroke-width="7"/><path d="M168 51c-24-18-46-15-57 7 26 10 43 8 57-7Zm0 0c21-23 45-23 60-6-19 18-38 22-60 6Z" fill="#6E8571"/>',
    "beach": '<path d="M35 130c67-9 158-7 272 0v30H35Z" fill="#C99B58"/><path d="M35 126c45-13 75-11 112-3s71 8 111-2 36-10 49-7" fill="none" stroke="#8FAEAA" stroke-width="9"/><path d="M158 55v75m-61-75c25-26 92-26 122 0-36 14-85 14-122 0Z" fill="#B97762"/><path d="M158 62v67" fill="none"/>',
    "fire": '<path d="M121 149c-27-26-16-60 9-82-4 26 10 29 16 23 16-20 16-43 10-68 53 25 82 76 62 111-17 30-72 39-97 16Z" fill="#B97762"/><path d="M149 148c-16-18-7-32 11-45 1 15 13 15 20-4 22 22 19 54-14 57-7 0-13-3-17-8Z" fill="#D7B662"/>',
    "building": '<path d="M86 36h170v121H86Z" fill="#C99B58"/><path d="M145 111h52v46h-52Z" fill="#9B7050"/><path d="M103 54h30v30h-30Zm52 0h31v30h-31Zm54 0h30v30h-30Zm-106 51h30v30h-30Zm106 0h30v30h-30Z" fill="#A8B9AD"/><path d="M72 157h199M86 37h170" fill="none" stroke-width="4"/>',
    "road": '<path d="M113 23h116l58 137H55Z" fill="#8C877C"/><path d="M171 30v23m0 25v25m0 27v28" fill="none" stroke="#ECD9AF" stroke-width="5"/><path d="M42 159h258" fill="none"/>',
    "plane": '<path d="M169 20c10 0 14 11 15 31l4 31 79 35v16l-78-18-5 24 23 13v11l-36-8-36 8v-11l23-13-5-24-78 18v-16l79-35 4-31c1-20 5-31 15-31Z" fill="#A8B9AD"/><path d="M169 30v116" fill="none"/>',
    "train": '<path d="M93 32h156c15 0 25 11 25 26v65H68V58c0-15 10-26 25-26Z" fill="#6E8571"/><path d="M85 52h74v40H85Zm98 0h74v40h-74Z" fill="#A8B9AD"/><path d="M69 112h205v20H69Z" fill="#B97762"/><circle cx="112" cy="137" r="16" fill="#584B3F"/><circle cx="230" cy="137" r="16" fill="#584B3F"/><path d="m85 158 30-22m142 22-30-22" fill="none"/>',
    "bath": '<path d="M63 79h216v41c0 19-15 30-39 30H102c-24 0-39-11-39-30Z" fill="#F7F2E6"/><path d="M63 79h216m-180 71-9 10m153-10 9 10M77 61V39c0-13 23-13 23 0v12h27" fill="none" stroke-width="5"/><circle cx="89" cy="67" r="5" fill="#8FAEAA"/>',
    "table": '<path d="M54 72h234v20H54Z" fill="#B98A56"/><path d="M77 92v65m188-65v65" fill="none" stroke="#9B7050" stroke-width="9"/><path d="M60 157h223" fill="none"/>',
    "window": '<path d="M94 20h154v139H94Z" fill="#F7F2E6"/><path d="M105 31h132v117H105Z" fill="#A8B9AD"/><path d="M171 31v117M105 90h132" fill="none" stroke="#F7F2E6" stroke-width="7"/><path d="M85 159h172" fill="none" stroke-width="5"/>',
    "wall": '<path d="M55 32h232v126H55Z" fill="#B97762"/><path d="M55 74h232M55 116h232M132 32v42m78-42v42M94 74v42m78-42v42m78-42v42m-117 0v42m78-42v42" fill="none" stroke="#ECD9AF" stroke-width="5"/>',
    "toilet": '<path d="M73 38h89v53H73Z" fill="#F7F2E6"/><path d="M108 91h124v18c0 27-25 44-62 44-33 0-62-14-62-44Z" fill="#F7F2E6"/><path d="M101 91h138M154 152h42v9h-42" fill="none" stroke-width="4"/><circle cx="145" cy="52" r="4" fill="#B8A06B"/>',
    "shower": '<path d="M107 159V63c0-21 13-34 35-34h44c23 0 34 12 34 32" fill="none" stroke-width="7"/><path d="M183 62h75c0 14-17 25-37 25s-38-11-38-25Z" fill="#A8B9AD"/><path d="m192 101-5 17m26-17-5 17m26-17-5 17m-37 7-5 17m26-17-5 17m26-17-5 17" fill="none" stroke="#8FAEAA" stroke-width="4"/>',
    "phone": '<rect x="114" y="17" width="114" height="143" rx="14" fill="#584B3F"/><rect x="124" y="31" width="94" height="108" rx="5" fill="#A8B9AD"/><circle cx="171" cy="150" r="4" fill="#ECD9AF"/><path d="M152 24h38" fill="none" stroke="#ECD9AF"/>',
    "television": '<path d="M61 44h220v94H61Z" fill="#584B3F"/><path d="M73 56h196v70H73Z" fill="#A8B9AD"/><path d="m128 37 43-26 43 26M95 144h152" fill="none" stroke-width="5"/><circle cx="250" cy="135" r="4" fill="#D7B662"/>',
    "radio": '<path d="M69 59h204v91H69Z" fill="#B98A56"/><path d="M83 77h106v58H83Z" fill="#584B3F"/><path d="M95 91h82m-82 14h82m-82 14h82" fill="none" stroke="#ECD9AF"/><circle cx="227" cy="105" r="24" fill="#D7B662"/><path d="M87 59 234 27" fill="none" stroke-width="3"/>',
    "disc": '<circle cx="171" cy="91" r="65" fill="#A8B9AD"/><circle cx="171" cy="91" r="17" fill="#ECD9AF"/><circle cx="171" cy="91" r="6" fill="#584B3F"/><path d="M114 70c16-22 35-33 59-34m15 106c23-9 35-26 41-47" fill="none" stroke="#F7F2E6" stroke-width="5"/>',
    "envelope": '<path d="M60 49h222v95H60Z" fill="#F7F2E6"/><path d="m60 49 111 70 111-70M60 144l80-61m142 61-80-61" fill="none"/><circle cx="171" cy="107" r="9" fill="#B97762"/>',
    "web": '<path d="M52 35h238v118H52Z" fill="#F7F2E6"/><path d="M52 57h238M67 45h4m12 0h4m12 0h4" fill="none" stroke-width="4"/><circle cx="164" cy="102" r="29" fill="#8FAEAA"/><path d="M135 102h58m-29-29c-15 15-15 43 0 58m0-58c15 15 15 43 0 58" fill="none"/><path d="M212 78h59m-59 16h42m-42 16h53" fill="none"/>',
    "pencil": '<path d="m94 132 120-105 25 28-120 105-41 9Z" fill="#D7B662"/><path d="m94 132 25 28-41 9Z" fill="#B98A56"/><path d="m214 27 25 28 12-11-25-28Z" fill="#B97762"/><path d="m103 144 126-111" fill="none"/>',
    "paper": '<path d="M105 21h110l28 28v110H105Z" fill="#F7F2E6"/><path d="M215 21v28h28M126 72h96m-96 18h96m-96 18h96m-96 18h70" fill="none"/>',
    "ticket": '<path d="M58 58h226v27c-13 1-18 8-18 17s5 16 18 17v27H58v-27c13-1 18-8 18-17s-5-16-18-17Z" fill="#D7B662"/><path d="M149 59v86m30-63h57m-57 20h57m-57 20h32" fill="none"/>',
    "passport": '<path d="M114 19h116v142H114Z" fill="#6E8571"/><path d="M129 34h86v111h-86Z" fill="none" stroke="#D7B662"/><circle cx="172" cy="91" r="26" fill="none" stroke="#D7B662"/><path d="M147 91h50m-25-26c-11 11-11 41 0 52m0-52c11 11 11 41 0 52" fill="none" stroke="#D7B662"/>',
    "map": '<path d="M60 46 127 28l86 18 69-18v112l-69 18-86-18-67 18Z" fill="#F7F2E6"/><path d="M127 28v112m86-94v112M83 108c46-37 60-3 99-28 34-20 62-10 79 6" fill="none" stroke="#6E8571" stroke-width="5"/><circle cx="184" cy="80" r="7" fill="#B97762"/>',
    "calendar": '<path d="M80 37h182v120H80Z" fill="#F7F2E6"/><path d="M80 37h182v31H80Z" fill="#B97762"/><path d="M110 25v24m122-24v24M97 91h147M97 112h147M97 133h147m-98-64v87m49-87v87" fill="none" stroke-width="3"/><circle cx="171" cy="102" r="8" fill="#D7B662"/>',
    "guitar": '<path d="M209 27h37v77l-8 13-18-4-16-16-13 23c-18 28-46 39-70 25-22-13-20-43-2-61 17-17 38-18 53-9l29-28Z" fill="#B98A56"/><circle cx="152" cy="110" r="18" fill="#584B3F"/><path d="M154 106 232 33m-72 79 78-74m-72 80 78-75" fill="none" stroke="#ECD9AF"/>',
    "piano": '<path d="M60 53h222v91H60Z" fill="#584B3F"/><path d="M76 77h190v52H76Z" fill="#F7F2E6"/><path d="M100 77v52m25-52v52m25-52v52m25-52v52m25-52v52m25-52v52m25-52v52" fill="none"/><path d="M90 77h17v31H90Zm35 0h17v31h-17Zm50 0h17v31h-17Zm25 0h17v31h-17Zm25 0h17v31h-17Z" fill="#584B3F"/><path d="M75 144v15m192-15v15" fill="none" stroke-width="5"/>',
    "microphone": '<rect x="143" y="24" width="56" height="79" rx="26" fill="#8FA69C"/><path d="M126 77c0 31 17 49 45 49s45-18 45-49m-45 49v31m-29 0h58" fill="none" stroke-width="5"/><path d="M152 48h38m-38 16h38m-38 16h38" fill="none"/>',
    "music": '<path d="M181 35v95m0-95 66-16v88" fill="none" stroke-width="7"/><ellipse cx="158" cy="137" rx="24" ry="14" fill="#B97762"/><ellipse cx="224" cy="114" rx="24" ry="14" fill="#B97762"/>',
    "film": '<circle cx="171" cy="89" r="59" fill="#584B3F"/><circle cx="171" cy="89" r="10" fill="#ECD9AF"/><circle cx="171" cy="48" r="12" fill="#ECD9AF"/><circle cx="212" cy="89" r="12" fill="#ECD9AF"/><circle cx="171" cy="130" r="12" fill="#ECD9AF"/><circle cx="130" cy="89" r="12" fill="#ECD9AF"/><path d="M224 131h54v20h-97" fill="none" stroke-width="7"/>',
    "pig": '<path d="M101 67c-14-22-3-40 16-36l21 18c22-12 45-12 67 0l21-18c19-4 30 14 16 36 16 22 11 61-13 77-28 19-85 19-113 0-24-16-29-55-15-77Z" fill="#D9AD87"/><ellipse cx="171" cy="112" rx="31" ry="21" fill="#B97762"/><circle cx="159" cy="112" r="5" fill="#785D3E"/><circle cx="183" cy="112" r="5" fill="#785D3E"/><circle cx="135" cy="83" r="4" fill="#3A362E"/><circle cx="207" cy="83" r="4" fill="#3A362E"/>',
    "sheep": '<path d="M99 55c-18-19-7-37 14-36 8-22 34-22 44-6 16-16 42-8 42 9 25-4 37 16 25 33 20 12 16 37 0 43H99c-20-9-19-32 0-43Z" fill="#F7F2E6"/><path d="M118 81c2-21 23-32 53-32s51 11 53 32v27c0 28-21 45-53 45s-53-17-53-45Z" fill="#785D3E"/><path d="M124 89c-21-10-27 18-8 22m102-22c21-10 27 18 8 22" fill="#785D3E"/><circle cx="150" cy="98" r="4" fill="#F7F2E6"/><circle cx="192" cy="98" r="4" fill="#F7F2E6"/><path d="M160 121c7 6 15 6 22 0" fill="none"/>',
    "lion": '<circle cx="171" cy="89" r="68" fill="#B98A56"/><path d="M126 69c0-23 17-39 45-39s45 16 45 39v36c0 28-18 45-45 45s-45-17-45-45Z" fill="#D7B662"/><circle cx="151" cy="84" r="4" fill="#3A362E"/><circle cx="191" cy="84" r="4" fill="#3A362E"/><path d="m160 105 11 9 11-9Z" fill="#584B3F"/><path d="M171 114c-8 12-18 15-29 8m29-8c8 12 18 15 29 8" fill="none"/>',
    "horse": '<path d="M111 56 126 21l20 21c27-9 59 3 77 31l11 44-35 25-30-22-25 13-36-18Z" fill="#9B7050"/><path d="M115 60 91 37l-5 46 21 23M154 43c23-6 48 0 65 23" fill="#584B3F"/><circle cx="195" cy="80" r="4" fill="#3A362E"/><path d="M211 120c-13 5-25 3-35-4" fill="none"/>',
    "snake": '<path d="M77 123c37-44 86-16 99-9 38 20 75 4 79-25 6-44-46-42-53-16-6 21 19 24 28 9" fill="none" stroke="#6E8571" stroke-width="20"/><path d="m75 124-21-5 12 25Z" fill="#6E8571"/><circle cx="228" cy="61" r="3" fill="#3A362E"/><path d="m247 95 21 4-13 8" fill="none" stroke="#B97762" stroke-width="3"/>',
    "mouse": '<ellipse cx="171" cy="112" rx="63" ry="39" fill="#8C877C"/><circle cx="130" cy="75" r="23" fill="#8C877C"/><circle cx="203" cy="75" r="23" fill="#8C877C"/><circle cx="130" cy="75" r="12" fill="#D9AD87"/><circle cx="203" cy="75" r="12" fill="#D9AD87"/><circle cx="149" cy="104" r="3" fill="#3A362E"/><circle cx="190" cy="104" r="3" fill="#3A362E"/><path d="m164 123 7 6 7-6Z" fill="#B97762"/><path d="M219 137c33 0 45-16 52-34" fill="none" stroke-width="4"/>',
    "orange": '<circle cx="171" cy="91" r="57" fill="#C7814D"/><path d="M171 37c4-13 10-20 19-24m-18 27c18-21 35-20 48-9-12 15-28 18-48 9Z" fill="#6E8571"/><circle cx="144" cy="75" r="4" fill="#D7B662"/><circle cx="191" cy="109" r="4" fill="#D7B662"/>',
    "tomato": '<path d="M119 52c-23 13-32 56-10 81 24 28 100 28 124 0 22-25 13-68-10-81-25-14-79-14-104 0Z" fill="#B97762"/><path d="M171 46c-21-22-39-20-48-12l27 19-15 4 26 8 10-19 10 19 26-8-15-4 27-19c-9-8-27-10-48 12Z" fill="#6E8571"/><path d="M171 47V25" fill="none"/>',
    "onion": '<path d="M171 26c8 23 52 36 52 76 0 28-20 50-52 50s-52-22-52-50c0-40 44-53 52-76Z" fill="#C99B8A"/><path d="M171 31v120m-12-98c-24 29-25 67-9 89m33-89c24 29 25 67 9 89" fill="none"/><path d="M147 153h48" fill="none" stroke="#785D3E" stroke-width="5"/>',
    "potato": '<path d="M102 75c7-30 31-46 70-42 44 3 69 31 65 67-3 31-26 50-67 50-46 0-72-27-68-75Z" fill="#B98A56"/><circle cx="137" cy="80" r="3" fill="#785D3E"/><circle cx="191" cy="61" r="3" fill="#785D3E"/><circle cx="215" cy="111" r="3" fill="#785D3E"/><circle cx="155" cy="124" r="3" fill="#785D3E"/>',
    "sandwich": '<path d="M77 125 171 38l94 87-94 30Z" fill="#D7B662"/><path d="M80 111 171 27l91 84-91 27Z" fill="#F7F2E6"/><path d="M83 100 171 18l88 82-88 25Z" fill="#6E8571"/><path d="M77 94 171 10l94 84-94 30Z" fill="#D7B662"/><path d="M171 124v31" fill="none"/>',
    "salad": '<path d="M79 91h184c-5 41-35 62-92 62S84 132 79 91Z" fill="#F7F2E6"/><path d="M97 91c-4-28 25-42 43-23 6-26 36-32 50-10 24-23 53-8 52 18 15 2 24 8 21 15Z" fill="#6E8571"/><circle cx="134" cy="81" r="9" fill="#B97762"/><circle cx="203" cy="79" r="9" fill="#B97762"/><path d="M91 108h160" fill="none"/>',
    "soup": '<path d="M69 84h204c-5 44-29 68-102 68S74 128 69 84Z" fill="#F7F2E6"/><path d="M78 86h186c-8 19-29 28-93 28s-85-9-93-28Z" fill="#C7814D"/><path d="M93 151h157M123 69c-10-13 9-18 1-30m47 30c-10-13 9-18 1-30m47 30c-10-13 9-18 1-30" fill="none"/>',
    "rice": '<path d="M79 105h184c-5 37-35 52-92 52s-87-15-92-52Z" fill="#F7F2E6"/><path d="M92 104c0-30 26-47 79-47s79 17 79 47Z" fill="#ECD9AF"/><path d="M123 83h9m19-9h9m19 9h9m17-7h9m-88 27h9m32-15h9m39 13h9" fill="none" stroke="#B8A06B" stroke-width="3"/>',
    "milk": '<path d="M129 55h84v101h-84Z" fill="#F7F2E6"/><path d="M129 55 145 23h53l15 32M145 23v33m53-33v33" fill="#A8B9AD"/><path d="M143 87h56v44h-56Z" fill="#8FAEAA"/><path d="M154 109c10-22 24-22 34 0-5 10-29 10-34 0Z" fill="#F7F2E6"/>',
    "tea": '<path d="M89 79h150v48c0 18-13 29-31 29h-88c-18 0-31-11-31-29Z" fill="#F7F2E6"/><path d="M239 86h17c22 0 22 36 0 36h-17" fill="none" stroke-width="8"/><path d="M90 84h148" fill="none" stroke="#9B7A46" stroke-width="8"/><path d="M153 57c-9-13 9-18 1-30m39 30c-9-13 9-18 1-30M72 157h199" fill="none"/>',
    "icecream": '<path d="M129 93h85l-43 64Z" fill="#C99B58"/><path d="M123 94c-15-12-9-30 5-35-4-20 11-33 29-28 13-18 39-14 45 5 20-3 35 14 29 32 12 11 6 28-10 31Z" fill="#F7F2E6"/><circle cx="161" cy="62" r="5" fill="#B97762"/><circle cx="189" cy="75" r="5" fill="#B97762"/>',
    "butter": '<path d="M73 99h199v54H73Z" fill="#F7F2E6"/><path d="M95 67h152v61H95Z" fill="#D7B662"/><path d="M95 67 126 45h124l-3 22M95 128h152M73 153h199" fill="none"/>',
    "meat": '<path d="M86 96c-13-24 2-51 29-55 23-3 31 14 60 13 27-1 43-13 61-1 17 12 22 43 3 64-17 19-43 14-62 20-22 6-26 27-53 20-26-7-25-36-38-61Z" fill="#B97762"/><path d="M111 91c17-19 40-11 56-9m8 39c16-8 29-6 40-17" fill="none" stroke="#F7F2E6" stroke-width="7"/>',
    "beer": '<path d="M105 55h118v94H105Z" fill="#D7B662"/><path d="M223 67h22c27 0 27 63 0 63h-22" fill="none" stroke-width="9"/><path d="M99 56c-7-15 3-25 20-21 4-18 23-23 35-12 16-13 36-7 41 9 17-6 29 7 28 24Z" fill="#F7F2E6"/><path d="M126 85v47m28-55v59m28-53v49" fill="none" stroke="#F7F2E6" stroke-width="5"/>',
    "wine": '<path d="M118 31h106l-8 55c-4 27-19 40-45 40s-41-13-45-40Z" fill="#F7F2E6"/><path d="M130 73h82l-2 15c-3 20-16 29-39 29s-36-9-39-29Z" fill="#B97762"/><path d="M171 126v30m-38 0h76" fill="none" stroke-width="5"/>',
    "chocolate": '<path d="M76 41h191v112H76Z" fill="#785D3E"/><path d="M76 78h191m-191 38h191M124 41v112m48-112v112m48-112v112" fill="none" stroke="#9B7050" stroke-width="4"/><path d="M87 53h25m25 0h24m25 0h24m24 0h24" fill="none" stroke="#B98A56"/>',
    "salt": '<path d="M137 55h68l15 94h-98Z" fill="#F7F2E6"/><path d="M142 33h58v23h-58Z" fill="#8FA69C"/><circle cx="153" cy="45" r="3" fill="#584B3F"/><circle cx="172" cy="45" r="3" fill="#584B3F"/><circle cx="191" cy="45" r="3" fill="#584B3F"/><path d="M136 106h70" fill="none"/>',
    "juice": '<path d="M106 45h130l-14 111H120Z" fill="#F7F2E6"/><path d="M114 79h115l-10 69h-96Z" fill="#C7814D"/><path d="m175 79 25-57h33M106 45h130" fill="none" stroke-width="4"/><circle cx="158" cy="113" r="13" fill="#D7B662"/>',
    "shirt": '<path d="M116 32 84 53l-30 43 39 20 21-28v68h114V88l21 28 39-20-30-43-32-21-27 22h-56Z" fill="#6E8571"/><path d="m143 33 28 33 28-33m-28 33v90" fill="none"/>',
    "trousers": '<path d="M112 26h118l-8 130h-45l-6-70-6 70h-45Z" fill="#6E8571"/><path d="M112 47h118m-59 7v33M120 155h45m12 0h45" fill="none"/>',
    "dress": '<path d="M145 25h52l-9 39 58 91H96l58-91Z" fill="#B97762"/><path d="M145 25 171 54l26-29m-43 39h34m-78 80h122" fill="none"/><path d="M145 32 117 79m80-47 28 47" fill="none" stroke-width="7"/>',
    "skirt": '<path d="M128 37h86l37 117H91Z" fill="#B97762"/><path d="M128 37h86v21h-86Zm-20 101h126" fill="none"/><path d="m143 58-16 75m45-75v75m26-75 16 75" fill="none"/>',
    "hat": '<path d="M93 110c0-51 24-74 78-74s78 23 78 74Z" fill="#C99B58"/><path d="M66 109h210v24H66Z" fill="#B98A56"/><path d="M96 99h150" fill="none" stroke="#B97762" stroke-width="11"/>',
    "shoe": '<path d="M111 86h42c12 24 32 37 57 37h34c20 0 30 11 29 30H70c-3-25 12-41 41-45Z" fill="#9B7050"/><path d="M70 144h203m-129-42 17-5m-10 16 20-7" fill="none"/><path d="M69 154h204" fill="none" stroke-width="5"/>',
    "jacket": '<path d="M119 31 91 49 58 135l39 19 24-48v50h100v-50l24 48 39-19-33-86-28-18-29 24h-46Z" fill="#6E8571"/><path d="M148 55 171 85l23-30m-23 30v71M119 114h25m54 0h25" fill="none"/><circle cx="181" cy="104" r="3" fill="#D7B662"/><circle cx="181" cy="129" r="3" fill="#D7B662"/>',
    "sweater": '<path d="M120 33 90 54 61 118l38 17 22-43v65h100V92l22 43 38-17-29-64-30-21-24 25h-54Z" fill="#C99B58"/><path d="M144 36c7 18 47 18 54 0M123 91h96m-96 43h96" fill="none" stroke="#D7B662" stroke-width="5"/>',
    "umbrella": '<path d="M62 90c8-41 45-66 109-66s101 25 109 66c-20-10-40-10-59 0-17-10-34-10-50 0-16-10-33-10-50 0-19-10-39-10-59 0Z" fill="#B97762"/><path d="M171 89v49c0 22-26 29-35 9" fill="none" stroke-width="6"/>',
    "gift": '<path d="M82 77h178v78H82Z" fill="#D7B662"/><path d="M72 61h198v26H72Z" fill="#C99B58"/><path d="M159 62h24v93h-24Z" fill="#B97762"/><path d="M171 61c-33-2-51-6-51-25 0-23 40-19 51 25Zm0 0c33-2 51-6 51-25 0-23-40-19-51 25Z" fill="#B97762"/>',
    "balloon": '<ellipse cx="171" cy="65" rx="43" ry="51" fill="#B97762"/><path d="M162 116h18l-9 13Zm9 13c13 15-10 21 1 32" fill="none"/><path d="M144 46c4-12 12-19 23-22" fill="none" stroke="#F7F2E6"/>',
    "dice": '<rect x="103" y="33" width="136" height="116" rx="16" fill="#F7F2E6"/><circle cx="134" cy="64" r="8" fill="#B97762"/><circle cx="171" cy="64" r="8" fill="#B97762"/><circle cx="208" cy="64" r="8" fill="#B97762"/><circle cx="134" cy="116" r="8" fill="#B97762"/><circle cx="171" cy="116" r="8" fill="#B97762"/><circle cx="208" cy="116" r="8" fill="#B97762"/>',
    "tennis": '<ellipse cx="139" cy="68" rx="47" ry="54" fill="none" stroke="#9B7050" stroke-width="10"/><path d="m171 105 73 53m-131-111 55 57m-55-19 55-57M101 68h76" fill="none" stroke-width="4"/><circle cx="238" cy="57" r="23" fill="#D7B662"/>',
    "pool": '<path d="M48 73h246v86H48Z" fill="#8FAEAA"/><path d="M48 111c25 0 25 12 50 12s25-12 50-12 25 12 50 12 25-12 50-12 25 12 46 12M87 73V28h35v45m-35-25h35" fill="none" stroke="#F7F2E6" stroke-width="5"/>',
    "weights": '<path d="M70 84h202m-197-24h21v48H75Zm30-17h27v82h-27Zm105 0h27v82h-27Zm36 17h21v48h-21Z" fill="#584B3F"/><path d="M70 84h202" fill="none" stroke="#9B7050" stroke-width="8"/>',
    "coin": '<circle cx="171" cy="91" r="62" fill="#D7B662"/><circle cx="171" cy="91" r="49" fill="none" stroke="#B98A56" stroke-width="3"/><path d="M184 65c-10-10-32-8-38 4-14 27 47 16 43 43-3 17-32 23-49 9m31-69v76" fill="none" stroke-width="5"/>',
    "cart": '<path d="M52 39h28l28 86h129l29-62H92" fill="none" stroke="#9B7050" stroke-width="7"/><path d="M110 123h128" fill="none" stroke="#B97762" stroke-width="6"/><circle cx="127" cy="146" r="11" fill="#584B3F"/><circle cx="223" cy="146" r="11" fill="#584B3F"/>',
    "microscope": '<path d="M158 30 196 9l18 31-38 21Z" fill="#6E8571"/><path d="m177 60-13 25c-9 19 0 33 22 33m20-81 11 35c13 37-7 64-47 65M109 143h124v16H109Z" fill="none" stroke="#584B3F" stroke-width="7"/><circle cx="186" cy="124" r="10" fill="#D7B662"/>',
    "brush": '<path d="m104 129 111-104 19 21-112 103Z" fill="#B98A56"/><path d="m104 129 18 20-41 10c-6-16 2-26 23-30Z" fill="#B97762"/><path d="m214 25 19 21 16-15-19-21Z" fill="#584B3F"/>',
    "plate": '<ellipse cx="171" cy="105" rx="93" ry="46" fill="#F7F2E6"/><ellipse cx="171" cy="105" rx="66" ry="29" fill="none" stroke="#B8A06B" stroke-width="3"/><path d="M57 63v86m-10-86v30m20-30v30M285 63v86" fill="none" stroke="#9B7050" stroke-width="5"/>',
    "flag": '<path d="M111 157V27m0 5c48-19 78 25 127 6v73c-49 19-79-25-127-6" fill="#B97762"/><path d="M111 105c49-19 78 25 127 6" fill="none"/><path d="M85 157h52" fill="none" stroke-width="5"/>',
    "leaf": '<path d="M59 129c40-73 90-102 218-97-9 95-77 137-166 118Z" fill="#6E8571"/><path d="M85 141c48-37 93-66 157-92m-80 58-29-31m55 18 4-31" fill="none" stroke-width="4"/>',
    "line": '<path d="M58 102h226" fill="none" stroke="#B97762" stroke-width="8"/><circle cx="58" cy="102" r="6" fill="#B97762"/><circle cx="284" cy="102" r="6" fill="#B97762"/>',
    "paint": '<path d="M86 92c0-42 41-69 88-67 52 2 85 32 79 72-4 25-31 33-50 24-16-7-30 5-23 20 11 25-20 31-39 25-34-11-55-36-55-74Z" fill="#F7F2E6"/><circle cx="125" cy="69" r="12" fill="#B97762"/><circle cx="171" cy="55" r="12" fill="#D7B662"/><circle cx="215" cy="72" r="12" fill="#6E8571"/><circle cx="224" cy="108" r="12" fill="#8FAEAA"/><circle cx="142" cy="125" r="13" fill="#ECD9AF"/>',
    "photo": '<path d="M73 34h196v119H73Z" fill="#F7F2E6"/><path d="M89 51h164v83H89Z" fill="#A8B9AD"/><circle cx="136" cy="77" r="14" fill="#D7B662"/><path d="m92 132 43-39 31 25 33-34 50 48Z" fill="#6E8571"/>',
    "painting": '<path d="M81 28h180v130H81Z" fill="#B98A56"/><path d="M94 41h154v104H94Z" fill="#A8B9AD"/><circle cx="139" cy="68" r="14" fill="#D7B662"/><path d="m97 140 48-44 30 22 32-36 38 58Z" fill="#6E8571"/>',
    "bench": '<path d="M75 71h192v17H75Zm0 31h192v17H75Z" fill="#B98A56"/><path d="M96 120v36m150-36v36M95 72V55m151 17V55" fill="none" stroke="#9B7050" stroke-width="7"/>',
    "badge": '<path d="M171 22 208 54l-8 48-29 47-29-47-8-48Z" fill="#D7B662"/><circle cx="171" cy="81" r="25" fill="#F7F2E6"/><path d="m171 59 5 15 16 1-13 10 4 16-12-10-12 10 4-16-13-10 16-1Z" fill="#B97762"/>',
    "star": '<path d="m171 18 24 47 52 8-38 38 9 51-47-25-47 25 9-51-38-38 52-8Z" fill="#D7B662"/>',
    "pen": '<path d="m96 132 119-107 24 24-119 107-44 14Z" fill="#584B3F"/><path d="m96 132 24 24-44 14Z" fill="#B98A56"/><path d="m215 25 24 24 10-11-24-24Z" fill="#D7B662"/>',
    "glass": '<path d="M111 37h120l-11 119h-98Z" fill="#F7F2E6"/><path d="M117 92h108l-6 57h-96Z" fill="#8FAEAA"/><path d="M111 37h120" fill="none" stroke-width="4"/>',
    "floor": '<path d="M49 91h244v69H49Z" fill="#C99B58"/><path d="M49 116h244m-244 22h244M111 91v25m118-25v25m-75 0v22m-55 0v22m135-22v22" fill="none" stroke="#9B7050" stroke-width="3"/>',
    "machine": '<circle cx="171" cy="92" r="56" fill="#8FA69C"/><circle cx="171" cy="92" r="26" fill="#ECD9AF"/><path d="M162 18h18v22h-18Zm0 126h18v22h-18ZM97 83h22v18H97Zm126 0h22v18h-22ZM117 29l16-10 13 19-16 10Zm80 108 16-10 13 19-16 10Zm-67-10 16 10-13 19-16-10Zm80-108 16 10-13 19-16-10Z" fill="#584B3F"/>',
    "watch": '<path d="M147 19h48l-6 41h-36Zm6 105h36l6 41h-48Z" fill="#9B7050"/><circle cx="171" cy="92" r="47" fill="#F7F2E6"/><circle cx="171" cy="92" r="38" fill="none" stroke="#B98A56" stroke-width="4"/><path d="M171 68v24h21" fill="none" stroke-width="4"/>',
    "elder": '<circle cx="171" cy="53" r="23" fill="#D9AD87"/><path d="M146 48c0-24 9-32 25-32s25 8 25 32c-16-10-34-10-50 0Z" fill="#F7F2E6"/><path d="M122 155v-35c0-26 17-43 49-43s49 17 49 43v35Z" fill="#9B7050"/><path d="M221 103h20v52" fill="none" stroke-width="5"/>',
    "elderwoman": '<circle cx="171" cy="52" r="22" fill="#D9AD87"/><path d="M145 50c-5-29 7-41 26-41s31 12 26 41l10 26h-72Z" fill="#F7F2E6"/><path d="M143 76h56l34 80H109Z" fill="#9B7050"/><path d="M212 113h20v43" fill="none" stroke-width="5"/>',
    "back": '<path d="M123 60c0-23 18-37 48-37s48 14 48 37v95h-96Z" fill="#6E8571"/><path d="M148 36c0-13 10-22 23-22s23 9 23 22v19h-46Z" fill="#584B3F"/><path d="M171 77v66m-46-39-27 38m121-38 27 38" fill="none" stroke-width="4"/>',
    "walking": '<circle cx="171" cy="34" r="18" fill="#D9AD87"/><path d="M150 59h41l21 58-34 7-16-31-19 26-31-13Z" fill="#6E8571"/><path d="m166 113-40 44m58-44 50 43m-83-82-32 25m70-25 33 22" fill="none" stroke="#3A362E" stroke-width="9"/><path d="M77 159h200" fill="none"/>',
    "running": '<circle cx="164" cy="39" r="17" fill="#D9AD87"/><path d="m144 58 40-5 31 43-41 19-29-23Z" fill="#B97762"/><path d="m156 107-43 14-23 36m86-47 46 13 36-20m-111-30-37 19m86-23 31-25" fill="none" stroke="#3A362E" stroke-width="9"/><path d="M48 157h234" fill="none"/>',
    "sitting": '<circle cx="173" cy="42" r="19" fill="#D9AD87"/><path d="M152 65h42v60h-42Z" fill="#6E8571"/><path d="M153 123h70v17h-70Z" fill="#584B3F"/><path d="M223 140v18m-70-18-26 17m44-83-20 33m43-33 28 27" fill="none" stroke-width="7"/><path d="M108 103v53m0-48h50" fill="none" stroke="#9B7050" stroke-width="8"/>',
    "sleeping": '<path d="M58 118h224v26H58Z" fill="#6E8571"/><path d="M71 96h179v25H71Z" fill="#F7F2E6"/><circle cx="107" cy="82" r="23" fill="#D9AD87"/><path d="M86 77c0-19 12-26 24-25 16 1 25 11 22 26-14-7-29-8-46-1Z" fill="#584B3F"/><path d="M94 91h25M60 144v16m222-16v16" fill="none"/>',
    "swimming": '<path d="M45 127c28-13 46-13 71 0s43 13 69 0 47-13 72 0 40 13 52 0M45 149c28-13 46-13 71 0s43 13 69 0 47-13 72 0 40 13 52 0" fill="none" stroke="#8FAEAA" stroke-width="8"/><circle cx="126" cy="65" r="19" fill="#D9AD87"/><path d="M133 83c35-14 69-10 99 4m-43-4 26-27m-62 23-29 27" fill="none" stroke="#6E8571" stroke-width="12"/>',
    "eating": '<circle cx="161" cy="67" r="28" fill="#D9AD87"/><path d="M126 155v-30c0-23 19-38 35-38s35 15 35 38v30Z" fill="#6E8571"/><path d="M213 57v55m-17-53v33m34-33v33m-34 0h34m-17 20-25-25" fill="none" stroke="#9B7050" stroke-width="6"/><path d="M177 74c7-4 14-4 21 0" fill="none"/>',
    "drinking": '<circle cx="150" cy="59" r="26" fill="#D9AD87"/><path d="M111 155v-29c0-25 18-42 39-42s39 17 39 42v29Z" fill="#6E8571"/><path d="m172 101 38-28m-13 0h42l-5 43h-32Z" fill="#F7F2E6"/><path d="m204 88 31-2" fill="none" stroke="#C7814D" stroke-width="7"/>',
    "writing": '<path d="M68 98h206v57H68Z" fill="#B98A56"/><path d="M97 62h131v57H97Z" fill="#F7F2E6"/><path d="M116 82h85m-85 18h66" fill="none"/><path d="m183 101 59-73 15 12-59 73-22 10Z" fill="#D7B662"/><path d="M96 155v7m150-7v7" fill="none"/>',
    "reading": '<circle cx="171" cy="40" r="19" fill="#D9AD87"/><path d="M135 58c-16 6-25 20-25 42v54h122v-54c0-22-9-36-25-42Z" fill="#6E8571"/><path d="M171 95c-31-15-58-16-85-7v46c27-9 54-8 85 8 31-16 58-17 85-8V88c-27-9-54-8-85 7Z" fill="#F7F2E6"/><path d="M171 95v47m-68-37 48 10m42 0 48-10" fill="none"/>',
    "cooking": '<path d="M92 102h159v42H92Z" fill="#9B7050"/><path d="M78 95h185v11H78Z" fill="#584B3F"/><path d="M130 92c-9-12 10-19 2-34m38 34c-9-12 10-19 2-34m38 34c-9-12 10-19 2-34" fill="none"/><path d="M97 144h149m-132 0-10 16m126-16 10 16" fill="none" stroke-width="5"/>',
    "cleaning": '<path d="M211 27 136 156m0 0 103-4-23-26Z" fill="#B98A56"/><path d="M91 64h47v67H91Z" fill="#8FAEAA"/><path d="M92 62h45m-31-18h17m-9 20v-20" fill="none"/><path d="m66 137 9 9m18-15 9 9m-25-36 8 8" fill="none" stroke="#D7B662" stroke-width="4"/>',
    "climbing": '<path d="M57 156 220 23l67 133Z" fill="#8FA69C"/><circle cx="152" cy="72" r="15" fill="#D9AD87"/><path d="m145 91 24 17-15 29m10-29 31-21m-52 19-25 18m37 11 32 18" fill="none" stroke="#B97762" stroke-width="9"/>',
    "carrying": '<circle cx="132" cy="48" r="19" fill="#D9AD87"/><path d="M111 71h42l9 75h-60Z" fill="#6E8571"/><path d="m107 85-25 40m67-40 29 23m-55 38-18 14m40-14 21 14" fill="none" stroke-width="7"/><path d="M171 89h89v58h-89Z" fill="#C99B58"/><path d="M171 89 216 70l44 19m-44-19v77" fill="none"/>',
    "giving": '<circle cx="100" cy="45" r="18" fill="#D9AD87"/><circle cx="242" cy="45" r="18" fill="#D9AD87"/><path d="M75 153v-58c0-20 12-29 25-29s25 9 25 29v58Zm142 0V95c0-20 12-29 25-29s25 9 25 29v58Z" fill="#6E8571"/><path d="m116 98 38 20m72-20-39 20" fill="none" stroke-width="7"/><path d="M150 107h42v31h-42Z" fill="#D7B662"/>',
    "talking": '<circle cx="116" cy="54" r="22" fill="#D9AD87"/><circle cx="226" cy="54" r="22" fill="#D9AD87"/><path d="M79 155v-47c0-22 15-34 37-34s37 12 37 34v47Zm110 0v-47c0-22 15-34 37-34s37 12 37 34v47Z" fill="#6E8571"/><path d="M150 55h43m-34-15h26m-26 30h26" fill="none" stroke="#B97762" stroke-width="4"/>',
    "listening": '<circle cx="171" cy="76" r="31" fill="#D9AD87"/><path d="M125 155v-24c0-25 17-39 46-39s46 14 46 39v24Z" fill="#6E8571"/><path d="M118 83V63c0-31 20-47 53-47s53 16 53 47v20m-105-6h-17v25h21m100-25h17v25h-21" fill="none" stroke-width="7"/>',
    "cycling": '<circle cx="92" cy="128" r="25" fill="none" stroke-width="4"/><circle cx="250" cy="128" r="25" fill="none" stroke-width="4"/><path d="m92 128 52-62 36 62H92l85-62h42l31 62" fill="none" stroke-width="4"/><circle cx="174" cy="36" r="15" fill="#D9AD87"/><path d="m163 53-25 36 41 12m-15-48 36 21 27-8" fill="none" stroke="#B97762" stroke-width="9"/>',
    "falling": '<circle cx="218" cy="67" r="18" fill="#D9AD87"/><path d="m199 86-49 29 20 33m-20-33-46-22m54 36-47 26m59-7 48 11" fill="none" stroke="#B97762" stroke-width="10"/><path d="M65 159h221" fill="none"/><path d="m244 36 10-11m7 22 14-4" fill="none" stroke="#D7B662" stroke-width="4"/>',
    "waving": '<circle cx="150" cy="51" r="21" fill="#D9AD87"/><path d="M112 155v-42c0-27 15-41 38-41s38 14 38 41v42Z" fill="#6E8571"/><path d="m181 91 25-31 16-24m-16 24 20 20" fill="none" stroke="#D9AD87" stroke-width="12"/><path d="m230 31 9-11m0 33 17-4" fill="none" stroke="#D7B662" stroke-width="4"/>',
    "pointing": '<path d="M93 110h79l77-47c13-8 23 6 12 17l-72 62H93Z" fill="#D9AD87"/><path d="M123 110c-14-19-30-21-45-10l15 43h96m-70-15h48" fill="none"/>',
    "smiling": '<circle cx="171" cy="88" r="59" fill="#D9AD87"/><path d="M113 66c-2-33 22-52 58-52s60 19 58 52c-29-15-87-15-116 0Z" fill="#584B3F"/><circle cx="149" cy="82" r="4" fill="#3A362E"/><circle cx="193" cy="82" r="4" fill="#3A362E"/><path d="M142 108c16 22 42 22 58 0" fill="none" stroke-width="5"/>',
    "sadface": '<circle cx="171" cy="88" r="59" fill="#D9AD87"/><path d="M113 66c-2-33 22-52 58-52s60 19 58 52c-29-15-87-15-116 0Z" fill="#584B3F"/><circle cx="149" cy="82" r="4" fill="#3A362E"/><circle cx="193" cy="82" r="4" fill="#3A362E"/><path d="M143 126c14-22 42-22 56 0" fill="none" stroke-width="5"/><path d="m139 90-4 22" fill="none" stroke="#8FAEAA" stroke-width="4"/>',
    "angryface": '<circle cx="171" cy="88" r="59" fill="#D9AD87"/><path d="M113 66c-2-33 22-52 58-52s60 19 58 52c-29-15-87-15-116 0Z" fill="#584B3F"/><path d="m132 73 27 10m51-10-27 10" fill="none" stroke-width="5"/><circle cx="148" cy="87" r="4" fill="#3A362E"/><circle cx="194" cy="87" r="4" fill="#3A362E"/><path d="M149 121h44" fill="none" stroke-width="5"/>',
    "tiredface": '<circle cx="171" cy="88" r="59" fill="#D9AD87"/><path d="M113 66c-2-33 22-52 58-52s60 19 58 52c-29-15-87-15-116 0Z" fill="#584B3F"/><path d="M135 87h27m18 0h27" fill="none" stroke-width="5"/><path d="M157 119h28" fill="none" stroke-width="4"/>',
    "child": '<circle cx="171" cy="51" r="27" fill="#D9AD87"/><path d="M142 49c-2-22 8-32 29-32s31 10 29 32c-18-8-40-8-58 0Z" fill="#584B3F"/><path d="M126 153v-30c0-27 17-44 45-44s45 17 45 44v30Z" fill="#C99B58"/><path d="M148 153v8m46-8v8" fill="none" stroke-width="5"/>',
    "childgirl": '<circle cx="171" cy="51" r="26" fill="#D9AD87"/><path d="M141 49c-5-29 8-39 30-39s35 10 30 39l12 30h-84Z" fill="#584B3F"/><path d="M143 83h56l29 73H114Z" fill="#B97762"/><path d="M146 154v7m50-7v7" fill="none" stroke-width="5"/>',
    "sugar": '<path d="M99 80h65v65H99Zm78 0h65v65h-65ZM138 37h65v65h-65Z" fill="#F7F2E6"/><path d="M99 80 120 61h65l-21 19m13 0 21-19h65l-21 19m-104-43 21-17h65l-21 17" fill="none"/>',
    "lamp": '<path d="M105 35h132l-23 76h-86Z" fill="#D7B662"/><path d="M171 111v43m-45 0h90" fill="none" stroke-width="6"/><path d="m91 53-19-12m180 0-19 12m-62-31V8" fill="none" stroke="#D7B662" stroke-width="4"/>',
    "stage": '<path d="M62 36h218v124H62Z" fill="#9B7050"/><path d="M74 36c21 26 23 66 0 104h43c-7-36-6-69 5-104Zm146 0c11 35 12 68 5 104h43c-23-38-21-78 0-104Z" fill="#B97762"/><path d="M123 141h98m-96-15h92" fill="none" stroke="#D7B662" stroke-width="4"/><circle cx="171" cy="80" r="24" fill="#F7F2E6"/>',
    "thermometer": '<path d="M150 38c0-12 9-21 21-21s21 9 21 21v79c12 8 18 20 18 34 0 21-17 38-39 38s-39-17-39-38c0-14 6-26 18-34Z" fill="#F7F2E6"/><path d="M171 67v78" fill="none" stroke="#B97762" stroke-width="13"/><circle cx="171" cy="151" r="24" fill="#B97762"/>',
    "openbox": '<path d="M98 82h146v72H98Z" fill="#C99B58"/><path d="M98 82 66 45l55-20 50 27 50-27 55 20-32 37M171 52v102" fill="#D7B662"/><path d="M98 82h146M171 52v102" fill="none"/>',
    "broken": '<path d="M95 43h153v99H95Z" fill="#F7F2E6"/><path d="m171 44-16 31 21 20-18 23 14 25" fill="none" stroke="#B97762" stroke-width="5"/><path d="M95 142h153" fill="none"/>',
    "knife": '<path d="m94 143 72-71 22 22-72 71Z" fill="#9B7050"/><path d="M166 72 252 15c25 34 19 55-11 80l-53-1Z" fill="#A8B9AD"/><path d="m102 151 76-75" fill="none"/>',
    "trophy": '<path d="M127 29h88v52c0 33-17 51-44 51s-44-18-44-51Z" fill="#D7B662"/><path d="M126 43H91c-11 37 7 56 43 51m82-51h35c11 37-7 56-43 51m-37 38v20m-38 0h76" fill="none" stroke="#B98A56" stroke-width="6"/>',
    "big": '<circle cx="192" cy="91" r="60" fill="#B97762"/><circle cx="74" cy="119" r="25" fill="#D7B662"/>',
    "small": '<circle cx="113" cy="91" r="60" fill="#D7B662"/><circle cx="237" cy="119" r="25" fill="#B97762"/>',
    "long": '<path d="M52 75h240v24H52Z" fill="#B97762"/><path d="M52 119h89v24H52Z" fill="#D7B662"/><path d="M52 75v68" fill="none"/>',
    "short": '<path d="M52 75h240v24H52Z" fill="#D7B662"/><path d="M52 119h89v24H52Z" fill="#B97762"/><path d="M52 75v68" fill="none"/>',
    "dirty": '<path d="M116 32 84 53l-30 43 39 20 21-28v68h114V88l21 28 39-20-30-43-32-21-27 22h-56Z" fill="#ECD9AF"/><circle cx="145" cy="88" r="13" fill="#9B7050"/><circle cx="187" cy="120" r="15" fill="#9B7050"/><circle cx="124" cy="136" r="7" fill="#9B7050"/>',
    "blonde": '<circle cx="171" cy="83" r="47" fill="#D9AD87"/><path d="M119 70c-7-37 11-58 52-58s59 21 52 58c-19-18-85-18-104 0Z" fill="#D7B662"/><path d="M124 68v65m94-65v65" fill="none" stroke="#D7B662" stroke-width="14"/><circle cx="152" cy="85" r="3" fill="#3A362E"/><circle cx="190" cy="85" r="3" fill="#3A362E"/>',
    "ring": '<circle cx="171" cy="107" r="45" fill="none" stroke="#D7B662" stroke-width="15"/><path d="m146 71 25-49 25 49Z" fill="#A8B9AD"/><path d="M146 71h50" fill="none"/>',
    "quiet": '<circle cx="171" cy="85" r="54" fill="#D9AD87"/><path d="M118 68c-3-32 17-49 53-49s56 17 53 49c-29-14-77-14-106 0Z" fill="#584B3F"/><circle cx="150" cy="83" r="3" fill="#3A362E"/><circle cx="191" cy="83" r="3" fill="#3A362E"/><path d="M160 120h25m-14-15v33" fill="none" stroke-width="4"/>',
    "taxi": '<path d="M48 107V88c0-9 7-15 18-15h26l22-32h110l27 32h26c12 0 18 6 18 15v36H48Z" fill="#D7B662"/><path d="M106 73l20-24h88l20 24Z" fill="#A8B9AD"/><path d="M147 29h48v12h-48Z" fill="#F7F2E6"/><circle cx="105" cy="125" r="19" fill="#3A362E"/><circle cx="237" cy="125" r="19" fill="#3A362E"/><circle cx="105" cy="125" r="7" fill="#ECD9AF"/><circle cx="237" cy="125" r="7" fill="#ECD9AF"/>',
    "pepper": '<path d="M153 40h36v18l21 20v69h-78V78l21-20Z" fill="#785D3E"/><path d="M148 25h46v18h-46Z" fill="#9B7050"/><path d="M143 104h56m-56 24h56" fill="none" stroke="#D7B662" stroke-width="4"/><circle cx="112" cy="145" r="5" fill="#584B3F"/><circle cx="231" cy="144" r="5" fill="#584B3F"/>',
    "cream": '<path d="M92 113h158c-7 29-31 42-79 42s-72-13-79-42Z" fill="#F7F2E6"/><path d="M102 110c7-28 24-25 35-36 9-10 3-23 20-31 16-8 31 2 31 20 19-16 42-3 35 16 20 7 22 21 16 31Z" fill="#F7F2E6"/><path d="M115 114h112" fill="none" stroke="#B8A06B" stroke-width="4"/>',
    "center": '<circle cx="171" cy="91" r="61" fill="none" stroke="#B8A06B" stroke-width="5"/><circle cx="171" cy="91" r="26" fill="#B97762"/><path d="M171 30v30m0 62v30M110 91h30m62 0h30" fill="none" stroke-width="3"/>',
    "half": '<circle cx="171" cy="90" r="61" fill="#F7F2E6"/><path d="M171 29a61 61 0 0 1 0 122Z" fill="#B97762"/><path d="M171 29v122" fill="none" stroke-width="4"/>',
    "quarter": '<circle cx="171" cy="90" r="61" fill="#F7F2E6"/><path d="M171 90V29a61 61 0 0 1 61 61Z" fill="#B97762"/><path d="M171 29v122M110 90h122" fill="none" stroke-width="3"/>',
    "wind": '<path d="M55 64h178c40 0 42-35 14-35-15 0-23 7-25 19M53 94h228M83 126h159c31 0 35 27 11 31-14 2-24-5-25-17" fill="none" stroke="#8FAEAA" stroke-width="6"/><path d="M130 89c-14-15-32-16-42-7 5 16 21 22 42 7Zm66 25c18-16 35-15 47-4-9 15-26 18-47 4Z" fill="#6E8571"/>',
    "addition": '<circle cx="82" cy="98" r="25" fill="#B97762"/><circle cx="260" cy="98" r="25" fill="#B97762"/><path d="M151 98h40m-20-20v40m42-20h19" fill="none" stroke="#6E8571" stroke-width="6"/>',
    "changing": '<path d="M62 77h73v75H62Z" fill="#B97762"/><path d="M207 77h73v75h-73Z" fill="#6E8571"/><path d="M148 93h44m-18-16 18 16-18 16M194 131h-44m18-16-18 16 18 16" fill="none" stroke="#D7B662" stroke-width="5"/>',
    "wilted": '<path d="M178 52c-24 18-26 62-12 105" fill="none" stroke="#6E8571" stroke-width="8"/><path d="M178 53c-22-28-42-27-49-12 3 16 18 24 49 12Zm-4 6c22-25 39-18 42-2-7 15-19 17-42 2Z" fill="#B97762"/><path d="M167 107c-23-16-36-11-42 3 14 14 29 13 42-3Z" fill="#6E8571"/><path d="M138 157h73" fill="none"/>',
    "check": '<circle cx="171" cy="91" r="59" fill="#6E8571"/><path d="m135 92 25 26 50-57" fill="none" stroke="#F7F2E6" stroke-width="12"/>',
    "cross": '<circle cx="171" cy="91" r="59" fill="#B97762"/><path d="m143 63 56 56m0-56-56 56" fill="none" stroke="#F7F2E6" stroke-width="12"/>',
    "leftarrow": '<path d="M272 90H78m69-57L78 90l69 57" fill="none" stroke="#B97762" stroke-width="12"/>',
    "rightarrow": '<path d="M70 90h194m-69-57 69 57-69 57" fill="none" stroke="#B97762" stroke-width="12"/>',
    "magnifier": '<circle cx="145" cy="69" r="41" fill="#A8B9AD"/><path d="m175 101 78 55" fill="none" stroke="#9B7050" stroke-width="14"/><circle cx="145" cy="69" r="18" fill="#ECD9AF"/>',
    "handshake": '<path d="M61 87 116 52l45 22 29-22 91 38-42 59-48-22-20 19-24-19-21 18Z" fill="#D9AD87"/><path d="m61 87 65 57m155-54-90 37m-45-25 25 25m0-53 21 15" fill="none" stroke-width="4"/>',
    "piece": '<path d="M92 36h63c-9 16-1 28 16 28s25-12 16-28h63v48c-17-9-29-1-29 16s12 25 29 16v42H92v-42c17 9 29 1 29-16s-12-25-29-16Z" fill="#D7B662"/>',
}
MOTIFS["fat"] = '<circle cx="171" cy="46" r="23" fill="#D9AD87"/><ellipse cx="171" cy="122" rx="70" ry="46" fill="#6E8571"/><path d="M101 122v32m140-32v32" fill="none" stroke="#3A362E" stroke-width="5"/>'
MOTIFS["fast"] = MOTIFS["running"] + '<path d="M65 72h34M49 91h43M61 111h33" fill="none" stroke="#B97762" stroke-width="5"/>'
MOTIFS["first"] = '<path d="M67 121h68v38H67Zm68-55h72v93h-72Zm72 55h68v38h-68Z" fill="#C99B58"/><text x="171" y="111" text-anchor="middle" font-family="Fraunces, serif" font-size="35" fill="#6E5A34" stroke="none">1</text>'
MOTIFS["again"] = '<path d="M119 66a61 61 0 1 1-9 70m9-70V27m0 39-38-7" fill="none" stroke="#6E8571" stroke-width="11" stroke-linecap="round" stroke-linejoin="round"/><circle cx="171" cy="91" r="17" fill="#B97762"/>'

COLORS = {
    "black": "#211E19", "blue": "#557A9C", "brown": "#9B7050",
    "green": "#6E8571", "grey": "#8C877C", "orange": "#C7814D",
    "pink": "#D99B9D", "purple": "#87729A", "red": "#B97762",
    "white": "#F7F2E6", "yellow": "#D7B662",
}

SPATIAL = {
    "above": '<circle cx="171" cy="52" r="27" fill="#B97762"/><rect x="118" y="104" width="106" height="54" fill="#C99B58"/>',
    "across": '<path d="M70 44h57v94H70Zm145 0h57v94h-57Z" fill="#C99B58"/><path d="M116 91h114m-22-15 22 15-22 15" fill="none" stroke="#B97762" stroke-width="7"/>',
    "around": '<rect x="143" y="63" width="57" height="57" fill="#C99B58"/><path d="M126 57c-44 39-19 91 45 91 56 0 81-41 51-85m-11 17 11-17 17 10" fill="none" stroke="#B97762" stroke-width="6"/>',
    "behind": '<circle cx="171" cy="72" r="34" fill="#B97762"/><rect x="110" y="78" width="122" height="75" fill="#C99B58"/><path d="M110 78h122" fill="none" stroke-width="4"/>',
    "below": '<rect x="118" y="29" width="106" height="61" fill="#C99B58"/><circle cx="171" cy="131" r="27" fill="#B97762"/>',
    "between": '<rect x="65" y="60" width="70" height="78" fill="#C99B58"/><rect x="207" y="60" width="70" height="78" fill="#C99B58"/><circle cx="171" cy="100" r="24" fill="#B97762"/>',
    "down": '<circle cx="112" cy="54" r="24" fill="#B97762"/><path d="M171 39v102m-23-23 23 23 23-23" fill="none" stroke="#6E8571" stroke-width="8"/>',
    "away": '<rect x="64" y="68" width="80" height="80" fill="#C99B58"/><circle cx="230" cy="107" r="25" fill="#B97762"/><path d="M154 107h43m-15-15 15 15-15 15" fill="none" stroke="#6E8571" stroke-width="6"/>',
    "in": '<path d="M90 56h162v99H90Z" fill="#C99B58"/><circle cx="171" cy="107" r="27" fill="#B97762"/><path d="M90 56h162" fill="none" stroke-width="5"/>',
    "near": '<rect x="110" y="62" width="85" height="87" fill="#C99B58"/><circle cx="227" cy="109" r="27" fill="#B97762"/>',
    "opposite": '<rect x="69" y="57" width="77" height="91" fill="#C99B58"/><rect x="196" y="57" width="77" height="91" fill="#6E8571"/><path d="m151 103 29-16-29-16m41 32-29 16 29 16" fill="none" stroke="#B97762" stroke-width="5"/>',
    "over": '<rect x="127" y="96" width="90" height="57" fill="#C99B58"/><circle cx="170" cy="52" r="25" fill="#B97762"/><path d="M88 72c30-44 106-46 145-2m-20-16 20 16-21 12" fill="none" stroke="#6E8571" stroke-width="5"/>',
    "on": '<rect x="105" y="101" width="132" height="56" fill="#C99B58"/><circle cx="171" cy="73" r="27" fill="#B97762"/>',
    "off": '<rect x="75" y="101" width="108" height="56" fill="#C99B58"/><circle cx="244" cy="104" r="25" fill="#B97762"/><path d="m183 65 37 22m-14-22 14 22-25 1" fill="none" stroke="#6E8571" stroke-width="5"/>',
    "outside": '<rect x="72" y="57" width="127" height="100" fill="#C99B58"/><circle cx="246" cy="111" r="27" fill="#B97762"/>',
    "through": '<path d="M86 57h170v97H86Z" fill="#C99B58"/><path d="M119 154V98c0-29 18-45 52-45s52 16 52 45v56Z" fill="#ECD9AF"/><circle cx="149" cy="120" r="19" fill="#B97762"/><path d="M172 120h74m-18-15 18 15-18 15" fill="none" stroke="#6E8571" stroke-width="5"/>',
    "up": '<circle cx="112" cy="132" r="24" fill="#B97762"/><path d="M171 146V44m-23 23 23-23 23 23" fill="none" stroke="#6E8571" stroke-width="8"/>',
    "upstairs": '<path d="M58 154h57v-32h55V90h56V58h57" fill="none" stroke="#C99B58" stroke-width="14"/><path d="m77 115 142-70m-20 2 20-2-7 20" fill="none" stroke="#B97762" stroke-width="6"/>',
    "downstairs": '<path d="M58 58h57v32h55v32h56v32h57" fill="none" stroke="#C99B58" stroke-width="14"/><path d="m77 45 142 70m-20 2 20-2-7-20" fill="none" stroke="#B97762" stroke-width="6"/>',
}
COMPASS = '<circle cx="171" cy="91" r="59" fill="#F7F2E6"/><path d="M171 33v116M113 91h116" fill="none" stroke="#B8A06B"/><text x="171" y="28" text-anchor="middle" fill="#6E5A34" stroke="none">N</text><text x="171" y="168" text-anchor="middle" fill="#6E5A34" stroke="none">S</text><text x="96" y="96" text-anchor="middle" fill="#6E5A34" stroke="none">W</text><text x="246" y="96" text-anchor="middle" fill="#6E5A34" stroke="none">E</text>'
for direction, angle in (("north", 0), ("east", 90), ("south", 180), ("west", 270)):
    SPATIAL[direction] = COMPASS + f'<path d="m171 39-14 53 14-9 14 9Z" fill="#B97762" transform="rotate({angle} 171 91)"/>'

# Oxford 3000 by CEFR level, A1 section. We select meanings that a single
# scene can teach without copying any source artwork or dictionary text.
# https://www.oxfordlearnersdictionaries.com/external/pdf/wordlists/oxford-3000-5000/The_Oxford_3000_by_CEFR_level.pdf
NOUNS = """
actor=person+film
actress=woman+film
adult=person
airport=building+plane
animal=lion
apartment=building
arm=arm
art=brush+paper
artist=person+brush
autumn=tree+leaf
baby=baby
back=back
band=guitar+microphone
bank=building+coin
bath=bath
bathroom=bath+toilet
beach=beach
bedroom=bed+window
beer=beer
bike=bicycle
bill=paper+coin
birthday=cake+balloon
blog=computer+web
body=person
boy=child
boyfriend=person+woman
breakfast=bread+egg
brother=person+person
building=building
butter=butter
cafe=building+coffee
call=phone
card=paper
cent=coin
chart=paper+line
chocolate=chocolate
cinema=building+film
city=building+road
class=person+book
classroom=building+book
clothes=shirt+trousers
college=building+book
colour=brush+paint
concert=microphone+guitar
conversation=person+woman
cooking=plate+fire
country=map+flag
cousin=person+woman
cream=cream
cup=cup
customer=person+cart
dad=person+baby
dance=person+music
dancer=woman+music
dancing=person+music
day=sun
daughter=woman+person
dinner=plate+soup
dish=plate
dollar=coin
dress=dress
driver=person+car
DVD=disc
ear=ear
email=envelope+web
evening=sun+moon
exam=paper+pencil
exercise=person+weights
eye=eye
face=face
farm=house+cow
farmer=person+tree
father=person+baby
festival=balloon+music
film=film
fire=fire
flat=building
flight=plane
floor=floor
food=plate+sandwich
foot=foot
friend=person+person
fruit=apple+orange
game=dice
garden=tree+flower
geography=map+mountain
girl=childgirl
girlfriend=woman+person
glass=glass
grandfather=elder+baby
grandmother=elderwoman+baby
grandparent=elder+baby
group=person+woman+baby
guitar=guitar
gym=weights+building
hair=face
hand=hand
hat=hat
head=face
holiday=beach+bag
home=house
homework=book+pencil
horse=horse
hospital=building+doctor
hotel=building+bed
husband=person+woman
ice=snow
ice cream=icecream
internet=computer+web
interview=person+woman
island=island
jacket=jacket
jeans=trousers
journey=plane+bag
juice=juice
kitchen=table+plate
land=mountain+tree
laugh=face
leg=leg
lesson=person+book
letter=envelope
library=building+book
light=sun
line=paper
lion=lion
list=paper
love=person+woman
lunch=plate+sandwich
machine=machine
magazine=paper+photo
man=person
map=map
market=building+cart
match=football
meal=plate+soup
meat=meat
meeting=person+woman
menu=paper+plate
message=envelope
milk=milk
money=coin
morning=sun
mother=woman+baby
mountain=mountain
mouse=mouse
mouth=mouth
movie=film
museum=building+painting
music=music
neighbour=house+house
news=paper
newspaper=paper
night=moon
nose=nose
note=paper
nurse=woman+doctor
office=building+computer
onion=onion
orange=orange
page=paper
paint=brush
painting=brush+paper
pair=shoe+shoe
paper=paper
parent=person+baby
park=tree+bench
party=balloon+cake
passport=passport
pen=pen
pencil=pencil
people=person+woman+baby
person=person
phone=phone
photo=photo
photograph=photo
piano=piano
picture=painting
pig=pig
plane=plane
plant=tree
player=person+football
police=person+badge
policeman=person+badge
pool=pool
post=envelope
potato=potato
present=gift
radio=radio
rain=rain
reader=person+book
reading=book
restaurant=building+plate
rice=rice
river=river
road=road
room=table+window
salad=salad
salt=salt
sandwich=sandwich
school=building+book
science=microscope
scientist=person+microscope
sea=sea
sheep=sheep
shirt=shirt
shoe=shoe
shop=building+cart
shopping=cart
show=film
shower=shower
singer=person+microphone
sister=woman+woman
skirt=skirt
snake=snake
snow=snow
son=person+person
song=music
sound=music
soup=soup
sport=football+tennis
spring=flower+sun
star=star
station=building+train
story=book
street=road+building
student=person+book
study=book+pencil
sugar=sugar
summer=sun+beach
sun=sun
supermarket=building+cart
sweater=sweater
swimming=pool
table=table
taxi=taxi
tea=tea
teacher=person+book
team=person+person+football
teenager=child
telephone=phone
television=television
tennis=tennis
test=paper+pencil
theatre=building+stage
ticket=ticket
toilet=toilet
tomato=tomato
tooth=tooth
tourist=person+bag
town=building+road
traffic=car+bus
train=train
travel=plane+bag
tree=tree
trip=plane+bag
trousers=trousers
T-shirt=shirt
TV=television
umbrella=umbrella
uncle=person+baby
university=building+book
vacation=beach+bag
vegetable=carrot+tomato
video=film
village=house+tree
visitor=person+house
waiter=person+plate
walk=person+road
wall=wall
watch=watch
water=sea
weather=sun+cloud
website=web
wife=woman+person
window=window
wine=wine
winter=snow+tree
woman=woman
work=person+building
worker=person+building
world=map
writer=person+pencil
writing=paper+pencil
"""

MORE_NOUNS = """
afternoon=sun+clock
aunt=woman+baby
black=color_black
blue=color_blue
break=broken
brown=color_brown
CD=disc
child=child
cold=snow
drink=glass
euro=coin
event=balloon+person
front=face
goodbye=waving
green=color_green
grey=color_grey
help=giving
midnight=moon+clock
mum=woman+baby
pepper=pepper
pink=color_pink
play=dice
point=pointing
pound=coin
purple=color_purple
red=color_red
return=walking+house
visit=person+house
white=color_white
yellow=color_yellow
year=calendar
"""

VERBS = """
arrive=walking+house
ask=talking
break=broken
bring=carrying
build=person+building
buy=cart+coin
call=phone
carry=carrying
check=paper+pen
clean=cleaning
climb=climbing
close=door
come=walking+house
cook=cooking
cut=knife+carrot
dance=person+music
draw=brush+paper
dress=person+shirt
drink=drinking
drive=person+car
eat=eating
email=envelope+web
exercise=running
fall=falling
fill=glass+sea
find=person+key
fly=plane
follow=walking+walking
give=giving
go=walking
grow=flower+tree
hear=listening
help=giving
join=person+woman
laugh=smiling
learn=reading
leave=walking+house
listen=listening
look=eye
love=person+woman
make=person+brush
meet=talking
move=carrying
open=openbox
order=paper+plate
paint=brush+painting
park=car+road
pay=coin+hand
phone=phone
play=dice
post=envelope
put=hand+box
rain=rain
read=reading
relax=sitting
return=walking+house
ride=cycling
run=running
say=talking
see=eye
sell=cart+coin
send=envelope
share=giving
shop=cart
show=pointing
sing=microphone+music
sit=sitting
sleep=sleeping
snow=snow
speak=talking
stand=person
stop=hand
study=reading
swim=swimming
take=hand+gift
talk=talking
teach=person+book
telephone=phone
tell=talking
test=paper+pencil
travel=plane+bag
turn=car+road
visit=person+house
wait=sitting+clock
wake=sleeping+sun
walk=walking
wash=cleaning
watch=person+television
wear=person+shirt
win=trophy
work=person+computer
write=writing
"""

ADJECTIVES = """
afraid=sadface+lion
angry=angryface
big=big
black=color_black
blonde=blonde
blue=color_blue
bored=tiredface
brown=color_brown
busy=person+clock
clean=shirt
cold=snow
cool=snow
dangerous=fire+snake
dark=moon
delicious=cake
different=apple+orange
dirty=dirty
excited=smiling+balloon
fast=running
friendly=smiling+person
full=tea
funny=smiling
green=color_green
grey=color_grey
happy=smiling
healthy=person+apple
high=mountain
hot=fire
hungry=person+plate
large=big
late=clock+running
little=small
long=long
married=person+ring
modern=computer
new=gift
old=elder
open=openbox
pink=color_pink
pretty=flower
purple=color_purple
quick=running
quiet=quiet
red=color_red
sad=sadface
short=short
sick=person+doctor
similar=shoe+shoe
slow=walking
small=small
strong=person+weights
tall=tree
thirsty=person+glass
tired=tiredface
warm=sun
white=color_white
wonderful=flower+sun
yellow=color_yellow
young=child
"""

EXTRA_NOUNS = """
address=house+envelope
answer=talking
capital=building+flag
centre=center
date=calendar
difference=apple+orange
half=half
health=person+apple
hobby=guitar
hour=clock
job=person+building
language=talking
light=lamp
minute=clock
order=paper+plate
partner=person+woman
place=map
plan=map+pen
practice=person+weights
price=coin+ticket
problem=broken
product=box
project=paper+brush
quarter=quarter
question=talking
report=paper
result=trophy
routine=clock+person
space=star+moon
stop=hand
success=trophy
time=clock
turn=car+road
way=road
week=calendar
weekend=calendar+sun
"""

EXTRA_VERBS = """
answer=talking
choose=pointing+gift
correct=paper+pen
create=brush+paper
enjoy=smiling
finish=trophy
lie=sleeping
live=person+house
practise=person+weights
prepare=cooking
repeat=spatial_around
start=flag
stay=person+house
think=person+face
try=running
use=person+machine
welcome=waving
"""

EXTRA_ADJECTIVES = """
complete=paper+pen
correct=paper+pen
early=sun+clock
few=small
near=spatial_near
opposite=spatial_opposite
orange=color_orange
same=shoe+shoe
"""

FINAL_NOUNS = """
air=wind
article=paper
beginning=flag
business=building+coin
company=person+building
cost=coin
east=spatial_east
first=first
form=paper
fun=dice+balloon
history=book+clock
ice cream=icecream
member=person+group
mistake=cross
month=calendar
north=spatial_north
object=box
opposite=spatial_opposite
part=piece
piece=piece
programme=television
south=spatial_south
text=paper
today=calendar+sun
tomorrow=calendar+rightarrow
tonight=moon+clock
west=spatial_west
yesterday=calendar+leftarrow
"""

FINAL_VERBS = """
add=addition
become=child+person
begin=flag
change=changing
compare=apple+orange
complete=check
decide=pointing+gift
design=brush+paper
die=wilted
end=trophy
explain=talking+book
get=hand+gift
have=hand+gift
keep=box+gift
list=paper
lose=key+falling
match=shoe+shoe
plan=map+pen
sound=music
spend=coin+cart
thank=handshake
"""

FINAL_ADJECTIVES = """
beautiful=flower
best=trophy
better=small+big
boring=tiredface
cheap=coin
difficult=sadface+book
easy=smiling+book
exciting=smiling+balloon
expensive=coin+coin+coin
false=cross
famous=person+star
fat=fat
favourite=gift+smiling
final=trophy
first=first
good=smiling
great=trophy
interested=reading
left=leftarrow
natural=tree
next=calendar
east=spatial_east
north=spatial_north
online=web
ready=person+bag
right=rightarrow
special=star
south=spatial_south
true=check
useful=key
welcome=waving
west=spatial_west
wrong=cross
"""

ADVERBS = """
above=spatial_above
across=spatial_across
again=again
around=spatial_around
away=spatial_away
behind=spatial_behind
below=spatial_below
between=spatial_between
down=spatial_down
downstairs=spatial_downstairs
east=spatial_east
fast=fast
first=first
in=spatial_in
near=spatial_near
north=spatial_north
off=spatial_off
on=spatial_on
opposite=spatial_opposite
out=spatial_outside
outside=spatial_outside
over=spatial_over
quickly=fast
south=spatial_south
together=person+person
through=spatial_through
today=calendar+sun
tomorrow=calendar+rightarrow
tonight=moon+clock
under=spatial_below
up=spatial_up
upstairs=spatial_upstairs
west=spatial_west
yesterday=calendar+leftarrow
"""


def recipes(source):
    return dict(line.split("=", 1) for line in source.splitlines() if line.strip())


def scene_for(key):
    if key in MOTIFS:
        return f'<g stroke="#3A362E" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{MOTIFS[key]}</g>'
    if key.startswith("color_"):
        color = COLORS[key.removeprefix("color_")]
        return f'<g stroke="#3A362E" stroke-width="1.8"><circle cx="171" cy="89" r="57" fill="{color}"/></g>'
    if key.startswith("spatial_"):
        return f'<g stroke="#3A362E" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{SPATIAL[key.removeprefix("spatial_")]}</g>'
    path = ASSETS / f"word_{key}_plate.imageset/word_{key}_plate.svg"
    source = path.read_text()
    match = re.search(r"(<g\b[\s\S]*</g>)\s*</svg>", source)
    if not match:
        match = re.search(r"(<g\b[\s\S]*?)\n  <text", source)
    if not match:
        raise ValueError(f"No picture for motif {key}")
    return match.group(1)


def pictured(recipe):
    keys = recipe.split("+")
    if len(keys) == 1:
        positions = [(171, 89, 0.9)]
    elif len(keys) == 2:
        positions = [(108, 90, 0.48), (234, 90, 0.48)]
    else:
        positions = [(81, 90, 0.34), (171, 90, 0.34), (261, 90, 0.34)]
    return "\n    ".join(
        f'<g transform="translate({x} {y}) scale({scale}) translate(-171 -89)">{scene_for(key)}</g>'
        for key, (x, y, scale) in zip(keys, positions, strict=True)
    )


def main():
    catalog = json.loads(BINDINGS.read_text())
    existing = {(item["lemma"].casefold(), item["partOfSpeech"], item["style"]): item
                for item in catalog["assets"] if "dictionary_entry" in item["contexts"]}
    additions = []
    all_nouns = recipes(NOUNS + MORE_NOUNS + EXTRA_NOUNS + FINAL_NOUNS)
    for pos, words in (("noun", all_nouns), ("verb", recipes(VERBS + EXTRA_VERBS + FINAL_VERBS)),
                       ("adjective", recipes(ADJECTIVES + EXTRA_ADJECTIVES + FINAL_ADJECTIVES)),
                       ("adverb", recipes(ADVERBS))):
        for word, recipe in words.items():
            lemma = word.lower()
            slug = re.sub(r"[^a-z0-9]+", "_", lemma).strip("_")
            style = "color_swatch" if recipe.startswith("color_") else "monochrome_line_art"
            key = (lemma, pos, style)
            prior = existing.get(key)
            shown = " and ".join(
                part.removeprefix("color_") + " color" if part.startswith("color_")
                else part.removeprefix("spatial_") + " position" if part.startswith("spatial_")
                else part
                for part in recipe.split("+")
            )
            article = "An" if word == "orange" else "A"
            alt_text = f"{article} {word} color swatch." if style == "color_swatch" else f"A line drawing showing {shown} for {word}."
            noun_style = "color_swatch" if all_nouns.get(word, "").startswith("color_") else "monochrome_line_art"
            reuse = pos != "noun" and all_nouns.get(word) == recipe and (lemma, "noun", noun_style) in existing
            if reuse:
                noun_asset = existing[(lemma, "noun", noun_style)]
                name = noun_asset["assetName"]
                asset_path = noun_asset["assetPath"]
            else:
                name = prior["assetName"] if prior else f"word_{slug}_{pos}_plate" if pos != "noun" else f"word_{slug}_plate"
                asset_path = f"Resources/IllustrationsSVG/Words.xcassets/{name}.imageset/{name}.svg"
                folder = ASSETS / f"{name}.imageset"
                if prior:
                    continue  # Keep curated existing drawings intact.
                else:
                    if folder.exists():
                        raise ValueError(f"Asset name collision: {folder}")
                    folder.mkdir()
                    additions.append(name)
                scene = pictured(recipe)
                svg = line_art_svg(f'<svg xmlns="http://www.w3.org/2000/svg">{scene}</svg>', preserve_color=style == "color_swatch")
                (folder / f"{name}.svg").write_text(svg)
                (folder / "Contents.json").write_text(json.dumps({
                    "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
                    "info": {"author": "xcode", "version": 1},
                    "properties": {"preserves-vector-representation": True}
                }, separators=(",", ":")) + "\n")
            if prior:
                continue
            binding = {
                "id": f"illustration.{slug}.{pos}.plate",
                "word": word, "lemma": lemma, "partOfSpeech": pos, "senseId": None,
                "assetName": name, "assetPath": asset_path,
                "style": style, "contexts": ["dictionary_entry"], "version": 1,
                "tags": ["a1", "visual"], "altText": alt_text,
                "isDecorative": False, "notes": None
            }
            catalog["assets"].append(binding)
            existing[key] = binding

    BINDINGS.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n")
    project = PROJECT.read_text()
    start = project.index("\t\t\tinputPaths = (", project.index("/* Validate SVG illustrations */ = {"))
    end = project.index("\t\t\t);", start)
    existing_inputs = project[start:end]
    new_inputs = "".join(
        f'\t\t\t\t"$(SRCROOT)/Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets/{name}.imageset/{filename}",\n'
        for name in sorted(additions) for filename in ("Contents.json", f"{name}.svg")
        if f"{name}.imageset/{filename}" not in existing_inputs
    )
    if new_inputs:
        project = project[:end] + new_inputs + project[end:]
        PROJECT.write_text(project)
    print(f"Added {len(additions)} dictionary illustrations; {len(catalog['assets'])} bindings total")


if __name__ == "__main__":
    main()
