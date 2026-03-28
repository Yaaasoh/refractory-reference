---
description: ローカルLLM（LM Studio）でバックグラウンドファイル調査を実行
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
argument-hint: "タスクファイルパス(.json) or 調査指示（自然言語）"
---

# ローカルLLM調査

## 調査対象

$ARGUMENTS

---

## 手順

### 1. LM Studio接続確認

```bash
curl -s http://localhost:1234/v1/models | py -3.11 -c "import sys,json; d=json.load(sys.stdin); print('Models:', [m['id'] for m in d.get('data',[])])"
```

接続できない場合:
1. LM Studioが起動しているか確認
2. `~/.lmstudio/bin/lms server start` でサーバー起動
3. `~/.lmstudio/bin/lms load "qwen/qwen3.5-9b" --gpu=max --yes` でモデルロード

### 2. タスク準備

`$ARGUMENTS` が `.json` で終わる場合、そのファイルをタスク定義として使用。

そうでない場合、以下のJSONを `.claude/scripts/local-llm-tools/tasks/` に生成:

```json
{
  "name": "local-investigate-[timestamp]",
  "system_prompt": "/no_think\nYou are a file system investigation agent. Use the provided tools to investigate files and directories, then produce a comprehensive Markdown report. Write in Japanese.",
  "prompt": "[ユーザーの調査指示]",
  "allowed_paths": ["[カレントリポジトリの絶対パス]"],
  "max_turns": 15,
  "model": "qwen/qwen3.5-9b"
}
```

### 3. GPU事前チェック

```bash
cd .claude/scripts/local-llm-tools && py -3.11 gpu_guard.py --check
```

FAILの場合は理由を報告して中断。

### 4. 実行

```bash
cd .claude/scripts/local-llm-tools && py -3.11 agent_runner.py --task [タスクファイルパス] --verbose
```

バックグラウンド実行する場合は `run_in_background` を使用。

### 5. 結果確認

実行完了後、outputディレクトリのレポートファイルを読み取り、要約を報告。

```bash
ls -t .claude/scripts/local-llm-tools/output/*.md | head -1
```

GPU watchdogログも確認:
```bash
ls -t .claude/scripts/local-llm-tools/logs/gpu/ | head -3
```

---

## 注意事項

- LM Studioが起動していない場合は手順1で案内して終了
- GPU TDRが発生した場合: `py -3.11 gpu_guard.py --analyze` で事後分析
- WhisperX/YomiToku稼働中はGPU VRAMが不足するため、pre-flight checkで拒否される
- 結果レポートはローカルLLM（Qwen3.5-9B）が生成したものであり、精度はClaude Codeに劣る。重要な判断には人間レビューが必要
