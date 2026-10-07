#!/usr/bin/env python3
"""Build the bundled "Top 3000" word list: wordfreq frequency order mapped onto Open English Wordnet entries.

Requires `pip install wordfreq`. Frequency data: wordfreq (CC BY-SA 4.0); entry ids: OEWN (CC BY 4.0).
Output is a JSON array of entry ids ("oewn:<lemma>:<pos>") in frequency order, one entry per lemma.
"""

import argparse
import json
import re
import zipfile
from pathlib import Path

from wordfreq import top_n_list, word_frequency

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
    """lemma -> (best part-of-speech key, sense count); inflected form -> lemma."""
    lemmas, forms = {}, {}
    with zipfile.ZipFile(source) as archive:
        for name in sorted(n for n in archive.namelist() if n.startswith("entries-") and n.endswith(".json")):
            for lemma, variants in json.loads(archive.read(name)).items():
                if not WORD.match(lemma):
                    continue
                best = max(variants.items(), key=lambda item: len(item[1]["sense"]))
                lemmas[lemma] = (best[0], len(best[1]["sense"]))
                for record in variants.values():
                    for form in record.get("form", []):
                        if WORD.match(form):
                            forms.setdefault(form, lemma)
    return lemmas, forms


def regular_base(token: str, lemmas) -> str | None:
    """OEWN lists only irregular forms, so strip regular -s/-es/-ies endings."""
    for suffix, repl in (("ies", "y"), ("es", ""), ("s", "")):
        if token.endswith(suffix) and len(token) > len(suffix) + 2 and token[: -len(suffix)] + repl in lemmas:
            return token[: -len(suffix)] + repl
    return None


def build(source: Path, destination: Path, count: int) -> None:
    lemmas, forms = load_lemmas(source)
    chosen, seen = [], set()
    for token in top_n_list("en", 30_000):
        if not WORD.match(token) or len(token) < 2 or token in FUNCTION_WORDS:
            continue
        # An inflection of a more frequent lemma ("rings" -> "ring") counts toward that lemma.
        regular = regular_base(token, lemmas)
        base = forms.get(token) or regular
        if base and base != token and base in lemmas and (
                base == regular or word_frequency(base, "en") >= word_frequency(token, "en")):
            lemma = base
        else:
            lemma = token if token in lemmas else base
        if lemma is None or lemma in seen:
            continue
        seen.add(lemma)
        chosen.append(f"oewn:{lemma}:{lemmas[lemma][0]}")
        if len(chosen) == count:
            break
    if len(chosen) < count:
        raise SystemExit(f"Only {len(chosen)} words available")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(chosen, separators=(",", ":")) + "\n")
    print(f"Wrote {len(chosen)} ids to {destination}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Official english-wordnet-2025-json.zip")
    parser.add_argument("destination", type=Path, help="Output JSON")
    parser.add_argument("--count", type=int, default=3000)
    args = parser.parse_args()
    build(args.source, args.destination, args.count)
