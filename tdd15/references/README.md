# TDD15 References

Progressive disclosure docs. Main skill links here for details.

## Core

| File | Purpose |
|------|---------|
| `initialization.md` | Setup steps, progress.json schema |
| `state-management.md` | Cache structure, JSON protocol |
| `self-healing.md` | 3-retry protocol, fix actions |
| `gleam-conventions.md` | 7 Commandments, Intent CLI modules |
| `rust-conventions.md` | Zero panics, Railway-Oriented |

## Phases

| Phase | File | Model | Gate |
|-------|------|-------|------|
| 0 | `phase-00-triage.md` | - | complexity_assessed |
| 1 | `phase-01-research.md` | haiku | sufficient_context |
| 2 | `phase-02-plan.md` | sonnet | plan_verified |
| 3 | `phase-03-verify.md` | sonnet | plan_verified_llm |
| 4 | `phase-04-red.md` | haiku | tests_fail |
| 5 | `phase-05-green.md` | sonnet | tests_pass |
| 6 | `phase-06-refactor.md` | haiku | tests_green |
| 7 | `phase-07-martin-fowler-1.md` | sonnet | martin_fowler_1 |
| 8 | `phase-08-implement.md` | sonnet | implementation_complete |
| 9 | `phase-09-verify-criteria.md` | haiku | criteria_met |
| 10 | `phase-10-fp-gates.md` | 5x haiku | no_critical_issues |
| 11 | `phase-11-qa.md` | haiku | qa_pass |
| 12 | `phase-12-martin-fowler-2.md` | **opus** | martin_fowler_2 |
| 13 | `phase-13-consistency.md` | haiku | standards_met |
| 14 | `phase-14-code-liability.md` | - | minimized |
| 15 | `phase-15-landing.md` | - | push_succeeded |

## Model Distribution

- **haiku** (7): Research, RED, REFACTOR, Verify, FP×5, QA, Consistency
- **sonnet** (5): Plan, Verify-LLM, GREEN, MF#1, Implement
- **opus** (1): MF#2 (final gate)
- **inline** (3): Triage, Liability, Landing

## Complexity Routes

| Complexity | Phases | Savings |
|------------|--------|---------|
| SIMPLE | 0→4→5→6→14→15 | ~60% |
| MEDIUM | 0→1→2→4→5→6→7→9→11→15 | ~35% |
| COMPLEX | All 16 | 0% |
