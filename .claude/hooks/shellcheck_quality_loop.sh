#!/bin/bash
# SC Quality Loop hook - シェルスクリプト品質チェック (Quality Loops対応)
# File: shellcheck_quality_loop.sh
#
# 用途: PostToolUse (Write|Edit) で実行
# 効果: shellcheck実行 + additionalContext修正指示注入
# 動作: stderr=人間向け警告、stdout=エージェント向けadditionalContext JSON
#
# 前提: shellcheckがインストール済みであること（未インストール時は無音スキップ）
#
# 設定例 (.claude/settings.json):
# {
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "Write|Edit",
#       "hooks": [{"type": "command", "command": "bash .claude/hooks/shellcheck_quality_loop.sh", "timeout": 10}]
#     }]
#   }
# }

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# ファイルパスが空の場合はスルー
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# .sh/.bashファイルのみ対象
case "$FILE_PATH" in
  *.sh|*.bash) ;;
  *) exit 0 ;;
esac

# ファイルが存在しない場合はスルー
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# SC未インストール時は無音スキップ
if ! command -v shellcheck >/dev/null 2>&1; then
  exit 0
fi

# SC実行（JSON形式で結果取得）
RESULT=$(shellcheck -f json "$FILE_PATH" 2>/dev/null || true)

# 結果が空またはJSON無効の場合はスルー
if [ -z "$RESULT" ] || [ "$RESULT" = "[]" ]; then
  exit 0
fi

ERROR_COUNT=$(echo "$RESULT" | jq 'length' 2>/dev/null || echo "0")

if [ "$ERROR_COUNT" -gt 0 ]; then
  # stderr: 人間向け警告サマリ
  echo "⚠️  shellcheck: ${ERROR_COUNT}件の問題（${FILE_PATH}）" >&2

  # 上位3件の詳細をstderrに表示
  echo "$RESULT" | jq -r '.[0:3] | .[] | "  L\(.line):\(.column) [\(.code)] \(.message)"' >&2 2>/dev/null
  if [ "$ERROR_COUNT" -gt 3 ]; then
    echo "  ... 他$((ERROR_COUNT - 3))件" >&2
  fi

  # stdout: additionalContext注入（エージェント向け修正指示）
  SUMMARY=$(echo "$RESULT" | jq -r '.[0:3] | .[] | "L\(.line): SC\(.code) \(.message)"' 2>/dev/null || true)
  CONTEXT_TEXT="[shellcheck] ${FILE_PATH} に${ERROR_COUNT}件の問題。上位3件: ${SUMMARY} これらを修正してください。"
  ESCAPED=$(printf '%s' "$CONTEXT_TEXT" | jq -Rs '.')
  echo "{\"hookSpecificOutput\":{\"additionalContext\":${ESCAPED}}}" >&1
fi

exit 0
