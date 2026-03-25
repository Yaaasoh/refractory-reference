# jsbsim-xml-generator への導入案内

**対象リポジトリ**: jsbsim-xml-generator
**リポジトリパス**: `C:\Users\xprin\github\jsbsim-xml-generator\`
**所要時間**: 10分

---

## 🎯 あなたのリポジトリに追加される機能

### 1. セッション終了時のコミット忘れ防止 ⭐NEW
セッション終了時に自動で未コミットファイルを警告します。

### 2. XML生成向け機能 ⭐NEW
- テストプロセス要件（生成XML検証の完了定義明確化）
- 技術精度ガイドライン（XML妥当性確保）
- 6フェーズ開発プロセス

### 3. 安全性確保 ⭐NEW
- 破壊的コマンド自動ブロック
- 大規模ファイル読み込み防止

---

## 📦 導入手順（3ステップ）

### Step 1: バックアップ

```bash
cd C:/Users/xprin/github/jsbsim-xml-generator

# 既存設定をバックアップ（存在する場合）
if [ -d .claude ]; then
  cp -r .claude/ .claude.backup-$(date +%Y%m%d)
fi
```

### Step 2: デプロイ実行

```bash
cd C:/Users/xprin/github/prompt-patterns

# ドライラン（確認のみ）
./scripts/deploy.sh -t -n C:/Users/xprin/github/jsbsim-xml-generator

# 実際にデプロイ
./scripts/deploy.sh -t C:/Users/xprin/github/jsbsim-xml-generator
```

### Step 3: 設定確認

```bash
cd C:/Users/xprin/github/jsbsim-xml-generator
git status
ls -la .claude/
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 📝 追加されるファイル

```
jsbsim-xml-generator/
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
│   ├── test-process-requirements.md ⭐重要（XML検証）
│   ├── technical-accuracy-guidelines.md ⭐重要（XML妥当性）
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
cd C:/Users/xprin/github/jsbsim-xml-generator
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

XML生成リポジトリ向けの CLAUDE.md:

```markdown
# jsbsim-xml-generator プロジェクトガイド

## プロジェクト概要

JSBSim XMLファイル生成ツール

---

## CRITICAL - セッション開始プロトコル

### セッション開始時（必須3ステップ）

1. `git status` でUntracked/変更ファイル確認
2. 既存作業の有無を確認（ユーザーに質問）
3. 作業方針を明確化

---

## 絶対禁止事項

### 破壊的コマンド（絶対実行禁止）

**生成XMLファイルの誤削除は致命的**

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
- XML生成結果のコミット漏れを防止

---

## XML生成のテストプロセス

### 完了の定義

```
実装 + テスト + パス = 完了
```

**必須検証項目**:
- [ ] XMLファイル生成完了
- [ ] XML構文妥当性検証（well-formed）
- [ ] JSBSim スキーマ検証（valid）
- [ ] 実際にJSBSimで読み込み確認
- [ ] エラーがないことを確認
→ 完了

詳細: `technical-projects-cli/test-process-requirements.md`

### XML妥当性検証

生成されたXMLは必ず以下を確認:

1. **構文チェック（well-formed）**
   ```bash
   xmllint --noout generated.xml
   # エラーがなければOK
   ```

2. **スキーマ検証（valid）**
   ```bash
   # JSBSim DTD/XSDでの検証
   xmllint --schema jsbsim.xsd generated.xml
   ```

3. **実動作確認**
   ```bash
   # JSBSimで実際に読み込み
   jsbsim --script=test_script.xml
   # エラーなく実行できればOK
   ```

詳細: `technical-projects-cli/technical-accuracy-guidelines.md`

---

## 6フェーズ開発プロセス

新規生成機能実装時の標準プロセス:

1. **Phase 1: 仕様妥当性確認**（0.5-1日）
   - JSBSim仕様の確認
   - XMLスキーマの理解

2. **Phase 2: 実装**（機能による）
   - XML生成ロジックの実装
   - アンチパターン回避（過度なエラーハンドリング、完璧主義）

3. **Phase 3: 実動作確認（手動）**（0.5-1日）
   - 手動テスト優先
   - 実際のXML生成確認

4. **Phase 4: 整合性検証**（0.5日）
   - 仕様との乖離確認
   - 既知の制限事項文書化

5. **Phase 5: 必要最小限テスト**（0.5-1日）
   - コア機能のみ自動テスト
   - 完璧なカバレッジ不要

6. **Phase 6: 文書化**（0.5-1日）
   - 生成XMLの仕様書
   - 技術的判断の理由記録

詳細: `development/reference/6phase-development-template.md`

---

## 参照ドキュメント

### セッション開始時
- このファイル（CLAUDE.md）

### XML生成時
- `development/reference/6phase-development-template.md`
- `technical-projects-cli/test-process-requirements.md`
- `technical-projects-cli/technical-accuracy-guidelines.md`
```

---

## 🎓 XML生成リポジトリでの活用例

### XML生成とテストプロセス

```bash
# XML生成
python generate_aircraft.py --output aircraft.xml

# 構文チェック
xmllint --noout aircraft.xml

# スキーマ検証
xmllint --schema jsbsim.xsd aircraft.xml

# 実動作確認
jsbsim --script=test_aircraft.xml

# 全テストパス確認
pytest tests/ --verbose
```

### 6フェーズプロセスの活用

```bash
# Phase 1: JSBSim仕様確認
cat docs/jsbsim_specification.md

# Phase 2-3: 実装と手動確認
python generate_*.py
xmllint --noout generated.xml

# Phase 4: 整合性検証
diff expected.xml generated.xml

# Phase 5: 自動テスト
pytest tests/test_core.py

# Phase 6: 文書化
vim docs/generated_xml_spec.md
```

---

## 🔧 settings.json の内容

デプロイされる `C:\Users\xprin\github\jsbsim-xml-generator\.claude\settings.json`:

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

### XML検証エラーが出る

```bash
# 詳細なエラー出力
xmllint --noout --verbose generated.xml

# スキーマエラーの詳細
xmllint --schema jsbsim.xsd --noout generated.xml 2>&1 | less
```

### JSBSim実行エラー

```bash
# デバッグモードで実行
jsbsim --script=test_script.xml --debug

# ログを確認
tail -f jsbsim.log
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
- [ ] XML検証ツール確認（xmllint, jsbsim）
- [ ] git commit & push

---

**質問・不具合報告**: https://github.com/Yaaasoh/prompt-patterns/issues
