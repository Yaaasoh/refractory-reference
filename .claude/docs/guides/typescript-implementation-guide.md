# TypeScript + Claude Code 実装ガイド

**調査日**: 2026-01-22
**目的**: TypeScriptでClaude Codeが実装する際の利点・相性・Tips・ノウハウの整理
**総調査回数**: WebSearch 21回

---

## 目次

### Part 1: 基礎編（初回調査）
1. [TypeScriptとClaude Codeの相性が良い理由](#1-typescriptとclaude-codeの相性が良い理由)
2. [型システムがClaude Codeに与える影響](#2-型システムがclaude-codeに与える影響)
3. [LSPサポートの活用](#3-lspサポートの活用)
4. [推奨tsconfig.json設定](#4-推奨tsconfigjson設定)
5. [CLAUDE.md設定のベストプラクティス](#5-claudemd設定のベストプラクティス)
6. [相性の良いコーディングパターン](#6-相性の良いコーディングパターン)
7. [実践的なTips・ノウハウ](#7-実践的なtipsノウハウ)
8. [生産性向上の実績データ](#8-生産性向上の実績データ)
9. [参考リソース](#9-参考リソース)

### Part 2: 深掘り編（Step 1-8追記）
10. [高度な型パターン（AI向け深掘り）](#10-高度な型パターンai向け深掘り)
11. [参考リソース（追加）](#107-参考リソース追加)
12. [テスト戦略とClaude Code](#12-テスト戦略とclaude-code)
13. [参考リソース（テスト関連）](#1210-参考リソーステスト関連)
14. [エラーハンドリングパターン](#14-エラーハンドリングパターン)
15. [参考リソース（エラーハンドリング）](#147-参考リソースエラーハンドリング)
16. [実プロジェクトワークフロー & CI/CD統合](#16-実プロジェクトワークフロー--cicd統合)
17. [参考リソース（ワークフロー）](#1611-参考リソースワークフロー)
18. [カスタムコマンド & Skills詳細](#18-カスタムコマンド--skills詳細)
19. [参考リソース（コマンド）](#1810-参考リソースコマンド)
20. [Hooks詳細設定](#20-hooks詳細設定)
21. [参考リソース（Hooks）](#2012-参考リソースhooks)
22. [Monorepo設定（Turborepo / Nx）](#22-monorepo設定turborepo--nx)
23. [参考リソース（Monorepo）](#2211-参考リソースmonorepo)
24. [API設計（tRPC / GraphQL）](#24-api設計trpc--graphql)
25. [まとめ](#25-まとめ)

---

## 1. TypeScriptとClaude Codeの相性が良い理由

### 1.1 型情報による明確なコンテキスト提供

TypeScriptの型情報は、Claude Codeに対して**明確な仕様書**として機能する。

| 言語 | AIの理解方法 | 精度 |
|------|-------------|------|
| JavaScript | 変数名・コメント・使用パターンから推測 | 低〜中 |
| TypeScript | 型定義を仕様として読み込む | 高 |

**具体例**:
```typescript
// JavaScriptの場合: AIは「推測」する
function formatPrice(value) {
  // valueは何型？stringかもしれないしnumberかもしれない
}

// TypeScriptの場合: AIは「確定」できる
function formatPrice(value: number): string {
  // valueは必ずnumber、戻り値は必ずstring
}
```

### 1.2 GitHub統計データ（2025年）

GitHub Octoverse 2025によると:
- TypeScriptはPythonとJavaScriptを抜いて**最も人気のある言語**に
- この成長の主要因は**AIコーディングツールとの相性の良さ**
- TypeScript + AIツールを使うチームは「production-ready codeの生成が速く、バグが少ない」

### 1.3 自己修正能力の向上

型エラーがAIの自己修正を助ける:

> 「AIがハルシネーションを起こしても、TypeScript型システムが迅速な反復と修正を強制した。デプロイや追加プラグインは不要で、組み込みのTypeScript Language Serverがほとんどの作業を行った」
> — [The Unexpected Benefits of Using TypeScript with AI-Aided Development](https://pm.dartus.fr/posts/2025/typescript-ai-aided-development/)

---

## 2. 型システムがClaude Codeに与える影響

### 2.1 曖昧性の排除

**strictモード有効時**:
- すべての変数・関数引数・戻り値に型が明示
- `any`型が禁止されるため、推測に頼らない
- 型レベルで入出力の契約が保証される

### 2.2 厳密な型定義の重要性

> 「型を丁寧に作り込むことが重要。無効な状態を明示的に禁止する厳密な型を使うことで、AIエージェントがより高品質で正確なコードを生成するよう誘導できる」

**効果的な型定義の例**:
```typescript
// 悪い例: 曖昧な型
type User = {
  status: string;  // "active", "inactive", "pending" のどれか？
};

// 良い例: 厳密な型
type UserStatus = 'active' | 'inactive' | 'pending';
type User = {
  status: UserStatus;  // 3つの値のみ許可
};
```

### 2.3 エラーハンドリングの強制

Result型パターンを使うことで、エラー処理の漏れを型レベルで検出:

```typescript
type Result<T, E> =
  | { ok: true; value: T }
  | { ok: false; error: E };

// 使用側は必ずエラーケースを処理する必要がある
const result = await fetchUser(id);
if (result.ok) {
  console.log(result.value.name);
} else {
  console.error(result.error);  // 必須
}
```

---

## 3. LSPサポートの活用

### 3.1 Claude Code LSP（2025年12月導入）

Claude Code v2.0.74でLSPサポートが公式追加:

| 機能 | 説明 | 効果 |
|-----|------|------|
| Go to Definition | 定義元へジャンプ | コード理解の高速化 |
| Find References | 参照箇所の検索 | 影響範囲の把握 |
| Hover | 型情報の表示 | 即座に型確認 |
| Get Diagnostics | エラー・警告の取得 | リアルタイム品質チェック |
| Document Symbol | シンボル一覧 | ファイル構造の把握 |

### 3.2 パフォーマンス改善

> 「LSP有効時、Claude Codeはコードベースを**45秒→50ms**でナビゲート。従来のテキスト検索から根本的に変革」

### 3.3 TypeScript LSPのセットアップ

```bash
# vtsls（推奨）のインストール
/plugin install vtsls@claude-code-lsps

# または手動インストール
npm install -g @vtsls/language-server typescript
```

**注意**: 公式マーケットプレイスのtypescript-lspプラグインは不完全（plugin.json欠落）との報告あり。vtsls@claude-code-lspsの使用を推奨。

---

## 4. 推奨tsconfig.json設定

### 4.1 Claude Code最適化設定

```json
{
  "compilerOptions": {
    // 基本設定
    "target": "ES2024",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2024"],
    "rootDir": "src",
    "outDir": "./dist",

    // ★ 最重要: Strict Mode
    "strict": true,

    // ★ 追加の厳密チェック（Claude Code推奨）
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "noFallthroughCasesInSwitch": true,

    // ★ 未使用コード検出（改ざん防止に有効）
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,

    // モジュール解決
    "resolveJsonModule": true,
    "allowJs": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,

    // 開発支援
    "incremental": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### 4.2 各オプションの効果

| オプション | Claude Codeでの効果 |
|-----------|-------------------|
| `strict: true` | 曖昧性排除、AI提案精度向上 |
| `noUncheckedIndexedAccess` | 配列・オブジェクトの不正アクセスを事前検出 |
| `exactOptionalPropertyTypes` | `undefined` vs 欠落の区別を強制 |
| `noImplicitReturns` | 分岐漏れをAIが発見しやすい |
| `noUnusedLocals/Parameters` | AI改ざん防止（テストコード改ざん等の検出） |

### 4.3 段階的導入（既存プロジェクト向け）

**Phase 1（第1週）**: 基本strict mode
```json
{ "strict": true }
```

**Phase 2（第2-3週）**: 追加のstrict checks
```json
{
  "strict": true,
  "noUncheckedIndexedAccess": true,
  "noImplicitOverride": true
}
```

**Phase 3（第4週以降）**: 完全な厳密化

---

## 5. CLAUDE.md設定のベストプラクティス

### 5.1 TypeScriptプロジェクト向けCLAUDE.md

```markdown
# プロジェクト概要

React 18 + TypeScript + Vite のフロントエンドプロジェクト

## 開発コマンド

- `npm run dev` - 開発サーバー起動
- `npm run build` - プロダクションビルド
- `npm run type-check` - 型チェック
- `npm run test` - テスト実行
- `npm run lint` - ESLint実行

## ディレクトリ構成

- `src/components/` - UIコンポーネント
- `src/hooks/` - カスタムフック
- `src/types/` - 型定義
- `src/utils/` - ユーティリティ関数
- `src/api/` - API呼び出し

## コードスタイル

- TypeScript strict mode 必須
- `any` 禁止、`unknown` を使用
- `type` より `interface` を優先（拡張性のため）
- コンポーネントは関数コンポーネント + Hooks

## テスト規約

- 新規コンポーネントには必ずテストを作成
- React Testing Library を使用
- テストファイル名: `*.test.tsx`

## 型定義規約

- Branded Types をドメインIDに使用
- Result型をエラーハンドリングに使用
- Loading/Error/Success の全状態を型で表現
```

### 5.2 Hooks設定（型チェック自動化）

```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsc --noEmit",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "npm run type-check",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### 5.3 複数CLAUDE.mdの配置

```
project/
├── CLAUDE.md                 # プロジェクト全体
├── frontend/
│   └── CLAUDE.md             # フロントエンド固有
├── backend/
│   └── CLAUDE.md             # バックエンド固有
└── deployment/
    └── CLAUDE.md             # デプロイ手順
```

---

## 6. 相性の良いコーディングパターン

### 6.1 Branded Types（ドメイン固有の型）

```typescript
// 型安全なID
type UserId = string & { readonly brand: 'UserId' };
type OrderId = string & { readonly brand: 'OrderId' };

// ファクトリ関数
function makeUserId(value: string): UserId {
  return value as UserId;
}

// UserId と OrderId を混同できない
function getUser(id: UserId): Promise<User> {
  // ...
}
```

**Claude Codeへの効果**: 異なるIDの混同を型レベルで防止

### 6.2 Discriminated Union（判別可能なUnion型）

```typescript
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function UserProfile({ userId }: { userId: UserId }) {
  const [state, setState] = useState<RequestState<User>>({ status: 'idle' });

  // 型ガードで全ケースの処理が強制される
  switch (state.status) {
    case 'idle':    return <Button>Load</Button>;
    case 'loading': return <Spinner />;
    case 'success': return <div>{state.data.name}</div>;
    case 'error':   return <Error error={state.error} />;
  }
}
```

**Claude Codeへの効果**: 全状態をカバーするテストの自動生成が容易

### 6.3 Zod による実行時型検証

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().min(0).optional(),
});

type User = z.infer<typeof UserSchema>;

// APIレスポンスの検証
const parseUser = (data: unknown): User => {
  return UserSchema.parse(data);
};
```

**Claude Codeへの効果**: スキーマ定義がAPIの契約として機能

---

## 7. 実践的なTips・ノウハウ

### 7.1 Git ワークフローとの統合

**ブランチ戦略**:
```bash
# 必ず新しいブランチで作業
git checkout -b feature/user-authentication

# Claude Codeに指示
"このブランチで認証機能を実装してください"
```

**Git Worktreesの活用**:
```bash
# 複数のClaude Codeインスタンスを並行実行
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
```

### 7.2 /rewind コマンドの活用

> 「不要なコード変更や方向性の誤ったプロンプトでセッションが脱線し、再開や修正にトークンを浪費することがある。/rewindは会話履歴とコード状態を以前のチェックポイントにロールバックし、安全な実験を可能にする」

### 7.3 @-mentions による型ファイル参照

```
@src/types/models.ts この型定義を使って、新しいAPIエンドポイントを実装してください
```

### 7.4 Planning Mode（Shift+Tab）の活用

複雑な変更前に計画を立てる:
1. Planning Modeを有効化
2. 実装計画を確認
3. 型チェック結果を事前に確認
4. 承認後に実装開始

### 7.5 カスタムコマンドの作成

`.claude/commands/new-component.md`:
```markdown
# 新しいReactコンポーネントを作成

## 入力
- $ARGUMENTS: コンポーネント名

## 出力
1. `src/components/${ARGUMENTS}.tsx` - コンポーネント本体
2. `src/components/${ARGUMENTS}.test.tsx` - テストファイル
3. 必要な型定義を `src/types/` に追加

## ルール
- 関数コンポーネントを使用
- Props型を明示的に定義
- React Testing Libraryでテスト作成
```

使用方法: `/new-component UserAvatar`

---

## 8. 生産性向上の実績データ

### 8.1 実例: 350k+ LOCコードベース

> 「過去4ヶ月間、350k+ LOC（PHP, TypeScript/React, React Native, Terraform, Python）のソロメンテナーとして、**80%以上のコード変更がClaude Codeによって書かれた**。生成→レビュー後のClaude Codeによる修正→最小限の手動リファクタリング」
> — [Claude Code in Production: 40% Productivity Increase](https://dev.to/dzianiskarviha/integrating-claude-code-into-production-workflows-lbn)

### 8.2 実例: 週10時間の節約

> 「毎週約10時間をテスト実行、バージョンアップ、デバッグなどの反復作業に費やしていた。Claude Codeで10個の自動化コマンドを構築した結果、**週10時間以上を節約**」
> — [Claude Code Have Automated My Entire Dev Workflow](https://dimitri-derthe.medium.com/how-i-automated-my-entire-typescript-workflow-and-saved-10-hours-per-week-7285c643d588)

### 8.3 実例: 30ファイル2日間

> 「30個のTypeScriptファイルを完全なテストカバレッジ付きで2日間で構築、現在本番運用中。適切なワークフロー構造 + 専門化されたエージェント = AI速度でのproduction-qualityコード」
> — [claude-code-workflows](https://github.com/shinpr/claude-code-workflows)

---

## 9. 参考リソース

### 公式ドキュメント
- [Claude Code Documentation](https://code.claude.com/docs)
- [Claude Agent SDK - TypeScript](https://platform.claude.com/docs/en/agent-sdk/typescript)
- [TypeScript TSConfig Reference](https://www.typescriptlang.org/tsconfig/)

### CLAUDE.md例
- [MCP TypeScript SDK CLAUDE.md](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/CLAUDE.md)
- [CLAUDE.md TypeScript Wiki](https://github.com/ruvnet/claude-flow/wiki/CLAUDE-MD-TypeScript)
- [Next.js + TypeScript CLAUDE.md Gist](https://gist.github.com/gregsantos/2fc7d7551631b809efa18a0bc4debd2a)

### LSP関連
- [Claude Code LSP Setup Guide](https://www.aifreeapi.com/en/posts/claude-code-lsp)
- [cclsp - Non-IDE LSP Integration](https://github.com/ktnyt/cclsp)
- [Piebald-AI claude-code-lsps](https://github.com/Piebald-AI/claude-code-lsps)

### ベストプラクティス
- [10 Claude Code Productivity Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)
- [7 Essential Claude Code Best Practices](https://www.eesel.ai/blog/claude-code-best-practices)
- [TypeScript vs JavaScript for AI Tools](https://www.builder.io/blog/typescript-vs-javascript)
- [Unexpected Benefits of TypeScript with AI Development](https://pm.dartus.fr/posts/2025/typescript-ai-aided-development/)

### ワークフロー
- [claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase)
- [claude-code-spec-workflow](https://github.com/Pimzino/claude-code-spec-workflow)
- [claude-code-workflows](https://github.com/shinpr/claude-code-workflows)

---

## 10. 高度な型パターン（AI向け深掘り）

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 4回

### 10.1 TypeScriptのAI時代における台頭

**GitHub Octoverse 2025の注目データ**:
- TypeScriptがPython・JavaScriptを抜いて**最も使用される言語**に
- 100万人以上の開発者が貢献（前年比66%増）
- 成長の主要因: **AIコーディングツールとの相性の良さ**

**Anders Hejlsberg（TypeScript Lead Architect）の見解**:
> 「AIの言語を書く能力は、その言語をどれだけ見てきたかに比例する。AIはJavaScript、Python、TypeScriptを大量に見ているので、これらの言語を書くのが非常に得意」

**AIツールでの違い**:
| アプローチ | JavaScript | TypeScript |
|-----------|------------|------------|
| AIの理解方法 | 変数名・使用パターンから**推測** | 型定義を**仕様書**として読み込む |
| エラー検出 | 実行時まで不明 | コンパイル時に検出 |
| 自己修正 | 限定的 | 型エラーメッセージで効果的に修正 |

### 10.2 AIが理解するTypeScript機能一覧

AIコーディングツール（Claude Code、Cursor、Copilot等）は以下の高度な機能を理解し、適切に生成できる:

| 機能 | 説明 | AI活用例 |
|------|------|---------|
| Generic Functions/Classes | 型パラメータ付き関数・クラス | 型安全なユーティリティ生成 |
| Conditional Types | 型の条件分岐 | 入力型に応じた出力型の推論 |
| Mapped Types | 型の変換・マッピング | Partial, Pick, Omit等の活用 |
| Template Literal Types | 文字列パターンの型 | API URL、イベント名の型安全化 |
| Utility Types | 組み込みの型変換 | 既存型からの派生型生成 |
| `infer` キーワード | 型推論の抽出 | 関数の戻り値型・引数型の取得 |
| Decorators | メタデータ付与 | フレームワーク統合 |

### 10.3 Discriminated Union（判別可能なUnion型）詳細

既存ガイド（セクション6.2）の拡張。

#### 網羅性チェック（Exhaustiveness Checking）

**`never`型による完全なケースカバー**:
```typescript
type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'square'; side: number }
  | { kind: 'triangle'; base: number; height: number };

function getArea(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'square':
      return shape.side ** 2;
    case 'triangle':
      return (shape.base * shape.height) / 2;
    default:
      // 新しいShapeを追加した場合、ここでコンパイルエラー
      const _exhaustiveCheck: never = shape;
      return _exhaustiveCheck;
  }
}
```

**Claude Codeへの効果**:
- 新しいvariantを追加すると、全switchで修正が必要なことをAIが認識
- テストケースの漏れを型レベルで検出

#### ビジネスロジックの型レベル表現

```typescript
// 状態遷移を型で表現
type Order =
  | { status: 'draft'; items: Item[] }
  | { status: 'submitted'; items: Item[]; submittedAt: Date }
  | { status: 'paid'; items: Item[]; submittedAt: Date; paidAt: Date }
  | { status: 'shipped'; items: Item[]; submittedAt: Date; paidAt: Date; trackingNumber: string };

// 不正な状態遷移をコンパイル時に防止
function submitOrder(order: Extract<Order, { status: 'draft' }>): Extract<Order, { status: 'submitted' }> {
  return {
    ...order,
    status: 'submitted',
    submittedAt: new Date(),
  };
}
```

### 10.4 Template Literal Types

**TypeScript 4.1で導入された文字列パターンの型**。

#### 基本構文

```typescript
type EventName = `on${Capitalize<'click' | 'focus' | 'blur'>}`;
// → "onClick" | "onFocus" | "onBlur"

type APIEndpoint = `/api/${string}/${number}`;
// → "/api/users/123" はOK、"/api/users/abc" はエラー
```

#### 動的な文字列ベースAPI

```typescript
// CSS-in-JSスタイルの型安全なプロパティ
type CSSUnit = 'px' | 'rem' | 'em' | '%';
type CSSValue = `${number}${CSSUnit}`;

const padding: CSSValue = '16px';  // OK
const margin: CSSValue = '2rem';   // OK
// const invalid: CSSValue = 'auto';  // エラー
```

#### Claude Codeへの効果と注意点

**効果**:
- API URL、イベント名、CSSプロパティ等の文字列値を型安全に
- 無効な文字列の生成を防止

**注意点**:
- 過度な使用はコンパイル時間に影響
- 再帰的なTemplate Literal Typesは特にIDEパフォーマンスに影響
- **推奨**: 明確な利点がある場合のみ使用

### 10.5 Conditional Types

**型の条件分岐を実現**。

#### 基本構文

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<'hello'>;  // true
type B = IsString<123>;      // false
```

#### `infer`キーワードによる型抽出

```typescript
// 関数の戻り値型を抽出
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// Promise内の型を抽出
type Awaited<T> = T extends Promise<infer U> ? Awaited<U> : T;

// 配列の要素型を抽出
type ElementType<T> = T extends (infer E)[] ? E : never;
```

#### 実用例: API Response Handler

```typescript
type APIResponse<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

// 成功時のデータ型を抽出
type ExtractData<R> = R extends { status: 'success'; data: infer D } ? D : never;

type UserResponse = APIResponse<{ id: string; name: string }>;
type UserData = ExtractData<UserResponse>;  // { id: string; name: string }
```

### 10.6 型設計のベストプラクティス（AI向け）

**AI（Claude Code等）がより高品質なコードを生成するための型設計**:

#### 1. 関数の戻り値型を明示する

```typescript
// ❌ 戻り値型を省略（AIは推測が必要）
function fetchUser(id: string) {
  return fetch(`/api/users/${id}`).then(r => r.json());
}

// ✅ 戻り値型を明示（AIは仕様を理解）
function fetchUser(id: string): Promise<User | null> {
  return fetch(`/api/users/${id}`).then(r => r.json());
}
```

#### 2. 無効な状態を型で禁止する

```typescript
// ❌ 曖昧な型（AIが無効な状態を生成しうる）
type FormState = {
  isLoading: boolean;
  error: string | null;
  data: User | null;
};

// ✅ 判別可能なUnion型（無効な状態は型エラー）
type FormState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: string };
```

#### 3. `noUncheckedIndexedAccess`を有効にする

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "noUncheckedIndexedAccess": true
  }
}

// 効果:
const arr = [1, 2, 3];
const value = arr[0];  // number | undefined（自動でundefined許容）

// AIが適切なnullチェックを生成するようになる
if (value !== undefined) {
  console.log(value.toFixed(2));
}
```

#### 4. AIに文脈を提供するコメント + 型

```typescript
/**
 * ユーザーの年齢を検証する
 * @param age - 0以上120以下の整数
 * @returns 検証結果とエラーメッセージ
 */
function validateAge(age: number): ValidationResult<number> {
  // AIはコメントと型の両方から仕様を理解
}
```

### 10.7 参考リソース（追加）

#### 高度な型パターン
- [TypeScript's rise in the AI era](https://github.blog/developer-skills/programming-languages-and-frameworks/typescripts-rise-in-the-ai-era-insights-from-lead-architect-anders-hejlsberg/)
- [Discriminated Unions - Total TypeScript](https://www.totaltypescript.com/discriminated-unions-are-a-devs-best-friend)
- [Template Literal Types - TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
- [Mastering TypeScript Advanced Patterns 2025](https://johal.in/mastering-typescript-advanced-patterns-2025-future-proof-your-code/)

#### AIとTypeScriptの相性
- [TypeScript vs JavaScript for AI Tools](https://www.builder.io/blog/typescript-vs-javascript)
- [Google Agent Development Kit for TypeScript](https://developers.googleblog.com/introducing-agent-development-kit-for-typescript-build-ai-agents-with-the-power-of-a-code-first-approach/)

---

## 12. テスト戦略とClaude Code

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 3回

### 12.1 TDD（テスト駆動開発）とClaude Code

**なぜTDDがAIコーディングと相性が良いか**:
> 「テスト駆動開発（TDD）はLLM支援とうまく機能する。人間が品質のゲートを修正し、設計を定義できるから」
> — [The New Stack](https://thenewstack.io/claude-code-and-the-art-of-test-driven-development/)

**Claude CodeでのTDDの利点**:
- テストが**明確な検証可能ターゲット**を提供
- AIが変更 → 評価 → 改善のサイクルを効果的に実行可能
- 安全なコードを生成し、LLMがすべてを理解している必要がない

### 12.2 TDD Guard（自動TDD強制ツール）

**概要**: Claude CodeにTDD原則を強制するツール

**機能**:
- テストをスキップしようとすると**ブロック**
- 過剰実装を検出して警告
- Red-Green-Refactorサイクルを強制

**対応フレームワーク**:
| 言語 | フレームワーク |
|------|---------------|
| JavaScript/TypeScript | Jest, Vitest, Storybook |
| Python | pytest |
| PHP | PHPUnit |
| Go | Go 1.24+ |
| Rust | cargo, cargo-nextest |

**参考**: [nizos/tdd-guard](https://github.com/nizos/tdd-guard)

### 12.3 高度なTDDワークフロー（Skills + Subagents）

**課題**: 単一コンテキストでは、テスト作成者の分析が実装者の思考に混入する

**解決策**: Subagentsによるコンテキスト分離
```
┌─────────────────────────────────────────────────┐
│  Phase 1: Test Writer Subagent                  │
│  - 要件を分析                                    │
│  - 失敗するテストを作成                          │
│  - 実装計画を見ない（重要！）                    │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│  Phase 2: Implementer Subagent                  │
│  - テストのみを見る                              │
│  - 最小限の実装で通過させる                      │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│  Phase 3: Refactorer Subagent                   │
│  - テスト維持しながらリファクタリング            │
└─────────────────────────────────────────────────┘
```

**セットアップコスト**: 約2時間
**効果**: 各機能リクエストが自動でRed-Green-Refactorサイクルを実行

### 12.4 Jest vs Vitest 選択ガイド

| 観点 | Jest | Vitest |
|------|------|--------|
| 速度 | 標準 | Jest比10-20倍高速（大規模コードベース） |
| ESM対応 | 要設定 | ネイティブ対応 |
| TypeScript | Jest 30でTS 5.4+必須 | 標準対応 |
| 推奨ケース | レガシー/企業向けReact、Node、React Native | Vite/ESMプロジェクト |

**推奨**: 既存プロジェクトのツールに合わせる。2つ目のランナーを導入しない。

### 12.5 Claude Codeでのテスト生成ベストプラクティス

#### よくある失敗パターン

| 問題 | 具体例 |
|------|--------|
| フレームワーク間違い | Jasmine構文でJestテストを書く |
| モック地獄 | 全依存関係にモックファイル作成 |
| 実装詳細テスト | フレームワーク動作の検証に終始 |

#### 成功パターン

```markdown
# CLAUDE.md に記載するテスト規約

## テスト生成ルール

1. **BDD命名規則**: GIVEN/WHEN/SHOULD形式
2. **1ファイル10テスト以下**: 保守性確保
3. **ユーザー行動フォーカス**: 実装詳細を避ける
4. **確立されたFakeパターン使用**: 過度なモック回避
5. **決定論的テスト**: sleepを避け、時刻・ネットワークをモック
```

#### 具体的な指示例

```
# ❌ 曖昧な指示
「このコンポーネントにテストを追加して」

# ✅ 具体的な指示
「Vitestと@vue/test-utilsを使ってUserProfileコンポーネントのテストを追加して。
カバレッジレポートで確認するので、エッジケースも含めて。」
```

### 12.6 テストカバレッジ改善の実績

**実例**: UIライブラリのカバレッジ改善
- **改善前**: 約60%
- **改善後**: 90%以上
- **コスト**: 約$1 USD（Claude Code使用）
- **対象**: 全欠落コンポーネント・composables

### 12.7 Property-Based Testing（プロパティベーステスト）

**従来のテスト vs Property-Based Testing**:
| 観点 | Example-Based Testing | Property-Based Testing |
|------|----------------------|------------------------|
| アプローチ | 特定の入出力ペアを検証 | **不変条件**（invariant）を検証 |
| 入力 | 開発者が選んだ固定値 | フレームワークがランダム生成 |
| バグ発見力 | カバーした範囲のみ | 予期しないエッジケースを発見 |

**TypeScript用ツール**: [fast-check](https://github.com/dubzzz/fast-check)

**実例**:
> 「Hypothesisは95%行カバレッジを持つ本番JSONパーサーでUnicode処理バグを発見した」
> — Property-based testingの価値を示す事例

**fast-checkの基本例**:
```typescript
import fc from 'fast-check';

// 「ソート後の配列は元の配列と同じ長さ」という不変条件
fc.assert(
  fc.property(fc.array(fc.integer()), (arr) => {
    const sorted = [...arr].sort((a, b) => a - b);
    return sorted.length === arr.length;
  })
);
```

### 12.8 テストピラミッド戦略

```
        ┌───────────────┐
        │   E2E Tests   │  ← 5-15件: 最重要フロー3-5件
        │   (Playwright)│
        └───────────────┘
      ┌───────────────────┐
      │ Integration Tests │  ← API/契約テスト
      │    (Supertest)    │
      └───────────────────┘
  ┌───────────────────────────┐
  │      Unit Tests           │  ← 多数: コアロジック
  │   (Vitest/Jest)           │
  └───────────────────────────┘
```

**Claude Codeへの指示**:
- 「ユニットテストを中心に、統合テストは最小限」
- 「E2Eは最重要フローのみ」

### 12.9 テスト関連Claude Code Skills/Plugins

| 名前 | 機能 |
|------|------|
| `/tdd-implement` (jerseycheese) | Red-Green-Refactor自動実行 |
| `Vitest Testing Standards` | Vitestベストプラクティス適用 |
| `javascript-testing-patterns` | Jest/Vitest/Testing Libraryパターン |
| Claude CodePro (Max Ritter) | TDD強制 + 品質Hooks |

### 12.10 参考リソース（テスト関連）

- [Claude Code and the Art of TDD](https://thenewstack.io/claude-code-and-the-art-of-test-driven-development/)
- [Forcing Claude Code to TDD](https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/)
- [TDD Guard](https://github.com/nizos/tdd-guard)
- [CLAUDE.md TDD Wiki](https://github.com/ruvnet/claude-flow/wiki/CLAUDE-MD-TDD)
- [Create Reliable Unit Tests with Claude Code](https://medium.com/ngconf/create-reliable-unit-tests-with-claude-code-9147d050d557)
- [fast-check (Property-Based Testing)](https://github.com/dubzzz/fast-check)

---

## 14. エラーハンドリングパターン

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 2回

### 14.1 なぜResult型が重要か

**従来のthrow/catchの問題点**:
- TypeScriptは例外のハンドリングを**強制しない**
- 未キャッチの例外がランタイムエラーに
- 関数シグネチャから例外の可能性が読み取れない

**Result型のメリット**:
- 成功/失敗を**型レベル**で表現
- TypeScriptの型システムが両ケースの処理を強制
- 関数シグネチャから失敗の可能性が明確

```typescript
// 従来のthrow（型から失敗が読み取れない）
function parseJSON(input: string): object {
  return JSON.parse(input);  // 失敗の可能性が型に表れない
}

// Result型（型から失敗が明確）
function parseJSON(input: string): Result<object, ParseError> {
  try {
    return ok(JSON.parse(input));
  } catch (e) {
    return err(new ParseError('Invalid JSON'));
  }
}
```

### 14.2 neverthrow（推奨入門ライブラリ）

**概要**: TypeScript向け型安全エラーハンドリングライブラリ

**特徴**:
- 軽量・ゼロ依存
- 段階的導入が容易
- ESLintプラグインあり

**基本使用法**:
```typescript
import { ok, err, Result } from 'neverthrow';

type User = { id: string; name: string };
type UserError = 'NOT_FOUND' | 'UNAUTHORIZED';

function getUser(id: string): Result<User, UserError> {
  if (!id) return err('NOT_FOUND');
  return ok({ id, name: 'Test User' });
}

// 使用側は両ケースの処理が必要
const result = getUser('123');
if (result.isOk()) {
  console.log(result.value.name);  // User型としてアクセス
} else {
  console.error(result.error);     // UserError型としてアクセス
}
```

**非同期対応（ResultAsync）**:
```typescript
import { ResultAsync } from 'neverthrow';

function fetchUser(id: string): ResultAsync<User, FetchError> {
  return ResultAsync.fromPromise(
    fetch(`/api/users/${id}`).then(r => r.json()),
    () => new FetchError('Network error')
  );
}
```

**Claude Codeでの効果**:
- AIが生成するコードで**必ずエラーケースが処理される**
- 型エラーによる自己修正が効果的に機能

### 14.3 Effect-TS（高度なユースケース向け）

**概要**: 本格的な関数型エフェクトシステム

**特徴**:
- Rust風のエラーハンドリング
- 並行処理、リトライ、ストリームを統合
- 「Effect<Success, Error, Requirements>」の3パラメータ型

**基本構文**:
```typescript
import { Effect } from 'effect';

const program = Effect.gen(function* () {
  const user = yield* fetchUser('123');
  const orders = yield* fetchOrders(user.id);
  return { user, orders };
});

// エラー型が自動で集約される
// Effect<{ user: User, orders: Order[] }, UserError | OrderError, never>
```

**トレードオフ**:
| 観点 | neverthrow | Effect-TS |
|------|-----------|-----------|
| 学習コスト | 低 | 高 |
| 導入ハードル | 低（段階的導入可） | 高（パラダイムシフト必要） |
| 機能 | Result型のみ | 並行処理、リソース管理、DI含む |
| 推奨 | 入門〜中規模 | 大規模・複雑なシステム |

**Effect-TS AI支援の課題**:
- LSPが利用できない環境でのAI支援に課題
- CLI診断ツールの開発が要望されている（[Issue #5180](https://github.com/Effect-TS/effect/issues/5180)）

### 14.4 選択ガイドライン

```
┌──────────────────────────────────────────────────────────┐
│  チームが関数型プログラミングに不慣れ？                    │
│                                                          │
│  YES → neverthrow（入門として最適）                       │
│  NO  → Effect-TS検討可能                                 │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│  段階的導入が必要？                                       │
│                                                          │
│  YES → neverthrow（混在しやすい）                         │
│  NO  → Effect-TS（全面導入時に真価発揮）                  │
└──────────────────────────────────────────────────────────┘
```

### 14.5 ESLint統合

**neverthrow + ESLint**:
```bash
npm install eslint-plugin-neverthrow
```

```json
// .eslintrc.json
{
  "plugins": ["neverthrow"],
  "rules": {
    "neverthrow/must-use-result": "error"
  }
}
```

**効果**:
- Result型の未処理を検出
- throw禁止の強制
- AI生成コードの品質ゲートとして機能

### 14.6 CLAUDE.mdへの記載例

```markdown
## エラーハンドリング規約

- **throwは最終手段**: 通常はResult型を使用
- **ライブラリ**: neverthrowを使用
- **エラー型**: 文字列リテラルのunionで定義

### 例
\`\`\`typescript
type ApiError = 'NOT_FOUND' | 'UNAUTHORIZED' | 'NETWORK_ERROR';

function fetchData(id: string): ResultAsync<Data, ApiError> {
  // ...
}
\`\`\`

### 禁止事項
- catchブロックで何もしない
- anyでエラーを握りつぶす
- Result型を.unwrap()で即時展開（エラー無視と同等）
```

### 14.7 参考リソース（エラーハンドリング）

- [neverthrow GitHub](https://github.com/supermacro/neverthrow)
- [Error Handling with Result Types](https://typescript.tv/best-practices/error-handling-with-result-types/)
- [Practically Safe TypeScript Using Neverthrow](https://www.solberg.is/neverthrow)
- [Effect-TS公式サイト](https://effect.website/)
- [Effect-TS Documentation](https://effect.website/docs/getting-started/creating-effects/)
- [TypeScript Error Handling Comparison](https://devalade.me/blog/error-handling-in-typescript-neverthrow-try-catch-and-alternative-like-effec-ts.mdx)

---

## 16. 実プロジェクトワークフロー & CI/CD統合

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 2回

### 16.1 Claude Code GitHub Actions

**概要**: 2025年9月リリースのGitHub連携機能

**主な機能**:
| 機能 | 説明 |
|------|------|
| インタラクティブアシスタント | @claude メンションで起動 |
| コードレビュー | PR変更の分析・改善提案 |
| 自動実装 | Issue/PRからの機能実装 |
| バグ修正 | 問題の特定と修正 |

**セットアップ**:
```bash
# Claude Code内で実行
/install-github-app
```

### 16.2 GitHub Actions ワークフロー例

**基本設定（TypeScriptプロジェクト）**:
```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]
  issue_comment:
    types: [created]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@<commit-sha>  # SHA固定推奨
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          model: claude-sonnet-4-5-20251101
```

**TypeScript品質チェック連携**:
```yaml
jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Type check
        run: npx tsc --noEmit

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm test

      - name: Claude Review
        uses: anthropics/claude-code-action@<commit-sha>
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 16.3 セキュリティベストプラクティス

| 推奨 | 理由 |
|------|------|
| **SHA固定** | サプライチェーン攻撃防止 |
| **最小権限** | `contents: write`は必要時のみ |
| **シークレット管理** | APIキーをハードコードしない |
| **ブランチ保護** | mainへの直接pushを防止 |

### 16.4 Plan-Before-Execute ワークフロー

**3段階アプローチ**:

```
Phase 1: Research & Plan
┌─────────────────────────────────────────────────┐
│ 「関連ファイルを読んで実装計画を立てて。        │
│   まだコードは書かないで。」                    │
│                                                 │
│ → Subagent活用推奨（複雑な問題の場合）         │
└─────────────────────────────────────────────────┘
                       ↓
Phase 2: Approval
┌─────────────────────────────────────────────────┐
│ 計画をレビュー・承認                            │
│ → 必要に応じて修正指示                          │
└─────────────────────────────────────────────────┘
                       ↓
Phase 3: Implementation
┌─────────────────────────────────────────────────┐
│ 「承認した計画に沿って実装して」                │
│ → TDDアプローチ推奨                             │
└─────────────────────────────────────────────────┘
```

**実践例**:
```
1. Research API best practices → 結果をRESEARCH.mdに保存
2. Design error handling strategy → 承認待ち
3. Write TypeScript interfaces → 型レビュー
4. Implement core logic → TDDアプローチ
5. Add retry logic and logging → 本番強化
```

### 16.5 Git Worktrees（並列セッション）

**課題**: 複数のClaude Codeセッションを同時実行したい

**解決策**: Git Worktrees
```bash
# ワークツリー作成
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b

# それぞれのディレクトリでClaude Codeを起動
cd ../project-feature-a && claude
cd ../project-feature-b && claude

# 作業完了後にクリーンアップ
git worktree remove ../project-feature-a
```

**メリット**:
- 各ワークツリーが独立したファイル状態
- Claudeインスタンス間の干渉なし

### 16.6 Multi-Agent Pipeline

**3エージェント構成**:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Architect  │ →  │   Builder   │ →  │     QA      │
│             │    │             │    │             │
│ 設計レビュー │    │ 実装        │    │ テスト・     │
│ パターン提案 │    │ 承認計画実行 │    │ コードレビュー│
└─────────────┘    └─────────────┘    └─────────────┘
```

**参考実装**: [claude-code-workflows](https://github.com/shinpr/claude-code-workflows)

### 16.7 Spec-Driven Development

**新機能ワークフロー**:
```
Requirements → Design → Tasks → Implementation
```

**バグ修正ワークフロー**:
```
Report → Analyze → Fix → Verify
```

**参考実装**: [claude-code-spec-workflow](https://github.com/Pimzino/claude-code-spec-workflow)

### 16.8 コンテキスト管理

**課題**: 200Kトークン制限に達すると自動要約 → 重要な詳細を喪失

**対策**:
```bash
# タスク完了ごとにコンテキストをクリア
/clear

# または新しいセッションを開始
```

**ベストプラクティス**:
- タスクを小さく分割
- 完了したらすぐに`/clear`
- 長時間セッションを避ける

### 16.9 複数CLAUDE.mdの構成例

```
project/
├── CLAUDE.md                   # プロジェクト全体のルール
├── frontend/
│   └── CLAUDE.md               # React/TypeScript固有
│       - コンポーネント規約
│       - 状態管理パターン
│       - テスト戦略
├── backend/
│   └── CLAUDE.md               # Node.js/Express固有
│       - APIエンドポイント規約
│       - エラーハンドリング
│       - データベースアクセス
└── infrastructure/
    └── CLAUDE.md               # Terraform/CI固有
```

### 16.10 MCP統合

**`.mcp.json`設定例**:
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-puppeteer"]
    },
    "sentry": {
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server"],
      "env": {
        "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}"
      }
    }
  }
}
```

**効果**: リポジトリをクローンした全員が同じMCPサーバーを利用可能

### 16.11 参考リソース（ワークフロー）

#### 公式
- [Claude Code GitHub Actions Docs](https://code.claude.com/docs/en/github-actions)
- [Common Workflows](https://code.claude.com/docs/en/common-workflows)
- [Claude Code Best Practices (Anthropic)](https://www.anthropic.com/engineering/claude-code-best-practices)

#### コミュニティ
- [claude-code-action](https://github.com/anthropics/claude-code-action)
- [claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase)
- [claude-code-workflows](https://github.com/shinpr/claude-code-workflows)
- [claude-code-spec-workflow](https://github.com/Pimzino/claude-code-spec-workflow)
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)

---

## 18. カスタムコマンド & Skills詳細

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 2回

### 18.1 コマンドとSkillsの関係

**歴史的経緯**:
- カスタムSlash Commands（`.claude/commands/`）が先
- Skills（`.claude/skills/`）が後から追加
- 両方で同じ`/command-name`が作成可能
- 既存の`.claude/commands/`は引き続き動作

**違い**:
| 観点 | Slash Commands | Skills |
|------|---------------|--------|
| 場所 | `.claude/commands/command.md` | `.claude/skills/command/SKILL.md` |
| 構造 | 単一Markdownファイル | ディレクトリ（スクリプト、テンプレート含む） |
| 拡張性 | 低 | 高（サブフォルダ、ヘルパースクリプト） |

### 18.2 配置場所

**プロジェクトコマンド**（チーム共有可能）:
```
project/
└── .claude/
    └── commands/
        ├── review.md       → /review
        ├── new-component.md → /new-component
        └── deploy.md       → /deploy
```

**パーソナルコマンド**（全プロジェクトで利用）:
```
~/.claude/
└── commands/
    ├── my-snippets.md
    └── journal.md
```

### 18.3 引数の使い方

**$ARGUMENTS**: コマンド名の後の全テキストを取得
```markdown
<!-- .claude/commands/fix-issue.md -->
GitHub Issue #$ARGUMENTS を修正してください。
コーディング規約に従い、テストも追加すること。
```

**使用例**:
```
/fix-issue 123
→ 「GitHub Issue #123 を修正してください。...」
```

**$1, $2**: 位置引数（スペース区切り）
```markdown
<!-- .claude/commands/create-component.md -->
コンポーネント名: $1
ディレクトリ: $2
```

**使用例**:
```
/create-component UserAvatar src/components
→ コンポーネント名: UserAvatar
→ ディレクトリ: src/components
```

### 18.4 Frontmatter（メタデータ）

```yaml
---
allowed-tools: Read, Grep, Glob, Edit
description: セキュリティ脆弱性スキャン
model: claude-sonnet-4-5-20250929
argument-hint: [file-pattern]
---
```

**主要フィールド**:
| フィールド | 説明 |
|-----------|------|
| `allowed-tools` | 使用可能なツール制限 |
| `description` | コマンドの説明（`/`入力時に表示） |
| `model` | 使用するモデル指定 |
| `argument-hint` | 引数のヒント表示 |

### 18.5 動的コンテンツ

**Bashコマンド埋め込み（!）**:
```markdown
---
allowed-tools: Bash(git status:*), Bash(git diff:*)
---
現在のGit状態:
!git status

変更内容:
!git diff HEAD
```

**ファイル参照（@）**:
```markdown
以下の型定義に基づいてAPIを実装してください:
@src/types/api.ts
```

### 18.6 TypeScriptプロジェクト向けコマンド例

#### 1. 新規コンポーネント作成

```markdown
<!-- .claude/commands/new-component.md -->
---
allowed-tools: Read, Write, Glob
description: React + TypeScriptコンポーネントを作成
argument-hint: <ComponentName>
---
# 新しいReactコンポーネントを作成

## 入力
- コンポーネント名: $ARGUMENTS

## 出力ファイル
1. `src/components/$ARGUMENTS/$ARGUMENTS.tsx` - コンポーネント本体
2. `src/components/$ARGUMENTS/$ARGUMENTS.test.tsx` - テスト
3. `src/components/$ARGUMENTS/index.ts` - エクスポート

## 規約
- 関数コンポーネント使用
- Props型を明示的に定義（`interface ${ARGUMENTS}Props`）
- displayNameを設定
- React Testing Library + Vitestでテスト

## 参考（既存パターン）
@src/components/Button/Button.tsx
```

#### 2. 型安全APIエンドポイント

```markdown
<!-- .claude/commands/new-api.md -->
---
allowed-tools: Read, Write, Grep
description: tRPC互換のAPIエンドポイントを作成
argument-hint: <endpoint-name>
---
# 新しいAPIエンドポイントを作成

## エンドポイント名: $ARGUMENTS

## 出力
1. `src/api/$ARGUMENTS.ts` - エンドポイント実装
2. `src/types/$ARGUMENTS.ts` - Request/Response型
3. `tests/api/$ARGUMENTS.test.ts` - 統合テスト

## 必須要件
- Zod schemaでバリデーション
- Result型でエラーハンドリング
- OpenAPI互換のドキュメントコメント

## 参考
@src/api/users.ts
@src/types/users.ts
```

#### 3. TypeScript型チェックレビュー

```markdown
<!-- .claude/commands/type-review.md -->
---
allowed-tools: Bash(npx tsc:*), Read, Grep
description: TypeScript型エラーを分析・修正提案
---
# TypeScript型チェックレビュー

## Step 1: 型エラー取得
!npx tsc --noEmit 2>&1 || true

## Step 2: 分析
上記のエラーを分析し、以下を報告:
1. エラー種別ごとの件数
2. 最も影響が大きいエラー（依存関係が多い順）
3. 修正優先度の提案

## Step 3: 修正提案
各エラーについて具体的な修正コードを提示してください。
```

### 18.7 Skills構造（高度な用途）

```
.claude/skills/
└── api-generator/
    ├── SKILL.md              # エントリポイント
    ├── templates/
    │   ├── endpoint.ts.tmpl  # テンプレート
    │   └── test.ts.tmpl
    ├── scripts/
    │   └── validate.sh       # 検証スクリプト
    └── examples/
        └── sample.ts         # サンプルコード
```

**SKILL.md例**:
```markdown
---
description: 型安全なAPIエンドポイント生成
argument-hint: <endpoint-name>
---
# API Generator

$ARGUMENTSという名前のAPIエンドポイントを生成します。

## テンプレート
@templates/endpoint.ts.tmpl

## 検証
生成後、以下を実行:
!./scripts/validate.sh $ARGUMENTS
```

### 18.8 コミュニティリソース

| リソース | 内容 |
|---------|------|
| [wshobson/commands](https://github.com/wshobson/commands) | 本番向けSlash Commands集 |
| [Claude-Command-Suite](https://github.com/qdhenry/Claude-Command-Suite) | 148+ コマンド、54 AIエージェント |
| [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Skills, Hooks, Commands一覧 |
| [claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) | 包括的な設定例 |

### 18.9 ベストプラクティス

1. **具体的に**: 一行プロンプトは避け、詳細な指示を記載
2. **既存パターン参照**: `@`でプロジェクト内の実例を埋め込む
3. **ツール制限**: `allowed-tools`で必要最小限のツールのみ許可
4. **チーム共有**: `.claude/commands/`をGit管理
5. **引数ヒント**: `argument-hint`で使い方を明示

### 18.10 参考リソース（コマンド）

- [Slash Commands - Claude Code Docs](https://code.claude.com/docs/en/slash-commands)
- [Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Inside Claude Code Skills](https://mikhail.io/2025/10/claude-code-skills/)
- [Claude Code Custom Commands Guide](https://www.aiengineering.report/p/claude-code-custom-commands-3-practical)
- [Custom Slash Commands Tutorial](https://en.bioerrorlog.work/entry/claude-code-custom-slash-command)

---

## 20. Hooks詳細設定

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 2回

### 20.1 Hookイベント一覧

| イベント | タイミング | 主な用途 |
|---------|-----------|---------|
| `PreToolUse` | ツール実行**前** | ブロック、入力修正 |
| `PostToolUse` | ツール実行**後** | フォーマット、検証 |
| `PostToolUseFailure` | ツール失敗後 | エラーハンドリング |
| `PermissionRequest` | 許可ダイアログ表示時 | 自動許可/拒否 |
| `Stop` | ターン終了時 | 品質ゲート |
| `SessionStart` | セッション開始時 | 初期化 |
| `SessionEnd` | セッション終了時 | クリーンアップ |
| `SubagentStart/Stop` | サブエージェント開始/終了 | サブエージェント監視 |
| `PreCompact` | コンテキスト圧縮前 | 保存処理 |

### 20.2 終了コードの意味

| コード | 意味 | 動作 |
|--------|------|------|
| `0` | 成功 | 処理続行 |
| `2` | ブロック（PreToolUseのみ） | ツール実行を停止、stderrがClaudeに伝達 |
| その他 | エラー | ユーザーに表示、処理は続行 |

### 20.3 TypeScriptプロジェクト向け設定例

#### 基本設定（`.claude/settings.json`）

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/block-dangerous.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/format-and-check.sh"
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/quality-gate.sh"
        }]
      }
    ]
  }
}
```

### 20.4 TypeScript自動フォーマット + 型チェック

**`.claude/hooks/format-and-check.sh`**:
```bash
#!/bin/bash

# 標準入力からツール情報を取得
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# TypeScript/TSXファイルのみ処理
if [[ "$FILE_PATH" =~ \.(ts|tsx)$ ]]; then
  # Prettier実行
  npx prettier --write "$FILE_PATH" 2>/dev/null

  # ESLint --fix実行
  npx eslint --fix "$FILE_PATH" 2>/dev/null

  # 型チェック（ファイル単体ではなくプロジェクト全体）
  npx tsc --noEmit 2>&1 | head -20
fi
```

### 20.5 品質ゲート（Stopイベント）

**`.claude/hooks/quality-gate.sh`**:
```bash
#!/bin/bash

echo "=== Quality Gate Check ===" >&2

# 1. 型チェック
echo "Running type check..." >&2
if ! npx tsc --noEmit 2>&1; then
  echo "❌ Type errors detected" >&2
  exit 2  # ブロック
fi
echo "✓ Type check passed" >&2

# 2. Lint
echo "Running lint..." >&2
if ! npx eslint src/ --max-warnings 0 2>&1; then
  echo "❌ Lint errors detected" >&2
  exit 2  # ブロック
fi
echo "✓ Lint passed" >&2

# 3. テスト（変更されたファイルのみ）
echo "Running related tests..." >&2
npx vitest related --run 2>&1 || true

echo "=== Quality Gate Passed ===" >&2
exit 0
```

### 20.6 危険なコマンドのブロック

**`.claude/hooks/block-dangerous.sh`**:
```bash
#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 危険なパターン
DANGEROUS_PATTERNS=(
  "rm -rf"
  "git reset --hard"
  "git clean -fd"
  "DROP TABLE"
  "DELETE FROM .* WHERE 1"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "❌ 危険なコマンドをブロックしました: $pattern" >&2
    echo "このコマンドは禁止されています。" >&2
    exit 2
  fi
done

exit 0
```

### 20.7 mainブランチへの編集ブロック

```bash
#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  echo "❌ main/masterブランチへの直接編集は禁止されています" >&2
  echo "作業ブランチを作成してください: git checkout -b feature/xxx" >&2
  exit 2
fi

exit 0
```

### 20.8 入力修正（v2.0.10+）

**PreToolUseでの入力変更**:
```bash
#!/bin/bash

INPUT=$(cat)

# dry-runフラグを自動付与
MODIFIED=$(echo "$INPUT" | jq '.tool_input.command += " --dry-run"')

# 変更した入力を出力
echo "$MODIFIED"
```

### 20.9 TypeScript型付きHooks（claude-hooks）

**インストール**:
```bash
npm install claude-hooks
```

**`.claude/hooks/index.ts`**:
```typescript
import { defineHook, PreToolUseInput, PostToolUseInput } from 'claude-hooks';

export const preToolUse = defineHook<PreToolUseInput>((input) => {
  if (input.tool_name === 'Bash') {
    const command = input.tool_input?.command as string;
    if (command.includes('rm -rf')) {
      return { blocked: true, reason: '危険なコマンドです' };
    }
  }
  return { blocked: false };
});

export const postToolUse = defineHook<PostToolUseInput>(async (input) => {
  if (input.tool_name === 'Write') {
    const filePath = input.tool_input?.file_path as string;
    if (filePath.endsWith('.ts')) {
      // Prettier実行
      await $`npx prettier --write ${filePath}`;
    }
  }
});
```

### 20.10 テスト変更時の自動テスト実行

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "FILE=$(cat | jq -r '.tool_input.file_path'); if [[ \"$FILE\" == *.test.ts ]]; then npx vitest run \"$FILE\"; fi"
        }]
      }
    ]
  }
}
```

### 20.11 Hooks設計のベストプラクティス

| 原則 | 説明 |
|------|------|
| **高速化** | Hooksは毎回実行されるため、1-2秒以内に完了すべき |
| **PreToolUseはポリシー用** | ブロック・入力修正に使用 |
| **PostToolUseはフィードバック用** | フォーマット・検証に使用 |
| **Stopは品質ゲート用** | ターン終了時の総合チェック |
| **matcherで絞り込み** | 不要な実行を避ける |
| **exit 2でブロック** | stderrでClaudeに理由を伝達 |

### 20.12 参考リソース（Hooks）

- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [johnlindquist/claude-hooks](https://github.com/johnlindquist/claude-hooks)
- [Hooks for Automated Quality Checks](https://www.letanure.dev/blog/2025-08-06--claude-code-part-8-hooks-automated-quality-checks)
- [End-of-Turn Quality Gates](https://jpcaparas.medium.com/claude-code-use-hooks-to-enforce-end-of-turn-quality-gates-5bed84e89a0d)
- [Claude Code Showcase (Hooks例)](https://github.com/ChrisWiles/claude-code-showcase)

---

## 22. Monorepo設定（Turborepo / Nx）

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 2回

### 22.1 Turborepo vs Nx選択ガイド

| 観点 | Turborepo | Nx |
|------|-----------|-----|
| 複雑さ | シンプル | 高機能 |
| 速度 | 高速（キャッシュ最適化） | 高速 |
| カスタマイズ | 限定的 | 高度に柔軟 |
| プラグイン | 少なめ | 豊富なエコシステム |
| 推奨ケース | 中小規模、シンプルな構成 | 大規模、企業向け |

### 22.2 推奨ディレクトリ構造（Turborepo）

```
my-monorepo/
├── apps/
│   ├── web/                 # Next.js アプリ
│   │   ├── CLAUDE.md        # フロントエンド固有ルール
│   │   └── ...
│   ├── api/                 # Express/Fastify API
│   │   ├── CLAUDE.md        # バックエンド固有ルール
│   │   └── ...
│   └── mobile/              # React Native
├── packages/
│   ├── ui/                  # 共有UIコンポーネント
│   ├── types/               # ★ 共有TypeScript型定義
│   ├── config-eslint/       # 共有ESLint設定
│   ├── config-typescript/   # 共有tsconfig
│   └── utils/               # 共有ユーティリティ
├── CLAUDE.md                # ★ ルートCLAUDE.md（全体ルール）
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

### 22.3 共有TypeScript設定

**`packages/config-typescript/base.json`**:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "target": "ES2024",
    "lib": ["ES2024"],
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

**`apps/web/tsconfig.json`（継承）**:
```json
{
  "extends": "@my-monorepo/config-typescript/nextjs.json",
  "compilerOptions": {
    "rootDir": ".",
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### 22.4 共有型定義パッケージ

**`packages/types/index.ts`**:
```typescript
// ドメインモデル
export type UserId = string & { readonly brand: 'UserId' };
export type OrderId = string & { readonly brand: 'OrderId' };

export interface User {
  id: UserId;
  name: string;
  email: string;
}

export interface Order {
  id: OrderId;
  userId: UserId;
  items: OrderItem[];
  status: OrderStatus;
}

export type OrderStatus = 'draft' | 'submitted' | 'paid' | 'shipped';

// API型
export interface ApiResponse<T> {
  success: true;
  data: T;
} | {
  success: false;
  error: string;
}
```

**使用側（apps/web）**:
```typescript
import { User, ApiResponse } from '@my-monorepo/types';

async function getUser(id: string): Promise<ApiResponse<User>> {
  // 型が共有されているため、フロントとバックで一貫
}
```

### 22.5 CLAUDE.md階層設計

**`CLAUDE.md`（ルート）**:
```markdown
# Monorepo共通ルール

## 概要
pnpm + Turborepo のモノレポ。TypeScript strict mode必須。

## コマンド
- `pnpm install` - 依存関係インストール
- `pnpm dev` - 全アプリ開発サーバー起動
- `pnpm build` - 全アプリビルド
- `pnpm test` - 全テスト実行
- `pnpm lint` - 全Lint実行
- `pnpm check-types` - 全型チェック

## パッケージ構成
- `apps/web` - Next.jsフロントエンド
- `apps/api` - Express APIサーバー
- `packages/types` - 共有型定義（★ 新しい型はここに）
- `packages/ui` - 共有UIコンポーネント

## 開発ルール
1. 新しい型は必ず `packages/types` に追加
2. UIコンポーネントは `packages/ui` に追加
3. アプリ固有のコードのみ `apps/` に配置
```

**`apps/web/CLAUDE.md`（サブディレクトリ）**:
```markdown
# Frontend (Next.js)

## 固有コマンド
- `pnpm --filter web dev` - このアプリのみ起動
- `pnpm --filter web test` - このアプリのみテスト

## ディレクトリ
- `src/components/` - ページ固有コンポーネント
- `src/pages/` - Next.jsページ
- `src/hooks/` - カスタムフック

## 注意
- 共有コンポーネントは `@my-monorepo/ui` から import
- 共有型は `@my-monorepo/types` から import
```

### 22.6 Nx + AI統合

**Nx MCP Server**:
```bash
# Nxワークスペースで自動生成される
# CLAUDE.md と AGENTS.md が含まれる
npx create-nx-workspace@latest
```

**Nx固有の利点**:
- プロジェクトグラフの可視化
- 依存関係の自動検出
- 影響を受けるプロジェクトのみテスト/ビルド

### 22.7 pnpm-workspace.yaml

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### 22.8 turbo.json（タスク定義）

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    },
    "lint": {
      "outputs": []
    },
    "check-types": {
      "dependsOn": ["^check-types"],
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

### 22.9 Claude CodeでのMonorepo操作

**フィルタリングコマンド**:
```bash
# 特定パッケージのみ操作
pnpm --filter web dev
pnpm --filter @my-monorepo/ui build

# 変更されたパッケージのみテスト
pnpm --filter ...[HEAD~1] test
```

**Claude Codeへの指示例**:
```
「packages/typesにUserPreferences型を追加して、
apps/webとapps/apiの両方で使用できるようにして」
```

### 22.10 CI/CD統合

**`.github/workflows/ci.yml`**:
```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - run: pnpm install

      # Turborepoのリモートキャッシュ
      - run: pnpm build
        env:
          TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
          TURBO_TEAM: ${{ vars.TURBO_TEAM }}

      - run: pnpm check-types
      - run: pnpm lint
      - run: pnpm test
```

### 22.11 参考リソース（Monorepo）

- [Turborepo TypeScript Guide](https://turborepo.dev/docs/guides/tools/typescript)
- [Nx AI Setup Guide](https://nx.dev/docs/getting-started/ai-setup)
- [JavaScript Monorepos Complete Guide 2025](https://jeffbruchado.com.br/en/blog/javascript-monorepos-turborepo-nx-2025)
- [ai-monorepo-scaffold](https://github.com/maccman/ai-monorepo-scaffold) - Turbo + tRPC + Claude設定例
- [CodeSyncer](https://github.com/bitjaru/codesyncer) - Monorepo自動検出

---

## 24. API設計（tRPC / GraphQL）

> **追記日**: 2026-01-22
> **調査回数**: WebSearch 2回

### 24.1 tRPC vs GraphQL選択ガイド

| 観点 | tRPC | GraphQL |
|------|------|---------|
| コード生成 | **不要** | 必要（codegen） |
| 型安全性 | エンドツーエンド | スキーマベース |
| 学習コスト | 低（TypeScriptのみ） | 中（SDL + クエリ言語） |
| 柔軟性 | 低（TypeScript限定） | 高（多言語対応） |
| 推奨ケース | TypeScript Full-Stack | 多言語/公開API |

### 24.2 tRPC（推奨）

**概要**: TypeScriptコードがそのままAPIスキーマになる

**特徴**:
- コード生成なし、ランタイムブロートなし
- バックエンドがコンパイルすれば、フロントエンドは動作保証
- TypeScript限定（クライアント・サーバー両方）

**基本構文**:
```typescript
// server/routers/user.ts
import { router, publicProcedure } from '../trpc';
import { z } from 'zod';

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      // 戻り値の型が自動推論される
      return await prisma.user.findUnique({ where: { id: input.id } });
    }),

  create: publicProcedure
    .input(z.object({
      name: z.string().min(1),
      email: z.string().email(),
    }))
    .mutation(async ({ input }) => {
      return await prisma.user.create({ data: input });
    }),
});
```

**クライアント側（自動型推論）**:
```typescript
// client/pages/user.tsx
import { trpc } from '../utils/trpc';

function UserPage() {
  // getByIdの戻り値型が自動で推論される
  const { data: user } = trpc.user.getById.useQuery({ id: '123' });

  // user は User | null | undefined として型付け
  return <div>{user?.name}</div>;
}
```

**Claude Codeへの効果**:
- 型がコードから直接推論されるため、AI生成コードが即座に型チェック
- バックエンド変更時、フロントエンドの型エラーとして即検出
- 「バックエンドがコンパイルすれば、フロントエンドは動作保証」

### 24.3 T3 Stack（2025年推奨スタック）

| コンポーネント | 役割 |
|--------------|------|
| Next.js | Full-stackフレームワーク |
| TypeScript | 型安全性 |
| **tRPC** | エンドツーエンド型安全API |
| Prisma | ORM（自動型生成） |
| Tailwind CSS | スタイリング |

**採用実績**: Cal.com、Ping.gg、YCスタートアップ多数

### 24.4 GraphQL + Code Generator

**GraphQL Code Generator**:
```bash
npm install -D @graphql-codegen/cli @graphql-codegen/typescript @graphql-codegen/typescript-resolvers
```

**`codegen.ts`設定**:
```typescript
import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
  schema: './src/schema.graphql',
  documents: ['src/**/*.tsx'],
  generates: {
    './src/generated/types.ts': {
      plugins: [
        'typescript',
        'typescript-operations',
        'typescript-react-apollo',
      ],
    },
    './src/generated/resolvers.ts': {
      plugins: ['typescript', 'typescript-resolvers'],
    },
  },
};

export default config;
```

**重要なポイント**:
> スキーマから直接型生成するのではなく、**オペレーション（クエリ/ミューテーション）から型生成**すべき

```graphql
# これに対して型が生成される
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    email
  }
}
```

### 24.5 Zod（ランタイムバリデーション）

**tRPCとの統合**:
```typescript
import { z } from 'zod';

// スキーマ定義（型とバリデーションを同時に）
const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().min(0).max(120).optional(),
});

// 型を抽出
type CreateUserInput = z.infer<typeof CreateUserSchema>;
// → { name: string; email: string; age?: number }

// tRPCプロシージャで使用
publicProcedure
  .input(CreateUserSchema)  // バリデーション + 型推論
  .mutation(({ input }) => {
    // inputは CreateUserInput として型付け
  });
```

### 24.6 CLAUDE.mdへの記載例（API）

```markdown
## API規約

### tRPC
- すべてのプロシージャにZodスキーマを定義
- mutationには必ずエラーハンドリング
- 複雑なクエリはサブルーターに分割

### 命名規則
- Query: `getById`, `list`, `search`
- Mutation: `create`, `update`, `delete`
- Subscription: `onUpdate`, `onDelete`

### エラーハンドリング
\`\`\`typescript
import { TRPCError } from '@trpc/server';

throw new TRPCError({
  code: 'NOT_FOUND',
  message: 'User not found',
});
\`\`\`

### 認証
- `protectedProcedure` を使用（認証必須）
- `publicProcedure` は認証不要
```

### 24.7 Claude Codeでの活用

**Claude Code Subagent（TypeScript Pro）の実績**:
> 「100%型カバレッジ、tRPCによるエンドツーエンド型安全性、最適化されたバンドル（40%サイズ削減）を達成。プロジェクト参照によりビルド時間60%改善」

**効果的な指示例**:
```
「userRouterに新しいプロシージャ`updateProfile`を追加して。
Zodスキーマで入力バリデーション、
エラーハンドリング、
フロントエンドのuseUpdateProfile hookまで一貫して実装して」
```

### 24.8 OpenAPI（REST API）との比較

| 観点 | tRPC | OpenAPI + TS |
|------|------|-------------|
| スキーマ定義 | TypeScriptコード | YAML/JSON |
| コード生成 | 不要 | 必要（openapi-generator等） |
| 同期コスト | ゼロ | 手動/CI統合必要 |
| 外部公開 | 困難 | 容易 |

**OpenAPIが必要なケース**:
- 外部開発者向けAPI
- 多言語クライアント対応
- ドキュメント自動生成

### 24.9 参考リソース（API設計）

- [tRPC公式](https://trpc.io/)
- [tRPC and T3 Stack 2025 Guide](https://www.rajeshdhiman.in/blog/trpc-t3-stack-guide-2025)
- [GraphQL Code Generator](https://the-guild.dev/graphql/codegen)
- [TypeScript GraphQL Types Tutorial](https://www.apollographql.com/tutorials/intro-typescript/09-codegen)
- [Zod](https://zod.dev/)

---

## 25. まとめ

### TypeScript + Claude Codeの主要な利点

1. **型が曖昧性を排除** → AI提案の精度が劇的に向上
2. **LSP統合で型チェックが自動化** → 50msでコード理解
3. **型定義がAIに文脈を提供** → より正確なコード生成
4. **テスト自動生成が型から推導可能** → カバレッジ向上
5. **改ざん防止が型レベルで可能** → コード品質維持
6. **TDD強制ツール（TDD Guard）** → 品質担保の自動化
7. **Result型でエラーハンドリング強制** → 堅牢なコード生成
8. **tRPCでエンドツーエンド型安全** → フロント・バック一貫性

### 実装推奨ステップ（更新版）

| Phase | ステップ | 詳細 |
|-------|---------|------|
| **Phase 1** | 基盤構築 | `strict: true`、tsconfig最適化 |
| **Phase 2** | 型パターン | Branded Types、Result型、Discriminated Union |
| **Phase 3** | 開発環境 | CLAUDE.md、カスタムコマンド、Hooks |
| **Phase 4** | 品質自動化 | TDD Guard、品質ゲートHook、CI/CD統合 |
| **Phase 5** | アーキテクチャ | tRPC、Monorepo（必要に応じて） |

### 調査で得られた重要な知見

1. **GitHub Octoverse 2025**: TypeScriptがPython/JSを抜いて最も人気のある言語に（AIとの相性が主要因）
2. **Anders Hejlsberg**: 「AIの言語を書く能力は、その言語をどれだけ見てきたかに比例する」
3. **TDD + Claude Code**: 「テスト駆動開発はLLM支援とうまく機能する」
4. **厳密な型定義**: 「無効な状態を型で禁止すると、AIがより高品質なコードを生成」
5. **Hooks活用**: 手動チェックではなく、自動品質ゲートで一貫性を確保

### クイックスタートチェックリスト

```markdown
□ tsconfig.json で strict: true を有効化
□ CLAUDE.md をプロジェクトルートに配置
□ .claude/hooks/ で品質ゲートを設定
□ .claude/commands/ でよく使うワークフローをコマンド化
□ neverthrow でResult型を導入（エラーハンドリング）
□ Zod でランタイムバリデーション
□ TDD Guard でテスト駆動開発を強制（任意）
□ CI/CDでClaude Code GitHub Actions統合（任意）
```

---

## 調査メタ情報

**作成者**: Claude Code調査セッション
**調査日**: 2026-01-22

### 調査履歴

| Phase | 内容 | WebSearch回数 |
|-------|------|---------------|
| 初回調査 | 基礎編（セクション1-9） | 6回 |
| Step 1 | 高度な型パターン | 4回 |
| Step 2 | テスト戦略 | 3回 |
| Step 3 | エラーハンドリング | 2回 |
| Step 4 | ワークフロー・CI/CD | 2回 |
| Step 5 | カスタムコマンド | 2回 |
| Step 6 | Hooks設定 | 2回 |
| Step 7 | Monorepo | 2回 |
| Step 8 | API設計 | 2回 |
| **合計** | | **25回** |

---

## 残タスク（CLI版で対応予定）

以下のURLは403エラーのためアクセスできず、詳細な内容取得が未完了:

| URL | 内容 |
|-----|------|
| https://pm.dartus.fr/posts/2025/typescript-ai-aided-development/ | TypeScript + AI開発の詳細事例 |
| https://github.blog/developer-skills/programming-languages-and-frameworks/typescripts-rise-in-the-ai-era-insights-from-lead-architect-anders-hejlsberg/ | Anders Hejlsbergインタビュー全文 |
| https://www.builder.io/blog/typescript-vs-javascript | TypeScript vs JavaScript詳細比較 |

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-01-22 | 初版作成（セクション1-9） |
| 2026-01-22 | Step 1-8追記（セクション10-24） |
