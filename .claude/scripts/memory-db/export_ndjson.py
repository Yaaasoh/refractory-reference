#!/usr/bin/env python3
"""
Export memory DB tables to NDJSON (Newline-Delimited JSON) files.

NDJSON format: one JSON object per line, git-friendly (line-level diffs).
Exported files are tracked by git; the .db file is gitignored.

Usage:
    py -3.11 shared/scripts/memory-db/export_ndjson.py \
        --db-path .claude/memory.db \
        --out-dir .claude/memory-data/
"""

import argparse
import base64
import json
import sqlite3
import sys
from pathlib import Path


def export_table(db: sqlite3.Connection, table: str, out_dir: Path,
                 order_by: str = "rowid") -> int:
    """Export a single table to NDJSON file."""

    try:
        rows = db.execute(f"SELECT * FROM {table} ORDER BY {order_by}").fetchall()
    except sqlite3.OperationalError as e:
        print(f"  SKIP {table}: {e}", file=sys.stderr)
        return 0

    if not rows:
        return 0

    out_file = out_dir / f"{table}.ndjson"
    with open(out_file, "w", encoding="utf-8") as f:
        for row in rows:
            record = dict(row)
            # Remove binary/blob columns (embeddings) — handled separately
            record = {k: v for k, v in record.items()
                      if not isinstance(v, (bytes, memoryview))}
            f.write(json.dumps(record, ensure_ascii=False, default=str) + "\n")

    return len(rows)


def export_schema(db: sqlite3.Connection, out_dir: Path):
    """Export CREATE TABLE statements."""
    rows = db.execute(
        "SELECT sql FROM sqlite_master WHERE type='table' AND sql IS NOT NULL "
        "AND name NOT LIKE 'fts_%' AND name NOT LIKE 'vec_%' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name"
    ).fetchall()

    out_file = out_dir / "schema.sql"
    with open(out_file, "w", encoding="utf-8") as f:
        for row in rows:
            f.write(row["sql"] + ";\n\n")


def export_vec_table(db: sqlite3.Connection, vec_table: str, id_col: str,
                     out_dir: Path) -> int:
    """Export sqlite-vec virtual table embeddings as base64-encoded NDJSON."""
    try:
        rows = db.execute(
            f"SELECT {id_col}, embedding FROM {vec_table} ORDER BY {id_col}"
        ).fetchall()
    except sqlite3.OperationalError as e:
        print(f"  SKIP {vec_table}: {e}", file=sys.stderr)
        return 0

    if not rows:
        return 0

    out_file = out_dir / f"{vec_table}.ndjson"
    with open(out_file, "w", encoding="utf-8") as f:
        for row_id, embedding_blob in rows:
            record = {
                "id": row_id,
                "embedding_b64": base64.b64encode(bytes(embedding_blob)).decode("ascii"),
            }
            f.write(json.dumps(record) + "\n")

    return len(rows)


def export_db(db_path: str, out_dir: str, include_embeddings: bool = True) -> dict:
    """Export all tables to NDJSON."""
    db = sqlite3.connect(db_path)
    db.row_factory = sqlite3.Row

    # Load sqlite-vec if available (needed to read vec tables)
    vec_loaded = False
    if include_embeddings:
        try:
            import sqlite_vec
            db.enable_load_extension(True)
            sqlite_vec.load(db)
            db.enable_load_extension(False)
            vec_loaded = True
        except (ImportError, Exception) as e:
            print(f"  sqlite-vec not available: {e}", file=sys.stderr)

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)

    # Tables to export (skip FTS shadow tables and vec virtual tables)
    exportable = [
        ("sessions", "started_at"),
        ("observations", "id"),
        ("documents", "id"),
        ("chunks", "id"),
        ("bib_references", "key"),
        ("schema_meta", "key"),
    ]

    results = {}
    total = 0

    # Schema
    export_schema(db, out)

    # Data
    for table, order_by in exportable:
        count = export_table(db, table, out, order_by)
        if count > 0:
            results[table] = count
            total += count

    # Embeddings (base64-encoded)
    if vec_loaded:
        for vec_table, id_col in [("vec_chunks", "chunk_id"), ("vec_references", "ref_rowid")]:
            count = export_vec_table(db, vec_table, id_col, out)
            if count > 0:
                results[vec_table] = count
                total += count

    db.close()
    return {"total_rows": total, "tables": results, "out_dir": str(out)}


def main():
    parser = argparse.ArgumentParser(description="Export memory DB to NDJSON")
    parser.add_argument("--db-path", default=".claude/memory.db", help="DB path")
    parser.add_argument("--out-dir", default=".claude/memory-data/", help="Output directory")
    args = parser.parse_args()

    if not Path(args.db_path).exists():
        print(f"ERROR: DB not found: {args.db_path}", file=sys.stderr)
        sys.exit(1)

    result = export_db(args.db_path, args.out_dir)

    print(f"Exported to {result['out_dir']}:")
    for table, count in result["tables"].items():
        print(f"  {table}: {count} rows")
    print(f"  Total: {result['total_rows']} rows")


if __name__ == "__main__":
    main()
