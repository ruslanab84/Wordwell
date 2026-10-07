#!/usr/bin/env python3
"""Group the bundled Top 3000 list by topic.

Reads CommonWords3000.json (ids "oewn:<lemma>:<pos>") and writes CommonWordTopics.json:
a {entry id: topic id} map. A word goes to the first topic whose lexicon contains its lemma;
other words fall back to the WordNet category of their first sense (see LEXFILE_TOPIC). Topic titles/symbols live in CommonWordTopic.swift.

Usage: build_common_topics.py <CommonWords3000.json> <CommonWordTopics.json> <Dictionary.sqlite>
"""

import json
import sqlite3
import sys
from collections import Counter

# Order matters: the first matching topic wins.
LEXICON = {
    "family": """family mother father mom dad parent child kid baby son daughter brother sister husband wife grandmother
        grandfather uncle aunt cousin marriage married wedding couple relative boyfriend girlfriend partner birth born
        teenager youth adult""",
    "body": """body head face eye ear nose mouth lip tooth hair neck shoulder arm hand finger leg foot knee skin bone heart
        brain blood back chest stomach breath muscle voice thumb toe heel hip waist""",
    "health": """health doctor hospital disease cancer pain sick medicine medical drug patient nurse cure treatment injury
        illness fever cough clinic surgery therapy diet pill symptom virus fitness hurt recovery healthy""",
    "food": """food eat drink coffee tea water milk bread meat fish chicken egg rice fruit apple orange vegetable sugar salt
        butter cheese cake pizza soup salad dinner lunch breakfast meal kitchen cook restaurant menu beer wine juice dish
        cup bottle bean potato tomato sweet taste hungry bar snack sauce oil""",
    "clothes": """clothes dress shirt shoe hat coat jacket pants suit jean sock skirt uniform wear fashion bag glove ring
        belt boot scarf pocket""",
    "home": """home house room bed door window floor wall roof kitchen table chair garden furniture apartment key lock
        bathroom bedroom lamp mirror sofa carpet shelf box clean wash""",
    "animals": """animal dog cat bird horse cow pig sheep fish bear wolf lion tiger monkey snake rat mouse insect bee bug
        duck chicken rabbit deer fox elephant tail wing pet""",
    "nature": """nature earth sea ocean river lake mountain forest tree flower plant grass rock stone sand island beach
        field land hill valley sky sun moon star planet fire ice snow rain wind environment coast wood leaf seed""",
    "weather": """weather rain snow wind storm cloud sunny hot cold warm cool season winter summer spring fall temperature
        heat climate""",
    "travel": """travel trip tour visit hotel flight airport passport ticket tourist journey abroad map luggage vacation
        holiday passenger""",
    "transport": """car bus train plane ship boat bike bicycle truck taxi road street traffic drive driver ride station
        track fly railway highway engine wheel pilot""",
    "places": """city town country village area place region center centre park street square building office store
        shop market bank church school hall library museum theater airport capital state county district""",
    "education": """school university college student teacher professor class lesson study learn education course exam test
        subject science math history knowledge degree research grade library book read write essay homework language
        training academic""",
    "work": """work job business company office manager boss worker employee staff career salary meeting project team
        industry factory service customer client contract profession professional management director executive
        secretary hire resume application agency""",
    "money": """money pay cost price buy sell sale cash credit bank tax income account bill budget profit loss rich poor
        trade market economy economic financial insurance value earn spend save debt fee rate stock""",
    "technology": """technology computer internet website online software data code phone mobile network digital video
        screen email device machine system electronic app program web google database server file""",
    "media": """media news newspaper magazine film movie television tv radio channel show episode series video photo
        camera picture image article story report press interview broadcast""",
    "arts": """art music song band album dance paint painting artist theater concert piano guitar poem poetry novel
        author writer design culture style singer performance actor""",
    "sports": """sport game team player football basketball tennis golf coach match race win lose beat score goal league
        champion club fan swim run training stadium athlete""",
    "law": """law legal court judge crime police prison guilty murder trial justice lawyer rule rights illegal arrest
        evidence prove steal kill gun weapon security violence""",
    "government": """government president minister congress election vote political party policy council federal public
        nation national state citizen leader democracy campaign senator mayor union""",
    "war": """war army military soldier battle attack defense force fight enemy weapon navy victory peace officer captain
        troop""",
    "religion": """god church holy religion christian prayer pray soul spirit heaven hell faith bible lord""",
    "emotions": """love hate happy sad angry fear hope feel feeling joy sorry glad worry afraid proud lonely upset
        surprise excited crazy enjoy care miss like laugh smile cry""",
    "communication": """say tell talk speak ask answer call word message letter write read language listen hear conversation
        discuss explain mention comment statement voice speech question reply""",
    "time": """time day week month year hour minute second morning evening night today tomorrow yesterday tonight weekend
        daily century decade moment date calendar early late soon later ago always never often usually already""",
    "numbers": """one two three four five six seven eight nine ten hundred thousand million half double single number
        percent first second third zero count dozen pair""",
    "feelings": """sad angry afraid scared nervous tired lonely upset surprised excited confident proud ashamed jealous
        bored worried anxious calm relaxed grateful pleased disappointed annoyed annoying confused curious desperate
        embarrassed furious glad sorry sure impressed shocked cheerful hopeful comfortable awkward anxious""",
    "evaluation": """good bad great fine nice perfect terrible awful awesome excellent wonderful amazing fantastic horrible
        brilliant lovely super decent poor cheap expensive valuable useful useless helpful successful effective
        important serious significant essential necessary ideal suitable proper right wrong true false fair
        positive negative incredible outstanding extraordinary fabulous worthy""",
    "size": """big small little large huge tiny long short tall wide narrow thin thick deep flat high low heavy light
        massive vast giant enormous broad round straight tight loose fat mini slim steep tall greater larger smaller
        bigger smaller higher lower longer shorter""",
    "appearance": """beautiful pretty ugly cute handsome gorgeous attractive sexy clean dirty bright dark fresh soft hard
        smooth rough sharp wet dry hot cold warm cool naked plain golden wooden plastic loud quiet silent
        delicious sweet sour""",
    "character": """kind honest brave smart wise stupid dumb clever silly crazy mad weird strange funny friendly polite
        rude lucky careful creative lazy generous patient gentle cruel evil innocent guilty strong weak powerful
        famous rich poor busy shy confident romantic nervous mean selfish""",
    "colors": """color red blue green yellow black white brown gray grey pink purple orange gold silver dark light""",
}


# Fallback for words outside the curated lexicons: WordNet lexicographer file of the first sense
# (the number in sense ids such as "mother%1:18:00::"), plus the part of speech for adjectives/adverbs.
LEXFILE_TOPIC = {
    4: "actions", 5: "animals", 6: "objects", 7: "qualities", 8: "body", 9: "ideas", 10: "communication",
    11: "actions", 12: "emotions", 13: "food", 14: "groups", 15: "places", 16: "ideas", 17: "nature",
    18: "people", 19: "nature", 20: "nature", 21: "money", 22: "actions", 23: "numbers", 24: "ideas",
    25: "qualities", 26: "qualities", 27: "objects", 28: "time",
    29: "body", 30: "actions", 31: "ideas", 32: "communication", 33: "sports", 34: "food", 35: "actions",
    36: "actions", 37: "emotions", 38: "movement", 39: "ideas", 40: "money", 41: "actions", 42: "actions",
    43: "weather",
}
POS_TOPIC = {"a": "describing", "s": "describing", "r": "adverbs"}


def fallback(entry: str, sense_id: str | None) -> str:
    pos = entry.split(":")[2].split("-")[0]
    if pos in ("a", "s") and entry.split(":")[1].endswith(("ed", "ing", "en")):
        return "participles"
    if pos in POS_TOPIC:
        return POS_TOPIC[pos]
    try:
        return LEXFILE_TOPIC.get(int(sense_id.split("%")[1].split(":")[1]), "general")
    except (AttributeError, IndexError, ValueError):
        return "general"


def main(source: str, destination: str, database: str) -> None:
    ids = json.load(open(source))
    senses = dict(sqlite3.connect(database).execute("select id, json_extract(payload, '$.senses[0].id') from entries"))
    lookup = {}
    for topic, text in LEXICON.items():
        for lemma in text.split():
            lookup.setdefault(lemma, topic)
    mapping = {entry: lookup.get(entry.split(":")[1]) or fallback(entry, senses.get(entry)) for entry in ids}
    with open(destination, "w") as out:
        json.dump(mapping, out, separators=(",", ":"))
        out.write("\n")
    for topic, count in Counter(mapping.values()).most_common():
        print(f"{topic:15} {count}")


if __name__ == "__main__":
    main(*sys.argv[1:4])
