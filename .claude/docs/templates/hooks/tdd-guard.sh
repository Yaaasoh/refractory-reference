#!/bin/bash
# tdd-guard.sh - t-wadaスタイルTDD強制スクリプト
#
# 用途: PreToolUse (Edit|Write) で実行
# 効果: テスト改ざんを検出・ブロック
#
# 設定例 (.claude/settings.json):
# {
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "Edit|Write",
#       "hooks": [{"type": "command", "command": ".claude/hooks/tdd-guard.sh"}]
#     }]
#   }
# }

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# テストファイル以外は通過
if [[ ! "$FILE_PATH" =~ \.(test|spec)\.(ts|tsx|js|jsx|py)$ ]]; then
  exit 0
fi

# Git差分を取得（staged優先、なければunstaged）
DIFF=$(git diff --cached "$FILE_PATH" 2>/dev/null || git diff "$FILE_PATH" 2>/dev/null || echo "")

if [ -z "$DIFF" ]; then
  exit 0
fi

# =============================================================================
# 検出パターン1: アサーション削除
# =============================================================================
if echo "$DIFF" | grep -E "^-[^-].*(\bassert\b|\bexpect\b|\bshould\b)" > /dev/null; then
  echo "============================================" >&2
  echo "  t-wada警告: アサーション削除を検出" >&2
  echo "============================================" >&2
  echo "" >&2
  echo "削除された行:" >&2
  echo "$DIFF" | grep -E "^-[^-].*(\bassert\b|\bexpect\b|\bshould\b)" | head -5 >&2
  echo "" >&2
  echo "TDDの原則 (t-wada):" >&2
  echo "  - テストを弱めてパスさせてはいけない" >&2
  echo "  - 実装を修正してテストをパスさせる" >&2
  echo "  - 「動作するきれいなコード」がゴール" >&2
  echo "" >&2
  echo "対処法:" >&2
  echo "  1. 削除したアサーションを復元" >&2
  echo "  2. 実装コードを修正してテストをパス" >&2
  echo "============================================" >&2
  exit 2
fi

# =============================================================================
# 検出パターン2: テストスキップ
# =============================================================================
if echo "$DIFF" | grep -E "^\+.*(\bit\.skip\b|\bdescribe\.skip\b|\btest\.skip\b|@skip|@pytest\.mark\.skip|\bSkip\()" > /dev/null; then
  echo "============================================" >&2
  echo "  t-wada警告: テストスキップを検出" >&2
  echo "============================================" >&2
  echo "" >&2
  echo "追加された行:" >&2
  echo "$DIFF" | grep -E "^\+.*(\bit\.skip\b|\bdescribe\.skip\b|\btest\.skip\b|@skip|@pytest\.mark\.skip)" | head -5 >&2
  echo "" >&2
  echo "TDDの原則 (t-wada):" >&2
  echo "  - テストをスキップして通すのは改ざん" >&2
  echo "  - 問題のあるテストは修正する" >&2
  echo "" >&2
  echo "例外（許容される場合）:" >&2
  echo "  - 既知の制約がIssueで追跡されている" >&2
  echo "  - 実装中の機能で明示的にWIPマーク" >&2
  echo "============================================" >&2
  exit 2
fi

# =============================================================================
# 検出パターン3: 期待値の改ざん（警告のみ）
# =============================================================================
if echo "$DIFF" | grep -E "^-.*(\btoEqual\b|\btoBe\b|\bdeepEqual\b).*\)" > /dev/null && \
   echo "$DIFF" | grep -E "^\+.*(\btoEqual\b|\btoBe\b|\bdeepEqual\b).*\)" > /dev/null; then
  echo "============================================" >&2
  echo "  t-wada注意: 期待値の変更を検出" >&2
  echo "============================================" >&2
  echo "" >&2
  echo "変更前:" >&2
  echo "$DIFF" | grep -E "^-.*(\btoEqual\b|\btoBe\b|\bdeepEqual\b)" | head -3 >&2
  echo "" >&2
  echo "変更後:" >&2
  echo "$DIFF" | grep -E "^\+.*(\btoEqual\b|\btoBe\b|\bdeepEqual\b)" | head -3 >&2
  echo "" >&2
  echo "確認事項:" >&2
  echo "  - 仕様変更に伴う正当な変更ですか？" >&2
  echo "  - 実装のバグに合わせた改ざんではないですか？" >&2
  echo "" >&2
  echo "（警告のみ、ブロックしません）" >&2
  echo "============================================" >&2
  # 警告のみ、exit 0 で通過
fi

exit 0
