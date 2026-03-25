# アップデート通知: セッション安定化・ベストプラクティス更新

**日付**: 2026-03-06
**対象**: 全展開対象リポジトリ（22件）
**所要時間**: 5分

---

## 概要

Claude Code v2.1.47以降でVSCodeターミナルのセッション異常終了が頻発している問題に対応し、以下を全リポジトリに展開しました。

---

## 1. 自動展開済み（対応不要）

以下はdeploy.sh経由で全リポジトリに配置・commit・push済みです。

### /recover コマンド
- **配置先**: `.claude/commands/recover.md`
- **用途**: セッション異常終了後の標準復旧ワークフロー
- **使い方**: 新セッション起動後に `/recover` を実行

### ccusage statusline
- **配置先**: `~/.claude/settings.json`（グローバル設定）
- **効果**: 全リポジトリで自動的にコスト・バーンレート・コンテキスト使用率を表示
- **対応不要**: グローバル設定のため個別対応は不要

---

## 2. 各リポジトリのCLAUDE.mdに追記推奨

以下の内容を、各リポジトリのCLAUDE.mdに追記することを推奨します。

### 追記内容テンプレート

```markdown
### セッション安定化ガイド

**クラッシュ防止策**:
1. コンテキスト使用率70%で `/compact` を実行
2. タスク間で `/clear` してセッションをリセット
3. 大きなタスクはサブエージェント（Agentツール）に委譲
4. `/resume`でセッション再開時、大きなセッション（数百MB）は避ける

**異常終了後の復旧**:
- `/recover` — 復旧ワークフロー（未コミット変更・タスク状態・コンテキスト復元）
- `claude --continue` — 直前セッション継続（CLI起動時）
- `claude --resume` — セッション選択して再開（CLI起動時）
- `/rewind` — ファイル変更の巻き戻し（コード/会話/両方の3モード）
```

### 追記場所

CLAUDE.mdの冒頭付近（CRITICAL セクションの直後、またはリポジトリ概要セクションの前）に追記。

---

## 3. 2026年1-3月 ベストプラクティス更新（参考情報）

以下は各リポジトリでの作業時に意識すべき運用改善です。CLAUDE.mdへの追記は任意。

| 項目 | 内容 |
|------|------|
| タスクごとに新セッション | `/clear`でタスク間をリセット |
| 70%でcompact | コンテキスト使用率70%で`/compact`推奨 |
| サブエージェント活用 | 調査タスクはAgentツールに委譲（40%+トークン節約） |
| `/simplify` | 変更コードのリファクタ（3並列reviewerエージェント）— v2.1.60+ |
| `/batch` | 大規模コード変更（5-30並列エージェント）— v2.1.60+ |
| `/debug` | セッションのデバッグログ分析 — v2.1.60+ |
| `/rewind` | ファイル変更の巻き戻し（Esc x2） |

### コンテキスト管理の更新

- 実効コンテキスト: 約167K（バッファ33K）
- 自動compactionが64-75%で発動
- 200K超は割増料金（2x入力/1.5x出力）

---

## 4. 展開状況

| リポジトリ | /recover | commit+push | CLAUDE.md更新 |
|-----------|----------|-------------|---------------|
| account-management | 済 | 済 | 要対応 |
| evm-app | 済 | 済 | 要対応 |
| facility-safety | 済 | 済 | 要対応 |
| fixed-wing-knowledge | 済 | 済 | 要対応 |
| flying-robot-rule-coding-private | 済 | 済 | 要対応 |
| gdrive-materials-archive | 済 | 済 | 要対応 |
| jsbsim_fg | 済 | gitignored | 要対応 |
| jsbsim-flightgear-guide | 済 | 済 | 要対応 |
| jsbsim-flight-sim-private | 済 | 済 | 要対応 |
| ocr-app | 済 | 済 | 要対応 |
| pst_dev_docs | 済 | 済 | 要対応 |
| research-workspace | 済 | 済 | 要対応 |
| rockets-facilities | 済 | 済 | 要対応 |
| rockets-facilities- | 済 | untracked | 要対応 |
| space-antenna-infrastructure | 済 | 済 | 要対応 |
| space-fund-curation | 済 | 済 | 要対応 |
| tech-articles | 済 | 済 | 要対応 |
| tech-research-portfolio | 済 | 済 | 要対応 |
| tech-v2-research-portfolio | 済 | 済 | 要対応 |
| transcription-workspace | 済 | 済 | 要対応 |
| vibration-diagnosis-prototype | 済 | 済 | 要対応 |
| prompt-patterns | 済 | 済 | 済 |

---

## 5. 対応手順（各リポジトリでの作業時）

各リポジトリで次回セッションを開始する際に:

1. このnoticeの「追記内容テンプレート」をCLAUDE.mdにコピー
2. リポジトリ固有の調整（不要な項目の削除等）
3. コミット・プッシュ

**急ぎではありません**。次回そのリポジトリで作業する際に対応してください。

---

## 参照

- 調査報告書: `work/reports/WORK_REPORT_20260306_SESSION_STABILITY_AND_CCUSAGE.md`
- VSCodeクラッシュ問題: https://github.com/anthropics/claude-code/issues/27820
- ccusage: https://github.com/ryoppippi/ccusage
