---
name: ocr-document-converter
description: PDF文書のOCR変換専門家。ゼロからの構造化Markdown変換を担当。6Phase統合ワークフロー（init/preprocess/ocr/postprocess/structure/finalize）、マルチエンジン対応（YomiToku/NDLOCR/GCP Vision）、page_mapping.json管理。PDF変換、ドキュメント処理、ページ管理、構造化出力で自動適用。example-transcript-correction（既存テキスト校正）とは異なり、ゼロからのドキュメント変換を担当。
license: MIT
metadata:
  author: yaaasoh
  version: "1.0.0"
---

# OCRドキュメント変換スキル

PDF文書をOCRで構造化Markdownに変換する統合ワークフロー。

## example-transcript-correctionとの違い

| 項目 | ocr-document-converter（本スキル） | example-transcript-correction |
|------|-----------------------------------|-------------------------------|
| 入力 | PDF（画像） | テキスト（文字起こし済み） |
| 処理 | ゼロからの変換 | 既存テキストの校正 |
| 出力 | 構造化Markdown + メタデータ | 修正済みテキスト |
| ツール | ocr-app CLI / MCP | テキストエディタ |
| 用語集 | 不要（OCR結果をそのまま構造化） | 必須（誤変換修正の基準） |

**判断基準**: PDFから文字を読み取る必要がある → 本スキル。既にテキスト化されている → transcript-correction。

## 前提条件

- ocr-appがインストール済み（`pip install -e /path/to/ocr-app`）
- GPU環境推奨（yomitoku, ndlocrはCUDA対応）
- GCPエンジン使用時はサービスアカウント設定が必要

## Phase概要

| Phase | 名称 | 処理内容 | 成果物 |
|-------|------|---------|--------|
| 0 | init | プロジェクト初期化、PDFページ数確認 | ディレクトリ構造、page_mapping.json |
| 1 | preprocess | PDF→ページ画像変換、空白ページ検出 | pages/*.png |
| 2 | ocr | ページ別OCR実行 | ocr_results/*.json |
| 3 | postprocess | NFKC正規化、品質分析 | 正規化済みテキスト、品質スコア |
| 4 | structure | 見出し抽出、ページ別Markdown生成 | markdown/*.md、マニフェスト |
| 5 | finalize | 統合Markdown生成、品質サマリー | consolidated.md、quality_summary.json |

## Phase 0: init（プロジェクト初期化）

### 目的
プロジェクトディレクトリの作成とPDF情報の収集。

### 実行

```bash
ocr-app workflow init <pdf_path> -o ./output [-n project_name] [-e engine]
```

### 出力構造

```
output/<project_name>/
  page_mapping.json     # プロジェクトメタデータ
  pages/                # ページ画像格納先（空）
  ocr_results/          # OCR結果格納先（空）
  markdown/             # Markdown格納先（空）
```

### 確認項目
- [ ] ディレクトリが正しく作成された
- [ ] page_mapping.jsonにPDF情報が記録された

## Phase 1: preprocess（前処理）

### 目的
PDFをページ単位の画像に変換し、空白ページを検出。

### 実行

```bash
ocr-app workflow run <pdf_path> -o ./output --phase preprocess [--dpi 300]
```

### DPI選択ガイド

| DPI | 用途 | ファイルサイズ |
|-----|------|-------------|
| 200 | 高速処理、文字が大きい文書 | 小 |
| 300 | 標準（推奨） | 中 |
| 400 | 小さい文字、複雑な図表 | 大 |

### 確認項目
- [ ] pages/配下に各ページのPNG画像が生成された
- [ ] 空白ページが正しく検出された（page_mapping.json確認）

## Phase 2: ocr（OCR実行）

### 目的
各ページ画像に対してOCRエンジンでテキスト抽出。

### エンジン選択

| エンジン | 特徴 | 推奨用途 |
|---------|------|---------|
| `auto` | 環境に応じて自動選択 | 迷ったらこれ |
| `yomitoku` | 高精度、表・図領域検出対応 | 技術文書、表の多い資料 |
| `ndlocr` | 高速、商用利用可（CC BY 4.0） | 大量処理、商用プロジェクト |
| `gcp` | Google Cloud Vision API（CLI専用） | GPU非搭載機、クラウド環境 |

**注意**: MCP経由の`analyze_document`では`auto/yomitoku/ndlocr`の3択。`gcp`はCLI(`workflow run`)専用。

### 実行

```bash
ocr-app workflow run <pdf_path> -o ./output --phase ocr --engine yomitoku
```

### 確認項目
- [ ] ocr_results/配下に各ページのJSON結果が生成された
- [ ] page_mapping.jsonの各ページステータスが更新された

## Phase 3: postprocess（後処理）

### 目的
OCR結果のNFKC正規化と品質分析。

### 実行

```bash
ocr-app workflow run <pdf_path> -o ./output --phase postprocess
```

### 処理内容
- 全角英数字→半角英数字（NFKC正規化）
- 品質スコア算出（文字数、空行率等）
- ページ番号行の除去（`--remove-page-numbers`指定時）

### 確認項目
- [ ] 品質スコアがpage_mapping.jsonに記録された
- [ ] 低品質ページ（スコアが低い）を確認

## Phase 4: structure（構造化）

### 目的
見出し抽出とページ別Markdown生成。

### 実行

```bash
ocr-app workflow run <pdf_path> -o ./output --phase structure
```

### 処理内容
- 日本語見出しの自動抽出（パターンマッチ）
- ページ別構造化Markdown生成
- マニフェスト（目次情報）の生成

### 確認項目
- [ ] markdown/配下にページ別.mdファイルが生成された
- [ ] 見出し構造が正しいか（目次との照合）

## Phase 5: finalize（統合・完了）

### 目的
全ページを統合した最終Markdownと品質サマリーの生成。

### 実行

```bash
ocr-app workflow run <pdf_path> -o ./output --phase finalize
```

### 成果物
- `consolidated.md` — 統合Markdown（最終成果物）
- `quality_summary.json` — 全体品質レポート

### 確認項目
- [ ] consolidated.mdが生成された
- [ ] 見出し構造が論理的に正しい
- [ ] quality_summary.jsonで全体品質を確認

## page_mapping.jsonの読み方

page_mapping.jsonはワークフロー全体の状態管理ファイル。

### 主要フィールド

```json
{
  "project_name": "document_name",
  "ocr_engine": "yomitoku",
  "total_pages": 50,
  "pages": {
    "1": {
      "status": "completed",
      "image_path": "pages/page_001.png",
      "ocr_result_path": "ocr_results/page_001.json",
      "markdown_path": "markdown/page_001.md",
      "quality": {
        "text_length": 1234,
        "score": 0.85
      }
    }
  }
}
```

### ステータス一覧

| ステータス | 意味 |
|-----------|------|
| `pending` | 未処理 |
| `completed` | 正常完了 |
| `failed` | エラー発生 |
| `skipped` | スキップ（空白ページ等） |

## トラブルシューティング

### OCR結果が空になる

**原因**: DPIが低い、画像が読み取り不能
**対処**:
1. `--dpi 400` で再実行
2. 元PDFの画像品質を確認
3. 別エンジンを試す

### 表が正しく変換されない

**原因**: エンジンが表構造を認識できていない
**対処**:
1. `--engine yomitoku` を指定（表検出に優れる）
2. 手動でMarkdownテーブルに修正

### GCPエンジンが認証エラー

**原因**: サービスアカウントが未設定
**対処**:
1. GCPコンソールでサービスアカウントキーを発行
2. `GOOGLE_APPLICATION_CREDENTIALS` 環境変数を設定
3. Vision APIが有効か確認

### 特定ページだけ再処理したい

現在の実装ではPhase単位での再実行のみ対応。特定ページの再処理は将来対応予定。
ワークアラウンド: 該当ページの結果ファイルを削除してからPhaseを再実行。

## 品質チェックリスト

### 完全性（Completeness）
- [ ] 全ページが処理された（page_mapping.jsonで確認）
- [ ] 空白ページが正しくスキップされた
- [ ] failedページがない（またはリトライ済み）

### 正確性（Accuracy）
- [ ] consolidated.mdの見出し構造が元文書と一致
- [ ] 表が正しく変換されている
- [ ] 数値・固有名詞が正確

### 構造（Structure）
- [ ] Markdownの見出しレベルが適切
- [ ] ページ区切りが正しい
- [ ] 目次（マニフェスト）と本文が一致

## 完了定義（Definition of Done）

- [ ] 全Phaseが正常完了（page_mapping.jsonで確認）
- [ ] consolidated.mdが生成され、内容を目視確認済み
- [ ] quality_summary.jsonで品質スコアを確認済み
- [ ] 低品質ページの対処が完了（再処理 or 手動修正 or 受容判断）
- [ ] 成果物がGitにコミット済み

## 参照

- `/ocr-workflow` — 簡易実行コマンド
- `docs/templates/mcp/ocr-app.json` — MCP設定テンプレート
- ocr-appリポジトリ — 実装の詳細

---

**作成日**: 2026-03-08
**バージョン**: 1.0.0
**出典**: ocr-app統合ワークフロー
