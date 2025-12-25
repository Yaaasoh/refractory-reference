#!/bin/bash
# エンコーディングチェックフック
# BOM付きUTF-8問題の再発防止

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# WriteツールまたはEditツールの場合のみチェック
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    # シェルスクリプトの場合、BOMチェック
    if [[ "$FILE_PATH" == *.sh ]] || [[ "$FILE_PATH" == *.bash ]]; then
        if [ -f "$FILE_PATH" ]; then
            # BOM検出（0xEF 0xBB 0xBF）
            FIRST_BYTES=$(head -c 3 "$FILE_PATH" | od -An -tx1 | tr -d ' ')
            if [ "$FIRST_BYTES" = "efbbbf" ]; then
                echo "❌ BLOCKED: $FILE_PATH contains UTF-8 BOM" >&2
                echo "💡 Shell scripts must not have BOM. Please use UTF-8 without BOM." >&2
                echo "" >&2
                echo "To fix this issue:" >&2
                echo "  1. Open the file in an editor that supports encoding selection" >&2
                echo "  2. Save as UTF-8 without BOM" >&2
                echo "  3. Or use: sed -i '1s/^\xEF\xBB\xBF//' \"$FILE_PATH\"" >&2
                exit 1
            fi

            # CRLF検出
            if grep -q $'\r' "$FILE_PATH" 2>/dev/null; then
                echo "⚠️  WARNING: $FILE_PATH contains CRLF line endings" >&2
                echo "💡 Shell scripts should use LF line endings." >&2
                echo "" >&2
                echo "To fix this issue:" >&2
                echo "  dos2unix \"$FILE_PATH\"" >&2
                echo "  or: sed -i 's/\r$//' \"$FILE_PATH\"" >&2
            fi
        fi
    fi

    # settings.local.json の変更警告
    if [[ "$FILE_PATH" == *".claude/settings.local.json" ]]; then
        echo "⚠️  WARNING: Modifying .claude/settings.local.json" >&2
        echo "💡 This file should not be committed. Consider using .claude/settings.json instead." >&2
        echo "" >&2
    fi

    # gitignore対象ファイルの変更警告
    if [ -f .gitignore ]; then
        # ファイルが.gitignoreに含まれているかチェック
        if git check-ignore -q "$FILE_PATH" 2>/dev/null; then
            echo "⚠️  WARNING: $FILE_PATH is in .gitignore" >&2
            echo "💡 This file should not be tracked or modified." >&2
            echo "" >&2
        fi
    fi
fi

# 通常フロー
echo "$INPUT"
