# UPDATE: 引用配置チェック2層hook追加 (2026-04-01)

## 変更概要

tech-articles 849件是正の知見を汎用化し、引用配置チェックの2層hookを追加しました。

## 追加されたhook

### 1. check_citation_placement.sh (PostToolUse Write|Edit)
- .qmd/.Rmd ファイルのWrite/Edit時に自動実行
- P1（見出し内引用）とP2（Bold小見出し内引用）を検出
- **警告のみ**（ブロックしない）
- .qmd/.Rmd 以外のファイルは自動スキップ

### 2. preflight_citation_gate.sh (PreToolUse Bash)
- `quarto render` / `quarto preview` 実行時に自動実行
- 引用配置違反があれば**ブロック**
- if条件: `Bash(quarto render*)|Bash(quarto preview*)`

## 影響

- .qmdファイルを持たないリポジトリ: 影響なし（スクリプトが自動スキップ）
- .qmdファイルを持つリポジトリ: Write時に警告、quarto render前にブロック

## スタンドアロン実行

手動でディレクトリをスキャンすることも可能:
```bash
bash .claude/hooks/check_citation_placement.sh --scan content/
bash .claude/hooks/check_citation_placement.sh --file article.qmd
```
