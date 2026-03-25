---
description: エラー・問題発生時に公式ドキュメントとユーザー事例を調査
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
  - Write
  - Grep
  - Glob
  - Bash
  - Agent
argument-hint: "エラー内容（例: HTTP 403 Permission denied mcp/filesystem）"
---

# エラー・問題調査

## 対象エラー

$ARGUMENTS

## 目的

エラーや問題が発生した際に、推測で修正を試みず、公式ドキュメントとユーザー事例を調査して正しい解決策を特定する。

## 実行手順

### 1. エラー情報の収集

まず以下を正確に記録する:
- エラーメッセージ全文
- 発生したコマンド/APIリクエスト
- 環境情報（ツールバージョン、OS等）

### 2. 公式ドキュメントの確認

エラーメッセージのキーワードで公式ドキュメントを検索:

```
WebSearch: "[ツール名] [エラーメッセージのキーワード] site:公式ドメイン"
```

確認すべき公式ソース:
| ツール | ドキュメント | バグトラッカー |
|--------|-------------|---------------|
| LM Studio | lmstudio.ai/docs | github.com/lmstudio-ai/lmstudio-bug-tracker |
| llama.cpp | github.com/ggml-org/llama.cpp | 同上Issues |
| Qwen | qwen.readthedocs.io | github.com/QwenLM |

### 3. ユーザー事例の調査

公式ドキュメントで解決しない場合、ユーザー事例を検索:

```
WebSearch: "[ツール名] [エラーメッセージ] site:github.com"
WebSearch: "[ツール名] [エラーメッセージ] 2025 2026"
WebSearch: "[ツール名] [エラーメッセージ] workaround fix"
```

確認すべきソース:
- GitHub Issues（公式バグトラッカー）
- GitHub Discussions
- Stack Overflow
- Reddit r/LocalLLaMA
- HuggingFace Discussions

### 4. 結果の保存

**【絶対遵守】調査結果は100%ファイルに保存する。**

保存先: 対象に応じた適切なディレクトリ
保存フォーマット:
```markdown
# エラー調査: [エラー概要]

## メタデータ
- 調査日: YYYY-MM-DD
- エラーメッセージ: [全文]
- 発生環境: [ツール、バージョン、OS]

## 公式ドキュメントの記載
- [URL]: [関連する記述]

## ユーザー事例
- [Issue/URL]: [報告内容と解決策]

## 原因
[特定された原因]

## 解決策
[公式推奨の解決策、または確認された回避策]

## 未解決の場合
[不明点、追加調査が必要な項目]
```

### 5. 解決策の適用

調査結果に基づいて修正を実施する。
**推測による修正は禁止。** 公式ドキュメントまたはユーザー事例で確認された方法のみ使用する。

## 注意事項

- **エラーメッセージを全文読む**（evidence-based-thinking原則）
- **推測で修正しない**: 「多分これが原因だろう」で修正を試みない
- **保存義務**: 調査結果は全てファイルに保存する
- **同じエラーの再調査防止**: 過去の調査結果を先に確認する
  - `work/research/local-llm-tools/lm_studio_research/websearch_results/` を先にGrep
