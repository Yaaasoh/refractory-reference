#!/bin/bash
# 公開リポジトリ検出Hook
# SessionStartで実行し、公開リポジトリの場合は警告を表示
# INC-005対策

# 現在のリポジトリ名を取得
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)

# 公開リポジトリリスト
PUBLIC_REPOS=(
    "flying-robot-contest-rules-public"
    "jsbsim-xml-generator"
)

# 公開リポジトリかチェック
is_public=false
for public_repo in "${PUBLIC_REPOS[@]}"; do
    if [ "$REPO_NAME" = "$public_repo" ]; then
        is_public=true
        break
    fi
done

# 警告表示
if [ "$is_public" = true ]; then
    echo ""
    echo "========================================"
    echo "【警告】公開リポジトリで作業中"
    echo "========================================"
    echo ""
    echo "  リポジトリ: $REPO_NAME"
    echo ""
    echo "  注意事項:"
    echo "  - .claude/ をコミット・プッシュしない"
    echo "  - 機密情報を含むファイルを作成しない"
    echo "  - 変更前に .gitignore を確認"
    echo ""
    echo "  参照: INC-005 公開リポジトリ汚染事件"
    echo ""
    echo "========================================"
    echo ""
fi
