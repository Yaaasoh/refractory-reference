#!/bin/bash
# memory_db_sync.sh — PostToolUse Edit|Write hook
# .md/.bib ファイルの変更を検出し、memory DBに同期する
#
# 設定例 (settings.json):
# {
#   "hooks": {
#     "PostToolUse": [
#       {
#         "matcher": "Edit|Write",
#         "hooks": [{ "type": "command", "command": "bash .claude/hooks/memory_db_sync.sh" }]
#       }
#     ]
#   }
# }

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only process .md and .bib files
case "$FILE_PATH" in
  *.md|*.bib|*.txt) ;;
  *) exit 0 ;;
esac

# Skip node_modules, .git, etc.
case "$FILE_PATH" in
  *node_modules*|*.git/*|*__pycache__*) exit 0 ;;
esac

# DB path
DB_PATH="${CLAUDE_PROJECT_DIR:-.}/.claude/memory.db"

# Script path: .claude/scripts/ (deployed) or shared/scripts/ (source repo)
SCRIPTS_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/scripts/memory-db"
if [ ! -d "$SCRIPTS_DIR" ]; then
  SCRIPTS_DIR="${CLAUDE_PROJECT_DIR:-.}/shared/scripts/memory-db"
fi

# Ensure DB exists (init if needed)
if [ ! -f "$DB_PATH" ]; then
  INIT_SCRIPT="$SCRIPTS_DIR/init_db.py"
  if [ -f "$INIT_SCRIPT" ]; then
    if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
      python3 "$INIT_SCRIPT" --db-path "$DB_PATH" 2>/dev/null
    else
      py -3.11 "$INIT_SCRIPT" --db-path "$DB_PATH" 2>/dev/null
    fi
  fi
fi

# Sync file to DB
SYNC_SCRIPT="$SCRIPTS_DIR/sync_to_db.py"
if [ -f "$SYNC_SCRIPT" ] && [ -f "$DB_PATH" ]; then
  if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
    RESULT=$(python3 "$SYNC_SCRIPT" --file "$FILE_PATH" --db-path "$DB_PATH" 2>/dev/null)
  else
    RESULT=$(py -3.11 "$SYNC_SCRIPT" --file "$FILE_PATH" --db-path "$DB_PATH" 2>/dev/null)
  fi
fi

exit 0
