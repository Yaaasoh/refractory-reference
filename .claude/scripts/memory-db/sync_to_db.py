#!/usr/bin/env python3
"""
Sync file changes to the long-term memory DB.

Called by PostToolUse hook when .md or .bib files are written/edited.
Also usable standalone for batch import.

Usage (hook):
    echo '{"tool_input":{"file_path":"/path/to/file.md"}}' | py -3.11 sync_to_db.py

Usage (standalone):
    py -3.11 sync_to_db.py --file /path/to/file.md --db-path .claude/memory.db
    py -3.11 sync_to_db.py --file /path/to/refs.bib --db-path .claude/memory.db
"""

import argparse
import hashlib
import json
import re
import sqlite3
import sys
from pathlib import Path


def get_db(db_path: str) -> sqlite3.Connection:
    """Open DB connection, creating if needed."""
    db = sqlite3.connect(db_path)
    db.execute("PRAGMA journal_mode = WAL")
    db.execute("PRAGMA busy_timeout = 5000")
    return db


# --- Markdown processing ---

def extract_md_metadata(content: str, file_path: str) -> dict:
    """Extract metadata from Markdown file content."""
    title = ""
    created_at = ""
    doc_type = "unknown"

    # Title from first H1
    m = re.search(r"^#\s+(.+)$", content, re.MULTILINE)
    if m:
        title = m.group(1).strip()

    # Date from common patterns
    for pattern in [
        r"\*\*(?:日付|作成日|調査日|検索日|Date)\*\*:\s*(\d{4}-\d{2}-\d{2})",
        r"(?:日付|作成日|調査日):\s*(\d{4}-\d{2}-\d{2})",
    ]:
        m = re.search(pattern, content)
        if m:
            created_at = m.group(1)
            break

    # Doc type from path
    p = Path(file_path)
    parts = p.parts
    if "sources" in parts:
        doc_type = "source"
    elif "reports" in parts or p.name.startswith("WORK_REPORT"):
        doc_type = "report"
    elif "research" in parts:
        doc_type = "research"
    elif "review" in p.name.lower() or "REVIEW" in p.name:
        doc_type = "review"
    elif p.name.startswith("INCIDENT") or p.name.startswith("INC-"):
        doc_type = "incident"

    # Category from directory
    category = ""
    for part in parts:
        if part in ("work", "research", "reports", "sources", "incidents"):
            idx = parts.index(part)
            if idx + 1 < len(parts) and not parts[idx + 1].endswith(".md"):
                category = parts[idx + 1]
            break

    return {
        "title": title,
        "created_at": created_at,
        "doc_type": doc_type,
        "category": category,
    }


def chunk_markdown(content: str, file_path: str) -> list[dict]:
    """
    Split Markdown into chunks by ## headings.

    Small files (<4KB) are kept as a single chunk.
    """
    if len(content) < 4096:
        return [{"section": None, "content": content}]

    chunks = []
    current_section = None
    current_lines = []

    for line in content.split("\n"):
        if line.startswith("## "):
            # Save previous section
            if current_lines:
                text = "\n".join(current_lines).strip()
                if text:
                    chunks.append({"section": current_section, "content": text})
            current_section = line[3:].strip()
            current_lines = [line]
        else:
            current_lines.append(line)

    # Last section
    if current_lines:
        text = "\n".join(current_lines).strip()
        if text:
            chunks.append({"section": current_section, "content": text})

    return chunks if chunks else [{"section": None, "content": content}]


def sync_markdown(db: sqlite3.Connection, file_path: str, content: str, project: str = ""):
    """Sync a Markdown file to the DB (upsert documents + chunks)."""
    meta = extract_md_metadata(content, file_path)

    # Upsert document
    db.execute(
        """INSERT INTO documents(file_path, title, doc_type, created_at, category, project, content)
           VALUES (?, ?, ?, ?, ?, ?, ?)
           ON CONFLICT(file_path) DO UPDATE SET
             title=excluded.title, doc_type=excluded.doc_type,
             updated_at=datetime('now'), content=excluded.content""",
        [file_path, meta["title"], meta["doc_type"], meta["created_at"],
         meta["category"], project, content]
    )
    row = db.execute(
        "SELECT id FROM documents WHERE file_path = ?", [file_path]
    ).fetchone()
    if row is None:
        raise RuntimeError(f"Failed to insert/retrieve document: {file_path}")
    doc_id = row[0]

    # Replace chunks atomically (delete + insert in same transaction)
    chunks = chunk_markdown(content, file_path)
    db.execute("DELETE FROM chunks WHERE doc_id = ?", [doc_id])
    for chunk in chunks:
        db.execute(
            "INSERT INTO chunks(doc_id, section, content, source_file, doc_type) VALUES (?, ?, ?, ?, ?)",
            [doc_id, chunk["section"], chunk["content"], file_path, meta["doc_type"]]
        )
    db.commit()
    return len(chunks)


# --- BibTeX processing ---

def sync_bibtex(db: sqlite3.Connection, file_path: str, content: str, project: str = ""):
    """Sync a BibTeX file to the DB."""
    try:
        import bibtexparser
        from bibtexparser.middlewares import SeparateCoAuthors
    except ImportError:
        print("WARNING: bibtexparser not installed. Skipping .bib sync.", file=sys.stderr)
        return 0

    layers = [SeparateCoAuthors()]
    library = bibtexparser.parse_string(content, append_middleware=layers)

    if library.failed_blocks:
        print(f"WARNING: {len(library.failed_blocks)} blocks failed to parse", file=sys.stderr)

    def _bib_str(val) -> str:
        """Convert bibtexparser Field objects to str for sqlite3 bind."""
        if val is None:
            return ""
        # bibtexparser v2 Field object: unwrap .value
        if hasattr(val, "value"):
            return _bib_str(val.value)
        if isinstance(val, list):
            return "; ".join(_bib_str(a) for a in val)
        return str(val)

    count = 0
    for entry in library.entries:
        author_str = _bib_str(entry.get("author", ""))

        db.execute(
            """INSERT INTO bib_references(key, entry_type, title, author, year,
                 journal, doi, abstract, url, source_file, project)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
               ON CONFLICT(key) DO UPDATE SET
                 title=excluded.title, author=excluded.author,
                 year=excluded.year, journal=excluded.journal,
                 doi=excluded.doi, abstract=excluded.abstract,
                 url=excluded.url, updated_at=datetime('now')""",
            [
                str(entry.key),
                str(entry.entry_type),
                _bib_str(entry.get("title", "")),
                author_str,
                _bib_str(entry.get("year", "")),
                _bib_str(entry.get("journal", "")),
                _bib_str(entry.get("doi", "")),
                _bib_str(entry.get("abstract", "")),
                _bib_str(entry.get("url", "")),
                file_path,
                project,
            ]
        )

        count += 1

    # Commit all reference upserts first, then update FTS
    db.commit()

    # Rebuild FTS for references (ensures rowids are available)
    db.execute("DELETE FROM fts_references")
    db.execute("""
        INSERT INTO fts_references(rowid, title, author, abstract, journal)
        SELECT rowid, title, author, abstract, journal FROM bib_references
    """)
    db.commit()
    return count


# --- Main entry point ---

def sync_file(db: sqlite3.Connection, file_path: str, project: str = "") -> dict:
    """Sync a single file to the DB based on its extension."""
    p = Path(file_path)
    if not p.exists():
        return {"error": f"File not found: {file_path}", "count": 0}

    content = p.read_text(encoding="utf-8", errors="replace")
    ext = p.suffix.lower()

    if ext == ".bib":
        count = sync_bibtex(db, file_path, content, project)
        return {"type": "bibtex", "count": count, "file": file_path}
    elif ext in (".md", ".txt"):
        count = sync_markdown(db, file_path, content, project)
        return {"type": "markdown", "count": count, "file": file_path}
    else:
        return {"error": f"Unsupported extension: {ext}", "count": 0}


def main():
    parser = argparse.ArgumentParser(description="Sync file to memory DB")
    parser.add_argument("--file", help="File path to sync (standalone mode)")
    parser.add_argument("--db-path", default=".claude/memory.db", help="DB path")
    parser.add_argument("--project", default="", help="Project name")
    args = parser.parse_args()

    # Hook mode: read file_path from stdin JSON
    if not args.file:
        try:
            stdin_data = sys.stdin.read()
            hook_input = json.loads(stdin_data)
            args.file = hook_input.get("tool_input", {}).get("file_path", "")
        except (json.JSONDecodeError, KeyError):
            pass

    if not args.file:
        print("No file specified. Use --file or pipe hook JSON.", file=sys.stderr)
        sys.exit(1)

    # Check extension filter
    ext = Path(args.file).suffix.lower()
    if ext not in (".md", ".bib", ".txt"):
        sys.exit(0)  # Silently skip unsupported files

    db = get_db(args.db_path)
    result = sync_file(db, args.file, args.project)
    db.close()

    if "error" in result:
        print(f"ERROR: {result['error']}", file=sys.stderr)
        sys.exit(1)

    print(json.dumps(result))


if __name__ == "__main__":
    main()
