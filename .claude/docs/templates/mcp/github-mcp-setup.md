# GitHub MCP Setup Guide

> **出典**: `work/research/claude-code-web-development/stage2/session_2_5_mcp_integration.md`

GitHub MCPのセットアップと使用方法。

---

## 1. 概要

### 1.1 GitHub MCPとは

GitHub MCPは、Claude CodeからGitHub APIを直接操作するためのMCPサーバー。
Anthropic公式が提供。

### 1.2 できること

- Issue作成・検索・更新
- Pull Request作成・レビュー
- コード検索
- リポジトリ情報取得
- コミット履歴確認

---

## 2. インストール

### 2.1 前提条件

- Node.js 18以上
- Claude Code CLI
- GitHub Personal Access Token

### 2.2 トークン作成

1. GitHub → Settings → Developer settings → Personal access tokens
2. 「Generate new token (classic)」または「Fine-grained tokens」
3. 必要なスコープを選択:
   - `repo`（リポジトリアクセス）
   - `read:org`（組織情報、必要な場合）

### 2.3 CLIでの追加

```bash
# 環境変数を設定
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# MCPサーバー追加
claude mcp add github --scope user
```

### 2.4 手動設定（~/.claude.json）

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

**重要**: トークンは環境変数で管理し、設定ファイルに直接記述しない。

---

## 3. 使用方法

### 3.1 Issue操作

**Issue検索**:
```
Search for issues in owner/repo with label "bug"
```

**Issue作成**:
```
Create an issue in owner/repo titled "Fix login bug" with body "..."
```

**Issue更新**:
```
Add label "in-progress" to issue #123 in owner/repo
```

### 3.2 Pull Request操作

**PR作成**:
```
Create a pull request in owner/repo from feature-branch to main
```

**PR情報取得**:
```
Get details of pull request #456 in owner/repo
```

**PRレビュー**:
```
Get review comments on PR #456 in owner/repo
```

### 3.3 コード検索

```
Search for code containing "handleSubmit" in owner/repo
```

### 3.4 リポジトリ情報

```
Get repository information for owner/repo
```

```
Get recent commits in owner/repo
```

---

## 4. ワークフロー統合

### 4.1 Issue → 実装 → PR

```
1. Issue確認
   └── Get issue #123 details

2. 実装
   └── （通常のコーディング）

3. PR作成
   └── Create pull request referencing issue #123

4. レビュー対応
   └── Get PR review comments
   └── 修正
```

### 4.2 自動PR作成

```
1. 変更をコミット
   └── Bash: git add && git commit

2. ブランチをプッシュ
   └── Bash: git push

3. PR作成
   └── GitHub MCP: Create pull request
```

---

## 5. セキュリティ考慮事項

### 5.1 トークン管理

| DO | DON'T |
|----|-------|
| 環境変数で管理 | 設定ファイルに直接記述 |
| 最小限のスコープ | 全スコープ付与 |
| 定期的なローテーション | 永続的な使用 |

### 5.2 推奨スコープ（Fine-grained tokens）

| 用途 | 必要な権限 |
|------|-----------|
| **読み取りのみ** | `contents: read`, `issues: read`, `pull_requests: read` |
| **Issue/PR作成** | + `issues: write`, `pull_requests: write` |
| **コードプッシュ** | + `contents: write` |

### 5.3 環境変数設定

**Linux/macOS（~/.bashrc または ~/.zshrc）**:
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

**Windows（PowerShell）**:
```powershell
[Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_xxxx", "User")
```

**Windows（システム環境変数）**:
1. システムのプロパティ → 環境変数
2. ユーザー環境変数に `GITHUB_TOKEN` を追加

---

## 6. トラブルシューティング

### 6.1 よくある問題

| 問題 | 原因 | 対策 |
|------|------|------|
| 認証エラー | トークン無効/期限切れ | 新しいトークン発行 |
| 権限エラー | スコープ不足 | 必要なスコープを追加 |
| レート制限 | API呼び出し過多 | 待機、または認証済みリクエスト使用 |
| サーバー起動しない | 環境変数未設定 | GITHUB_TOKEN設定 |

### 6.2 デバッグ

```bash
# 環境変数確認
echo $GITHUB_TOKEN

# MCPデバッグモード
claude --mcp-debug
```

### 6.3 設定確認

```bash
# サーバー一覧
claude mcp list

# GitHub サーバー詳細
claude mcp get github
```

---

## 7. ユースケース

### 7.1 類似Issue検索

```
プロジェクトでバグを発見した場合:

1. Search for similar issues in owner/repo
2. 類似Issueがなければ新規作成
3. Create issue with appropriate labels
```

### 7.2 自動化されたPRワークフロー

```
1. 機能実装完了

2. GitHub MCP でPR作成
   - タイトル: "feat: Add new feature"
   - 本文: 変更内容の説明
   - ラベル: enhancement

3. レビュー待ち

4. レビューコメント取得
   - Get review comments

5. 対応・修正

6. マージ
```

### 7.3 コードベース調査

```
新しいプロジェクトに参加した場合:

1. Get repository information
2. Search for code patterns (e.g., "handleError")
3. Get recent commits to understand recent changes
```

---

## 8. Hooks連携

### 8.1 GitHub操作のログ

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "mcp__github__*",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): GitHub MCP used\" >> ~/.claude/mcp-log.txt"
          }
        ]
      }
    ]
  }
}
```

### 8.2 Issue作成時の通知

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "mcp__github__create_issue",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'New issue created via Claude Code'"
          }
        ]
      }
    ]
  }
}
```

---

## 9. Claude Code組み込みGit機能との使い分け

### 9.1 使い分けガイド

| 操作 | 推奨ツール | 理由 |
|------|-----------|------|
| **コミット** | Bash (git) | 組み込み機能で十分 |
| **プッシュ** | Bash (git) | 組み込み機能で十分 |
| **Issue操作** | GitHub MCP | API経由で高度な操作可能 |
| **PR作成** | GitHub MCP または `gh` CLI | どちらも可 |
| **コード検索** | GitHub MCP | 大規模リポジトリで有効 |

### 9.2 gh CLI との違い

| 特性 | GitHub MCP | gh CLI |
|------|-----------|--------|
| **インストール** | npx で自動 | 別途インストール必要 |
| **認証** | 環境変数 | `gh auth login` |
| **Claude Code統合** | MCP経由で自然な対話 | Bash経由 |

---

## 10. 参照リソース

### 公式

- [MCP Servers Repository (GitHub)](https://github.com/modelcontextprotocol/servers)
- [GitHub REST API Documentation](https://docs.github.com/en/rest)

### コミュニティ

- [Best MCP Servers for Claude Code (MCPcat)](https://mcpcat.io/guides/best-mcp-servers-for-claude-code/)
- [Claude Code MCP Integration (ClaudeCode.io)](https://claudecode.io/guides/mcp-integration)
