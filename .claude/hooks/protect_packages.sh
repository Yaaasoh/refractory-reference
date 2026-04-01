#!/bin/bash
# R26: パッケージディレクトリの直接編集を禁止
# PreToolUse Edit|Write で実行

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# 保護対象ディレクトリ
PROTECTED_DIRS=(
    "technical-projects-cli/"
    "technical-projects/"
    "prompt-creation-projects-cli/"
    "prompt-creation-projects/"
    "claude-projects/"
    "shared-knowledge/"
)

for dir in "${PROTECTED_DIRS[@]}"; do
    if echo "$FILE_PATH" | grep -q "/$dir\|^$dir"; then
        echo '{"decision":"block","reason":"パッケージディレクトリの直接編集は禁止です。shared/配下を編集しdeploy.shで展開してください。対象: '"$dir"'"}' | jq .
        exit 0
    fi
done

exit 0
