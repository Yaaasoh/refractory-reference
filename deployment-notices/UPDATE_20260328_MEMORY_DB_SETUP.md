# Memory-DB 初回セットアップ通知

**日付**: 2026-03-28
**対象**: memory-db がデプロイされた全リポジトリ

## 概要

長期記憶DB（memory-db）がデプロイされました。セッション横断の知識蓄積と検索が可能になります。

## 必要な初回セットアップ

以下をこのリポジトリで **1回だけ** 実行してください:

### Step 1: DB初期化

```bash
py -3.11 .claude/scripts/memory-db/init_db.py --db-path .claude/memory.db
```

### Step 2: 既存ファイルのインポート

```bash
# --dirs にはこのリポジトリの主要ディレクトリを指定
# 例: work/ research/ content/ （リポジトリ構造に合わせて調整）
py -3.11 .claude/scripts/memory-db/import_existing.py \
    --db-path .claude/memory.db \
    --dirs work/ research/ \
    --project <リポジトリ名>
```

### Step 3: NDJSON export（git管理用）

```bash
py -3.11 .claude/scripts/memory-db/export_ndjson.py \
    --db-path .claude/memory.db \
    --out-dir .claude/memory-data/
```

### Step 4: コミット

```bash
git add .claude/memory-data/
git commit -m "feat: memory-db初回セットアップ"
```

## 検索の使い方

```bash
py -3.11 .claude/scripts/memory-db/search.py \
    --db-path .claude/memory.db \
    --query "検索キーワード" --limit 10
```

## 自動同期

セットアップ後、以下のhookが自動動作します:
- **SessionStart**: NDJSONからDBを自動rebuild
- **PostToolUse (Write/Edit)**: .md/.bib/.txt ファイル変更時にDBを自動更新
- **Stop**: セッション終了時にNDJSON export

## 参照

- `.claude/docs/guides/memory-db-setup-guide.md` — 詳細ガイド
