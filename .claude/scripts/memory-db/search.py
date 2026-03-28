#!/usr/bin/env python3
"""
Hybrid search module for the long-term memory DB.

Supports:
- FTS5 trigram full-text search (Japanese-friendly)
- sqlite-vec vector search (when embeddings available)
- RRF (Reciprocal Rank Fusion) for combining results

Usage:
    from search import hybrid_search, fts_search
    results = fts_search(db, "deploy.sh公開リポジトリ")
    results = hybrid_search(db, "BOMインシデント", query_embedding)
"""

import sqlite3
import sys
from typing import Optional


VALID_FTS_TABLES = {"fts_chunks", "fts_observations", "fts_references"}
VALID_VEC_TABLES = {"vec_chunks", "vec_references"}
VALID_ID_COLS = {"chunk_id", "ref_rowid"}


def fts_search(
    db: sqlite3.Connection,
    query: str,
    table: str = "fts_chunks",
    k: int = 20,
) -> list[dict]:
    """
    FTS5 trigram search.

    Args:
        db: Database connection
        query: Search query text
        table: FTS5 table name (fts_chunks, fts_observations, fts_references)
        k: Max results

    Returns:
        List of {rowid, rank} dicts ordered by relevance
    """
    if table not in VALID_FTS_TABLES:
        raise ValueError(f"Invalid FTS table: {table}")
    try:
        rows = db.execute(
            f"SELECT rowid, rank FROM {table} WHERE {table} MATCH ? ORDER BY rank LIMIT ?",
            [query, k]
        ).fetchall()
        return [{"rowid": r[0], "rank": r[1]} for r in rows]
    except sqlite3.OperationalError as e:
        print(f"FTS search error: {e}", file=sys.stderr)
        return []


def vec_search(
    db: sqlite3.Connection,
    query_embedding: bytes,
    table: str = "vec_chunks",
    id_col: str = "chunk_id",
    k: int = 20,
) -> list[dict]:
    """
    sqlite-vec KNN search.

    Args:
        db: Database connection
        query_embedding: Query vector as float32 bytes
        table: vec0 table name
        id_col: Primary key column name
        k: Max results

    Returns:
        List of {rowid, distance} dicts ordered by distance
    """
    if table not in VALID_VEC_TABLES:
        raise ValueError(f"Invalid vec table: {table}")
    if id_col not in VALID_ID_COLS:
        raise ValueError(f"Invalid id_col: {id_col}")
    try:
        rows = db.execute(
            f"SELECT {id_col}, distance FROM {table} "
            f"WHERE embedding MATCH ? AND k = ? ORDER BY distance",
            [query_embedding, k]
        ).fetchall()
        return [{"rowid": r[0], "distance": r[1]} for r in rows]
    except sqlite3.OperationalError as e:
        print(f"Vector search error: {e}", file=sys.stderr)
        return []


def rrf_merge(
    fts_results: list[dict],
    vec_results: list[dict],
    rrf_k: int = 60,
    weight_fts: float = 1.0,
    weight_vec: float = 1.0,
) -> list[tuple[int, float]]:
    """
    Reciprocal Rank Fusion to combine FTS5 and vector search results.

    Args:
        fts_results: FTS5 results with 'rowid' key
        vec_results: Vector results with 'rowid' key
        rrf_k: RRF constant (default 60)
        weight_fts: FTS weight
        weight_vec: Vector weight

    Returns:
        List of (rowid, rrf_score) tuples sorted by score descending
    """
    scores: dict[int, float] = {}

    for rank, r in enumerate(fts_results):
        rid = r["rowid"]
        scores[rid] = scores.get(rid, 0.0) + weight_fts / (rrf_k + rank + 1)

    for rank, r in enumerate(vec_results):
        rid = r["rowid"]
        scores[rid] = scores.get(rid, 0.0) + weight_vec / (rrf_k + rank + 1)

    return sorted(scores.items(), key=lambda x: x[1], reverse=True)


def hybrid_search(
    db: sqlite3.Connection,
    query: str,
    query_embedding: Optional[bytes] = None,
    k: int = 20,
    rrf_k: int = 60,
    weight_fts: float = 1.0,
    weight_vec: float = 1.0,
    source: str = "chunks",
) -> list[dict]:
    """
    Hybrid search combining FTS5 and vector search with RRF.

    Args:
        db: Database connection
        query: Search query text
        query_embedding: Query vector as float32 bytes (None = FTS only)
        k: Max results
        rrf_k: RRF constant
        weight_fts: FTS weight
        weight_vec: Vector weight
        source: "chunks" or "observations" or "references"

    Returns:
        List of result dicts with content and metadata
    """
    # Table mapping with validation
    VEC_SOURCES = {
        "chunks": ("vec_chunks", "chunk_id"),
        "references": ("vec_references", "ref_rowid"),
        # observations: FTS only (no vec table — structured memories use keyword search)
    }
    fts_table = f"fts_{source}"
    main_table = source if source != "references" else "bib_references"

    # FTS5 search
    fts_results = fts_search(db, query, fts_table, k)

    # Vector search (only for sources with vec tables)
    vec_results = []
    if query_embedding is not None and source in VEC_SOURCES:
        vec_table, id_col = VEC_SOURCES[source]
        vec_results = vec_search(db, query_embedding, vec_table, id_col, k)

    # Merge
    if vec_results:
        merged = rrf_merge(fts_results, vec_results, rrf_k, weight_fts, weight_vec)
    else:
        merged = [(r["rowid"], abs(r["rank"])) for r in fts_results]

    # Fetch content
    results = []
    for rowid, score in merged[:k]:
        if source == "chunks":
            row = db.execute(
                "SELECT content, source_file, doc_type, section FROM chunks WHERE id = ?",
                [rowid]
            ).fetchone()
            if row:
                results.append({
                    "chunk_id": rowid,
                    "score": score,
                    "content": row[0],
                    "source_file": row[1],
                    "doc_type": row[2],
                    "section": row[3],
                })
        elif source == "observations":
            row = db.execute(
                "SELECT title, content, type, project, topic_key FROM observations WHERE id = ?",
                [rowid]
            ).fetchone()
            if row:
                results.append({
                    "observation_id": rowid,
                    "score": score,
                    "title": row[0],
                    "content": row[1],
                    "type": row[2],
                    "project": row[3],
                    "topic_key": row[4],
                })
        elif source == "references":
            row = db.execute(
                "SELECT key, title, author, year, journal, abstract FROM bib_references WHERE rowid = ?",
                [rowid]
            ).fetchone()
            if row:
                results.append({
                    "ref_key": row[0],
                    "score": score,
                    "title": row[1],
                    "author": row[2],
                    "year": row[3],
                    "journal": row[4],
                    "abstract": row[5],
                })

    return results


def search_all(
    db: sqlite3.Connection,
    query: str,
    query_embedding: Optional[bytes] = None,
    k: int = 10,
) -> dict[str, list[dict]]:
    """
    Search across all sources (chunks, observations, references).

    Returns dict with keys 'chunks', 'observations', 'references'.
    """
    return {
        "chunks": hybrid_search(db, query, query_embedding, k, source="chunks"),
        "observations": hybrid_search(db, query, query_embedding, k, source="observations"),
        "references": hybrid_search(db, query, query_embedding, k, source="references"),
    }


def main():
    """CLI entry point for search."""
    import argparse
    import json

    parser = argparse.ArgumentParser(description="Search the long-term memory DB")
    parser.add_argument("--query", "-q", required=True, help="Search query")
    parser.add_argument("--db-path", default=".claude/memory.db", help="DB path")
    parser.add_argument("--limit", "-k", type=int, default=10, help="Max results")
    parser.add_argument("--source", choices=["chunks", "observations", "references", "all"],
                        default="chunks", help="Search source (default: chunks)")
    parser.add_argument("--mode", choices=["fts", "hybrid"], default="fts",
                        help="Search mode (default: fts)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    db = sqlite3.connect(args.db_path)

    # sqlite_vec is only needed for hybrid/vector search
    try:
        import sqlite_vec
        db.enable_load_extension(True)
        sqlite_vec.load(db)
        db.enable_load_extension(False)
    except ImportError:
        if args.mode == "hybrid":
            print("ERROR: sqlite_vec not installed. Use --mode fts or install requirements-memory.txt",
                  file=sys.stderr)
            db.close()
            sys.exit(1)

    if args.mode == "hybrid":
        print("NOTE: --mode hybrid without pre-computed embeddings falls back to FTS only.",
              file=sys.stderr)

    try:
        if args.source == "all":
            results = search_all(db, args.query, k=args.limit)
            total = sum(len(v) for v in results.values())
            if args.json:
                print(json.dumps(results, ensure_ascii=False, indent=2))
            else:
                for source, items in results.items():
                    if items:
                        print(f"\n=== {source} ({len(items)} results) ===")
                        for r in items:
                            _print_result(r, source)
                print(f"\nTotal: {total} results")
        else:
            results = hybrid_search(db, args.query, k=args.limit, source=args.source)
            if args.json:
                print(json.dumps(results, ensure_ascii=False, indent=2))
            else:
                print(f"=== {args.source} ({len(results)} results) ===")
                for r in results:
                    _print_result(r, args.source)
    finally:
        db.close()


def _print_result(r: dict, source: str):
    """Format and print a single search result."""
    if source == "chunks":
        print(f"\n  [{r.get('score', 0):.4f}] {r.get('source_file', '?')}")
        print(f"  Section: {r.get('section', '?')}")
        content = r.get("content", "")
        print(f"  {content[:200]}{'...' if len(content) > 200 else ''}")
    elif source == "observations":
        print(f"\n  [{r.get('score', 0):.4f}] {r.get('title', '?')} ({r.get('type', '?')})")
        content = r.get("content", "")
        print(f"  {content[:200]}{'...' if len(content) > 200 else ''}")
    elif source == "references":
        print(f"\n  [{r.get('score', 0):.4f}] {r.get('ref_key', '?')}: {r.get('title', '?')}")
        print(f"  {r.get('author', '?')} ({r.get('year', '?')})")


if __name__ == "__main__":
    main()
