# jsbsim-flightgear-guide への導入案内

**対象リポジトリ**: jsbsim-flightgear-guide
**リポジトリパス**: `C:\Users\xprin\github\jsbsim-flightgear-guide\`
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. 技術文書作成向け機能 ⭐NEW
- 調査ワークフロー標準化（WebSearch 100%保存義務）
- 技術ツールノウハウ集（BibTeX、引用管理等）
- 文書品質基準

### 3. テストプロセス要件 ⭐NEW
コード例・スクリプト作成時の完了定義: `実装 + テスト + パス = 完了`

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd C:/Users/xprin/github/jsbsim-flightgear-guide

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd C:/Users/xprin/github/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n C:/Users/xprin/github/jsbsim-flightgear-guide

# 実際にデプロイ
./scripts/deploy.sh -t C:/Users/xprin/github/jsbsim-flightgear-guide
```

### Step 3: 設定確認

```bash
cd C:/Users/xprin/github/jsbsim-flightgear-guide
git status
ls -la .claude/
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 📝 追加されるファイル

```
jsbsim-flightgear-guide/
├── .claude/ ⭐完全構成
│   ├── hooks/
│   │   ├── block_destructive.sh（破壊的コマンドブロック）
│   │   ├── check_file_size.sh（大規模ファイル制限）
│   │   ├── check_uncommitted.sh ⭐重要（コミット忘れ防止）
│   │   └── session_start.sh（セッション開始案内）
│   ├── commands/
│   │   ├── investigate.md（調査セッション）
│   │   ├── safety-check.md（安全確認）
│   │   └── suggest-claude-md.md（CLAUDE.md更新提案）
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
│   ├── investigation-workflow-template.md
│   ├── technical-tools-reference.md
│   └── README.md
│
└── CLAUDE.md ⭐推奨新規作成
```

---

## ✅ 動作確認

### check_uncommitted.sh のテスト

```bash
cd C:/Users/xprin/github/jsbsim-flightgear-guide
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

ガイド文書リポジトリ向けの CLAUDE.md を作成することを推奨:

```markdown
# jsbsim-flightgear-guide プロジェクトガイド

## プロジェクト概要

JSBSim/FlightGearの技術ガイド文書リポジトリ

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

**10MB以上のファイルは直接読み込み禁止**（特にPDF）

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

## 技術文書作成のルール

### WebSearch結果の100%保存義務

調査作業時は以下を必ず保存:
- WebSearch実施日
- 検索クエリ
- 情報源URL
- 抽出情報

詳細: `.claude/commands/investigate.md`（/investigate コマンド）

### 引用・参照管理

技術文書作成時の引用ルールを遵守。

参照: `development/reference/technical-tools-reference.md`（BibTeX管理）

---

## コード例・スクリプトのテスト要件

**完了の定義**:
```
実装 + テスト + パス = 完了
```

ガイドに含まれるコード例は必ず動作確認すること。

詳細: `technical-projects-cli/test-process-requirements.md`

---

## 参照ドキュメント

### セッション開始時
- このファイル（CLAUDE.md）

### 調査時
- `development/reference/investigation-workflow-template.md`
- `.claude/commands/investigate.md`（/investigate）

### 文書作成時
- `development/reference/technical-tools-reference.md`
- `technical-projects-cli/technical-accuracy-guidelines.md`
```

---

## 🎓 技術文書リポジトリでの活用例

### 調査セッション開始時

```bash
cd C:/Users/xprin/github/jsbsim-flightgear-guide
claude-code

# 調査セッション開始
/investigate
```

### 技術ツール参照

```bash
# BibTeX管理ノウハウを確認
cat development/reference/technical-tools-reference.md | grep -A 20 "BibTeX"

# 調査ワークフロー標準を確認
cat development/reference/investigation-workflow-template.md
```

---

## 🔧 settings.json の内容

デプロイされる `C:\Users\xprin\github\jsbsim-flightgear-guide\.claude\settings.json`:

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
- **技術ツール集**: `C:\Users\xprin\github\prompt-patterns\development\reference\technical-tools-reference.md`
- **調査ワークフロー**: `C:\Users\xprin\github\prompt-patterns\development\reference\investigation-workflow-template.md`
- **テスト要件**: `C:\Users\xprin\github\prompt-patterns\technical-projects-cli\test-process-requirements.md`

---

## 🆘 トラブルシューティング

### .claude/ が既に存在する場合

```bash
# 既存を確認
ls -la C:/Users/xprin/github/jsbsim-flightgear-guide/.claude/

# バックアップを作成
cp -r .claude/ .claude.backup-$(date +%Y%m%d)

# 強制上書きでデプロイ
cd C:/Users/xprin/github/prompt-patterns
./scripts/deploy.sh -t -f C:/Users/xprin/github/jsbsim-flightgear-guide
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
- [ ] Hooks 動作確認（Stop Hook）
- [ ] CLAUDE.md 作成（推奨）
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
