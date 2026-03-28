# /recover - 異常終了後のセッション復旧

セッションが異常終了（クラッシュ、exit code 1/3等）した後の復旧を支援します。

**設計原則**: 読み取り専用。承認を最小化する（Step 1は1回のBash実行のみ）。

---

## Step 1: 直近セッション一覧の表示（1コマンド）

**git status等は後回し。まずセッション一覧を見せることが最優先。**

```bash
py -3.11 shared/scripts/session_list.py --auto 8
```

スクリプトが見つからない場合のフォールバック（deploy先リポジトリ等）:
```bash
ls -lt "$HOME/.claude/projects/$(pwd | sed 's|[/:\\]|-|g' | sed 's|^-||')"/*.jsonl 2>/dev/null | head -8 | nl -ba
```

結果を見て、ユーザーに「どのセッションの詳細を見ますか？」と聞く。
**#1は現在のセッション自身。通常は#2以降が復旧対象。**

---

## Step 2: 選択されたセッションの詳細表示

ユーザーが選んだセッションのJSONLを読み取り、会話の流れを要約する。
先頭（作業開始）と末尾（最後の状態）の両方を読む:

```bash
# <SELECTED_FILE> をユーザーが選んだファイルパスに置換
echo "=== 冒頭 ===" && head -300 <SELECTED_FILE> | py -3.11 -c "
import sys, json
count = 0
for line in sys.stdin:
    if count >= 5: break
    try:
        obj = json.loads(line.strip())
        if obj.get('type') not in ('user', 'assistant'): continue
        role = obj['type'].upper()
        msg = obj.get('message', {})
        content = msg.get('content', '') if isinstance(msg, dict) else ''
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get('type') == 'text':
                    t = c['text'].strip()
                    if t and not t.startswith('<'):
                        print(f'{role}: {t[:300]}')
                        print('---')
                        count += 1
                        break
        elif isinstance(content, str):
            t = content.strip()
            if t and not t.startswith('<'):
                print(f'{role}: {t[:300]}')
                print('---')
                count += 1
    except: pass
" && echo "" && echo "=== 末尾 ===" && tail -300 <SELECTED_FILE> | py -3.11 -c "
import sys, json
msgs = []
for line in sys.stdin:
    try:
        obj = json.loads(line.strip())
        if obj.get('type') not in ('user', 'assistant'): continue
        role = obj['type'].upper()
        msg = obj.get('message', {})
        content = msg.get('content', '') if isinstance(msg, dict) else ''
        text = ''
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get('type') == 'text':
                    t = c['text'].strip()
                    if t and not t.startswith('<'):
                        text = t
                        break
        elif isinstance(content, str):
            t = content.strip()
            if t and not t.startswith('<'):
                text = t
        if text:
            msgs.append((role, text))
    except: pass
for role, text in msgs[-5:]:
    print(f'{role}: {text[:300]}')
    print('---')
"
```

会話内容を読み取ったら、以下を簡潔に報告する:

```markdown
## セッション復旧報告

**セッションID**: [ファイル名]
**作業内容**: [何をしていたか]
**最後の状態**: [完了/途中/エラー]
**次にやること**: [推奨アクション]
```

---

## Step 3: 補足情報（必要な場合のみ）

ユーザーが求めた場合にのみ、以下を追加確認する:

- `git status && git diff --stat` — 未コミット変更
- `git log --oneline -5` — 直近コミット
- TaskListツール — 未完了タスク
- `work/reports/` — 作業報告書

**ユーザーが求めない限り、Step 2の報告で完了とする。**

---

## 参照

- `claude --continue` — 直前セッションの継続（CLI起動時）
- `claude --resume` — セッション選択して再開（CLI起動時）
- `/rewind` — ファイル変更の巻き戻し
