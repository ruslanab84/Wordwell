#!/usr/bin/env python3
"""Build the hand-authored offline phrasal-verb catalog and its original line scenes."""

import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).with_name('entries.tsv')
DATA = Path(__file__).with_name('phrasal_verbs.json')
SWIFT = ROOT / 'Packages/WordwellKit/Sources/WordwellData/LocalPhrasalVerbCatalog.swift'
ASSETS = ROOT / 'Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/PhrasalVerbs.xcassets'


def P(d): return f'<path d="{d}"/>'
def C(x, y, r): return f'<circle cx="{x}" cy="{y}" r="{r}"/>'
def R(x, y, w, h, radius=0): return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}"/>'
def L(x1, y1, x2, y2): return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"/>'

HUMANS = {'person','child','teacher','doctor','patient','friend','people','crowd','team','runner','choir'}
ANIMALS = {'cat','dog','bird','insect'}
VEHICLES = {'car','bus','train','bike','boat','plane','rocket'}
BUILDINGS = {'house','hotel','school','library','shop','station','factory','cinema','theater','building','restaurant','farm','hall','city'}
PAPERS = {'book','paper','page','report','plan','recipe','form','register','list','contract','ticket','letter','envelope','photo','picture','map','word','letters','topics','film','bookmark','calendar','folder'}
ELECTRONICS = {'phone','computer','screen','printer','camera','speaker','microphone','fan','lamp','alarm','clock','power','plug','bulb','thermometer'}
FURNITURE = {'bed','chair','table','desk','shelf','cupboard','drawer','door','gate','fence','bridge','wall','podium','stall','tent','tower','road','path','edge'}
CONTAINERS = {'bag','box','bottle','jar','bin','suitcase','case','carton','pot','bowl','plate','cup','postbox'}
FOOD = {'bread','cheese','egg','chocolate','sugar','picnic','fuel','oven'}
NATURE = {'sun','moon','cloud','rain','wind','sea','island','valley','tree','flower','plant','water','fire','ground','insect'}
TOOLS = {'hand','eye','ear','magnifier','pencil','pen','brush','broom','spoon','fork','scissors','tool','key','lock','tap','rope','paint','flask','mirror'}
SYMBOLS = {'heart','question','check','chart','arrow','spark','wave','drop','coin','flag','star','medal','trophy','gift','ball','balloon','umbrella','scarf','shoe','boot','coat','costume','carpet','trap','barrier','mask','dots','number','sign','speech','music','party','glass','toy','piece','work','virus','candle'}
ALL = HUMANS | ANIMALS | VEHICLES | BUILDINGS | PAPERS | ELECTRONICS | FURNITURE | CONTAINERS | FOOD | NATURE | TOOLS | SYMBOLS


def icon(name):
    if name in HUMANS:
        body = C(31,14,7) + P('M31 21 V43 M19 30 Q31 22 43 30 M31 43 L20 58 M31 43 L43 58')
        if name == 'child': body = '<g transform="translate(8 13) scale(.75)">' + body + '</g>'
        if name == 'runner': body = C(31,14,7)+P('M31 21 L37 37 L47 44 M35 27 L19 31 M37 37 L23 48 M37 37 L49 55')
        if name in {'people','crowd','team','choir'}: body = '<g transform="translate(-7 9) scale(.74)">' + body + '</g><g transform="translate(18 6) scale(.74)">' + body + '</g>'
        if name == 'teacher': body += R(42,10,16,12,2)+L(45,17,55,17)
        if name == 'doctor': body += P('M51 12 V24 M45 18 H57')
        if name == 'patient': body += P('M23 12 H39 M31 7 V17')
        if name == 'friend': body += C(50,14,5)
        if name == 'choir': body += P('M4 4 Q8 0 12 4 M52 4 Q56 0 60 4')
        return body
    if name in ANIMALS:
        if name == 'bird': return P('M8 39 Q24 22 36 35 Q45 26 57 31 L44 38 Q35 53 20 47 Z M35 51 L30 58 M41 49 L43 57')+C(40,34,1.5)
        if name == 'insect': return C(31,32,9)+C(31,19,5)+P('M23 30 L11 23 M23 36 L11 43 M39 30 L52 23 M39 36 L52 43 M28 15 L23 8 M34 15 L39 8')
        return P('M10 42 Q16 27 33 31 L44 24 L53 33 L56 45 L48 46 L44 57 M21 45 L19 57 M42 45 L42 57 M11 42 L5 29')+C(47,36,1.5)+(P('M42 25 L42 15 L48 22 M51 27 L57 18') if name == 'cat' else P('M43 23 Q38 14 35 21 M52 26 Q59 19 59 28'))
    if name in VEHICLES:
        if name == 'bike': return C(15,47,10)+C(50,47,10)+P('M15 47 L28 28 L37 47 L15 47 M28 28 L50 47 M26 25 H36 M39 26 L45 24')
        if name == 'boat': return P('M7 42 H58 L50 54 H17 Z M31 8 V42 M31 10 L51 37 H31 Z M19 59 Q25 55 31 59 Q37 63 43 59')
        if name == 'plane': return P('M5 35 L56 29 L60 33 L42 40 L49 51 L43 53 L31 44 L17 49 L11 47 L22 39 Z')
        if name == 'rocket': return P('M32 7 Q48 19 43 44 L21 44 Q16 19 32 7 Z M21 37 L12 48 L22 46 M43 37 L52 48 L42 46 M27 47 L27 58 M37 47 L37 58')+C(32,29,6)
        if name == 'train': return R(7,14,50,37,7)+R(13,20,17,14,2)+R(35,20,16,14,2)+C(19,53,5)+C(46,53,5)+L(10,60,54,60)
        if name == 'bus': return R(5,16,54,35,6)+R(10,21,14,14,2)+R(28,21,14,14,2)+R(46,21,9,14,2)+C(18,53,5)+C(49,53,5)
        return P('M8 42 L15 27 H48 L57 42 V51 H8 Z M18 27 L23 17 H43 L48 27 M20 32 H45')+C(19,51,5)+C(47,51,5)
    if name in BUILDINGS:
        base = P('M7 29 L32 10 L57 29 V57 H7 Z') if name in {'house','farm'} else R(9,13,46,44,2)
        base += R(25,38,14,19,1)+R(15,22,8,9,1)+R(41,22,8,9,1)
        if name in {'hotel','hospital'}: base += P('M29 18 V31 M23 24 H35')
        if name in {'school','library'}: base += P('M17 49 H22 M42 49 H47')
        if name in {'factory'}: base += P('M13 13 V4 H20 V13 M34 13 V6 H41 V13')
        if name in {'shop','restaurant','cinema','theater'}: base += P('M9 18 H55 M12 20 L16 27 L21 20 L26 27 L31 20 L36 27 L41 20 L46 27 L51 20')
        if name == 'restaurant': base += P('M20 45 V54 M17 45 H23 M44 44 V54')
        if name in {'station','city'}: base += P('M4 58 H60 M11 9 H18 M46 9 H53')
        if name == 'hall': base += P('M3 58 H61')
        return base
    if name in PAPERS:
        if name == 'book': return P('M5 15 Q20 10 31 18 Q43 10 59 15 V52 Q43 48 31 56 Q19 48 5 52 Z M31 18 V56 M12 25 H25 M38 25 H52')
        if name == 'envelope': return R(6,17,52,34,2)+P('M7 20 L32 38 L57 20')
        if name in {'letter','paper','page','report','plan','recipe','form','register','list','contract','ticket','word','letters','topics','film'}:
            b = R(13,5,38,54,2)+L(19,19,45,19)+L(19,27,41,27)+L(19,35,44,35)
            if name == 'list': b += R(20,42,6,6,1)+L(31,45,43,45)
            if name == 'form': b += R(20,42,22,6,1)
            if name == 'register': b += P('M20 43 L26 49 L33 40 M36 45 H44')
            if name == 'report': b += P('M20 49 L28 41 L34 45 L44 38')
            if name == 'plan': b += P('M20 50 L26 43 L32 48 L43 40')
            if name == 'contract': b += P('M24 48 Q32 42 40 49')
            if name == 'ticket': b += P('M16 41 H47 M23 47 H41')
            if name == 'recipe': b += C(32,46,5)
            if name in {'word','letters'}: b += P('M21 12 H42')
            return b
        if name == 'bookmark': return P('M19 7 H45 V58 L32 48 L19 58 Z')
        if name == 'calendar': return R(7,13,50,45,2)+P('M7 25 H57 M18 7 V19 M46 7 V19 M17 36 H25 M31 36 H39 M17 46 H25 M31 46 H39')
        if name == 'folder': return P('M5 18 H26 L31 24 H59 V54 H5 Z M5 30 H59')
        if name in {'photo','picture'}: return R(5,8,54,48,2)+C(45,22,6)+P('M8 49 L24 31 L35 42 L42 36 L57 51')
        if name == 'map': return P('M6 14 L24 8 L42 14 L58 8 V50 L42 56 L24 50 L6 56 Z M24 8 V50 M42 14 V56 M13 33 L19 28 L33 35 L49 22')
    if name in ELECTRONICS:
        if name == 'phone': return R(18,4,28,56,5)+L(25,11,39,11)+C(32,52,2)
        if name in {'computer','screen','printer','camera'}:
            if name == 'camera': return R(7,20,50,32,5)+C(32,36,11)+P('M17 20 L21 13 H38 L43 20')
            b=R(7,9,50,38,3)+L(32,47,32,57)+L(17,58,47,58)
            if name == 'printer': b += R(14,18,36,12,1)+P('M19 30 V43 H45 V30')
            return b
        if name == 'speaker': return R(13,10,34,48,3)+C(30,40,10)+C(30,21,4)
        if name == 'bulb': return P('M20 40 Q9 23 23 12 Q32 3 41 12 Q55 23 44 40 L39 47 H25 Z M25 52 H39 M28 58 H36')
        if name == 'thermometer': return R(27,7,10,40,5)+C(32,50,10)+P('M32 19 V48')
        if name == 'microphone': return R(23,8,18,32,9)+P('M17 30 Q17 51 32 51 Q47 51 47 30 M32 51 V59 M22 59 H42')
        if name == 'fan': return C(32,29,5)+P('M32 24 Q18 11 31 7 Q46 7 37 27 M37 29 Q54 20 57 31 Q57 47 35 34 M31 34 Q30 51 18 47 Q7 40 27 29 M32 35 V56 M23 57 H41')
        if name in {'lamp','alarm','clock'}:
            if name == 'lamp': return P('M18 29 L28 8 H42 L51 29 Z M35 29 V53 M20 56 H50')
            return C(32,32,22)+L(32,32,32,18)+L(32,32,43,38)+(P('M15 8 L7 16 M49 8 L57 16') if name == 'alarm' else '')
        if name == 'plug': return P('M20 13 V27 M40 13 V27 M15 27 H45 V38 Q45 49 32 49 V58 M32 49 Q19 49 19 38 V27')
        if name == 'power': return C(32,34,22)+P('M32 7 V34 M20 20 Q9 31 19 45 Q32 58 45 45 Q55 31 44 20')
    if name in FURNITURE:
        if name == 'bed': return P('M7 45 V57 M7 45 H58 V57 M7 33 H58 V45 M10 34 V24 H26 V34 M28 34 Q45 22 57 34')
        if name == 'chair': return P('M19 8 V39 H50 V14 M19 39 H50 M22 40 V58 M47 40 V58')
        if name == 'table': return P('M7 32 H57 V38 H7 Z M15 38 V58 M49 38 V58')
        if name == 'desk': return P('M5 28 H59 V35 H5 Z M13 35 V58 M51 35 V58 M22 18 H42 V28')
        if name == 'shelf': return P('M9 9 V58 M55 9 V58 M9 25 H55 M9 45 H55 M18 11 V23 M25 13 V23 M36 30 V43 M44 28 V43')
        if name in {'cupboard','drawer'}: return R(10,8,44,50,2)+L(10,33,54,33)+C(29,22,1.5)+C(35,43,1.5)
        if name in {'door','gate'}: return R(15,5,34,54,2)+C(41,34,2)+(P('M6 57 H58') if name == 'door' else P('M20 12 L44 53 M44 12 L20 53'))
        if name == 'fence': return P('M6 14 V58 M19 14 V58 M32 14 V58 M45 14 V58 M58 14 V58 M5 27 H59 M5 44 H59')
        if name == 'bridge': return P('M4 43 Q32 9 60 43 M4 43 V56 H60 V43 M14 35 V55 M32 27 V55 M50 35 V55')
        if name == 'wall': return R(4,14,56,42)+P('M4 28 H60 M4 42 H60 M20 14 V28 M43 14 V28 M31 28 V42 M20 42 V56 M45 42 V56')
        if name == 'podium': return P('M14 58 H50 V34 H42 V22 H22 V34 H14 Z')
        if name == 'stall': return P('M8 20 H56 L51 35 H13 Z M14 35 V57 M50 35 V57 M15 43 H49 M21 20 V13 H43 V20')
        if name == 'tent': return P('M5 55 L31 9 L59 55 Z M31 9 V55 M20 55 L31 33 L43 55')
        if name == 'tower': return P('M18 55 L23 13 H41 L46 55 Z M15 55 H49 M26 13 V6 H38 V13 M24 29 H40')
        if name in {'road','path'}: return P('M6 58 Q17 36 12 7 M58 58 Q47 36 52 7 M32 54 V47 M32 37 V30 M32 20 V13')+(P('M2 58 H62') if name == 'road' else '')
        if name == 'edge': return P('M5 48 H40 V18 H58 M40 48 V59')
    if name in CONTAINERS:
        if name in {'bag','suitcase','case'}: return R(9,22,46,35,4)+P('M23 22 V15 Q23 8 32 8 Q41 8 41 15 V22')+(P('M32 23 V56') if name == 'suitcase' else '')
        if name == 'box': return P('M8 21 L32 12 L56 21 V51 L32 60 L8 51 Z M8 21 L32 31 L56 21 M32 31 V60')
        if name in {'bottle','carton'}: return P('M23 9 H41 V18 L46 25 V55 Q46 59 42 59 H22 Q18 59 18 55 V25 L23 18 Z M23 9 V5 H41 V9')
        if name == 'jar': return R(16,16,32,42,7)+R(14,9,36,8,2)
        if name in {'bin','postbox'}: return P('M16 18 H48 L45 57 H19 Z M11 17 H53 M25 8 H39 M27 29 V49 M37 29 V49')
        if name == 'pot': return P('M12 28 H52 L47 56 H17 Z M18 22 H46 M9 32 H12 M52 32 H55')
        if name in {'bowl','plate','cup'}:
            if name == 'cup': return P('M13 22 H44 V49 Q29 57 13 49 Z M44 27 Q60 23 56 38 Q54 44 44 43 M9 56 H49')
            if name == 'plate': return C(32,33,25)+C(32,33,16)
            return P('M7 31 H57 Q55 55 32 56 Q9 55 7 31 Z M6 31 H58')
    if name in FOOD:
        if name == 'egg': return P('M32 7 C47 7 53 44 43 55 C33 64 16 57 14 42 C12 27 21 7 32 7 Z')
        if name == 'cheese': return P('M7 31 L48 12 L58 48 L17 58 Z M7 31 L17 58 M22 37 H25 M39 42 H42')+C(35,30,4)
        if name == 'bread': return P('M10 53 V25 Q10 11 22 12 Q31 5 40 12 Q55 9 55 25 V53 Z M16 35 H50')
        if name == 'chocolate': return R(9,10,46,45,2)+P('M24 10 V55 M39 10 V55 M9 25 H55 M9 40 H55')
        if name == 'sugar': return P('M13 38 L32 28 L51 38 L32 49 Z M13 38 V51 L32 61 L51 51 V38 M32 49 V61')
        if name == 'fuel': return R(14,10,30,48,3)+R(19,17,20,15,1)+P('M44 23 Q57 27 54 43 L50 46 M26 46 H34')
        if name == 'oven': return R(7,8,50,51,2)+R(13,24,38,28,2)+P('M13 18 H51')+C(18,15,2)+C(29,15,2)
        return P('M7 54 H57 M13 49 Q16 22 32 21 Q48 22 51 49 Z')
    if name in NATURE:
        if name == 'sun': return C(32,32,14)+''.join(L(32+int(24*__import__('math').cos(a)),32+int(24*__import__('math').sin(a)),32+int(29*__import__('math').cos(a)),32+int(29*__import__('math').sin(a))) for a in [i*__import__('math').pi/4 for i in range(8)])
        if name == 'moon': return P('M43 8 Q20 15 22 39 Q25 54 49 52 Q34 63 19 52 Q4 40 12 22 Q21 5 43 8 Z')
        if name in {'cloud','rain','wind'}:
            b=P('M12 44 Q2 34 14 27 Q17 14 31 19 Q43 8 51 25 Q63 27 58 41 Q55 47 48 47 H18 Q13 47 12 44 Z')
            if name == 'rain': b += P('M17 53 L14 60 M31 53 L28 60 M45 53 L42 60')
            if name == 'wind': b += P('M7 54 H44 Q55 54 55 49 M10 60 H38')
            return b
        if name in {'sea','water','valley','island','ground'}:
            b=P('M4 42 Q10 37 16 42 Q22 47 28 42 Q34 37 40 42 Q46 47 52 42 Q58 37 61 42 M4 53 Q10 48 16 53 Q22 58 28 53 Q34 48 40 53 Q46 58 52 53 Q58 48 61 53')
            if name in {'island','valley'}: b+=P('M13 36 Q32 8 51 36')
            if name == 'ground': b=L(6,28,58,28)
            return b
        if name in {'tree','plant','flower'}:
            if name == 'flower': return C(32,25,5)+''.join(C(x,y,7) for x,y in [(32,13),(44,25),(32,37),(20,25)])+P('M32 41 V60 M32 51 Q20 42 16 48 M32 53 Q45 43 50 49')
            if name == 'plant': return P('M19 44 H45 L41 59 H23 Z M32 44 V13 M32 28 Q19 15 15 24 Q17 35 32 35 M32 25 Q45 12 50 23 Q48 36 32 36')
            return P('M29 39 V58 H37 V39 M32 39 Q7 42 13 25 Q6 9 23 13 Q31 1 39 13 Q57 8 55 25 Q60 42 32 39 Z')
        if name == 'fire': return P('M32 5 Q45 23 39 33 Q50 27 48 44 Q45 58 32 59 Q17 59 15 44 Q15 32 26 24 Q23 39 32 39 Q37 27 32 5 Z')
    if name in TOOLS:
        if name == 'hand': return P('M19 57 Q9 48 11 38 Q13 31 19 37 L21 43 V12 Q21 6 26 7 Q30 7 30 13 V33 V9 Q31 4 35 6 Q39 7 39 11 V34 V16 Q40 11 44 12 Q48 13 48 18 V37 Q50 31 54 33 Q60 35 56 43 L46 58 Z')
        if name == 'eye': return P('M5 32 Q32 4 59 32 Q32 60 5 32 Z')+C(32,32,10)+C(32,32,3)
        if name == 'ear': return P('M21 43 Q9 19 29 9 Q50 5 54 26 Q56 39 41 43 Q33 47 35 57 Q21 63 20 50 M28 36 Q19 22 30 18 Q43 16 44 27 Q45 34 34 37')
        if name == 'magnifier': return C(27,26,17)+P('M39 39 L57 57')
        if name == 'mirror': return R(13,7,38,45,4)+P('M21 14 Q35 8 43 20 M32 52 V59 M22 59 H42')
        if name in {'pencil','pen','brush','broom','spoon','fork','scissors','tool','key','lock','tap','rope','paint','flask'}:
            if name == 'key': return C(23,25,12)+P('M32 34 L55 57 M45 47 L51 41 M51 53 L57 47')
            if name == 'lock': return R(13,28,38,29,3)+P('M20 28 V19 Q20 7 32 7 Q44 7 44 19 V28')+C(32,42,3)
            if name == 'scissors': return C(14,47,8)+C(32,51,8)+P('M20 43 L55 10 M37 45 L11 10')
            if name == 'tap': return P('M10 35 H48 V45 H42 V38 H18 V51 H10 Z M32 35 V20 H50 M43 16 H57 M50 10 V22')
            if name == 'rope': return P('M6 40 Q17 15 31 39 Q47 63 58 30 M7 40 Q12 50 17 42')
            if name == 'flask': return P('M25 7 H39 M28 7 V29 L13 53 Q12 58 18 58 H46 Q52 58 51 53 L36 29 V7 M20 44 H44')
            if name in {'pen','pencil','brush','broom'}: return P('M12 53 L45 10 L54 19 L22 59 Z M45 10 L54 19 M22 59 L12 53')+(P('M10 58 Q5 48 12 45') if name in {'brush','broom'} else '')
            if name == 'spoon': return P('M30 35 V59 M30 35 Q17 32 17 18 Q17 8 30 8 Q43 8 43 18 Q43 32 30 35 Z')
            if name == 'fork': return P('M18 8 V28 Q18 38 31 38 Q44 38 44 28 V8 M27 8 V35 M35 8 V35 M31 38 V59')
            if name == 'tool': return P('M18 9 Q25 8 27 17 L22 23 L30 31 L38 23 L33 15 Q43 7 50 15 Q56 24 47 31 L27 55 Q18 63 10 53 Q4 46 13 37 L30 31')
            return R(10,15,44,38,3)+P('M16 44 Q32 34 48 44')
    if name in SYMBOLS:
        if name == 'heart': return P('M32 55 L8 32 Q1 18 14 12 Q24 8 32 21 Q40 8 50 12 Q63 18 56 32 Z')
        if name == 'question': return P('M20 21 Q20 8 33 8 Q48 8 47 22 Q46 31 33 36 V42')+C(33,55,2)
        if name == 'check': return P('M10 33 L25 48 L54 17')
        if name == 'chart': return P('M9 8 V55 H58 M13 46 L26 36 L37 41 L53 17')
        if name == 'arrow': return P('M7 32 H56 M44 20 L56 32 L44 44')
        if name in {'spark','star'}: return P('M32 5 L38 25 L58 32 L38 38 L32 58 L25 38 L5 32 L25 25 Z')
        if name == 'wave': return P('M5 30 Q12 16 19 30 Q26 44 33 30 Q40 16 47 30 Q54 44 60 30 M5 44 Q12 30 19 44 Q26 58 33 44 Q40 30 47 44 Q54 58 60 44')
        if name == 'drop': return P('M32 7 Q17 30 17 42 Q17 57 32 57 Q47 57 47 42 Q47 30 32 7 Z')
        if name == 'coin': return C(32,32,23)+C(32,32,16)+P('M36 18 Q22 15 22 26 Q22 31 33 32 Q44 34 42 41 Q40 50 27 46 M32 14 V51')
        if name == 'flag': return P('M14 6 V58 M14 10 Q26 4 36 11 Q48 17 54 10 V38 Q43 45 33 38 Q23 33 14 39')
        if name in {'medal','trophy'}: return P('M16 10 H48 V32 Q48 46 32 48 Q16 46 16 32 Z M16 16 H7 V29 Q7 37 18 36 M48 16 H57 V29 Q57 37 46 36 M32 48 V56 M22 57 H42')
        if name == 'gift': return R(9,25,46,32,2)+R(6,20,52,8,2)+P('M32 20 V57 M32 20 Q8 16 18 9 Q27 4 32 20 Q37 4 46 9 Q56 16 32 20')
        if name in {'ball','balloon'}: return C(32,29,21)+(P('M32 50 Q36 58 30 61') if name == 'balloon' else P('M18 14 Q36 28 51 42 M15 43 Q30 32 44 11'))
        if name == 'umbrella': return P('M5 31 Q32 2 59 31 H5 Z M32 30 V51 Q32 61 22 56')
        if name == 'boot': return P('M16 8 H34 V35 Q41 41 55 42 V54 H10 V46 L16 37 Z M12 54 H56 M23 14 H30')
        if name == 'coat': return P('M20 9 L31 15 L43 9 L56 28 L49 34 L46 56 H17 L14 34 L8 28 Z M31 15 V56 M22 23 L31 28 L40 23')
        if name in {'scarf','shoe','costume','carpet'}: return P('M10 42 Q18 39 25 43 L38 24 Q43 20 49 25 L58 48 H10 Z M10 48 H58 M28 40 L35 32')
        if name in {'trap','barrier'}: return P('M8 14 H56 V55 H8 Z M13 50 L51 19 M13 19 L51 50')
        if name == 'mask': return P('M8 18 Q32 9 56 18 L51 43 Q32 58 13 43 Z M16 29 Q22 23 28 30 M36 30 Q42 23 48 29 M24 42 Q32 47 40 42')
        if name in {'dots','number'}: return C(14,32,3)+C(27,32,3)+C(40,32,3)+C(53,32,3)
        if name == 'sign': return R(9,13,46,32,2)+P('M32 45 V59 M20 59 H44 M16 26 H48')
        if name == 'speech': return P('M6 11 H58 V44 H33 L17 56 V44 H6 Z M16 22 H48 M16 31 H41')
        if name == 'music': return P('M21 45 V14 L48 8 V42 M21 14 L48 8 M21 45 Q17 55 10 49 Q5 43 21 42 M48 42 Q44 52 37 46 Q32 40 48 39')
        if name == 'party': return P('M13 56 L32 8 L52 56 Z M8 17 L13 11 M49 10 L55 16 M51 25 L59 25')
        if name == 'glass': return P('M12 9 L52 9 L46 44 Q32 58 18 44 Z M32 48 V58 M18 59 H46')
        if name == 'candle': return P('M24 24 H40 V57 H24 Z M32 21 Q23 14 32 5 Q41 14 32 21 Z')
        if name == 'toy': return R(12,20,40,34,4)+C(23,17,6)+C(42,17,6)+C(24,35,2)+C(40,35,2)+P('M24 45 Q32 52 40 45')
        if name == 'piece': return P('M11 12 H30 Q30 24 38 22 Q44 20 42 12 H54 V31 Q43 30 43 38 Q43 46 54 45 V56 H11 Z')
        if name == 'work': return R(10,19,44,35,3)+P('M23 19 V11 H41 V19 M10 35 H54 M31 32 V38')
        if name == 'virus': return C(32,32,14)+''.join(L(x1,y1,x2,y2) for x1,y1,x2,y2 in [(32,7,32,18),(32,46,32,57),(7,32,18,32),(46,32,57,32),(14,14,22,22),(42,42,50,50),(14,50,22,42),(42,22,50,14)])
    raise ValueError(f'No drawing for {name}')


def relation(name):
    middle = {
        'toward': P('M73 48 H91 M84 41 L91 48 L84 55'),
        'away': P('M91 48 H73 M80 41 L73 48 L80 55'),
        'up': P('M82 59 V35 M75 42 L82 35 L89 42'),
        'down': P('M82 35 V59 M75 52 L82 59 L89 52'),
        'over': P('M70 35 Q82 19 94 35 M88 29 L94 35 L86 39'),
        'through': P('M70 48 H94 M88 42 L94 48 L88 54'),
        'connect': P('M72 43 L78 50 L84 43 L90 50'),
        'burst': P('M82 36 V26 M82 59 V69 M69 48 H61 M95 48 H103 M72 38 L66 32 M92 38 L98 32'),
        'cross': P('M73 39 L91 57 M91 39 L73 57'),
        'check': P('M72 48 L79 55 L93 39'),
        'barrier': P('M82 29 V68 M75 34 H89 M75 62 H89'),
        'repeat': P('M70 48 Q70 30 84 32 Q96 33 96 47 M89 40 L96 47 L101 39 M95 51 Q92 64 78 63'),
        'help': P('M72 52 Q82 34 92 52 M77 48 L82 42 L87 48'),
        'inside': P('M73 38 H91 V58 H73 Z M77 48 H87 M83 44 L87 48 L83 52'),
        'follow': P('M70 47 H88 M82 41 L88 47 L82 53 M70 57 H82'),
        'around': P('M73 56 Q65 42 79 35 Q94 29 97 44 M91 39 L97 44 L102 38'),
        'split': P('M72 47 H80 L91 36 M80 47 L91 58'),
        'wait': C(82,48,14)+L(82,48,82,39)+L(82,48,89,51),
        'return': P('M72 40 H93 V55 H72 M78 49 L72 55 L78 61'),
        'forward': P('M70 48 H95 M85 38 L95 48 L85 58'),
        'change': P('M70 55 L82 42 L94 55 M82 42 V35'),
        'close': P('M73 38 L82 48 L91 38 M73 58 L82 48 L91 58'),
        'side': P('M77 39 V57 M87 39 V57 M72 48 H92'),
        'back': P('M94 48 H70 M79 40 L70 48 L79 56'),
        'mirror': P('M82 30 V65 M75 39 L68 48 L75 57 M89 39 L96 48 L89 57'),
        'speak': P('M70 40 Q82 31 94 40 V54 Q82 63 70 54 Z'),
        'open': P('M75 36 L68 48 L75 60 M89 36 L96 48 L89 60'),
        'fade': P('M71 36 L78 43 M82 48 L87 53 M91 57 L96 62'),
    }
    if name not in middle: raise ValueError(f'No relation {name}')
    return middle[name]


def main():
    rows = [line.split('|') for line in SOURCE.read_text().splitlines() if line.strip()]
    assert len(rows) == 300 and all(len(row) == 6 for row in rows)
    ASSETS.mkdir(parents=True, exist_ok=True)
    DATA.parent.mkdir(parents=True, exist_ok=True)
    expected_names = {'pv_' + re.sub(r'[^a-z0-9]+', '_', row[0].lower()).strip('_') + '_line' for row in rows}
    for folder in ASSETS.glob('pv_*.imageset'):
        if folder.stem not in expected_names:
            shutil.rmtree(folder)
    entries = []
    for phrase, meaning, example, level, scene, alt in rows:
        slug = re.sub(r'[^a-z0-9]+', '-', phrase.lower()).strip('-')
        left, right, action = scene.split(',')
        assert left in ALL and right in ALL
        name = 'pv_' + slug.replace('-', '_') + '_line'
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="160" height="96" viewBox="0 0 160 96" '
               f'fill="none" stroke="#3A362E" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">'
               f'<g transform="translate(8 16) scale(.9)">{icon(left)}</g>'
               f'{relation(action)}'
               f'<g transform="translate(94 16) scale(.9)">{icon(right)}</g></svg>')
        folder = ASSETS / f'{name}.imageset'
        folder.mkdir(exist_ok=True)
        (folder / f'{name}.svg').write_text(svg + '\n')
        (folder / 'Contents.json').write_text(json.dumps({'images':[{'filename':f'{name}.svg','idiom':'universal'}], 'info':{'author':'xcode','version':1},'properties':{'preserves-vector-representation':True}}, indent=2)+'\n')
        entries.append({'id':slug,'phrase':phrase,'meaning':meaning,'example':example,'level':level,'imageAsset':name,'imageAlt':alt})
    assert len({e['id'] for e in entries}) == 300
    entries.sort(key=lambda entry: {'A1–A2': 0, 'B1–B2': 1, 'C1': 2}[entry['level']])
    DATA.write_text(json.dumps(entries, indent=2, ensure_ascii=False)+'\n')
    fields = ('id', 'phrase', 'meaning', 'example', 'level', 'imageAsset', 'imageAlt')
    lines = [
        '// Generated by Tools/PhrasalVerbs/build_gallery.py. Edit entries.tsv instead.',
        '',
        'public struct PhrasalVerbEntry: Codable, Identifiable, Sendable {',
        *[f'    public let {field}: String' for field in fields],
        '    public var baseVerb: String { phrase.split(separator: " ", maxSplits: 1).first.map(String.init) ?? phrase }',
        '}',
        '',
        'public enum LocalPhrasalVerbCatalog {',
        '    public static let all: [PhrasalVerbEntry] = [',
    ]
    for entry in entries:
        args = ', '.join(f'{field}: {json.dumps(entry[field], ensure_ascii=False)}' for field in fields)
        lines.append(f'        .init({args}),')
    lines += ['    ]', '}', '']
    SWIFT.write_text('\n'.join(lines))
    print(f'Built {len(entries)} original phrasal verb scenes')


if __name__ == '__main__': main()
