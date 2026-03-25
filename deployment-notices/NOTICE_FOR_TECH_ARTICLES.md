# tech-articles への導入案内

**対象リポジトリ**: tech-articles
**導入日**: 2025-11-28以降
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. WebSearch 100%保存義務の明確化 ⭐拡張
investigate.md に保存義務を明記（既に実践している内容の明文化）

### 3. 技術ツールノウハウ集 ⭐NEW
- BibTeX管理ノウハウ
- Quarto使用法
- pdftotext/tesseract活用法

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd /path/to/tech-articles

# 既存設定をバックアップ
cp -r .claude/ .claude.backup-$(date +%Y%m%d)
```

### Step 2: デプロイ実行

```bash
cd /path/to/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n /path/to/tech-articles

# 実際にデプロイ
./scripts/deploy.sh -t /path/to/tech-articles
```

### Step 3: 設定確認

```bash
cd /path/to/tech-articles

# Stop Hook が追加されたか確認
cat .claude/settings.json | grep -A 5 "Stop"

# 新規ファイルを確認
git status
```

---

## 📝 追加されるファイル

```
tech-articles/
├── .claude/
│   ├── hooks/
│   │   └── check_uncommitted.sh ⭐NEW
│   ├── commands/
│   │   └── investigate.md（拡張版）
│   └── settings.json（Stop Hook追加）
│
├── technical-projects-cli/ ⭐NEW
│   ├── test-process-requirements.md
│   └── README.md
│
└── development/reference/
    ├── investigation-workflow-template.md ⭐NEW
    ├── technical-tools-reference.md ⭐NEW
    └── README.md（更新）
```

---

## ✅ 動作確認

### check_uncommitted.sh のテスト

```bash
# Claude Codeセッションを開始
claude-code

# テストファイル作成
echo "test" > test-file.txt

# セッションを終了（Ctrl+D）
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

---

## 🔧 settings.json の統合

**既存の settings.json がある場合**、以下を手動追加:

```json
{
  "hooks": {
    "PreToolUse": [
      // 既存の設定を保持
    ],
    "SessionStart": [
      // 既存の設定を保持
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

## 📋 CLAUDE.md への追加推奨

以下のセクションを追加することを推奨:

```markdown
### セッション終了時のコミット忘れ防止

**自動チェック**:
- `.claude/hooks/check_uncommitted.sh` がセッション終了時に未コミット変更を警告
- Untracked、Modified、Stagedファイルを表示
- コミット・プッシュ忘れを防止
```

---

## 🆘 トラブルシューティング

### check_uncommitted.sh が動作しない

```bash
# 実行権限を確認
ls -l .claude/hooks/check_uncommitted.sh

# 権限がない場合
chmod +x .claude/hooks/check_uncommitted.sh

# settings.json を確認
cat .claude/settings.json | jq .
```

### 既存の hook が上書きされた

```bash
# バックアップから復元
cp .claude.backup-YYYYMMDD/hooks/custom-hook.sh .claude/hooks/
```

---

## 🎓 参考資料

- **詳細ガイド**: `DEPLOYMENT_GUIDE.md`
- **技術ツール集**: `development/reference/technical-tools-reference.md`
- **調査ワークフロー**: `development/reference/investigation-workflow-template.md`

---

## ✅ 完了チェックリスト

- [ ] バックアップ作成
- [ ] デプロイ実行
- [ ] Stop Hook 動作確認
- [ ] CLAUDE.md 更新
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
