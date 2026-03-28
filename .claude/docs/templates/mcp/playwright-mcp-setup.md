# Playwright MCP Setup Guide

> **出典**: `work/research/claude-code-web-development/stage2/session_2_5_mcp_integration.md`

Playwright MCPのセットアップと使用方法。

---

## 1. 概要

### 1.1 Playwright MCPとは

Playwright MCPは、Claude CodeからWebブラウザを直接制御するためのMCPサーバー。
Microsoft公式が提供。

### 1.2 できること

- ページナビゲーション
- スクリーンショット取得
- クリック・入力操作
- JavaScript実行
- 要素の確認

---

## 2. インストール

### 2.1 前提条件

- Node.js 18以上
- Claude Code CLI

### 2.2 CLIでの追加

```bash
# ユーザースコープで追加（全プロジェクト共通）
claude mcp add playwright --scope user

# プロジェクトスコープで追加
claude mcp add playwright
```

### 2.3 手動設定（~/.claude.json）

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"]
    }
  }
}
```

### 2.4 プロジェクト固有設定（.mcp.json）

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"]
    }
  }
}
```

---

## 3. 使用方法

### 3.1 基本コマンド

**ブラウザを開く**:
```
Use playwright mcp to open a browser to https://example.com
```

**スクリーンショット取得**:
```
Take a screenshot of the current page
```

**要素をクリック**:
```
Click the button with text "Login"
```

**フォーム入力**:
```
Fill the input field with id "email" with "test@example.com"
```

### 3.2 重要な注意点

**初回は明示的に「playwright mcp」と指定する**

悪い例:
```
Open a browser to localhost:3000
→ BashでPlaywrightを実行しようとする
```

良い例:
```
Use playwright mcp to open a browser to localhost:3000
→ MCPサーバー経由でブラウザが開く
```

---

## 4. 設定オプション

### 4.1 ブラウザ設定

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"],
      "env": {
        "PLAYWRIGHT_BROWSER": "chromium"
      }
    }
  }
}
```

利用可能なブラウザ:
- `chromium`（デフォルト）
- `firefox`
- `webkit`

### 4.2 ヘッドレスモード

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp", "--headless"]
    }
  }
}
```

**注意**: ヘッドレスモードではブラウザウィンドウが表示されない。
視覚確認が必要な場合はデフォルト（ヘッドフル）を使用。

---

## 5. トラブルシューティング

### 5.1 よくある問題

| 問題 | 原因 | 対策 |
|------|------|------|
| サーバーが起動しない | Node.js未インストール | Node.js 18+をインストール |
| ブラウザが開かない | 設定ファイルの構文エラー | JSON構文を確認 |
| Bashで実行される | 「playwright mcp」と言っていない | 明示的に指定 |
| タイムアウト | ページ読み込み遅延 | 待機時間を指定 |

### 5.2 デバッグ

```bash
# MCPデバッグモードで起動
claude --mcp-debug
```

### 5.3 設定確認

```bash
# 登録されたMCPサーバー一覧
claude mcp list

# 特定サーバーの詳細
claude mcp get playwright
```

---

## 6. セキュリティ考慮事項

### 6.1 ローカル環境での使用

Playwright MCPはローカルマシンでブラウザを起動する。
以下に注意:

- 認証情報を含むページへのアクセスは慎重に
- スクリーンショットに機密情報が含まれる可能性
- ローカル開発サーバー（localhost）へのアクセスは安全

### 6.2 推奨プラクティス

| プラクティス | 理由 |
|-------------|------|
| テスト環境のみで使用 | 本番データへのアクセス回避 |
| スクリーンショットのGit管理 | 機密情報が含まれないか確認 |
| 認証が必要なページは避ける | 認証情報の漏洩防止 |

---

## 7. ユースケース

### 7.1 開発中の視覚確認

```
1. 開発サーバー起動
2. Use playwright mcp to open localhost:3000
3. Navigate to /components/button
4. Take a screenshot
5. 問題があれば修正
```

### 7.2 E2Eテスト支援

```
1. Use playwright mcp to open localhost:3000/login
2. Fill email field with "test@example.com"
3. Fill password field with "password123"
4. Click the login button
5. Take a screenshot
6. Verify the dashboard is displayed
```

### 7.3 レスポンシブ確認

```
1. Set viewport to 375x667 (mobile)
2. Take a screenshot
3. Set viewport to 768x1024 (tablet)
4. Take a screenshot
5. Set viewport to 1440x900 (desktop)
6. Take a screenshot
```

---

## 8. Hooks連携

### 8.1 PostToolUse連携

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "mcp__playwright__*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Playwright MCP used' >> ~/.claude/mcp-log.txt"
          }
        ]
      }
    ]
  }
}
```

### 8.2 スクリーンショット自動保存

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "mcp__playwright__screenshot",
        "hooks": [
          {
            "type": "command",
            "command": "cp /tmp/playwright-screenshot.png tests/screenshots/"
          }
        ]
      }
    ]
  }
}
```

---

## 9. 参照リソース

### 公式

- [Playwright MCP (GitHub)](https://github.com/microsoft/playwright-mcp)
- [Playwright Documentation](https://playwright.dev/)

### コミュニティ

- [Using Playwright MCP with Claude Code (Simon Willison)](https://til.simonwillison.net/claude-code/playwright-mcp-claude-code)
- [Claude Code MCP Workflow](https://vladimirsiedykh.com/blog/claude-code-mcp-workflow-playwright-supabase-figma-linear-integration-2025)

---

## 10. CLIモード（v0.0.58〜）

> **追加日**: 2026-01-24
> **対象バージョン**: v0.0.58以降

v0.0.58で**トークン効率の良いCLIモード**が追加された。

### 10.1 概要

従来のMCPサーバー方式に加え、Bashツール経由で直接コマンドを実行できる。

| 観点 | MCPサーバー方式 | CLI方式 |
|------|----------------|---------|
| トークン効率 | △ やや多い | ◎ 効率的 |
| セッション管理 | 都度起動 | 永続プロファイル |
| 複数操作 | 複数ツール呼び出し | 1回のBashで完結 |
| 学習コスト | 低（自然言語） | 中（コマンド構文） |

### 10.2 インストール

```bash
npm install -g @playwright/mcp@latest
```

### 10.3 基本コマンド

```bash
# ページを開く
npx @playwright/mcp navigate https://example.com

# クリック
npx @playwright/mcp click "button#login"

# テキスト入力
npx @playwright/mcp fill "input#email" "test@example.com"

# スクリーンショット
npx @playwright/mcp screenshot output.png

# ページ戻る/進む
npx @playwright/mcp goBack
npx @playwright/mcp goForward

# リロード
npx @playwright/mcp reload
```

### 10.4 コマンドカテゴリ

| カテゴリ | コマンド例 |
|---------|-----------|
| 基本操作 | `navigate`, `click`, `fill`, `drag` |
| ナビゲーション | `goBack`, `goForward`, `reload` |
| キーボード・マウス | `press`, `hover`, `scroll` |
| スクリーンショット・PDF | `screenshot`, `pdf` |
| タブ管理 | `newTab`, `closeTab`, `switchTab` |
| DevTools | `console`, `network`, `trace` |

### 10.5 セッション管理

CLIモードでは**永続的なブラウザプロファイル**がデフォルト。

- クッキーとストレージ状態が複数セッション間で保持
- ログイン状態の維持が可能
- 明示的なクリアが必要な場合は `--clean` オプション

### 10.6 使い分けガイド

| ユースケース | 推奨方式 |
|-------------|---------|
| 対話的な操作（自然言語で指示） | MCPサーバー |
| 自動化スクリプト | CLI |
| トークン節約が重要 | CLI |
| 初心者・学習目的 | MCPサーバー |
| 複数操作を連続実行 | CLI |

### 10.7 permissions設定（オプション）

`settings.local.json`に追加する場合:

```json
{
  "permissions": {
    "allow": [
      "Bash(npx @playwright/mcp:*)"
    ]
  }
}
```

### 10.8 ⚠️ CLIモードの制約（2026-03-16確認）

**セクション10.3のCLIコマンド例は未検証**。GCE VM上で実行した結果:

```
$ npx @playwright/mcp navigate https://example.com
error: too many arguments. Expected 0 arguments but got 2.
```

`@playwright/mcp`はMCPサーバーであり、CLIサブコマンド（`navigate`, `click`等）を直接受け付けない。
セクション10.3のコマンド例はv0.0.58リリースノートに基づく記載だが、実際の動作と乖離している可能性がある。

**推奨**: MCP方式（セクション1-8）を使用すること。

### 10.9 参照

- [v0.0.58 Release Notes](https://github.com/microsoft/playwright-mcp/releases/tag/v0.0.58)

---

## 11. GCE Linux VM でのヘッドレス実行

> **追加日**: 2026-03-16
> **動作確認環境**: GCE n2d-standard-2, Ubuntu 24.04, Node.js 22

### 11.1 概要

GCE Linux VMにはディスプレイがないため、ヘッドレスモードで実行する。
Xvfbは不要（Chromium自体がヘッドレス対応）。

### 11.2 追加インストール

```bash
# Chromium依存ライブラリ + 日本語フォント
sudo apt install -y \
  libnss3 libnspr4 libatk1.0-0t64 libatk-bridge2.0-0t64 \
  libcups2t64 libdrm2 libxkbcommon0 libxcomposite1 \
  libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 \
  libcairo2 libasound2t64 libxshmfence1 fonts-noto-cjk

# Playwright本体（@playwright/mcpとは別に必要）
npm install -g playwright

# Chrome（MCPはデフォルトでchromeを要求）
npx playwright install chrome
```

### 11.3 .mcp.json設定

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp", "--headless"]
    }
  }
}
```

### 11.4 注意事項

| 項目 | 内容 |
|------|------|
| `--headless` | **必須**（GCEにディスプレイがないため） |
| `chromium` vs `chrome` | MCPは`chrome`を要求。`npx playwright install chromium`だけでは不足 |
| `playwright`本体 | `@playwright/mcp`とは別パッケージ。Node.js API使用時に必要 |
| `claude -p` | 非対話モードでは権限承認不可。settings.jsonにallow設定が必須 |
| サンドボックス | GCEカーネル5.x+でネイティブ動作。`--no-sandbox`不要 |

### 11.5 claude -p（非対話モード）で使う場合

`settings.json`にPlaywright MCP関連の許可を事前追加する必要がある:

```json
{
  "permissions": {
    "allow": [
      "mcp__playwright__*"
    ]
  }
}
```

これにより`claude -p "E2Eテストを実行して"`のような非対話実行が可能になる。
