# Hooksテンプレート

Claude Code Hooksの再利用可能なテンプレート集です。

## 概要

| ファイル | 用途 | イベント |
|---------|------|---------|
| `tdd-guard.sh` | テスト改ざん検出・ブロック | PreToolUse (Edit\|Write) |
| `typescript-quality-gate.sh` | TypeScript品質ゲート | Stop |

## 使用方法

### 1. プロジェクトにコピー

```bash
# プロジェクトの.claude/hooks/にコピー
cp shared/docs/templates/hooks/*.sh /path/to/project/.claude/hooks/

# 実行権限付与
chmod +x /path/to/project/.claude/hooks/*.sh
```

### 2. settings.jsonに設定

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/tdd-guard.sh"
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/typescript-quality-gate.sh"
        }]
      }
    ]
  }
}
```

## テンプレート詳細

### tdd-guard.sh

**目的**: t-wadaスタイルTDDを強制し、テスト改ざんを防止

**検出パターン**:
- アサーション削除（`assert`, `expect`, `should`）
- テストスキップ（`it.skip`, `describe.skip`, `@skip`）
- 期待値の変更（警告のみ）

**対応言語**: JavaScript/TypeScript, Python

### typescript-quality-gate.sh

**目的**: ターン終了時に品質チェックを実行

**チェック項目**:
1. 型チェック（`tsc --noEmit`）
2. ESLint
3. 関連テスト実行（Vitest/Jest）

**前提条件**:
- Node.js環境
- TypeScript設定済み
- ESLint設定済み（オプション）

## カスタマイズ

### 検出パターンの追加

`tdd-guard.sh`の検出パターンを追加する場合:

```bash
# 例: 特定のアサーション関数を追加
if echo "$DIFF" | grep -E "^-.*\bexpect\(" > /dev/null; then
  # 検出時の処理
fi
```

### 品質ゲートの項目追加

`typescript-quality-gate.sh`に項目を追加する場合:

```bash
# 例: Prettierチェックを追加
echo "[4/4] Running Prettier check..." >&2
npx prettier --check src/
```

## 関連ドキュメント

- `shared/rules/anti-tampering-rules.md` - 改ざん防止ルール
- `work/research/typescript-claude-code-guide/t-wada-tdd-research.md` - t-wada TDD調査

---

**作成日**: 2026-01-23
**出典**: transcription-workspace PR #10, t-wada TDD調査
