#!/bin/bash
# preflight_citation_gate.sh — quarto render前の引用配置ゲート
# PreToolUse hook (Bash) — quarto renderコマンド検出時にブロック
#
# 動作:
#   1. quarto renderコマンドを検出
#   2. 対象ファイル/ディレクトリの引用配置をチェック
#   3. P1/P2違反があればブロック（blocked: true）
#
# 出典: tech-articles/scripts/preflight.sh の Check 4 をhook化
#       ブロッキング化（tech-articlesでは警告のみだったが、是正完了後はブロック可能）

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# quarto render以外はスキップ
case "$COMMAND" in
  *"quarto render"*|*"quarto preview"*) ;;
  *) echo "$INPUT"; exit 0 ;;
esac

# quarto renderの対象を判定
# "quarto render file.qmd" → 単一ファイル
# "quarto render" → プロジェクト全体
RENDER_TARGET=""
if echo "$COMMAND" | grep -qE 'quarto (render|preview)\s+\S+\.qmd'; then
  RENDER_TARGET=$(echo "$COMMAND" | grep -oE '\S+\.qmd' | head -1)
fi

# スクリプトの場所を特定（同じディレクトリにcheck_citation_placement.shがある前提）
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")"
CHECK_SCRIPT="$SCRIPT_DIR/check_citation_placement.sh"

if [ ! -f "$CHECK_SCRIPT" ]; then
  # フォールバック: .claude/hooks/配下を探す
  CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null)
  CHECK_SCRIPT="$CWD/.claude/hooks/check_citation_placement.sh"
fi

if [ ! -f "$CHECK_SCRIPT" ]; then
  # チェックスクリプトがなければスキップ（インストールされていないリポ）
  echo "$INPUT"
  exit 0
fi

# チェック実行
if [ -n "$RENDER_TARGET" ] && [ -f "$RENDER_TARGET" ]; then
  RESULT=$(bash "$CHECK_SCRIPT" --file "$RENDER_TARGET" 2>&1)
  EXIT_CODE=$?
else
  # プロジェクト全体のrender → ディレクトリスキャン
  RESULT=$(bash "$CHECK_SCRIPT" --scan . 2>&1)
  EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -ne 0 ]; then
  echo "" >&2
  echo "========================================" >&2
  echo "【ブロック】引用配置の違反を検出" >&2
  echo "========================================" >&2
  echo "$RESULT" | tail -20 >&2
  echo "" >&2
  echo "quarto render前に引用配置を修正してください。" >&2
  echo "修正ツール: bash scripts/fix_citation_placement.py --dry-run [file]" >&2
  echo "========================================" >&2

  # ブロック
  jq -n '{"blocked": true, "reason": "Citation placement violations detected. Fix before rendering."}'
  exit 0
fi

echo "$INPUT"
exit 0
