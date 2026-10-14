#!/usr/bin/env python3
"""Build the bundled "Top 3000" word list from the Open English Wordnet 2025 XML (CC BY 4.0).

OEWN carries no frequency data, so rank is polysemy: lemmas ordered by total sense count across parts of speech
(frequent words are the most polysemous). Only single lowercase words present in Dictionary.sqlite are kept.
Output is a JSON array of entry ids ("oewn:<lemma>:<pos>"), one entry per lemma, most polysemous first.
"""

import argparse
import json
import re
import sqlite3
import xml.etree.ElementTree as ET
from pathlib import Path


WORD = re.compile(r"^[a-z]+$")

# Closed-class words: OEWN has no useful entries for them (e.g. "he" is helium, "are" is a unit of area).
FUNCTION_WORDS = set("""a an the i me my mine myself you your yours yourself he him his himself she her hers herself it its
itself we us our ours ourselves they them their theirs themselves this that these those who whom whose which what whatever
be am is are was were been being have has had having do does did done doing will would shall should can could may might must
ought and or but nor so yet for of in on at by to from with without about above across after against along among around
as before behind below beneath beside between beyond down during except inside into like near off onto out outside over past
since than through throughout till toward under until up upon within not no yes if then there here when where while because
although though unless whether either neither both each every all any some such own same other another more most much many
few less least very too also just only even ever never again once already still""".split())


def load_lemmas(source: Path):
    """lemma -> (total sense count, best part-of-speech key)."""
    totals, best = {}, {}
    for _, entry in ET.iterparse(source):
        if entry.tag != "LexicalEntry":
            continue
        lemma = entry.find("Lemma")
        word, pos = lemma.get("writtenForm"), lemma.get("partOfSpeech")
        if WORD.match(word) and len(word) > 1 and word not in FUNCTION_WORDS:
            count = len(entry.findall("Sense"))
            totals[word] = totals.get(word, 0) + count
            if count > best.get(word, (0, ""))[0]:
                best[word] = (count, pos)
        entry.clear()
    return totals, best


def build(source: Path, database: Path, destination: Path, count: int) -> None:
    totals, best = load_lemmas(source)
    known = {row[0] for row in sqlite3.connect(database).execute("select id from entries")}
    ranked = sorted(totals, key=lambda w: (-totals[w], w))
    chosen = [f"oewn:{w}:{best[w][1]}" for w in ranked if f"oewn:{w}:{best[w][1]}" in known][:count]
    if len(chosen) < count:
        raise SystemExit(f"Only {len(chosen)} words available")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(chosen, separators=(",", ":")) + "\n")
    print(f"Wrote {len(chosen)} ids to {destination}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="english-wordnet-2025.xml")
    parser.add_argument("database", type=Path, help="Dictionary.sqlite (ids must resolve)")
    parser.add_argument("destination", type=Path, help="Output JSON")
    parser.add_argument("--count", type=int, default=3000)
    args = parser.parse_args()
    build(args.source, args.database, args.destination, args.count)
