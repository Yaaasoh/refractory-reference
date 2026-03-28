#!/bin/bash
# memory_db_rebuild.sh — SessionStart hook
# memory.dbが存在しない場合、NDJSON dataから自動rebuild
#
# 設定例 (settings.json):
# {
#   "hooks": {
#     "SessionStart": [
#       {
#         "matcher": "startup|clear",
#         "hooks": [{ "type": "command", "command": "bash .claude/hooks/memory_db_rebuild.sh" }]
#       }
#     ]
#   }
# }

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
DB_PATH="$PROJECT_DIR/.claude/memory.db"
DATA_DIR="$PROJECT_DIR/.claude/memory-data"
# Script path: .claude/scripts/ (deployed) or shared/scripts/ (source repo)
REBUILD_SCRIPT="$PROJECT_DIR/.claude/scripts/memory-db/rebuild_db.py"
if [ ! -f "$REBUILD_SCRIPT" ]; then
  REBUILD_SCRIPT="$PROJECT_DIR/shared/scripts/memory-db/rebuild_db.py"
fi

# DB already exists — nothing to do
if [ -f "$DB_PATH" ]; then
  exit 0
fi

# No NDJSON data — nothing to rebuild from
if [ ! -d "$DATA_DIR" ] || [ -z "$(ls "$DATA_DIR"/*.ndjson 2>/dev/null)" ]; then
  exit 0
fi

# No rebuild script — skip
if [ ! -f "$REBUILD_SCRIPT" ]; then
  exit 0
fi

# Rebuild DB from NDJSON
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
  python3 "$REBUILD_SCRIPT" --data-dir "$DATA_DIR" --db-path "$DB_PATH" 2>&1
else
  py -3.11 "$REBUILD_SCRIPT" --data-dir "$DATA_DIR" --db-path "$DB_PATH" 2>&1
fi

exit 0
