CREATE TABLE bib_references (
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

CREATE TABLE chunks (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    doc_id      INTEGER REFERENCES documents(id) ON DELETE CASCADE,
    section     TEXT,
    content     TEXT NOT NULL,
    source_file TEXT,
    doc_type    TEXT,
    created_at  TEXT DEFAULT (datetime('now'))
);

CREATE TABLE documents (
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

CREATE TABLE observations (
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

CREATE TABLE schema_meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

CREATE TABLE sessions (
    id          TEXT PRIMARY KEY,
    project     TEXT NOT NULL,
    directory   TEXT NOT NULL,
    started_at  TEXT NOT NULL DEFAULT (datetime('now')),
    ended_at    TEXT,
    summary     TEXT
);

