---
description: リポジトリ調査レポートを自動生成（LM Studio必要）
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
argument-hint: "[--all | --reset | <repo-name>]"
---

# /survey-repo コマンド

## 引数

$ARGUMENTS

## 前提条件

1. LM Studioが起動し、qwen3.5-9bがロード済みであること
2. APIトークンが `~/.lmstudio/api_token.txt` に保存されていること

前提条件を確認:

```bash
curl -s http://localhost:1234/v1/models | py -3.11 -c "import sys,json; models=json.load(sys.stdin)['data']; print('\n'.join(m['id'] for m in models))"
cat ~/.lmstudio/api_token.txt > /dev/null 2>&1 && echo "Token: OK" || echo "Token: MISSING"
```

## 実行

作業ディレクトリ: `work/repo-survey-system`

### 単体調査（1リポ）

```bash
cd work/repo-survey-system && py -3.11 scripts/run_survey.py --repo <repo-name> --verbose
```

### 全件再生成（25リポ、約30-40分）

```bash
cd work/repo-survey-system && py -3.11 scripts/run_survey.py --reset --verbose
```

### Phase Aのみ（LLM不要、raw data収集のみ）

```bash
cd work/repo-survey-system && py -3.11 scripts/run_survey.py --phase-a-only --verbose
```

### ドライラン

```bash
cd work/repo-survey-system && py -3.11 scripts/run_survey.py --dry-run
```

## 出力先

- Raw data: `work/repo-survey-system/raw_data/<repo>.txt`
- レポート: `work/repo-surveys/<repo>.md`
- 状態: `work/repo-survey-system/state.json`
- ログ: `work/repo-survey-system/logs/survey_*.log`

## 注意事項

- 3リポごとにKVキャッシュを解放するため `lms unload --all` が自動実行される
- GPUを占有するため、WhisperX/YomiTokuとの同時実行は不可
- トークンは `~/.lmstudio/api_token.txt` から自動読み取り（`--token` 省略可）

## 参照

- `work/repo-survey-system/REVIEW_AND_NEXT_STEPS.md` — 設計・改善計画
- `work/repo-survey-system/DESIGN_DOCUMENT.md` — 設計根拠
- `shared/docs/guides/local-llm-setup-guide.md` — LM Studioセットアップ
