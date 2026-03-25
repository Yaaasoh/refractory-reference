---
description: 公式ドキュメントを調査（設計・計画時の事前確認）
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
  - Write
  - Grep
  - Glob
  - Agent
argument-hint: "ツール名とトピック（例: LM Studio model.yaml）"
---

# 公式ドキュメント事前調査

## 対象

$ARGUMENTS

## 目的

**設計・計画・実装の前に**公式ドキュメントを確認し、正しい仕様・手順・制約を把握する。
推測で作業を開始することを防止する（INC-020 再発防止）。

## 実行手順

### 1. 公式ドキュメントの特定

対象ツール/サービスの公式ドキュメントURLを特定する:

| ツール | 公式ドキュメント |
|--------|----------------|
| LM Studio | https://lmstudio.ai/docs/ 、GitHub: lmstudio-ai/docs |
| llama.cpp | https://github.com/ggml-org/llama.cpp |
| Qwen | https://huggingface.co/Qwen/ 、https://qwen.readthedocs.io/ |
| Claude Code | https://code.claude.com/docs/ |

**ローカルに保存済みの調査資料があれば先に確認**:
- `work/research/local-llm-tools/lm_studio_research/` — LM Studio関連
- `work/research/local-llm-tools/lm_studio_research/websearch_results/` — 過去のWebSearch結果

### 2. 公式ドキュメントの取得・確認

WebFetchで公式ページを取得し、以下を抽出:
- **仕様**: パラメータ名、型、必須/任意、デフォルト値
- **制約**: 非対応機能、既知の制限事項
- **サンプルコード**: 公式の使用例
- **バージョン要件**: 対応バージョン

### 3. 結果の保存

**【絶対遵守】取得した情報は100%ファイルに保存する。**

保存先: 対象に応じた適切なディレクトリ
保存フォーマット:
```markdown
# 公式ドキュメント調査: [トピック]

## メタデータ
- 調査日: YYYY-MM-DD
- ソース: [URL]
- 対象バージョン: [バージョン]

## 仕様
[パラメータ、型、制約の詳細]

## サンプルコード
[公式の使用例]

## 制約・注意事項
[非対応機能、既知の制限]
```

### 4. 作業計画への反映

確認した仕様に基づいて:
- 正しいパラメータ名・フォーマットを使う
- 非対応機能を事前に把握する
- 公式サンプルコードをベースにする

## 注意事項

- **推測禁止**: 公式ドキュメントに記載がない場合は「記載なし」と明記する
- **保存義務**: WebSearch/WebFetch結果は全て保存する
- **事前確認**: 作業開始前に実行する（失敗してから調べるのは禁止）
