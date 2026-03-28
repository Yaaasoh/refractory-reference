# テンプレート集

Claude Code開発における標準テンプレート。
SVCPサイクルに基づき体系化された構成。

---

## 構成

```
templates/
├── claude-md/         # CLAUDE.md関連
├── session/           # セッション管理
├── checkpoint/        # チェックポイント
├── investigation/     # 調査ワークフロー
├── specification/     # 仕様記述
├── task/              # タスク管理
├── hooks/             # Hooks設定
├── mcp/               # MCP設定
└── github-actions/    # CI/CD
```

---

## テンプレート一覧

### CLAUDE.md関連

| テンプレート | 用途 |
|-------------|------|
| [claude-md/CLAUDE_MD_TEMPLATE.md](claude-md/CLAUDE_MD_TEMPLATE.md) | SVCP形式CLAUDE.md |

### セッション管理

| テンプレート | 用途 |
|-------------|------|
| [session/SESSION_START_CHECKLIST.md](session/SESSION_START_CHECKLIST.md) | セッション開始チェック |
| [session/SESSION_END_REPORT.md](session/SESSION_END_REPORT.md) | セッション終了報告 |

### チェックポイント

| テンプレート | 用途 |
|-------------|------|
| [checkpoint/CHECKPOINT_TEMPLATE.md](checkpoint/CHECKPOINT_TEMPLATE.md) | 30分/80%ルール、進捗確認 |

### 調査ワークフロー

| テンプレート | 用途 |
|-------------|------|
| [investigation/SESSION_PLAN.md](investigation/SESSION_PLAN.md) | 調査計画書 |
| [investigation/COMPLETION_REPORT.md](investigation/COMPLETION_REPORT.md) | 調査完了報告 |

### 仕様記述

| テンプレート | 用途 |
|-------------|------|
| [specification/GWT_COMPLETION_CRITERIA.md](specification/GWT_COMPLETION_CRITERIA.md) | Given-When-Then形式 |

### タスク管理

| テンプレート | 用途 |
|-------------|------|
| [task/TODOWRITE_TEMPLATES.md](task/TODOWRITE_TEMPLATES.md) | TodoWriteパターン |

### Hooks設定

| テンプレート | 用途 |
|-------------|------|
| hooks/ | Hooks設定JSON |

### MCP設定

| テンプレート | 用途 |
|-------------|------|
| [mcp/playwright-mcp-setup.md](mcp/playwright-mcp-setup.md) | Playwright MCPセットアップ |
| [mcp/github-mcp-setup.md](mcp/github-mcp-setup.md) | GitHub MCPセットアップ |

### GitHub Actions

| テンプレート | 用途 |
|-------------|------|
| github-actions/ | CI/CDワークフロー |

---

## SVCP対応

| カテゴリ | SVCP | 該当テンプレート |
|---------|------|-----------------|
| 仕様 | **S** (Specification) | CLAUDE_MD_TEMPLATE, GWT_COMPLETION_CRITERIA |
| 検証 | **V** (Verification) | investigation/, hooks/ |
| 制御 | **C** (Control) | CHECKPOINT_TEMPLATE, SESSION_* |
| 進捗 | **P** (Progress) | TODOWRITE_TEMPLATES |

---

## 核心ルール

### WebSearch結果保存義務

```
WebSearch/WebFetch実行回数 = 保存ファイル数
```

**絶対禁止**: WebSearch結果を捨てる

### 調査レポート4必須セクション

| セクション | 内容 |
|-----------|------|
| **目的** | 調査の背景と目的 |
| **結論** | 主要な発見事項 |
| **詳細** | 調査内容の詳細 |
| **参照** | 情報源、関連文書 |

---

## デプロイ

```bash
./scripts/deploy.sh -t /path/to/target-repo
```

---

## 改訂履歴

| 日付 | 内容 |
|------|------|
| 2025-12-29 | 初版作成 |
| 2026-01-01 | V1/V2統合、サブディレクトリ再構成 |
