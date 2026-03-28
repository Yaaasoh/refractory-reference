#!/usr/bin/env python3
"""
Long-term memory DB initialization script.

Creates SQLite database with:
- documents table (Markdown/BibTeX metadata)
- chunks table (section-level text chunks)
- FTS5 virtual table (trigram tokenizer for Japanese)
- vec0 virtual table (sqlite-vec for semantic search)
- sessions table (session tracking, Engram-inspired)
- observations table (structured memories, Engram-inspired)

Usage:
    py -3.11 shared/scripts/memory-db/init_db.py [--db-path .claude/memory.db]
"""

import argparse
import sqlite3
import sys
from pathlib import Path


SCHEMA_VERSION = 1

PRAGMA_SETTINGS = """
PRAGMA journal_mode = WAL;
PRAGMA busy_timeout = 5000;
PRAGMA synchronous = NORMAL;
PRAGMA foreign_keys = ON;
"""

# --- Core tables ---

SESSIONS_TABLE = """
CREATE TABLE IF NOT EXISTS sessions (
    id          TEXT PRIMARY KEY,
    project     TEXT NOT NULL,
    directory   TEXT NOT NULL,
    started_at  TEXT NOT NULL DEFAULT (datetime('now')),
    ended_at    TEXT,
    summary     TEXT
);
"""

OBSERVATIONS_TABLE = """
CREATE TABLE IF NOT EXISTS observations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id      TEXT NOT NULL,
    type            TEXT NOT NULL,
    title           TEXT NOT NULL,
    content         TEXT NOT NULL,
    project         TEXT,
    scope           TEXT NOT NULL DEFAULT 'project',
    topic_key       TEXT,
    normalized_hash TEXT,
    revision_count  INTEGER NOT NULL DEFAULT 1,
    duplicate_count INTEGER NOT NULL DEFAULT 1,
    last_seen_at    TEXT,
    created_at      TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);
"""

DOCUMENTS_TABLE = """
CREATE TABLE IF NOT EXISTS documents (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    file_path   TEXT NOT NULL UNIQUE,
    title       TEXT,
    doc_type    TEXT,
    created_at  TEXT,
    updated_at  TEXT DEFAULT (datetime('now')),
    category    TEXT,
    project     TEXT,
    content     TEXT NOT NULL
);
"""

CHUNKS_TABLE = """
CREATE TABLE IF NOT EXISTS chunks (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    doc_id      INTEGER REFERENCES documents(id) ON DELETE CASCADE,
    section     TEXT,
    content     TEXT NOT NULL,
    source_file TEXT,
    doc_type    TEXT,
    created_at  TEXT DEFAULT (datetime('now'))
);
"""

REFERENCES_TABLE = """
CREATE TABLE IF NOT EXISTS bib_references (
    key         TEXT PRIMARY KEY,
    entry_type  TEXT,
    title       TEXT,
    author      TEXT,
    year        TEXT,
    journal     TEXT,
    doi         TEXT,
    abstract    TEXT,
    url         TEXT,
    source_file TEXT,
    project     TEXT,
    created_at  TEXT DEFAULT (datetime('now')),
    updated_at  TEXT DEFAULT (datetime('now'))
);
"""

SCHEMA_META_TABLE = """
CREATE TABLE IF NOT EXISTS schema_meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
"""

# --- FTS5 virtual tables ---

FTS_CHUNKS = """
CREATE VIRTUAL TABLE IF NOT EXISTS fts_chunks USING fts5(
    content,
    content='chunks',
    content_rowid='id',
    tokenize='trigram'
);
"""

FTS_OBSERVATIONS = """
CREATE VIRTUAL TABLE IF NOT EXISTS fts_observations USING fts5(
    title,
    content,
    type,
    project,
    topic_key,
    content='observations',
    content_rowid='id'
);
"""

FTS_REFERENCES = """
CREATE VIRTUAL TABLE IF NOT EXISTS fts_references USING fts5(
    title,
    author,
    abstract,
    journal,
    tokenize='trigram'
);
"""

# --- Triggers for FTS sync ---

TRIGGERS_CHUNKS = """
CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
    INSERT INTO fts_chunks(rowid, content)
    VALUES (new.id, new.content);
END;

CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
    INSERT INTO fts_chunks(fts_chunks, rowid, content)
    VALUES ('delete', old.id, old.content);
END;

CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
    INSERT INTO fts_chunks(fts_chunks, rowid, content)
    VALUES ('delete', old.id, old.content);
    INSERT INTO fts_chunks(rowid, content)
    VALUES (new.id, new.content);
END;
"""

TRIGGERS_OBSERVATIONS = """
CREATE TRIGGER IF NOT EXISTS obs_fts_insert AFTER INSERT ON observations BEGIN
    INSERT INTO fts_observations(rowid, title, content, type, project, topic_key)
    VALUES (new.id, new.title, new.content, new.type, new.project, new.topic_key);
END;

CREATE TRIGGER IF NOT EXISTS obs_fts_delete AFTER DELETE ON observations BEGIN
    INSERT INTO fts_observations(fts_observations, rowid, title, content, type, project, topic_key)
    VALUES ('delete', old.id, old.title, old.content, old.type, old.project, old.topic_key);
END;

CREATE TRIGGER IF NOT EXISTS obs_fts_update AFTER UPDATE ON observations BEGIN
    INSERT INTO fts_observations(fts_observations, rowid, title, content, type, project, topic_key)
    VALUES ('delete', old.id, old.title, old.content, old.type, old.project, old.topic_key);
    INSERT INTO fts_observations(rowid, title, content, type, project, topic_key)
    VALUES (new.id, new.title, new.content, new.type, new.project, new.topic_key);
END;
"""

# --- Indexes ---

INDEXES = """
CREATE INDEX IF NOT EXISTS idx_obs_session ON observations(session_id);
CREATE INDEX IF NOT EXISTS idx_obs_type ON observations(type);
CREATE INDEX IF NOT EXISTS idx_obs_project ON observations(project);
CREATE INDEX IF NOT EXISTS idx_obs_created ON observations(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_obs_topic ON observations(topic_key, project, scope, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_obs_deleted ON observations(deleted_at);
CREATE INDEX IF NOT EXISTS idx_obs_dedupe ON observations(normalized_hash, project, scope, type, title);

CREATE INDEX IF NOT EXISTS idx_docs_path ON documents(file_path);
CREATE INDEX IF NOT EXISTS idx_docs_type ON documents(doc_type);
CREATE INDEX IF NOT EXISTS idx_docs_project ON documents(project);

CREATE INDEX IF NOT EXISTS idx_chunks_doc ON chunks(doc_id);
CREATE INDEX IF NOT EXISTS idx_chunks_type ON chunks(doc_type);

CREATE INDEX IF NOT EXISTS idx_refs_year ON bib_references(year);
CREATE INDEX IF NOT EXISTS idx_refs_project ON bib_references(project);
CREATE INDEX IF NOT EXISTS idx_refs_source ON bib_references(source_file);
"""


def create_vec_table(db: sqlite3.Connection, dim: int = 768):
    """Create sqlite-vec virtual table if extension is available."""
    try:
        import sqlite_vec
        db.enable_load_extension(True)
        sqlite_vec.load(db)
        db.enable_load_extension(False)

        db.execute(f"""
            CREATE VIRTUAL TABLE IF NOT EXISTS vec_chunks USING vec0(
                chunk_id INTEGER PRIMARY KEY,
                embedding float[{dim}]
            )
        """)
        db.execute(f"""
            CREATE VIRTUAL TABLE IF NOT EXISTS vec_references USING vec0(
                ref_rowid INTEGER PRIMARY KEY,
                embedding float[{dim}]
            )
        """)
        return True
    except ImportError:
        print("WARNING: sqlite-vec not installed. Vector search disabled.", file=sys.stderr)
        print("  Install with: pip install sqlite-vec", file=sys.stderr)
        return False
    except Exception as e:
        print(f"WARNING: sqlite-vec failed to load: {e}", file=sys.stderr)
        return False


def init_db(db_path: str, dim: int = 768) -> sqlite3.Connection:
    """Initialize the memory database with all tables and indexes."""
    db_file = Path(db_path)
    db_file.parent.mkdir(parents=True, exist_ok=True)

    db = sqlite3.connect(str(db_file))

    # PRAGMA settings
    db.execute("PRAGMA journal_mode = WAL")
    db.execute("PRAGMA busy_timeout = 5000")
    db.execute("PRAGMA synchronous = NORMAL")
    db.execute("PRAGMA foreign_keys = ON")

    # Core tables
    db.execute(SCHEMA_META_TABLE)
    db.execute(SESSIONS_TABLE)
    db.execute(OBSERVATIONS_TABLE)
    db.execute(DOCUMENTS_TABLE)
    db.execute(CHUNKS_TABLE)
    db.execute(REFERENCES_TABLE)

    # FTS5 virtual tables
    db.execute(FTS_CHUNKS)
    db.execute(FTS_OBSERVATIONS)
    db.execute(FTS_REFERENCES)

    # Triggers
    db.executescript(TRIGGERS_CHUNKS)
    db.executescript(TRIGGERS_OBSERVATIONS)

    # Indexes
    db.executescript(INDEXES)

    # Vector tables (optional)
    vec_ok = create_vec_table(db, dim)

    # Schema version
    db.execute(
        "INSERT OR REPLACE INTO schema_meta(key, value) VALUES (?, ?)",
        ["schema_version", str(SCHEMA_VERSION)]
    )
    db.execute(
        "INSERT OR REPLACE INTO schema_meta(key, value) VALUES (?, ?)",
        ["vec_enabled", "1" if vec_ok else "0"]
    )

    db.commit()
    return db


def main():
    parser = argparse.ArgumentParser(description="Initialize long-term memory DB")
    parser.add_argument(
        "--db-path", default=".claude/memory.db",
        help="Path to the SQLite database file (default: .claude/memory.db)"
    )
    parser.add_argument(
        "--dim", type=int, default=768,
        help="Embedding dimension (default: 768 for Ruri v3-310m)"
    )
    args = parser.parse_args()

    db = init_db(args.db_path, args.dim)

    # Print summary
    tables = db.execute(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    ).fetchall()

    vec_status = db.execute(
        "SELECT value FROM schema_meta WHERE key='vec_enabled'"
    ).fetchone()

    print(f"Memory DB initialized: {args.db_path}")
    print(f"  Tables: {len(tables)}")
    print(f"  Vector search: {'enabled' if vec_status and vec_status[0] == '1' else 'disabled'}")
    print(f"  Embedding dim: {args.dim}")

    db.close()


if __name__ == "__main__":
    main()
