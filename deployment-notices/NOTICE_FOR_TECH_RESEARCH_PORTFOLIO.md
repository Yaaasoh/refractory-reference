# tech-research-portfolio への導入案内

**対象リポジトリ**: tech-research-portfolio
**導入日**: 2025-11-28以降
**所要時間**: 15分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. Claude Code CLI 完全セットアップ ⭐NEW
.claude/ ディレクトリの完全構成（Hooks, Commands, settings.json）

### 2. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告

### 3. 調査ワークフロー標準化 ⭐NEW
WebSearch 100%保存義務、セッション管理構造

### 4. 参照テンプレート集 ⭐NEW
README_FOR_CLAUDE、development-policy、調査ワークフロー等

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd /path/to/tech-research-portfolio

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd /path/to/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n /path/to/tech-research-portfolio

# 実際にデプロイ
./scripts/deploy.sh -t /path/to/tech-research-portfolio
```

### Step 3: 設定確認

```bash
cd /path/to/tech-research-portfolio

# .claude/ 構成を確認
ls -la .claude/
ls -la .claude/hooks/
ls -la .claude/commands/

# 新規ファイルを確認
git status
```

---

## 📝 追加されるファイル（完全セット）

```
tech-research-portfolio/
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
│   ├── test-process-requirements.md
│   ├── technical-accuracy-guidelines.md
│   ├── universal-instruction-quality-rules.md
│   └── README.md
│
├── development/reference/ ⭐NEW
│   ├── README_FOR_CLAUDE_TEMPLATE.md
│   ├── development-policy-template.md
│   ├── investigation-workflow-template.md
│   ├── 6phase-development-template.md
│   ├── technical-tools-reference.md
│   └── README.md
│
└── CLAUDE.md ⭐推奨新規作成
```

---

## 🔄 既存ファイルとの関係

### ATONEMENT_SYSTEM.md（既存）の保持

**重要**: `ATONEMENT_SYSTEM.md` は **prompt-patterns には含まれていません**。

このファイルはプロジェクト固有の重要文書として保持してください。

```bash
# 既存のまま保持
projects/flyingrobot_knowledge/flight-sim/20251003_jsbsim_investigation/ATONEMENT_SYSTEM.md
```

### 他のプロジェクト固有文書

以下もすべて保持:
- `TEST_PROCESS_REQUIREMENTS.md`（既存版）
- `COMMUNICATION_PRINCIPLES.md`
- `DEBUGGING_PROTOCOL.md`
- `EFFICIENCY_LESSONS.md`
- `CLAUDE_CODE_GUIDELINES.md`

**新規追加されるファイルとの関係**:
- 既存: プロジェクト固有の詳細ルール
- 新規: 汎用テンプレート（他プロジェクトへの展開用）

---

## ✅ 動作確認

### 1. Hooks の動作確認

```bash
# Claude Codeセッションを開始
claude-code

# SessionStart Hook 確認
# → セッション開始メッセージが表示される

# PreToolUse Hook（破壊的コマンド）確認
# 以下のコマンドを実行してブロックされることを確認
git clean -fd
# → ブロックされればOK

# テストファイル作成
echo "test" > test-file.txt

# セッション終了（Ctrl+D）
# → 未コミット警告が表示されればOK
```

### 2. Commands の動作確認

```bash
# Claude Codeセッション内で
/investigate
# → 調査セッション案内が表示される

/safety-check
# → 安全確認チェックリストが表示される

/suggest-claude-md
# → CLAUDE.md更新提案が表示される
```

---

## 🔧 settings.json の内容

**デプロイされる settings.json**:

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

## 📋 CLAUDE.md の新規作成（推奨）

tech-research-portfolio には CLAUDE.md がない可能性があります。
以下のテンプレートで作成することを推奨:

```markdown
# tech-research-portfolio プロジェクトガイド

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
- `find . -delete` （一括削除）
- `git reset --hard` （ユーザー確認なし）
- `git push --force` （ユーザー確認なし）

**自動ブロック**:
- `.claude/hooks/block_destructive.sh` が危険コマンドを自動ブロック

---

## 大規模ファイル読み込み禁止

**10MB以上のファイルは直接読み込み禁止**（特にPDF）

**自動ブロック**:
- `.claude/hooks/check_file_size.sh` が10MB超のファイルを自動ブロック
- 5MB超で警告表示

---

## セッション終了時のコミット忘れ防止

**自動チェック**:
- `.claude/hooks/check_uncommitted.sh` がセッション終了時に未コミット変更を警告
- Untracked、Modified、Stagedファイルを表示
- コミット・プッシュ忘れを防止

---

## プロジェクト固有ルール

### ATONEMENT_SYSTEM（罪の償いシステム）

詳細: `projects/flyingrobot_knowledge/flight-sim/20251003_jsbsim_investigation/ATONEMENT_SYSTEM.md`

### テストプロセス要件

**完了の定義**:
```
実装 + テスト + パス = 完了
```

詳細: `technical-projects-cli/test-process-requirements.md`

---

## 参照ドキュメント

### 必読（セッション開始時）
- このファイル（CLAUDE.md）

### 調査時参照
- `development/reference/investigation-workflow-template.md`
- `.claude/commands/investigate.md`（/investigate コマンド）

### 開発時参照
- `development/reference/development-policy-template.md`
- `development/reference/6phase-development-template.md`
- `technical-projects-cli/test-process-requirements.md`
```

---

## 🎓 参照テンプレートの活用

### README_FOR_CLAUDE_TEMPLATE.md

新規プロジェクト開始時のテンプレートとして使用:

```bash
# 新規プロジェクトディレクトリで
cp development/reference/README_FOR_CLAUDE_TEMPLATE.md \
   projects/new-project/README_FOR_CLAUDE.md

# プレースホルダーを埋める
vim projects/new-project/README_FOR_CLAUDE.md
```

### investigation-workflow-template.md

調査セッション時の標準フローとして参照:

```bash
# 調査セッション開始時
/investigate

# または、テンプレートを直接参照
cat development/reference/investigation-workflow-template.md
```

---

## 🆘 トラブルシューティング

### .claude/ が既に存在する場合

```bash
# 既存の .claude/ を確認
ls -la .claude/

# バックアップを作成
cp -r .claude/ .claude.backup-$(date +%Y%m%d)

# デプロイ実行（既存ファイルはスキップされる）
cd /path/to/prompt-patterns
./scripts/deploy.sh -t /path/to/tech-research-portfolio

# または、強制上書き
./scripts/deploy.sh -t -f /path/to/tech-research-portfolio
```

### settings.json が競合する場合

```bash
# 既存の settings.json を確認
cat .claude/settings.json

# 新規版との差分を確認
git diff .claude/settings.json

# 手動でマージが必要な場合、バックアップから復元
cp .claude/settings.json.backup .claude/settings.json
# その後、必要な部分を手動追加
```

---

## 🎓 参考資料

- **詳細ガイド**: `DEPLOYMENT_GUIDE.md`
- **テンプレート集**: `development/reference/README.md`
- **テスト要件**: `technical-projects-cli/test-process-requirements.md`

---

## ✅ 完了チェックリスト

- [ ] バックアップ作成（既存の .claude/ がある場合）
- [ ] デプロイ実行
- [ ] Hooks 動作確認（SessionStart, PreToolUse, Stop）
- [ ] Commands 動作確認（/investigate, /safety-check, /suggest-claude-md）
- [ ] CLAUDE.md 作成（推奨）
- [ ] プロジェクト固有文書の保持確認（ATONEMENT_SYSTEM.md等）
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
