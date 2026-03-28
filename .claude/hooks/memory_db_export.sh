#!/bin/bash
# memory_db_export.sh — Stop hook
# セッション終了時にmemory.dbの内容をNDJSONにエクスポート
# git-friendly形式で保存し、次回セッションでrebuild可能にする
#
# 設定例 (settings.json):
# {
#   "hooks": {
#     "Stop": [
#       {
#         "hooks": [{ "type": "command", "command": "bash .claude/hooks/memory_db_export.sh", "timeout": 30 }]
#       }
#     ]
#   }
# }

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
DB_PATH="$PROJECT_DIR/.claude/memory.db"
DATA_DIR="$PROJECT_DIR/.claude/memory-data"
# Script path: .claude/scripts/ (deployed) or shared/scripts/ (source repo)
EXPORT_SCRIPT="$PROJECT_DIR/.claude/scripts/memory-db/export_ndjson.py"
if [ ! -f "$EXPORT_SCRIPT" ]; then
  EXPORT_SCRIPT="$PROJECT_DIR/shared/scripts/memory-db/export_ndjson.py"
fi

# No DB — nothing to export
if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# No export script — skip
if [ ! -f "$EXPORT_SCRIPT" ]; then
  exit 0
fi

# Ensure output directory exists
mkdir -p "$DATA_DIR" || { echo "[memory-db] ERROR: cannot create $DATA_DIR" >&2; exit 0; }

# Export DB to NDJSON
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
  RESULT=$(python3 "$EXPORT_SCRIPT" --db-path "$DB_PATH" --out-dir "$DATA_DIR" 2>&1)
else
  RESULT=$(py -3.11 "$EXPORT_SCRIPT" --db-path "$DB_PATH" --out-dir "$DATA_DIR" 2>&1)
fi
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "[memory-db] ERROR: export failed (exit $EXIT_CODE)" >&2
elif [ -n "$RESULT" ]; then
  echo "[memory-db] exported: $RESULT"
fi

exit 0
