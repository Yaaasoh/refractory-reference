# Claude Code設定更新連絡書

**発行日**: 2026-01-18
**発行元**: prompt-patterns
**対象**: 本リポジトリの `.claude/settings.json`
**優先度**: 低（次回作業時に対応可）

---

## 概要

2026年1月のClaude Codeベストプラクティス調査に基づき、settings.jsonの設定更新が推奨されます。

**緊急性**: なし（パフォーマンス改善のみ）

---

## 更新内容

### 1. timeout設定の追加

**目的**: フック実行時間の明示化、予期せぬブロッキング防止

**変更前**:
```json
{
  "type": "command",
  "command": "bash .claude/hooks/block_destructive.sh"
}
```

**変更後**:
```json
{
  "type": "command",
  "command": "bash .claude/hooks/block_destructive.sh",
  "timeout": 5
}
```

**推奨timeout値**:
| フック | timeout |
|--------|:-------:|
| block_destructive.sh | 5秒 |
| check_file_size.sh | 5秒 |
| check_encoding.sh | 5秒 |
| check_public_repo.sh | 10秒 |
| session_start.sh | 10秒 |
| check_uncommitted.sh | 10秒 |

### 2. .gitignoreへのtmpclaude追加

**目的**: Claude Codeが作成する一時ファイルの除外

**背景**: [GitHub Issue #17600](https://github.com/anthropics/claude-code/issues/17600) - 未修正

**追加内容**:
```gitignore
# Claude Code temporary files (Issue #17600 - not yet fixed)
tmpclaude-*-cwd
tmpclaude-*
```

---

## 対応手順

### 手順1: settings.jsonの更新

`.claude/settings.json`の各フックにtimeout設定を追加:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block_destructive.sh",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_file_size.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_encoding.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_public_repo.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/session_start.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_uncommitted.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### 手順2: .gitignore更新

```bash
# .gitignoreに追加
echo "" >> .gitignore
echo "# Claude Code temporary files (Issue #17600)" >> .gitignore
echo "tmpclaude-*" >> .gitignore
```

### 手順3: 既存tmpclaude削除（任意）

```bash
rm tmpclaude-*-cwd 2>/dev/null || true
```

### 手順4: コミット

```bash
git add .claude/settings.json .gitignore
git commit -m "chore: Add timeout settings and tmpclaude gitignore (2026-01 best practices)"
```

---

## 完了後の対応

本連絡書の対応完了後、このファイルを削除してください:

```bash
rm .claude/docs/work-orders/SETTINGS_UPDATE_NOTICE_202601.md
git add -A && git commit -m "chore: Remove completed settings update notice"
```

---

## 参照

- 調査レポート: `prompt-patterns/work/research/claude_code_config_review_202601_v2.md`
- Issue調査: `prompt-patterns/work/research/claude_code_issues_202601.md`
- GitHub Issue: [#17600 - tmpclaude-*-cwd files](https://github.com/anthropics/claude-code/issues/17600)

---

**ステータス**: 未対応
