#!/usr/bin/env python3
"""
Rebuild memory DB from NDJSON export files.

Reads .ndjson files from the data directory, creates the DB schema,
and imports all rows. FTS5 indexes are rebuilt automatically via triggers.

Usage:
    py -3.11 shared/scripts/memory-db/rebuild_db.py \
        --data-dir .claude/memory-data/ \
        --db-path .claude/memory.db

    # Force rebuild (delete existing DB first)
    py -3.11 shared/scripts/memory-db/rebuild_db.py --force
"""

import argparse
import base64
import json
import sqlite3
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from init_db import init_db


# Column definitions for each table (must match schema)
TABLE_COLUMNS = {
    "sessions": ["id", "project", "directory", "started_at", "ended_at", "summary"],
    "observations": [
        "id", "session_id", "type", "title", "content", "project", "scope",
        "topic_key", "normalized_hash", "revision_count", "duplicate_count",
        "last_seen_at", "created_at", "updated_at", "deleted_at"
    ],
    "documents": [
        "id", "file_path", "title", "doc_type", "created_at", "updated_at",
        "category", "project", "content"
    ],
    "chunks": [
        "id", "doc_id", "section", "content", "source_file", "doc_type", "created_at"
    ],
    "bib_references": [
        "key", "entry_type", "title", "author", "year", "journal",
        "doi", "abstract", "url", "source_file", "project", "created_at", "updated_at"
    ],
    "schema_meta": ["key", "value"],
}

# Import order (respect foreign key constraints)
IMPORT_ORDER = [
    "schema_meta",
    "sessions",
    "documents",
    "observations",
    "chunks",
    "bib_references",
]


def import_ndjson(db: sqlite3.Connection, table: str, ndjson_path: Path) -> int:
    """Import a single NDJSON file into a table."""
    if not ndjson_path.exists():
        return 0

    columns = TABLE_COLUMNS.get(table)
    if not columns:
        print(f"  SKIP {table}: no column definition", file=sys.stderr)
        return 0

    placeholders = ", ".join(["?"] * len(columns))
    col_names = ", ".join(columns)
    sql = f"INSERT OR REPLACE INTO {table}({col_names}) VALUES ({placeholders})"

    count = 0
    with open(ndjson_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            record = json.loads(line)
            values = [record.get(col) for col in columns]
            try:
                db.execute(sql, values)
                count += 1
            except sqlite3.Error as e:
                print(f"  ERROR {table} row {count}: {e}", file=sys.stderr)

    return count


def rebuild_fts(db: sqlite3.Connection):
    """Rebuild FTS5 indexes from base tables."""
    # chunks -> fts_chunks
    db.execute("INSERT INTO fts_chunks(fts_chunks) VALUES('rebuild')")

    # observations -> fts_observations
    db.execute("INSERT INTO fts_observations(fts_observations) VALUES('rebuild')")

    # bib_references -> fts_references (direct insert, not external content)
    db.execute("DELETE FROM fts_references")
    db.execute("""
        INSERT INTO fts_references(rowid, title, author, abstract, journal)
        SELECT rowid, title, author, abstract, journal FROM bib_references
    """)

    # Optimize all FTS indexes
    db.execute("INSERT INTO fts_chunks(fts_chunks) VALUES('optimize')")
    db.execute("INSERT INTO fts_observations(fts_observations) VALUES('optimize')")
    db.execute("INSERT INTO fts_references(fts_references) VALUES('optimize')")


def rebuild_db(data_dir: str, db_path: str, force: bool = False) -> dict:
    """Rebuild the entire DB from NDJSON files."""
    data = Path(data_dir)
    db_file = Path(db_path)

    if not data.exists():
        print(f"ERROR: Data directory not found: {data_dir}", file=sys.stderr)
        sys.exit(1)

    # Check for existing DB
    if db_file.exists():
        if force:
            db_file.unlink()
            # Also remove WAL/SHM if present
            for suffix in ("-wal", "-shm"):
                wal = db_file.with_name(db_file.name + suffix)
                if wal.exists():
                    wal.unlink()
        else:
            print(f"DB already exists: {db_path}. Use --force to rebuild.", file=sys.stderr)
            sys.exit(1)

    # Initialize empty DB (creates schema + FTS + triggers)
    # Temporarily disable triggers during bulk import
    db = init_db(db_path)
    db.execute("DROP TRIGGER IF EXISTS chunks_ai")
    db.execute("DROP TRIGGER IF EXISTS chunks_ad")
    db.execute("DROP TRIGGER IF EXISTS chunks_au")
    db.execute("DROP TRIGGER IF EXISTS obs_fts_insert")
    db.execute("DROP TRIGGER IF EXISTS obs_fts_delete")
    db.execute("DROP TRIGGER IF EXISTS obs_fts_update")

    # Import tables in order
    results = {}
    total = 0

    for table in IMPORT_ORDER:
        ndjson_file = data / f"{table}.ndjson"
        count = import_ndjson(db, table, ndjson_file)
        if count > 0:
            results[table] = count
            total += count

    db.commit()

    # Rebuild FTS indexes (bulk, faster than trigger-per-row)
    rebuild_fts(db)
    db.commit()

    # Import embeddings if available
    vec_loaded = False
    try:
        import sqlite_vec
        db.enable_load_extension(True)
        sqlite_vec.load(db)
        db.enable_load_extension(False)
        vec_loaded = True
    except (ImportError, Exception):
        pass

    if vec_loaded:
        for vec_table, id_col, dim in [
            ("vec_chunks", "chunk_id", 768),
            ("vec_references", "ref_rowid", 768),
        ]:
            ndjson_file = data / f"{vec_table}.ndjson"
            if not ndjson_file.exists():
                continue

            # vec tables already created by init_db()
            count = 0
            with open(ndjson_file, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    record = json.loads(line)
                    emb_bytes = base64.b64decode(record["embedding_b64"])
                    db.execute(
                        f"INSERT OR REPLACE INTO {vec_table}({id_col}, embedding) VALUES (?, ?)",
                        [record["id"], emb_bytes]
                    )
                    count += 1

            if count > 0:
                results[vec_table] = count
                total += count

        db.commit()

    # Re-create triggers for future incremental updates
    from init_db import TRIGGERS_CHUNKS, TRIGGERS_OBSERVATIONS
    db.executescript(TRIGGERS_CHUNKS)
    db.executescript(TRIGGERS_OBSERVATIONS)
    db.commit()

    db.close()
    return {"total_rows": total, "tables": results, "db_path": db_path}


def main():
    parser = argparse.ArgumentParser(description="Rebuild memory DB from NDJSON")
    parser.add_argument("--data-dir", default=".claude/memory-data/", help="NDJSON data directory")
    parser.add_argument("--db-path", default=".claude/memory.db", help="Output DB path")
    parser.add_argument("--force", action="store_true", help="Delete existing DB before rebuild")
    args = parser.parse_args()

    start = time.time()
    result = rebuild_db(args.data_dir, args.db_path, args.force)
    elapsed = time.time() - start

    print(f"Rebuilt {result['db_path']} in {elapsed:.1f}s:")
    for table, count in result["tables"].items():
        print(f"  {table}: {count} rows")
    print(f"  Total: {result['total_rows']} rows")


if __name__ == "__main__":
    main()
