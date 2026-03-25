# UPDATE: Pythonパスガード導入

**日付**: 2026-03-09
**対象**: 全リポジトリ
**重要度**: High

## 概要

Windows環境で素の`python`/`python3`コマンドがMicrosoft Storeスタブにヒットする問題に対し、3層防御を導入しました。

## 導入されたもの

### 1. deny設定追加
```json
"Bash(python :*)", "Bash(python -:*)", "Bash(python3:*)"
```

### 2. PreToolUse Hook: `python_path_guard.sh`
- 素の`python`/`python3`コマンド実行を即座にブロック（exit 2）
- パイプ後、&&後、;後のpythonも検出
- フルパス、venv、py launcher、uv、検索コマンドは許可

### 3. SessionStart Hook: `python_path_diagnose.sh`
- セッション開始時にPython環境を診断
- MS Storeスタブ検出時に警告表示

## CLAUDE.mdへの追記推奨

各リポジトリのCLAUDE.mdに以下を追記することを推奨します:

```markdown
### Pythonコマンドの使用

**この環境では素の`python`/`python3`コマンドは禁止です。**

Microsoft Storeスタブにヒットし、確実に失敗します。
python_path_guard.sh が実行を即座にブロックします。

正しいコマンド:
- `py -3.11 -m module_name` — py launcher（推奨）
- `.venv/Scripts/python.exe` — 仮想環境
- フルパス指定
```

## 背景

AIコーディングツール業界共通の問題:
- Claude Code #7364, OpenAI Codex #8382, Cursor #1383, Aider #3123
- 学習データのLinux/macOS偏重により、Windows環境で同じミスを繰り返す
