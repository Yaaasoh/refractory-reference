# UPDATE: Plan Mode 計画品質ルール導入

**日付**: 2026-03-14
**種別**: 新規ルール・フック追加
**対象**: 全リポジトリ

## 変更内容

### 1. Plan Modeルール新規追加
- `.claude/rules/plan-mode.md` — 計画品質基準
- 計画の最小要件:「ファイルパス + 変更内容 + 根拠（読んだ事実）」
- 詳細度3段階（Simple/Medium/Complex）

### 2. Plan Modeリマインダーフック新規追加
- `.claude/hooks/plan_mode_reminder.sh` — 大規模作業検出→Plan Mode推奨
- UserPromptSubmitイベントで発火

### 3. auto_activate_skills.sh改修
- デッドリンク4スキル（code-quality-enforcer, deployment-verifier, purpose-driven-impl, root-cause-analyzer）への参照を除去
- 95行→59行に削減

## 既存リポジトリでの手動設定

deploy.shは既存ファイルをスキップするため、以下2点を手動で対応してください。

### A. settings.jsonへのhook登録

`hooks.UserPromptSubmit[0].hooks` 配列に以下を追加:

```json
{
  "type": "command",
  "command": "bash .claude/hooks/plan_mode_reminder.sh",
  "timeout": 5
}
```

### B. auto_activate_skills.shの更新

既存の `.claude/hooks/auto_activate_skills.sh` をprompt-patternsの最新版で上書き:

```bash
cp /c/Users/xprin/github/prompt-patterns/shared/hooks/auto_activate_skills.sh .claude/hooks/auto_activate_skills.sh
```

変更内容: 存在しないスキル4件（code-quality-enforcer, deployment-verifier, purpose-driven-impl, root-cause-analyzer）への誘導ブロックを削除。これらのスキルは実装されておらず、参照先が存在しないデッドリンクでした。

## CLAUDE.md追記推奨

```markdown
### Plan Mode ワークフロー
大規模作業（3ファイル以上の変更）はPlan Modeで探索→計画を行う。
計画の最小要件:「ファイルパス + 変更内容 + 根拠（読んだ事実）」
詳細: .claude/rules/plan-mode.md
```
