#!/usr/bin/env python3
"""
Batch import existing Markdown and BibTeX files into the memory DB.

Scans specified directories for .md and .bib files, chunks them,
and inserts into the database.

Usage:
    py -3.11 shared/scripts/memory-db/import_existing.py \
        --db-path .claude/memory.db \
        --dirs work/ research/ incidents/ \
        --project prompt-patterns

    # Dry run (count files only)
    py -3.11 shared/scripts/memory-db/import_existing.py --dry-run --dirs work/
"""

import argparse
import json
import sys
import time
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from init_db import init_db
from sync_to_db import sync_file


def find_files(dirs: list[str], extensions: tuple = (".md", ".bib")) -> list[Path]:
    """Find all target files in specified directories."""
    files = []
    for d in dirs:
        p = Path(d)
        if not p.exists():
            print(f"WARNING: Directory not found: {d}", file=sys.stderr)
            continue
        for ext in extensions:
            files.extend(p.rglob(f"*{ext}"))

    # Sort by modification time (newest first)
    files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
    return files


def filter_files(files: list[Path], exclude_patterns: list[str] = None) -> list[Path]:
    """Filter out unwanted files."""
    default_excludes = [
        "node_modules",
        ".git",
        "__pycache__",
        ".venv",
        "venv",
        ".claude/worktrees",
    ]
    excludes = default_excludes + (exclude_patterns or [])

    filtered = []
    for f in files:
        # Normalize separators for cross-platform matching
        path_str = f.as_posix()
        if any(ex in path_str for ex in excludes):
            continue
        # Skip very large files (>1MB)
        if f.stat().st_size > 1_000_000:
            print(f"SKIP (>1MB): {f}", file=sys.stderr)
            continue
        filtered.append(f)

    return filtered


def main():
    parser = argparse.ArgumentParser(description="Batch import files into memory DB")
    parser.add_argument("--db-path", default=".claude/memory.db", help="DB path")
    parser.add_argument("--dirs", nargs="+", default=["work/"], help="Directories to scan")
    parser.add_argument("--project", default="", help="Project name")
    parser.add_argument("--dry-run", action="store_true", help="Count files only")
    parser.add_argument("--exclude", nargs="*", default=[], help="Additional exclude patterns")
    args = parser.parse_args()

    # Find files
    files = find_files(args.dirs)
    files = filter_files(files, args.exclude)

    # Categorize
    md_files = [f for f in files if f.suffix == ".md"]
    bib_files = [f for f in files if f.suffix == ".bib"]

    print(f"Found: {len(md_files)} .md + {len(bib_files)} .bib = {len(files)} files")

    if args.dry_run:
        print("\n--- Dry run: file listing ---")
        for f in files[:50]:
            size_kb = f.stat().st_size / 1024
            print(f"  [{f.suffix}] {f} ({size_kb:.1f}KB)")
        if len(files) > 50:
            print(f"  ... and {len(files) - 50} more")
        return

    # Initialize DB
    db = init_db(args.db_path)

    # Import
    start = time.time()
    success = 0
    errors = 0
    total_chunks = 0

    for i, f in enumerate(files):
        try:
            result = sync_file(db, str(f), args.project)
            if "error" in result:
                print(f"  ERROR: {f}: {result['error']}", file=sys.stderr)
                errors += 1
            else:
                total_chunks += result.get("count", 0)
                success += 1
        except Exception as e:
            print(f"  EXCEPTION: {f}: {e}", file=sys.stderr)
            errors += 1

        # Progress every 100 files
        if (i + 1) % 100 == 0:
            elapsed = time.time() - start
            rate = (i + 1) / elapsed
            print(f"  Progress: {i+1}/{len(files)} ({rate:.1f} files/sec)")

    elapsed = time.time() - start

    # Summary
    print(f"\n--- Import complete ---")
    print(f"  Files:  {success} success, {errors} errors")
    print(f"  Chunks: {total_chunks}")
    print(f"  Time:   {elapsed:.1f}s ({len(files)/max(elapsed,0.1):.1f} files/sec)")

    # Verify
    doc_count = db.execute("SELECT count(*) FROM documents").fetchone()[0]
    chunk_count = db.execute("SELECT count(*) FROM chunks").fetchone()[0]
    ref_count = db.execute("SELECT count(*) FROM bib_references").fetchone()[0]
    print(f"\n--- DB stats ---")
    print(f"  Documents:  {doc_count}")
    print(f"  Chunks:     {chunk_count}")
    print(f"  References: {ref_count}")

    # Optimize FTS
    db.execute("INSERT INTO fts_chunks(fts_chunks) VALUES('optimize')")
    db.commit()
    print("  FTS optimized")

    db.close()


if __name__ == "__main__":
    main()
