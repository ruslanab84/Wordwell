# Dictionary seed provenance

The bundled `Dictionary.sqlite` is generated from **Open English Wordnet 2025**
(standard edition, without Open English Namenet), published by the Open English
Wordnet Community on 2025-12-31:

https://en-word.net/downloads

Source archive: `https://en-word.net/static/english-wordnet-2025-json.zip`

SHA-256: `7d749f6e2c39e6970e4997839dcf6e42fd281f3c2fae0171d2192bae8cfa4b51`

Open English Wordnet is licensed under CC BY 4.0 and derives from Princeton
WordNet. The complete upstream `LICENSE.md` and `WNDB_License.txt` are bundled
with the database as `OEWN_LICENSE.md` and `WNDB_License.txt`. Attribution:
Open English Wordnet Community and Princeton University WordNet. The importer
converts the upstream JSON into the app's SQLite schema and search index; it
does not rewrite definitions or examples.

Rebuild from the official archive:

```sh
python3 Tools/import_dictionary.py english-wordnet-2025-json.zip Packages/WordwellKit/Sources/WordwellData/Resources/Dictionary.sqlite
```

The seed contains 135,969 lemma/part-of-speech entries. OEWN provides
definitions, examples where available, pronunciations where available, forms,
synonyms, and antonyms. It does not provide curated CEFR levels, collocations,
common learner mistakes, or pronunciation audio; those fields remain empty.
The database is read-only at runtime and separate from future user-owned data.
