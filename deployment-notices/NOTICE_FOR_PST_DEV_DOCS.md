# pst_dev_docs への導入案内

**対象リポジトリ**: pst_dev_docs
**リポジトリパス**: `C:\Users\xprin\github\pst_dev_docs\`
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. 開発ドキュメント向け機能 ⭐NEW
- 調査ワークフロー標準化（WebSearch 100%保存義務）
- 技術ツールノウハウ集
- 6フェーズ開発プロセステンプレート

### 3. テストプロセス要件 ⭐NEW
コード例・スクリプト作成時の完了定義: `実装 + テスト + パス = 完了`

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd C:/Users/xprin/github/pst_dev_docs

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd C:/Users/xprin/github/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n C:/Users/xprin/github/pst_dev_docs

# 実際にデプロイ
./scripts/deploy.sh -t C:/Users/xprin/github/pst_dev_docs
```

### Step 3: 設定確認

```bash
cd C:/Users/xprin/github/pst_dev_docs
git status
ls -la .claude/
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 📝 追加されるファイル

```
pst_dev_docs/
├── .claude/ ⭐完全構成
│   ├── hooks/
│   │   ├── block_destructive.sh
│   │   ├── check_file_size.sh
│   │   ├── check_uncommitted.sh ⭐重要
│   │   └── session_start.sh
│   ├── commands/
│   │   ├── investigate.md
│   │   ├── safety-check.md
│   │   └── suggest-claude-md.md
│   ├── settings.json
│   └── README.md
│
├── technical-projects-cli/ ⭐NEW
│   ├── test-process-requirements.md ⭐重要
│   ├── technical-accuracy-guidelines.md
│   └── universal-instruction-quality-rules.md
│
├── development/reference/ ⭐NEW
│   ├── README_FOR_CLAUDE_TEMPLATE.md
│   ├── development-policy-template.md
│   ├── investigation-workflow-template.md
│   ├── 6phase-development-template.md ⭐開発向け
│   ├── technical-tools-reference.md
│   └── README.md
│
└── CLAUDE.md ⭐推奨新規作成
```

---

## ✅ 動作確認

### check_uncommitted.sh のテスト

```bash
cd C:/Users/xprin/github/pst_dev_docs
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

---

## 📋 CLAUDE.md の推奨構成（新規作成）

開発ドキュメントリポジトリ向けの CLAUDE.md:

```markdown
# pst_dev_docs プロジェクトガイド

## プロジェクト概要

開発ドキュメントリポジトリ

---

## CRITICAL - セッション開始プロトコル

### セッション開始時（必須3ステップ）

1. `git status` でUntracked/変更ファイル確認
2. 既存作業の有無を確認（ユーザーに質問）
3. 作業方針を明確化

---

## 絶対禁止事項

### 破壊的コマンド（絶対実行禁止）

- `git clean -fd` / `git clean -f` / `git clean -d`
- `rm -rf <directory>` （ユーザー確認なし）
- `git reset --hard` （ユーザー確認なし）
- `git push --force` （ユーザー確認なし）

**自動ブロック**: `.claude/hooks/block_destructive.sh`

---

## 大規模ファイル読み込み禁止

**10MB以上のファイルは直接読み込み禁止**

**対処法**:
- PDF: `pdftotext file.pdf - | head -1000`
- 大規模テキスト: `head -500 file.txt`

**自動ブロック**: `.claude/hooks/check_file_size.sh`

---

## セッション終了時のコミット忘れ防止

**自動チェック**:
- `.claude/hooks/check_uncommitted.sh` がセッション終了時に未コミット変更を警告
- コミット・プッシュ忘れを防止

---

## 開発ドキュメント作成のルール

### テストプロセス要件

**完了の定義**:
```
実装 + テスト + パス = 完了
```

ドキュメントに含まれるコード例・スクリプトは必ず動作確認すること。

詳細: `technical-projects-cli/test-process-requirements.md`

### 調査ワークフロー

WebSearch結果の100%保存義務:
- WebSearch実施日
- 検索クエリ
- 情報源URL
- 抽出情報

詳細: `development/reference/investigation-workflow-template.md`

### 6フェーズ開発プロセス

プロトタイプ・実装例作成時の標準プロセス:
1. 仕様妥当性確認
2. 実装
3. 実動作確認（手動優先）
4. 整合性検証
5. 必要最小限テスト
6. 文書化

詳細: `development/reference/6phase-development-template.md`

---

## 参照ドキュメント

### セッション開始時
- このファイル（CLAUDE.md）

### 調査時
- `development/reference/investigation-workflow-template.md`
- `.claude/commands/investigate.md`（/investigate）

### 開発時
- `development/reference/6phase-development-template.md`
- `technical-projects-cli/test-process-requirements.md`
```

---

## 🎓 開発ドキュメントリポジトリでの活用例

### コード例作成時のテストプロセス

```markdown
## 実装完了チェックリスト

- [ ] コードを書いた
- [ ] テストを実行した
- [ ] テストが成功した
- [ ] 実際の動作を確認した
- [ ] エラーがないことを確認した
→ 完了
```

### 6フェーズプロセスの活用

```bash
# 6フェーズテンプレートを参照
cat development/reference/6phase-development-template.md

# Phase 1: 仕様妥当性確認
# Phase 2: 実装
# Phase 3: 実動作確認（手動優先）
# Phase 4: 整合性検証
# Phase 5: 必要最小限テスト
# Phase 6: 文書化
```

---

## 🔧 settings.json の内容

デプロイされる `C:\Users\xprin\github\pst_dev_docs\.claude\settings.json`:

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

## 📚 詳細ドキュメント（prompt-patternsリポジトリ内）

- **詳細ガイド**: `C:\Users\xprin\github\prompt-patterns\DEPLOYMENT_GUIDE.md`
- **6フェーズ開発**: `C:\Users\xprin\github\prompt-patterns\development\reference\6phase-development-template.md`
- **テスト要件**: `C:\Users\xprin\github\prompt-patterns\technical-projects-cli\test-process-requirements.md`
- **調査ワークフロー**: `C:\Users\xprin\github\prompt-patterns\development\reference\investigation-workflow-template.md`
- **技術ツール集**: `C:\Users\xprin\github\prompt-patterns\development\reference\technical-tools-reference.md`

---

## 🆘 トラブルシューティング

### デプロイスクリプトが見つからない

```bash
# prompt-patternsを最新化
cd C:/Users/xprin/github/prompt-patterns
git pull origin main

# 実行権限を確認
chmod +x scripts/deploy.sh
```

### check_uncommitted.sh が動作しない

```bash
# 実行権限を確認
ls -l .claude/hooks/check_uncommitted.sh

# 権限がない場合
chmod +x .claude/hooks/check_uncommitted.sh

# settings.json を確認
cat .claude/settings.json | jq .
```

---

## ✅ 完了チェックリスト

- [ ] バックアップ作成（既存の .claude/ がある場合）
- [ ] デプロイ実行
- [ ] Hooks 動作確認（Stop Hook）
- [ ] CLAUDE.md 作成（推奨）
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
