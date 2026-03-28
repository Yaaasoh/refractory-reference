---
description: 調査セッションを開始
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
  - WebSearch
  - WebFetch
  - TodoWrite
argument-hint: "調査テーマ（例: Claude Code Hooks）"
---

# 調査セッション開始

## 対象テーマ

$ARGUMENTS

## 実行手順

### 1. 安全確認（必須）

まず `git status` でUntracked/変更ファイルを確認し、既存作業がないか確認してください。

### 2. セッションディレクトリ作成

以下の構造でディレクトリを作成:

```
work/research/session_YYYYMMDD_[テーマ名]/
├── SESSION_PLAN.md
├── websearch_results/
│   └── [対象別ディレクトリ]/
│       └── NN_topic.md
└── SESSION_COMPLETION_REPORT.md (完了時)
```

### 3. SESSION_PLAN.md作成

以下の内容を含む計画書を作成:
- セッションID
- 目的（1-2文）
- 対象トピック
- 作業計画
- 品質基準
- 成功基準

### 4. WebSearch実施（重要）

**【絶対遵守】WebSearch 100%保存義務**

```
WebSearch実行回数 = 保存ファイル数（100%保存必須）
```

各WebSearch結果は以下を含めて保存:
- WebSearch実施日
- 検索クエリ
- 情報源URL
- 抽出情報（要約ではなく具体的なデータ）

**保存先**: `websearch_results/[対象]/NN_topic.md`

**保存フォーマット例**:
```markdown
# WebSearch結果: [トピック]

## メタデータ
- 検索日: YYYY-MM-DD
- 検索クエリ: "[クエリ]"
- 情報源: [URL]

## 抽出情報

### 概要
[主要な情報]

### 詳細データ
[具体的なデータ・数値]
```

### 5. 完了報告

SESSION_COMPLETION_REPORT.md を作成:
- 実施内容
- 成果物サマリー
- 品質評価
- 課題・改善点
- 次のステップ

## 品質基準

- **WebSearch結果**: 100%保存（実行回数 = 保存ファイル数）
- **詳細度**: 平均100行以上/ファイル
- **索引**: websearch_results/README.md作成

## 調査範囲

このリポジトリおよび関連する外部情報を対象とします。

## 注意事項

- 公式ドキュメントを最優先で確認すること
- 推測ではなく、確認した事実に基づいて報告すること
- 不明点は明示すること
- **WebSearch結果を捨てないこと**（過去のインシデント教訓）
