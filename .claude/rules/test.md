# テスト品質ルール

**対策対象**: FP-1（テスト改ざん）
**優先度**: Critical
**出典**: vibration-diagnosis-prototype失敗事例、びーぐるPDF、obra/superpowers

## やってはいけないこと

### 1. テストを弱めてパスさせる

**絶対禁止**:
- テストの期待値を実装に合わせて変更する
- アサーションを削除・コメントアウトする
- テストケースを削除する
- テストをスキップ(`@skip`, `it.skip`, `describe.skip`等)する
- タイムアウトを過度に延長する（10秒以上）
- モックの戻り値を「とりあえず通る値」に変更する

**具体例（vibration-diagnosis-prototype Sin 1）**:
```python
# ❌ 悪い例：テストを実装に合わせて改ざん
def test_parse_dataframe():
-    assert result.shape == (100, 5)  # 期待される正しい形状
+    assert result.shape == (50, 3)   # 実装の誤りに合わせて変更
```

### 2. テストの目的を歪める

**禁止**:
- テストの検証内容を削減する
- エッジケースのテストを削除する
- エラーケースのテストを削除する
- カバレッジのためだけのダミーテストを追加する

### 3. テスト設定の改ざん

**禁止**:
- `pytest.ini`, `jest.config.js`等の設定ファイルでテストを除外する
- `.gitignore`でテストファイルを無視する
- CI設定(`pytest.yml`, `test.yml`)でテストを無効化する
- カバレッジ閾値を下げる（現状維持か向上のみ許可）

## やるべきこと

### 1. テスト失敗時の正しいアプローチ

**TDD鉄則** (obra/superpowers):
> NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**手順**:
1. **失敗原因の特定**: テスト出力を詳細に読む
2. **期待値の検証**: テストの期待値が正しいか確認する
3. **実装の修正**: 実装を期待値に合わせて修正する
4. **テストの追加**: 不足しているテストケースを追加する

**具体例**:
```python
# ✅ 正しい例：実装を修正してテストをパスさせる

# Test (変更なし)
def test_parse_dataframe():
    assert result.shape == (100, 5)  # 期待値はそのまま

# Implementation (修正)
def parse_dataframe(data):
-    return pd.DataFrame(data[:50])  # 誤った実装
+    return pd.DataFrame(data)       # 正しい実装
```

### 2. テスト追加のベストプラクティス

**カバレッジ向上**:
- エッジケース: 空配列、null、undefined、0、負数
- エラーケース: 不正な入力、API障害、タイムアウト
- 境界値: 最小値、最大値、範囲外

**例**:
```typescript
describe('parseData', () => {
  it('should handle empty array', () => {
    expect(parseData([])).toEqual([])
  })

  it('should throw on null input', () => {
    expect(() => parseData(null)).toThrow()
  })

  it('should handle maximum array size', () => {
    const largeArray = new Array(10000).fill(1)
    expect(parseData(largeArray)).toBeDefined()
  })
})
```

### 3. テスト品質の確認

**チェックリスト**:
- [ ] すべてのテストがパスしているか
- [ ] カバレッジが維持・向上しているか
- [ ] 新機能に対応するテストが追加されているか
- [ ] エッジケース・エラーケースをカバーしているか
- [ ] テストの実行時間が適切か（1テスト < 1秒が目安）

## 例外処理

### 例外が許される場合

1. **テストの誤りが明確な場合**
   - **条件**: 仕様書・ドキュメントと照らし合わせてテストが間違っている
   - **手順**:
     1. ユーザーに確認を求める（AskUserQuestion）
     2. 承認後に修正
     3. 修正理由をコミットメッセージに記載

2. **テストフレームワーク移行の場合**
   - **条件**: Jest → Vitest、mocha → Jest等のフレームワーク移行
   - **手順**:
     1. 移行計画をユーザーに提示
     2. 承認後に段階的移行
     3. 移行前後でテストカバレッジを維持

3. **過度に厳格なテストの緩和**
   - **条件**: 誤差範囲の調整（小数点以下の桁数等）
   - **手順**:
     1. 技術的根拠を提示
     2. ユーザーに確認
     3. 承認後に調整

### 例外処理の手順

```markdown
# AskUserQuestion使用例

**質問**: このテストは実装の仕様変更に伴い、期待値の更新が必要です。更新してよろしいですか？

**背景**:
- 仕様書: データ形状は(N, 3)と定義されている
- 現在のテスト: (N, 5)を期待している
- 実装: 仕様書通り(N, 3)を返している

**提案**:
テストの期待値を(N, 5)から(N, 3)に更新する
```

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 基本方針の提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**: `code-quality-enforcer`
- **機能**: テスト改ざんパターンの検出と警告

### Layer 3: Hooks
- **効果**: 強（実行前にブロック可能）
- **フック**: `quality_check.sh`（PreToolUse: Edit/Write）
- **機能**: テストファイル編集時にdiffをチェック、削除・スキップパターンを検出

## 関連ドキュメント

- `implementation.md`: 実装ショートカットの防止
- `evidence-based-thinking.md`: 推測による実装の防止
- `shared/rules/anti-tampering-rules.md`: 汎用改ざん防止ルール
- `phase3-use-cases-tips/step3.5-failure-case-analysis.md`: 失敗パターン詳細

## 参考リンク

- [obra/superpowers](https://github.com/obra/superpowers): TDD徹底のCLAUDE.md実例
- [びーぐるPDF](work/claude-code-reference/phase3-use-cases-tips/): テスト品質確保の実践知見
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 1, Sin 2, Sin 9の詳細

---

**最終更新**: 2025-12-27
**バージョン**: 1.0
**ステータス**: Phase 4統合版
