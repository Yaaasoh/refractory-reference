#!/bin/bash
# protect_embeddings.sh — PreToolUse Bash hook
# embedding計算結果（.npyファイル）の誤削除を防止する
#
# 設定例 (settings.json):
# {
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Bash",
#         "hooks": [{ "type": "command", "command": "bash .claude/hooks/protect_embeddings.sh" }]
#       }
#     ]
#   }
# }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check for commands that would delete .npy embedding cache files
if echo "$COMMAND" | grep -qE '(rm|del|remove|unlink).*\.(npy|npz)'; then
  echo "========================================" >&2
  echo "  embedding計算結果の削除を検出" >&2
  echo "  .npy/.npzファイルは計算に数時間かかります" >&2
  echo "  削除する場合は手動で実行してください" >&2
  echo "========================================" >&2
  echo '{"decision":"block","reason":"Embedding cache files (.npy) are expensive to recompute (hours). Delete manually if intended."}'
  exit 0
fi

# Check for commands that would delete embedding_backup directory
if echo "$COMMAND" | grep -qE '(rm|del|remove).*embedding_backup'; then
  echo "========================================" >&2
  echo "  embedding_backupディレクトリの削除を検出" >&2
  echo "  バックアップは計算結果のセーフティネットです" >&2
  echo "  削除する場合は手動で実行してください" >&2
  echo "========================================" >&2
  echo '{"decision":"block","reason":"Embedding backup directory is a safety net for expensive computations. Delete manually if intended."}'
  exit 0
fi

# Check for commands that would delete memory.db while embedding computation may be running
if echo "$COMMAND" | grep -qE '(rm|del).*memory\.db'; then
  # Check if embedding computation is in progress
  if ls "${CLAUDE_PROJECT_DIR:-.}/.claude/memory_chunk_ids.npy" >/dev/null 2>&1; then
    echo "========================================" >&2
    echo "  embedding計算中にmemory.dbの削除を検出" >&2
    echo "  計算結果がロストします" >&2
    echo "========================================" >&2
    echo '{"decision":"block","reason":"Embedding computation in progress. Do not delete memory.db."}'
    exit 0
  fi
fi

echo "$INPUT"
exit 0
