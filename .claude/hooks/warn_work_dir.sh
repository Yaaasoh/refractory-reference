#!/bin/bash
# R27: work/外への新規ファイル作成を警告
# PreToolUse Write で実行
# ブロックではなくadditionalContextで注意喚起

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 空パスは無視
[ -z "$FILE_PATH" ] && exit 0

# 既存ファイルへの上書きは警告不要
[ -f "$FILE_PATH" ] && exit 0

# work/ 配下、.claude/ 配下、shared/ 配下は許可（警告なし）
if echo "$FILE_PATH" | grep -qE '(/work/|^work/|/\.claude/|^\.claude/|/shared/|^shared/|/scripts/|^scripts/|/deployment-notices/|^deployment-notices/)'; then
    exit 0
fi

# パッケージディレクトリはR26でブロック済み、ここでは対象外
# それ以外のwork/外ファイル作成を警告
echo ""
echo "⚠️ work/外への新規ファイル作成を検出しました"
echo "  パス: $FILE_PATH"
echo "  作業ファイルはwork/配下に作成してください（CLAUDE.md参照）"
echo ""

exit 0
