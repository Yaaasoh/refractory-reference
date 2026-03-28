# Memory-DB セットアップガイド

セッション横断の長期記憶システム。Markdown/BibTeX/テキストをチャンク分割しSQLiteに格納、FTS5全文検索+sqlite-vecベクトル検索のハイブリッド検索を提供する。

## 前提条件

- Python 3.11+
- py launcher（Windows）または python3（Linux/macOS/リモート環境）
  - リモート環境では `CLAUDE_CODE_REMOTE=true` を設定するとhookが自動的に `python3` を使用する
- 以下のコマンドはすべてリポジトリルートから実行すること

## 1. インストール

```bash
# 基本パッケージ（検索・同期に必要）
py -3.11 -m pip install -r .claude/scripts/memory-db/requirements-memory.txt

# フルパッケージ（embedding計算も行う場合）
py -3.11 -m pip install -r .claude/scripts/memory-db/requirements-memory-full.txt
```

**依存関係**:
- 基本: sqlite-vec, sqlite-utils, bibtexparser, rapidfuzz
- フル: 上記 + sentence-transformers, numpy

## 2. 初回セットアップ

### 2-1. `.gitignore` 設定

以下をリポジトリの `.gitignore` に追加する:

```gitignore
# Long-term memory DB (rebuilt from NDJSON)
.claude/memory.db
.claude/memory.db-wal
.claude/memory.db-shm
# Embedding cache (local only, expensive to recompute)
.claude/memory_chunk_ids.npy
.claude/memory_chunk_embeddings.npy
.claude/embedding_backup/
# .claude/memory-data/*.ndjson はgit管理対象（削除しない）
```

### 2-2. DB初期化とインポート

```bash
# Step 1: DBスキーマ作成
py -3.11 .claude/scripts/memory-db/init_db.py --db-path .claude/memory.db

# Step 2: 既存ファイルのインポート
py -3.11 .claude/scripts/memory-db/import_existing.py \
    --db-path .claude/memory.db \
    --dirs work/ research/ \
    --project <リポジトリ名>

# Step 3: embedding計算（オプション、ベクトル検索に必要）
# GPU推奨（CPU比35倍高速）
py -3.11 .claude/scripts/memory-db/compute_embeddings_gpu.py \
    --db-path .claude/memory.db
# GPUなしの場合（低速: 0.5 chunks/sec）
py -3.11 .claude/scripts/memory-db/compute_embeddings.py \
    --db-path .claude/memory.db
```

注: `memory_db_sync.sh` hookは `.md/.bib/.txt` ファイル書き込み時にDBが存在しない場合、自動初期化する。手動のStep 1はhook有効化前の初期インポートが目的。

### `--dirs` の指定

リポジトリの構造に合わせてスキャン対象を指定する。

| リポジトリ例 | 推奨 `--dirs` |
|-------------|--------------|
| prompt-patterns | `work/ research/ incidents/` |
| tech-articles | `work/ research/ content/ bibliography/` |
| 構造が不明な場合 | `.`（全ディレクトリスキャン） |

除外パターン（自動適用）: `node_modules`, `.git`, `__pycache__`, `.venv`, `.claude/worktrees`

追加の除外: `--exclude build/ dist/`

## 3. 日常運用（Hook自動処理）

4つのhookがsettings.jsonに登録されていれば、日常運用は全自動。

| イベント | Hook | 動作 |
|---------|------|------|
| SessionStart | `memory_db_rebuild.sh` | DB不在時にNDJSONから自動再構築 |
| PostToolUse (Write/Edit) | `memory_db_sync.sh` | .md/.bib/.txt変更時にDBに即座同期 |
| Stop | `memory_db_export.sh` | セッション終了時にDBをNDJSONへエクスポート |
| PreToolUse (Bash) | `protect_embeddings.sh` | .npy/.npzファイルの誤削除をブロック |

### settings.json登録

既存のsettings.jsonにhookを追加する場合は、各イベントの既存エントリに**マージ**する（置換しない）。

```json
// SessionStart: 既存の hooks 配列に追加
{ "type": "command", "command": "bash .claude/hooks/memory_db_rebuild.sh", "timeout": 15 }

// PostToolUse: matcher "Write|Edit" で新規エントリ追加
{
  "matcher": "Write|Edit",
  "hooks": [{ "type": "command", "command": "bash .claude/hooks/memory_db_sync.sh", "timeout": 10 }]
}

// Stop: 既存の hooks 配列に追加
{ "type": "command", "command": "bash .claude/hooks/memory_db_export.sh", "timeout": 30 }

// PreToolUse: 既存の matcher "Bash" の hooks 配列に追加
{ "type": "command", "command": "bash .claude/hooks/protect_embeddings.sh", "timeout": 5 }
```

## 4. 検索

```bash
# FTS5全文検索
py -3.11 .claude/scripts/memory-db/search.py \
    --query "キーワード" \
    --db-path .claude/memory.db

# ベクトル検索（embedding計算済みの場合）
py -3.11 .claude/scripts/memory-db/search.py \
    --query "意味的に近い文章" \
    --db-path .claude/memory.db \
    --mode hybrid
```

## 5. データの流れ

```
[.md/.bib/.txt ファイル]
        │
        ▼ (sync_to_db.py / import_existing.py)
   [memory.db]  ← SQLite + FTS5 + sqlite-vec
        │
        ▼ (export_ndjson.py / Stop hook)
[.claude/memory-data/*.ndjson]  ← git管理対象（テキスト形式）
        │
        ▼ (rebuild_db.py / SessionStart hook)
   [memory.db]  ← clone後に自動再構築
```

**重要**: `memory.db` は `.gitignore` 対象（バイナリ）。NDJSONがgit管理の正本。

## 6. トラブルシューティング

| 症状 | 対処 |
|------|------|
| clone後にDBがない | SessionStart hookが自動rebuild。手動: `py -3.11 .claude/scripts/memory-db/rebuild_db.py --data-dir .claude/memory-data --db-path .claude/memory.db` |
| exportが動かない | `ls .claude/memory.db` でDB存在確認。Stop hookのtimeoutを確認 |
| embeddingがない | `compute_embeddings_gpu.py` を再実行。VRAM 6GB以上推奨 |
| sqlite-vec segfault | sentence-transformersと同一プロセスで使わない。Stage 1: `compute_embeddings_gpu.py --stage compute` でembeddingを `.npy` に保存、Stage 2: `compute_embeddings_gpu.py --stage load` でsqlite-vecにロード。`--stage both` は使用しない |
| `--dirs .` で大量ファイル | `--exclude` で不要ディレクトリを追加除外 |

## 7. ファイル一覧

| ファイル | 役割 |
|---------|------|
| `.claude/scripts/memory-db/init_db.py` | DBスキーマ作成 |
| `.claude/scripts/memory-db/sync_to_db.py` | 単一ファイル同期 |
| `.claude/scripts/memory-db/import_existing.py` | バッチインポート |
| `.claude/scripts/memory-db/export_ndjson.py` | DB→NDJSONエクスポート |
| `.claude/scripts/memory-db/rebuild_db.py` | NDJSON→DB再構築 |
| `.claude/scripts/memory-db/search.py` | 検索インターフェース |
| `.claude/scripts/memory-db/compute_embeddings.py` | CPU embedding計算 |
| `.claude/scripts/memory-db/compute_embeddings_gpu.py` | GPU embedding計算 |
| `.claude/scripts/memory-db/requirements-memory.txt` | 基本依存関係 |
| `.claude/scripts/memory-db/requirements-memory-full.txt` | フル依存関係 |
| `.claude/hooks/memory_db_rebuild.sh` | SessionStart hook |
| `.claude/hooks/memory_db_sync.sh` | PostToolUse hook |
| `.claude/hooks/memory_db_export.sh` | Stop hook |
| `.claude/hooks/protect_embeddings.sh` | PreToolUse hook |
