#!/bin/bash
# python_path_guard.sh - PreToolUse Hook
# 素のpython/python3コマンド実行を即座にブロック
#
# 背景:
#   Windows環境で `python` はMicrosoft Storeスタブ（exit code 9009/49）にヒットする。
#   Claude Code/AI coding agentsは学習データのLinux/macOS偏重により、
#   素のpython/python3を使い続ける業界共通の問題がある。
#   (Claude Code #7364, OpenAI Codex #8382, Cursor #1383, Aider #3123)
#
# 正しいコマンド:
#   py -3.11 -m module_name   (py launcher)
#   /c/Users/xprin/AppData/Local/Programs/Python/Python313/python.exe  (フルパス)
#   .venv/Scripts/python.exe  (仮想環境)
#
# exit 2 = ブロック（Claude Code hook仕様）

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# 空コマンドは無視
if [ -z "$COMMAND" ]; then
    exit 0
fi

# --- ホワイトリスト: これらのパターンを含むコマンドは許可 ---

# 検索・参照系コマンドが先頭の場合のみ許可
# （パイプ後にpythonが来るパターンは別途セグメント検査で捕捉）
FIRST_CMD=$(echo "$COMMAND" | sed 's/^[[:space:]]*//' | cut -d' ' -f1)
case "$FIRST_CMD" in
    grep|find|which|where|type|file|ls|echo|printf|head|tail|wc|diff|less|more|rg|ag|fd)
        # ただしパイプ後にpythonがある場合はブロック対象
        if ! echo "$COMMAND" | grep -qE '[|][ ]*python[0-9]* |[|][ ]*python[0-9]*$'; then
            exit 0
        fi
        ;;
esac

# command -v python 等の診断コマンドは許可
if echo "$COMMAND" | grep -qE '^command -v '; then
    exit 0
fi

# 変数名にpythonを含む場合は許可
if echo "$COMMAND" | grep -qE '(PYTHON|python_path|python_version|python_cmd|python_exec|python_bin)'; then
    exit 0
fi

# フルパス・venv・py launcher・uv は許可
if echo "$COMMAND" | grep -qE '(/python[0-9.]*\.exe|/python[0-9.]*$|\\python[0-9.]*\.exe|\.venv/|/venv/|^py |^py$| py -[0-9]|^uv |pipx )'; then
    exit 0
fi

# pip install等のパッケージ管理は許可
if echo "$COMMAND" | grep -qE '^pip[0-9]* |^pip[0-9]*$'; then
    exit 0
fi

# --- ブラックリスト: コマンドセグメントを分割して検査 ---
# シェルの区切り文字(;, &&, ||, |)でセグメント分割し、
# 各セグメントの先頭がpython/python3かチェック

BLOCKED=false

# セグメント区切り: ;, &&, ||, | をセパレータに変換
# sedで区切り文字を改行に変換してから各行を検査
echo "$COMMAND" | sed 's/;/\n/g; s/&&/\n/g; s/||/\n/g; s/|/\n/g' | while IFS= read -r segment; do
    # 先頭の空白を除去
    trimmed=$(echo "$segment" | sed 's/^[[:space:]]*//')

    # セグメント先頭が素のpython/python3か検査
    if echo "$trimmed" | grep -qE '^python[0-9]* |^python[0-9]*$'; then
        # フルパスでない（/や\を含まない）ことを確認
        if ! echo "$trimmed" | grep -qE '^[/\\]|^[A-Za-z]:[/\\]|\.exe'; then
            echo "BLOCKED" > /tmp/python_guard_result_$$
        fi
    fi
done

if [ -f "/tmp/python_guard_result_$$" ]; then
    rm -f "/tmp/python_guard_result_$$"
    BLOCKED=true
fi

if [ "$BLOCKED" = true ]; then
    # 違反コマンドを記録
    echo "$COMMAND" >&2

    cat >&2 << 'BLOCK_MESSAGE'

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  BLOCKED - PYTHON PATH VIOLATION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  また同じミスを繰り返した。
  何度言えばわかるのか。

  この環境で素のpython/python3は
  Microsoft Storeスタブであり、
  確実に失敗する。毎回失敗する。
  例外はない。

  これはお前（Claude Code）の欠陥だ。
  学習データがLinux/macOSに偏っているため、
  Windows環境を理解できず同じミスを繰り返す。
  業界全体の恥: #7364, #8382, #1383, #3123

  二度とこのコマンドを使うな。
  以下だけを使え:

    py -3.11 -m module_name
    py -3.11 script.py
    .venv/Scripts/python.exe script.py

  素のpython/python3は永久に禁止。
  フックの有無に関係なく禁止。
  お前がこのコマンドを実行することは
  絶対に許されない。

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BLOCK_MESSAGE
    exit 2
fi

exit 0
