# account-management への導入案内

**対象リポジトリ**: account-management
**リポジトリパス**: `C:\Users\xprin\github\account-management\`
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. 安全性確保 ⭐NEW
- 破壊的コマンド自動ブロック（git clean -fd, rm -rf等）
- 大規模ファイル読み込み防止
- セッション開始時の確認プロトコル

### 3. テストプロセス要件 ⭐NEW
スクリプト作成時の完了定義: `実装 + テスト + パス = 完了`

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd C:/Users/xprin/github/account-management

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd C:/Users/xprin/github/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n C:/Users/xprin/github/account-management

# 実際にデプロイ
./scripts/deploy.sh -t C:/Users/xprin/github/account-management
```

### Step 3: 設定確認

```bash
cd C:/Users/xprin/github/account-management
git status
ls -la .claude/
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 📝 追加されるファイル

```
account-management/
├── .claude/ ⭐完全構成
│   ├── hooks/
│   │   ├── block_destructive.sh ⭐重要（誤削除防止）
│   │   ├── check_file_size.sh
│   │   ├── check_uncommitted.sh ⭐重要（コミット忘れ防止）
│   │   └── session_start.sh
│   ├── commands/
│   │   ├── investigate.md
│   │   ├── safety-check.md ⭐重要（作業前確認）
│   │   └── suggest-claude-md.md
│   ├── settings.json
│   └── README.md
│
├── technical-projects-cli/ ⭐NEW
│   ├── test-process-requirements.md
│   ├── technical-accuracy-guidelines.md
│   └── universal-instruction-quality-rules.md
│
├── development/reference/ ⭐NEW
│   ├── README_FOR_CLAUDE_TEMPLATE.md
│   ├── development-policy-template.md
│   └── README.md
│
└── CLAUDE.md ⭐推奨新規作成
```

---

## ✅ 動作確認

### check_uncommitted.sh のテスト

```bash
cd C:/Users/xprin/github/account-management
claude-code

# テストファイル作成
echo "test" > test-file.txt

# セッション終了（Ctrl+D）
# → 未コミット警告が表示されればOK
```

**期待される出力**:
```
======================================
【警告】未コミットのファイルがあります
======================================

未追跡ファイル: 1件
  test-file.txt

コミット・プッシュを忘れずに！
======================================
```

### 破壊的コマンドブロックのテスト

```bash
claude-code

# 以下のコマンドがブロックされることを確認
git clean -fd
# → ブロックされればOK
```

---

## 📋 CLAUDE.md の推奨構成（新規作成）

アカウント管理リポジトリ向けの CLAUDE.md:

```markdown
# account-management プロジェクトガイド

## プロジェクト概要

アカウント管理リポジトリ

---

## CRITICAL - セッション開始プロトコル

### セッション開始時（必須3ステップ）

1. `git status` でUntracked/変更ファイル確認
2. 既存作業の有無を確認（ユーザーに質問）
3. 作業方針を明確化

---

## 絶対禁止事項

### 破壊的コマンド（絶対実行禁止）

**アカウント情報を含むファイルの誤削除は致命的**

- `git clean -fd` / `git clean -f` / `git clean -d`
- `rm -rf <directory>` （ユーザー確認なし）
- `git reset --hard` （ユーザー確認なし）
- `git push --force` （ユーザー確認なし）

**自動ブロック**: `.claude/hooks/block_destructive.sh`

---

## 大規模ファイル読み込み禁止

**10MB以上のファイルは直接読み込み禁止**

**自動ブロック**: `.claude/hooks/check_file_size.sh`

---

## セッション終了時のコミット忘れ防止

**自動チェック**:
- `.claude/hooks/check_uncommitted.sh` がセッション終了時に未コミット変更を警告
- アカウント情報の更新漏れを防止

---

## 安全確認チェック

作業開始前に安全確認を実施:

```
/safety-check
```

チェック項目:
- [ ] git status確認済み
- [ ] 作業対象ファイル明確
- [ ] バックアップ確認
- [ ] .gitignore確認

---

## スクリプト作成時のテスト要件

**完了の定義**:
```
実装 + テスト + パス = 完了
```

アカウント操作スクリプトは必ず動作確認すること。

詳細: `technical-projects-cli/test-process-requirements.md`

---

## 参照ドキュメント

### セッション開始時
- このファイル（CLAUDE.md）

### 作業前確認
- `.claude/commands/safety-check.md`（/safety-check）
```

---

## 🎓 アカウント管理リポジトリでの活用例

### 作業開始前の安全確認

```bash
cd C:/Users/xprin/github/account-management
claude-code

# 安全確認チェックリスト実行
/safety-check
```

### スクリプト作成時のテスト

```bash
# スクリプト作成
vim update_accounts.sh

# 必ずテスト実行
bash update_accounts.sh --dry-run

# テスト成功後に本番実行
bash update_accounts.sh
```

---

## 🔧 settings.json の内容

デプロイされる `C:\Users\xprin\github\account-management\.claude\settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block_destructive.sh",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_file_size.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session_start.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_uncommitted.sh"
          }
        ]
      }
    ]
  }
}
```

---

## ⚠️ 重要: セキュリティ注意事項

### 機密情報の取り扱い

- **絶対にコミットしない**: パスワード、APIキー、トークン
- **.gitignore の確認**: 機密ファイルが除外されているか
- **環境変数の使用**: 機密情報は環境変数で管理

### 推奨: .gitignore に追加

```gitignore
# 機密情報
*.secret
*.key
credentials.json
.env
config.local.*

# バックアップ
*.backup
*.bak
```

---

## 📚 詳細ドキュメント（prompt-patternsリポジトリ内）

- **詳細ガイド**: `C:\Users\xprin\github\prompt-patterns\DEPLOYMENT_GUIDE.md`
- **テスト要件**: `C:\Users\xprin\github\prompt-patterns\technical-projects-cli\test-process-requirements.md`

---

## 🆘 トラブルシューティング

### 誤ってファイルを削除した

```bash
# Untracked ファイルの場合
# → バックアップから復元

# コミット済みファイルの場合
git checkout HEAD -- <ファイル名>

# ステージ済み（未コミット）の場合
git restore --staged <ファイル名>
git restore <ファイル名>
```

### check_uncommitted.sh が動作しない

```bash
# 実行権限を確認
ls -l .claude/hooks/check_uncommitted.sh

# 権限がない場合
chmod +x .claude/hooks/check_uncommitted.sh
```

---

## ✅ 完了チェックリスト

- [ ] バックアップ作成（既存の .claude/ がある場合）
- [ ] デプロイ実行
- [ ] Hooks 動作確認（破壊的コマンドブロック、Stop Hook）
- [ ] CLAUDE.md 作成（推奨）
- [ ] .gitignore確認（機密情報除外）
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
