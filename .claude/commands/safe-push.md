---
description: 順を追って安全かつ適切にプッシュ
allowed-tools:
  - Bash
---

# 安全なプッシュ手順

## 実行手順

### Step 1: 現状確認

```bash
git status
```

確認ポイント:
- [ ] 変更ファイルは意図したものか
- [ ] 意図しないファイルが含まれていないか
- [ ] `.gitignore` 対象ファイルが含まれていないか

### Step 2: 差分確認

```bash
git diff
git diff --cached
```

確認ポイント:
- [ ] 変更内容は正しいか
- [ ] 機密情報が含まれていないか
- [ ] デバッグコードが残っていないか

### Step 3: リモート状態確認

```bash
git fetch --all
git status
```

確認ポイント:
- [ ] リモートより behind の場合は先に pull が必要
- [ ] コンフリクトの可能性を確認

### Step 4: ステージング

```bash
git add [対象ファイル]
# または
git add -p  # 対話的に選択
```

**注意**: `git add .` は避け、ファイルを明示的に指定

### Step 5: コミット

```bash
git commit -m "$(cat <<'EOF'
[コミットメッセージ]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Step 6: 最終確認

```bash
git log --oneline -3
git diff origin/main..HEAD --stat
```

確認ポイント:
- [ ] コミットメッセージは適切か
- [ ] プッシュ対象のコミットは正しいか

### Step 7: プッシュ

```bash
git push origin [ブランチ名]
```

### Step 8: 結果確認

```bash
git status
git log --oneline -1
```

## 禁止事項

以下は**絶対禁止**:
- `git push --force`
- `git reset --hard`
- `git clean -fd`

## 問題発生時

### リモートより behind の場合

```bash
git pull --rebase origin main
# コンフリクト解消後
git push origin main
```

### 誤ってコミットした場合

**ユーザーに相談してから対応**（自己判断でforce pushしない）

## チェックリスト（最終確認）

プッシュ前に以下を確認:
- [ ] git status で想定外のファイルがないか
- [ ] git diff で変更内容を確認したか
- [ ] コミットメッセージは適切か
- [ ] リモートとの同期状態を確認したか
