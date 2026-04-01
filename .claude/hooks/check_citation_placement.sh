#!/bin/bash
# check_citation_placement.sh — 引用配置チェック（汎用版）
# PostToolUse hook (Write|Edit) + スタンドアロン実行の両方に対応
#
# 検出パターン:
#   P1: 見出し内の引用 (## ... [@key])
#   P2: Bold小見出し内の引用 (**text** [@key]:)
#
# hook モード (PostToolUse):
#   stdin からJSONを受け取り、.qmd/.Rmd ファイルへのWrite/Editを検出
#   違反があれば stderr に警告出力（ブロックしない）
#
# スタンドアロンモード:
#   bash check_citation_placement.sh [directory]     # ディレクトリスキャン
#   bash check_citation_placement.sh --file FILE     # 単一ファイル
#
# 出典: tech-articles/scripts/check_citation_placement.sh (134行)
#       849件の引用違反を検出した実績に基づく

set -euo pipefail

# --- hook モード ---
# stdinがパイプの場合、PostToolUse hookとして動作
if [ ! -t 0 ] && [ "${1:-}" != "--file" ] && [ "${1:-}" != "--scan" ]; then
  INPUT=$(cat)

  # ツール名とファイルパスを取得
  TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

  # Write/Edit以外はスキップ
  if [ "$TOOL" != "Write" ] && [ "$TOOL" != "Edit" ]; then
    echo "$INPUT"
    exit 0
  fi

  # .qmd / .Rmd 以外はスキップ
  case "$FILE_PATH" in
    *.qmd|*.Rmd) ;;
    *) echo "$INPUT"; exit 0 ;;
  esac

  # ファイルが存在しなければスキップ
  if [ ! -f "$FILE_PATH" ]; then
    echo "$INPUT"
    exit 0
  fi

  # P1/P2チェック
  p1=$(grep -c '^##.*\[@[a-zA-Z_]' "$FILE_PATH" 2>/dev/null || true)
  p2=$(grep -c '^\*\*[^*]\+\*\*.*\[@[a-zA-Z_][^]]*\].*:' "$FILE_PATH" 2>/dev/null || true)
  total=$((${p1:-0} + ${p2:-0}))

  if [ "$total" -gt 0 ]; then
    echo "" >&2
    echo "======================================" >&2
    echo "【警告】引用配置の問題を検出: $FILE_PATH" >&2
    echo "======================================" >&2
    if [ "${p1:-0}" -gt 0 ]; then
      echo "  P1（見出し内引用）: ${p1}件" >&2
      grep -n '^##.*\[@[a-zA-Z_]' "$FILE_PATH" 2>/dev/null | head -3 | sed 's/^/    /' >&2
    fi
    if [ "${p2:-0}" -gt 0 ]; then
      echo "  P2（Bold小見出し内引用）: ${p2}件" >&2
      grep -n '^\*\*[^*]\+\*\*.*\[@[a-zA-Z_][^]]*\].*:' "$FILE_PATH" 2>/dev/null | head -3 | sed 's/^/    /' >&2
    fi
    echo "" >&2
    echo "  引用は具体的事実（数値・日付・仕様）の直後に配置してください" >&2
    echo "======================================" >&2
  fi

  echo "$INPUT"
  exit 0
fi

# --- スタンドアロンモード ---

# 単一ファイルモード
if [ "${1:-}" = "--file" ]; then
  if [ -z "${2:-}" ] || [ ! -f "${2:-}" ]; then
    echo "ERROR: --file requires a valid file path" >&2
    exit 1
  fi
  SINGLE_FILE="$2"
  p1=$(grep -c '^##.*\[@[a-zA-Z_]' "$SINGLE_FILE" 2>/dev/null || true)
  p2=$(grep -c '^\*\*[^*]\+\*\*.*\[@[a-zA-Z_][^]]*\].*:' "$SINGLE_FILE" 2>/dev/null || true)
  total=$((${p1:-0} + ${p2:-0}))
  echo "=== $SINGLE_FILE ==="
  if [ "${p1:-0}" -gt 0 ]; then
    echo "P1 (heading citations): $p1"
    grep -n '^##.*\[@[a-zA-Z_]' "$SINGLE_FILE" 2>/dev/null | sed 's/^/  /'
  fi
  if [ "${p2:-0}" -gt 0 ]; then
    echo "P2 (bold sub-heading citations): $p2"
    grep -n '^\*\*[^*]\+\*\*.*\[@[a-zA-Z_][^]]*\].*:' "$SINGLE_FILE" 2>/dev/null | sed 's/^/  /'
  fi
  if [ "$total" -eq 0 ]; then
    echo "No improper citation placements detected."
    exit 0
  else
    echo "Total: $total detections"
    exit 1
  fi
fi

# ディレクトリスキャンモード
TARGET_DIR="${1:-${2:-.}}"
[ "${1:-}" = "--scan" ] && TARGET_DIR="${2:-.}"

P1_COUNT=0
P2_COUNT=0
TOTAL_FILES=0

P1_RESULTS=$(mktemp)
P2_RESULTS=$(mktemp)
trap 'rm -f "$P1_RESULTS" "$P2_RESULTS"' EXIT

echo "=== Citation Placement Check ==="
echo "Target: $TARGET_DIR"
echo ""

while IFS= read -r -d '' file; do
  TOTAL_FILES=$((TOTAL_FILES + 1))
  rel_path="${file#./}"

  while IFS= read -r match; do
    if [ -n "$match" ]; then
      line_num=$(echo "$match" | cut -d: -f1)
      content=$(echo "$match" | cut -d: -f2-)
      echo "P1|$rel_path|$line_num|$content" >> "$P1_RESULTS"
      P1_COUNT=$((P1_COUNT + 1))
    fi
  done < <(grep -n '^##.*\[@[a-zA-Z_]' "$file" 2>/dev/null || true)

  while IFS= read -r match; do
    if [ -n "$match" ]; then
      line_num=$(echo "$match" | cut -d: -f1)
      content=$(echo "$match" | cut -d: -f2-)
      echo "P2|$rel_path|$line_num|$content" >> "$P2_RESULTS"
      P2_COUNT=$((P2_COUNT + 1))
    fi
  done < <(grep -n '^\*\*[^*]\+\*\*.*\[@[a-zA-Z_][^]]*\].*:' "$file" 2>/dev/null || true)

done < <(find "$TARGET_DIR" \( -name "*.qmd" -o -name "*.Rmd" \) -print0 2>/dev/null)

echo "=== Summary ==="
echo "Files scanned: $TOTAL_FILES"
echo "P1 (heading citations): $P1_COUNT"
echo "P2 (bold sub-heading citations): $P2_COUNT"
echo "Total: $((P1_COUNT + P2_COUNT))"

if [ "$((P1_COUNT + P2_COUNT))" -gt 0 ]; then
  echo ""
  if [ -s "$P1_RESULTS" ]; then
    echo "--- P1 detections ---"
    sort "$P1_RESULTS" | while IFS='|' read -r _ f l c; do echo "  $f:$l: $c"; done
  fi
  if [ -s "$P2_RESULTS" ]; then
    echo "--- P2 detections ---"
    sort "$P2_RESULTS" | while IFS='|' read -r _ f l c; do echo "  $f:$l: $c"; done
  fi
  exit 1
else
  echo "No improper citation placements detected."
  exit 0
fi
