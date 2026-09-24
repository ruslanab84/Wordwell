#!/usr/bin/env python3
"""Build the bundled, read-only dictionary from Open English Wordnet JSON ZIP."""

import argparse
import json
import sqlite3
import zipfile
from pathlib import Path


PARTS = {"n": "noun", "v": "verb", "a": "adjective", "s": "adjective", "r": "adverb"}


def build(source: Path, destination: Path) -> None:
    with zipfile.ZipFile(source) as archive:
        synsets = {}
        for name in archive.namelist():
            if name.endswith(".json") and not name.startswith("entries-") and name != "frames.json":
                synsets.update(json.loads(archive.read(name)))

        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.unlink(missing_ok=True)
        db = sqlite3.connect(destination)
        try:
            db.executescript("""
                PRAGMA journal_mode=DELETE;
                CREATE TABLE entries (
                    id TEXT PRIMARY KEY,
                    word TEXT NOT NULL,
                    word_key TEXT NOT NULL,
                    lemma TEXT NOT NULL,
                    pos TEXT NOT NULL,
                    preview TEXT NOT NULL,
                    payload TEXT NOT NULL
                ) WITHOUT ROWID;
                CREATE INDEX entries_word ON entries(word_key, pos);
                CREATE VIRTUAL TABLE entry_search USING fts5(
                    id UNINDEXED, word, forms, definitions, tokenize='unicode61 remove_diacritics 2'
                );
            """)
            count = 0
            with db:
                for name in sorted(n for n in archive.namelist() if n.startswith("entries-") and n.endswith(".json")):
                    for lemma, variants in json.loads(archive.read(name)).items():
                        for source_pos, record in variants.items():
                            pos = PARTS.get(source_pos.split("-")[0])
                            if pos is None:
                                raise ValueError(f"Unexpected part of speech: {source_pos}")
                            senses = []
                            synonyms = set()
                            antonyms = set()
                            definitions = []
                            for sense in record["sense"]:
                                synset = synsets[sense["synset"]]
                                for index, definition in enumerate(synset["definition"]):
                                    senses.append({
                                        "id": sense["id"] if len(synset["definition"]) == 1 else f'{sense["id"]}#{index}',
                                        "definition": definition,
                                        "examples": synset.get("example", []),
                                        "register": None,
                                    })
                                    definitions.append(definition)
                                synonyms.update(synset["members"])
                                antonyms.update(item.split("%", 1)[0].replace("_", " ") for item in sense.get("antonym", []))
                            if not senses:
                                continue
                            synonyms.discard(lemma)
                            pronunciations = record.get("pronunciation", [])

                            def ipa(variety):
                                return next((p["value"] for p in pronunciations if p.get("variety") == variety), None)

                            generic_ipa = next((p["value"] for p in pronunciations if "variety" not in p), None)
                            identifier = f"oewn:{lemma}:{source_pos}"
                            entry = {
                                "id": identifier, "word": lemma.replace("_", " "), "lemma": lemma.replace("_", " "),
                                "partOfSpeech": pos, "ipaUK": ipa("GB") or generic_ipa,
                                "ipaUS": ipa("US") or generic_ipa, "senses": senses,
                                "synonyms": sorted(synonyms), "antonyms": sorted(antonyms),
                                "collocations": [], "cefrLevel": None, "usageNotes": [],
                                "commonMistakes": [], "audioUK": None, "audioUS": None,
                            }
                            word = entry["word"]
                            db.execute(
                                "INSERT INTO entries VALUES (?, ?, ?, ?, ?, ?, ?)",
                                (identifier, word, word.casefold(), entry["lemma"], pos,
                                 senses[0]["definition"], json.dumps(entry, ensure_ascii=False, separators=(",", ":"))),
                            )
                            db.execute(
                                "INSERT INTO entry_search VALUES (?, ?, ?, ?)",
                                (identifier, word, " ".join(record.get("form", [])), " ".join(definitions)),
                            )
                            count += 1
            db.execute("INSERT INTO entry_search(entry_search) VALUES ('optimize')")
            db.commit()
            assert db.execute("SELECT count(*) FROM entries").fetchone()[0] == count
            assert db.execute("SELECT count(*) FROM entry_search").fetchone()[0] == count
            print(f"Imported {count} entries to {destination}")
        finally:
            db.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Official english-wordnet-2025-json.zip")
    parser.add_argument("destination", type=Path, help="Output SQLite database")
    args = parser.parse_args()
    build(args.source, args.destination)
