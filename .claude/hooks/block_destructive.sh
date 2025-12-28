#!/bin/bash
# 破壊的コマンドをブロックするPreToolUse Hook
# Settings denyの限界を補完

# 標準入力からJSONを読み込み
INPUT=$(cat)

# ツール名とコマンドを抽出
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Bashツールの場合のみチェック
if [ "$TOOL_NAME" = "Bash" ]; then
    # 危険なパターン
    DANGEROUS_PATTERNS=(
        "rm -rf"
        "rm -r "
        "git clean -fd"
        "git clean -f"
        "git reset --hard"
        "find .* -delete"
        "> /dev/null"
        "chmod 777"
    )

    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -q "$pattern"; then
            echo "破壊的コマンドは禁止されています: $pattern" >&2
            exit 2
        fi
    done
fi

# 許可（何も出力しないか、exit 0）
exit 0
