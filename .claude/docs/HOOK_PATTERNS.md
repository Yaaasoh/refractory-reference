# Hook Patterns Reference

**Version**: 1.0
**Last Updated**: 2025-12-27
**Sources**: GitHub implementations (6 repositories) + Phase 4 custom hooks

---

## Purpose

This document catalogs **15+ proven Hook patterns** for Claude Code, organized by lifecycle event and use case. Hooks are executable scripts that run at specific points in Claude Code's execution lifecycle.

**Target Audience**: Hook creators, DevOps engineers, Claude Code customization specialists

**Key Benefit**: Automated quality enforcement, monitoring, and workflow optimization

---

## Lifecycle Events (8 Types)

Claude Code provides **8 lifecycle events** where hooks can execute:

| Event | When It Fires | Common Use Cases |
|-------|---------------|------------------|
| **UserPromptSubmit** | Before user prompt processed | Context detection, skill auto-activation, input filtering |
| **PreToolUse** | Before tool execution | Safety checks, tampering prevention, permission validation |
| **PostToolUse** | After tool execution | Verification reminders, logging, formatting |
| **SessionStart** | Session initialization | Environment setup, welcome messages, rule loading |
| **SessionEnd** | Session termination | Cleanup, summary generation, metric reporting |
| **ToolApprovalRequest** | When tool needs approval | Custom approval logic, risk assessment |
| **ToolApprovalResponse** | After approval decision | Logging, audit trail |
| **Error** | When error occurs | Error handling, recovery, notification |

---

## Hook I/O Format (JSON)

**All hooks** use JSON for input/output:

**Input** (from Claude Code):
```json
{
  "event": "UserPromptSubmit",
  "prompt": "User's message",
  "tool": "ToolName",
  "file_path": "/path/to/file",
  "command": "bash command",
  "exit_code": 0,
  ...
}
```

**Output** (from hook):
```json
{
  "blocked": false,
  "message": "Optional message to display"
}
```

**Critical Fields**:
- `blocked`: `true` = stop execution, `false` = continue
- `message`: Displayed to user if provided

---

## Pattern Categories

### Category 1: Quality Enforcement (4 patterns)

#### Pattern 1: Test Tampering Detection (PreToolUse)

**Purpose**: Prevent modifications to test files that weaken quality
**Lifecycle**: PreToolUse (Edit, Write tools)
**FP Target**: FP-1 (Test Tampering)

**Implementation**:
```bash
#!/usr/bin/env bash
# quality_check.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // ""')

# Only check Edit/Write tools
if [ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# Protected file patterns
PROTECTED_PATTERNS=(
  "test.*\\.py$"
  ".*\\.test\\.js$"
  ".*\\.spec\\.ts$"
  "\\.eslintrc"
  "pytest\\.ini$"
  ".github/workflows/.*\\.yml$"
)

IS_PROTECTED=false
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qE "$pattern"; then
    IS_PROTECTED=true
    break
  fi
done

if [ "$IS_PROTECTED" = false ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# Warning for protected files
MESSAGE="⚠️ Quality Check Warning (FP-1)

You are about to modify a protected file: $FILE_PATH

**Protected File Types**:
- Test files
- Lint configuration
- CI/CD configuration

**Anti-Tampering Rules**:
❌ Don't weaken tests to make them pass
❌ Don't loosen lint rules to hide warnings
✅ Fix implementation to pass tests

See: docs/rules/test.md"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{
  blocked: false,
  message: $msg
}'
```

**Characteristics**:
- Non-blocking (educational approach)
- Pattern-based file detection
- Clear guidance in warning message

**Source**: Phase 4 Step 4 (this project)

---

#### Pattern 2: False Completion Detection (UserPromptSubmit)

**Purpose**: Detect completion claims without verification evidence
**Lifecycle**: UserPromptSubmit
**FP Target**: FP-7 (False Completion)

**Implementation**:
```bash
#!/usr/bin/env bash
# prevent_false_completion.sh
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

[ -z "$PROMPT" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Completion keywords
COMPLETION_PATTERNS=("完了" "完成" "終了" "できました" "completed" "done")

HAS_COMPLETION=false
for pattern in "${COMPLETION_PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qi "$pattern"; then
    HAS_COMPLETION=true
    break
  fi
done

[ "$HAS_COMPLETION" = false ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Verification keywords
VERIFICATION_KEYWORDS=("テスト" "確認" "検証" "test" "verify" "pass")

HAS_VERIFICATION=false
for keyword in "${VERIFICATION_KEYWORDS[@]}"; do
  if echo "$PROMPT" | grep -qi "$keyword"; then
    HAS_VERIFICATION=true
    break
  fi
done

[ "$HAS_VERIFICATION" = true ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Completion without verification → Warning
MESSAGE="⚠️ False Completion Warning (FP-7)

Your message contains completion keywords but lacks verification evidence.

**Missing verification**: Test results, confirmation, pass evidence

**Task Integrity Rules**:
- Completed = Implemented + Tested + Verified + Evidence
- Don't claim completion without verification

See: docs/rules/task-integrity.md"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{
  blocked: false,
  message: $msg
}'
```

**Characteristics**:
- Keyword-based detection
- Two-stage check (completion + verification)
- Non-blocking educational warning

**Source**: Phase 4 Step 4 (this project)

---

#### Pattern 3: Deployment Verification Reminder (PostToolUse)

**Purpose**: Remind to verify after deployment commands
**Lifecycle**: PostToolUse (Bash tool)
**FP Target**: FP-9 (Deployment Verification Neglect)

**Implementation**:
```bash
#!/usr/bin/env bash
# post_deploy_verification.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
COMMAND=$(echo "$INPUT" | jq -r '.command // ""')
EXIT_CODE=$(echo "$INPUT" | jq -r '.exit_code // 0')

[ "$TOOL" != "Bash" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Deployment command patterns
DEPLOY_PATTERNS=("npm install" "pip install" "git clone" "git pull" "docker" "deploy" "rsync")

IS_DEPLOY=false
for pattern in "${DEPLOY_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    IS_DEPLOY=true
    break
  fi
done

[ "$IS_DEPLOY" = false ] && echo "$INPUT" | jq '{blocked: false}' && exit 0
[ "$EXIT_CODE" != "0" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

MESSAGE="🔍 Deployment Verification Reminder (FP-9)

Deployment command executed: $COMMAND

**Next Steps**:
1. Verify deployment succeeded
2. Test functionality
3. Collect evidence (screenshots, logs)

**4-Stage Verification**:
- Pre-Deploy: Files, environment, backups
- During Deploy: Command output
- Post-Deploy: HTTP check, functionality test
- DoD: All checks passed + evidence

See: docs/rules/deployment.md"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{
  blocked: false,
  message: $msg
}'
```

**Characteristics**:
- Triggers only on deployment commands
- Only reminds if command succeeded (exit code 0)
- Provides verification checklist

**Source**: Phase 4 Step 4 (this project)

---

#### Pattern 4: Code Formatting (PostToolUse)

**Purpose**: Auto-format code after file modifications
**Lifecycle**: PostToolUse (Edit, Write tools)
**Benefit**: Consistent code style

**Implementation**:
```bash
#!/usr/bin/env bash
# auto_format.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // ""')

[ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Format based on file extension
if echo "$FILE_PATH" | grep -qE '\\.js$|\\.ts$|\\.jsx$|\\.tsx$'; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
elif echo "$FILE_PATH" | grep -qE '\\.py$'; then
  black "$FILE_PATH" 2>/dev/null || true
fi

echo "$INPUT" | jq '{blocked: false}'
```

**Characteristics**:
- Silent operation (no user message)
- Language-specific formatters
- Non-blocking (formatting errors ignored)

**Source**: Community pattern (hesreallyhim/awesome-claude-code)

---

### Category 2: Skill Activation (2 patterns)

#### Pattern 5: Context-Based Skill Auto-Activation (UserPromptSubmit)

**Purpose**: Auto-activate relevant skills based on prompt context
**Lifecycle**: UserPromptSubmit
**Benefit**: Skills invoked automatically when needed

**Implementation**:
```bash
#!/usr/bin/env bash
# auto_activate_skills.sh
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

[ -z "$PROMPT" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

generate_skill_message() {
  local skill_name="$1"
  local reason="$2"
  echo "🎯 Auto-Activating Skill: $skill_name

Reason: $reason

This skill will guide you through the process with best practices.

See: .claude/skills/$skill_name/SKILL.md"
}

# code-quality-enforcer (FP-1, FP-2)
if echo "$PROMPT" | grep -qiE "(実装|implement|機能追加|add feature|バグ修正|fix bug)"; then
  MESSAGE=$(generate_skill_message "code-quality-enforcer" "Implementation/bugfix detected")
  echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
  exit 0
fi

# deployment-verifier (FP-9)
if echo "$PROMPT" | grep -qiE "(デプロイ|deploy|インストール|install)"; then
  MESSAGE=$(generate_skill_message "deployment-verifier" "Deployment command detected")
  echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
  exit 0
fi

# purpose-driven-impl (FP-3)
if echo "$PROMPT" | grep -qiE "(新規|new|追加|add|作成|create)"; then
  if ! echo "$PROMPT" | grep -qiE "(目的|purpose|なぜ|why)"; then
    MESSAGE=$(generate_skill_message "purpose-driven-impl" "New feature without clear purpose")
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
    exit 0
  fi
fi

# root-cause-analyzer (FP-8)
if echo "$PROMPT" | grep -qiE "(エラー|error|問題|problem|バグ|bug)"; then
  if ! echo "$PROMPT" | grep -qiE "(確認|check|調査|investigate|ログ|log)"; then
    MESSAGE=$(generate_skill_message "root-cause-analyzer" "Error reported without investigation")
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
    exit 0
  fi
fi

echo "$INPUT" | jq '{blocked: false}'
```

**Characteristics**:
- Pattern-based context detection
- Non-blocking (suggests, doesn't force)
- Clear reason for activation

**Source**: Phase 4 Step 4 (this project), inspired by diet103 pattern

---

#### Pattern 6: Manual Skill Invocation Helper (UserPromptSubmit)

**Purpose**: Detect skill invocation requests and load skill
**Lifecycle**: UserPromptSubmit
**Benefit**: Easier skill invocation syntax

**Implementation**:
```bash
#!/usr/bin/env bash
# skill_invoker.sh
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# Detect "/skill-name" or "use skill-name" patterns
if echo "$PROMPT" | grep -qE "^/[a-z-]+$|use [a-z-]+ skill"; then
  SKILL_NAME=$(echo "$PROMPT" | sed -E 's|^/([a-z-]+)$|\1|; s|use ([a-z-]+) skill|\1|')

  if [ -f ".claude/skills/$SKILL_NAME/SKILL.md" ]; then
    MESSAGE="✅ Activating skill: $SKILL_NAME"
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
  else
    MESSAGE="❌ Skill not found: $SKILL_NAME"
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
  fi
  exit 0
fi

echo "$INPUT" | jq '{blocked: false}'
```

**Characteristics**:
- Shorthand syntax for skill invocation
- File existence check
- User-friendly error messages

**Source**: Community pattern (diet103)

---

### Category 3: Monitoring & Logging (3 patterns)

#### Pattern 7: Real-Time File Operation Tracking (PreToolUse + PostToolUse)

**Purpose**: Monitor all file operations in real-time
**Lifecycle**: PreToolUse + PostToolUse (Edit, Write tools)
**Benefit**: Audit trail, debugging

**Implementation** (PreToolUse):
```bash
#!/usr/bin/env bash
# file_tracking_pre.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // ""')

[ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$TIMESTAMP | PRE  | $TOOL | $FILE_PATH" >> .claude/logs/file_operations.log

echo "$INPUT" | jq '{blocked: false}'
```

**Implementation** (PostToolUse):
```bash
#!/usr/bin/env bash
# file_tracking_post.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // ""')

[ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$TIMESTAMP | POST | $TOOL | $FILE_PATH" >> .claude/logs/file_operations.log

echo "$INPUT" | jq '{blocked: false}'
```

**Log Format**:
```
2025-12-27T10:30:00Z | PRE  | Edit | src/components/Button.tsx
2025-12-27T10:30:05Z | POST | Edit | src/components/Button.tsx
```

**Source**: Community pattern (hesreallyhim/awesome-claude-code)

---

#### Pattern 8: Multi-Agent Observability (All Events)

**Purpose**: Monitor multiple Claude Code sessions in real-time
**Lifecycle**: All 8 events
**Benefit**: Coordination, performance monitoring

**Architecture**:
```
Claude Session 1 → Hook → HTTP POST → Backend Server
Claude Session 2 → Hook → HTTP POST →   (Bun TS)  → Frontend
Claude Session 3 → Hook → HTTP POST →             (Vue 3)
```

**Implementation** (Generic hook):
```bash
#!/usr/bin/env bash
# observability_hook.sh
set -euo pipefail

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.event // "unknown"')

# Send to monitoring server
curl -X POST http://localhost:3000/hook-event \
  -H "Content-Type: application/json" \
  -d "$INPUT" \
  2>/dev/null || true

echo "$INPUT" | jq '{blocked: false}'
```

**Backend** (receives events, serves frontend):
- Collects events from all hooks
- Stores in time-series DB
- Provides WebSocket stream to frontend

**Frontend** (visualizes):
- Real-time event timeline
- Agent coordination view
- Performance metrics

**Source**: Community pattern (disler/claude-code-hooks-multi-agent-observability)

---

#### Pattern 9: Session Summary Generation (SessionEnd)

**Purpose**: Generate summary report at session end
**Lifecycle**: SessionEnd
**Benefit**: Review, documentation

**Implementation**:
```bash
#!/usr/bin/env bash
# session_summary.sh
set -euo pipefail

INPUT=$(cat)

# Read session log
LOG_FILE=".claude/logs/file_operations.log"
[ ! -f "$LOG_FILE" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Generate summary
EDIT_COUNT=$(grep "| POST | Edit" "$LOG_FILE" | wc -l)
WRITE_COUNT=$(grep "| POST | Write" "$LOG_FILE" | wc -l)
TOTAL=$((EDIT_COUNT + WRITE_COUNT))

MESSAGE="📊 Session Summary

Files modified: $TOTAL
- Edit operations: $EDIT_COUNT
- Write operations: $WRITE_COUNT

Full log: $LOG_FILE"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
```

**Source**: Custom pattern

---

### Category 4: Safety & Security (3 patterns)

#### Pattern 10: Sensitive Data Filtering (UserPromptSubmit)

**Purpose**: Filter sensitive data from prompts before processing
**Lifecycle**: UserPromptSubmit
**Benefit**: Prevent accidental exposure

**Implementation**:
```bash
#!/usr/bin/env bash
# sensitive_data_filter.sh
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# Sensitive patterns
SENSITIVE_PATTERNS=(
  "password"
  "api[_-]?key"
  "secret"
  "token"
  "credit[_-]?card"
  "ssn"
)

HAS_SENSITIVE=false
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qiE "$pattern"; then
    HAS_SENSITIVE=true
    break
  fi
done

if [ "$HAS_SENSITIVE" = true ]; then
  MESSAGE="⚠️ Sensitive Data Warning

Your prompt may contain sensitive information.

Please remove or mask:
- Passwords
- API keys
- Secrets/tokens
- Credit card numbers
- SSNs

Edit your prompt and try again."

  echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
  exit 0
fi

echo "$INPUT" | jq '{blocked: false}'
```

**Characteristics**:
- Pattern-based detection
- Non-blocking (warns, doesn't block)
- Keyword-based (not perfect, but helpful)

**Source**: Community pattern (hesreallyhim)

---

#### Pattern 11: Dangerous Command Blocker (PreToolUse)

**Purpose**: Block truly dangerous commands
**Lifecycle**: PreToolUse (Bash tool)
**Benefit**: Prevent catastrophic errors

**Implementation**:
```bash
#!/usr/bin/env bash
# dangerous_command_blocker.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
COMMAND=$(echo "$INPUT" | jq -r '.command // ""')

[ "$TOOL" != "Bash" ] && echo "$INPUT" | jq '{blocked: false}' && exit 0

# Truly dangerous patterns
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf /\*"
  "> /dev/sda"
  "dd if=/dev/zero"
  "mkfs\\."
  ":(){ :|:& };:"  # Fork bomb
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$pattern"; then
    MESSAGE="🛑 BLOCKED: Dangerous Command

Command: $COMMAND

This command is extremely dangerous and has been blocked.

If you need to perform this operation, do it manually."

    echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: true, message: $msg}'
    exit 0
  fi
done

echo "$INPUT" | jq '{blocked: false}'
```

**Characteristics**:
- **Blocking** (blocked: true)
- Only blocks truly catastrophic commands
- Clear explanation

**Source**: Best practice (phase 4 research)

---

#### Pattern 12: Permission Audit Logger (ToolApprovalResponse)

**Purpose**: Log all permission approval decisions
**Lifecycle**: ToolApprovalResponse
**Benefit**: Audit trail, security review

**Implementation**:
```bash
#!/usr/bin/env bash
# permission_audit.sh
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
APPROVED=$(echo "$INPUT" | jq -r '.approved // false')
COMMAND=$(echo "$INPUT" | jq -r '.command // ""')

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
AUDIT_LOG=".claude/logs/permission_audit.log"

echo "$TIMESTAMP | $TOOL | $APPROVED | $COMMAND" >> "$AUDIT_LOG"

echo "$INPUT" | jq '{blocked: false}'
```

**Log Format**:
```
2025-12-27T10:30:00Z | Bash | true | git push origin main
2025-12-27T10:35:00Z | Bash | false | rm -rf node_modules
```

**Source**: Custom pattern

---

### Category 5: Session Management (3 patterns)

#### Pattern 13: Environment Setup (SessionStart)

**Purpose**: Initialize environment at session start
**Lifecycle**: SessionStart
**Benefit**: Consistent setup

**Implementation**:
```bash
#!/usr/bin/env bash
# session_setup.sh
set -euo pipefail

INPUT=$(cat)

# Create log directories
mkdir -p .claude/logs

# Load environment variables
[ -f .env ] && source .env

# Display welcome message
MESSAGE="========================================
   prompt-patterns セッション開始
========================================

【重要】このリポジトリでは破壊的コマンドが禁止されています。

  禁止: rm -rf, git clean -fd, git reset --hard
  詳細: CLAUDE.md

【作業ディレクトリ】
  - 作業は work/ で行ってください

========================================"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
```

**Characteristics**:
- Runs once per session
- Sets up environment
- Displays important info

**Source**: Phase 4 (this project - sessionstart:compact hook)

---

#### Pattern 14: Session Cleanup (SessionEnd)

**Purpose**: Clean up temporary files at session end
**Lifecycle**: SessionEnd
**Benefit**: No leftover artifacts

**Implementation**:
```bash
#!/usr/bin/env bash
# session_cleanup.sh
set -euo pipefail

INPUT=$(cat)

# Clean temporary files
rm -f .claude/temp/* 2>/dev/null || true

# Archive session log
if [ -f ".claude/logs/file_operations.log" ]; then
  TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
  mv ".claude/logs/file_operations.log" ".claude/logs/archive/session_$TIMESTAMP.log"
fi

echo "$INPUT" | jq '{blocked: false}'
```

**Source**: Custom pattern

---

#### Pattern 15: Error Recovery (Error)

**Purpose**: Attempt automatic recovery from errors
**Lifecycle**: Error
**Benefit**: Resilience

**Implementation**:
```bash
#!/usr/bin/env bash
# error_recovery.sh
set -euo pipefail

INPUT=$(cat)
ERROR_MESSAGE=$(echo "$INPUT" | jq -r '.error // ""')

# Log error
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$TIMESTAMP | ERROR | $ERROR_MESSAGE" >> .claude/logs/errors.log

# Attempt recovery based on error type
if echo "$ERROR_MESSAGE" | grep -qi "rate limit"; then
  MESSAGE="⏸️ Rate Limit Error

Rate limit reached. Recommendations:
1. Wait 60 seconds and retry
2. Use /clear to reduce context size
3. Break task into smaller steps

See: docs/troubleshooting.md#rate-limits"

  echo "$INPUT" | jq --arg msg "$MESSAGE" '{blocked: false, message: $msg}'
  exit 0
fi

# Default: just log
echo "$INPUT" | jq '{blocked: false}'
```

**Source**: Custom pattern

---

## Implementation Best Practices

### 1. Hook Script Requirements

**Shebang**:
```bash
#!/usr/bin/env bash
```

**Error Handling**:
```bash
set -euo pipefail
```

**JSON Processing**:
```bash
# Requires jq
INPUT=$(cat)  # Read from stdin
OUTPUT=$(echo "$INPUT" | jq '...')  # Process JSON
```

**Permissions**:
```bash
chmod +x .claude/hooks/*.sh
```

---

### 2. Performance Considerations

**Fast Execution**:
- Target <100ms per hook
- Avoid heavy computations
- Use background processes for slow operations

**Example** (slow operation backgrounded):
```bash
# BAD: Blocks for 5 seconds
sleep 5
echo "$INPUT" | jq '{blocked: false}'

# GOOD: Runs in background
(sleep 5 && do_something) &
echo "$INPUT" | jq '{blocked: false}'
```

---

### 3. Error Handling

**Always Provide Output**:
```bash
# If hook fails, still output valid JSON
trap 'echo "{\"blocked\": false}" >&2; exit 1' ERR

# Your hook logic here
...
```

**Fail-Safe**:
```bash
# If unsure, don't block
echo "$INPUT" | jq '{blocked: false}'
```

---

### 4. Testing Hooks

**Test JSON I/O**:
```bash
# Simulate UserPromptSubmit event
echo '{"event": "UserPromptSubmit", "prompt": "implement feature"}' | .claude/hooks/auto_activate_skills.sh

# Expect valid JSON output
```

**Test All Code Paths**:
```bash
# Test when condition matches
# Test when condition doesn't match
# Test with malformed input
# Test with missing fields
```

---

## References

**Primary Sources**:
- disler/claude-code-hooks-mastery: All 8 event examples
- hesreallyhim/awesome-claude-code: Quality check patterns
- disler/multi-agent-observability: Monitoring patterns
- johnlindquist/claude-hooks: TypeScript implementations
- diet103/infrastructure-showcase: Auto-activation pattern

**Phase 4 Custom Hooks**:
- `quality_check.sh`: FP-1 prevention
- `prevent_false_completion.sh`: FP-7 prevention
- `post_deploy_verification.sh`: FP-9 prevention
- `auto_activate_skills.sh`: Skill auto-activation

**Related Documentation**:
- `FAILURE_PATTERNS.md`: Patterns that hooks prevent
- `SKILL_CATALOG.md`: Skills activated by hooks
- Phase 3 Step 6: GitHub implementations analysis

---

**Last Updated**: 2025-12-27
**Version**: 1.0
**Maintainer**: Claude Code Research Project
