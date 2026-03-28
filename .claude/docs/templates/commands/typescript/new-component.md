---
description: React + TypeScriptコンポーネントをTDDで作成
argument-hint: <ComponentName>
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# React + TypeScript コンポーネント作成（TDDスタイル）

**コンポーネント名**: $ARGUMENTS

## 概要

t-wadaスタイルのTDDに従い、テストファーストでコンポーネントを作成します。

---

## Step 1: テストリスト作成

`$ARGUMENTS`コンポーネントのテストリストを作成してください。

```markdown
## テストリスト: $ARGUMENTS

- [ ] レンダリング: 正常にレンダリングされる
- [ ] Props: 必須propsが正しく表示される
- [ ] Props: オプショナルpropsがデフォルト動作する
- [ ] イベント: クリックイベントが発火する
- [ ] 状態: 状態変更が正しく反映される
- [ ] アクセシビリティ: 適切なaria属性がある
```

---

## Step 2: Red（失敗するテストを書く）

まず、テストファイルを作成します。

**ファイル**: `src/components/$ARGUMENTS/$ARGUMENTS.test.tsx`

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { $ARGUMENTS } from './$ARGUMENTS';

describe('$ARGUMENTS', () => {
  it('正常にレンダリングされる', () => {
    render(<$ARGUMENTS />);

    // TODO: 適切なクエリに置き換え
    expect(screen.getByRole('...')).toBeInTheDocument();
  });
});
```

**確認**: テストが失敗することを確認
```bash
npm test -- --testPathPattern=$ARGUMENTS
```

---

## Step 3: Green（最短で通す）

コンポーネント本体を作成します。

**ファイル**: `src/components/$ARGUMENTS/$ARGUMENTS.tsx`

```typescript
import { FC } from 'react';

/**
 * $ARGUMENTS コンポーネント
 */
export interface $ARGUMENTSProps {
  // TODO: props定義
}

export const $ARGUMENTS: FC<$ARGUMENTSProps> = (props) => {
  return (
    <div>
      {/* TODO: 最小限の実装 */}
    </div>
  );
};

$ARGUMENTS.displayName = '$ARGUMENTS';
```

**インデックスファイル**: `src/components/$ARGUMENTS/index.ts`

```typescript
export { $ARGUMENTS } from './$ARGUMENTS';
export type { $ARGUMENTSProps } from './$ARGUMENTS';
```

**確認**: テストが通ることを確認
```bash
npm test -- --testPathPattern=$ARGUMENTS
```

---

## Step 4: Refactor

テストが通ったままで、以下を改善してください:

1. **Props型の詳細化**: 必要なpropsを追加
2. **スタイリング**: Tailwind CSS / CSS Modules
3. **アクセシビリティ**: aria属性、semantic HTML
4. **エラーハンドリング**: ErrorBoundary対応

---

## Step 5: テスト拡充

テストリストの残りのテストを追加してください。

**追加テスト例**:
```typescript
describe('$ARGUMENTS', () => {
  // ... 既存テスト ...

  it('クリック時にonClickが呼ばれる', async () => {
    const handleClick = vi.fn();
    render(<$ARGUMENTS onClick={handleClick} />);

    await userEvent.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('disabled時はクリックできない', async () => {
    const handleClick = vi.fn();
    render(<$ARGUMENTS onClick={handleClick} disabled />);

    await userEvent.click(screen.getByRole('button'));

    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

---

## 出力ファイル一覧

| ファイル | 内容 |
|---------|------|
| `src/components/$ARGUMENTS/$ARGUMENTS.tsx` | コンポーネント本体 |
| `src/components/$ARGUMENTS/$ARGUMENTS.test.tsx` | テストファイル |
| `src/components/$ARGUMENTS/index.ts` | エクスポート |

---

## チェックリスト

- [ ] テストリストを作成した
- [ ] 失敗するテストを書いた（Red）
- [ ] 最短で通した（Green）
- [ ] リファクタリングした
- [ ] 残りのテストを追加した
- [ ] 型チェックが通る（`npm run type-check`）
- [ ] Lintが通る（`npm run lint`）

---

## 既存パターン参照

プロジェクト内の既存コンポーネントを参考にしてください:

```bash
ls src/components/
```

既存コンポーネントのパターンを踏襲することで、コードベースの一貫性を保ちます。
