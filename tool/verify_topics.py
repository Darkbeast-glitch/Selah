#!/usr/bin/env python3
"""Assert every curated verse id in topic_catalog.dart and the daily pool exists.

    python3 tool/verify_topics.py

A missing id fails silently at runtime — the topic simply shows nothing — so this
runs against the built corpus. It cannot live in `flutter test` because opening
the SQLite asset requires a platform; the Dart-side test covers structure and
UI coverage instead. Run this after editing either list, or after rebuilding the
database with a different source.
"""

import re
import sqlite3
import sys

DB = "assets/scripture/kjv.db"
FILES = {
    "topic_catalog": "lib/features/scripture/data/topic_catalog.dart",
    "dailyPool": "lib/features/scripture/data/scripture_datasource.dart",
}


def ids_from(path: str, marker: str) -> list[tuple[str, str]]:
    src = open(path).read()
    if marker == "dailyPool":
        block = re.search(r"dailyPool = <String>\[(.*?)\];", src, re.S).group(1)
        return [("dailyPool", i) for i in re.findall(r"'([a-z0-9_]+)'", block)]

    body = src[src.index("topics = <String, List<String>>{"):]
    out = []
    for topic, block in re.findall(r"'([^']+)':\s*\[(.*?)\]", body, re.S):
        out += [(topic, i) for i in re.findall(r"'([a-z0-9_]+)'", block)]
    return out


def main() -> None:
    try:
        db = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    except sqlite3.OperationalError:
        sys.exit(f"{DB} not found — run tool/build_kjv_db.py first")

    entries = ids_from(FILES["topic_catalog"], "topic_catalog")
    entries += ids_from(FILES["dailyPool"], "dailyPool")

    missing = [
        (owner, vid)
        for owner, vid in entries
        if not db.execute("SELECT 1 FROM verses WHERE id=?", (vid,)).fetchone()
    ]

    print(f"checked {len(entries)} curated ids across {len({o for o, _ in entries})} lists")
    if missing:
        print(f"\n{len(missing)} INVALID:", file=sys.stderr)
        for owner, vid in missing:
            print(f"  {owner}: {vid}", file=sys.stderr)
        sys.exit(1)
    print("all ids resolve to real verses")


if __name__ == "__main__":
    main()
