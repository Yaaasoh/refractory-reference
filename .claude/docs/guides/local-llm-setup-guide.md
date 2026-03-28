# ローカルLLM調査エージェント セットアップガイド

## 1. 概要

Claude Codeセッション外でファイル調査をバックグラウンド実行する仕組み。
LM Studio + Qwen3.5-9B でファイルシステムの検索・読み取り・grep結果をMarkdownレポートにまとめる。

**2つの実行方式**:

| 方式 | ランナー | API | ツール実行 | 推奨用途 |
|------|---------|-----|----------|---------|
| MCP方式 | `mcp_runner.py` | `/api/v1/chat` | サーバー側自動実行 | 通常の調査 |
| FC方式 | `agent_runner.py` | `/v1/chat/completions` | クライアント側Python | FC精度テスト・デバッグ |

## 2. 前提条件

| 要件 | 詳細 |
|------|------|
| OS | Windows 11 |
| GPU | NVIDIA GeForce RTX（VRAM 8GB以上、12GB推奨） |
| Python | 3.11+（`py -3.11` 経由。素の`python`は禁止） |
| LM Studio | v0.4.7+ |
| deploy.sh | `-l` フラグで配置済み |

## 3. LM Studioセットアップ

### 3.1 インストールとモデル準備

1. https://lmstudio.ai/download からWindows版をインストール
2. LM Studioを1回起動（CLI有効化に必要）
3. モデルダウンロード:
```bash
~/.lmstudio/bin/lms get "qwen/qwen3.5-9b" -y
```
4. サーバー起動とモデルロード:
```bash
~/.lmstudio/bin/lms server start
~/.lmstudio/bin/lms load "qwen/qwen3.5-9b" --gpu=max --yes
```

### 3.2 Server Settings

Developer → Server Settings で以下をON:

| 設定 | 値 | 理由 |
|------|-----|------|
| Require Authentication | **ON** | mcp.jsonサーバー利用に必須 |
| Allow per-request MCPs | **ON** | エフェメラルMCP（HuggingFace等）利用 |
| Allow calling servers from mcp.json | **ON** | filesystemサーバー利用 |
| Just-in-Time Model Loading | **ON** | 動的モデルロード |
| JIT models auto-evict | **注意** | ONだとdraft_model指定時にメインモデルが自動アンロードされる副作用あり（§12参照） |

### 3.3 APIトークン生成

Server Settings → Manage Tokens → Create token:
- Name: 任意（例: `agent-runner`）
- Allow per-request remote MCP servers: **Allow**
- Allow calling servers from mcp.json: **Allow**

生成されたトークン（`sk-lm-XXXXX`）を記録。

**トークン保存先**: `~/.lmstudio/api_token.txt`
- トークンは1行テキストで保存する（改行のみ、他のフォーマットなし）
- このファイルはgitignore対象であること
- スクリプトからは `cat ~/.lmstudio/api_token.txt` で読み取り可能

### 3.4 mcp.json設定

`~/.lmstudio/mcp.json` を作成:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-filesystem@latest", "C:/Users/<USERNAME>/github"]
    }
  }
}
```

### 3.5 動作確認

```bash
# OpenAI互換API（FC方式用）
curl -s http://localhost:1234/v1/models | py -3.11 -m json.tool

# Stateful API + MCP（MCP方式用）
curl -s http://localhost:1234/api/v1/chat \
  -H "Authorization: Bearer sk-lm-XXXXX" \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen/qwen3.5-9b","input":"List C:/Users/<USERNAME>/github","integrations":["mcp/filesystem"],"context_length":8000,"temperature":0,"reasoning":"off"}'
```

## 4. TdrDelay設定（eGPU / 長時間推論対策）

管理者PowerShellで実行:
```powershell
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDelay /t REG_DWORD /d 60 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDdiDelay /t REG_DWORD /d 60 /f
```

再起動後に有効化。デフォルト2秒を60秒に延長。

## 5. deploy.shでの配置

```bash
./scripts/deploy.sh -t -l /path/to/target-repo
```

配置先: `.claude/scripts/local-llm-tools/`（7ファイル）

## 6. 使い方

### 6.1 /local-investigate コマンド（Claude Code内）

```
/local-investigate tech-v2の05-projectsの構造を調査してください
/local-investigate .claude/scripts/local-llm-tools/tasks/my_task.json
```

### 6.2 MCP方式（推奨）

```bash
cd .claude/scripts/local-llm-tools
py -3.11 mcp_runner.py --task tasks/mcp_task.json --token "sk-lm-XXXXX" -v
```

### 6.3 FC方式

```bash
cd .claude/scripts/local-llm-tools
py -3.11 agent_runner.py --task tasks/example_task.json -v
```

### 6.4 GPU事前チェックのみ

```bash
py -3.11 gpu_guard.py --check
```

## 7. タスク定義リファレンス

### 共通フィールド

| フィールド | 必須 | デフォルト | 説明 |
|-----------|:----:|----------|------|
| name | - | ファイル名 | レポートファイル名に使用 |
| system_prompt | - | 汎用プロンプト | 下記注意参照 |
| prompt | **必須** | - | 調査指示 |
| max_turns | - | 20 (FC) / 8 (MCP) | ツール呼び出し最大回数 |
| model | - | qwen/qwen3.5-9b | LM Studioのモデル識別子 |

### FC方式の追加フィールド

| フィールド | 必須 | デフォルト | 説明 |
|-----------|:----:|----------|------|
| allowed_paths | **必須** | [] | ツールがアクセスできるパス |

### MCP方式の追加フィールド

| フィールド | 必須 | デフォルト | 説明 |
|-----------|:----:|----------|------|
| integrations | - | `["mcp/filesystem"]` | MCP統合設定 |
| context_length | - | 8000 | コンテキスト長（16000は安定性低下） |
| max_output_tokens | - | 4096 | 最大出力トークン数（Stateful API正式名。OpenAI互換の`max_tokens`とは別） |
| reasoning | - | `"off"` | thinking制御（`"on"`/`"off"`の2値。§7.4参照） |
| api_token | - | - | LM Studio APIトークン（`sk-lm-XXXXX`形式） |

### Thinking制御（重要）

Qwen3.5-9BはデフォルトでthinkingがONになる。thinking暴走すると`max_output_tokens`をreasoningトークンで消費し、content（回答）が空になる。

**制御方法**: Stateful APIの`reasoning`パラメータを使用（mcp_runner.pyはデフォルト`"off"`）

| 方法 | 対応状況 | 備考 |
|------|:--------:|------|
| `reasoning: "off"` (Stateful API) | **推奨** | 確実にthinking OFF。0 reasoning tokens |
| `reasoning: "on"` (Stateful API) | 使用可 | thinkingが暴走しやすい。`max_output_tokens`を十分確保すること |
| `reasoning: "low"/"medium"/"high"` | **非対応** | Qwen3.5は`on`/`off`の2値のみ |
| `/no_think` (プロンプト内) | **非対応** | Qwen3.5では公式非サポート（Issue #1559） |
| `chat_template_kwargs` | **非対応** | LM Studio Stateful APIでは未サポート |
| OpenAI互換APIの`reasoning` | **無視される** | thinking制御はStateful API経由のみ有効 |

### API パラメータ名の違い

| 機能 | Stateful API (`/api/v1/chat`) | OpenAI互換 (`/v1/chat/completions`) |
|------|------|------|
| 最大出力長 | `max_output_tokens` | `max_tokens` |
| thinking制御 | `reasoning` ("on"/"off") | **未対応** |
| 入力 | `input` | `messages` |
| MCP統合 | `integrations` | **未対応** |
| 会話継続 | `previous_response_id` | **未対応** |

## 8. GPUガード

| 機能 | 説明 | コマンド |
|------|------|---------|
| pre-flight check | VRAM/RAM事前確認 | `py -3.11 gpu_guard.py --check` |
| GPUWatchdog | 実行中5秒間隔メトリクス記録 | 自動（`--skip-preflight`で無効化） |
| emergency_unload | クラッシュ時モデル自動アンロード | 自動 |
| post_crash_analysis | イベントログ+watchdog突合分析 | `py -3.11 gpu_guard.py --analyze` |

## 8.1 バッチ実行のメモリ管理（基本原則）

ローカルLLMのバッチ実行（複数タスクの連続処理）では、推論ごとにKVキャッシュがRAMに蓄積し自動解放されない。

**原則: N件処理ごとにモデルをサイクルする**

```python
# オーケストレータの標準パターン
UNLOAD_INTERVAL = 3  # 3タスクごとにKVキャッシュ解放

for i, task in enumerate(tasks):
    run_task(task)

    if (i + 1) % UNLOAD_INTERVAL == 0:
        subprocess.run(["lms", "unload", "--all"], timeout=30)
        time.sleep(2)  # unload完了待ち
        # JIT Loading ONなら次のAPIリクエストで自動リロード
```

**なぜ必要か**: 16GB RAM環境でQwen3.5-9B（6.55GB）ロード時、RAM使用率は86%が正常。推論2-3回で93-95%に達し、preflightブロックまたはシステム不安定に至る。

**`lms unload --all`の効果**: KVキャッシュ含め全解放。上記環境で95% → 53%に回復（7GB解放）。JIT Loading ONなら次リクエストで自動リロード（数秒のオーバーヘッド）。

## 9. トラブルシューティング

| 症状 | 原因 | 対策 |
|------|------|------|
| LM Studioに接続できない | サーバー未起動 | `~/.lmstudio/bin/lms server start` |
| 401 Unauthorized | APIトークン未設定/無効 | Server Settings → Manage Tokensで再生成 |
| MCP タイムアウト | 1ターンで大量ツール呼び出し | **タスクを分割（1ターン1-2操作に制限）** |
| mcp.jsonサーバー利用不可 | Require Authentication=OFF | ONに変更し、APIトークンを生成 |
| pre-flight FAIL: VRAM不足 | WhisperX等がVRAM使用中 | 他のGPUプロセスを停止 |
| TDRクラッシュ | eGPU負荷過大 | TdrDelay=60s設定、max_turns削減 |
| 空のレポート出力 | コンテキスト超過 | context_lengthを8000に制限 |
| `exit code 9009` | 素の`python`使用 | `py -3.11`を使用 |
| TTFT遅延（5秒+） | マルチターンでコンテキスト蓄積 | max_turnsを8以下に制限 |
| thinking暴走（回答が空） | `reasoning`未指定でthinkingがON | `reasoning: "off"`を明示指定（§7.4参照） |
| Spec Dec非対応エラー | Qwen3.5がマルチモーダルモデル | 外部ドラフトモデル方式は使用不可（§12参照） |
| draft_model指定後に全モデルがアンロード | JIT auto-evictがメインモデルを解放 | JIT auto-evict設定を確認、Spec Decテスト前はOFFに |
| チェックポイント破損で--resume失敗 | 書き込み途中でクラッシュ | 最新版mcp_runner.pyはアトミック書き込み対応済み |

## 10. 推奨パラメータ

### MCP方式（Stateful API）

| パラメータ | 推奨値 | 備考 |
|-----------|--------|------|
| temperature | 0.0 | 決定論的動作 |
| context_length | 8000 | 16000は安定性低下（LM Studio v0.4.xにコンテキスト長管理バグあり） |
| max_output_tokens | 4096 | 未設定は無限ループリスク |
| reasoning | `"off"` | thinking暴走防止。§7.4参照 |

### FC方式（OpenAI互換API）

| パラメータ | 推奨値 | 備考 |
|-----------|--------|------|
| temperature | 0.0 | 決定論的動作 |
| max_tokens | 4096 | 未設定は無限ループリスク |

### Qwen3.5公式推奨（Instructモード）

| パラメータ | 値 |
|-----------|-----|
| temperature | 0.7 |
| top_p | 0.8 |
| top_k | 20 |
| presence_penalty | 1.5 |

## 11. セキュリティ

- **Read-only**: ツールはファイル読み取りのみ。書き込み操作は一切提供しない
- **パス制限**: FC方式は`allowed_paths`、MCP方式はmcp.json許可ディレクトリ
- **BLOCKED_PATTERNS**: `.env`, `credentials`, `.secret`, `id_rsa`, `id_ed25519` を含むパスは拒否
- **バイナリ拒否**: バイナリファイルの読み取りは拒否
- **結果上限**: search_files 100件、grep_content 50件で打ち切り
- **認証**: MCP方式はAPIトークン必須。トークンにはツール別権限設定可能
- **TLS検証**: `ssl.create_default_context()`による証明書検証。http+token使用時は警告を出力
- **入力バリデーション**: タスクJSON読み込み時にprompt/max_turns/integrations等の型・値域を検証
- **URLスキーム制限**: `base_url`はhttp/httpsのみ許可（file://やftp://はブロック）
- **レスポンスサイズ制限**: APIレスポンスは10MBまで（OOM防止）
- **エラーメッセージ制限**: APIエラー本文はverboseモード以外100文字に制限（情報漏洩防止）
- **チェックポイント安全性**: アトミック書き込み（一時ファイル→rename）で破損防止

## 12. Speculative Decoding（非対応）

**Qwen3.5-9Bでは外部ドラフトモデルによるSpeculative Decodingは使用不可。**

### 原因

Qwen3.5ファミリーはマルチモーダル（Vision-Language）モデルとして設計されており、llama.cppがマルチモーダルモデルのSpeculative Decodingを明示的にブロックしている。

```
Failed to load draft model. Speculative decoding is not supported for multimodal models in llama.cpp server
```

### 現状と今後

| 選択肢 | 状況 | 詳細 |
|--------|:----:|------|
| Spec Decなしで運用 | **現在** | ~30 tok/s、実用上十分 |
| MTP内蔵Spec Dec | WIP | llama.cpp PR #20700。9B Q4_K_Mで28.1 tok/s、82%受理率 |
| テキストオンリーモデルに変更 | 可能 | DeepSeek-R1-Distill-Qwen系等 |

### JIT auto-evict問題

`draft_model`パラメータを指定してリクエストを送ると、JIT auto-evictがメインモデルをアンロードし、ドラフトモデルのロードもマルチモーダル非対応で失敗 → **両モデルがアンロード状態**になる。Spec Decをテストする際はJIT auto-evictをOFFにすること。
