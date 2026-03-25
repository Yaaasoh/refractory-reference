# flying-robot-contest-rules-public への導入案内

**対象リポジトリ**: flying-robot-contest-rules-public
**リポジトリパス**: `C:\Users\xprin\github\flying-robot-contest-rules-public\`
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. 公開ルール文書向け機能 ⭐NEW
- 調査ワークフロー標準化（WebSearch 100%保存義務）
- 技術文書作成ガイドライン
- 引用・参照管理ノウハウ

### 3. 安全性確保 ⭐NEW
- 破壊的コマンド自動ブロック
- 大規模ファイル読み込み防止

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd C:/Users/xprin/github/flying-robot-contest-rules-public

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd C:/Users/xprin/github/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n C:/Users/xprin/github/flying-robot-contest-rules-public

# 実際にデプロイ
./scripts/deploy.sh -t C:/Users/xprin/github/flying-robot-contest-rules-public
```

### Step 3: 設定確認

```bash
cd C:/Users/xprin/github/flying-robot-contest-rules-public
git status
ls -la .claude/
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 📝 追加されるファイル

```
flying-robot-contest-rules-public/
├── .claude/ ⭐完全構成
│   ├── hooks/
│   │   ├── block_destructive.sh ⭐重要（誤削除防止）
│   │   ├── check_file_size.sh
│   │   ├── check_uncommitted.sh ⭐重要（公開前確認）
│   │   └── session_start.sh
│   ├── commands/
│   │   ├── investigate.md（調査セッション）
│   │   ├── safety-check.md ⭐重要（公開前確認）
│   │   └── suggest-claude-md.md
│   ├── settings.json
│   └── README.md
│
├── technical-projects-cli/ ⭐NEW
│   ├── technical-accuracy-guidelines.md ⭐ルール文書の正確性
│   ├── universal-instruction-quality-rules.md
│   └── README.md
│
├── development/reference/ ⭐NEW
│   ├── README_FOR_CLAUDE_TEMPLATE.md
│   ├── investigation-workflow-template.md ⭐調査向け
│   ├── technical-tools-reference.md ⭐引用管理
│   └── README.md
│
└── CLAUDE.md ⭐推奨新規作成
```

---

## ✅ 動作確認

### check_uncommitted.sh のテスト

```bash
cd C:/Users/xprin/github/flying-robot-contest-rules-public
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

公開ルール文書リポジトリ向けの CLAUDE.md:

```markdown
# flying-robot-contest-rules-public プロジェクトガイド

## プロジェクト概要

Flying Robotコンテストルール（公開版）

**重要**: このリポジトリは公開リポジトリです。機密情報を含めないこと。

---

## CRITICAL - セッション開始プロトコル

### セッション開始時（必須3ステップ）

1. `git status` でUntracked/変更ファイル確認
2. 既存作業の有無を確認（ユーザーに質問）
3. 作業方針を明確化

---

## 絶対禁止事項

### 破壊的コマンド（絶対実行禁止）

**公開ルールの誤削除は致命的**

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
- 公開前のコミット漏れを防止

---

## 公開リポジトリの注意事項

### 機密情報の除外（絶対厳守）

**絶対に含めないこと**:
- 内部資料への参照
- プライベート版ルールへのリンク
- 開発者の個人情報
- 未公開の計画・スケジュール

### 公開前の確認チェック

```
/safety-check
```

チェック項目:
- [ ] 機密情報が含まれていないか
- [ ] リンク切れがないか
- [ ] 誤字脱字がないか
- [ ] フォーマットが正しいか
- [ ] .gitignore確認

---

## 技術文書作成のルール

### WebSearch結果の100%保存義務

外部資料調査時は以下を必ず保存:
- WebSearch実施日
- 検索クエリ
- 情報源URL
- 抽出情報

詳細: `development/reference/investigation-workflow-template.md`

### 引用・参照管理

公式規格・技術標準を引用する場合:
- 正確な出典明記
- URL + アクセス日
- 引用部分の明示

参照: `development/reference/technical-tools-reference.md`

### 技術的正確性

ルール文書の正確性は極めて重要:
- 数値・単位の確認
- 技術用語の統一
- 矛盾のないロジック

詳細: `technical-projects-cli/technical-accuracy-guidelines.md`

---

## 参照ドキュメント

### セッション開始時
- このファイル（CLAUDE.md）

### ルール作成時
- `technical-projects-cli/technical-accuracy-guidelines.md`
- `development/reference/technical-tools-reference.md`

### 調査時
- `development/reference/investigation-workflow-template.md`
- `.claude/commands/investigate.md`（/investigate）

### 公開前確認
- `.claude/commands/safety-check.md`（/safety-check）
```

---

## 🎓 公開ルール文書での活用例

### 公開前の安全確認

```bash
cd C:/Users/xprin/github/flying-robot-contest-rules-public
claude-code

# 公開前チェック
/safety-check
```

### 外部資料調査

```bash
# 調査セッション開始
/investigate

# WebSearch結果を必ず保存
# → investigation_results/YYYY-MM-DD_topic/ に保存
```

### 技術的正確性の確認

```bash
# 技術精度ガイドラインを参照
cat technical-projects-cli/technical-accuracy-guidelines.md
```

---

## 🔧 settings.json の内容

デプロイされる `C:\Users\xprin\github\flying-robot-contest-rules-public\.claude\settings.json`:

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

## ⚠️ 重要: 公開リポジトリのセキュリティ

### .gitignore の推奨設定

```gitignore
# 機密情報
*.secret
*.key
credentials.*
.env
config.local.*

# 内部資料
private/
internal/
draft/

# バックアップ
*.backup
*.bak

# 一時ファイル
*.tmp
*.temp
```

### 公開前チェックリスト

- [ ] 機密情報が含まれていないか全文検索
- [ ] プライベート版へのリンクがないか確認
- [ ] 内部資料への参照がないか確認
- [ ] .gitignoreが適切に設定されているか
- [ ] コミットログに機密情報がないか

---

## 📚 詳細ドキュメント（prompt-patternsリポジトリ内）

- **詳細ガイド**: `C:\Users\xprin\github\prompt-patterns\DEPLOYMENT_GUIDE.md`
- **調査ワークフロー**: `C:\Users\xprin\github\prompt-patterns\development\reference\investigation-workflow-template.md`
- **技術ツール集**: `C:\Users\xprin\github\prompt-patterns\development\reference\technical-tools-reference.md`
- **技術精度ガイドライン**: `C:\Users\xprin\github\prompt-patterns\technical-projects-cli\technical-accuracy-guidelines.md`

---

## 🆘 トラブルシューティング

### 誤って機密情報をコミットした

```bash
# コミット前に気づいた場合
git reset HEAD <ファイル名>
git restore <ファイル名>

# プッシュ前に気づいた場合
git reset --soft HEAD~1
# ファイルを修正
git commit -m "..."

# プッシュ後の場合
# → 即座にユーザーに報告し、対処方法を相談
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
- [ ] .gitignore確認（機密情報除外）
- [ ] 公開前チェックリスト確認
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
