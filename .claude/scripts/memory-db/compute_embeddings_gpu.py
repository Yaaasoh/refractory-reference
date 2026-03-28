#!/usr/bin/env python3
"""
GPU-accelerated embedding computation for memory DB using Ruri v3-310m.

Requires: CUDA-capable GPU (tested: RTX 3060 6GB VRAM)
Expected: 4,728 chunks in 10-25 seconds (vs ~2 hours on CPU)

Two-stage approach to avoid segfault with sqlite-vec + sentence-transformers:
  Stage 1 (this script): GPU embedding computation -> .npy files
  Stage 2 (compute_embeddings.py --stage load): Load .npy into sqlite-vec

Usage:
    py -3.11 shared/scripts/memory-db/compute_embeddings_gpu.py --db-path .claude/memory.db
    py -3.11 shared/scripts/memory-db/compute_embeddings.py --db-path .claude/memory.db --stage load
"""

import argparse
import os
import sqlite3
import sys
import time
from pathlib import Path

# Shared constants with CPU version
CACHE_DIR = ".claude"
IDS_FILE = "memory_chunk_ids.npy"
EMBS_FILE = "memory_chunk_embeddings.npy"


def stage_compute_gpu(db_path: str, batch_size: int = 64,
                      model_name: str = "cl-nagoya/ruri-v3-310m",
                      prefix: str = "検索文書: ", cache_dir: str = CACHE_DIR):
    """Stage 1 (GPU): Compute embeddings with CUDA acceleration."""
    import numpy as np
    import torch
    sys.stdout.reconfigure(line_buffering=True)

    # Verify CUDA
    if not torch.cuda.is_available():
        print("ERROR: CUDA not available. Use compute_embeddings.py (CPU version) instead.",
              file=sys.stderr, flush=True)
        sys.exit(1)

    gpu_name = torch.cuda.get_device_name(0)
    vram_mb = torch.cuda.get_device_properties(0).total_memory / 1024 / 1024
    print(f"GPU: {gpu_name} ({vram_mb:.0f} MB VRAM)", flush=True)
    print(f"Stage 1 (GPU): Computing embeddings with CUDA", flush=True)

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

    # Load model on GPU with FP16
    print(f"  Loading model: {model_name} (cuda, fp16)...", flush=True)
    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer(model_name, device="cuda")
    model.max_seq_length = 512
    # Convert to FP16 for ~2x speedup on consumer GPUs
    model.half()
    print(f"  Model loaded. max_seq_length={model.max_seq_length}, dtype=float16", flush=True)

    # Prepare texts
    texts = [f"{prefix}{c[1][:1024]}" for c in chunks]
    all_ids = [c[0] for c in chunks]

    # Encode all at once (GPU handles large batches efficiently)
    print(f"  Encoding {len(texts)} chunks (batch_size={batch_size})...", flush=True)
    start = time.time()

    embeddings = model.encode(
        texts,
        batch_size=batch_size,
        show_progress_bar=True,
        normalize_embeddings=True,
        convert_to_numpy=True,
    )

    # Ensure float32 for sqlite-vec compatibility (encode returns float32 even with fp16 model)
    embeddings = embeddings.astype(np.float32)

    elapsed = time.time() - start
    rate = len(texts) / max(elapsed, 0.01)
    print(f"  Complete: {len(embeddings)} embeddings in {elapsed:.1f}s ({rate:.0f} chunks/sec)", flush=True)
    print(f"  Shape: {embeddings.shape}, dtype: {embeddings.dtype}", flush=True)

    # Free GPU memory
    del model
    torch.cuda.empty_cache()

    # Save to numpy files (same format as CPU version)
    ids_path = os.path.join(cache_dir, IDS_FILE)
    embs_path = os.path.join(cache_dir, EMBS_FILE)
    np.save(ids_path, np.array(all_ids, dtype=np.int64))
    np.save(embs_path, embeddings)
    print(f"  Saved: {ids_path} ({os.path.getsize(ids_path) / 1024:.0f} KB)", flush=True)
    print(f"  Saved: {embs_path} ({os.path.getsize(embs_path) / 1024 / 1024:.1f} MB)", flush=True)

    # Create backup copies (same as CPU version)
    import shutil

    # Backup 1: Project-local
    backup_local = os.path.join(cache_dir, "embedding_backup")
    os.makedirs(backup_local, exist_ok=True)
    shutil.copy2(ids_path, os.path.join(backup_local, IDS_FILE))
    shutil.copy2(embs_path, os.path.join(backup_local, EMBS_FILE))
    print(f"  Backup 1 (local): {backup_local}/", flush=True)

    # Backup 2: User home
    home_dir = os.path.expanduser("~")
    project_name = os.path.basename(os.path.abspath(cache_dir + "/.."))
    backup_home = os.path.join(home_dir, ".claude", "embedding_backup", project_name)
    os.makedirs(backup_home, exist_ok=True)
    shutil.copy2(ids_path, os.path.join(backup_home, IDS_FILE))
    shutil.copy2(embs_path, os.path.join(backup_home, EMBS_FILE))
    print(f"  Backup 2 (home):  {backup_home}/", flush=True)

    print(f"\nNext step: load into sqlite-vec with:", flush=True)
    print(f"  py -3.11 shared/scripts/memory-db/compute_embeddings.py --db-path {db_path} --stage load", flush=True)


def main():
    parser = argparse.ArgumentParser(
        description="GPU-accelerated embedding computation for memory DB")
    parser.add_argument("--db-path", default=".claude/memory.db", help="DB path")
    parser.add_argument("--batch-size", type=int, default=64,
                        help="Batch size (GPU default: 64, adjust for VRAM)")
    parser.add_argument("--model", default="cl-nagoya/ruri-v3-310m", help="Model name")
    args = parser.parse_args()

    stage_compute_gpu(args.db_path, args.batch_size, args.model)


if __name__ == "__main__":
    main()
