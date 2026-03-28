# Chrome DevTools MCP 導入ガイド

**導入日**: 2026-01-06
**ステータス**: 導入完了
**スコープ**: ユーザーレベル（全リポジトリで使用可能）

---

## 1. 導入完了報告

Chrome DevTools MCPがユーザーレベルでインストールされました。

```bash
# 確認コマンド
claude mcp list
# → chrome-devtools: ✓ Connected
```

---

## 2. 概要

| 項目 | 内容 |
|------|------|
| **提供元** | Google公式 |
| **機能数** | 26ツール（6カテゴリ） |
| **基盤技術** | Puppeteer + Chrome DevTools Protocol (CDP) |

### 主要機能

- スクリーンショット取得
- コンソールログ確認
- ネットワークリクエスト分析
- DOM検査・操作
- JavaScript実行
- パフォーマンストレース

---

## 3. 基本的な使い方

### 3.1 スクリーンショット取得

```
Claude Codeで: "Take a screenshot of https://example.com"
```

### 3.2 コンソールログ確認

```
Claude Codeで: "Navigate to https://example.com and show console messages"
```

### 3.3 ネットワーク分析

```
Claude Codeで: "Navigate to https://example.com and list network requests"
```

---

## 4. 使用可能なツール

### 4.1 ナビゲーション

| ツール | 説明 |
|--------|------|
| `navigate` | URLに移動 |
| `go_back` | 前のページに戻る |
| `go_forward` | 次のページに進む |
| `reload` | ページをリロード |

### 4.2 スクリーンショット

| ツール | 説明 |
|--------|------|
| `take_screenshot` | ページ全体または要素のスクリーンショット |
| `take_element_screenshot` | 特定要素のスクリーンショット |

### 4.3 DOM操作

| ツール | 説明 |
|--------|------|
| `click` | 要素をクリック |
| `type` | テキストを入力 |
| `select` | セレクトボックスの選択 |
| `hover` | 要素にホバー |

### 4.4 開発者ツール

| ツール | 説明 |
|--------|------|
| `list_console_messages` | コンソールメッセージ一覧 |
| `list_network_requests` | ネットワークリクエスト一覧 |
| `evaluate` | JavaScript実行 |

### 4.5 パフォーマンス

| ツール | 説明 |
|--------|------|
| `start_tracing` | トレース開始 |
| `stop_tracing` | トレース停止・分析 |

---

## 5. ユースケース例

### 5.1 Webアプリデバッグ

```
"Navigate to http://localhost:3000, take a screenshot, and show any console errors"
```

### 5.2 API検証

```
"Navigate to https://example.com/api-test and list all XHR requests"
```

### 5.3 パフォーマンス分析

```
"Navigate to https://example.com, record a performance trace for 5 seconds, and analyze LCP"
```

---

## 6. 注意事項

### 6.1 セキュリティ

- **認証サイト**: 専用プロファイルを使用（後述のxserverガイド参照）
- **機密情報**: ログイン済みサイトへのAIアクセスに注意
- **使用後**: Chrome終了を推奨

### 6.2 制限事項

- **ブラウザ**: Chrome専用
- **リソース**: 長時間セッションでメモリ使用量増加
- **タイムアウト**: 重い処理（Pyodide等）は60秒以上のタイムアウト設定推奨

---

## 7. トラブルシューティング

### 接続できない場合

```bash
# MCPサーバーの状態確認
claude mcp list

# 再インストール
claude mcp remove chrome-devtools
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest
```

### タイムアウトエラー

重い処理の場合、明示的に待機を指示:

```
"Navigate to the page and wait for 30 seconds before taking a screenshot"
```

---

## 8. 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [XSERVER_AUTHENTICATION_GUIDE.md](./XSERVER_AUTHENTICATION_GUIDE.md) | xserver認証サイトでの使用方法 |
| [prompt-patterns調査レポート](https://github.com/Yaaasoh/prompt-patterns/work/research/chrome-devtools-mcp/) | 詳細調査資料 |

---

## 9. 参考リンク

- [Chrome Developers公式ブログ](https://developer.chrome.com/blog/chrome-devtools-mcp)
- [GitHubリポジトリ](https://github.com/ChromeDevTools/chrome-devtools-mcp)

---

**作成者**: Claude Code (Opus 4.5)
**基準**: prompt-patterns/work/research/chrome-devtools-mcp/RESEARCH_REPORT.md
