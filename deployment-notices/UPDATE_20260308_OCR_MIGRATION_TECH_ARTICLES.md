# tech-articles OCR移行ガイド

**日付**: 2026-03-08
**種別**: 移行ガイド
**対象**: tech-articles

## 概要

tech-articlesの`scripts/ocr/`配下の14スクリプトは、ocr-appの統合ワークフローに統合されました。本ガイドは段階的移行の方針を示します。

## 既存スクリプトとの対応表

| 既存スクリプト | ocr-app対応 | 対応Phase |
|---------------|------------|-----------|
| `pdf_to_images.py` | 統合済み | Phase 1 (preprocess) |
| `detect_empty_pages.py` | 統合済み | Phase 1 (preprocess) |
| `simple_ocr.py` | 統合済み | Phase 2 (ocr) |
| `main_ocr_processor.py` | 統合済み | Phase 2 (ocr) |
| `convert_pdf.py` | 統合済み | Phase 2 (ocr) |
| `quality_checker.py` | 統合済み | Phase 3 (postprocess) |
| `data_structurer.py` | 統合済み | Phase 4 (structure) |
| `generate_structured_markdown.py` | 統合済み | Phase 4 (structure) |
| `merge_markdown_pages.py` | 統合済み | Phase 5 (finalize) |
| `generate_consolidated_text.py` | 統合済み | Phase 5 (finalize) |
| `run_ocr_project.py` | 統合済み | 全Phase (workflow run) |
| `setup_workload_identity.sh` | 別途管理 | GCP設定（ocr-app外） |
| `test_auth.py` | 別途管理 | GCPテスト（ocr-app外） |
| `README.md` | 本ガイドで代替 | - |

## 移行方針: 段階的移行

### Phase A: 並行運用（現在）

- 新規OCR作業は`ocr-app workflow run`を使用
- 既存スクリプトはそのまま残す（既存プロジェクトの互換性維持）
- 両方の結果を比較して品質差異がないことを確認

### Phase B: 検証完了後

- 品質差異がないことを確認したら、新規作業はocr-app一本化
- 既存スクリプトはリファレンスとして残す（削除しない）

### Phase C: 完全移行（将来）

- 既存スクリプトの削除はユーザー判断
- `scripts/ocr/README.md`に移行先を記載

## 使い方

### 新規OCR作業

```bash
# ocr-appを使用（推奨）
ocr-app workflow run document.pdf -o ./research/ocr_projects/project_name --engine yomitoku

# または /ocr-workflow コマンド
/ocr-workflow document.pdf
```

### 既存プロジェクトの継続

既存の`research/ocr_projects/`配下のプロジェクトは、従来通り既存スクリプトで継続可能。

## CLAUDE.md追記推奨

```markdown
## OCRワークフロー

### 新規OCR作業
ocr-appの統合ワークフローを使用:
- コマンド: `/ocr-workflow <pdf_path>`
- スキル: `ocr-document-converter`
- CLI: `ocr-app workflow run <pdf_path> -o ./research/ocr_projects/<name>`

### 既存OCRスクリプト（scripts/ocr/）
並行運用中。新規作業はocr-appを優先。
```

## 注意事項

- ocr-appは別リポジトリ（`ocr-app`）で管理
- `pip install -e /path/to/ocr-app` でインストール後に使用可能
- GCP Vision APIを使う場合は`setup_workload_identity.sh`による設定が引き続き必要
