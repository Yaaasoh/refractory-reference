# UPDATE: ローカルLLM調査エージェント D3-5〜D3-9 完了

**日付**: 2026-03-25
**対象**: 全リポジトリ
**種類**: mcp_runner.py更新 + 新コマンド追加

## 概要

ローカルLLM調査エージェント（mcp_runner.py）のD3-5〜D3-9が完了しました。
3専門家レビュー（セキュリティ/運用/テスト品質）で指摘された42件を全て対応済みです。

## 主な変更

### mcp_runner.py の改善（D3-6〜D3-9）

| 改善 | 内容 |
|------|------|
| thinking制御 | Stateful API `reasoning=off`でQwen3.5のthinking暴走を防止 |
| パラメータ名修正 | `max_tokens`→`max_output_tokens`（Stateful API正式名） |
| レスポンス上限 | 10MBのresp.readサイズ制限（OOM防止） |
| チェックポイント | アトミック書き込み（tempfile+fsync+replace）、破損処理、スキーマ検証 |
| エラー処理 | エラー本文100文字制限、タイムアウト判別、ターンリトライ（指数バックオフ） |
| 入力検証 | URLスキーム、タスクJSONスキーマ、パスサニタイズ |
| TLS | ssl.create_default_context()、http+token警告 |
| テスト | 22件→40件（エラーパス、checkpoint、extract_content、payload検証） |

### D3-5: Speculative Decoding検証結果

Qwen3.5-9Bはマルチモーダル（Vision-Language）モデルのため、llama.cppがSpeculative Decodingを非対応。
mcp_runner.pyへのdraft_model統合は不要。

### 新コマンド

| コマンド | 用途 |
|---------|------|
| `/lookup-docs` | 設計・計画時に公式ドキュメントを事前調査 |
| `/troubleshoot` | エラー発生時に公式ドキュメント+ユーザー事例を調査 |

## CLAUDE.mdへの追記推奨

```markdown
### 新コマンド（2026-03-25追加）
- `/lookup-docs [ツール名]` — 公式ドキュメントの事前調査（設計・計画時）
- `/troubleshoot [エラー内容]` — エラー発生時の公式+事例調査
```

## 配布対象ファイル

- `shared/commands/lookup-docs.md`（新規）
- `shared/commands/troubleshoot.md`（新規）
- `shared/scripts/local-llm-tools/mcp_runner.py`（更新）
- `shared/scripts/local-llm-tools/config.py`（更新）
- `shared/docs/lessons/ATONEMENT_SYSTEM.md`（更新）
