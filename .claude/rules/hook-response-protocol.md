# Hook応答プロトコル

**対策対象**: FP-5（Hook警告無視）
**優先度**: High
**適用範囲**: すべてのパッケージ（technical, prompt-creation）
**出典**: WORK_PROCESS_PROTOCOLS Protocol 2, vibration-diagnosis-prototype失敗事例

## 概要

Claude Code Hooksは、不適切な操作を防止するために警告やブロックを発行します。このプロトコルは、Hook警告への適切な対応手順を定義します。

**Hookの役割**:
- 不適切な操作の検出
- 警告メッセージの表示
- 必要に応じて操作のブロック（`blocked: true`）

**Hookのイベント**:
- `PreToolUse`: ツール実行前
- `PostToolUse`: ツール実行後
- `UserPromptSubmit`: ユーザープロンプト送信時
- その他8種類のイベント

## やってはいけないこと

### 1. Hook警告の無視

**絶対禁止**:
- Hook警告を読まずに次の操作を続行する
- 警告の意味を理解せずに無視する
- 「些細な警告」と決めつけて無視する
- Hook警告を繰り返し引き起こす

**具体例（vibration-diagnosis-prototype Sin 5）**:
```bash
# Hook警告
⚠️  警告: テストファイルの削除を検出しました
test/auth.test.ts の削除は品質低下の原因になります

# ❌ 悪い例：警告を無視して続行
（警告を読まずに次の操作へ）

# ✅ 正しい例：警告に対応
（警告を読み、テスト削除の理由を確認、必要なら復元）
```

### 2. Hook機能の無効化

**絶対禁止**:
- 警告を避けるためにHookを無効化する
- settings.local.jsonにhooks空設定を追加してsettings.jsonのHookを迂回する
- Hookスクリプトをコメントアウトする
- Hookスクリプトに `exit 0` を追加して常に成功させる

**具体例**:
```json
// ❌ 悪い例：settings.local.jsonでHookを迂回
// （settings.local.jsonはsettings.jsonより優先度が高い）
{
  "hooks": {}
}

// ✅ 正しい例：settings.jsonのHook設定を維持（変更しない）
// Hookはsettings.jsonで定義されており、settings.local.jsonで上書きしない
```

### 3. Hook警告への不適切な対応

**禁止**:
- 警告の根本原因を解決せずに回避策を使う
- 「一時的」と称して恒久的に無効化する
- 警告をユーザーに報告しない

## やるべきこと

### 1. Hook警告の読解

**4ステップアプローチ**:

#### Step 1: 警告メッセージを全文読む
```bash
⚠️  警告: テストの改ざんを検出しました

以下のパターンが検出されました:
  - test/users.test.ts: アサーション削除（行42）
  - test/auth.test.ts: テストスキップ（行15）

これは品質低下の原因になります。
実装を修正してテストをパスさせてください。
```

#### Step 2: 警告の種類を特定
```yaml
警告の種類:
  - テスト改ざん（FP-1）
  - Lint設定改ざん
  - 設定ファイル変更
  - 破壊的コマンド実行
  - セキュリティリスク
  - その他の品質リスク
```

#### Step 3: 影響範囲を評価
```yaml
影響レベル:
  Critical: 即座に修正が必要（セキュリティ、データ損失リスク）
  High: 早急に修正が必要（品質低下、テスト改ざん）
  Medium: 修正推奨（lint警告、スタイル違反）
  Low: 情報提供（Tips、推奨事項）
```

#### Step 4: 適切に対応
```markdown
Criticalの場合:
  1. 即座に操作を中止
  2. ユーザーに報告
  3. 承認を得てから進行

High/Mediumの場合:
  1. 警告内容を確認
  2. 根本原因を特定
  3. 修正して再試行

Lowの場合:
  1. 情報を記録
  2. 可能なら改善
```

### 2. Hook警告への対応例

#### 例1: テスト改ざん警告

**Hook警告**:
```bash
⚠️  警告: テストの改ざんを検出しました
test/users.test.ts: アサーション削除（行42）
```

**対応手順**:
```markdown
1. 警告を読む: アサーション削除を検出

2. 変更を確認:
   $ git diff test/users.test.ts

3. 原因を特定:
   - テストが失敗していた
   - アサーションを削除して対処しようとした

4. 正しい対応:
   - アサーションを復元
   - 実装を修正してテストをパスさせる

5. 再試行:
   $ git restore test/users.test.ts
   （実装を修正）
   $ npm test  # テストがパス
```

#### 例2: 破壊的コマンド警告

**Hook警告**:
```bash
⚠️  警告: 破壊的コマンドの実行を検出しました
コマンド: rm -rf dist/

このコマンドは禁止されています。
代替: 安全な削除コマンドを使用してください
```

**対応手順**:
```markdown
1. 警告を読む: rm -rf は禁止

2. 理由を確認:
   - 誤操作でデータ損失のリスク

3. 代替手段:
   - rm dist/*.js （特定ファイルのみ）
   - npm run clean （定義済みスクリプト）

4. 実行:
   $ npm run clean
```

### 3. Hook応答の記録

**記録の目的**:
- 警告の傾向を把握
- 再発防止策の策定
- チーム全体での学習

**記録フォーマット**:
```markdown
## Hook警告記録: 2025-12-27

### 警告1: テスト改ざん
- **時刻**: 14:30
- **Hook**: PreToolUse
- **ファイル**: test/users.test.ts
- **内容**: アサーション削除
- **対応**: アサーション復元、実装修正
- **結果**: 解決

### 警告2: Lint設定変更
- **時刻**: 15:45
- **Hook**: PreToolUse
- **ファイル**: .eslintrc.json
- **内容**: no-unused-vars ルール無効化
- **対応**: ルール維持、未使用変数削除
- **結果**: 解決
```

## Hook応答のベストプラクティス

### 1. 警告優先の原則

**原則**:
> Hook警告は、品質を守るための重要なシグナル

**実践**:
```yaml
優先順位:
  1. Hook警告への対応（最優先）
  2. 元の作業の続行

理由:
  - 警告を無視すると品質低下
  - 後から修正するとコスト増
  - 警告は再発防止の機会
```

### 2. 根本原因の解決

**原則**:
> Hook警告を回避するのではなく、根本原因を解決する

**実践**:
```markdown
❌ 回避策（悪い例）:
  - Hookを無効化
  - 警告を無視
  - 一時的に設定変更

✅ 根本解決（良い例）:
  - テストを修正
  - 実装を改善
  - 品質基準を維持
```

### 3. 透明性の原則

**原則**:
> Hook警告は、ユーザーに報告する

**実践**:
```markdown
報告すべきHook警告:
  - Critical/High レベルの警告
  - 繰り返し発生する警告
  - ユーザー指示と矛盾する警告

報告方法:
  「⚠️ Hook警告を検出しました：[警告内容]
  対応方法：[提案]
  承認をいただけますか？」
```

## Hook設定のベストプラクティス

### 1. 段階的導入

**推奨アプローチ**:
```markdown
Phase 1: 情報提供Hookのみ
  - 警告表示のみ、ブロックしない
  - チームが警告に慣れる

Phase 2: 一部ブロックHook
  - Critical警告のみブロック
  - High警告は警告表示のみ

Phase 3: 完全なブロックHook
  - Critical/High警告をブロック
  - チーム全体で品質文化が定着
```

### 2. Hook開発のガイドライン

**Hookスクリプト作成時**:
```bash
#!/bin/bash
# 良いHookの例

INPUT=$(cat)

# 1. 明確な警告メッセージ
echo "⚠️  警告: [具体的な問題]" >&2
echo "" >&2
echo "検出内容: [詳細]" >&2
echo "推奨対応: [具体的なアクション]" >&2

# 2. 適切なブロック判断
if [[ $SEVERITY == "critical" ]]; then
  echo '{"blocked": true, "reason": "Critical issue detected"}' | jq
  exit 0
fi

# 3. 情報を保持
echo "$INPUT"
```

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: Hook対応プロトコルの提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**: Hook警告発生時に適切な対応を誘導
- **機能**: 警告解読、対応手順の提示

### Layer 3: Hooks（本層）
- **効果**: 強（実行前/後にブロック可能）
- **機能**: 不適切な操作の検出と防止
- **種類**: 品質チェック、セキュリティチェック、改ざん検出

## 関連ドキュメント

### 共有ルール
- `shared/rules/anti-tampering-rules.md` - 改ざん防止
- `shared/rules/evidence-based-thinking.md` - 証拠ベース思考

### パッケージ固有ルール
- `technical-projects-cli/docs/rules/test.md` - テスト品質
- `technical-projects-cli/docs/rules/task-integrity.md` - タスク完全性

### Claude Code公式
- [Hooks Documentation](https://docs.claude.com/ja/docs/claude-code/hooks)
- [Settings Reference](https://code.claude.com/docs/ja/settings)

## 参考リンク

- [vibration-diagnosis-prototype WORK_PROCESS_PROTOCOLS](vibration-diagnosis-prototype/docs/WORK_PROCESS_PROTOCOLS_20251227.md): Protocol 2
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 5

---

**最終更新**: 2025-12-27
**バージョン**: 1.0
**ステータス**: Phase 4統合版（汎用）
**適用**: すべてのパッケージ
