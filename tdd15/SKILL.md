---
name: tdd15
description: 15-phase TDD workflow for Gleam/Rust. Phases 0-15 execute once then STOP.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task,TodoWrite,Skill,AskUserQuestion
model: sonnet
user-invocable: true
---

# /tdd15: 15-Phase TDD Workflow

```
/tdd15 <session-id>
```

Triage → Research → Plan → Verify → RED → GREEN → REFACTOR → MF#1 → Implement → VerifyCriteria → FP-Gates → QA → MF#2 → Consistency → Liability → Landing

---

## Nu Backbone

All state is managed by `tdd15.nu`. Claude is the creative executor; nu is the deterministic state machine.

**NEVER modify the blackboard YAML directly.** All state mutations go through `tdd15` commands.

```bash
T="$HOME/.claude/skills/tdd15/tdd15.nu"
nu $T <command>
```

State location: `~/.local/share/tdd15/<session>/blackboard.yml`

---

## Initialization

```bash
tdd15 init <session-id> --language <gleam|rust>
```

This creates the blackboard and a zjj workspace (`tdd15-<session-id>`).

Then begin Phase 0:
```bash
tdd15 phase-start <session-id> 0
```

See: `references/initialization.md`

---

## Phase Loop Protocol

For each phase:

1. **Start**: `tdd15 phase-start <id> <N>` — prints model, threshold, thinking trigger
2. **Execute**: Creative work (Claude does the actual coding/reviewing)
3. **Gate**: `tdd15 gate-check <id> <N> '<result-json>'`
   - Exit 0 = pass → `tdd15 advance <id>`
   - Exit 1 = retry or rewind (follow printed instructions)
   - Exit 2 = HALT (manual intervention required)

---

## DAG Rewind (replaces flat 3-retry)

When a gate fails, `tdd15 gate-check` decides the action:

| Attempt | Action | Model | Threshold | Thinking |
|---------|--------|-------|-----------|----------|
| 1 | Retry in-place | base | base | base |
| 2 | Rewind to `rewind_to` | upgraded | raised | escalated |
| 3 | Rewind to `escalation_target` | opus | max | ultrathink |
| 4+ | HALT (exit 2) | - | - | - |

Claude does NOT decide rewind targets — `tdd15 gate-check` decides.

See: `references/self-healing.md`

---

## Gate Result JSON Formats

Claude passes gate results as JSON:

- **Boolean**: `{"passed": true}`
- **Scored** (MF#1/MF#2): `{"score": 8, "questions": {"Q1": true, ...}}`
- **Parallel** (FP-Gates): `{"checks": {"immutability": true, ...}, "critical_count": 0}`
- **Triage** (Phase 0): `{"passed": true, "complexity": "simple", "route": [0,4,5,6,14,15]}`

---

## Anthropic Best Practices

Per [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices):

| Practice | How |
|----------|-----|
| Separate exploration/execution | Phase 1 before Phase 5 |
| Be explicitly specific | Prompts have criteria + penalties |
| Parallel verification | Phase 10: 5x haiku in parallel |
| Deterministic state | YAML blackboard via nu CLI |
| Subagent investigation | Task agents preserve context |
| Extended thinking | Escalated per attempt |

---

## Phase-Agent-Model Mapping

| Phase | Name | Agent | Base Model | Gate |
|-------|------|-------|------------|------|
| 0 | TRIAGE | Inline | - | complexity_assessed |
| 1 | RESEARCH | Task(Explore) | haiku | sufficient_context |
| 2 | PLAN | Task(Plan) | sonnet | plan_verified |
| 3 | VERIFY | Task(Plan) | sonnet | plan_verified_llm |
| 4 | RED | Task(general-purpose) | haiku | tests_fail |
| 5 | GREEN | Task(general-purpose) | sonnet | tests_pass |
| 6 | REFACTOR | Task(general-purpose) | haiku | tests_green |
| 7 | MF#1 | Task(code-reviewer) | sonnet | martin_fowler_1 |
| 8 | IMPLEMENT | Task(general-purpose) | sonnet | implementation_complete |
| 9 | VERIFY-CRITERIA | Task(general-purpose) | haiku | criteria_met |
| 10 | FP-GATES | 5x Task(general-purpose) | haiku | no_critical_issues |
| 11 | QA | Task(general-purpose) | haiku | qa_pass |
| 12 | MF#2 | Task(code-reviewer) | **opus** | martin_fowler_2 |
| 13 | CONSISTENCY | Task(code-reviewer) | haiku | standards_met |
| 14 | LIABILITY | Inline | - | minimized |
| 15 | LANDING | Skill(landing-skill) | - | push_succeeded |

Models escalate on retry: haiku→sonnet→opus (see DAG Rewind above).

---

## Complexity Routing

| Complexity | Phases | Savings |
|------------|--------|---------|
| SIMPLE | 0→4→5→6→14→15 | ~60% |
| MEDIUM | 0→1→2→4→5→6→7→9→11→15 | ~35% |
| COMPLEX | All 16 phases | 0% |

View routes: `tdd15 route simple`, `tdd15 route medium`, `tdd15 route complex`

See: `references/phase-00-triage.md`

---

## Extended Thinking Triggers

Base triggers (escalate on retry):

| Phase | Base Trigger |
|-------|-------------|
| 2 | "think step by step" |
| 3 | "think hard" |
| 5 | "think about edge cases" |
| 7 | "think hard, be rigorous" |
| 12 | "ultrathink" |

Query current: `tdd15 phase-start <id> <N>` prints the thinking trigger.

---

## zjj Workspace Integration

Sessions use zjj for workspace isolation:
- `tdd15 init` creates workspace `tdd15-<session-id>`
- `tdd15 land` runs `zjj done tdd15-<session-id>`
- Work happens in the isolated zjj workspace

---

## State Management

Blackboard at `~/.local/share/tdd15/<session>/blackboard.yml` (managed by nu CLI).

Phase artifacts (creative outputs) remain in `.tdd15-cache/` as before:
- `research.json`, `plan.json`, `mf1.json`, `omarchy.json`, `mf2.json`

See: `references/state-management.md`

---

## Language-Specific Behavior

Detected in Phase 0, affects phases 4-6, 10, 13:

| Language | Test Cmd | Format Cmd | FP Checks |
|----------|----------|------------|-----------|
| Gleam | `gleam test` | `gleam format` | 7 Commandments |
| Rust | `cargo test` | `cargo fmt && cargo clippy` | Zero panics |

See: `references/gleam-conventions.md`, `references/rust-conventions.md`

---

## Useful Commands

```bash
tdd15 status <id>    # Full status with route visualization
tdd15 dag            # Print full DAG with rewind arrows
tdd15 validate <id>  # Re-check all completed gates
tdd15 show <id>      # Raw blackboard YAML
tdd15 reset <id>     # Destructive reset
```

---

## Landing

```bash
tdd15 land <id>
```

Runs `zjj done` and marks session completed.

---

## Phase Details

Each phase has detailed prompts and criteria in reference docs:

- `references/phase-00-triage.md`
- `references/phase-01-research.md` through `references/phase-15-landing.md`

---

## Sources

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Prompting Best Practices](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
