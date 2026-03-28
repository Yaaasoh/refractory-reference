#!/bin/bash
# 大規模ファイル読み込みブロッカー
# PreToolUse hook for Read tool
# 10MB以上のファイル読み込みをブロックし、エラーループを防止

# 設定: 最大ファイルサイズ (bytes)
MAX_SIZE_BYTES=$((10 * 1024 * 1024))  # 10MB
MAX_SIZE_MB=10

# 警告サイズ
WARN_SIZE_BYTES=$((5 * 1024 * 1024))  # 5MB

# JSONパース
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty' 2>/dev/null)

# Readツール以外は許可
if [ "$TOOL_NAME" != "Read" ]; then
    exit 0
fi

# ファイルパス取得
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)

# パスが空なら許可
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# ファイルが存在しない場合は許可
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# ファイルサイズ取得
FILE_SIZE=$(stat -c%s "$FILE_PATH" 2>/dev/null || stat -f%z "$FILE_PATH" 2>/dev/null || echo "0")

# サイズ制限チェック
if [ "$FILE_SIZE" -gt "$MAX_SIZE_BYTES" ]; then
    SIZE_MB=$((FILE_SIZE / 1024 / 1024))
    FILENAME=$(basename "$FILE_PATH")
    EXTENSION="${FILENAME##*.}"

    # PDF特別メッセージ
    if [ "${EXTENSION,,}" = "pdf" ]; then
        echo "【大規模ファイル警告】${FILENAME} (${SIZE_MB}MB) は読み込み上限 ${MAX_SIZE_MB}MB を超えています。PDFの場合: pdftotext でテキスト抽出してください。再試行は無効です。" >&2
    else
        echo "【大規模ファイル警告】${FILENAME} (${SIZE_MB}MB) は読み込み上限 ${MAX_SIZE_MB}MB を超えています。対処法: head, tail等で必要な部分のみ抽出してください。再試行は無効です。" >&2
    fi
    exit 2
fi

# 警告サイズ以上
if [ "$FILE_SIZE" -gt "$WARN_SIZE_BYTES" ]; then
    SIZE_MB=$((FILE_SIZE / 1024 / 1024))
    echo "【注意】大きなファイル (${SIZE_MB}MB) を読み込みます。" >&2
fi

exit 0
