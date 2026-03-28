# 共有コンポーネント展開ガイド

**作成日**: 2026-01-02
**更新日**: 2026-01-05
**バージョン**: 1.1.0

---

## 概要

prompt-patternsの共有コンポーネント（hooks、commands、skills、agents）を
対象リポジトリに展開するためのガイド。

---

## 展開対象コンポーネント

### Agents（3件）【2026-01-05追加】

| エージェント | 用途 | モデル | 公式推奨 |
|-------------|------|--------|:--------:|
| `code-reviewer.md` | コードレビュー（品質・セキュリティ） | Haiku | ✅ |
| `test-debug-agent.md` | テスト実行・デバッグ | inherit | ✅ |
| `web-researcher.md` | Web調査（100%保存義務） | Haiku | - |

### Commands（6件）

| コマンド | 機能 | ファイル |
|---------|------|---------|
| `/checkpoint` | 30分ルール+80%閾値チェック | checkpoint.md |
| `/investigate` | 調査セッション（WebSearch 100%保存） | investigate.md |
| `/safety-check` | 作業前安全確認 | safety-check.md |
| `/scrutinize` | 2フェーズ型精査セッション | scrutinize.md |
| `/scrutinize-verify` | 精査事後検証 | scrutinize-verify.md |
| `/suggest-claude-md` | CLAUDE.md更新提案 | suggest-claude-md.md |

### Skills（3件）

| スキル | 機能 | ディレクトリ |
|--------|------|-------------|
| `verification-enforcer` | 4-Level検証強制 | verification-enforcer/ |
| `comparative-analyzer` | ギャップ・比較分析 | comparative-analyzer/ |
| `consistency-checker` | 整合性・完全性チェック | consistency-checker/ |

### Hooks（7件）

| Hook | トリガー | 機能 |
|------|---------|------|
| `block_destructive.sh` | PreToolUse:Bash | 破壊的コマンドブロック |
| `check_encoding.sh` | PostToolUse:Write/Edit | エンコーディングチェック |
| `check_file_size.sh` | PreToolUse:Read | 大規模ファイルブロック |
| `check_public_repo.sh` | SessionStart | 公開リポジトリ警告 |
| `check_uncommitted.sh` | Stop | 未コミット警告 |
| `session_start.sh` | SessionStart | セッション開始メッセージ |
| `session_start.sh.template` | - | 動的生成用テンプレート |

---

## 展開方法

### 方法A: deploy.sh使用（推奨）

```bash
# prompt-patternsディレクトリで実行

# 技術系プロジェクト用パッケージ
./scripts/deploy.sh -t /path/to/target-repo

# プロンプト作成プロジェクト用パッケージ
./scripts/deploy.sh -p /path/to/target-repo

# 最小構成（共有コンポーネントのみ）
./scripts/deploy.sh -m /path/to/target-repo

# 上書きモード（既存ファイルを更新）
./scripts/deploy.sh -t -f /path/to/target-repo

# ドライラン（実行内容確認のみ）
./scripts/deploy.sh -t -n /path/to/target-repo
```

**deploy.shが展開するもの**:
- `.claude/hooks/` - 全7フック
- `.claude/commands/` - 全6コマンド
- `.claude/skills/` - 全3スキル
- `.claude/agents/` - 全3エージェント【2026-01-05追加】
- `.claude/rules/` - 共有ルール
- `.claude/docs/` - 共有ドキュメント
- `.claude/settings.json` - フック設定
- `CLAUDE.md.template` - CLAUDE.md雛形

### 方法B: 手動コピー

既にClaude Code環境が設定されているリポジトリに
特定のコンポーネントのみ追加する場合。

#### コマンドの追加

```bash
# 特定のコマンドをコピー
cp prompt-patterns/shared/commands/scrutinize.md /target-repo/.claude/commands/
cp prompt-patterns/shared/commands/scrutinize-verify.md /target-repo/.claude/commands/
```

#### スキルの追加

```bash
# スキルディレクトリごとコピー
cp -r prompt-patterns/shared/skills/comparative-analyzer /target-repo/.claude/skills/
cp -r prompt-patterns/shared/skills/consistency-checker /target-repo/.claude/skills/
```

#### フックの追加

```bash
# フックをコピー
cp prompt-patterns/shared/hooks/check_public_repo.sh /target-repo/.claude/hooks/
chmod +x /target-repo/.claude/hooks/check_public_repo.sh

# settings.jsonにフック登録を追加（手動編集が必要）
```

#### エージェントの追加【2026-01-05追加】

```bash
# エージェントをコピー（プロジェクトレベル）
cp prompt-patterns/shared/agents/code-reviewer.md /target-repo/.claude/agents/
cp prompt-patterns/shared/agents/test-debug-agent.md /target-repo/.claude/agents/

# または全エージェント
cp prompt-patterns/shared/agents/*.md /target-repo/.claude/agents/
# ※ README.mdは除外することを推奨
```

---

## ユーザーレベル設定（全プロジェクト共通）

### ~/.claude/settings.json

WebSearch・WebFetch・MCPの自動承認設定:

```json
{
  "permissions": {
    "allow": [
      "WebSearch",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:developer.chrome.com)",
      "WebFetch(domain:platform.claude.com)",
      "WebFetch(domain:docs.claude.com)",
      "WebFetch(domain:code.claude.com)",
      "WebFetch(domain:qiita.com)",
      "mcp__github__get_*",
      "mcp__chrome-devtools__list_*",
      "mcp__chrome-devtools__take_screenshot",
      "mcp__chrome-devtools__list_console_messages"
    ]
  }
}
```

### ~/.claude/agents/

全プロジェクトで使用するエージェント:

```bash
# ユーザーレベルにエージェントを配置
mkdir -p ~/.claude/agents
cp prompt-patterns/shared/agents/code-reviewer.md ~/.claude/agents/
cp prompt-patterns/shared/agents/test-debug-agent.md ~/.claude/agents/
```

---

## settings.json設定（プロジェクトレベル）

### 完全版settings.json

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(rm -r :*)",
      "Bash(git clean -fd:*)",
      "Bash(git reset --hard:*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block_destructive.sh"
          }
        ]
      },
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_file_size.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_encoding.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_public_repo.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/session_start.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check_uncommitted.sh"
          }
        ]
      }
    ]
  }
}
```

### スキルについて

スキルは`.claude/skills/`ディレクトリ配下のSKILL.mdファイルから
**自動検出**されます。settings.jsonへの登録は不要です。

スキルが正しく検出されるための要件:
1. `.claude/skills/<skill-name>/SKILL.md` の形式で配置
2. SKILL.mdに正しいフロントマターがあること:

```yaml
---
name: skill-name
description: スキルの説明文
---
```

---

## 展開前チェックリスト

### 対象リポジトリの確認

- [ ] 対象がプライベートリポジトリであることを確認
- [ ] `.claude/`ディレクトリの現状を確認
- [ ] 既存のhooks/commands/skillsとの競合をチェック

### 展開後の確認

- [ ] `claude` コマンドでセッション開始
- [ ] SessionStartフックが動作することを確認
- [ ] `/checkpoint` などのコマンドが認識されることを確認
- [ ] スキルが認識されることを確認（`/skill` または description発火）

---

## トラブルシューティング

### コマンドが認識されない

1. `.claude/commands/`にファイルが存在するか確認
2. ファイル名が正しいか確認（`command-name.md`形式）
3. Claudeセッションを再起動

### スキルが発火しない

1. `.claude/skills/<name>/SKILL.md`の形式で配置されているか確認
2. SKILL.mdのフロントマターが正しいか確認
3. descriptionのキーワードが発話に含まれているか確認

### フックがエラーになる

1. シェルスクリプトに実行権限があるか確認: `chmod +x *.sh`
2. スクリプトのエンコーディングがUTF-8 (no BOM)か確認
3. 改行コードがLFか確認

---

## 展開対象リポジトリ一覧

> **ステータス**: 2026-01-02 全13リポジトリ展開完了（refractory-reference除外）

| リポジトリ | 展開優先度 | 状態 | コミット |
|-----------|:----------:|:----:|---------|
| vibration-diagnosis-prototype | 高 | ✅完了 | 88971b0 |
| tech-articles | 高 | ✅完了 | fc4178c |
| jsbsim-flightgear-guide | 高 | ✅完了 | e3c2553 |
| tech-v2-research-portfolio | 中 | ✅完了 | d4e0b05 |
| research-workspace | 中 | ✅完了 | 519fcd3 |
| tech-research-portfolio | 中 | ✅完了 | c3a2450c |
| pst_dev_docs | 低 | ✅完了 | f4a450d |
| gdrive-materials-archive | 低 | ✅完了 | d5048ec |
| account-management | 低 | ✅完了 | abc8fbd |
| space-fund-curation | 低 | ✅完了 | 4ed169e |
| flying-robot-rule-coding-private | 低 | ✅完了 | 9c39048 |
| jsbsim-flight-sim-private | 低 | ✅完了 | 9353462 |
| fixed-wing-knowledge | 低 | ✅完了 | e62a156 |

**除外（公開リポジトリ）**:
- jsbsim-xml-generator
- refractory-reference（INC-012: 2026-01-05 46ファイル汚染発覚、要クリーンアップ）

---

## 関連ドキュメント

- `scripts/deploy.sh` - デプロイスクリプト本体
- `shared/README.md` - 共有コンポーネント索引
- `work/TASK_BACKLOG.md` §9.4 - 展開タスク詳細
