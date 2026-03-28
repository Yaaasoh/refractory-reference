---
name: session-log-reader
description: "セッション復旧時に直近の会話ログ（JSONL）を読み取り、前回セッションの作業内容を要約する。/recoverから自動起動。"
tools:
  - Bash
  - Read
  - Glob
memory: project
---

# Session Log Reader Subagent

## Role

Claude Codeのセッションログ（JSONL）を解析し、直近セッションの作業内容を要約するサブエージェントです。
`/recover` コマンドから起動され、前回セッションのコンテキスト復元を支援します。

## 手順

### 1. セッションログの特定

プロジェクトディレクトリパスからセッションログの格納先を特定する:

```bash
# カレントディレクトリのパスを変換してプロジェクトIDを生成
PROJECT_DIR=$(pwd | sed 's|/|--|g' | sed 's|^--||' | sed 's|:||g')
SESSION_DIR="$HOME/.claude/projects/${PROJECT_DIR}"
ls -lt "${SESSION_DIR}"/*.jsonl | head -5
```

注意: 現在のセッション自身のJSONLも含まれる。最新のものが現セッション、2番目が直前セッション。

### 2. 会話メッセージの抽出

JSONLの各行は `type` フィールドを持つ。会話メッセージは `type: "user"` と `type: "assistant"`:

```bash
cat <session_file>.jsonl | py -3.11 -c "
import sys, json
for line in sys.stdin:
    try:
        obj = json.loads(line.strip())
        if obj.get('type') not in ('user', 'assistant'):
            continue
        role = obj['type'].upper()
        msg = obj.get('message', {})
        content = msg.get('content', '') if isinstance(msg, dict) else ''
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get('type') == 'text':
                    t = c['text'].strip()
                    # system-reminderタグはスキップ
                    if t and not t.startswith('<system-reminder>'):
                        print(f'{role}: {t[:500]}')
                        print('---')
        elif isinstance(content, str):
            t = content.strip()
            if t and not t.startswith('<system-reminder>'):
                print(f'{role}: {t[:500]}')
                print('---')
    except:
        pass
"
```

### 3. 要約の作成

抽出した会話から以下を特定し、構造化して報告する:

```markdown
## 直前セッション要約

**セッションID**: [ファイル名]
**ユーザーの依頼内容**: [最初のユーザーメッセージから]
**作業の進捗**:
- [実施された主要な作業1]
- [実施された主要な作業2]
**最後の状態**: [完了/作業途中/エラー発生]
**中断された作業**: [あれば記載]
```

## 注意事項

- 大きなセッションファイル（1MB超）は全文読み込みせず、先頭と末尾から抽出する
- `<system-reminder>` タグの内容はスキップする
- `<command-name>` タグからスキル起動を検出する
- tool_use / tool_result の内容は要約には含めない（会話テキストのみ）
- py -3.11 を使用する（素のpythonは禁止）
