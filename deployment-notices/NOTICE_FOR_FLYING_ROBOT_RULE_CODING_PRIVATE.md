# flying-robot-rule-coding-private への導入案内

**対象リポジトリ**: flying-robot-rule-coding-private
**リポジトリパス**: `C:\Users\xprin\github\flying-robot-rule-coding-private\`
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. ルールコーディング向け機能 ⭐NEW
- テストプロセス要件（完了の定義明確化）
- 技術精度ガイドライン
- 6フェーズ開発プロセス

### 3. 安全性確保 ⭐NEW
- 破壊的コマンド自動ブロック
- 大規模ファイル読み込み防止

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd C:/Users/xprin/github/flying-robot-rule-coding-private

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd C:/Users/xprin/github/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n C:/Users/xprin/github/flying-robot-rule-coding-private

# 実際にデプロイ
./scripts/deploy.sh -t C:/Users/xprin/github/flying-robot-rule-coding-private
```

### Step 3: 設定確認

```bash
cd C:/Users/xprin/github/flying-robot-rule-coding-private
git status
ls -la .claude/
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 📝 追加されるファイル

```
flying-robot-rule-coding-private/
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
│   ├── test-process-requirements.md ⭐重要（ルール検証）
│   ├── technical-accuracy-guidelines.md
│   └── universal-instruction-quality-rules.md
│
├── development/reference/ ⭐NEW
│   ├── README_FOR_CLAUDE_TEMPLATE.md
│   ├── development-policy-template.md
│   ├── 6phase-development-template.md ⭐開発向け
│   ├── investigation-workflow-template.md
│   └── README.md
│
└── CLAUDE.md ⭐推奨新規作成
```

---

## ✅ 動作確認

### check_uncommitted.sh のテスト

```bash
cd C:/Users/xprin/github/flying-robot-rule-coding-private
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

ルールコーディングリポジトリ向けの CLAUDE.md:

```markdown
# flying-robot-rule-coding-private プロジェクトガイド

## プロジェクト概要

Flying Robotコンテストルールコーディング（プライベート版）

---

## CRITICAL - セッション開始プロトコル

### セッション開始時（必須3ステップ）

1. `git status` でUntracked/変更ファイル確認
2. 既存作業の有無を確認（ユーザーに質問）
3. 作業方針を明確化

---

## 絶対禁止事項

### 破壊的コマンド（絶対実行禁止）

**ルールコードの誤削除は致命的**

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
- ルール変更のコミット漏れを防止

---

## ルールコーディングのテストプロセス

### 完了の定義

```
実装 + テスト + パス = 完了
```

**必須テスト項目**:
- [ ] ルール実装完了
- [ ] 単体テスト実行
- [ ] 統合テスト実行
- [ ] テストケース全パス
- [ ] エッジケース確認
→ 完了

詳細: `technical-projects-cli/test-process-requirements.md`

### 仕様-テスト対応

各ルールに対してテストケースを明確化:

| ルールID | ルール内容 | テスト種別 | テストケース | 合否基準 |
|---------|-----------|----------|------------|---------|
| R001 | 飛行エリア制限 | 単体 | 境界値テスト | 正しく判定 |
| R002 | 高度制限 | 単体 | 上限/下限 | 適切にエラー |
| R003 | 速度制限 | 統合 | 実フライトシミュレート | 違反検出 |

---

## 6フェーズ開発プロセス

新規ルール実装時の標準プロセス:

1. **Phase 1: 仕様妥当性確認**（0.5-1日）
   - ルール仕様の技術的根拠確認
   - 既存ルールとの整合性確認

2. **Phase 2: 実装**（機能による）
   - ルールロジックの実装
   - アンチパターン回避（過度なエラーハンドリング、完璧主義）

3. **Phase 3: 実動作確認（手動）**（0.5-1日）
   - 手動テスト優先
   - 実際のルール適用確認

4. **Phase 4: 整合性検証**（0.5日）
   - 仕様との乖離確認
   - 既知の制限事項文書化

5. **Phase 5: 必要最小限テスト**（0.5-1日）
   - コアルールのみ自動テスト
   - 完璧なカバレッジ不要

6. **Phase 6: 文書化**（0.5-1日）
   - ルール実装レポート
   - 技術的判断の理由記録

詳細: `development/reference/6phase-development-template.md`

---

## 参照ドキュメント

### セッション開始時
- このファイル（CLAUDE.md）

### ルール実装時
- `development/reference/6phase-development-template.md`
- `technical-projects-cli/test-process-requirements.md`
- `technical-projects-cli/technical-accuracy-guidelines.md`
```

---

## 🎓 ルールコーディングでの活用例

### テストプロセスの実践

```bash
# ルール実装
vim rule_altitude_limit.py

# 単体テスト作成
vim test_rule_altitude_limit.py

# テスト実行
pytest test_rule_altitude_limit.py

# 統合テスト
pytest tests/integration/

# 全テストパス確認
pytest --verbose
```

### 仕様-テスト対応マトリクス作成

```markdown
## ルールR001: 飛行エリア制限

### 仕様
- 飛行可能エリア: 50m x 50m
- 境界での動作: エラー

### テストケース
1. 正常系: エリア内 (25, 25) → OK
2. 境界値: (0, 0) → OK
3. 境界値: (50, 50) → Error
4. 異常系: (-10, 25) → Error
5. 異常系: (60, 25) → Error
```

---

## 🔧 settings.json の内容

デプロイされる `C:\Users\xprin\github\flying-robot-rule-coding-private\.claude\settings.json`:

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
- **技術精度ガイドライン**: `C:\Users\xprin\github\prompt-patterns\technical-projects-cli\technical-accuracy-guidelines.md`

---

## 🆘 トラブルシューティング

### テストが失敗する

```bash
# 詳細なエラー出力
pytest --verbose --tb=long

# 特定のテストのみ実行
pytest test_specific_rule.py::test_boundary_case
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
- [ ] テストプロセス確認
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
