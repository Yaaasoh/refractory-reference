# Claude Code Hooks 使用ガイド

**作成日**: 2025年12月20日
**最終更新**: 2025年12月20日

---

## 📋 このディレクトリについて

すべてのプロジェクトで共通して使える**基本的なHooks**が含まれています。

**Hooksとは**:
- ツール実行前後やセッション開始/終了時に自動実行されるスクリプト
- セキュリティ強化、自動チェック、ワークフロー自動化に活用

---

## 🔧 含まれているHooks

### 1. block_destructive.sh

**目的**: 破壊的コマンドのブロック

**ブロック対象**:
```bash
rm -rf
rm -r
git clean -fd
git clean -f
git reset --hard
find . -delete
```

**使用方法**:
```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash(*)",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/block_destructive.sh"
      }]
    }]
  }
}
```

**動作**:
- 破壊的コマンドを検出すると `exit 1` でツール実行を中止
- エラーメッセージを表示

---

### 2. check_file_size.sh

**目的**: 大規模ファイル読み込み防止

**制限**:
- **10MB以上のファイルは直接読み込み禁止**

**理由**:
- 大規模ファイル読み込みでエラーループに陥る
- ユーザーの中止命令が無視される致命的状態

**使用方法**:
```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Read(*)",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/check_file_size.sh"
      }]
    }]
  }
}
```

**動作**:
- ファイルサイズをチェック
- 10MB以上の場合、代替手段を提案

**代替手段**:
```bash
# PDF
pdftotext file.pdf - | head -1000

# 大規模テキスト
head -500 file.txt
```

---

### 3. check_uncommitted.sh

**目的**: 未コミット変更の確認

**使用方法**:
```json
// .claude/settings.json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/check_uncommitted.sh"
      }]
    }]
  }
}
```

**動作**:
- セッション開始時に `git status` 実行
- 未コミット変更がある場合、警告表示

---

### 4. session_start.sh

**目的**: セッション開始時の情報表示

**表示内容**:
- リポジトリ名
- ブランチ名
- CLAUDE.md の重要な注意事項
- パッケージディレクトリ情報
- 作業ディレクトリ推奨

**使用方法**:
```json
// .claude/settings.json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/session_start.sh"
      }]
    }]
  }
}
```

---

## 🚨 CRITICAL: CRLF問題の予防策

### 問題

**Hooksスクリプトに改行コード CRLF が含まれると動作しません。**

**症状**:
```
line 2: $'\r': command not found
line 5: syntax error near unexpected token `$'\r''
```

### 原因

- Windows環境で Git が自動的に LF → CRLF 変換
- Bash スクリプトは LF のみ対応

### 対策1: .gitattributes 設定（必須）

**プロジェクトルート**に `.gitattributes` を作成:

```gitattributes
# Hooks は常に LF
*.sh text eol=lf

# その他の設定
*.md text
*.json text
*.yaml text
*.yml text
```

**重要**: この設定がないと、Windows環境で必ず CRLF 問題が発生します。

### 対策2: 既存ファイルの修正

すでに CRLF になっている場合:

```bash
# Unix/Linux/macOS
dos2unix shared/hooks/*.sh

# Git で強制的に LF に変換
git add --renormalize .
git commit -m "fix: Normalize line endings for hooks"
```

### 対策3: エディタ設定

**VS Code**:
```json
// .vscode/settings.json
{
  "files.eol": "\n",
  "[shellscript]": {
    "files.eol": "\n"
  }
}
```

**その他のエディタ**:
- ファイル保存時の改行コードを LF に設定

---

## 📦 デプロイ方法

### 1. 共有Hooksをプロジェクトにコピー

```bash
# プロジェクトルートで実行
mkdir -p .claude/hooks
cp shared/hooks/*.sh .claude/hooks/
```

### 2. settings.json に登録

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/session_start.sh"
        },
        {
          "type": "command",
          "command": ".claude/hooks/check_uncommitted.sh"
        }
      ]
    }],
    "PreToolUse": [
      {
        "matcher": "Bash(*)",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/block_destructive.sh"
        }]
      },
      {
        "matcher": "Read(*)",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/check_file_size.sh"
        }]
      }
    ]
  }
}
```

### 3. .gitattributes を作成（必須）

```bash
echo "*.sh text eol=lf" > .gitattributes
git add .gitattributes
git commit -m "chore: Add .gitattributes for hooks"
```

---

## 🔍 トラブルシューティング

### Hook が実行されない

**確認項目**:
1. settings.json に登録されているか
2. パスが正しいか（`.claude/hooks/` から始まる相対パス）
3. 実行権限があるか（`chmod +x .claude/hooks/*.sh`）

### CRLF エラーが発生

**症状**:
```
line 2: $'\r': command not found
```

**対処**:
```bash
# 1. .gitattributes を確認
cat .gitattributes

# 2. ファイルの改行コードを確認
file .claude/hooks/*.sh

# 3. LF に変換
dos2unix .claude/hooks/*.sh

# 4. Git で正規化
git add --renormalize .
git commit -m "fix: Normalize line endings"
```

### Hook が途中で止まる

**原因**: `exit 1` でブロックされている

**確認**:
- Hook の標準出力/エラー出力を確認
- ブロック条件を見直し

---

## 📚 参照リンク

### 公式ドキュメント
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Hooks guide](https://code.claude.com/docs/en/hooks-guide)

### Phase 2調査結果
- `work/claude-code-reference/updates/official-docs/hooks-extracted.md`
- `work/claude-code-reference/updates/step3-github-issues-discussions.md`

### インシデント記録
- `incidents/` - CRLF問題の詳細記録

---

## 🔄 定期メンテナンス

**推奨**: 月1回

1. 公式ドキュメントの更新確認
2. Hooks の動作確認
3. .gitattributes の確認
4. 新規Hooksの追加検討

---

**作成者**: Claude Sonnet 4.5
**作成日**: 2025年12月20日
**ステータス**: Phase 1完了（緊急対応）
