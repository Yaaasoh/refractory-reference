# TypeScript向けカスタムコマンドテンプレート

Claude Codeカスタムコマンド（Slash Commands）のTypeScript向けテンプレート集です。

## 概要

| コマンド | 用途 | 引数 |
|---------|------|------|
| `/tdd-cycle` | t-wadaスタイルTDDサイクル実行 | 機能名または要件 |
| `/type-safety-audit` | TypeScript型安全性監査 | なし |
| `/new-component` | React+TSコンポーネント作成（TDD） | コンポーネント名 |

## 使用方法

### 1. プロジェクトにコピー

```bash
# プロジェクトの.claude/commands/にコピー
cp shared/docs/templates/commands/typescript/*.md /path/to/project/.claude/commands/
```

### 2. 使用

```
/tdd-cycle ユーザー認証機能
/type-safety-audit
/new-component UserAvatar
```

## テンプレート詳細

### /tdd-cycle

**目的**: t-wadaスタイルのTDD（テスト駆動開発）サイクルを実行

**フロー**:
1. テストリスト作成（人間が確認）
2. Red: 失敗するテストを1つ書く
3. Green: 最短で通す（汚くてもOK）
4. Refactor: きれいにする
5. 繰り返し

**特徴**:
- テストリスト先行
- 小さなサイクル維持
- 「動作する」を先に、「きれい」は後

### /type-safety-audit

**目的**: プロジェクトのTypeScript設定を監査し、AIコーディングとの相性を最大化

**チェック項目**:
- tsconfig.json厳密性設定
- 型エラー状況
- `any`型の使用状況

**出力**:
- 厳密性スコア
- 改善提案（Phase 1-3）
- 推奨設定

### /new-component

**目的**: React + TypeScriptコンポーネントをTDDスタイルで作成

**出力ファイル**:
- `src/components/<Name>/<Name>.tsx` - コンポーネント本体
- `src/components/<Name>/<Name>.test.tsx` - テストファイル
- `src/components/<Name>/index.ts` - エクスポート

**特徴**:
- テストファースト
- Props型の明示的定義
- 既存パターンの参照

## カスタマイズ

### プロジェクト固有の調整

各テンプレートはプロジェクトに合わせてカスタマイズ可能:

```markdown
---
description: プロジェクト固有の説明
allowed-tools: Read, Write, Edit, Bash
---

# カスタマイズしたコマンド

## 参考（プロジェクト固有）
@src/components/Button/Button.tsx  ← 既存パターンを参照
```

### Frontmatterオプション

| オプション | 説明 |
|-----------|------|
| `description` | コマンドの説明（`/`入力時に表示） |
| `argument-hint` | 引数のヒント表示 |
| `allowed-tools` | 使用可能なツール制限 |
| `model` | 使用するモデル指定 |

## t-wadaスタイルTDDの原則

これらのコマンドは、t-wada（和田卓人）氏のTDDスタイルに基づいています:

> 「動作するきれいなコード」（Clean code that works）がゴール
> — Ron Jeffries（Kent Beckが引用）

**黄金の回転**: Red → Green → Refactor
- **Red**: 失敗するテストを書く
- **Green**: 最短で通す（汚くてもOK）
- **Refactor**: きれいにする

**AI時代のTDD**:
> 「TDDを取り入れれば、コードとそれをメンテナンスする人間との距離、つまり技術的負債をある程度までコントロールできるようになる」
> — t-wada

## 関連ドキュメント

- `shared/rules/anti-tampering-rules.md` - 改ざん防止ルール（t-wadaスタイルTDD含む）
- `shared/docs/templates/hooks/` - Hooksテンプレート
- `work/research/typescript-claude-code-guide/t-wada-tdd-research.md` - t-wada TDD調査
- `work/research/typescript-claude-code-guide/ANALYSIS_PR10_TYPESCRIPT_TDD.md` - 検討ドキュメント

---

**作成日**: 2026-01-23
**出典**: transcription-workspace PR #10, t-wada TDD調査
