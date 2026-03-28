#!/usr/bin/env python3
"""
Compute embeddings for all chunks in the memory DB using Ruri v3-310m.

Two-stage approach to avoid segfault with sqlite-vec + sentence-transformers:
  Stage 1: compute_embeddings.py --stage compute  (sentence-transformers only)
  Stage 2: compute_embeddings.py --stage load      (sqlite-vec only)

Or run both stages sequentially:
  compute_embeddings.py  (default: runs both)

Usage:
    py -3.11 shared/scripts/memory-db/compute_embeddings.py --db-path .claude/memory.db
"""

import argparse
import os
import sqlite3
import struct
import subprocess
import sys
import time
from pathlib import Path


CACHE_DIR = ".claude"
IDS_FILE = "memory_chunk_ids.npy"
EMBS_FILE = "memory_chunk_embeddings.npy"


def serialize_f32(vector) -> bytes:
    """Convert numpy array to float32 bytes for sqlite-vec."""
    import numpy as np
    return vector.astype(np.float32).tobytes()


def stage_compute(db_path: str, batch_size: int = 8, model_name: str = "cl-nagoya/ruri-v3-310m",
                  prefix: str = "検索文書: ", cache_dir: str = CACHE_DIR):
    """Stage 1: Compute embeddings with sentence-transformers (NO sqlite-vec)."""
    import numpy as np
    sys.stdout.reconfigure(line_buffering=True)

    print("Stage 1: Computing embeddings (sentence-transformers only)", flush=True)

    if not Path(db_path).exists():
        print(f"  ERROR: DB not found: {db_path}", file=sys.stderr, flush=True)
        sys.exit(1)

    # Read chunks from DB (plain sqlite3, no extensions)
    db = sqlite3.connect(db_path)
    chunks = db.execute("SELECT id, content FROM chunks ORDER BY id").fetchall()
    db.close()
    print(f"  Chunks to embed: {len(chunks)}", flush=True)

    if not chunks:
        print("  No chunks found.", flush=True)
        return

    # Load model with CPU optimizations
    print(f"  Loading model: {model_name}...", flush=True)
    import torch
    torch.set_num_threads(min(os.cpu_count() or 4, 8))  # Cap at 8 to avoid contention
    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer(model_name, device="cpu")
    # Reduce max_seq_length: default 8192 is wasteful for short chunks
    # Attention is O(n^2), so 512 vs 8192 = ~256x less computation per token
    model.max_seq_length = 512
    print(f"  Model loaded. max_seq_length={model.max_seq_length}, threads={torch.get_num_threads()}", flush=True)

    # Resume from checkpoint if available
    checkpoint_ids = os.path.join(cache_dir, "checkpoint_ids.npy")
    checkpoint_embs = os.path.join(cache_dir, "checkpoint_embeddings.npy")
    all_ids = []
    all_embeddings = []
    start_idx = 0

    if os.path.exists(checkpoint_ids) and os.path.exists(checkpoint_embs):
        saved_ids = np.load(checkpoint_ids).tolist()
        saved_embs = np.load(checkpoint_embs).tolist()
        all_ids = saved_ids
        all_embeddings = saved_embs
        start_idx = len(saved_ids)
        print(f"  Resumed from checkpoint: {start_idx}/{len(chunks)} already computed", flush=True)

    # Compute in batches with periodic checkpointing
    CHECKPOINT_INTERVAL = 500  # Save every 500 chunks
    start = time.time()

    for i in range(start_idx, len(chunks), batch_size):
        batch = chunks[i:i + batch_size]
        texts = [f"{prefix}{c[1][:1024]}" for c in batch]

        embs = model.encode(
            texts,
            batch_size=batch_size,
            show_progress_bar=False,
            normalize_embeddings=True,
        )

        for (cid, _), emb in zip(batch, embs):
            all_ids.append(cid)
            all_embeddings.append(emb)

        done = len(all_ids)
        elapsed = time.time() - start

        # Periodic checkpoint (protects against crash/interruption)
        if done % CHECKPOINT_INTERVAL < batch_size and done > start_idx:
            np.save(checkpoint_ids, np.array(all_ids, dtype=np.int64))
            np.save(checkpoint_embs, np.array(all_embeddings, dtype=np.float32))
            rate = (done - start_idx) / max(elapsed, 0.1)
            print(f"  Checkpoint: {done}/{len(chunks)} ({rate:.1f}/sec, {elapsed:.0f}s)", flush=True)
        elif done % (batch_size * 12) < batch_size or done == len(chunks):
            rate = (done - start_idx) / max(elapsed, 0.1)
            print(f"  {done}/{len(chunks)} ({rate:.1f}/sec, {elapsed:.0f}s)", flush=True)

    elapsed = time.time() - start
    print(f"  Complete: {len(all_embeddings)} embeddings in {elapsed:.1f}s", flush=True)

    # Remove checkpoint files (no longer needed)
    for cp in [checkpoint_ids, checkpoint_embs]:
        try:
            os.remove(cp)
        except OSError:
            pass

    # Save to numpy files (primary)
    ids_path = os.path.join(cache_dir, IDS_FILE)
    embs_path = os.path.join(cache_dir, EMBS_FILE)
    np.save(ids_path, np.array(all_ids, dtype=np.int64))
    np.save(embs_path, np.array(all_embeddings, dtype=np.float32))
    print(f"  Saved: {ids_path}, {embs_path}", flush=True)

    # Create backup copies at MULTIPLE locations (multi-layer protection)
    import shutil

    # Backup 1: Project-local (.claude/embedding_backup/)
    backup_local = os.path.join(cache_dir, "embedding_backup")
    os.makedirs(backup_local, exist_ok=True)
    shutil.copy2(ids_path, os.path.join(backup_local, IDS_FILE))
    shutil.copy2(embs_path, os.path.join(backup_local, EMBS_FILE))
    print(f"  Backup 1 (local): {backup_local}/", flush=True)

    # Backup 2: User home (~/.claude/embedding_backup/<project>/)
    home_dir = os.path.expanduser("~")
    project_name = os.path.basename(os.path.abspath(cache_dir + "/.."))
    backup_home = os.path.join(home_dir, ".claude", "embedding_backup", project_name)
    os.makedirs(backup_home, exist_ok=True)
    shutil.copy2(ids_path, os.path.join(backup_home, IDS_FILE))
    shutil.copy2(embs_path, os.path.join(backup_home, EMBS_FILE))
    print(f"  Backup 2 (home):  {backup_home}/", flush=True)


def stage_load(db_path: str, cache_dir: str = CACHE_DIR):
    """Stage 2: Load precomputed embeddings into sqlite-vec (NO sentence-transformers)."""
    import numpy as np
    import sqlite_vec

    print("Stage 2: Loading embeddings into sqlite-vec")

    ids_path = os.path.join(cache_dir, IDS_FILE)
    embs_path = os.path.join(cache_dir, EMBS_FILE)

    if not os.path.exists(ids_path) or not os.path.exists(embs_path):
        import shutil
        restored = False

        # Try backup 1: project-local
        backup_local = os.path.join(cache_dir, "embedding_backup")
        if os.path.exists(os.path.join(backup_local, IDS_FILE)):
            print(f"  Restoring from local backup: {backup_local}/", flush=True)
            shutil.copy2(os.path.join(backup_local, IDS_FILE), ids_path)
            shutil.copy2(os.path.join(backup_local, EMBS_FILE), embs_path)
            restored = True

        # Try backup 2: user home
        if not restored:
            home_dir = os.path.expanduser("~")
            project_name = os.path.basename(os.path.abspath(cache_dir + "/.."))
            backup_home = os.path.join(home_dir, ".claude", "embedding_backup", project_name)
            if os.path.exists(os.path.join(backup_home, IDS_FILE)):
                print(f"  Restoring from home backup: {backup_home}/", flush=True)
                shutil.copy2(os.path.join(backup_home, IDS_FILE), ids_path)
                shutil.copy2(os.path.join(backup_home, EMBS_FILE), embs_path)
                restored = True

        if not restored:
            print(f"  ERROR: No cache files or backups found.", file=sys.stderr)
            print(f"    Primary: {ids_path}", file=sys.stderr)
            print(f"    Backup1: {backup_local}/", file=sys.stderr)
            print(f"    Re-run with: --stage compute", file=sys.stderr)
            sys.exit(1)

    ids = np.load(ids_path)
    embeddings = np.load(embs_path)
    print(f"  Loaded: {len(ids)} embeddings, shape {embeddings.shape}")

    # Open DB with sqlite-vec
    db = sqlite3.connect(db_path)
    db.enable_load_extension(True)
    sqlite_vec.load(db)
    db.enable_load_extension(False)

    # Ensure vec table exists
    db.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS vec_chunks USING vec0(
            chunk_id INTEGER PRIMARY KEY,
            embedding float[768]
        )
    """)

    # Check and warn about existing data
    existing = db.execute("SELECT count(*) FROM vec_chunks").fetchone()[0]
    if existing > 0:
        print(f"  WARNING: vec_chunks has {existing} existing rows. Clearing before insert.")
        db.execute("DELETE FROM vec_chunks")
        db.commit()

    # Insert embeddings
    count = 0
    for chunk_id, emb in zip(ids, embeddings):
        db.execute(
            "INSERT INTO vec_chunks(chunk_id, embedding) VALUES (?, ?)",
            [int(chunk_id), emb.astype(np.float32).tobytes()]
        )
        count += 1
        if count % 500 == 0:
            db.commit()
            print(f"  {count}/{len(ids)} inserted", flush=True)

    # Update metadata
    db.execute(
        "INSERT OR REPLACE INTO schema_meta(key, value) VALUES (?, ?)",
        ["vec_enabled", "1"]
    )
    db.execute(
        "INSERT OR REPLACE INTO schema_meta(key, value) VALUES (?, ?)",
        ["embedding_model", "cl-nagoya/ruri-v3-310m"]
    )
    db.commit()

    total = db.execute("SELECT count(*) FROM vec_chunks").fetchone()[0]
    print(f"  Inserted: {count}, Total in vec_chunks: {total}")
    db.close()

    # Clean up PRIMARY cache files ONLY after successful insertion
    # Backup copies are retained in embedding_backup/ for safety
    for path in [ids_path, embs_path]:
        try:
            os.remove(path)
        except OSError:
            pass
    print("  Cleaned up primary cache files (backup retained)")


def main():
    parser = argparse.ArgumentParser(description="Compute embeddings for memory DB")
    parser.add_argument("--db-path", default=".claude/memory.db", help="DB path")
    parser.add_argument("--batch-size", type=int, default=8, help="Batch size")
    parser.add_argument("--model", default="cl-nagoya/ruri-v3-310m", help="Model name")
    parser.add_argument("--stage", choices=["compute", "load", "both"], default="both",
                        help="Which stage to run")
    args = parser.parse_args()

    if args.stage in ("compute", "both"):
        stage_compute(args.db_path, args.batch_size, args.model)

    if args.stage == "both":
        # Verify Stage 1 output exists before launching Stage 2
        ids_path = os.path.join(CACHE_DIR, IDS_FILE)
        embs_path = os.path.join(CACHE_DIR, EMBS_FILE)
        if not os.path.exists(ids_path) or not os.path.exists(embs_path):
            print(f"ERROR: Stage 1 output not found. Expected:", file=sys.stderr)
            print(f"  {ids_path}", file=sys.stderr)
            print(f"  {embs_path}", file=sys.stderr)
            sys.exit(1)

        # Run stage 2 in a separate process to avoid segfault
        print("\nLaunching Stage 2 in separate process...")
        result = subprocess.run(
            [sys.executable, __file__, "--db-path", args.db_path, "--stage", "load"],
            capture_output=False,
        )
        if result.returncode != 0:
            print("Stage 2 failed! Cache files preserved for retry:", file=sys.stderr)
            print(f"  {ids_path}", file=sys.stderr)
            print(f"  {embs_path}", file=sys.stderr)
            print("  Retry with: --stage load", file=sys.stderr)
            sys.exit(1)
    elif args.stage == "load":
        stage_load(args.db_path)


if __name__ == "__main__":
    main()
