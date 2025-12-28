# 実装品質ルール

**対策対象**: FP-2（実装ショートカット）, FP-4（文脈無視）
**優先度**: High
**出典**: vibration-diagnosis-prototype失敗事例、obra/superpowers、WORK_PROCESS_PROTOCOLS

## やってはいけないこと

### 1. 実装ショートカット（FP-2）

**絶対禁止**:
- 仕様を満たさない簡易実装
- エラーハンドリングの省略
- 入力バリデーションの省略
- セキュリティチェックの省略
- ロギングの省略
- ドキュメントの省略

**具体例（vibration-diagnosis-prototype Sin 2）**:
```typescript
// ❌ 悪い例：エラーハンドリング省略
async function fetchData(url: string) {
  const response = await fetch(url)  // エラー処理なし
  return response.json()              // 失敗時の考慮なし
}

// ✅ 正しい例：適切なエラーハンドリング
async function fetchData(url: string): Promise<Data> {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    return await response.json()
  } catch (error) {
    logger.error('Failed to fetch data', { url, error })
    throw new DataFetchError('Data fetch failed', { cause: error })
  }
}
```

### 2. 文脈無視（FP-4）

**禁止**:
- 既存のコーディングスタイル・パターンを無視する
- プロジェクト固有の命名規則を無視する
- 既存のエラーハンドリングパターンを無視する
- アーキテクチャパターンを無視する

**具体例（vibration-diagnosis-prototype Sin 4）**:
```python
# ❌ 悪い例：既存パターン無視
# プロジェクトは snake_case を使用しているのに camelCase を導入
def parseUserData(userData):  # 既存パターンと不一致
    pass

# ✅ 正しい例：既存パターンに従う
def parse_user_data(user_data):  # snake_case で統一
    pass
```

### 3. 未検証の実装

**禁止**:
- 動作確認せずにコミット
- テストなしで実装完了と報告
- ドキュメントとの整合性を確認せずに実装
- 依存関係の影響を確認せずに変更

## やるべきこと

### 1. 実装前の確認（Pre-Implementation Checklist）

**必須確認事項**:
- [ ] 仕様・要件の理解（不明点はAskUserQuestionで確認）
- [ ] 既存コードの調査（Grep, Read使用）
- [ ] 既存パターンの把握（命名規則、エラーハンドリング、アーキテクチャ）
- [ ] 影響範囲の特定（依存関係、呼び出し元）
- [ ] テスト戦略の策定

**コード調査の例**:
```bash
# 既存のエラーハンドリングパターンを調査
$ grep -r "try.*catch" --include="*.ts" src/

# 既存の命名規則を調査（関数名）
$ grep -r "function\s\+\w\+" --include="*.ts" src/ | head -20

# 同様の機能実装を探す
$ grep -r "fetchData\|fetch_data" --include="*.ts" src/
```

### 2. 段階的実装（obra/superpowers方式）

**TDD鉄則**:
1. **Red**: 失敗するテストを先に書く
2. **Green**: テストをパスする最小限の実装
3. **Refactor**: リファクタリング

**例**:
```typescript
// Step 1: Red - 失敗するテストを書く
describe('UserService', () => {
  it('should fetch user by id', async () => {
    const user = await userService.getById('user-123')
    expect(user).toEqual({ id: 'user-123', name: 'Test User' })
  })
})

// Step 2: Green - 最小限の実装
class UserService {
  async getById(id: string): Promise<User> {
    const response = await fetch(`/api/users/${id}`)
    return response.json()
  }
}

// Step 3: Refactor - エラーハンドリング、バリデーション追加
class UserService {
  async getById(id: string): Promise<User> {
    if (!id) throw new ValidationError('User ID is required')

    try {
      const response = await fetch(`/api/users/${id}`)
      if (!response.ok) {
        throw new HttpError(`Failed to fetch user: ${response.status}`)
      }
      return await response.json()
    } catch (error) {
      logger.error('User fetch failed', { id, error })
      throw error
    }
  }
}
```

### 3. 文脈適合の確認

**既存パターンの踏襲**:

```typescript
// Step 1: 既存コードを調査
// $ grep -A 5 "class.*Service" src/services/*.ts

// Step 2: パターンを把握
// 既存: すべてのServiceクラスはBaseServiceを継承
// 既存: エラーは CustomError を継承したクラスを使用
// 既存: ロギングは logger.error({ context, error }) 形式

// Step 3: パターンに従って実装
class UserService extends BaseService {
  async getById(id: string): Promise<User> {
    try {
      return await this.fetchJson(`/api/users/${id}`)  // BaseServiceのメソッド使用
    } catch (error) {
      logger.error({ method: 'getById', userId: id, error })  // 既存形式
      throw new UserServiceError('Failed to get user', { cause: error })  // CustomError継承
    }
  }
}
```

### 4. 実装完了の定義（Definition of Done）

**完了基準**:
- [ ] すべてのテストがパス
- [ ] カバレッジが維持・向上
- [ ] 既存パターンに準拠
- [ ] エラーハンドリング実装済み
- [ ] ロギング実装済み
- [ ] ドキュメント更新済み（必要な場合）
- [ ] コードレビュー基準を満たす

## 例外処理

### 例外が許される場合

1. **プロトタイピング・PoC**
   - **条件**: ユーザーが「とりあえず動くものを」と明示
   - **手順**:
     1. プロトタイプであることを明記（コメント、ファイル名）
     2. 本実装時の TODO を記載
     3. ユーザーに「本実装が必要」と伝える

2. **段階的実装**
   - **条件**: 大規模機能の段階的実装
   - **手順**:
     1. 実装計画をユーザーに提示
     2. Phase 1, 2, 3... と明確に分割
     3. 各Phaseの完了基準を定義

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 基本方針の提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**:
  - `purpose-driven-impl`: 目的優先思考の誘導
  - `code-quality-enforcer`: 実装品質チェック

### Layer 3: Hooks
- **効果**: 強（実行前にブロック可能）
- **フック**: `quality_check.sh`（PreToolUse: Write/Edit）
- **機能**:
  - エラーハンドリング省略検出
  - try-catch パターン確認
  - TODO/FIXME の存在確認

## ベストプラクティス

### 1. Purpose-Driven Implementation（目的優先実装）

**obra/superpowersより**:
> 実装する前に「なぜこれを実装するのか」を明確にする

**実践**:
```markdown
# 実装前の自問自答
1. この機能の目的は何か？
2. 誰が使うのか？
3. どのような価値を提供するのか？
4. 失敗時の影響は？
5. 代替手段は？
```

### 2. Evidence-Based Implementation（証拠ベース実装）

**WORK_PROCESS_PROTOCOLS Protocol 1より**:
> 推測ではなく、コードを読んで確認する

**実践**:
```bash
# 推測: "この関数は ID を返すはず"
# ❌ 推測で実装を進めない

# 証拠: コードを読んで確認
$ grep -A 10 "function getUserId" src/auth/*.ts
# ✅ 実際の戻り値を確認してから実装
```

### 3. Incremental Implementation（漸進的実装）

**手順**:
1. 最小限の機能実装
2. テスト追加
3. エラーハンドリング追加
4. バリデーション追加
5. ロギング追加
6. ドキュメント追加

## 関連ドキュメント

- `test.md`: テスト品質ルール
- `evidence-based-thinking.md`: 証拠ベース思考
- `task-integrity.md`: タスク範囲の遵守
- `deployment.md`: デプロイ検証
- `shared/rules/anti-tampering-rules.md`: 汎用改ざん防止

## 参考リンク

- [obra/superpowers](https://github.com/obra/superpowers): Purpose-Driven Development
- [vibration-diagnosis-prototype WORK_PROCESS_PROTOCOLS](vibration-diagnosis-prototype/docs/WORK_PROCESS_PROTOCOLS_20251227.md): Protocol 1, 3
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 2, Sin 4, Sin 10

---

**最終更新**: 2025-12-27
**バージョン**: 1.0
**ステータス**: Phase 4統合版
