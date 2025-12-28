#!/bin/bash
# 未コミットファイル警告
# Stop hook で実行
# セッション終了時に未コミットの変更があれば警告

# Gitリポジトリのルートに移動
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

# 未追跡ファイル
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

# 変更されたファイル（未ステージ）
MODIFIED=$(git diff --name-only 2>/dev/null)

# ステージ済みファイル
STAGED=$(git diff --cached --name-only 2>/dev/null)

# カウント
UNTRACKED_COUNT=$(echo "$UNTRACKED" | grep -c . 2>/dev/null || echo 0)
MODIFIED_COUNT=$(echo "$MODIFIED" | grep -c . 2>/dev/null || echo 0)
STAGED_COUNT=$(echo "$STAGED" | grep -c . 2>/dev/null || echo 0)

# 何かあれば警告
if [ "$UNTRACKED_COUNT" -gt 0 ] || [ "$MODIFIED_COUNT" -gt 0 ] || [ "$STAGED_COUNT" -gt 0 ]; then
    echo ""
    echo "========================================"
    echo "【警告】未コミットのファイルがあります"
    echo "========================================"

    if [ "$UNTRACKED_COUNT" -gt 0 ]; then
        echo ""
        echo "未追跡ファイル: ${UNTRACKED_COUNT}件"
        echo "$UNTRACKED" | head -5
        [ "$UNTRACKED_COUNT" -gt 5 ] && echo "  ...他 $((UNTRACKED_COUNT - 5)) 件"
    fi

    if [ "$MODIFIED_COUNT" -gt 0 ]; then
        echo ""
        echo "変更ファイル（未ステージ）: ${MODIFIED_COUNT}件"
        echo "$MODIFIED" | head -5
        [ "$MODIFIED_COUNT" -gt 5 ] && echo "  ...他 $((MODIFIED_COUNT - 5)) 件"
    fi

    if [ "$STAGED_COUNT" -gt 0 ]; then
        echo ""
        echo "ステージ済み（未コミット）: ${STAGED_COUNT}件"
        echo "$STAGED" | head -5
        [ "$STAGED_COUNT" -gt 5 ] && echo "  ...他 $((STAGED_COUNT - 5)) 件"
    fi

    echo ""
    echo "コミット・プッシュを忘れずに！"
    echo "========================================"
    echo ""
fi

# Stop hookは常に成功で終了
exit 0
