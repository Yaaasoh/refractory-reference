# vibration-diagnosis-prototype への導入案内

**対象リポジトリ**: vibration-diagnosis-prototype
**導入日**: 2025-11-28以降
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. テストプロセス要件の明確化 ⭐NEW
完了の定義: `実装 + テスト + パス = 完了`

### 3. 6フェーズ開発テンプレート ⭐NEW
既存の development-policy.md を補完するテンプレート版

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd /path/to/vibration-diagnosis-prototype

# 既存設定をバックアップ
cp -r .claude/ .claude.backup-$(date +%Y%m%d)
```

### Step 2: デプロイ実行

```bash
cd /path/to/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n /path/to/vibration-diagnosis-prototype

# 実際にデプロイ
./scripts/deploy.sh -t /path/to/vibration-diagnosis-prototype
```

### Step 3: 設定確認

```bash
cd /path/to/vibration-diagnosis-prototype

# Stop Hook が追加されたか確認
cat .claude/settings.json | grep -A 5 "Stop"

# 新規ファイルを確認
git status
```

---

## 📝 追加されるファイル

```
vibration-diagnosis-prototype/
├── .claude/
│   ├── hooks/
│   │   ├── block_destructive.sh（最新版）
│   │   ├── check_file_size.sh（最新版）
│   │   ├── check_uncommitted.sh ⭐NEW
│   │   └── session_start.sh
│   ├── commands/
│   │   ├── investigate.md ⭐NEW
│   │   ├── safety-check.md
│   │   └── suggest-claude-md.md
│   └── settings.json（完全版）
│
├── technical-projects-cli/ ⭐NEW
│   ├── test-process-requirements.md ⭐重要
│   ├── technical-accuracy-guidelines.md
│   └── README.md
│
└── development/reference/
    ├── 6phase-development-template.md ⭐NEW（テンプレート版）
    ├── technical-tools-reference.md ⭐NEW
    └── README.md
```

---

## 🔄 既存ファイルとの関係

### development-policy.md（既存）vs 6phase-development-template.md（新規）

| ファイル | 用途 | 保持/削除 |
|---------|------|---------|
| `.claude/development-policy.md` | プロジェクト固有の6フェーズ実装 | **保持** |
| `development/reference/6phase-development-template.md` | 汎用テンプレート（他プロジェクト向け） | **追加** |

**結論**: 両方を保持。既存のdevelopment-policy.mdはそのまま使用し、新規テンプレートは参照用。

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

### test-process-requirements.md の確認

```bash
# 完了の定義を確認
cat technical-projects-cli/test-process-requirements.md | head -40
```

**期待される内容**:
```
完了の定義:
実装 ≠ 完了
実装 + テスト + パス = 完了
```

---

## 🔧 settings.json の統合

**デプロイスクリプトが自動で追加する内容**:

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

**既存の settings.json がある場合**、手動でマージが必要です。

---

## 📋 CLAUDE.md への追加推奨

以下のセクションを追加することを推奨:

```markdown
### セッション終了時のコミット忘れ防止

**自動チェック**:
- `.claude/hooks/check_uncommitted.sh` がセッション終了時に未コミット変更を警告
- コミット・プッシュ忘れを防止

---

### テストプロセス要件

**完了の定義**:
```
実装 + テスト + パス = 完了
```

詳細: `technical-projects-cli/test-process-requirements.md`
```

---

## 🎓 テストプロセス要件の活用

### 実装時のチェック

```markdown
## 実装完了チェックリスト

- [ ] コードを書いた
- [ ] テストを実行した
- [ ] テストが成功した
- [ ] 実際の動作を確認した
- [ ] エラーがないことを確認した
→ 完了
```

### 仕様-テスト対応

```markdown
| 仕様ID | 仕様項目 | テスト種別 | テスト方法 | 合否基準 |
|-------|---------|----------|----------|---------|
| S001 | 加速度データ読み込み | 単体 | 入力テスト | エラーなし |
| S002 | FFT計算 | 単体 | 既知入力 | 期待値一致 |
| S003 | 異常検出 | 統合 | 全体フロー | 正しい判定 |
```

---

## 🆘 トラブルシューティング

### settings.json のマージエラー

```bash
# JSON構文チェック
cat .claude/settings.json | jq .

# エラーがある場合、バックアップから復元
cp .claude/settings.json.backup .claude/settings.json
```

### 既存のカスタムファイルが上書きされた

```bash
# バックアップから復元
cp .claude.backup-YYYYMMDD/.claude/custom-file.md .claude/
```

---

## 🎓 参考資料

- **詳細ガイド**: `DEPLOYMENT_GUIDE.md`
- **テスト要件**: `technical-projects-cli/test-process-requirements.md`
- **6フェーズテンプレート**: `development/reference/6phase-development-template.md`

---

## ✅ 完了チェックリスト

- [ ] バックアップ作成
- [ ] デプロイ実行
- [ ] Stop Hook 動作確認
- [ ] test-process-requirements.md 確認
- [ ] CLAUDE.md 更新
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
