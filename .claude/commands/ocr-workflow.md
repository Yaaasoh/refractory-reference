---
description: PDFからOCR処理を実行（ocr-app統合ワークフロー）
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
argument-hint: "<pdf_path> [--engine auto|yomitoku|ndlocr|gcp] [--phase init|preprocess|ocr|postprocess|structure|finalize]"
---

# OCR Workflow

PDF文書をOCRで構造化Markdownに変換する統合ワークフロー。

## 対象PDF

$ARGUMENTS

## Step 1: 環境確認

### ocr-app CLIの確認

```bash
# CLIが使用可能か確認
ocr-app version

# 使用不可の場合: pipでインストール
pip install -e /path/to/ocr-app
```

### MCP経由の場合

MCPサーバーが設定されていれば、ocr-appのツールを直接呼び出せる。
設定テンプレート: `.claude/docs/templates/mcp/ocr-app.json`
**注意**: MCP経由ではエンジンは `auto/yomitoku/ndlocr` の3択。`gcp`はCLI専用。

## Step 2: エンジン選択

| エンジン | 特徴 | 推奨用途 |
|---------|------|---------|
| `auto` | 環境に応じて自動選択 | 迷ったらこれ |
| `yomitoku` | 高精度、表・図対応 | 技術文書、表の多い資料 |
| `ndlocr` | 高速、商用利用可（CC BY 4.0） | 大量処理、商用プロジェクト |
| `gcp` | Google Cloud Vision API（CLI専用） | クラウド環境、GPU非搭載機 |

## Step 3: ワークフロー実行

### 全Phase一括実行（推奨）

```bash
ocr-app workflow run <pdf_path> -o ./output --engine auto
```

### Phase個別実行

```bash
# Phase 0: プロジェクト初期化（ディレクトリ構造+PDF配置）
ocr-app workflow init <pdf_path> -o ./output

# Phase 1-5: 個別実行
ocr-app workflow run <pdf_path> -o ./output --phase preprocess
ocr-app workflow run <pdf_path> -o ./output --phase ocr
ocr-app workflow run <pdf_path> -o ./output --phase postprocess
ocr-app workflow run <pdf_path> -o ./output --phase structure
ocr-app workflow run <pdf_path> -o ./output --phase finalize
```

### 主要オプション

| オプション | デフォルト | 説明 |
|-----------|-----------|------|
| `-o, --output` | `.` | 出力ディレクトリ |
| `-n, --name` | ファイル名 | プロジェクト名 |
| `-e, --engine` | `auto` | OCRエンジン |
| `--dpi` | `300` | PDF描画解像度 |
| `--remove-page-numbers` | false | ページ番号行を除去（書籍OCR推奨） |
| `--phase` | 全Phase | 特定Phaseのみ実行 |
| `--json` | false | JSON出力 |

## Step 4: 進捗確認

```bash
ocr-app workflow status ./output/<project_name>
```

## Step 5: 品質確認

### 出力ディレクトリ構成

```
output/<project_name>/
  page_mapping.json     # 全ページのメタデータ・品質情報
  pages/                # ページ別画像
  ocr_results/          # ページ別OCR結果
  markdown/             # ページ別構造化Markdown
  consolidated.md       # 統合Markdown（最終成果物）
  quality_summary.json  # 品質サマリー
```

### 確認項目

1. `page_mapping.json` で各ページのステータスを確認
2. `quality_summary.json` で全体の品質スコアを確認
3. `consolidated.md` を目視確認（見出し構造、表の整形）

### よくある問題と対処

| 問題 | 対処 |
|------|------|
| 空白ページが多い | `--dpi 400` で再実行 |
| 表が崩れる | `--engine yomitoku` を指定 |
| 文字化け | `--engine gcp` でクラウドOCRを試す |
| 処理が遅い | `--engine ndlocr` で高速エンジンを使用 |

## 注意事項

- ocr-appのインストールが必要（`pip install -e /path/to/ocr-app`）
- GPU環境推奨（yomitoku, ndlocrはCUDA対応）
- GCPエンジンはサービスアカウント設定が必要
- 詳細な手順はスキル `ocr-document-converter` を参照
