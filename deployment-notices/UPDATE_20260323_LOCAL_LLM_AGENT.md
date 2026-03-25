# ローカルLLM調査エージェント導入

**日付**: 2026-03-23
**対象**: GPU搭載マシンのリポジトリ

## 概要

ローカルLLM（LM Studio + Qwen3.5-9B）でファイル調査タスクをバックグラウンド実行する機能が利用可能になりました。

## 導入方法

```bash
# deploy.sh に -l フラグを追加
deploy.sh -t -l /path/to/target-repo
```

配置先: `.claude/scripts/local-llm-tools/`

## 前提条件

- NVIDIA GPU（VRAM 8GB以上）
- LM Studio v0.4.0+
- Qwen3.5-9B モデル

## 使い方

Claude Code内:
```
/local-investigate 05-projectsの構造を調査してください
```

直接実行:
```bash
cd .claude/scripts/local-llm-tools
py -3.11 agent_runner.py --task tasks/example_task.json
```

## CLAUDE.mdへの追記推奨

GPUマシンで利用する場合、CLAUDE.mdに以下を追記:

```markdown
## ローカルLLM調査

- `/local-investigate` でローカルLLM（Qwen3.5-9B）によるファイル調査が可能
- 詳細: `.claude/docs/guides/local-llm-setup-guide.md`
- GPU排他利用: WhisperX/YomiToku稼働中は使用不可
```

## 関連ドキュメント

- `.claude/docs/guides/local-llm-setup-guide.md` — セットアップガイド
