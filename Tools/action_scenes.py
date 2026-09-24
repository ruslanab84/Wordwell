"""Original action scene sources converted to dictionary line art."""


def scene(drawing):
    return f'<g fill="none" stroke="#3A362E" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{drawing}</g>'


WALKER = '''<circle cx="25" cy="17" r="11" fill="#D9AD87"/><path d="M14 16c0-12 22-15 24-1l-8-5-16 6Z" fill="#584B3F"/>
<path d="M17 31 8 65h39L33 31Z" fill="#6E8571"/><path d="m12 65-10 24m28-24 24 22M14 38 1 58m32-18 19 17" stroke-width="5"/>
<path d="m-4 90 15 3m42-5 12 4" stroke-width="4"/>'''

REACHER = '''<circle cx="23" cy="18" r="11" fill="#D9AD87"/><path d="M12 14c3-13 24-13 25 3l-12-6-13 3Z" fill="#584B3F"/>
<path d="M12 34h28l4 39H8Z" fill="#584B3F"/><path d="M14 72 8 97m29-25 7 25M39 42l34 13m-58-12-13 24" stroke-width="5"/>
<circle cx="75" cy="56" r="4" fill="#D9AD87"/>'''

CAR = '''<path d="M99 89 120 61h111l28 28h27c13 0 20 8 20 18v26H78v-26c0-11 8-18 21-18Z" fill="#B97762"/>
<path d="m129 65-18 24h65V65Zm54 0v24h64l-22-24Z" fill="#A8B9AD"/><path d="M177 65v69m-78-45h176m-81 11h12"/>
<circle cx="125" cy="135" r="19" fill="#584B3F"/><circle cx="263" cy="135" r="19" fill="#584B3F"/>
<circle cx="125" cy="135" r="8" fill="#ECD9AF"/><circle cx="263" cy="135" r="8" fill="#ECD9AF"/>'''

BUS = '''<path d="M84 41h207c12 0 19 8 19 20v76H72V55c0-9 5-14 12-14Z" fill="#6E8571"/>
<path d="M86 53h35v39H86Zm44 0h36v39h-36Zm45 0h35v39h-35Zm83 0h39v39h-39Z" fill="#A8B9AD"/>
<path d="M216 49h34v88h-34Z" fill="#ECD9AF"/><path d="M233 49v88M73 108h236"/>
<circle cx="116" cy="140" r="16" fill="#584B3F"/><circle cx="272" cy="140" r="16" fill="#584B3F"/>
<circle cx="116" cy="140" r="6" fill="#ECD9AF"/><circle cx="272" cy="140" r="6" fill="#ECD9AF"/>'''

BOWL = '''<path d="M78 84c7 49 27 68 93 68s86-19 93-68Z" fill="#F7F2E6"/>
<ellipse cx="171" cy="84" rx="93" ry="22" fill="#C99B58"/><path d="M90 87c27 19 133 21 163 0M116 121c32 14 77 14 110 0"/>
<path d="M126 77c26-13 69-13 94 0" stroke="#F7F2E6" stroke-width="5"/>'''

BOTTLE = '''<path d="M145 53h52v29c13 8 22 22 22 39v38h-96v-38c0-17 9-31 22-39Z" fill="#A8B9AD"/>
<path d="M145 53h52m-67 58h82m-67-43h52"/><path d="M146 39h50v16h-50Z" fill="#F7F2E6"/>'''

ACTION_SCENES = {
    "turn": (scene('''<ellipse cx="110" cy="125" rx="38" ry="17" fill="#D7B662"/><path d="M78 124c22 11 43 11 64 0"/>
        <ellipse cx="238" cy="67" rx="35" ry="14" transform="rotate(-26 238 67)" fill="#D7B662"/>
        <path d="M141 111c24-62 59-69 85-57m-18-10 18 10-15 12" stroke="#B97762" stroke-width="5"/>
        <path d="m89 117 12 3 12-3m113-57 12 2 11-6"/>'''), "A coin flips over from one face to the other."),
    "spin": (scene('''<circle cx="171" cy="94" r="61" fill="#F7F2E6" stroke-width="4"/><circle cx="171" cy="94" r="11" fill="#B97762"/>
        <path d="M171 35v118M112 94h118m-101-42 84 84m0-84-84 84" stroke="#8C877C" stroke-width="3"/>
        <path d="M94 47c-21 25-22 70-2 97m0-19v19l20-4m136-49c3 30-9 54-24 69m17-18-17 18-5-23" stroke="#B97762" stroke-width="5"/>'''), "A wheel spins rapidly, with curved arrows around it."),
    "rotate": (scene('''<circle cx="171" cy="92" r="57" fill="#8FAEAA"/><path d="M147 39c-22 10-27 24-12 35l18-3 10 15-8 23 17 24 22-8 7-25 23-15-17-16-8-22" fill="#6E8571"/>
        <path d="M151 50c-22 38-20 75 1 91m38-94c21 33 23 70 0 90M114 92h114M171 22v141"/>
        <path d="M226 43c17 18 23 39 21 59m-8-16 8 16 8-14M113 139c-14-16-20-39-18-58m8 16-8-16-8 15" stroke="#B97762" stroke-width="5"/>'''), "The Earth rotates around its fixed axis."),
    "twist": (scene(BOTTLE + '''<path d="M202 37c18-10 30-1 30 11 0 14-19 18-31 13l-16-7" fill="#D9AD87"/>
        <path d="M221 28c17 0 28 11 28 25m-5-14 5 14-15 2M116 38c-17 14-24 35-20 54" stroke="#B97762" stroke-width="5"/>
        <path d="M147 154h48"/>'''), "A hand twists the cap of a bottle."),
    "mix": (scene(BOWL + '''<path d="M213 34 173 106" stroke="#8C877C" stroke-width="8"/><path d="M211 31c15-11 27-5 30 6l-8 17-20-4" fill="#D9AD87"/>
        <path d="M104 58c27-19 73-20 105-4m-24-9 24 9-14 16" stroke="#B97762" stroke-width="5"/>
        <circle cx="146" cy="84" r="5" fill="#F7F2E6"/><circle cx="195" cy="89" r="5" fill="#D7B662"/>'''), "A hand mixes two ingredients together in a bowl."),
    "stir": (scene('''<path d="M96 68h137l-11 78H107Z" fill="#F7F2E6"/><ellipse cx="164" cy="68" rx="69" ry="18" fill="#9B7050"/>
        <path d="M233 87c44-5 45 45-7 44m-115-20c27 13 76 14 105 0"/>
        <path d="M209 29 163 78" stroke="#8C877C" stroke-width="8"/><path d="M204 25c16-9 31-1 33 12l-10 14-17-7" fill="#D9AD87"/>
        <path d="M129 76c-23 21 39 33 72 5m-15-10 15 10-17 6" stroke="#B97762" stroke-width="5"/>'''), "A spoon stirs liquid in a cup in a circular motion."),
    "shake": (scene('''<g transform="rotate(-18 171 91)"><path d="M143 43h56l11 95h-78Z" fill="#A8B9AD"/><path d="M143 47h56m-66 74h76"/>
        <path d="M143 29h56v16h-56Z" fill="#584B3F"/></g>
        <path d="M108 84c8-17 23-18 34-13l22 21-16 31-38-6Z" fill="#D9AD87"/>
        <path d="M104 45c-15 29-13 65 1 89m-7-18 7 18 11-16m119-65c15 31 13 62-1 85m7-18-7 18-11-16" stroke="#B97762" stroke-width="5"/>'''), "A hand shakes a closed bottle from side to side."),
    "blend": (scene('''<path d="M103 30h136l-13 91H116Z" fill="#A8B9AD"/><path d="M108 32h127m-110 89h92"/>
        <path d="M117 121h108l14 37H103Z" fill="#8C877C"/><circle cx="171" cy="139" r="10" fill="#D7B662"/>
        <path d="M239 54c36 0 34 43-8 43"/>
        <circle cx="139" cy="82" r="15" fill="#B97762"/><circle cx="186" cy="69" r="13" fill="#D7B662"/><circle cx="201" cy="99" r="12" fill="#6E8571"/>
        <path d="M139 50c8 9 16 10 24 1m32 29c-16 12-31 12-44 0" stroke="#F7F2E6" stroke-width="4"/>
        <path d="m84 61-8-10m3 37-12 1m199-30 10-10m-5 40 12 2" stroke="#B97762" stroke-width="4"/>'''), "Fruit blends inside a running blender."),
    "get in": (scene(CAR + f'<g transform="translate(47 52) scale(.85)">{WALKER}</g>' + '''<path d="M177 66 144 45l-18 45 51 43Z" fill="#ECD9AF"/>
        <path d="M177 66v67M130 113l20 17m-10-41 25 11"/>
        <path d="M79 155c23 0 43-8 55-30m-21 1 21-1-9 18" stroke="#B97762" stroke-width="5"/>'''), "A person steps into a car through its open door."),
    "get on": (scene(BUS + f'<g transform="translate(37 56) scale(.85)">{WALKER}</g>' + '''<path d="M98 156c53-1 91-11 115-37m-20 1 20-1-10 18" stroke="#B97762" stroke-width="5"/>'''), "A person boards a bus through its door."),
    "get off": (scene(BUS + f'<g transform="translate(197 66) scale(.82)">{WALKER}</g>' + '''<path d="M216 150c-47 13-82 8-113-9m10 18-10-18 21 2" stroke="#B97762" stroke-width="5"/>'''), "A person steps down from a bus."),
    "get out": (scene(CAR + f'<g transform="translate(141 65) scale(.82)">{WALKER}</g>' + '''<path d="M177 66 144 45l-18 45 51 43Z" fill="#ECD9AF"/>
        <path d="M177 66v67M130 113l20 17"/>
        <path d="M138 148c-25 10-48 10-69 1m16 16-16-16 20-5" stroke="#B97762" stroke-width="5"/>'''), "A person gets out of a car through its open door."),
    "steal": (scene('''<path d="M64 112h217v12H64Zm20 12v35m178-35v35" fill="#B98A56"/>
        <path d="M208 77h53v39h-53Z" fill="#F7F2E6"/><path d="M217 77c0-21 35-21 35 0"/>
        <g transform="translate(65 29) scale(.9)">''' + REACHER + '''</g><g transform="translate(252 34) scale(.9)">''' + WALKER + '''</g>
        <path d="M129 87h27v19h-27Z" fill="#9B7050"/><path d="M160 103c13-4 24-5 36-4m-13-7 13 7-10 7" stroke="#B97762" stroke-width="4"/>'''), "A thief quietly takes a wallet while its owner looks away."),
    "rob": (scene('''<path d="M183 52 248 23l64 29v100H183Z" fill="#C99B58"/><path d="M197 60h101m-85 2v71m29-71v71m29-71v71m-88 0h129"/>
        <path d="M239 92h21v41h-21Z" fill="#584B3F"/><g transform="translate(71 47) scale(1.05)">''' + WALKER + '''</g>
        <path d="M119 95c-15-18-37-9-34 12 2 21 32 28 43 8Z" fill="#F7F2E6"/>
        <path d="M104 97c9 13 12 18 10 27"/><path d="m81 140-22 13m43-3-20 11" stroke="#B97762" stroke-width="4"/>'''), "A robber runs away from a bank carrying a bag of money."),
    "mug": (scene('''<path d="M43 153h263"/>
        <g transform="translate(60 46) scale(.98)">''' + REACHER + '''</g><g transform="translate(221 46) scale(.98)">''' + WALKER + '''</g>
        <path d="M170 98h36v34h-36Z" fill="#B98A56"/><path d="M177 98c0-18 22-18 22 0"/>
        <path d="M155 112c13 2 22 3 31 2m-14-10 14 10-13 9" stroke="#B97762" stroke-width="5"/>
        <path d="m253 45 6-13m-21 6-1-12" stroke="#D7B662" stroke-width="4"/>'''), "An attacker grabs a person's bag on the street."),
    "burgle": (scene('''<path d="M43 154V43l129-28 127 28v111Z" fill="#C99B58"/><path d="M35 44 172 12l137 32"/>
        <path d="M126 52h91v83h-91Z" fill="#F7F2E6"/><path d="M126 52v83m91-83v83M126 52h91"/>
        <g transform="translate(154 48) scale(.83)">''' + REACHER + '''</g>
        <path d="M234 94c16-13 32-4 29 12-2 18-27 27-40 12Z" fill="#F7F2E6"/>
        <path d="M92 137h40m-40 11h40" stroke="#6E8571" stroke-width="4"/>'''), "A burglar climbs through a house window carrying a sack."),
}
