#!/bin/bash
# python_path_diagnose.sh - SessionStart Hook
# セッション開始時にPython環境を診断し、問題があれば警告

echo ""
echo "【Python環境診断】"

# py launcher の存在確認
if command -v py >/dev/null 2>&1; then
    PY_VERSION=$(py --version 2>&1)
    echo "  py launcher: OK ($PY_VERSION)"
else
    echo "  py launcher: 未検出 — py launcherをインストールしてください"
fi

# py -3.11 の確認
if py -3.11 --version >/dev/null 2>&1; then
    PY311=$(py -3.11 --version 2>&1)
    echo "  py -3.11:    OK ($PY311)"
else
    echo "  py -3.11:    未検出"
fi

# py -3.13 の確認
if py -3.13 --version >/dev/null 2>&1; then
    PY313=$(py -3.13 --version 2>&1)
    echo "  py -3.13:    OK ($PY313)"
else
    echo "  py -3.13:    未検出"
fi

# 素のpythonの解決先を診断
PYTHON_PATH=$(command -v python 2>/dev/null || true)
if [ -n "$PYTHON_PATH" ]; then
    if echo "$PYTHON_PATH" | grep -qi "WindowsApps"; then
        echo "  python:      MS Storeスタブ ($PYTHON_PATH)"
        echo ""
        echo "  *** 素のpythonコマンドはMS Storeスタブです ***"
        echo "  *** 必ず py -3.11 またはフルパスを使用してください ***"
    else
        PYTHON_VER=$(python --version 2>&1 || echo "取得失敗")
        echo "  python:      $PYTHON_PATH ($PYTHON_VER)"
    fi
else
    echo "  python:      未検出"
fi

# python3の解決先を診断
PYTHON3_PATH=$(command -v python3 2>/dev/null || true)
if [ -n "$PYTHON3_PATH" ]; then
    if echo "$PYTHON3_PATH" | grep -qi "WindowsApps"; then
        echo "  python3:     MS Storeスタブ ($PYTHON3_PATH)"
    else
        PYTHON3_VER=$(python3 --version 2>&1 || echo "取得失敗")
        echo "  python3:     $PYTHON3_PATH ($PYTHON3_VER)"
    fi
else
    echo "  python3:     未検出（Windowsでは正常）"
fi

# venv の確認
if [ -f ".venv/Scripts/python.exe" ]; then
    VENV_VER=$(.venv/Scripts/python.exe --version 2>&1)
    echo "  .venv:       OK ($VENV_VER)"
elif [ -f "venv/Scripts/python.exe" ]; then
    VENV_VER=$(venv/Scripts/python.exe --version 2>&1)
    echo "  venv:        OK ($VENV_VER)"
else
    echo "  venv:        未検出"
fi

echo ""
echo "  python_path_guard.sh が素のpython/python3の実行をブロックします。"
echo ""
