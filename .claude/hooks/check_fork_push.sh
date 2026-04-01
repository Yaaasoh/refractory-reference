#!/bin/bash
# フォークリポジトリへのgit pushブロック Hook
# PreToolUse: Bash で実行
# 第二十二の罪（2026-03-28）対策: 他者所有フォークへの誤push防止

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# git push コマンドでなければスルー
if ! echo "$COMMAND" | grep -qE "git\s+push"; then
    exit 0
fi

# リモートURLからオーナーを取得
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    exit 0
fi

# GitHubオーナーを抽出
OWNER=""
if echo "$REMOTE_URL" | grep -qE "github\.com[:/]"; then
    OWNER=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+)/.*|\1|')
fi

# Yaaasoh以外のオーナーならブロック
if [ -n "$OWNER" ] && [ "$OWNER" != "Yaaasoh" ]; then
    REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    echo "" >&2
    echo "===========================================" >&2
    echo "【ブロック】他者所有リポジトリへのpush禁止" >&2
    echo "===========================================" >&2
    echo "" >&2
    echo "リポジトリ: $REPO_NAME" >&2
    echo "所有者: $OWNER (Yaaasohではない)" >&2
    echo "リモート: $REMOTE_URL" >&2
    echo "" >&2
    echo "フォークリポジトリへのpushは一切禁止です。" >&2
    echo "参照: ATONEMENT_SYSTEM.md 第二十二の罪" >&2
    echo "" >&2
    echo '{"blocked": true, "reason": "フォークリポジトリへのpush禁止 (第二十二の罪)"}' | jq .
    exit 0
fi

exit 0
