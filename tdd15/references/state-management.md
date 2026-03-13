# State Management

## YAML Blackboard

All workflow state lives in a YAML blackboard managed by the `tdd15` nu CLI.

**Location**: `~/.local/share/tdd15/<session>/blackboard.yml`

**Rule**: NEVER edit the blackboard directly. All mutations go through `tdd15` commands.

## Blackboard Schema

```yaml
session_id: "feat-email"
created_at: "2026-01-27T10:00:00"
language: "gleam"
complexity: "complex"           # pending | simple | medium | complex
route: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
zjj_session: "tdd15-feat-email"
current_phase: 4
status: "active"                # active | halted | completed
phases:
  0:
    status: "completed"         # pending | in_progress | completed | failed
    gate_passed: true
    attempts: 1
    threshold_used: 1.0
    model_used: null
    started_at: "2026-01-27T10:00:00"
    completed_at: "2026-01-27T10:01:00"
    gate_result: {}
  1:
    status: "pending"
    gate_passed: false
    attempts: 0
    threshold_used: null
    model_used: null
    started_at: null
    completed_at: null
    gate_result: {}
rewind_log: []
```

## Commands for State Access

| Command | Purpose |
|---------|---------|
| `tdd15 show <id>` | Raw YAML dump |
| `tdd15 status <id>` | Pretty status with route visualization |
| `tdd15 validate <id>` | Re-check all completed gates |
| `tdd15 phase-start <id> <N>` | Sets phase to in_progress, bumps attempts |
| `tdd15 gate-check <id> <N> '<json>'` | Evaluates gate, updates state |
| `tdd15 advance <id>` | Moves current_phase forward |
| `tdd15 rewind <id> <target>` | Manual rewind (gate-check does this automatically) |

## Phase Artifacts

Creative outputs still go in the local project `.tdd15-cache/` directory:

```
.tdd15-cache/<session>/
├── research.json   # Phase 1 output
├── plan.json       # Phase 2 output
├── mf1.json        # Phase 7 scores
├── omarchy.json    # Phase 10 FP results
└── mf2.json        # Phase 12 scores
```

These are Claude's working files. The blackboard tracks workflow state; artifacts track creative outputs.

## Context Passing Rules

1. Subagents receive JSON summaries, not full context
2. Read from cache files, don't re-research
3. State updates happen via `tdd15` CLI commands
4. Max 500 words per text summary
