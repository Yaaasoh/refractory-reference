# ocr-app への統合ワークフロー導入案内

**対象リポジトリ**: ocr-app
**作成日**: 2026-03-07
**関連報告書**: `prompt-patterns/work/reports/REPORT_20260307_OCR_WORKFLOW_INTEGRATION_ANALYSIS.md`

---

## 背景

ocr-appは OCRエンジン層（YomiToku/NDLOCR-Lite）と事後処理（NFKC正規化・文字化け除去・品質分析）を備えているが、**エンドツーエンドのワークフローとしては機能しない**。

tech-articles には実績のあるOCRワークフロー（20+プロジェクト運用実績）が存在し、以下の機能をスクリプト群で提供している:
- プロジェクトディレクトリ初期化
- PDF→画像変換（DPI制御）
- page_mapping.json管理
- 見出し自動抽出（日本語パターン）
- 個別ページMarkdown + manifest.json生成
- セクション統合・統合Markdown（目次付き）
- 品質レポート

これらを統合した新型ワークフローをocr-appに整備する。

---

## 導入内容

### 新規追加モジュール

```
src/ocr_app/workflow/           # 新規ワークフローモジュール
  __init__.py
  runner.py                     # ワークフローエンジン（Phase 0-5 統合実行）
  project.py                    # プロジェクト初期化・ディレクトリ構成
  page_mapping.py               # page_mapping.json管理（tech-articles互換）
  heading_extractor.py          # 日本語見出し自動抽出（tech-articles HEADING_PATTERNS移植）
  structured_generator.py       # 個別ページMD + manifest.json生成
  consolidated_generator.py     # 統合Markdown生成（目次付き）
```

### CLIコマンド追加

```
ocr-app workflow run <input.pdf> -o <output_dir>    # 全Phase実行
ocr-app workflow run <input.pdf> --phase preprocess  # Phase単位実行
ocr-app workflow init <project_name>                 # プロジェクト初期化のみ
ocr-app workflow status <project_dir>                # 進捗確認
```

### ワークフロー全体フロー

```
Phase 0: init
  - data/{source,images,ocr_output/text,master,structured} 作成
  - page_mapping.json 初期化

Phase 1: preprocess
  - PDF→画像変換（PyMuPDF, DPI制御: 300/150/72）
  - 空ページ検出（ImagePreprocessor, OCR前・画像分析）
  - page_mapping.json 更新

Phase 2: ocr
  - エンジン選択（auto/yomitoku/ndlocr）
  - バッチ処理 + チェックポイント
  - テキスト出力: data/ocr_output/text/{page_key}.txt
  - page_mapping.json 更新（ocr_status, text_length等）

Phase 3: postprocess
  - TextPostProcessor（NFKC正規化、文字化け除去、ホワイトスペース正規化）
  - QualityAnalyzer（品質スコア計算、分類）
  - 空ページ検出（OCR後・テキスト分析）
  - page_mapping.json 更新（quality_score, flags等）
  - quality_report.json 生成

Phase 4: structure
  - 見出し自動抽出（日本語パターン: 第X章、1.、(1)、箇条書き）
  - 個別ページMarkdown生成（YAML frontmatter付き）
  - manifest.json 生成
  - セクション単位統合

Phase 5: finalize
  - 統合Markdown生成（目次付き、空ページスキップ）
  - 最終品質レポート
  - サマリー表示
```

### tech-articlesから移植する機能

| 移植元スクリプト | 移植先 | 移植内容 |
|-----------------|--------|---------|
| `generate_consolidated_text.py` L37-51 | `heading_extractor.py` | HEADING_PATTERNS（第X章、数字見出し等） |
| `generate_structured_markdown.py` | `structured_generator.py` | 個別ページMD + manifest.json |
| `generate_consolidated_text.py` | `consolidated_generator.py` | 目次生成、ページ区切り |
| `merge_markdown_pages.py` | `structured_generator.py` | セクション統合、品質フィルタ |
| `simple_ocr.py` | `page_mapping.py` | page_mapping.json形式 |
| `detect_empty_pages.py` | `page_mapping.py` | テキスト分析型品質メトリクス |
| `LOCAL_OCR_EXECUTION.md` | `project.py` | ディレクトリ規約 |

### ocr-app既存機能の活用

| 既存機能 | 活用方法 |
|---------|---------|
| TextPostProcessor | Phase 3 で自動適用 |
| QualityAnalyzer | Phase 3 で品質スコア計算 |
| ImagePreprocessor | Phase 1 で空ページ事前検出 |
| JobManager | Phase 2 でチェックポイント管理 |
| DocumentSplitter | Phase 4 でセクション分割 |
| OutputFormatter | Phase 4 で構造化出力 |

---

## ディレクトリ規約（プロジェクト構成）

```
<project_dir>/
  data/
    source/           # 元PDF配置
    images/           # PDF→画像変換結果
    ocr_output/
      text/           # ページごとのOCRテキスト
    master/
      page_mapping.json    # ページ管理マスター
      quality_report.json  # 品質レポート
    structured/
      README.md            # プロジェクト説明
      manifest.json        # 構造管理
      pages/               # 個別ページMarkdown
      sections/            # セクション統合
      consolidated.md      # 統合Markdown（目次付き）
```

---

## page_mapping.json形式（tech-articles互換）

```json
{
  "metadata": {
    "project_name": "YYYYMMDD_<name>",
    "total_pages": 42,
    "created_at": "2026-03-07T...",
    "last_updated": "2026-03-07T...",
    "ocr_engine": "yomitoku",
    "version": "3.0.0"
  },
  "pages": {
    "page_001": {
      "page_number": 1,
      "image_file": "page_001.png",
      "ocr_status": "completed",
      "ocr_timestamp": "2026-03-07T...",
      "text_length": 1234,
      "quality_score": 0.95,
      "type": "text",
      "flags": [],
      "section": "chapter1"
    }
  }
}
```

---

## CLAUDE.md への追記推奨内容

```markdown
## 統合ワークフロー

OCR処理はワークフローコマンドで実行:

\`\`\`bash
# 全Phase実行
ocr-app workflow run input.pdf -o output/

# Phase単位
ocr-app workflow run input.pdf --phase preprocess
ocr-app workflow run input.pdf --phase ocr --engine yomitoku
ocr-app workflow run input.pdf --phase structure

# プロジェクト初期化のみ
ocr-app workflow init my_project
\`\`\`

### ディレクトリ規約

プロジェクトは `data/{source,images,ocr_output/text,master,structured}` 構成。
page_mapping.json がマスター管理ファイル。
```

---

## 依存関係の追加

```toml
# pyproject.toml に追加
[project]
dependencies = [
    # 既存依存に加えて:
    "PyMuPDF>=1.24.0",  # PDF→画像変換（Phase 1）
]
```

---

## テスト計画

| テスト種別 | 対象 | ファイル |
|-----------|------|---------|
| Unit | HeadingExtractor パターンマッチ | `tests/test_heading_extractor.py` |
| Unit | PageMapping CRUD | `tests/test_page_mapping.py` |
| Unit | StructuredGenerator MD生成 | `tests/test_structured_generator.py` |
| Unit | ConsolidatedGenerator 目次生成 | `tests/test_consolidated_generator.py` |
| Integration | WorkflowRunner Phase 0-5 | `tests/integration/test_workflow.py` |
| Integration | CLI workflow コマンド | `tests/integration/test_workflow_cli.py` |

---

## 実装ロードマップ

### Step 1: 基盤（page_mapping + project init）
- `workflow/project.py`: ディレクトリ初期化
- `workflow/page_mapping.py`: page_mapping.json管理
- テスト作成

### Step 2: 見出し抽出 + 構造化出力
- `workflow/heading_extractor.py`: HEADING_PATTERNS移植
- `workflow/structured_generator.py`: 個別ページMD + manifest.json
- `workflow/consolidated_generator.py`: 統合Markdown
- テスト作成

### Step 3: ワークフローエンジン + CLI
- `workflow/runner.py`: Phase 0-5 統合実行
- CLI `workflow` サブコマンド追加
- 統合テスト

### Step 4: 検証
- tech-articles既存プロジェクト（実データ）での動作確認
- 品質比較（GCP Vision API vs YomiToku/NDLOCR、同一文書）

---

**作成者**: Claude Code
**分類**: 連絡展開（経路2）
