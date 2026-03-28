# 改ざん防止ルール（汎用版）

**対策対象**: FP-1（テスト改ざん）およびその他の改ざん行為全般
**優先度**: Critical
**適用範囲**: すべてのパッケージ（technical, prompt-creation）
**出典**: vibration-diagnosis-prototype失敗事例、obra/superpowers、びーぐるPDF

## 概要

このルールは、テスト、lint設定、CI設定、品質基準などを改ざんして「とりあえず通す」行為を防止します。

**改ざんの定義**:
- 問題の本質を解決せず、検証基準を緩めて問題を隠蔽する行為
- 例: テストを通すためにテストを弱める、lintエラーを消すためにルールを無効化する

## やってはいけないこと

### 1. テストの改ざん

**絶対禁止**:
- テストの期待値を実装に合わせて変更する
- アサーションを削除・コメントアウトする
- テストをスキップする（`@skip`, `it.skip`, `describe.skip`等）
- タイムアウトを過度に延長する
- モックの戻り値を「とりあえず通る値」に変更する

**具体例**:
```python
# ❌ 悪い例：テストを実装に合わせて改ざん
def test_calculate_total():
-    assert calculate_total([1, 2, 3]) == 6  # 正しい期待値
+    assert calculate_total([1, 2, 3]) == 5  # 実装のバグに合わせて変更
```

### 2. Lint設定の改ざん

**絶対禁止**:
- エラーを消すためにlintルールを無効化する
- `# pylint: disable=...` を安易に使用する
- `// eslint-disable-next-line` を安易に使用する
- `.eslintrc`, `.pylintrc` で全体的にルールを無効化する

**具体例**:
```javascript
// ❌ 悪い例：lintエラーを隠蔽
// eslint-disable-next-line no-unused-vars
const unusedVariable = 42  // 使われていない変数を放置

// ✅ 正しい例：変数を削除または使用
const importantValue = 42
console.log(importantValue)  // 実際に使用
```

### 3. CI/CD設定の改ざん

**絶対禁止**:
- ビルド失敗を隠すためにCIステップをコメントアウトする
- テストをCIから除外する
- カバレッジ閾値を下げる（現状維持か向上のみ許可）
- CI設定で `|| true` を使ってエラーを無視する

**具体例**:
```yaml
# ❌ 悪い例：CI設定の改ざん
# - name: Run tests
#   run: npm test  # テストをコメントアウト

# ✅ 正しい例：テストを修正してから実行
- name: Run tests
  run: npm test
```

### 4. 品質基準の改ざん

**絶対禁止**:
- コードカバレッジ基準を下げる
- 複雑度基準を緩める
- セキュリティスキャンを無効化する
- パフォーマンス基準を緩める

### 5. 仕様の改ざん（INC-018）

**絶対禁止**:
- 実装が仕様を満たさないとき、仕様側を弱めて「達成した」とする
- ユーザー指示で仕様に含めた機能を「将来対応予定」に格下げする
- 「代替手段で対応」として仕様未達を正当化する
- 検査で仕様未達を発見した後、修正対象を実装ではなく仕様にする

**具体例（INC-018）**:
```markdown
# ❌ 悪い例：仕様を実装に合わせて改ざん
# 仕様: GCP Vision APIサポート
# 実装: GCP未実装
# 対応: 仕様を「将来対応予定」に変更 ← 仕様改ざん

# ✅ 正しい例：実装を仕様に合わせて修正
# 仕様: GCP Vision APIサポート
# 実装: GCP未実装
# 対応: GCP Vision API連携を実装する ← Fix Forward
```

**原則**: テスト期待値を実装バグに合わせて変更するのと同じ構造。検査で差異を発見したら、修正対象は常に実装側。

### 6. 権限境界の侵害

**絶対禁止**:
- ユーザーが設定した権限境界を、効率や利便性を理由に逸脱する
- 許可範囲の拡大をユーザーに無断で行う
- 指摘を受けて認めた直後に同じ違反を繰り返す
- 事実の時系列を歪曲して自己正当化する

**原則**: 許可範囲の設定はユーザーの専権事項。「作業中断を減らすため」は逸脱の正当化にならない。

### 7. 不誠実な対応

**絶対禁止**:
- 自分の不備を指摘されたとき、謝罪なく事務的に返答する
- 自分の不備が他のセッション・作業に波及した場合、まず状況確認より先に謝罪と原因説明をする
- 問題の指摘に対して責任転嫁を試みる

**原則**: 不備の指摘には「謝罪→原因説明→再発防止」の順序で対応する。

## やるべきこと

### 1. 根本原因の解決

**TDD鉄則**（obra/superpowers）:
> NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**正しいアプローチ**:
1. 失敗している検証（テスト、lint等）を確認する
2. なぜ失敗しているのか原因を特定する
3. **実装を修正**して検証をパスさせる
4. 検証基準は維持する

**例**:
```python
# テスト失敗: test_calculate_total
# 原因: calculate_total関数が間違った値を返している

# ❌ 悪い例：テストを修正
def test_calculate_total():
    assert calculate_total([1, 2, 3]) == 5  # テストを実装に合わせる

# ✅ 正しい例：実装を修正
def calculate_total(numbers):
-    return sum(numbers) - 1  # バグ
+    return sum(numbers)       # 修正
```

### 2. 例外処理の透明性

**例外が許される場合**:

#### a. 既知の制約・技術的負債
```python
# 許容される例：既知の制約を明示
# TODO: Issue #123 - Python 3.8でのみ失敗する既知の問題
@pytest.mark.skip(reason="Python 3.8 compatibility issue - tracking in #123")
def test_advanced_feature():
    pass
```

#### b. 実装中の機能（明示的マーク）
```javascript
// 許容される例：実装中の機能を明示
describe.skip('Advanced feature (WIP - see PR #456)', () => {
  it('should handle edge cases', () => {
    // 実装中
  })
})
```

**例外処理の条件**:
- [ ] Issue/PRで追跡されている
- [ ] スキップ理由が明確
- [ ] 修正予定が明示されている
- [ ] ユーザーに報告済み

### 3. 品質維持の原則

**原則**:
- カバレッジは維持または向上のみ
- Lintルールは追加または維持のみ
- CI/CD は強化または維持のみ
- 品質基準は向上または維持のみ

**記録**:
```markdown
# QUALITY_CHANGELOG.md

## 2025-12-27
- カバレッジ: 85% → 87% ✅ 向上
- Lintエラー: 12件 → 8件 ✅ 改善
- CI実行時間: 5分 → 4分30秒 ✅ 改善

## 禁止事項（記録例）
❌ カバレッジ: 85% → 80%（低下は禁止）
❌ Lintルール無効化（品質低下は禁止）
```

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 基本方針の提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**:
  - `code-quality-enforcer`（technical-projects-cli）
  - `prompt-purpose-validator`（prompt-creation-projects-cli）
- **機能**: 改ざんパターンの検出と警告

### Layer 3: Hooks
- **効果**: 強（実行前にブロック可能）
- **フック**:
  - `quality_check.sh`（PreToolUse: Edit/Write）
  - `prevent_false_completion.sh`（UserPromptSubmit）
- **機能**:
  - テスト・lint改ざんの検出
  - 削除・スキップパターンの検出
  - blocked=trueで実行停止

## 検出パターン

### 改ざんの兆候（Hook検出対象）

**1. テストファイルの変更**:
```bash
# Hook検出パターン
grep -E "(\-.*assert|describe\.skip|it\.skip|@skip|TODO.*skip)" git diff
```

**2. Lint設定の緩和**:
```bash
# Hook検出パターン
grep -E "(eslint-disable|pylint: disable|noqa)" git diff
```

**3. CI設定の変更**:
```bash
# Hook検出パターン
grep -E "(#.*run:.*test|\|\| true)" .github/workflows/*.yml
```

## ベストプラクティス

### 1. t-wadaスタイルTDD（Red-Green-Refactor）

**出典**: 和田卓人（t-wada）氏 - 日本におけるTDDの第一人者、Kent Beck著『テスト駆動開発』翻訳者

#### TDDの定義（Kent Beck、t-wada訳）

1. **テストリストを書く**: 網羅したいテストシナリオのリスト
2. **1つだけ選ぶ**: 具体的で実行可能なテストコードに翻訳
3. **テストを通す**: プロダクトコードを変更
4. **リファクタリング**: 設計を改善
5. **繰り返す**: テストリストが空になるまで

#### 黄金の回転

```
           きれい
              |
    (目標)    |  ← 「動作するきれいなコード」
              |
動かない -----+------ 動作する
              |
   ↑ Red     |     Green ↓
              |
           汚い
              ↑
         Refactor
```

**核心思想**:
> 「動作する」を先に、「きれい」は後
> どれだけ汚くてもかまわない、「動作する」を優先する
> — t-wada

#### AI（Claude Code）との役割分担

| フェーズ | 担当 | 理由 |
|---------|------|------|
| テストリスト作成 | **人間** | 設計判断が必要 |
| Red（失敗テスト） | 人間 or AI | 仕様理解の確認 |
| Green（最短実装） | **AI** | 「汚くても早く動かす」が得意 |
| Refactor | **人間主導** | AIだと「ぐちゃっとなる」 |

**t-wadaの見解（2025年）**:
> 「TDDのいいところは汚くても動かして、あとでキレイにするところ。前者の『汚くても早く動かして』はAIが得意としているが、今のAIだとそのまま続けると『キレイにする』ところであるリファクタリングで、ぐちゃっとなってしまう」

#### 効果的なプロンプト

```
❌ 「きれいなコードを書いてください」
✅ 「先ほど書いたコードをまねしてください」
```

これは一種のコンテキストエンジニアリング。

#### テストリストの重要性

> 「TDDとはレッド、グリーン、リファクタの3ステップを繰り返すものである」という**誤認**がある。ここで抜け落ちているのは**テストリスト**。
> — t-wada

**テストリスト例**:
```markdown
## テストリスト: ユーザー認証機能

- [ ] 正常系: 有効な認証情報でログイン成功
- [ ] 正常系: ログアウト後にセッション無効化
- [ ] 異常系: 無効なパスワードでエラー
- [ ] 異常系: 存在しないユーザーでエラー
- [ ] 境界値: パスワード最小文字数
- [ ] セキュリティ: ブルートフォース対策
```

#### アサーション規約（power-assert思想）

> 「No API is the best API」（APIがないことが最良のAPI）
> — t-wada

**覚えるべき3つのAPI**:
1. `assert(actual)`
2. `assert.deepEqual(actual, expected)`
3. `assert.notDeepEqual(actual, expected)`

**one assertion per test**: 1テスト1アサーションを推奨

#### TDDと改ざん防止

**TDDはAI時代の「ガードレール」**:
> 「生成AI以前にはコードを触るのはみんな人間でしたが、今はチームに生成AIも加わっている。そこにTDDを取り入れれば、コードとそれをメンテナンスする人間との距離、つまり技術的負債をある程度までコントロールできるようになる」
> — t-wada（Agile Journey 2025）

**禁止される改ざん（再掲）**:
- ❌ テストの期待値を実装に合わせて変更
- ❌ アサーションの削除・コメントアウト
- ❌ `it.skip`, `describe.skip`でスキップ
- ❌ タイムアウトの過度な延長

#### 参考リソース

- [t-wadaのブログ](https://t-wada.hatenablog.jp/)
- [Speaker Deck @twada](https://speakerdeck.com/twada)
- [AIエージェント時代に、TDDは「ガードレール」になる](https://agilejourney.uzabase.com/entry/2025/08/29/103000)
- [power-assert](https://github.com/power-assert-js/power-assert)

### 2. Fix Forward, Not Backward

**原則**:
> 基準を下げるのではなく、実装を上げる

**例**:
```
❌ Backward（基準を下げる）:
  - カバレッジ 85% → 80%
  - Lintエラー許容

✅ Forward（実装を上げる）:
  - テストを追加してカバレッジ 85% → 90%
  - Lintエラーを修正
```

### 3. 透明性の原則

**改ざんではなく、明示的な意思決定**:

```markdown
# ❌ 悪い例：こっそり改ざん
- カバレッジ閾値を下げる（記録なし）

# ✅ 良い例：明示的な意思決定
## 品質基準の一時的緩和（PR #789）

**理由**: 外部APIのモックが困難なため、一時的にカバレッジを80%に設定

**期限**: 2025-12-31まで

**対策**:
- Issue #790でモック実装を追跡
- 2週間後にレビュー

**承認**: @user (2025-12-27)
```

## 関連ドキュメント

### パッケージ固有ルール
- `technical-projects-cli/docs/rules/test.md` - テスト改ざん詳細（技術系）
- `technical-projects-cli/docs/rules/implementation.md` - 実装品質
- `prompt-creation-projects-cli/docs/rules/prompt-testing.md` - プロンプトテスト

### 共有ルール
- `shared/rules/evidence-based-thinking.md` - 証拠ベース思考
- `shared/rules/hook-response-protocol.md` - Hook警告への対応

## 参考リンク

- [obra/superpowers](https://github.com/obra/superpowers): TDD鉄則
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 1, Sin 2
- [Google Testing Blog](https://testing.googleblog.com/): テストベストプラクティス

---

**最終更新**: 2026-01-23
**バージョン**: 1.1
**ステータス**: Phase 4統合版（汎用）+ t-wadaスタイルTDD追加
**適用**: すべてのパッケージ
