---
description: TypeScript型安全性監査を実行
allowed-tools: Read, Bash, Grep, Glob
---

# TypeScript型安全性監査

## 目的

プロジェクトのTypeScript設定を監査し、AIコーディング（Claude Code等）との相性を最大化するための改善提案を行う。

---

## Step 1: tsconfig.json確認

現在のtsconfig.jsonを確認します。

```bash
cat tsconfig.json
```

---

## Step 2: 厳密性スコア評価

以下の設定項目をチェックし、厳密性スコアを評価してください。

### 必須設定（★★★★★）

| 設定 | 推奨値 | 効果 |
|------|--------|------|
| `strict` | `true` | 基本的な厳密チェック一式 |
| `noUncheckedIndexedAccess` | `true` | 配列・オブジェクトアクセスの安全性 |
| `noImplicitReturns` | `true` | 分岐漏れ防止 |

### 推奨設定（★★★★☆）

| 設定 | 推奨値 | 効果 |
|------|--------|------|
| `noUnusedLocals` | `true` | 未使用変数検出（改ざん防止） |
| `noUnusedParameters` | `true` | 未使用引数検出 |
| `noImplicitOverride` | `true` | オーバーライド明示化 |
| `exactOptionalPropertyTypes` | `true` | undefined vs 欠落の区別 |
| `noPropertyAccessFromIndexSignature` | `true` | インデックス署名アクセス制限 |
| `noFallthroughCasesInSwitch` | `true` | switchのfall-through防止 |

---

## Step 3: 型エラーチェック

現在の型エラー状況を確認します。

```bash
npx tsc --noEmit 2>&1 | head -50
```

---

## Step 4: any型の使用状況

`any`型の使用箇所を検出します。

```bash
grep -rn ": any" --include="*.ts" --include="*.tsx" src/ | head -30
```

**評価基準**:
- **Good**: 0件
- **Warning**: 1-10件（段階的に削減推奨）
- **Critical**: 10件以上（品質リスク）

---

## Step 5: 改善提案

### A. tsconfig.json改善案

以下の設定を段階的に導入してください:

**Phase 1（即時）**:
```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

**Phase 2（1-2週間後）**:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true
  }
}
```

**Phase 3（1ヶ月後）**:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true
  }
}
```

### B. any型の削減

`any`を以下に置き換え:
- `unknown`: 型が不明な場合（型ガード必須）
- 具体的な型: 型定義を追加
- ジェネリクス: 柔軟性が必要な場合

### C. 型パターン導入

**Discriminated Union**（状態管理）:
```typescript
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

**Result型**（エラーハンドリング）:
```typescript
// neverthrowライブラリ推奨
import { Result, ok, err } from 'neverthrow';

function divide(a: number, b: number): Result<number, 'DIVIDE_BY_ZERO'> {
  if (b === 0) return err('DIVIDE_BY_ZERO');
  return ok(a / b);
}
```

**Branded Types**（ドメインID）:
```typescript
type UserId = string & { readonly brand: 'UserId' };
type OrderId = string & { readonly brand: 'OrderId' };
```

---

## 監査レポート

**プロジェクト**: [プロジェクト名]
**監査日**: [日付]

### 厳密性スコア

| 設定 | 現状 | 推奨 | ステータス |
|------|------|------|-----------|
| strict | | true | |
| noUncheckedIndexedAccess | | true | |
| noImplicitReturns | | true | |
| noUnusedLocals | | true | |

### any型使用状況

- **件数**: [件数]
- **評価**: Good / Warning / Critical

### 改善優先度

1. [最優先の改善項目]
2. [次の改善項目]
3. [その次の改善項目]

---

## 参考

- [TypeScript TSConfig Reference](https://www.typescriptlang.org/tsconfig/)
- [TypeScript's rise in the AI era](https://github.blog/developer-skills/)
- [neverthrow](https://github.com/supermacro/neverthrow)
