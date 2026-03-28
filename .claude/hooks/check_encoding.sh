#!/bin/bash
# エンコーディングチェックフック（強化版）
# BOM付きUTF-8問題の再発防止
# CRLF問題の自動修正（INC-20260121対策）
# .gitattributes eol=lf 対象全拡張子のCRLF→LF変換（INC-20260327対策）

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# .gitattributes で eol=lf を指定している拡張子か判定
is_eol_lf_target() {
    case "$1" in
        *.sh|*.bash|*.py|*.js|*.ts|*.json|*.md|*.yaml|*.yml|*.txt|*.csv)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# WriteツールまたはEditツールの場合のみチェック
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    # シェルスクリプトの場合、BOMチェック（CRLF修正は下の共通処理で実施）
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
                exit 2  # exit 2 = block
            fi
        fi
    fi

    # eol=lf対象拡張子のCRLF検出と自動修正
    if is_eol_lf_target "$FILE_PATH"; then
        if [ -f "$FILE_PATH" ] && grep -q $'\r' "$FILE_PATH" 2>/dev/null; then
            echo "⚠️  CRLF detected in $FILE_PATH" >&2
            echo "🔧 Auto-fixing..." >&2

            # 自動修正を試行
            if command -v dos2unix &> /dev/null; then
                dos2unix "$FILE_PATH" 2>/dev/null
                FIX_RESULT=$?
            else
                sed -i 's/\r$//' "$FILE_PATH"
                FIX_RESULT=$?
            fi

            # 修正結果を確認
            if [ $FIX_RESULT -eq 0 ] && ! grep -q $'\r' "$FILE_PATH" 2>/dev/null; then
                echo "✅ Fixed: $FILE_PATH (CRLF → LF)" >&2
                # additionalContext: 再発防止の注意喚起
                ESCAPED=$(printf '%s' "[encoding] ${FILE_PATH} のCRLFを自動修正しました。WriteツールはCRLFで書き込むことがあります。" | jq -Rs '.')
                echo "{\"hookSpecificOutput\":{\"additionalContext\":${ESCAPED}}}"
            else
                echo "❌ BLOCKED: Failed to fix CRLF in $FILE_PATH" >&2
                echo "💡 Please manually run: dos2unix \"$FILE_PATH\"" >&2
                exit 2  # exit 2 = block
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
