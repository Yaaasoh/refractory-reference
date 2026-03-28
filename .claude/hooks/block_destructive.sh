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
        "git rm"
        "git clean -fd"
        "git clean -f"
        "git reset --hard"
        "find .* -delete"
        "chmod 777"
    )

    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -q "$pattern"; then
            echo "破壊的コマンドは禁止されています: $pattern" >&2
            exit 2
        fi
    done

    # 安全チェック回避の検出（INC-020教訓）
    BYPASS_PATTERNS=(
        "--skip-preflight"
        "--no-verify"
        "--force"
    )

    for pattern in "${BYPASS_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -q -- "$pattern"; then
            echo "" >&2
            echo "========================================" >&2
            echo "  安全チェックの回避は禁止されています" >&2
            echo "  検出: $pattern" >&2
            echo "========================================" >&2
            echo "" >&2
            echo "  安全チェックを回避するのではなく、根本原因を解決しろ。" >&2
            echo "  Fix Forward, Not Backward（改ざん防止ルール）" >&2
            echo "" >&2
            echo "  閾値が実情に合わないなら config.py を修正する。" >&2
            echo "  テストが通らないならテストではなく実装を直す。" >&2
            echo "  hookが邪魔ならhookではなくコードを直す。" >&2
            echo "" >&2
            exit 2
        fi
    done
fi

# 許可（何も出力しないか、exit 0）
exit 0
