# OCRワークフローツール追加

**日付**: 2026-03-08
**種別**: 新機能追加
**対象**: 全リポジトリ（OCR作業を行うリポジトリ向け）

## 概要

ocr-appの統合ワークフロー（Phase 0-5）を各リポジトリから利用するためのツール一式を追加しました。

## 追加コンテンツ

### 1. カスタムコマンド: `/ocr-workflow`

**パス**: `.claude/commands/ocr-workflow.md`

PDFからOCR処理を実行する簡易コマンド。環境確認、エンジン選択、実行、品質確認の手順を提供。

**使い方**:
```
/ocr-workflow document.pdf --engine yomitoku
```

### 2. スキル: `ocr-document-converter`

**パス**: `.claude/skills/ocr-document-converter/SKILL.md`

6Phase統合ワークフローの詳細手順書。Phase別の実行方法、page_mapping.jsonの読み方、トラブルシューティング、品質チェックリストを含む。

**既存スキルとの区別**:
- `ocr-document-converter`: PDF（画像）からゼロからの変換
- `example-transcript-correction`: 既存テキストの校正・修正

### 3. MCP設定テンプレート: `ocr-app.json`

**パス**: `.claude/docs/templates/mcp/ocr-app.json`

ocr-appをMCPサーバーとして設定するためのテンプレート。手動でsettings.jsonにマージして使用。

## 利用条件

- ocr-appのインストールが必要: `pip install -e /path/to/ocr-app`
- GPU環境推奨（YomiToku, NDLOCR-LiteはCUDA対応）
- GCPエンジン使用時はサービスアカウント設定が必要

## 対応エンジン

| エンジン | 特徴 |
|---------|------|
| auto | 環境に応じて自動選択 |
| yomitoku | 高精度、表・図対応 |
| ndlocr | 高速、商用利用可 |
| gcp | クラウドOCR（GPU不要） |

## CLAUDE.md追記推奨

OCR作業を頻繁に行うリポジトリでは、以下をCLAUDE.mdに追記することを推奨:

```markdown
## OCRワークフロー

PDF文書のOCR変換には `/ocr-workflow` コマンドまたは `ocr-document-converter` スキルを使用。
ocr-appのインストールが前提: `pip install -e /path/to/ocr-app`
```
