#!/bin/bash
# セッション開始時の案内
# SessionStart hook
# テンプレート: deploy.shでrefractory-reference-freshを置換

echo ""
echo "========================================"
echo "   refractory-reference-fresh セッション開始"
echo "========================================"
echo ""
echo "【重要】このリポジトリでは破壊的コマンドが禁止されています。"
echo ""
echo "  禁止: rm -rf, git clean -fd, git reset --hard"
echo "  詳細: CLAUDE.md"
echo ""

# --- 未読deployment-notices検出 ---
# パス解決: このファイルは .claude/hooks/session_start.sh に配置される
#   dirname "$0"       = .claude/hooks
#   dirname "$0"/..    = .claude      (.notices-read の格納先)
#   dirname "$0"/../.. = リポルート   (deployment-notices/ の格納先)
# CWD=リポルートはClaude Code hookの保証事項
__NOTICES_DIR="$(cd "$(dirname "$0")/../.." && pwd)/deployment-notices"
__NOTICES_READ="$(cd "$(dirname "$0")/.." && pwd)/.notices-read"

if [ -d "$__NOTICES_DIR" ]; then
  # .notices-readが存在しなければ作成（.claude/未作成時はsilent fail、全件未読扱い）
  touch "$__NOTICES_READ" 2>/dev/null
  __UNREAD_COUNT=0
  __UNREAD_LIST=""
  # glob未マッチ時は [ -f ] ガードで安全にスキップ
  for __f in "$__NOTICES_DIR"/UPDATE_*.md; do
    [ -f "$__f" ] || continue
    __BASENAME=$(basename "$__f")
    if ! grep -Fxq "$__BASENAME" "$__NOTICES_READ" 2>/dev/null; then
      __UNREAD_COUNT=$((__UNREAD_COUNT + 1))
      __TITLE=$(head -1 "$__f" | sed 's/^# *//')
      if [ -z "$__UNREAD_LIST" ]; then
        __UNREAD_LIST="  - ${__TITLE} (${__BASENAME})"
      else
        __UNREAD_LIST="${__UNREAD_LIST}
  - ${__TITLE} (${__BASENAME})"
      fi
    fi
  done
  if [ "$__UNREAD_COUNT" -gt 0 ]; then
    echo ""
    echo "【未読アップデート通知: ${__UNREAD_COUNT}件】"
    printf '%s\n' "$__UNREAD_LIST"
    echo ""
    echo "  確認: deployment-notices/ 配下を参照"
    echo "  既読化: echo 'FILENAME' >> .claude/.notices-read"
  fi
fi
unset __NOTICES_DIR __NOTICES_READ __UNREAD_COUNT __UNREAD_LIST __f __BASENAME __TITLE
echo "========================================"
echo ""
