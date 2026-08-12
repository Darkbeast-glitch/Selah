#!/usr/bin/env python3
"""Build the bundled KJV Scripture database: assets/scripture/kjv.db

Run from the project root:

    python3 tool/build_kjv_db.py              # download source, build, verify
    python3 tool/build_kjv_db.py --src ./kjv  # build from an existing dir

Why this exists (PRD §12): the Bible content is stored separately from
application logic, and the translation must be configurable. The KJV is public
domain, so it carries no licensing risk — do NOT swap in a copyrighted
translation without confirming permission first.

Source: https://github.com/aruljohn/Bible-kjv — one JSON file per book with
*explicit* verse numbers, which is why it was chosen: versification can be
verified rather than assumed positionally. A previously considered dataset
(thiagobodruk/bible) was rejected because it splits 3 John 1:14 and
Revelation 12:17, which is Portuguese versification, not KJV.

The build refuses to emit a database unless the corpus is exactly 66 books /
1189 chapters / 31102 verses with contiguous verse numbering. A Scripture app
that silently drops verses is worse than one that fails loudly.

No FTS5: it is absent from Android's bundled SQLite below API 26, and Flutter
supports lower. Search uses LIKE, which SQLite evaluates case-insensitively for
ASCII by default — so no duplicate lowercased column is needed, and the KJV text
is pure ASCII. At 31k rows a scan is a few tens of milliseconds.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone

REPO = "https://raw.githubusercontent.com/aruljohn/Bible-kjv/master/"
TRANSLATION = "KJV"

EXPECT_BOOKS = 66
EXPECT_CHAPTERS = 1189
EXPECT_VERSES = 31102

# Genesis..Malachi are the 39 Old Testament books.
OT_COUNT = 39

# Chapters whose verse count differs between editions — asserted so a future
# source swap cannot silently change versification underneath the app.
VERSIFICATION_CHECKS = {
    ("3 John", 1): 14,
    ("Revelation", 12): 17,
    ("Revelation", 22): 21,
    ("Psalms", 117): 2,
    ("Psalms", 119): 176,
    ("John", 3): 36,
    ("Genesis", 1): 31,
}


def slug(name: str) -> str:
    """'Song of Solomon' -> 'song_of_solomon', '1 Kings' -> '1_kings'."""
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def fetch(url: str) -> bytes:
    with urllib.request.urlopen(url, timeout=60) as response:
        return response.read()


def load_corpus(src: str | None) -> tuple[list[str], dict]:
    if src:
        books = json.load(open(os.path.join(src, "Books.json")))
        read = lambda b: json.load(open(os.path.join(src, f"{b}.json")))
    else:
        books = json.loads(fetch(REPO + "Books.json"))
        def read(b):
            url = REPO + urllib.parse.quote(b.replace(" ", "")) + ".json"
            return json.loads(fetch(url))

    corpus = {}
    for i, book in enumerate(books, 1):
        data = read(book)
        if data["book"] != book:
            sys.exit(f"book name mismatch: file says {data['book']!r}, index says {book!r}")
        corpus[book] = data
        print(f"  [{i:2}/{len(books)}] {book}", flush=True)
    return books, corpus


def verify(books: list[str], corpus: dict) -> None:
    problems: list[str] = []
    chapters = verses = 0

    for book in books:
        for ci, chapter in enumerate(corpus[book]["chapters"], 1):
            chapters += 1
            if int(chapter["chapter"]) != ci:
                problems.append(f"{book}: chapter labelled {chapter['chapter']} at position {ci}")
            nums = [int(v["verse"]) for v in chapter["verses"]]
            verses += len(nums)
            if nums != list(range(1, len(nums) + 1)):
                problems.append(f"{book} {ci}: non-contiguous verse numbers")
            for v in chapter["verses"]:
                if not v["text"].strip():
                    problems.append(f"{book} {ci}:{v['verse']}: empty text")

    if len(books) != EXPECT_BOOKS:
        problems.append(f"books: {len(books)} != {EXPECT_BOOKS}")
    if chapters != EXPECT_CHAPTERS:
        problems.append(f"chapters: {chapters} != {EXPECT_CHAPTERS}")
    if verses != EXPECT_VERSES:
        problems.append(f"verses: {verses} != {EXPECT_VERSES}")

    for (book, ch), expected in VERSIFICATION_CHECKS.items():
        got = len(corpus[book]["chapters"][ch - 1]["verses"])
        if got != expected:
            problems.append(f"versification {book} {ch}: {got} verses, expected {expected}")

    print(f"\n  books={len(books)} chapters={chapters} verses={verses}")
    if problems:
        print("\nCORPUS REJECTED:", file=sys.stderr)
        for p in problems[:20]:
            print("  -", p, file=sys.stderr)
        sys.exit(1)
    print("  integrity: OK (counts, numbering, versification)")


SCHEMA = """
PRAGMA journal_mode = DELETE;   -- single-file asset, no -wal companion
PRAGMA page_size = 4096;

CREATE TABLE books (
  book_order INTEGER PRIMARY KEY,   -- 1..66, canonical order
  name       TEXT NOT NULL UNIQUE,  -- 'Psalms'
  slug       TEXT NOT NULL UNIQUE,  -- 'psalms'
  testament  TEXT NOT NULL,         -- 'OT' | 'NT'
  chapters   INTEGER NOT NULL
);

CREATE TABLE verses (
  id          TEXT PRIMARY KEY,     -- 'psalms_23_1'
  book        TEXT NOT NULL,        -- 'Psalms'
  book_order  INTEGER NOT NULL,
  chapter     INTEGER NOT NULL,
  verse       INTEGER NOT NULL,
  text        TEXT NOT NULL,
  translation TEXT NOT NULL
);

-- Reader: fetch a chapter in order.
CREATE INDEX idx_verses_location ON verses (book_order, chapter, verse);
-- Search by book name.
CREATE INDEX idx_verses_book ON verses (book);

CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
"""


def build(books: list[str], corpus: dict, out: str) -> None:
    os.makedirs(os.path.dirname(out), exist_ok=True)
    if os.path.exists(out):
        os.remove(out)

    db = sqlite3.connect(out)
    db.executescript(SCHEMA)

    book_rows = []
    verse_rows = []
    for order, book in enumerate(books, 1):
        data = corpus[book]
        book_rows.append((
            order, book, slug(book),
            "OT" if order <= OT_COUNT else "NT",
            len(data["chapters"]),
        ))
        for chapter in data["chapters"]:
            ch = int(chapter["chapter"])
            for v in chapter["verses"]:
                num = int(v["verse"])
                text = v["text"].strip()
                verse_rows.append((
                    f"{slug(book)}_{ch}_{num}",
                    book, order, ch, num, text, TRANSLATION,
                ))

    db.executemany("INSERT INTO books VALUES (?,?,?,?,?)", book_rows)
    db.executemany("INSERT INTO verses VALUES (?,?,?,?,?,?,?)", verse_rows)
    db.executemany("INSERT INTO meta VALUES (?,?)", [
        ("translation", TRANSLATION),
        ("translation_name", "King James Version"),
        ("license", "Public domain"),
        ("source", "https://github.com/aruljohn/Bible-kjv"),
        ("books", str(len(book_rows))),
        ("verses", str(len(verse_rows))),
        ("schema_version", "1"),
        ("built_at", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")),
    ])
    db.commit()
    db.execute("VACUUM")
    db.execute("PRAGMA optimize")
    db.close()

    # Read back and assert, so a broken write cannot ship.
    db = sqlite3.connect(f"file:{out}?mode=ro", uri=True)
    n_books, n_verses = (
        db.execute("SELECT COUNT(*) FROM books").fetchone()[0],
        db.execute("SELECT COUNT(*) FROM verses").fetchone()[0],
    )
    j316 = db.execute("SELECT text FROM verses WHERE id='john_3_16'").fetchone()
    integrity = db.execute("PRAGMA integrity_check").fetchone()[0]
    db.close()

    assert n_books == EXPECT_BOOKS, n_books
    assert n_verses == EXPECT_VERSES, n_verses
    assert integrity == "ok", integrity
    assert j316 and j316[0].startswith("For God so loved the world"), j316

    print(f"\n  {out}")
    print(f"  {n_books} books, {n_verses} verses, {os.path.getsize(out) // 1024} KB")
    print(f"  integrity_check: {integrity}")
    print(f"  john_3_16: {j316[0][:60]}...")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", help="directory of Books.json + <Book>.json (default: download)")
    ap.add_argument("--out", default="assets/scripture/kjv.db")
    args = ap.parse_args()

    print("Loading KJV corpus...")
    books, corpus = load_corpus(args.src)
    print("\nVerifying...")
    verify(books, corpus)
    print("\nBuilding database...")
    build(books, corpus, args.out)
    print("\nDone.")


if __name__ == "__main__":
    main()
