#!/bin/bash
# ocr_workflow_check.sh - OCRワークフロー遵守チェック
#
# 用途: PostToolUse (Write|Edit) で実行
# 効果: OCR出力書き込み時に正規ワークフロー遵守を警告（ブロックなし）
#
# 設定例 (.claude/settings.json):
# {
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "Write|Edit",
#       "hooks": [{
#         "type": "command",
#         "command": "bash .claude/hooks/ocr_workflow_check.sh",
#         "timeout": 5
#       }]
#     }]
#   }
# }
#
# 検査内容:
#   1. ocr_output/ 配下への書き込みを検出
#   2. full_text のみで page_mapping.json が存在しない場合に警告
#   3. ocr-document-converter SKILLの使用を促す
#
# 背景: facility-safety S-2 OCRワークフロー違反（2026-03-09）の再発防止
# 出典: facility-safety ローカルhookを汎用化

set -euo pipefail

INPUT=$(cat)

# ツール名を取得
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Write/Edit以外はスルー
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# ファイルパスを取得
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# ファイルパスが空の場合はスルー
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# ocr_output/ 配下以外はスルー（research/ocr_output/ や data/ocr_output/ 等に対応）
if ! echo "$FILE_PATH" | grep -q "ocr_output/"; then
  exit 0
fi

# プロジェクトディレクトリを特定（ocr_output/PROJECT_NAME/file の形式）
PROJECT_DIR=$(echo "$FILE_PATH" | sed -n 's|\(.*ocr_output/[^/]*\)/.*|\1|p')

if [ -z "$PROJECT_DIR" ]; then
  exit 0
fi

# full_text.txt / full_text.md への書き込みを検出した場合
if echo "$FILE_PATH" | grep -qE "full_text\.(txt|md)$"; then
  if [ ! -f "${PROJECT_DIR}/page_mapping.json" ]; then
    cat >&2 << 'MSG'
⚠️  OCRワークフロー違反の可能性を検出

full_text ファイルが書き込まれましたが、page_mapping.json が見つかりません。
API直接呼び出しによる非構造化テキストダンプの可能性があります。

**必須確認事項**:
1. ocr-document-converter SKILL の 6Phase ワークフローを使用していますか？
2. init → preprocess → ocr → postprocess → structure → finalize の順序を守っていますか？
3. page_mapping.json・quality_summary.json は生成されていますか？

**正規手順**: /ocr-workflow コマンドを使用してください。
**参照**: .claude/skills/ocr-document-converter/SKILL.md
MSG
    # additionalContext注入
    ESCAPED=$(printf '%s' "[OCR] ${FILE_PATH} にpage_mapping.jsonがありません。/ocr-workflowコマンドで正規ワークフローを使用してください。直接API呼び出しによるテキストダンプは禁止です。" | jq -Rs '.')
    echo "{\"hookSpecificOutput\":{\"additionalContext\":${ESCAPED}}}" >&1
  fi
fi

# quality_summary.json なしで完了報告的なファイルを書こうとした場合
if echo "$FILE_PATH" | grep -qE "(README|SUMMARY|report)\.(md|txt)$"; then
  if [ ! -f "${PROJECT_DIR}/quality_summary.json" ]; then
    cat >&2 << 'MSG'
⚠️  OCR品質レポート未生成

完了報告的なファイルが書き込まれましたが、quality_summary.json が見つかりません。
OCR処理が正規ワークフローで完了していない可能性があります。

quality_summary.json が生成されるまで完了と報告しないでください。
MSG
    # additionalContext注入
    ESCAPED=$(printf '%s' "[OCR] ${PROJECT_DIR} にquality_summary.jsonがありません。OCR処理が正規ワークフローで完了していません。完了と報告しないでください。" | jq -Rs '.')
    echo "{\"hookSpecificOutput\":{\"additionalContext\":${ESCAPED}}}" >&1
  fi
fi

exit 0
