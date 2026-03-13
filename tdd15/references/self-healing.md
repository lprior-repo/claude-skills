# Self-Healing Protocol: DAG Rewind

## Overview

Replaces the flat 3-retry loop. The `tdd15 gate-check` command deterministically decides retry, rewind, or halt based on attempt count and the phase DAG.

Claude does NOT decide rewind targets — `tdd15 gate-check` decides and prints instructions.

## Escalation Table

| Attempt | Action | Model | Threshold | Thinking |
|---------|--------|-------|-----------|----------|
| 1 | Retry in-place | base | base | base |
| 2 | Rewind to `rewind_to` | upgraded (haiku→sonnet, sonnet→opus) | raised | escalated |
| 3 | Rewind to `escalation_target` | opus | max | ultrathink |
| 4+ | HALT (exit 2) | - | - | - |

## DAG Rewind Map

| Phase | Name | rewind_to | escalation_target |
|-------|------|-----------|-------------------|
| 0 | TRIAGE | - | - |
| 1 | RESEARCH | 0:TRIAGE | - |
| 2 | PLAN | 1:RESEARCH | 0:TRIAGE |
| 3 | VERIFY | 2:PLAN | 1:RESEARCH |
| 4 | RED | 2:PLAN | 1:RESEARCH |
| 5 | GREEN | 4:RED | 2:PLAN |
| 6 | REFACTOR | 5:GREEN | 4:RED |
| 7 | MF#1 | 6:REFACTOR | 4:RED |
| 8 | IMPLEMENT | 7:MF#1 | 6:REFACTOR |
| 9 | VERIFY-CRITERIA | 8:IMPLEMENT | 5:GREEN |
| 10 | FP-GATES | 8:IMPLEMENT | 6:REFACTOR |
| 11 | QA | 8:IMPLEMENT | 5:GREEN |
| 12 | MF#2 | 8:IMPLEMENT | 6:REFACTOR |
| 13 | CONSISTENCY | 12:MF#2 | 8:IMPLEMENT |
| 14 | LIABILITY | 13:CONSISTENCY | 8:IMPLEMENT |
| 15 | LANDING | 14:LIABILITY | - |

## How It Works

### Attempt 1: Retry in-place
- Same model, same threshold, same thinking
- Gate check returns exit 1 with RETRY instruction
- Claude re-executes the phase with diagnostic context

### Attempt 2: Rewind to dependency
- Model upgraded one tier (haiku→sonnet, sonnet→opus)
- Threshold raised (more lenient)
- Thinking escalated to "think hard"
- All intermediate phases reset to pending
- `tdd15 gate-check` prints the rewind target and new parameters

### Attempt 3: Rewind to escalation target
- Model forced to opus
- Threshold at maximum leniency
- Thinking set to "ultrathink"
- Deeper rewind to escalation target
- Last chance before HALT

### Attempt 4+: HALT
- Session status set to "halted"
- Exit code 2
- Manual intervention required
- Full diagnostic in blackboard

## Protocol for Claude

```
1. tdd15 phase-start <id> <N>     # Get model/threshold/thinking
2. Execute creative work
3. tdd15 gate-check <id> <N> '<result>'
   - Exit 0 → tdd15 advance <id>
   - Exit 1 → Read printed instructions, follow rewind/retry
   - Exit 2 → HALT, surface to user
```

## Self-Heal Actions by Phase

| Phase | Gate | Fix Action on Retry |
|-------|------|---------------------|
| 0 | complexity_assessed | Re-examine, adjust classification |
| 1 | sufficient_context | Expand search scope |
| 2 | plan_verified | Refine plan, add missing criteria |
| 3 | plan_verified_llm | Address gaps, re-evaluate |
| 4 | tests_fail | Fix syntax, adjust assertions |
| 5 | tests_pass | Fix implementation bugs |
| 6 | tests_green | Revert refactor, try simpler |
| 7 | martin_fowler_1 | Fix lowest-scoring criteria |
| 8 | implementation_complete | Fix build errors |
| 9 | criteria_met | Add missing verification |
| 10 | no_critical_issues | Fix FP violations |
| 11 | qa_pass | Fix failing scenarios |
| 12 | martin_fowler_2 | Fix issues with escalated rigor |
| 13 | standards_met | Fix violations automatically |
| 14 | minimized | Restore deleted code, re-minimize |
| 15 | push_succeeded | Fix git conflicts |

## Viewing Rewind History

```bash
tdd15 status <id>   # Shows rewind log at bottom
tdd15 show <id>     # Full blackboard including rewind_log array
```
